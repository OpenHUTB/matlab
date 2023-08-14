function initToolStr=getInitSimToolStr(obj)



    if obj.hAvailableSimulationToolList.isToolListEmpty
        initToolStr=obj.NoAvailableSimToolStr;
    else
        toolNameList=obj.hAvailableSimulationToolList.getToolNameList;
        if isempty(toolNameList)
            initToolStr='No supported simulation tool on the path';
            return
        end
        foundModelSim=false;
        for ii=1:length(toolNameList)
            tn=toolNameList{ii};
            if strcmp(tn,'ModelSim')
                foundModelSim=true;
                break
            end
        end
        if foundModelSim
            initToolStr='ModelSim';
        else
            initToolStr=toolNameList{1};
        end
    end
end
