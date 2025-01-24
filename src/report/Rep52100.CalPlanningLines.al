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
                PlanningLine."Last 12 Months" := KesFunctions.GetLast12MonthsUsage(Item."No.", StartingDate) * -1;
                PlanningLine."Previous 12 Months" := KesFunctions.GetLast24MonthsUsage(Item."No.", StartingDate) * -1;
                PlanningLine."Per Month Avg." := (PlanningLine."Last 12 Months" + PlanningLine."Previous 12 Months") / 24;
                PlanningLine."Auto Create" := true;
                PlanningLine."Replenishment System" := Item."Replenishment System";
                PlanningLine."Ord. Coverage Date" := Round(PlanningLine."Total Qty." - (PlanningLine."Per Month Avg." * (KesFunctions.CalculateMonthsDifference(CoverageDate, StartingDate))), 1);
                PlanningLine."Execution Date" := StartingDate;
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
                        Visible = false;
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
        trigger OnOpenPage()
        begin
            StartingDate := Today;
        end;
    }

    var
        StartingDate: Date;
        EndingDate: Date;
        CoverageDate: Date;
        PlanningLine: Record "KES Planning Line";
        NewLineNo: Integer;
        KesFunctions: Codeunit "KES Functions";
}