function[addChecksIDs,addCheckNames,removeChecks]=updatePropsForChecks(this,prop,ssid)





    removeChecks=[];
    checkArray={};
    addCheckIDs={};
    addCheckNames={};
    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    if~isempty(mdladvObj)&&strcmp(bdroot(mdladvObj.SystemName),this.fModelName)...
        &&~isempty(mdladvObj.ResultMap)
        if mdladvObj.ResultMap.isKey(ssid)
            checkArray=mdladvObj.ResultMap(ssid);
        end
        addCheckIDs=checkArray(1:2:end);
        addCheckNames=checkArray(2:2:end);
        [addCheckNames,idx]=sort(addCheckNames);
        addCheckIDs=addCheckIDs(idx);
    end


    addChecksIDs=[{'.*','CheckSelectorGUI'},addCheckIDs];
    addCheckNames=[DAStudio.message('ModelAdvisor:engine:ExclusionAllChecks'),...
    DAStudio.message('ModelAdvisor:engine:CheckSelector'),...
    addCheckNames];







    if isKey(this.exclusionState,this.getPropKey(prop))
        val=this.exclusionState(this.getPropKey(prop));
        for i=1:length(val)
            removeChecks=[removeChecks,val.checkIDs];%#ok<AGROW>
        end
    end

    if~isempty(removeChecks)
        if strcmp(removeChecks{1},'.*')
            addChecksIDs=[];
        else
            [addChecksIDs,i]=setdiff(addChecksIDs,removeChecks);
            addCheckNames=addCheckNames(i);
        end
    end
end

function[addCheckIDs,addCheckNames]=extractCheckIDs(defaultConfig)
    addCheckIDs=cell(1,length(defaultConfig));
    addCheckNames=cell(1,length(defaultConfig));
    for i=1:length(defaultConfig)
        addCheckIDs{i}=defaultConfig{i}.CheckID;
        addCheckNames{i}=defaultConfig{i}.CheckTitle;
    end
end
