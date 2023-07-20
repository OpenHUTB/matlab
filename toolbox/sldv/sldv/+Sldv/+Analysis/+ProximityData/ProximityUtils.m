classdef ProximityUtils





    methods(Static)
        function obj=ProximityUtils()
        end


        function states=getNearestStates(transition,processedTransitions)
            utils=Sldv.Analysis.ProximityData.ProximityUtils;
            if nargin==1
                processedTransitions=[];
            end











            chartId=sfprivate('getChartOf',transition.Id);
            chart=sf('IdToHandle',chartId);
            states=chart.find('-isa','Stateflow.State','-or',...
            '-isa','Stateflow.Subchart','-or',...
            '-isa','Stateflow.AtomicSubchart');
            if isempty(states)
                states=chart;
                return;
            end
            source=transition.Source;

            if(isa(source,'Stateflow.State')||...
                isa(source,'Stateflow.SimulinkBasedState'))
                states=source;
                return;
            end


            if(isempty(source))
                states=transition.subviewer;
                return;
            end

            if(isa(source,'Stateflow.AtomicSubchart'))
                states=source;
                return;
            end

            if(isa(source,'Stateflow.Junction'))
                candidateTrans=source.sinkedTransitions;
                states=[];







                for i=1:length(candidateTrans)
                    if~ismember(candidateTrans(i),processedTransitions)
                        processedTransitions=[processedTransitions,candidateTrans(i)];%#ok<AGROW>
                        sthdls=utils.getNearestStates(candidateTrans(i),processedTransitions);
                        states=[states,sthdls];%#ok<AGROW>                    
                    else
                        states=[];
                        processedTransitions=[];
                    end
                end
            end
        end

        function closeStates=getClosestStates(state)
            utils=Sldv.Analysis.ProximityData.ProximityUtils;
            closeStates=[];
            if isa(state,'Stateflow.State')
                transitions=state.sinkedTransitions;
                transitions=transitions';
                for transition=transitions
                    states=utils.getNearestStates(transition);
                    closeStates=[closeStates,states];%#ok<AGROW>
                end
            end

        end




        function objectiveIndices=getStateExecObjectiveIndices(states,objectives,modelObjects)

            objectiveIndices=[];
            if~isempty(states)




                stateExecutedString=getString(message(...
                'Slvnv:simcoverage:make_formatters:MSG_SF_ACTIVE_CHILD_CALL_D'));
                for state=states
                    newObjectiveIndices=[];



                    if(isa(state,'Stateflow.Chart'))
                        newObjectiveIndices=[];
                    else
                        parentState=state.getParent();
                        parentSID=Simulink.ID.getSID(parentState);
                        reqdModelObj=modelObjects(strcmp({modelObjects.designSid},parentSID));
                        if~isempty(reqdModelObj)
                            reqdObjIndices=reqdModelObj.objectives;
                            reqdObjectives=objectives(reqdObjIndices);
                            objDescriptions={reqdObjectives.descr};
                            reqdStateName=state.Name;
                            stateObjFlags=cellfun(@(str)...
                            contains(str,stateExecutedString)&&...
                            contains(str,reqdStateName),objDescriptions);
                            newObjectiveIndices=reqdObjIndices(stateObjFlags);
                        else





                            if(isa(parentState,'Stateflow.State'))
                                utils=Sldv.Analysis.ProximityData.ProximityUtils;
                                newObjectiveIndices=utils.getStateExecObjectiveIndices(...
                                parentState,objectives,modelObjects);
                            end
                        end
                    end
                    objectiveIndices=[objectiveIndices,newObjectiveIndices];%#ok<AGROW>
                end
            end
        end


        function modelObjIdx=getMObjIdxOfSFObj(sfObj,modelObjects)
            utils=Sldv.Analysis.ProximityData.ProximityUtils;
            sid=utils.getSidFromStateflowObj(sfObj);
            mObjSids={modelObjects.designSid};
            modelObjIdx=find(strcmp(sid,mObjSids));
        end
        function sid=getSidFromStateflowObj(stateflowObj)


            if isa(stateflowObj,'Stateflow.Transition')
                transId=stateflowObj.Id;
                if(~isempty(sf('find',transId,'.type','SUB')))
                    superTransId=sf('get',transId,'.subLink.parent');



                    ssId=sf('get',superTransId,'.ssId');
                    chartId=sf('get',superTransId,'.chart');
                    blockH=sfprivate('chart2block',chartId);
                    chartSidString=Simulink.ID.getSID(blockH);
                    sid=[chartSidString,':',num2str(ssId)];
                else
                    sid=Simulink.ID.getSID(stateflowObj);
                end
            end

        end


        function sfObj=getStateflowObject(sid)
            sfObj=Simulink.ID.getHandle(sid);
        end
        function name=getStateNameFromLabel(label)
            sfStateLabel=label;
            delimiter='"';
            positions=strfind(sfStateLabel,delimiter);
            if isempty(positions)
                name=[];
                return;
            end
            startPos=positions(1);
            endPos=positions(2);
            sfStateName=extractBetween(sfStateLabel,...
            startPos,endPos,...
            'Boundaries','exclusive');
            name=sfStateName{:};
        end

        function sfObj=getStateStateflowObject(parentSID,stateName)
            parentObj=Simulink.ID.getHandle(parentSID);
            if(isa(parentObj,'Stateflow.State'))

            else



                chartBlkH=parentObj;
                chartId=sfprivate('block2chart',chartBlkH);
                parentObj=sf('IdToHandle',chartId);
            end
            stateObjs=parentObj.find({'-isa','Stateflow.State','-or',...
            '-isa','Stateflow.AtomicSubchart','-or',...
            '-isa','Stateflow.SimulinkBasedState'},...
            'Name',stateName,'-depth',1);




            stateObjs=stateObjs';
            for stateObj=stateObjs
                stateObjSID=Simulink.ID.getSID(stateObj);
                if~strcmp(stateObjSID,parentSID)
                    sfObj=stateObj;
                end
            end
        end

        function objIndices=getCandPredecessorObjs(stateObjIndices,objectives,modelObjects)
            proxUtils=Sldv.Analysis.ProximityData.ProximityUtils;
            objIndices=[];
            for objIterator=1:length(stateObjIndices)
                targObj=objectives(stateObjIndices(objIterator));
                stateName=proxUtils.getStateNameFromLabel(targObj.label);
                mObj=modelObjects(targObj.modelObjectIdx);
                stateObj=proxUtils.getStateStateflowObject(mObj.designSid,...
                stateName);
                outgoingTransitions=stateObj.sourcedTransitions;
                for transIterator=1:length(outgoingTransitions)
                    transition=outgoingTransitions(transIterator);
                    mObjIdx=proxUtils.getMObjIdxOfSFObj(transition,modelObjects);
                    transMObj=modelObjects(mObjIdx);
                    objIndices=[objIndices,transMObj.objectives];%#ok<AGROW>
                end
            end

        end
    end
end

