
















classdef HighlighterTask<Sldv.Tasking.Task
    properties(Access=private)
        mSldvAnalyzer Sldv.Analyzer
        mGoalIdToObjectiveIdMap containers.Map
        mModelView Sldv.ModelView
isValidatorON
mMinGoalCountForHlt
mMinItersForHlt
mIterNum
    end

    methods
        function obj=HighlighterTask(aTaskMgrH,aReady,aSldvAnalyzer)

            obj=obj@Sldv.Tasking.Task(aTaskMgrH,aReady);

            obj.mSldvAnalyzer=aSldvAnalyzer;







            obj.mMinGoalCountForHlt=20;

            obj.mMinItersForHlt=4;

            obj.mIterNum=0;




            obj.triggerOn(Sldv.Tasking.SldvEvents.AnalysisInit);



            obj.isValidatorON=Sldv.Utils.isValidatorEnabled(...
            obj.mSldvAnalyzer.getAnalysisOpts(),obj.mSldvAnalyzer.getAnalysisSimMode());
            if obj.isValidatorON
                obj.connect(Sldv.Tasking.SldvChannels.ValidatedGoals,...
                Sldv.Tasking.ChannelConnectMode.Read);
            else
                obj.connect(Sldv.Tasking.SldvChannels.ProcessedGoals,...
                Sldv.Tasking.ChannelConnectMode.Read);
            end
        end

        function delete(~)
        end

    end

    methods(Access=protected)
        function status=doTask(obj,aEvent)

            assert(~isempty(obj.mSldvAnalyzer)&&isvalid(obj.mSldvAnalyzer),'Invalid Analyzer Object');

            status=true;
            switch aEvent
            case Sldv.Tasking.SldvEvents.AnalysisInit
                try

                    obj.initModelView();
                    obj.mModelView.view;
                catch



                    obj.done();
                    return;
                end





            case Sldv.Tasking.SldvChannels.ValidatedGoals
                assert(obj.isValidatorON,'Invalid Event');
                obj.mIterNum=obj.mIterNum+1;

                force=false;
                status=obj.evaluateValidatedGoals(aEvent,force);





                if(obj.isEof(Sldv.Tasking.SldvChannels.ValidatedGoals))
                    obj.done();
                    return;
                end

            case Sldv.Tasking.SldvChannels.ProcessedGoals
                assert(~obj.isValidatorON,'Invalid Event');
                obj.mIterNum=obj.mIterNum+1;

                force=false;
                status=obj.evaluateProcessedGoals(aEvent,force);





                if(obj.isEof(Sldv.Tasking.SldvChannels.ProcessedGoals))
                    obj.done();
                    return;
                end

            otherwise
                assert(false,'HighlighterTask received an invalid event');
            end

            return;
        end

        function doCleanup(obj,cause)



            obj.flush();

            return;
        end

        function flush(obj)
            force=true;
            if obj.isValidatorON
                obj.evaluateValidatedGoals('FLUSH',force);
            else
                obj.evaluateProcessedGoals('FLUSH',force);
            end

            return;
        end
    end

    methods(Access=private)
        function initModelView(obj)
            [tSldvData,~,obj.mGoalIdToObjectiveIdMap]=obj.mSldvAnalyzer.getStaticSldvData();
            progressUIHandle=obj.mSldvAnalyzer.getProgressUIHandle();
            obj.mModelView=Sldv.ModelView(tSldvData,[],progressUIHandle);

            return;
        end

        function yesno=shouldHighlightNow(obj,numGoalsAvailable)
            yesno=false;


            if(obj.mMinGoalCountForHlt<=numGoalsAvailable)
                yesno=true;



            elseif(0==mod(obj.mIterNum,obj.mMinItersForHlt))
                yesno=true;
            end

            return;
        end

        function status=evaluateValidatedGoals(obj,aEvent,force)
            status=true;
            numGoalsAvailable=obj.numDataAvailable(Sldv.Tasking.SldvChannels.ValidatedGoals);
            if(numGoalsAvailable)
                isChnDone=obj.isSourceDone(Sldv.Tasking.SldvChannels.ValidatedGoals);



                if((false==obj.shouldHighlightNow(numGoalsAvailable))&&...
                    (false==isChnDone)&&~force)

                    obj.yield();
                    return;
                end


                [status,goalIds,~]=obj.read(Sldv.Tasking.SldvChannels.ValidatedGoals);
                assert(status,'Unable to read from Validated Channel');

                obj.logGoalsNTestCases(goalIds,aEvent);


                obj.incrementalHighlight(goalIds);
            end

            return;
        end

        function status=evaluateProcessedGoals(obj,aEvent,force)
            status=true;
            numGoalsAvailable=obj.numDataAvailable(Sldv.Tasking.SldvChannels.ProcessedGoals);
            if(numGoalsAvailable)
                isChnDone=obj.isSourceDone(Sldv.Tasking.SldvChannels.ProcessedGoals);



                if((false==obj.shouldHighlightNow(numGoalsAvailable))&&...
                    (false==isChnDone)&&~force)

                    obj.yield();
                    return;
                end


                [status,goalIds,~]=obj.read(Sldv.Tasking.SldvChannels.ProcessedGoals);
                assert(status,'Unable to read from Processed Channel');

                obj.logGoalsNTestCases(goalIds,aEvent);


                obj.incrementalHighlight(goalIds);
            end

            return;
        end

        function incrementalHighlight(obj,goalIds)
            check=logical(slavteng('feature','IncrementalHighlighting'));
            assert(check,'Incremental Highlighting should be featured on');



            [objectivesStruct,pathObjectivesStruct]=...
            obj.getObjectivesFromGoals(goalIds);


            if~isempty(objectivesStruct)
                obj.mModelView.updateModifiedObjectives(objectivesStruct,pathObjectivesStruct);


                if obj.mSldvAnalyzer.isHighlightOn()
                    obj.mModelView.view();
                end
            end

            return;
        end

        function[objectivesStruct,pathObjectivesStruct]=getObjectivesFromGoals(obj,goalIds)
            objectivesStruct=struct('index',{},'status',{});
            pathObjectivesStruct=struct('index',{},'status',{});
            for ind=1:numel(goalIds)
                gId=goalIds(ind);

                if~isKey(obj.mGoalIdToObjectiveIdMap,gId)
                    continue;
                end
                type=obj.mSldvAnalyzer.getGoalType(gId);
                if strcmp(type,'AVT_GOAL_PATH_OBJECTIVE')
                    if isempty(pathObjectivesStruct)
                        pathObjectivesStruct(1).index=obj.mGoalIdToObjectiveIdMap(gId);
                        pathObjectivesStruct(1).status=obj.mSldvAnalyzer.getObjectiveStatus(gId);
                    else
                        pathObjectivesStruct(end+1).index=obj.mGoalIdToObjectiveIdMap(gId);%#ok<AGROW>
                        pathObjectivesStruct(end).status=obj.mSldvAnalyzer.getObjectiveStatus(gId);
                    end
                else
                    if isempty(objectivesStruct)
                        objectivesStruct(1).index=obj.mGoalIdToObjectiveIdMap(gId);
                        objectivesStruct(1).status=obj.mSldvAnalyzer.getObjectiveStatus(gId);
                    else
                        objectivesStruct(end+1).index=obj.mGoalIdToObjectiveIdMap(gId);%#ok<AGROW>
                        objectivesStruct(end).status=obj.mSldvAnalyzer.getObjectiveStatus(gId);
                    end
                end
            end

            return;
        end

        function logGoalsNTestCases(obj,goalIds,msgIdentifier)
            LoggerId='sldv::task_manager';
            logStr=sprintf('HighlighterTask::%s::Start Logging',msgIdentifier);
            sldvprivate('SLDV_LOG_DATA',LoggerId,logStr);

            for ind=1:numel(goalIds)
                logStr=sprintf('HighlighterTask::%s::Goal::Id::%d::Status::%s',msgIdentifier,goalIds(ind),obj.mSldvAnalyzer.getGoalStatus(goalIds(ind)));
                sldvprivate('SLDV_LOG_DATA',LoggerId,logStr);
            end
            logStr=sprintf('HighlighterTask::%s::End Logging',msgIdentifier);
            sldvprivate('SLDV_LOG_DATA',LoggerId,logStr);

            return;
        end
    end
end
