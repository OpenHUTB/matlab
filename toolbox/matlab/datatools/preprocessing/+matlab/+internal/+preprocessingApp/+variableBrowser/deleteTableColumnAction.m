function codeObj=deleteTableColumnAction(varName,columnNames)



    codeObj=struct;
    codeObj.Code=varName+" = removevars("+varName+", "+" '"...
    +columnNames+"' );";
    codeObj.DisplayName=getString(message...
    ('MATLAB:datatools:preprocessing:variableBrowser:variableBrowser:DISPLAY_NAME_DELETE'))+...
    " "+columnNames;
    codeObj.VariableName=varName;
    codeObj.TableVariableName=columnNames;
end
