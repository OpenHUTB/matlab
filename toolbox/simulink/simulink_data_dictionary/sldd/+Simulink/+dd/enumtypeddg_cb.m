function varargout=enumtypeddg_cb(action,dialog)

    try
        out=loc_callbackActionDispatch(action,dialog);
        for i=1:length(out)
            varargout{i}=out{i};%#ok<AGROW>
        end
    catch E


        throwAsCaller(E);
    end

end


function out=loc_callbackActionDispatch(action,dialog)
    out={};

    switch action
    case 'doAdd'
        loc_doAdd(dialog);

    case 'doDelete'
        loc_doDelete(dialog);

    case 'doUp'
        loc_doRowSwap(dialog,-1);

    case 'doDown'
        loc_doRowSwap(dialog,+1);

    case 'doRevert'
        out=loc_doRevert(dialog);

    end

end


function loc_doAdd(dialog)

    source=dialog.getSource;
    dlgData=source.getUserData();


    enumTypeSpec=source.getForwardedObject;
    assert(isa(enumTypeSpec,'Simulink.data.dictionary.EnumTypeDefinition'));
    numEnums=enumTypeSpec.numEnumerals;
    newEnumName=enumTypeSpec.getUniqueEnumName;
    newEnumValue=enumTypeSpec.getEnumeralDefaultValue;
    enumTypeSpec.appendEnumeral(newEnumName,newEnumValue,'');


    dlgData.SelectedRow=numEnums;


    source.setUserData(dlgData);
    dialog.refresh;
    dialog.enableApplyButton(true);
end



function loc_doDelete(dialog)

    source=dialog.getSource;
    enumTypeSpec=source.getForwardedObject;
    assert(isa(enumTypeSpec,'Simulink.data.dictionary.EnumTypeDefinition'));

    enumToDelete=dialog.getSelectedTableRow('Enumerals')+1;

    numEnums=enumTypeSpec.numEnumerals;
    if(enumToDelete>=1)&&(enumToDelete<=numEnums)
        enumTypeSpec.removeEnumeral(enumToDelete);

        if(enumToDelete==numEnums)

            dlgData=source.getUserData();
            dlgData.SelectedRow=numEnums-2;
            source.setUserData(dlgData);
        end

        dialog.refresh;
        dialog.enableApplyButton(true);
    end
end


function loc_doRowSwap(dialog,inc)

    row=dialog.getSelectedTableRow('Enumerals')+1;

    if(row>=1)
        source=dialog.getSource;

        enumTypeSpec=source.getForwardedObject;
        assert(isa(enumTypeSpec,'Simulink.data.dictionary.EnumTypeDefinition'));
        newRow=row+inc;
        enumTypeSpec.swapEnumerals(row,newRow);

        dlgData=source.getUserData();
        dlgData.SelectedRow=newRow-1;
        source.setUserData(dlgData);

        dialog.refresh;
        dialog.enableApplyButton(true);
    end
end


function out=loc_doRevert(dialog)

    out=cell(2);
    source=dialog.getSource;

    enumTypeSpec=source.getForwardedObject;
    assert(isa(enumTypeSpec,'Simulink.data.dictionary.EnumTypeDefinition'));



    enumTypeSpec.clearEnumerals;
    dlgData=source.getUserData();
    numEnums=size(dlgData.enumeration,1);
    for e=1:numEnums
        enumTypeSpec.appendEnumeral(...
        dlgData.enumeration{e,1},...
        dlgData.enumeration{e,2},...
        dlgData.enumeration{e,3});
    end

    dialog.refresh;


    out{1}=true;
    out{2}='';
end
