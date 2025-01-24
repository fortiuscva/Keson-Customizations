table 52100 "KES Planning Line"
{
    DataClassification = CustomerContent;
    LookupPageId = "KES Planning Lines";
    DrillDownPageId = "KES Planning Lines";
    Caption = 'Planning Line';

    fields
    {
        field(1; "Worksheet Template Name"; Code[10])
        {
            Caption = 'Worksheet Template Name';
            TableRelation = "Req. Wksh. Template";
        }
        field(2; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Requisition Wksh. Name".Name where("Worksheet Template Name" = field("Worksheet Template Name"));
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; Type; Enum "Requisition Line Type")
        {
            Caption = 'Type';

            trigger OnValidate()
            var
                NewType: Enum "Requisition Line Type";
            begin
                if Type <> xRec.Type then begin
                    NewType := Type;


                    "No." := '';
                    "Variant Code" := '';

                    Init();
                    Type := NewType;
                end;
            end;
        }
        field(5; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = if (Type = const("G/L Account")) "G/L Account"
            else
            if (Type = const(Item)) Item;

            trigger OnValidate()
            begin
                //CheckActionMessageNew();

                if "No." = '' then begin
                    Init();
                    Type := xRec.Type;
                    exit;
                end;

                if "No." <> xRec."No." then begin
                    "Variant Code" := '';
                end;

                TestField(Type);
                case Type of
                    Type::"G/L Account":
                        CopyFromGLAcc();
                    Type::Item:
                        CopyFromItem();
                end;
            end;
        }
        field(6; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(7; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(8; "Qty. On Hand"; Decimal)
        {
            Caption = 'Qty. On Hand';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(9; "Qty. on Purch. Order"; Decimal)
        {
            Caption = 'Qty. on Purch. Order';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(10; "Qty. on Prod. Order"; Decimal)
        {
            Caption = 'Qty. on Prod. Order';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(11; "Total Qty."; Decimal)
        {
            Caption = 'Total OH + On Order';
        }
        field(12; "Last 12 Months"; Decimal)
        {
            Caption = 'Last 12 Month';
        }
        field(13; "Previous 12 Months"; Decimal)
        {
            Caption = 'Previous 12 Month';
        }
        field(14; "Ord. Coverage Date"; Decimal)
        {
            Caption = 'Order Through Coverage Date';
        }
        field(15; "Purch. Unit of Measure"; Code[10])
        {
            Caption = 'Purch. Unit of Measure';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("No."));
        }
        field(16; "Auto Create"; Boolean)
        {
            Caption = 'Auto Create';
        }
        field(17; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;
        }
        field(18; "Replenishment System"; Enum "Replenishment System")
        {
            Caption = 'Replenishment System';
        }
        field(21; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = if (Type = const(Item)) "Item Variant".Code where("Item No." = field("No."));
        }
        field(22; "Accept Action Message"; Boolean)
        {
            Caption = 'Accept Action Message';
        }
        field(23; "Per Month Avg."; Decimal)
        {
            Caption = 'Per Month Avg.';
        }
        field(24; "Execution Date"; Date)
        {
            Editable = false;
        }

    }
    keys
    {
        key(Key1; "Worksheet Template Name", "Journal Batch Name", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    local procedure CopyFromGLAcc()
    var
        GLAcc: Record "G/L Account";
    begin
        GLAcc.Get("No.");
        GLAcc.CheckGLAcc();
        GLAcc.TestField("Direct Posting", true);
        Description := GLAcc.Name;
    end;

    procedure CopyFromItem()
    var
        Item: Record Item;
    begin
        Item.Get("No.");
        Item.TestField(Blocked, false);
        Description := Item.Description;
        "Description 2" := Item."Description 2";
        "Purch. Unit of Measure" := Item."Purch. Unit of Measure";
        "Vendor No." := Item."Vendor No.";
    end;
}