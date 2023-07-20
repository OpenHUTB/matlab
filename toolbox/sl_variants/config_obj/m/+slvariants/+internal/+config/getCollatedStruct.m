function opStructs=getCollatedStruct(controlVarsStruct,accessibleCtrlVarsIdxs)












    opStructs=[];
    structVarsInfoMap=containers.Map;
    for i=1:numel(controlVarsStruct)
        varName=controlVarsStruct(i).Name;
        if~accessibleCtrlVarsIdxs(i)

            continue;
        end
        structVarNameAndFields=strsplit(varName,'.');
        if numel(structVarNameAndFields)<2

            continue;
        end
        structSource=controlVarsStruct(i).Source;
        if~structVarsInfoMap.isKey(structSource)
            structVarsInfoMap(structSource)=containers.Map();
        end
        structVarsInfoMapPerSource=structVarsInfoMap(structSource);
        structVarName=structVarNameAndFields{1};
        if structVarsInfoMapPerSource.isKey(structVarName)
            currStructValue=structVarsInfoMapPerSource(structVarName);
        else
            currStructValue=struct();
        end
        nestedStruct=currStructValue;
        command='';
        for j=2:numel(structVarNameAndFields)-1
            command=[command,['.(''',structVarNameAndFields{j},''')']];%#ok<AGROW>
            if~isfield(nestedStruct,structVarNameAndFields{j})

                eval(['currStructValue',command,' = [];'])
            end
            nestedStruct=eval(['currStructValue',command,';']);
        end
        controlVarsStruct(i).Value=Simulink.variant.utils.deepCopy(controlVarsStruct(i).Value,'ErrorForNonCopyableHandles',false);
        nestedStruct=setfield(nestedStruct,structVarNameAndFields{end},controlVarsStruct(i).Value);%#ok<SFLD,NASGU>
        eval(['currStructValue',command,'= nestedStruct;']);
        structVarsInfoMapPerSource(structVarName)=currStructValue;%#ok<NASGU>
    end

    allSources=structVarsInfoMap.keys;
    for i=1:numel(allSources)
        structVarsInfoMapPerSource=structVarsInfoMap(allSources{i});
        structVars=structVarsInfoMapPerSource.keys;
        for j=1:numel(structVars)
            structCtrlVarEntry=struct();
            structCtrlVarEntry.Name=structVars{j};
            structCtrlVarEntry.Value=structVarsInfoMapPerSource(structVars{j});
            structCtrlVarEntry.Source=allSources{i};
            opStructs=[opStructs,structCtrlVarEntry];%#ok<AGROW>
        end
    end
end


