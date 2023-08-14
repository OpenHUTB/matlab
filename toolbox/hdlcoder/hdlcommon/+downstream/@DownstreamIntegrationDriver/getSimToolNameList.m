function toolNameList=getSimToolNameList(obj)



    if obj.hAvailableSimulationToolList.isToolListEmpty
        toolNameList={obj.NoAvailableSimToolStr};
    else
        toolNameList=obj.hAvailableSimulationToolList.getToolNameList;
    end
end
