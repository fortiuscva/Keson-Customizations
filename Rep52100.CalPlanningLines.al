report 52100 "KES Cal. Planning Lines"
{
    ApplicationArea = All;
    Caption = 'Cal. Planning Lines';
    UsageCategory = ReportsAndAnalysis;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = where(Blocked = const(false));
            RequestFilterFields = "No.", "Item Category Code", "Replenishment System", "Vendor No.";
            CalcFields = Inventory, "Qty. on Purch. Order", "Qty. on Prod. Order";

            trigger OnAfterGetRecord()
            begin
                PlanningLine.Reset();
                PlanningLine.SetRange("Worksheet Template Name", 'Planning');
                PlanningLine.SetRange("Journal Batch Name", 'Default');
                if PlanningLine.FindLast() then
                    NewLineNo := PlanningLine."Line No." + 10000
                else
                    NewLineNo := 10000;

                PlanningLine.Init();
                PlanningLine."Worksheet Template Name" := 'Planning';
                PlanningLine."Journal Batch Name" := 'Default';
                PlanningLine."Line No." := NewLineNo;
                PlanningLine.Insert();

                PlanningLine.Type := PlanningLine.Type::Item;
                PlanningLine.Validate("No.", Item."No.");
                PlanningLine."Qty. On Hand" := Item.Inventory;
                PlanningLine."Qty. on Purch. Order" := Item."Qty. on Purch. Order";
                PlanningLine."Qty. on Prod. Order" := Item."Qty. on Prod. Order";
                PlanningLine."Total Qty." := Item.Inventory + Item."Qty. on Purch. Order" + Item."Qty. on Prod. Order";
                PlanningLine."Last 12 Months" := GetLast12MonthsUsage(Item."No.");
                PlanningLine."Previous 12 Months" := GetLast24MonthsUsage(Item."No.");
                PlanningLine."Per Month Avg." := (PlanningLine."Last 12 Months" + PlanningLine."Previous 12 Months") / 24;
                PlanningLine."Auto Create" := true;
                PlanningLine."Replenishment System" := Item."Replenishment System";
                PlanningLine."Ord. Coverage Date" := Round(PlanningLine."Total Qty." - (PlanningLine."Per Month Avg." * (CalculateMonthsDifference(CoverageDate))), 1);
                PlanningLine.Modify();
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(StartingDate; StartingDate)
                    {
                        Caption = 'Starting Date';
                        ApplicationArea = All;
                    }
                    field(EndingDate; EndingDate)
                    {
                        Caption = 'Ending Date';
                        ApplicationArea = All;
                    }
                    field(CoverageDate; CoverageDate)
                    {
                        Caption = 'Coverage Date';
                        ApplicationArea = All;
                    }
                }
            }
        }
        actions
        {
            area(Processing)
            {
            }
        }
    }
    var
        StartingDate: Date;
        EndingDate: Date;
        CoverageDate: Date;
        PlanningLine: Record "KES Planning Line";
        NewLineNo: Integer;

    procedure GetLast12MonthsUsage(ItemNo: Code[20]): Decimal
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        StartDate: Date;
        EndDate: Date;
    begin
        StartDate := CalcDate('-1Y', Today);
        EndDate := Today;
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange("Posting Date", StartDate, EndDate);
        ItemLedgerEntry.CalcSums(ItemLedgerEntry.Quantity);
        exit(ItemLedgerEntry.Quantity);
    end;

    procedure GetLast24MonthsUsage(ItemNo: Code[20]): Decimal
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        StartDate: Date;
        EndDate: Date;
    begin
        EndDate := CalcDate('-1Y', Today);
        StartDate := CalcDate('-1Y', EndDate);  //StartDate := CalcDate('-2Y', EndDate);

        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange("Posting Date", StartDate, EndDate);
        ItemLedgerEntry.CalcSums(ItemLedgerEntry.Quantity);
        exit(ItemLedgerEntry.Quantity);
    end;

    procedure CalculateMonthsDifference(CoverageDatePar: Date): Integer;
    var
        Year1, Month1, Year2, Month2 : Integer;
    begin
        // Get the year and month parts of the dates
        Year1 := Date2DMY(Today, 3);
        Month1 := Date2DMY(Today, 2);
        Year2 := Date2DMY(CoverageDatePar, 3);
        Month2 := Date2DMY(CoverageDatePar, 2);

        // Calculate the difference in months
        exit((Year2 - Year1) * 12 + (Month2 - Month1));
    end;
}