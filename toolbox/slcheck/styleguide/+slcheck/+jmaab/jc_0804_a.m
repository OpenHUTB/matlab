classdef jc_0804_a<slcheck.subcheck

    methods
        function obj=jc_0804_a()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='jc_0804_a';
        end

        function result=run(this)
            result=false;
            chart=this.getEntity();
            if~isa(chart,'Stateflow.Chart')
                return;
            end
            mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
            system=mdladvObj.System;
            inputParams=mdladvObj.getInputParameters;

            Stateflow.internal.UsesDatabase.RehashUsesInObject(chart.Id);
            graphicalFuncs=chart.find('-isa','Stateflow.Function');

            if isempty(graphicalFuncs)
                return;
            end

            funcIdToIndexMap=containers.Map(arrayfun(@(x)x.Id,graphicalFuncs),1:numel(graphicalFuncs));
            funcIdToIndexMapInv=containers.Map(1:numel(graphicalFuncs),arrayfun(@(x)x.Id,graphicalFuncs));

            funcIdToTransitionsMap=containers.Map('KeyType','double','ValueType','any');
            adjMat=zeros(numel(graphicalFuncs),numel(graphicalFuncs));
            rt=Stateflow.Root;
            vObjArray=[];
            for funcCnt=1:numel(graphicalFuncs)

                allUses=Stateflow.internal.UsesDatabase.GetAllUsesOfObject(graphicalFuncs(funcCnt).Id);
                for useCnt=1:numel(allUses)
                    handleWhereUsed=idToHandle(rt,allUses(useCnt).idWhereUsed);
                    parentOfHandle=handleWhereUsed.getParent;

                    if isa(parentOfHandle,'Stateflow.Function')


                        adjMat(funcIdToIndexMap(parentOfHandle.Id),funcIdToIndexMap(graphicalFuncs(funcCnt).Id))=1;

                        if isKey(funcIdToTransitionsMap,parentOfHandle.Id)
                            val=funcIdToTransitionsMap(parentOfHandle.Id);
                            val{end+1}=allUses(useCnt).idWhereUsed;
                            funcIdToTransitionsMap(parentOfHandle.Id)=val;
                        else
                            funcIdToTransitionsMap(parentOfHandle.Id)={allUses(useCnt).idWhereUsed};
                        end
                    end
                end
            end


            if inputParams{3}.Value
                keys=funcIdToTransitionsMap.keys;
                for i=1:numel(keys)
                    val=funcIdToTransitionsMap(keys{i});
                    vObj=ModelAdvisor.ResultDetail;
                    vObj.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0804_a_subtitle');
                    vObj.Status=DAStudio.message('ModelAdvisor:jmaab:jc_0804_a_warn');
                    vObj.RecAction=DAStudio.message('ModelAdvisor:jmaab:jc_0804_a_rec_action');
                    groupSIDs=cellfun(@(x)Simulink.ID.getSID(idToHandle(rt,x)),val,'UniformOutput',false);
                    groupSIDs=mdladvObj.filterResultWithExclusion(groupSIDs);
                    ModelAdvisor.ResultDetail.setData(vObj,'Group',unique(groupSIDs));
                    vObjArray=[vObjArray;vObj];
                end
            end

            [numCycles,cycles]=Advisor.Utils.Graph.findCycles(adjMat);


            for funcCnt=1:numel(graphicalFuncs)
                if adjMat(funcCnt,funcCnt)==1
                    numCycles=numCycles+1;
                    cycles{end+1}=funcCnt;
                end
            end
            for i=1:numCycles
                cycle=unique(cycles{i});
                cycleOfHandles=arrayfun(@(x)idToHandle(rt,funcIdToIndexMapInv(x)),cycle);
                cycleOfSIDs=arrayfun(@(x)Simulink.ID.getSID(x),cycleOfHandles,'UniformOutput',false);
                cycleOfSIDs=mdladvObj.filterResultWithExclusion(cycleOfSIDs);
                vObj=ModelAdvisor.ResultDetail;
                vObj.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0804_b_subtitle');
                vObj.Status=DAStudio.message('ModelAdvisor:jmaab:jc_0804_b_warn');
                vObj.RecAction=DAStudio.message('ModelAdvisor:jmaab:jc_0804_b_rec_action');
                ModelAdvisor.ResultDetail.setData(vObj,'Group',cycleOfSIDs);
                vObjArray=[vObjArray;vObj];
            end
            if~isempty(vObjArray)
                result=this.setResult(vObjArray);
            end
        end
    end
end
