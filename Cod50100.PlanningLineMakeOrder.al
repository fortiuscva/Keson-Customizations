codeunit 50100 "KES Planning Line Make Order"
{
    //TableNo = "KES Planning Line";

    procedure CreatePurchaseAndRelProdOrders(PlanningLinePar: Record "KES Planning Line")
    var
        PlanningLineRec: Record "KES Planning Line";
        PrevVendorNo: Code[50];
        NextLineNo: Integer;
        PurchOrderHeader: Record "Purchase Header";
        OrderDeleted: Boolean;
    begin
        PlanningLineRec.Copy(PlanningLinePar);

        PlanningLineRec.SetCurrentKey("Replenishment System", "Vendor No.");
        PlanningLineRec.SetRange("Accept Action Message", true);
        PlanningLineRec.SetFilter("Ord. Coverage Date", '<>%1', 0);
        if PlanningLineRec.FindSet() then
            repeat
                if PlanningLineRec."Replenishment System" = PlanningLineRec."Replenishment System"::Purchase then begin
                    if PrevVendorNo <> PlanningLineRec."Vendor No." then begin
                        PrevVendorNo := PlanningLineRec."Vendor No.";
                        CreatePurchaseOrder(PlanningLineRec, PurchOrderHeader, NextLineNo);
                    end else begin
                        NextLineNo := NextLineNo + 10000;
                        CreatePurchaseOrderLines(PurchOrderHeader, PlanningLineRec, NextLineNo);
                    end;
                    PlanningLineRec.Delete();
                end;
                if PlanningLineRec."Replenishment System" = PlanningLineRec."Replenishment System"::"Prod. Order" then begin
                    CreateReleaseProdOrder(PlanningLineRec, OrderDeleted);
                    if not OrderDeleted then
                        PlanningLineRec.Delete();
                end;

            until PlanningLineRec.Next() = 0;

        if OrderCreatedCounter > 0 then
            Message('%1 Order(s) are created successfully.', OrderCreatedCounter);
    end;


    local procedure CreatePurchaseOrder(PlanningLineLclPar: Record "KES Planning Line"; var PurchOrderHeader: Record "Purchase Header"; var NextLineNo: Integer)
    var
        PurchSetup: Record "Purchases & Payables Setup";
    begin
        Clear(NextLineNo);

        PurchSetup.Get();
        PurchSetup.TestField("Order Nos.");

        Clear(PurchOrderHeader);
        PurchOrderHeader.Init();
        PurchOrderHeader."Document Type" := PurchOrderHeader."Document Type"::Order;
        PurchOrderHeader."No." := '';
        PurchOrderHeader."Posting Date" := Today();
        PurchOrderHeader.Insert(true);
        PurchOrderHeader.Validate("Buy-from Vendor No.", PlanningLineLclPar."Vendor No.");
        if PurchOrderHeader.Modify(true) then
            OrderCreatedCounter += 1;

        NextLineNo := NextLineNo + 10000;
        CreatePurchaseOrderLines(PurchOrderHeader, PlanningLineLclPar, NextLineNo);
    end;

    local procedure CreatePurchaseOrderLines(var PurchOrderHeader: Record "Purchase Header"; PlanningLineLclPar: Record "KES Planning Line"; NextLineNoPar: Integer)
    var
        PurchOrderLine: Record "Purchase Line";
    begin
        Clear(PurchOrderLine);
        PurchOrderLine.Init();
        PurchOrderLine."Document Type" := PurchOrderLine."Document Type"::Order;
        PurchOrderLine."Document No." := PurchOrderHeader."No.";
        PurchOrderLine."Line No." := NextLineNoPar;
        PurchOrderLine.Insert(true);
        PurchOrderLine.Validate("Buy-from Vendor No.", PlanningLineLclPar."Vendor No.");
        PurchOrderLine.Validate(Type, PlanningLineLclPar.Type);
        PurchOrderLine.Validate("No.", PlanningLineLclPar."No.");
        PurchOrderLine.Validate("Unit of Measure Code", PlanningLineLclPar."Purch. Unit of Measure");
        PurchOrderLine.Validate("Order Date", PurchOrderHeader."Order Date");
        PurchOrderLine.Validate("Qty. Rounding Precision", 1);
        PurchOrderLine.Validate(Quantity, PlanningLineLclPar."Ord. Coverage Date");
        PurchOrderLine.Modify(true);
    end;

    local procedure CreateReleaseProdOrder(PlanningLineLclPar: Record "KES Planning Line"; var OrderDeletedPar: Boolean)
    var
        ProductionOrder: Record "Production Order";
        ProductionOrder2: Record "Production Order";
        ProductionOrderNo: Code[20];
        NextLineNo: Integer;
        RefreshProdOrderRep: Report "Refresh Production Order";
        Direction2: Option Forward,Backward;
        KESTestCod: Codeunit "KES Refresh Prod. Order";
        ErrorMessage: Text;
    begin
        Clear(NextLineNo);

        Clear(ProductionOrder);
        ProductionOrder.Init();
        ProductionOrder.Status := ProductionOrder.Status::Released;
        ProductionOrder."No." := '';
        ProductionOrder.Insert(true);

        ProductionOrder.Validate("Source Type", ProductionOrder."Source Type"::Item);
        ProductionOrder.Validate("Source No.", PlanningLineLclPar."No.");
        ProductionOrder.Validate(Quantity, PlanningLineLclPar."Ord. Coverage Date"); //CHECK
        if ProductionOrder.Modify(true) then begin
            Commit();
            ClearLastError();
            if not KESTestCod.Run(ProductionOrder) then begin
                ErrorMessage := GetLastErrorText();
                if ErrorMessage <> '' then begin
                    ProductionOrder.Delete();
                    OrderDeletedPar := true;
                    Message('%1', ErrorMessage);
                end;
            end else
                OrderCreatedCounter += 1;
        end;
    end;

    var
        OrderCreatedCounter: Integer;
}