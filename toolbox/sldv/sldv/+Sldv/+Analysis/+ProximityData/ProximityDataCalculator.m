classdef ProximityDataCalculator<handle











    properties
        mProximityTable;
        sldvObjectivesData;
        AGE_THRESH=2;
        visitedGroups={};

    end

    methods
        function obj=ProximityDataCalculator()

        end

        function initialize(obj,sldvObjectivesData)
            obj.sldvObjectivesData=sldvObjectivesData;
            obj.mProximityTable=Sldv.Analysis.ProximityData.ProximityDataTable();
            obj.mProximityTable.initialize();
            obj.visitedGroups={};

        end

        function populateData(obj,targetObjIndices,needProximityObjectives)
            withProximityIndices=true;
            if nargin==3
                withProximityIndices=needProximityObjectives;
            end

            for targObjIterator=1:length(targetObjIndices)
                targObjIdx=targetObjIndices(targObjIterator);
                closestObjIndices=obj.getClosestObjectiveIndices(targObjIdx);
                proximityIndices=[];
                if withProximityIndices
                    proximityIndices=obj.getProximityIndices(closestObjIndices);
                end
                if~isempty(closestObjIndices)

                    hasDecidedNeighbours=obj.checkForDecidedNeighbours(closestObjIndices);
                    proximityStruct.targetObjective=targObjIdx;
                    proximityStruct.closestObjIndices=closestObjIndices;
                    proximityStruct.hasDecidedNeighbours=hasDecidedNeighbours;
                    proximityStruct.proximityObjIndices=proximityIndices;
                    obj.mProximityTable.addData(proximityStruct);
                end
            end
        end



















        function getDataUsageMatrix(obj)
            rt=sfroot;

            data=rt.find('-isa','Stateflow.Data');


            for i=1:length(data)
                dataUsage=[Stateflow.internal.UsesDatabase.GetAllUsesOfObject(data(i).Id).idWhereUsed];
                obj.dataUsageMatrix(i,:)={dataUsage};
            end
        end






        function dataProxTable=getDataProximity(obj,targetObj)


            mdlObjIdx=obj.sldvObjectivesData.Objectives(targetObj).modelObjectIdx;

            sid=obj.sldvObjectivesData.ModelObjects(mdlObjIdx).sid;

            sfObjId=Simulink.ID.getHandle(sid).Id;

            dataProxTable=[];
            for j=1:length(obj.dataUsageMatrix)
                tempArr=obj.dataUsageMatrix{j};



                if ismember(sfObjId,tempArr)
                    dataProxTable=[dataProxTable,obj.getDataProxObj(tempArr)];
                end
            end


            dataProxTable=unique(dataProxTable);
        end





        function dataProxObj=getDataProxObj(obj,sfObjId)
            dataProxObj=[];
            for i=1:size(obj.sldvObjectivesData.ModelObjects,2)
                for j=1:length(sfObjId)
                    if ismember(obj.sldvObjectivesData.ModelObjects(i).sfObjNum,sfObjId)
                        dataProxObj=[dataProxObj,obj.sldvObjectivesData.ModelObjects(i).objectives];
                    end
                end
            end
            dataProxObj=unique(dataProxObj);
        end

        function data=getTargetData(obj)
            reqdTargets=obj.getTargets();
            if~isempty(reqdTargets)
                data.objIndices=[reqdTargets.targetObjective];
                obj.mProximityTable.incrementAge(data.objIndices);
                data.closestObjIndices=unique([reqdTargets.closestObjIndices]);
                data.proximityObjIndices=unique([reqdTargets.proximityObjIndices]);
            end
        end

        function updateProximityData(obj,modifiedObjIndices)

            for objIndex=modifiedObjIndices
                obj.mProximityTable.deleteData(objIndex);
            end

            for objIndex=modifiedObjIndices
                obj.mProximityTable.updateHasDecidedNeighbours(objIndex);
            end
        end
        function proximityData=getProximityData(obj)
            proximityData=obj.mProximityTable;
        end

        function flag=hasData(obj)
            allProximityData=obj.mProximityTable.getTable();
            flag=~isempty(allProximityData)&&any([allProximityData.hasDecidedNeighbours]==true);
        end

        function flag=hasNextSetObjectives(obj)
            flag=true;
            data=obj.mProximityTable.getTable();
            if isempty(data)
                flag=false;
            else
                targetData=obj.getTargets();
                if isempty(targetData)
                    flag=false;
                end
            end
        end
    end
    methods

        function reqdTargets=getTargets(obj)
            allProximityData=obj.mProximityTable.getTable();
            if isempty(allProximityData)
                reqdTargets=[];
                return;
            end
            reqdTargets=allProximityData([allProximityData.hasDecidedNeighbours]==true);
            reqdTargets=reqdTargets([reqdTargets.age]<obj.AGE_THRESH);
        end

        function objIndices=getNeighbors(obj,targetObjIdx)
            allProximityData=obj.mProximityTable.getTable();
            proximityData=obj.mProximityTable.getData(targetObjIdx);
            closestObjectiveIndices=proximityData.closestObjIndices;
            flags=arrayfun(@(proximityEntry)isequal(...
            proximityEntry.closestObjIndices,...
            closestObjectiveIndices),allProximityData);
            objIndices=[allProximityData(flags).targetObjective];
        end

        function closestObjIndices=getClosestObjectiveIndices(obj,targObjIdx)
            objectives=obj.sldvObjectivesData.Objectives;
            modelObjects=obj.sldvObjectivesData.ModelObjects;
            targetObjective=objectives(targObjIdx);
            targetMObj=modelObjects(targetObjective.modelObjectIdx);
            closestObjIndices=[];
            mObjType=targetMObj.typeDesc;

            switch mObjType
            case 'Transition'
                closestObjIndices=obj.getProximityDataForTransitions(targetObjective);
            case{'State','Chart'}
                closestObjIndices=obj.getProximityDataForStates(targetObjective);
            end

        end


        function closestObjIndices=getProximityDataForTransitions(obj,targetObjective)
            utils=Sldv.Analysis.ProximityData.ProximityUtils;
            objectives=obj.sldvObjectivesData.Objectives;
            modelObjects=obj.sldvObjectivesData.ModelObjects;
            targetMObj=modelObjects(targetObjective.modelObjectIdx);

            sfTransition=utils.getStateflowObject(targetMObj.designSid);
            states=utils.getNearestStates(sfTransition);
            closestObjIndices=utils.getStateExecObjectiveIndices(states,objectives,modelObjects);

        end

        function closestObjIndices=getProximityDataForStates(obj,targetObjective)
            utils=Sldv.Analysis.ProximityData.ProximityUtils;
            objectives=obj.sldvObjectivesData.Objectives;
            modelObjects=obj.sldvObjectivesData.ModelObjects;
            targetMObj=modelObjects(targetObjective.modelObjectIdx);
            closestObjIndices=[];
            if targetObjective.coveragePointIdx==1

                sfStateName=utils.getStateNameFromLabel(targetObjective.label);
                if isempty(sfStateName)
                    closestObjIndices=[];
                    return;
                end
                sfStateParentSID=targetMObj.designSid;
                sfState=utils.getStateStateflowObject(sfStateParentSID,...
                sfStateName);
                states=utils.getClosestStates(sfState);
                closestObjIndices=utils.getStateExecObjectiveIndices(states,objectives,modelObjects);


            elseif targetObjective.coveragePointIdx==2












                objIndicesOfSameMObj=modelObjects(targetObjective.modelObjectIdx).objectives;
                objectivesOfSameMObj=objectives(objIndicesOfSameMObj);
                flags=arrayfun(@(entry)strcmp(entry.outcomeValue,'n/a'),objectivesOfSameMObj);
                objectivesOfSameMObj(flags)=[];
                objIndicesOfSameState=objIndicesOfSameMObj(...
                targetObjective.outcomeValue==...
                [objectivesOfSameMObj.outcomeValue]);
                objectivesOfSameState=objectives(objIndicesOfSameState);

                closestObjIndices=objIndicesOfSameState(...
                [objectivesOfSameState.coveragePointIdx]==1);
            end
        end

        function flag=checkForDecidedNeighbours(obj,objIndices)
            objectives=obj.sldvObjectivesData.Objectives(objIndices);
            flag=false;
            if isfield(objectives,'testCaseIdx')&&~isempty(objectives)
                flag=any(~isempty([objectives.testCaseIdx]));
            end

        end

        function proximityIndices=getProximityIndices(obj,closestObjIndices,depth)
            if nargin==2
                depth=5;
            end
            proximityIndices=closestObjIndices;
            seedIndices=closestObjIndices;
            for currDepth=1:depth
                newSeedIndices=[];
                if~isempty(seedIndices)
                    for objIdx=seedIndices

                        newProxObjIndices=unique(obj.getClosestObjectiveIndices(objIdx));
                        if~isempty(newProxObjIndices)
                            newSeedIndices=[newSeedIndices,newProxObjIndices];%#ok<AGROW>
                        end
                    end
                    if~isempty(newSeedIndices)
                        seedIndices=unique(newSeedIndices);
                        proximityIndices=[proximityIndices,seedIndices];%#ok<AGROW>
                    else
                        seedIndices=[];
                    end
                end
            end
        end
    end
end


