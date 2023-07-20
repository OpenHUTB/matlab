function codeObj=renameTableColumnAction(data,varName,columnName,newName,isDataNode)




    codeObj=struct;

    if(nargin>4&&isDataNode)
        newName=strrep(newName,' ','');
        codeObj.Code=newName+"="+varName+";clear "+varName+";";
        codeObj.DisplayName=...
        getString(message...
        ('MATLAB:datatools:preprocessing:variableBrowser:variableBrowser:DISPLAY_NAME_RENAME',...
        varName,newName));
        codeObj.TableVariableName="";
        codeObj.VariableName=newName;
    else

        if(columnName==string(data.Properties.DimensionNames{1}))&&(class(data)=="timetable")
            codeObj.Code=varName+".Properties.DimensionNames{1} = "+" '"+newName+"' "+";";
        else
            codeObj.Code=varName+" = renamevars("+varName+", "+" '"+...
            columnName+"', '"+newName+"' );";
        end
        oldName=varName+"."+columnName;
        renamedName=varName+"."+newName;
        codeObj.DisplayName=getString(message('MATLAB:datatools:preprocessing:variableBrowser:variableBrowser:DISPLAY_NAME_RENAME',oldName,renamedName));
        codeObj.TableVariableName=columnName;
        codeObj.VariableName=varName;
    end
end

