codeunit 52102 "KES Functions"
{
    procedure GetLast12MonthsUsage(ItemNo: Code[20]; ExecutionDate: Date): Decimal
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        SetValuesForGetLast12MonthsUsage(ItemNo, ExecutionDate, ItemLedgerEntry);
        ItemLedgerEntry.CalcSums(ItemLedgerEntry.Quantity);
        exit(ItemLedgerEntry.Quantity);
    end;

    procedure GetLast24MonthsUsage(ItemNo: Code[20]; ExecutionDate: Date): Decimal
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        SetValuesForGetLast24MonthsUsage(ItemNo, ExecutionDate, ItemLedgerEntry);
        ItemLedgerEntry.CalcSums(ItemLedgerEntry.Quantity);
        exit(ItemLedgerEntry.Quantity);
    end;

    local procedure SetFiltersForILE(var ItemLedgerEntry: Record "Item Ledger Entry"; ItemNo: Code[20]; StartDatePar: Date; EndDatePar: Date)
    begin
        ItemLedgerEntry.SetCurrentKey("Entry Type", "Item No.", "Variant Code", "Source Type", "Source No.", "Posting Date");
        ItemLedgerEntry.SetFilter("Entry Type", '%1|%2', ItemLedgerEntry."Entry Type"::Sale, ItemLedgerEntry."Entry Type"::Consumption);
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange("Posting Date", StartDatePar, EndDatePar);
    end;

    procedure SetValuesForGetLast12MonthsUsage(ItemNo: Code[20]; ExecutionDate: Date; var ItemLedgerEntry: Record "Item Ledger Entry")
    var
        StartDate: Date;
        EndDate: Date;
    begin
        StartDate := CalcDate('-1Y', ExecutionDate);
        EndDate := ExecutionDate;
        SetFiltersForILE(ItemLedgerEntry, ItemNo, StartDate, EndDate);
    end;

    procedure SetValuesForGetLast24MonthsUsage(ItemNo: Code[20]; ExecutionDate: Date; var ItemLedgerEntry: Record "Item Ledger Entry")
    var
        StartDate: Date;
        EndDate: Date;
    begin
        EndDate := CalcDate('-1Y', ExecutionDate);
        StartDate := CalcDate('-1Y', EndDate);  //StartDate := CalcDate('-2Y', EndDate);
        SetFiltersForILE(ItemLedgerEntry, ItemNo, StartDate, EndDate);
    end;

    procedure CalculateMonthsDifference(CoverageDatePar: Date; ExecutionDate: Date): Integer;
    var
        Year1, Month1, Year2, Month2 : Integer;
    begin
        // Get the year and month parts of the dates
        Year1 := Date2DMY(ExecutionDate, 3);
        Month1 := Date2DMY(ExecutionDate, 2);
        Year2 := Date2DMY(CoverageDatePar, 3);
        Month2 := Date2DMY(CoverageDatePar, 2);

        // Calculate the difference in months
        exit((Year2 - Year1) * 12 + (Month2 - Month1));
    end;
}