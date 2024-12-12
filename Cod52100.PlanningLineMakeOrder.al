codeunit 52100 "KES Planning Line Make Order"
{
    //TableNo = "KES Planning Line";

    procedure CreatePurchaseAndRelProdOrders(PlanningLinePar: Record "KES Planning Line")
    begin
        PlanningLineRec.Copy(PlanningLinePar);

        CreatePurchaseOrder();
        //CreateReleaseProdOrder();

        if OrderCreatedCounter > 1 then begin
            Message('Order(s) are created successfully.');
            //PlanningLineRec.Reset();
            //PlanningLineRec.DeleteAll();
        end;
    end;

    local procedure CreatePurchaseOrder()
    var
        PrevVendorNo: Code[50];
        PurchSetup: Record "Purchases & Payables Setup";
        PurchOrderHeader: Record "Purchase Header";
        PurchaseOrdNo: Code[20];
        NextLineNo: Integer;
    begin
        PlanningLineRec.SetCurrentKey("Replenishment System", "Vendor No.");
        PlanningLineRec.SetRange("Replenishment System", PlanningLineRec."Replenishment System"::Purchase);
        PlanningLineRec.SetRange("Accept Action Message", true);
        if PlanningLineRec.FindSet() then
            repeat
                if PrevVendorNo <> PlanningLineRec."Vendor No." then begin
                    PrevVendorNo := PlanningLineRec."Vendor No.";
                    Clear(NextLineNo);

                    PurchSetup.Get();
                    PurchSetup.TestField("Order Nos.");

                    Clear(PurchOrderHeader);
                    PurchOrderHeader.Init();
                    PurchOrderHeader."Document Type" := PurchOrderHeader."Document Type"::Order;
                    PurchOrderHeader."No." := '';
                    PurchOrderHeader."Posting Date" := Today();
                    PurchOrderHeader.Insert(true);
                    PurchOrderHeader.Validate("Buy-from Vendor No.", PlanningLineRec."Vendor No.");
                    if PurchOrderHeader.Modify(true) then
                        OrderCreatedCounter += 1;

                    NextLineNo := NextLineNo + 10000;
                    CreatePurchaseOrderLines(PurchOrderHeader, PurchaseOrdNo, NextLineNo);
                    PurchaseOrdNo := PurchOrderHeader."No.";

                end else begin
                    NextLineNo := NextLineNo + 10000;
                    CreatePurchaseOrderLines(PurchOrderHeader, PurchaseOrdNo, NextLineNo);
                end;
            until PlanningLineRec.Next() = 0;
    end;

    local procedure CreatePurchaseOrderLines(var PurchOrderHeader: Record "Purchase Header"; var PurchaseOrdNo: Code[20]; NextLineNoPar: Integer)
    var
        PurchOrderLine: Record "Purchase Line";
    begin
        Clear(PurchOrderLine);
        PurchOrderLine.Init();
        PurchOrderLine."Document Type" := PurchOrderLine."Document Type"::Order;
        PurchOrderLine."Document No." := PurchOrderHeader."No.";
        PurchOrderLine."Line No." := NextLineNoPar;
        PurchOrderLine.Validate("Buy-from Vendor No.", PlanningLineRec."Vendor No.");
        PurchOrderLine.Validate(Type, PlanningLineRec.Type);
        PurchOrderLine.Validate("No.", PlanningLineRec."No.");
        PurchOrderLine.Validate("Unit of Measure Code", PlanningLineRec."Purch. Unit of Measure");
        PurchOrderLine.Validate("Order Date", PurchOrderHeader."Order Date");
        PurchOrderLine.Validate(Quantity, PlanningLineRec."Ord. Coverage Date");
        PurchOrderLine.Insert();
    end;

    local procedure CreateReleaseProdOrder()
    var
        ProductionOrder: Record "Production Order";
        ProductionOrderNo: Code[20];
        NextLineNo: Integer;
    begin
        PlanningLineRec.SetCurrentKey("Replenishment System");
        PlanningLineRec.SetRange("Replenishment System", PlanningLineRec."Replenishment System"::"Prod. Order");
        PlanningLineRec.SetRange("Accept Action Message", true);
        if PlanningLineRec.FindSet() then
            repeat
                Clear(NextLineNo);

                Clear(ProductionOrder);
                ProductionOrder.Init();
                ProductionOrder.Status := ProductionOrder.Status::Released;
                ProductionOrder."No." := '';
                ProductionOrder.Insert(true);

                ProductionOrder.Validate("Source Type", ProductionOrder."Source Type"::Item);
                ProductionOrder.Validate("Source No.", PlanningLineRec."No.");
                ProductionOrder.Validate(Quantity, PlanningLineRec."Ord. Coverage Date");
                if ProductionOrder.Modify(true) then
                    OrderCreatedCounter += 1;
            until PlanningLineRec.Next() = 0;
    end;

    var
        PlanningLineRec: Record "KES Planning Line";
        OrderCreatedCounter: Integer;
}
