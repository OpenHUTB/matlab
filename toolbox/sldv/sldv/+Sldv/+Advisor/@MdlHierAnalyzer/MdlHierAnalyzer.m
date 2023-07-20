




classdef(Sealed)MdlHierAnalyzer<handle




    properties(Hidden)



        ComponentStatus=[0,0,0,0,0,0];





        isReset=false;


        isAnalysisRunning=false;
    end

    properties(Access=private)

        ModelH=[];


        ModelName='';


        MdlHierInfo=[];




        AnalysisParams=[];




        IterationNumber=0;


        Visited={};


        OriginalWarningStatus;


        Explorer=[];

        JobQueue=[];



        TimePerComponentWidget=[];

        AnalysisTimePerComponent=20;
        AnalysisLevelPerComponent=0;


        ModelCloseListener=[];


        Store=[];


        TimeStamp=[];

    end

    methods(Access=public)
        function this=MdlHierAnalyzer(modelH)
            modelH=Sldv.utils.getObjH(modelH);
            if~isempty(modelH)
                modelObj=get_param(modelH,'Object');
                if~isa(modelObj,'Simulink.BlockDiagram')
                    modelH=[];
                end
            end
            if isempty(modelH)
                error(message('Sldv:xform:MdlHierAnalyzer:MdlHierAnalyzer:IncorrectInput'));
            end
            this.ModelH=modelH;

            this.ModelName=get_param(this.ModelH,'Name');

            this.JobQueue=Sldv.Utils.JobQueue();

            if slavteng('feature','TGALoadSavePrevResults')
                work_dir=fullfile(pwd,'sldv_output','sldv_advisor_output',...
                get_param(modelH,'Name'));
                this.Store=Sldv.Advisor.Repository(this,work_dir);
            end


            oModel=get_param(modelH,'Object');
            this.ModelCloseListener=Simulink.listener(oModel,'CloseEvent',...
            @(src,evt)modelCloseListener(src,evt,this));

            function modelCloseListener(~,~,src)
                delete(src);
            end
        end



        function delete(this)
            this.JobQueue.stop();
            delete(this.Explorer);
        end



        launch(this);




        recheckHierarchy(this,time);

        function me=getAdvisorUI(this)
            me=this.Explorer;
        end

        function modelH=getModelHandle(this)
            modelH=this.ModelH;
        end

        function valid=validateAdvisor(this)


            try
                currentName=get_param(this.ModelH,'Name');
                valid=(this.ModelName==currentName);
            catch Mex %#ok<NASGU>
                valid=false;
            end
            if~valid
                DAStudio.error('Sldv:ComponentAdvisor:TGASystemRenamed',this.ModelName);
            end
        end

    end

    methods(Access=public,Hidden)


        setup(this);

        function replay(this,blockH,recurse)





            if this.isAnalysisRunning
                return;
            end

            this.isAnalysisRunning=true;
            this.JobQueue.flush();
            this.updateStatusMessage(message('Sldv:ComponentAdvisor:StatusStart'));
            job.run=@()this.run(blockH,recurse);
            this.JobQueue.enqueue(job,false);
            this.JobQueue.start();
        end


        function pause(this)
            this.updateStatusMessage(message('Sldv:ComponentAdvisor:StatusPausing'));
            this.JobQueue.stop();
            this.JobQueue.flush();

            if slavteng('feature','TGALoadSavePrevResults')
                this.Store.save();
            end
            this.isAnalysisRunning=false;
            this.updateStatusMessage(message('Sldv:ComponentAdvisor:StatusDone'));
        end


        function stop(this)
            this.updateStatusMessage(message('Sldv:ComponentAdvisor:StatusStopping'));
            this.JobQueue.stop();
            this.JobQueue.flush();
            this.updateStatusMessage(message('Sldv:ComponentAdvisor:StatusReset'));
            this.resetAnalysisStateForAll;
            if slavteng('feature','TGALoadSavePrevResults')
                this.Store.save();
            end
            this.isAnalysisRunning=false;
            this.updateStatusMessage(message('Sldv:ComponentAdvisor:StatusDone'));
        end

        function initProgressFraction(this)
            this.ComponentStatus=[0,0,0,0,0,0];

            total=length(this.MdlHierInfo.MdlObjectToComponentMap.keys);
            this.ComponentStatus(Sldv.Advisor.MdlCompState.NotProcessedYet.idx)=total;
        end


        function mdlHierInfo=getModelHierarchyInfo(this)
            mdlHierInfo=this.MdlHierInfo;
        end


        function timer=getJobQueueTimer(this)
            timer=this.JobQueue.jobTimer;
        end

        function expandAll(this)

            imExplorer=DAStudio.imExplorer(this.getAdvisorUI);


            rootNode=this.MdlHierInfo.CompGraph;
            iterator=Sldv.xform.TreeBFSIterator(rootNode);
            iterator.firstElement(rootNode);

            while true
                node=iterator.currentElement;
                for i=1:length(node.proxyObj)
                    imExplorer.expandTreeNode(node.proxyObj{i});
                end

                if iterator.hasMoreElements
                    iterator.nextElement;
                else
                    break;
                end

            end
        end

        function collapseAll(this)

            imExplorer=DAStudio.imExplorer(this.getAdvisorUI);


            rootNode=this.MdlHierInfo.CompGraph;
            iterator=Sldv.xform.TreeBFSIterator(rootNode);
            iterator.firstElement(rootNode);

            while true
                node=iterator.currentElement;
                for i=1:length(node.proxyObj)
                    imExplorer.collapseTreeNode(node.proxyObj{i});
                end

                if iterator.hasMoreElements
                    iterator.nextElement;
                else
                    break;
                end

            end
        end


        function clearReset(this)
            this.isReset=false;
        end

        function params=getAnalysisParams(this)
            params=this.AnalysisParams;
        end

        function updateTimeStamp(this)

            this.TimeStamp=datenum(datetime('now'));
        end

        function ts=getTimeStamp(this)
            ts=this.TimeStamp;
        end
    end


    methods(Access=private)

        function me=createExplorer(this,meNode)

            title=getString(message('Sldv:ComponentAdvisor:Title',meNode.label));
            me=DAStudio.Explorer(meNode,title,false);

            me.title=title;
            me.setTreeTitle(getString(message('Sldv:ComponentAdvisor:ComponentHeirLabel')));

            me.showListView(false);


            me.showStatusBar(true);



            am=DAStudio.ActionManager;


            am.initializeClient(me);


            tb=am.createToolBar(me);


            model_sid=Simulink.ID.getSID(this.ModelH);
            callback_prefix=['sldvprivate(','''component_advisor_cb'',''',model_sid,''','];


            reset=am.createAction(me);
            reset.icon=fullfile(matlabroot,'toolbox','sldv','sldv','resources','edit_undo.png');
            reset.toolTip=getString(message('Sldv:ComponentAdvisor:StatusTipStop'));
            reset.callback=[callback_prefix,'''stop'')'];
            tb.addAction(reset);


            pause=am.createAction(me);
            pause.icon=fullfile(matlabroot,'toolbox','sldv','sldv','resources','pause.png');
            pause.toolTip=getString(message('Sldv:ComponentAdvisor:StatusTipPause'));
            pause.callback=[callback_prefix,'''pause'')'];
            tb.addSeparator;
            tb.addAction(pause);


            play=am.createAction(me);
            play.icon=fullfile(matlabroot,'toolbox','sldv','sldv','resources','run_small.png');
            play.toolTip=getString(message('Sldv:ComponentAdvisor:StatusTipPlay'));
            play.callback=[callback_prefix,'''play'')'];

            tb.addSeparator;
            tb.addAction(play);


            expand_all=am.createAction(me);
            expand_all.icon=fullfile(matlabroot,'toolbox','sldv','sldv','resources','tree-expand-all.png');
            expand_all.toolTip=getString(message('Sldv:ComponentAdvisor:StatusTipExpandAll'));
            expand_all.callback=[callback_prefix,'''expand_all'')'];
            me.addTreeAction(expand_all);



            collapse_all=am.createAction(me);
            collapse_all.icon=fullfile(matlabroot,'toolbox','sldv','sldv','resources','tree-collapse-all.png');
            collapse_all.toolTip=getString(message('Sldv:ComponentAdvisor:StatusTipCollapseAll'));
            collapse_all.callback=[callback_prefix,'''collapse_all'')'];

            me.addTreeAction(collapse_all);



            timeLabel=am.createToolBarText(tb);
            timeLabel.setText(getString(message('Sldv:ComponentAdvisor:TimeLabel')));
            tb.addSeparator;
            tb.addWidget(timeLabel);


            timeEdit=am.createToolBarEdit(tb);
            timeEdit.setText(num2str(this.AnalysisTimePerComponent));
            timeEdit.setToolTip(getString(message('Sldv:ComponentAdvisor:TooltipTime')));
            timeEdit.setEnabled(true);
            timeEdit.setMaximumSize(80,20);

            this.TimePerComponentWidget=timeEdit;
            tb.addWidget(timeEdit);
            tb.addSeparator;



            help=am.createAction(me);
            help.icon=fullfile(matlabroot,'toolbox','shared','dastudio','resources','help.png');
            help.toolTip=getString(message('Sldv:ComponentAdvisor:StatusTipHelp'));
            help.callback=['sldvprivate(','''util_testgen_advisor_open_help'',''','help_main''',')'];

            tb.addAction(help);
            tb.addSeparator;

            me.setDispatcherEvents({'PropertyChangedEvent','HierarchyChangedEvent'});
        end



        run(this,startNode,recurse,time);



        analyzeCompGraphScheduler(this,filter,node,front);


        analyzeComp(this,mdlComp);





        function ok=setInitialAssessmentOptions(this)


            ok=true;
            options=sldvoptions(this.ModelH);

            opts=options.deepCopy;

            opts.Mode='TestGeneration';


            opts.OutputDir=[this.Store.getWorkDir,'/$ModelName$'];
            opts.SaveReport='off';
            opts.SaveHarnessModel='off';
            opts.TestSuiteOptimization='Auto';

            opts.ModelCoverageObjectives='ConditionDecision';


            opts.IncludeRelationalBoundary='off';
            opts.CovFilter='off';
            opts.IgnoreCovSatisfied='off';
            opts.ExtendExistingTests='off';
            opts.MakeOutputFilesUnique='on';
            opts.TestObjectives='DisableAll';


            inputTime=str2double(this.TimePerComponentWidget.getText);

            nProcessed=this.getProcessedCompNumber;

            if nProcessed==0
                suggestedTime=20;
            else
                suggestedTime=max(20,this.AnalysisTimePerComponent);
            end

            if inputTime<suggestedTime




                answer=questdlg(getString(message('Sldv:ComponentAdvisor:InputTimeLessThanEstimate',...
                num2str(suggestedTime),num2str(inputTime))),...
                getString(message('Sldv:ComponentAdvisor:MinAnalysisTime')),...
                getString(message('Sldv:ComponentAdvisor:ButtonOk')),...
                getString(message('Sldv:ComponentAdvisor:ButtonCancel')),...
                getString(message('Sldv:ComponentAdvisor:ButtonCancel')));


                if~strcmp(answer,getString(message('Sldv:ComponentAdvisor:ButtonOk')))
                    ok=false;
                    return;
                end
            end

            this.AnalysisTimePerComponent=inputTime;
            opts.MaxProcessTime=this.AnalysisTimePerComponent;
            opts.AnalysisLevel=this.AnalysisLevelPerComponent;

            iterativeOpts.SLDVOptions=opts;
            iterativeOpts.('MeasureCoverage')=false;
            iterativeOpts.('MaxObjUndecidedRatio')=0.5;
            iterativeOpts.('MaxObjErrorRatio')=0.5;
            iterativeOpts.('GenCompHierarchyTree')=true;


            iterativeOpts.('MaxStartCovObj')=250;
            iterativeOpts.('MaxStartBlockCnt')=150;
            iterativeOpts.('MaxStartSFTransCnt')=60;

            this.AnalysisParams=iterativeOpts;
        end








        function out=isSimple(this,mdlComp)
            params=this.AnalysisParams;
            cmplx=mdlComp.ComplexityInfo;


            if(isempty(cmplx)||~mdlComp.IsAtomicSubsystem)
                out=false;
                return;
            end



            if(cmplx.SlBlkCnt>params.MaxStartBlockCnt)||...
                ((cmplx.CovDecCnt+cmplx.CovCondCnt)>params.MaxStartCovObj)||...
                (mdlComp.transCount>params.MaxStartSFTransCnt)
                out=false;
                return;
            end


            out=true;
        end



        function resetAnalysisStateForAll(this)

            rootNode=this.MdlHierInfo.CompGraph;
            iterator=Sldv.xform.TreeBFSIterator(rootNode);
            iterator.firstElement(rootNode);
            rootElem=iterator.currentElement;


            lock=Sldv.Advisor.ScopedLockAdvisor(this.getAdvisorUI,rootElem.proxyObj);%#ok<NASGU>



            this.isReset=true;
            cl=onCleanup(@()this.clearReset);



            while true
                node=iterator.currentElement;
                node.reset();

                if iterator.hasMoreElements
                    iterator.nextElement;
                else
                    break;
                end

            end

            this.clearReset;

            this.initProgressFraction;
        end


        function updateStatusMessage(this,msg)
            explorer=this.getAdvisorUI();
            explorer.setStatusMessage(getString(msg));
        end

        function updateEstimatedAnalysisTimePerComponent(this)


            if(this.ComponentStatus(Sldv.Advisor.MdlCompState.NotProcessedYet.idx)+...
                this.ComponentStatus(Sldv.Advisor.MdlCompState.NotAnalyzable.idx)>0)

                if this.AnalysisTimePerComponent<20
                    this.AnalysisTimePerComponent=20;
                elseif this.AnalysisTimePerComponent<40
                    this.AnalysisTimePerComponent=40;
                elseif this.AnalysisTimePerComponent<80
                    this.AnalysisTimePerComponent=80;
                elseif this.AnalysisTimePerComponent<160
                    this.AnalysisTimePerComponent=160;
                elseif this.AnalysisTimePerComponent<300
                    this.AnalysisTimePerComponent=300;
                end

                this.TimePerComponentWidget.setText(num2str(this.AnalysisTimePerComponent));
            end
        end

        function processed=getProcessedCompNumber(this)
            processed=sum(this.ComponentStatus)-...
            this.ComponentStatus(Sldv.Advisor.MdlCompState.NotProcessedYet.idx);
        end

    end












end


