function out=doesAnyUIExist(this)




    out=~isempty(this.requirementsEditor)||this.hasSpreadSheetData;
end

