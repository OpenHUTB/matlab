function rename(source,dlg)




    inputs=source.state.Inputs;
    newName=dlg.getWidgetValue('renameEdit');
    block=source.getBlock;
    ind=block.UserData.lastListSelectionIdx;
    hierarchy=source.getCachedSignalHierarchy(block,false);

    if~isnan(source.str2doubleNoComma(inputs))
        nameList={hierarchy(:).name};
    else
        nameList=source.str2CellArr(inputs);
    end

    if~isempty(newName)&&~isempty(ind)&&~strcmp(newName,nameList{ind+1})
        nIdx=find(ismember(nameList,newName),1);
        if isempty(nIdx)
            nameList{ind+1}=newName;
            source.state.Inputs=source.cellArr2Str(nameList);
            dlg.setUserData('signalsList',nameList);
            source.refresh(dlg,false);
        else
            errid='Simulink:blocks:UniqueName';
            errmsg=message(errid,newName);
            errorDuringEval=MException(errid,errmsg.getString);
            throwAsCaller(errorDuringEval);
        end
    end

