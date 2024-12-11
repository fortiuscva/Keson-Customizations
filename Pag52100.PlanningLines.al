page 52100 "KES Planning Lines"
{
    ApplicationArea = All;
    Caption = 'Planning Lines';
    PageType = List;
    SourceTable = "KES Planning Line";
    SourceTableView = where(Type = const(Item));
    UsageCategory = Lists;
    AutoSplitKey = true;
    DelayedInsert = true;
    MultipleNewLines = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.', Comment = '%';
                }
                field("Accept Action Message"; Rec."Accept Action Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Accept Action Message field.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field("Replenishment System"; Rec."Replenishment System")
                {
                    ToolTip = 'Specifies the value of the Replenishment System field.', Comment = '%';
                }
                field("Qty. On Hand"; Rec."Qty. On Hand")
                {
                    ToolTip = 'Specifies the value of the Qty. On Hand field.', Comment = '%';
                }
                field("Qty. on Purch. Order"; Rec."Qty. on Purch. Order")
                {
                    ToolTip = 'Specifies the value of the Qty. on Purch. Order field.', Comment = '%';
                }
                field("Qty. on Prod. Order"; Rec."Qty. on Prod. Order")
                {
                    ToolTip = 'Specifies the value of the Qty. on Prod. Order field.';
                }
                field("Last 12 Months"; Rec."Last 12 Months")
                {
                    ToolTip = 'Specifies the value of the Last 12 Month field.', Comment = '%';
                }
                field("Previous 12 Months"; Rec."Previous 12 Months")
                {
                    ToolTip = 'Specifies the value of the Previous 12 Month field.', Comment = '%';
                }
                field("Per Month Avg."; Rec."Per Month Avg.")
                {
                    ToolTip = 'Specifies the value of the Per Month Avg. field.';
                }
                field("Purch. Unit of Measure"; Rec."Purch. Unit of Measure")
                {
                    ToolTip = 'Specifies the value of the Purch. Unit of Measure field.', Comment = '%';
                }
                field("Auto Create"; Rec."Auto Create")
                {
                    ToolTip = 'Specifies the value of the Auto Create field.', Comment = '%';
                }
                field("Ord. Coverage Date"; Rec."Ord. Coverage Date")
                {
                    ToolTip = 'Specifies the value of the Coverage Date field.', Comment = '%';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ToolTip = 'Specifies the value of the Vendor No. field.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(CalculatePLanningLines)
            {
                Caption = 'Calculate Planning Lines';
                ApplicationArea = All;
                RunObject = report "KES Cal. Planning Lines";
                ToolTip = 'Executes the Calculate Planning Lines action.';
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;
            }
            action(FlagAll)
            {
                Caption = 'Flag All';
                ApplicationArea = All;
                ToolTip = 'Executes the Flag All action.';
                Image = Apply;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    PlanningLine: Record "KES Planning Line";
                begin
                    PlanningLine.Copy(Rec);
                    PlanningLine.ModifyAll("Accept Action Message", true);
                end;
            }
            action(UnFlagAll)
            {
                Caption = 'UnFlag All';
                ApplicationArea = All;
                ToolTip = 'Executes the UnFlag All action.';
                Image = UnApply;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    PlanningLine: Record "KES Planning Line";
                begin
                    PlanningLine.Copy(Rec);
                    PlanningLine.ModifyAll("Accept Action Message", false);
                end;
            }
            action(ProcessLines)
            {
                Caption = 'Process Lines';
                Image = Process;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    PlanningLineMakeOrder: Codeunit "KES Planning Line Make Order";
                begin
                    PlanningLineMakeOrder.CreatePurchaseAndRelProdOrders(Rec);
                end;
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Worksheet Template Name" := 'Planning';
        Rec."Journal Batch Name" := 'Default';
        Rec.Type := Rec.Type::Item;
    end;
}
