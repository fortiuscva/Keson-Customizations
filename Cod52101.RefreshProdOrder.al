codeunit 52101 "KES Refresh Prod. Order"
{
    TableNo = "Production Order";
    trigger OnRun()
    var
        ProductionOrder2: Record "Production Order";
    begin
        ProductionOrder2.SetRange("No.", Rec."No.");
        ProductionOrder2.FindFirst();
        REPORT.RunModal(REPORT::"Refresh Production Order", false, false, ProductionOrder2);
    end;
}