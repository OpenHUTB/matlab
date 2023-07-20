

function[storageClassCheck]=isUnSupportedCSC(sc)







    if strcmpi(sc.StorageClass,'Custom')...
        &&((strcmpi(sc.DataInit,'None')...
        ||(~strcmpi(sc.CSCType,'Unstructured')...
        &&~strcmpi(sc.CSCName,'GetSet')))...
        ||strcmpi(sc.CSCName,'Reusable')...
        ||strcmpi(sc.CSCName,'Localizable')...
        ||strcmpi(sc.DataScope,'Auto'))
        storageClassCheck=true;
    else
        storageClassCheck=false;
    end
end

