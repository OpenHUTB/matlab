


classdef MdlComp<Sldv.xform.SubSystemTreeNode&Sldv.Advisor.AbstractAdvisorNodeUI



    properties(Hidden)




        ComponentForAssessment=[];



        ExtractedModelFilePath='';

        IsExtracted=false;

        AtomicSubChartWithParam=false;


        ComplexityInfo=[];



        IsVisited=false;


        IsAtomicSubsystem=false;


        HasAtomicDescendent=false;



        RepresentsTopMdl=false;



        NotStandAlone=[];



        ReferencedMdlBlocks={};


        CoverageDescription={};


        Sid='';

    end

    properties(Access=private)


        TurnedOnAutoStubbing=false;



        LowerBoundRecommendedTimeForAnalyzable=300;


        LowerBoundRecommendedTimeForNotAnalyzable=600;


        mLauncher=[];
        mExecListener=[];
    end

    methods

        function obj=MdlComp(objH,heirAnalyzer)
            obj=obj@Sldv.xform.SubSystemTreeNode(objH);
            obj=obj@Sldv.Advisor.AbstractAdvisorNodeUI(get_param(objH,'Name'),heirAnalyzer);
            obj.Sid=Simulink.ID.getSID(obj.BlockH);
            obj.isAtomicSubsystem;
            obj.getCoverageDescription;




            obj.ComplexityInfo=Sldv.Advisor.ComplexityInfo();
            obj.ComplexityInfo.CovDecCnt=obj.getCoverageMetric('decision');
            obj.ComplexityInfo.CovCondCnt=obj.getCoverageMetric('condition');
        end

        function delete(obj)
            obj.cleanTimer();
        end

    end

    methods(Access=public,Hidden)





        [status,extractedH]=extract(obj,params)

        [status]=checkCompatibility(obj,params)

        [status,state]=checkForAnalysability(obj,params,sldvopts)

        [status,errorOccurred]=doQuickdeadLogicDetection(obj,params)



        function out=isLeaf(obj)
            out=isempty(obj.DirectSuccessors);
        end

        function tf=isTrivial(obj)
            tf=false;


            if obj.noObjectivesToAnalyze
                tf=true;
            end
        end

        function cnt=transCount(obj)
            cnt=obj.ComplexityInfo.SfClassCnt;
        end

        createComplexityInfo(obj)






        function markAllDescendentsSimpleToAnalyze(obj)
            child=obj.RightMostDown;
            while~isempty(child)
                if isa(child,'Sldv.Advisor.MdlRefBlkComp')
                    actualChild=child.CompGraph;
                else
                    actualChild=child;
                end
                actualChild.AnalysisState=Sldv.Advisor.MdlCompState.Simple;
                actualChild.markAllDescendentsSimpleToAnalyze;
                child=child.Left;
            end
        end




        function notCompatibleDueToEmptyMdl=isNotCompatibleDueToEmptyModel(obj)
            notCompatibleDueToEmptyMdl=false;

            myIncompatibility=obj.IncompatibilityMessages(obj.Sid);
            for i=1:length(myIncompatibility)
                m=myIncompatibility(i);
                if~isempty(m)&&isstruct(m)&&...
                    isempty(setdiff(fields(m),{'source','sourceFullName','objH','reportedBy','msg','msgid'}))
                    msgtmp={m.msg};
                    items=strfind(msgtmp,getString(message('Sldv:xform:MdlComp:Analyze:EmptyModel')));
                    notCompatibleDueToEmptyMdl=~isempty([items{:}]);
                end
            end
        end





        function tf=isPartiallyCompatible(obj)
            tf=false;

            myIncompatibility=obj.IncompatibilityMessages(obj.Sid);
            for i=1:length(myIncompatibility)
                m=myIncompatibility(i);
                if~isempty(m)&&isstruct(m)&&...
                    isempty(setdiff(fields(m),{'msg','msgid','modelitem'}))
                    tf=tf||(strcmp(m.msgid,'SLDV:Compatibility:PartiallyCompatible')==1);
                end
            end

        end







        function tf=hasFailedSubSysExtraction(obj)
            tf=false;

            if~isKey(obj.IncompatibilityMessages,obj.Sid)
                return;
            end


            myIncompatibility=obj.IncompatibilityMessages(obj.Sid);
            if~isempty(myIncompatibility)


                m=myIncompatibility(1);
                if~isempty(m)&&isstruct(m)&&...
                    isempty(setdiff(fields(m),{'msg','msgid','modelitem'}))
                    tf=tf||(strcmp(m.msgid,'Sldv:EXTRACT:Failed')==1);
                end
            end
        end


        function connectUp(obj,objParent)
            connectUp@Sldv.xform.SubSystemTreeNode(obj,objParent);
            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('HierarchyChangedEvent',objParent.proxyObj);
        end

        function parent=getParent(obj)
            parent=obj.Up;
        end








        function summary=getSummary(obj)
            summary=[];
            summary.sid=obj.Sid;
            if isempty(obj.ComplexityInfo)
                summary.objectives=0;
            else
                summary.objectives=obj.ComplexityInfo.CovDecCnt+...
                obj.ComplexityInfo.CovCondCnt;
            end
            summary.doclink='';
            if isempty(obj.DeadLogic)
                summary.dead='NA';
            else
                summary.dead=obj.DeadLogic.Dead;
            end
            if isempty(obj.TestGenResults)
                summary.testgen='NA';
            else
                if obj.TestGenResults.Total==0
                    summary.testgen='100%';
                else
                    num_obj=(obj.TestGenResults.Decided/obj.TestGenResults.Total)*100;


                    num_obj=round(num_obj,1);
                    summary.testgen=[num2str(num_obj),'%'];
                end
            end

            summary.icon=dependencies.file_url(obj.DerivedAnalysisState.iconPath);


            for i=1:length(obj.DirectSuccessors)
                child=obj.DirectSuccessors{i};
                child_summary=child.getSummary;
                summary=cat(1,summary,child_summary);
            end
        end



        function new_options=turnOnAutoStubbing(obj,options)
            new_options=deepCopy(options.SLDVOptions);
            new_options.AutomaticStubbing='on';
            obj.TurnedOnAutoStubbing=true;
        end

        function tEstimate=estimateAnalysisTimeForComponent(this)

            num_obj=this.ComplexityInfo.CovDecCnt+this.ComplexityInfo.CovCondCnt;

            children=this.DirectSuccessors;












            sum_timePerObj=0;
            for i=1:length(children)
                child=children{i};
                if~isempty(child.TestGenResults)
                    if child.TestGenResults.Total==0
                        decidedRatio=1;
                    else
                        decidedRatio=child.TestGenResults.Decided/child.TestGenResults.Total;
                    end
                    weight=1/(((decidedRatio+0.1)^2)*2);
                    sum_timePerObj=sum_timePerObj+weight*(child.TestGenResults.ActualTime/(child.TestGenResults.Decided+1));
                end
            end

            if~isempty(children)
                avg_timePerObj=sum_timePerObj/length(children);
            else
                avg_timePerObj=0;
            end

            tHeuristic=(avg_timePerObj*num_obj)+(0.5*num_obj);


            tEstimate=round(tHeuristic/10)*10;
        end


        function tf=isNotStandAlone(this)




            if isempty(this.NotStandAlone)
                if this.RepresentsTopMdl
                    [~,~,ssTriggerBlkHs,ssEnableBlkHs]=...
                    Sldv.utils.getSubSystemPortBlks(this.BlockH);
                    this.NotStandAlone=~isempty(ssTriggerBlkHs)||~isempty(ssEnableBlkHs);



                    detailMessage.msg=getString(message('Sldv:ComponentAdvisor:TriggeredMdlBlkIsNotStandalone'));
                    detailMessage.msgid='Sldv:ComponentAdvisor:TriggeredMdlBlkIsNotStandalone';
                    detailMessage.modelitem=this.Sid;
                    im=containers.Map;
                    im(this.Sid)=detailMessage;
                    this.IncompatibilityMessages=im;
                end
            end
            tf=this.NotStandAlone;
        end

        function formattedMessages=formatIncompatibilityMessages(obj,imessages)





            formattedMessages=struct('msg',{},'msgid',{},'modelitem',{});
            for i=1:length(imessages)
                im.msg=imessages(i).msg;
                im.msgid=imessages(i).msgid;



                if~isempty(imessages(i).objH)...
                    &&isValidSlObject(slroot,imessages(i).objH)
                    im.modelitem=Simulink.ID.getSID(imessages(i).objH);
                elseif~isempty(imessages(i).sourceFullName)&&...
                    isValidSlObject(slroot,imessages(i).sourceFullName)
                    im.modelitem=Simulink.ID.getSID(imessages(i).sourceFullName);
                else


                    im.modelitem=obj.Sid;
                end

                formattedMessages(i)=im;
            end

        end

    end

    methods(Access=private)
        function isAtomicSubsystem(obj)
            if strcmp(get_param(obj.BlockH,'Type'),'block')&&...
                strcmp(get_param(obj.BlockH,'BlockType'),'SubSystem')
                blockObj=get_param(obj.BlockH,'Object');
                portInfo=get_param(obj.BlockH,'PortHandles');









                obj.IsAtomicSubsystem=...
                strcmpi(blockObj.TreatAsAtomicUnit,'on')||...
                ~isempty(portInfo.Enable)||...
                ~isempty(portInfo.Trigger);

                obj.IsAtomicSubsystem=obj.IsAtomicSubsystem&&...
                isempty(portInfo.Ifaction);
            end
        end

        function getCoverageDescription(obj)
            if~obj.DvLibSubSystem&&~obj.UnderDVLibSubSystem

                topModelH=get_param(bdroot(obj.BlockH),'Handle');
                isTopCompiled=Sldv.xform.MdlInfo.isMdlCompiled(topModelH);
                assert(isTopCompiled,getString(message('Sldv:xform:MdlComp:MdlComp:ModelInCompileState',getfullname(topModelH))));
                obj.CoverageDescription=...
                SlCov.CoverageAPI.getCoverageDef(Simulink.ID.getSID(obj.BlockH));
            end
        end

        function cnt=getCoverageMetric(obj,metric)
            cnt=0;
            if~isempty(obj.CoverageDescription)
                for idx=1:numel(obj.CoverageDescription)
                    if strcmp(obj.CoverageDescription(idx).name,metric)
                        cnt=obj.CoverageDescription(idx).totalCount;
                        break;
                    end
                end
            end
        end

        function out=noObjectivesToAnalyze(obj)
            out=isempty(obj.ComplexityInfo)||...
            (obj.ComplexityInfo.CovDecCnt==0&&...
            obj.ComplexityInfo.CovCondCnt==0);
        end



        function calculateRecommendedOptions(obj,currentOptions,results,state)



            adviceAutoStubbing='';
            adviceMaxAnalysisTime=[];
            adviceStategy='';

            if obj.TurnedOnAutoStubbing
                adviceAutoStubbing='on';
            end


            if state==Sldv.Advisor.MdlCompState.Analyzable


                linearEstimate=2*(results.ActualTime/results.Decided)*results.Total;
                adviceMaxAnalysisTime=max(linearEstimate,obj.LowerBoundRecommendedTimeForAnalyzable);

            elseif state==Sldv.Advisor.MdlCompState.NotAnalyzable
                adviceMaxAnalysisTime=max(obj.estimateAnalysisTimeForComponent,obj.LowerBoundRecommendedTimeForNotAnalyzable);
            end

            obj.RecommendedOptions=deepCopy(currentOptions);
            if~isempty(adviceMaxAnalysisTime)
                obj.RecommendedOptions.MaxProcessTime=adviceMaxAnalysisTime;
            end
            if~isempty(adviceAutoStubbing)
                obj.RecommendedOptions.AutomaticStubbing=adviceAutoStubbing;
            end
            if~isempty(adviceStategy)
                obj.RecommendedOptions.TestSuiteOptimization=adviceStategy;
            end
        end

    end

    methods


        function startTG(obj)
            options=obj.RecommendedOptions;

            if isempty(options)
                analysisParams=obj.HierAnalyzer.getAnalysisParams();
                options=analysisParams.SLDVOptions;
            end

            options.Mode='TestGeneration';




            options.RebuildModelRepresentation='Always';



            mName=get_param(obj.HierAnalyzer.getModelHandle,'Name');




            oVar=matlab.lang.makeUniqueStrings([mName,'_options'],who);

            assignin('base',oVar,options);
















            obj.cleanTimer();




            period=0.1;
            obj.mLauncher=internal.IntervalTimer(period);


            showUI='true';
            startCov='[]';
            preExtract='[]';
            customEnhancedMCDCOpts='[]';
            client='Sldv.SessionClient.DVTGA';


            obj.mExecListener=event.listener(obj.mLauncher,'Executing',...
            @(src,evt)obj.timerCallback('sldvprivate','sldvRunAnalysis',...
            obj.Sid,oVar,showUI,startCov,preExtract,...
            customEnhancedMCDCOpts,client));



            start(obj.mLauncher);

        end

        function loadCurrentResults(obj)


            [status,errormsg]=sldvloadresults(bdroot(obj.BlockH),obj.TestGenResults.sldvDatafile,true);
            if status

                callbackInfo.model.Handle=bdroot(obj.BlockH);
                sldvprivate('util_menu_callback','load_active_results',callbackInfo);
            else
                new_exp=MException('Sldv:ComponentAdvisor:LoadResultsFailed',errormsg);
                MSLDiagnostic(new_exp).reportAsWarning;
            end

        end

    end


    methods(Access=private)
        function cleanTimer(obj)
            try

                if~isempty(obj.mExecListener)
                    clear('obj.mExecListener');
                    obj.mExecListener=[];
                end


                if~isempty(obj.mLauncher)
                    if obj.mLauncher.isRunning
                        stop(obj.mLauncher);
                    end
                    clear('obj.mLauncher');
                    obj.mLauncher=[];
                end
            catch

            end
        end

        function timerCallback(obj,fcn1,fcn2,model,options,showUI,...
            startCov,preExtract,customEnhancedMCDCOpts,client)
            stop(obj.mLauncher);
            evalin('base',sprintf('%s(''%s'', ''%s'', %s, %s, %s, %s, %s, %s);',...
            fcn1,fcn2,model,options,showUI,startCov,...
            preExtract,customEnhancedMCDCOpts,client));

            evalin('base',sprintf('clear %s',options));
        end
    end
end





















