function[newBusObjectResults,totalRecAdded]=createAndUpdateBusObjectResults(this,busObjHandleAndICList,busSrcBlks,runObj)















    totalRecAdded=0;
    newBusObjectResults={};

    for i_busObhHAndIC=1:length(busObjHandleAndICList)
        busObjHAndIC=busObjHandleAndICList(i_busObhHAndIC);


        busObjHandle=busObjHAndIC.busObjectHandle;
        L=length(busObjHandle.leafChildIndices);
        leafBusElementNames=...
        busObjHandle.elementNames(busObjHandle.leafChildIndices);

        for i_leafChildIndex=1:L


            leafChildIndex=busObjHandle.leafChildIndices(i_leafChildIndex);
            leafBusElementName=leafBusElementNames{i_leafChildIndex};

            [busObjectResult,addedRecNum]=...
            runObj.findResultFromArrayOrCreate(...
            {'Object',busObjHandle,'ElementName',leafBusElementName});







            SimulinkFixedPoint.Autoscaler.addToSrcList(runObj,...
            busObjectResult,busSrcBlks);


            IC=busObjHAndIC.initCondition;
            [busObjectResult,busObjHandle]=this.updateIC(IC,busObjHandle,...
            busObjectResult,leafChildIndex,leafBusElementName);


            if addedRecNum>0
                totalRecAdded=totalRecAdded+addedRecNum;
                newBusObjectResults{end+1}=busObjectResult;%#ok
            end

        end
    end
end
