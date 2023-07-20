classdef SolverProfilerClass<handle




    properties(SetAccess=private)





















AppContainer
SPToolstrip
SPDocument
SPData
ModelConfig
SPPlotter


IsNewProfilingSessionFinished
    end


    methods


        function obj=SolverProfilerClass(mdl)
            import matlab.ui.internal.*
            import solverprofiler.util.*
            import solverprofiler.internal.ModelConfigClass;
            import solverprofiler.internal.SolverProfilerDataClass;


            obj.IsNewProfilingSessionFinished=false;

            load_system(mdl);
            set_param(mdl,'simulationcommand','stop');
            obj.ModelConfig=ModelConfigClass(mdl);
            obj.SPData=SolverProfilerDataClass(mdl);



            obj.createSolverProfilerToolgroup(mdl);
            obj.createSolverProfilerToolstrip(mdl);
            obj.createSolverProfilerDocumentViews(mdl);



            obj.SPPlotter=SPPlotter(obj.SPDocument.getStepSizePlotHandle(),obj.SPData);





            addlistener(obj.AppContainer,'StateChanged',@obj.appContainerCallback);


            obj.AppContainer.Visible=true;




            if strcmp(get_param(mdl,'SaveState'),'on')
                obj.SPToolstrip.setStateCheckbox(true);
                obj.ModelConfig.enableStateLogging();
            end
            try
                if strcmp(get_param(mdl,'SimscapeLogSimulationStatistics'),'on')...
                    &&~strcmp(get_param(mdl,'SimscapeLogType'),'none')
                    obj.SPToolstrip.setSimlogCheckbox(true);
                    obj.ModelConfig.enableSimscapeStateLogging();
                end
            catch
            end
        end


        function delete(obj)
            obj.cleanup();
            obj.SPToolstrip.delete();
            obj.SPDocument.delete();
            obj.SPData.delete();
            obj.ModelConfig.delete();
            obj.SPPlotter.delete();
            obj.AppContainer.delete();
        end


        function modelCloseCallback(obj,~,~)
            obj.delete();
        end


        function appContainerCallback(obj,~,~)
            if obj.AppContainer.State==matlab.ui.container.internal.appcontainer.AppState.TERMINATED
                obj.delete();
            elseif obj.AppContainer.State==matlab.ui.container.internal.appcontainer.AppState.RUNNING
                obj.SPDocument.moveFocusToDiagnostics();
            end
        end


        function cleanup(obj,~,~)

            mdl=obj.SPData.getData('Model');
            if bdIsLoaded(mdl)

                status=get_param(mdl,'simulationstatus');




                currentTimer=obj.getCurrentTimer();
                if~strcmp(status,'stopped')&&~isempty(currentTimer)
                    set_param(mdl,'simulationcommand','stop');
                end


                obj.ModelConfig.restoreConfig();

                bdHandle=get_param(mdl,'Handle');
                SLStudio.HighlightSignal.removeHighlighting(bdHandle);
            end


            timerTag=obj.SPData.getData('TimerTag');
            if~isempty(timerTag)
                timers=timerfind('Tag',timerTag);
                if~isempty(timers)
                    stop(timers);
                    delete(timers);
                end
            end
        end

        function currentTimer=getCurrentTimer(obj)
            timerTag=obj.SPData.getData('TimerTag');
            currentTimer=timerfind('Tag',timerTag);
        end

        function flag=hasNewProfilingSessionFinished(SP)
            flag=SP.IsNewProfilingSessionFinished;
        end


        function saveButtonCallback(SP,~,~)
            import solverprofiler.internal.SolverProfilerSessionDataManager
            import solverprofiler.util.*

            strSaveSession=utilDAGetString('saveSession');
            [filename,pathname]=uiputfile('*.mat',strSaveSession,'Untitled.mat');
            if(filename~=0)
                mgr=SolverProfilerSessionDataManager(SP.SPData);
                mgr.saveSessionData(pathname,filename);
                mgr.delete();
            end
        end


        function saveDataCallback(SP,~,~)
            SP.saveButtonCallback([],[]);
        end

        function saveRuleCallback(SP,~,~)
            customRules.tag='SPRule';
            customRules.ruleSet=SP.SPData.getRuleSet();
            [filename,pathname]=uiputfile('*.mat','Export Rules','Untitled.mat');
            if(filename~=0)
                save(fullfile(pathname,filename),'customRules');
            end
        end


        function openLoadDataCallback(SP,~,~)
            SP.openButtonCallback();
        end
        function openLoadRuleCallback(SP,~,~)
            [filename,pathname]=uigetfile('*.mat');
            if filename==0,return;end
            readIn=load([pathname,filename]);


            try
                if strcmp(readIn.customRules.tag,'SPRule')
                    SP.SPData.setRuleSet(readIn.customRules.ruleSet);
                    SP.SPData.updateWindow();
                else
                    utilPopMsgBox('',utilDAGetString('ruleLoadFail'),'ruleLoadFail');
                    return
                end
            catch
                utilPopMsgBox('',utilDAGetString('ruleLoadFail'),'ruleLoadFail');
                return;
            end
        end


        function openButtonCallback(SP,~,~)
            import solverprofiler.util.*

            [filename,pathname]=uigetfile('*.mat');
            if filename==0,return;end
            readIn=load([pathname,filename]);

            try
                sessionData=readIn.sessionData;
            catch
                id=utilDAGetString('failedToLoadData');
                msg=utilDAGetString('notASessionDataForCurrentRelease');
                utilPopErrDlg(id,msg,'failedToLoadData');
                return;
            end
            SP.loadSavedSessionData(sessionData);
            mdl=sessionData.getModel();
            SP.changeSPTitle([mdl,' : ',fullfile(pathname,filename)])
        end


        function changeSPTitle(SP,title)
            SP.AppContainer.Title=title;
        end


        function loadSavedSessionData(SP,sessionData)
            import solverprofiler.internal.SolverProfilerSessionDataManager
            import solverprofiler.util.*

            mgr=SolverProfilerSessionDataManager(SP.SPData);
            try
                mgr.loadSessionData(sessionData);
            catch exception
                if regexp(exception.identifier,'failedToLoadData')
                    id=utilDAGetString('failedToLoadData');
                    msg=exception.message;
                    utilPopErrDlg(id,msg,exception.identifier);
                    return;
                else
                    rethrow(exception);
                end
            end
            mgr.delete();



            uiStatus=SP.SPData.getData('UIStatusAtSim');
            if~isempty(uiStatus)&&SP.isUIStatusValid(uiStatus)
                SP.SPToolstrip.restoreUIStatusAtSim(uiStatus);
            end

            SP.populateAllDocument();
            SP.resetButtonsAfterSim();
        end


        function valid=isUIStatusValid(~,uiStatus)
            valid=true;
            fields={'from','to','buffer','state','zc','simlog','jacobian','simscapeStiffness'};
            for i=1:length(fields)
                if~isfield(uiStatus,fields{i})
                    valid=false;
                    return;
                end
            end
        end


        function tabSelectCallback(obj,~,evt)
            import solverprofiler.util.*
            if~isvalid(obj)||~strcmp(evt.PropertyName,'SelectedChild')
                return;
            end





            hfig=obj.SPDocument.getStepSizePlotHandle();
            if isempty(hfig)
                return;
            end


            if~isvalid(hfig)||~(obj.SPData.isDataReady())
                return;
            end

            fName=obj.AppContainer.SelectedChild.title;


            if strcmp(obj.SPData.getData('TabSelected'),fName)
                return;
            else
                obj.SPData.setData('TabSelected',fName);
            end


            hilitePath='';
            fileInfo='';
            switch(fName)
            case utilDAGetString('Zerocrossing')
                if(~isempty(obj.SPData.getSelectedBlockNameFromZCLst()))
                    hilitePath=obj.SPData.getSelectedBlockNameFromZCLst();
                end
            case utilDAGetString('Solverreset')
                if(~isempty(obj.SPData.getSelectedBlockNameFromResetLst()))
                    hilitePath=obj.SPData.getSelectedBlockNameFromResetLst();
                end
            case utilDAGetString('Solverexception')
                if(~isempty(obj.SPData.getSelectedBlockNameFromExceptionLst()))
                    hilitePath=obj.SPData.getSelectedBlockNameFromExceptionLst();
                end
            case utilDAGetString('JacobianAnalysis')
                if(~isempty(obj.SPData.getSelectedBlockNameFromJacobianLst()))
                    hilitePath=obj.SPData.getSelectedBlockNameFromJacobianLst();
                end
            case utilDAGetString('SscStiff')
                if(~isempty(obj.SPData.getSelectedBlockNameFromSscStiffData()))
                    hilitePath=obj.SPData.getSelectedBlockNameFromSscStiffData();
                    fileInfo=obj.SPData.getSelectedFileInfoFromSscStiffData();
                end
            case utilDAGetString('Statistics')
            case utilDAGetString('InaccurateState')
                if(~isempty(obj.SPData.getSelectedBlockNameFromInaccurateStateLst()))
                    hilitePath=obj.SPData.getSelectedBlockNameFromInaccurateStateLst();
                end
            end

            obj.SPData.setData('HilitePath',hilitePath);

            if~isempty(hilitePath)

                obj.adjustTraceHiliteSSCButtons(hilitePath);
            else
                obj.SPToolstrip.disableHiliteAndTrace();

                if~isempty(obj.SPData.getSimlog())
                    obj.SPToolstrip.enableIcon('SSCButton');
                end
            end

            obj.SPData.setData('FileInfo',fileInfo);

            if~isempty(fileInfo)
                obj.SPToolstrip.enableIcon('SrcFileButton');
            else
                obj.SPToolstrip.disableIcon('SrcFileButton');
            end


            obj.SPToolstrip.disableIcon('ExportTabButton');

            obj.SPToolstrip.enableViewPanel();

            if strcmp(fName,utilDAGetString('Stepsize'))
                obj.SPToolstrip.enableIcon('ExportTabButton');
            elseif strcmp(fName,utilDAGetString('Statistics'))
                obj.SPToolstrip.enableIcon('ExportTabButton');
                obj.SPData.setData('TopTableName',fName);
            elseif strcmp(fName,utilDAGetString('Zerocrossing'))
                if obj.SPData.isThereAnyZCEvent()==false
                    return;
                end
                obj.SPToolstrip.enableIcon('ExportTabButton');
                obj.SPData.setData('TopTableName',fName);
            elseif strcmp(fName,utilDAGetString('Solverexception'))
                if obj.SPData.isThereAnyException()==false
                    return;
                end
                obj.SPToolstrip.enableIcon('ExportTabButton');
                obj.SPData.setData('TopTableName',fName);
            elseif strcmp(fName,utilDAGetString('JacobianAnalysis'))
                obj.SPToolstrip.enableIcon('ExportTabButton');
                obj.SPData.setData('TopTableName',fName);
            elseif strcmp(fName,utilDAGetString('SscStiff'))
                obj.SPToolstrip.enableIcon('ExportTabButton');
                obj.SPData.setData('TopTableName',fName);
            elseif strcmp(fName,utilDAGetString('Solverreset'))
                obj.SPToolstrip.enableIcon('ExportTabButton');
                obj.SPData.setData('TopTableName',fName);
            elseif strcmp(fName,utilDAGetString('InaccurateState'))
                obj.SPToolstrip.enableIcon('ExportTabButton');
                obj.SPData.setData('TopTableName',fName);
            end
        end



        function zcCheckboxCallback(SP,src,~)






            isRemovingActiveZCTableSelection=...
            src.Value==0&&...
            SP.SPData.isZCTabSelected()&&...
            ~isempty(SP.SPData.getData('ZCTableRowSelected'));

            hfig=SP.SPDocument.getStepSizePlotHandle();
            if isvalid(hfig)&&~isempty(hfig.CurrentAxes)
                SP.SPPlotter.updateZCCheckBoxPoints(SP.SPToolstrip.isZCCheckboxSelected());
            end

            if(isRemovingActiveZCTableSelection)

                SP.SPToolstrip.disableHiliteAndTrace();

                if~isempty(SP.SPData.getSimlog())
                    SP.SPToolstrip.enableIcon('SSCButton');
                end

                SP.SPData.setData('HilitePath',[]);
            end
        end


        function failureCheckboxCallback(SP,src,~)






            isRemovingActiveExceptionTableSelection=...
            src.Value==0&&...
            SP.SPData.isExceptionTabSelected()&&...
            ~isempty(SP.SPData.getData('ExceptionTableRowSelected'));

            hfig=SP.SPDocument.getStepSizePlotHandle();
            if isvalid(hfig)&&~isempty(hfig.CurrentAxes)
                SP.SPPlotter.updateFailureCheckBoxPoints(SP.SPToolstrip.isExceptionCheckboxSelected());
            end

            if(isRemovingActiveExceptionTableSelection)

                SP.SPToolstrip.disableHiliteAndTrace();

                if~isempty(SP.SPData.getSimlog())
                    SP.SPToolstrip.enableIcon('SSCButton');
                end

                SP.SPData.setData('HilitePath',[]);
            end
        end


        function resetCheckboxCallback(SP,src,~)






            isRemovingActiveResetTableSelection=...
            src.Value==0&&...
            SP.SPData.isResetTabSelected()&&...
            ~isempty(SP.SPData.getData('ResetTableRowSelected'));

            hfig=SP.SPDocument.getStepSizePlotHandle();
            if isvalid(hfig)&&~isempty(hfig.CurrentAxes)
                SP.SPPlotter.updateSolverResetCheckBoxPoints(SP.SPToolstrip.isResetCheckboxSelected());
            end

            if(isRemovingActiveResetTableSelection)

                SP.SPToolstrip.disableHiliteAndTrace();

                if~isempty(SP.SPData.getSimlog())
                    SP.SPToolstrip.enableIcon('SSCButton');
                end

                SP.SPData.setData('HilitePath',[]);
            end

        end


        function jacobianCheckboxCallback(SP,src,~)






            isRemovingActiveJacobianTableSelection=...
            src.Value==0&&...
            SP.SPData.isJacobianTabSelected()&&...
            ~isempty(SP.SPData.getData('JacobianTableRowSelected'));

            hfig=SP.SPDocument.getStepSizePlotHandle();
            if isvalid(hfig)&&~isempty(hfig.CurrentAxes)
                SP.SPPlotter.updateJacobianCheckBoxPoints(SP.SPToolstrip.isJacobianCheckboxSelected());
            end

            if(isRemovingActiveJacobianTableSelection)

                SP.SPToolstrip.disableHiliteAndTrace();

                if~isempty(SP.SPData.getSimlog())
                    SP.SPToolstrip.enableIcon('SSCButton');
                end

                SP.SPData.setData('HilitePath',[]);
            end

        end



        function panCallback(SP,~,evt)
            if(evt.Source.Value)
                SP.SPToolstrip.unselectZoomOut();
                SP.SPToolstrip.unselectZoomIn();
                SP.SPDocument.turnOnPan();
            else
                SP.SPDocument.turnOffPan();
            end
            drawnow;
        end


        function zoomOutCallback(SP,~,evt)
            if(evt.Source.Value)
                SP.SPToolstrip.unselectZoomIn();
                SP.SPToolstrip.unselectPan();
                SP.SPDocument.turnOnZoom('out');
            else
                if~SP.SPToolstrip.isZoomInSelected()
                    SP.SPDocument.turnOffZoom();
                end
            end
            drawnow;
        end


        function zoomInCallback(SP,~,evt)
            if(evt.Source.Value)
                SP.SPToolstrip.unselectZoomOut();
                SP.SPToolstrip.unselectPan();
                SP.SPDocument.turnOnZoom('in');
            else
                if~SP.SPToolstrip.isZoomOutSelected()
                    SP.SPDocument.turnOffZoom();
                end
            end
            drawnow;
        end

        function figureZoomPanPostCallback(SP,~,~)
            hfig=SP.SPDocument.getStepSizePlotHandle;
            SP.SPData.setData('FigureTimeRange',hfig.CurrentAxes.XLim);


            fakeSrc.Value=SP.SPDocument.getExceptionTableRankingType();
            SP.exceptionTablePopdownCallback(fakeSrc,[]);


            tableContent=SP.SPData.getZeroCrossingTableContent();
            SP.SPDocument.populateZeroCrossingTable(tableContent);


            SP.SPData.setData('ZCTableRowSelected',[]);


            tableContent=SP.SPData.getJacobianTableContent();
            SP.SPDocument.populateJacobianTable(tableContent);


            tableContent=SP.SPData.getResetTableContent();
            SP.SPDocument.populateResetTable(tableContent);


            SP.SPToolstrip.disableHiliteAndTrace();
        end


        function exceptionTablePopdownCallback(SP,src,~)
            if~(SP.SPData.isDataReady())
                return;
            end

            tableContent=SP.SPData.getExceptionTableContent(src.Value);
            SP.SPDocument.populateExceptionTable(tableContent);

            SP.SPData.setData('ExceptionTableRowSelected',[]);
            SP.SPData.setData('ExceptionTableColumnSelected',[]);
        end



        function tableSelectCallback(SP,~,evt)

            coordinate=evt.Indices;
            if isempty(coordinate)||~(SP.SPData.isDataReady())
                return
            end

            if SP.SPData.isZCTabSelected()

                SP.SPToolstrip.setZCCheckbox(true);



                SP.SPData.setData('ZCTableRowSelected',coordinate(1));
                hilitePath=SP.SPData.getSelectedBlockNameFromZCLst();


                SP.SPPlotter.plotSelectedZCEvents();

            elseif SP.SPData.isExceptionTabSelected()

                SP.SPToolstrip.setExceptionCheckbox(true);



                SP.SPData.setData('ExceptionTableRowSelected',coordinate(1));
                SP.SPData.setData('ExceptionTableColumnSelected',coordinate(2));
                hilitePath=SP.SPData.getSelectedBlockNameFromExceptionLst();


                SP.SPPlotter.plotSelectedExeceptionEvents();

            elseif SP.SPData.isJacobianTabSelected()



                SP.SPData.setData('JacobianTableRowSelected',coordinate(1));
                hilitePath=SP.SPData.getSelectedBlockNameFromJacobianLst();

            elseif SP.SPData.isSscStiffTabSelected()


                SP.SPData.setData('SscStiffTableRowSelected',coordinate(1));
                hilitePath=SP.SPData.getSelectedBlockNameFromSscStiffData();
                fileInfo=SP.SPData.getSelectedFileInfoFromSscStiffData();
                SP.SPData.setData('FileInfo',fileInfo);
                if~isempty(fileInfo)
                    SP.SPToolstrip.enableIcon('SrcFileButton');
                else
                    SP.SPToolstrip.disableIcon('SrcFileButton');
                end

            elseif SP.SPData.isResetTabSelected()

                SP.SPToolstrip.setResetCheckbox(true);



                SP.SPData.setData('ResetTableRowSelected',coordinate(1));
                SP.SPData.setData('ResetTableColumnSelected',coordinate(2));
                hilitePath=SP.SPData.getSelectedBlockNameFromResetLst();


                SP.SPPlotter.plotSelectedResetEvents();

            elseif SP.SPData.isInaccurateStateTableSelected()


                SP.SPData.setData('InaccurateStateTableRowSelected',coordinate(1));
                hilitePath=SP.SPData.getSelectedBlockNameFromInaccurateStateLst();
            end

            SP.SPData.setData('HilitePath',hilitePath);



            SP.adjustTraceHiliteSSCButtons(hilitePath);
        end


        function statisticsTableSelectCallback(SP,src,evt)
            import solverprofiler.internal.OverviewTableRowIndex;


            coordinate=evt.Indices;
            if isempty(coordinate)||~(SP.SPData.isDataReady())
                return
            end
            row=coordinate(1);


            SP.SPData.setData('StatisticsTableRowSelected',coordinate(1,1));


            if(row>=OverviewTableRowIndex.ZeroCrossing)
                SP.SPToolstrip.setExceptionCheckbox(false);
                SP.SPToolstrip.setResetCheckbox(false);
                SP.SPToolstrip.setJacobianUpdateCheckbox(false);
                SP.SPToolstrip.setZCCheckbox(false);
                SP.SPPlotter.removeAllEventDots();
            end


            SP.SPDocument.refreshAllTables();

            if row==OverviewTableRowIndex.ZeroCrossing
                SP.SPDocument.moveFocusToZeroCrossingTable();
                SP.SPDocument.moveFocusToStatisticsTable();
                SP.SPToolstrip.setZCCheckbox(true);

            elseif row==OverviewTableRowIndex.JacobianUpdate
                if(SP.SPToolstrip.getJacobianCheckbox())
                    SP.SPDocument.moveFocusToJacobianTable();
                    SP.SPDocument.moveFocusToStatisticsTable();
                end
                SP.SPToolstrip.setJacobianUpdateCheckbox(true);

            elseif(row>=OverviewTableRowIndex.TotalReset)&&...
                (row<=OverviewTableRowIndex.InternalReset)
                SP.SPDocument.moveFocusToResetTable();
                SP.SPDocument.moveFocusToStatisticsTable();
                SP.SPToolstrip.setResetCheckbox(true);

            elseif(row>=OverviewTableRowIndex.TotalException)&&...
                (row<=OverviewTableRowIndex.ExceptionByDAENewtonIteration)
                SP.SPDocument.moveFocusToExceptionTable();
                SP.SPDocument.moveFocusToStatisticsTable();
                SP.SPToolstrip.setExceptionCheckbox(true);

                val=row-OverviewTableRowIndex.InternalReset;
                SP.SPDocument.setExceptionTableRankTypeTo(val);
                fakeSrc.Value=val;
                SP.exceptionTablePopdownCallback(fakeSrc,[]);
            end


            SP.SPPlotter.plotSelectedStatisticsEvents();
        end


        function stopButtonCallback(SP,~,~)

            mdl=SP.SPData.getData('Model');
            status=get_param(mdl,'simulationstatus');
            if strcmp(status,'stopped')
                return;
            end


            SP.SPToolstrip.disableIcon('StopButton');
            SP.SPToolstrip.changeRunButtonTo('Run');


            SP.SPToolstrip.enableLogPanel();


            if strcmp(status,'paused')

                timerTag=SP.SPData.getData('TimerTag');
                stop(timerfind('Tag',timerTag));
                delete(timerfind('Tag',timerTag));

                set_param(mdl,'simulationcommand','stop');
                SP.ModelConfig.restoreConfig();


                spidataName=SP.ModelConfig.getSimulationOutputVarName();
                spidata=evalin('base',spidataName);
                evalin('base',['clear ',spidataName]);
                simlog=[];
                if spidata.isprop('simlog')
                    simlog=get(spidata,'simlog');
                end
                SP.SPData.setSimlog(simlog);



                SP.SPToolstrip.enableIcon('RunButton');
            else






                if strcmp(status,'running')

                    timerTag=SP.SPData.getData('TimerTag');
                    currentTimer=timerfind('Tag',timerTag);
                    if strcmp(currentTimer.running,'off')
                        start(currentTimer);
                    end
                end


                set_param(mdl,'simulationcommand','stop');
            end


            SP.SPToolstrip.enableIcon('OpenButton');
        end


        function runButtonCallback(SP,src,~)
            import solverprofiler.util.*





            SP.IsNewProfilingSessionFinished=false;
            SP.SPToolstrip.enableIcon('StopButton');

            strRun=utilDAGetString('run');
            strPause=utilDAGetString('pause');
            strContinue=utilDAGetString('continue');

            command=src.Text;



            if strcmp(command,strRun)||strcmp(command,strContinue)
                SP.SPToolstrip.changeRunButtonTo('Pause');
                SP.SPToolstrip.disableIcon('OpenButton');
                SP.SPToolstrip.disableIcon('SaveButton');
                SP.SPToolstrip.disableLogPanel();
            else
                SP.SPToolstrip.changeRunButtonTo('Continue');
            end

            drawnow;

            mdl=SP.SPData.getData('Model');

            if strcmp(command,strRun)

                exception=SP.checkIfProfilingReady(mdl);
                if~isempty(exception)
                    msg=exception.message;
                    id=utilDAGetString('failedToStart');
                    utilPopErrDlg(id,msg,exception.identifier)
                    SP.revertToBeforeSimStart();
                    return;
                end


                SP.ModelConfig.updateModelConfig();
                SP.ModelConfig.configForProfiler();


                SP.SPToolstrip.showBar();
                strPrepareSimulation=utilDAGetString('compiling');
                SP.SPToolstrip.setBarText([strPrepareSimulation,' ']);


                spTimer=timer('Period',1,'ExecutionMode','fixedDelay');
                spTimer.Tag=['SPTimer@',utilGetTimeLabel()];
                SP.SPData.setData('TimerTag',spTimer.Tag);
                spTimer.TimerFcn={@SP.timerCallback};



                stepperObj=Simulink.SimulationStepper(mdl);
                stepperObj.initialize();
                try
                    SP.SPData.setDiscDriContblkList(feval(mdl,'get','discDerivSig'));
                catch
                    SP.SPData.setDiscDriContblkList({});
                end
                stepperObj.continue();


                status=get_param(mdl,'simulationStatus');
                if strcmp(status,'stopped')
                    SP.revertToBeforeSimStart();
                    return;
                end


                start(spTimer);
                SP.SPData.setData('UIStatusAtSim',SP.SPToolstrip.getUIStatusAtSim());

            elseif strcmp(command,strPause)
                set_param(mdl,'simulationcommand','pause');

            elseif strcmp(command,strContinue)



                status=get_param(mdl,'simulationStatus');
                if strcmp(status,'stopped')
                    SP.revertToBeforeSimStart();
                    return;
                end


                spidataName=SP.ModelConfig.getSimulationOutputVarName();
                evalin('base',['clear ',spidataName]);


                if~bdIsLoaded(mdl)
                    load_system(mdl);
                end


                set_param(mdl,'simulationcommand','continue');


                timerTag=SP.SPData.getData('TimerTag');
                currentTimer=timerfind('Tag',timerTag);
                start(currentTimer);
            end
            src.Enabled=true;
        end

        function revertToBeforeSimStart(obj)
            timerTag=obj.SPData.getData('TimerTag');
            if~isempty(timerTag)
                currentTimer=timerfind('Tag',timerTag);
                if~isempty(currentTimer)
                    stop(currentTimer);
                    delete(currentTimer);
                end
            end
            obj.SPToolstrip.changeRunButtonTo('Run');
            obj.SPToolstrip.enableIcon('RunButton');
            obj.SPToolstrip.disableIcon('StopButton');
            obj.SPToolstrip.enableIcon('OpenButton');
            if obj.SPData.isDataReady()
                obj.SPToolstrip.disableIcon('SaveButton');
            end
            obj.SPToolstrip.enableLogPanel();
            obj.ModelConfig.restoreConfig();
            obj.SPToolstrip.setBarText(' ');
            obj.SPToolstrip.hideBar();
        end

        function errmsg=checkIfProfilingReady(SP,mdl)
            import solverprofiler.util.*
            errmsg=[];


            if~bdIsLoaded(mdl)
                id='failedToStart:modelNotLoaded';
                msg=utilDAGetString('modelNotLoaded',mdl);
                errmsg=MException(id,msg);
                return;
            end


            try
                fromTextboxValue=utilInterpretVal(SP.SPToolstrip.getFromTime());
            catch
                id='failedToStart:startTimeInvalid';
                msg=utilDAGetString('startTimeInvalid');
                errmsg=MException(id,msg);
                return;
            end

            try
                toTextboxValue=utilInterpretVal(SP.SPToolstrip.getToTime());
            catch
                id='failedToStart:endTimeInvalid';
                msg=utilDAGetString('endTimeInvalid');
                errmsg=MException(id,msg);
                return;
            end

            if(fromTextboxValue<toTextboxValue)
                SP.ModelConfig.setFromTime(num2str(fromTextboxValue));
                SP.ModelConfig.setToTime(num2str(toTextboxValue));
            else
                id='failedToStart:startExceedEnd';
                msg=utilDAGetString('startExceedEnd');
                errmsg=MException(id,msg);
                return;
            end

            try
                number=utilInterpretVal(SP.SPToolstrip.getBufferValue());
                if number<=0||rem(number,1)~=0
                    id='failedToStart:bufferSizeInvalid';
                    msg=utilDAGetString('bufferSizeInvalid');
                    errmsg=MException(id,msg);
                    return;
                else
                    SP.ModelConfig.setPDLength(num2str(number));
                end
            catch
                id='failedToStart:bufferSizeInvalid';
                msg=utilDAGetString('bufferSizeInvalid');
                errmsg=MException(id,msg);
                return;
            end


            mode=get_param(mdl,'simulationMode');
            if~strcmp(mode,'normal')&&~strcmp(mode,'accelerator')
                id='failedToStart:simulationMode';
                msg=utilDAGetString('modeSupport');
                errmsg=MException(id,msg);
                return;
            end


            status=get_param(mdl,'simulationstatus');
            if~strcmp(status,'stopped')
                id='failedToStart:simHasStarted';
                msg=utilDAGetString('simHasStarted');
                errmsg=MException(id,msg);
                return;
            end
        end

        function timerCallback(SP,~,~)
            import solverprofiler.util.*



            mdl=SP.SPData.getData('Model');
            status=get_param(mdl,'simulationstatus');
            isDataAtWorkspace=false;
            spidataName=SP.ModelConfig.getSimulationOutputVarName();

            if strcmp(status,'stopped')
                SP.ModelConfig.restoreConfig();


                SP.SPToolstrip.enableLogPanel();


                if evalin('base',['exist(''',spidataName,''')'])
                    isDataAtWorkspace=true;

                    timerTag=SP.SPData.getData('TimerTag');
                    stop(timerfind('Tag',timerTag));
                    delete(timerfind('Tag',timerTag));
                end


                SP.SPToolstrip.changeRunButtonTo('Run');

                SP.SPToolstrip.disableIcon('StopButton');

            else

                [percent,percentStr]=utilGetSimTimePercentage(mdl);


                streamedFile=SP.ModelConfig.getXoutFilePath();
                if~isempty(streamedFile)
                    streamedStatesFileInfo=dir(streamedFile);
                    if~isempty(streamedStatesFileInfo)
                        sizeInGb=streamedStatesFileInfo.bytes/1024^3;
                        if(sizeInGb>3&&percent>0)
                            cSizeInGb=sprintf('%0.2f',sizeInGb);
                            expSizeInGb=sprintf('%0.2f',sizeInGb*100/percent);
                            utilPopMsgBox('',utilDAGetString('largeStreamedStates',cSizeInGb,expSizeInGb),'largeStateData');
                        end
                    end
                end

                SP.SPToolstrip.setBarValue(percent);
                strSimulationProgress=utilDAGetString('simulationProgress');
                SP.SPToolstrip.setBarText([strSimulationProgress,' ',percentStr,'%']);


                if strcmp(status,'paused')
                    if evalin('base',['exist(''',spidataName,''')'])
                        isDataAtWorkspace=true;

                        timerTag=SP.SPData.getData('TimerTag');
                        stop(timerfind('Tag',timerTag));
                    end
                end
            end


            if(isDataAtWorkspace)
                spidata=evalin('base',spidataName);
                evalin('base',['clear ',spidataName]);


                dataValid=utilCheckData(spidata,1);

                if(dataValid)
                    SP.processData(spidata);
                    try
                        SP.populateAllDocument();
                    catch
                        msg=utilDAGetString('failedToPopulateData');
                        warning(msg);
                    end


                    SE=SP.SPData.getData('StatesExplorer');
                    if~isempty(SE)&&isvalid(SE)
                        sortedPD=SP.SPData.getData('SortedPD');
                        tout=sortedPD.getData('Tout');
                        xout=sortedPD.getData('Xout');
                        failureInfo=sortedPD.getData('FailureInfo');
                        stats=sortedPD.getData('BlockStateStats');
                        hfig=SP.SPDocument.getStepSizePlotHandle();
                        SE.refresh(tout,xout,failureInfo,stats,hfig.CurrentAxes.XLim,0)
                    end


                    ZE=SP.SPData.getData('ZCExplorer');
                    if~isempty(ZE)&&isvalid(ZE)
                        sortedPD=SP.SPData.getData('SortedPD');
                        tout=sortedPD.getData('Tout');
                        hfig=SP.SPDocument.getStepSizePlotHandle();
                        zcInfo=SP.SPData.getZcInfo();


                        if(zcInfo.hasZCValue())
                            ZE.refresh(zcInfo,hfig.CurrentAxes.XLim,[tout(1),tout(end)]);
                        else
                            ZE.delete;
                        end
                    end
                end


                SP.resetButtonsAfterSim();
                SP.SPToolstrip.enableIcon('RunButton');


                SP.SPToolstrip.hideBar();
                SP.SPToolstrip.setBarText('');



                SP.IsNewProfilingSessionFinished=true;
            end
        end

        function processData(SP,spidata)
            import solverprofiler.util.*

            SP.ModelConfig.parseUserDataToWorkSpace(spidata);


            strProcessingData=utilDAGetString('processingData');
            SP.SPToolstrip.setBarText([strProcessingData,' ']);
            SP.SPData.initializeSortedPD(spidata);
            SP.SPToolstrip.setBarValue(15);
            SP.SPData.fillZeroCrossingInfo(spidata);
            SP.SPData.fillResetInfo(spidata);
            SP.SPToolstrip.setBarValue(25);
            SP.SPData.setStateRange(spidata);
            if SP.ModelConfig.isXoutLogged()
                if SP.ModelConfig.isXoutStreamedIfLogged()
                    SP.SPData.fillStateValue(SP.ModelConfig.getXoutFilePath());
                else
                    SP.SPData.fillStateValue(spidata);
                end
            end
            SP.SPToolstrip.setBarValue(40);
            SP.SPData.fillFailureInfo(spidata);
            SP.SPToolstrip.setBarValue(70);
            SP.SPData.analyzeModelJacobian(spidata)
            SP.SPData.setSimscapeStiff();
            SP.SPToolstrip.setBarValue(90);
            SP.SPData.getOverview();
            SP.SPToolstrip.setBarValue(95);
            SP.SPData.getModelDiagnosticsAndTableIndex(spidata);
            SP.SPToolstrip.setBarValue(100);
        end

        function populateAllDocument(obj)

            obj.SPPlotter.generateCleanFigure();


            obj.SPDocument.resetLastOpenedDoc();


            tableContent=obj.SPData.getStatisticsTableContent();
            obj.SPDocument.populateStatisticsTable(tableContent);


            tableContent=obj.SPData.getZeroCrossingTableContent();
            obj.SPDocument.populateZeroCrossingTable(tableContent);


            type=obj.SPDocument.getExceptionTableRankingType();
            tableContent=obj.SPData.getExceptionTableContent(type);
            obj.SPDocument.populateExceptionTable(tableContent);


            tableContent=obj.SPData.getJacobianTableContent();
            obj.SPDocument.populateJacobianTable(tableContent);


            tableContent=obj.SPData.getSscStiffTableContent();
            obj.SPDocument.populateSscStiffTable(tableContent);


            tableContent=obj.SPData.getResetTableContent();
            obj.SPDocument.populateResetTable(tableContent);


            tableContent=obj.SPData.getInaccurateStateTableContent();
            obj.SPDocument.populateInaccurateStateTable(tableContent);


            OverallDiag=obj.SPData.getData('OverallDiag');
            obj.SPDocument.populateDiagnostics(OverallDiag);


            obj.SPPlotter.updateZCCheckBoxPoints(obj.SPToolstrip.isZCCheckboxSelected());
            obj.SPPlotter.updateFailureCheckBoxPoints(obj.SPToolstrip.isExceptionCheckboxSelected());
            obj.SPPlotter.updateSolverResetCheckBoxPoints(obj.SPToolstrip.isResetCheckboxSelected());
            obj.SPPlotter.updateJacobianCheckBoxPoints(obj.SPToolstrip.isJacobianCheckboxSelected());












            if~isempty(obj.SPDocument.LastOpenedDoc)
                waitfor(obj.SPDocument.LastOpenedDoc,'Opened',true);
            end


            obj.SPDocument.moveFocusToDiagnostics();


            obj.SPDocument.moveFocusToStatisticsTable();
        end


        function resetButtonsAfterSim(SP)

            if~isempty(SP.SPData.getJacobianUpdateTime())
                SP.SPToolstrip.enableIcon('JacobianUpdateCheckbox');
            else
                SP.SPToolstrip.disableIcon('JacobianUpdateCheckbox');
            end

            if SP.SPData.isThereAnyZCEvent()
                SP.SPToolstrip.enableIcon('ZCCheckbox');
            else
                SP.SPToolstrip.disableIcon('ZCCheckbox');
            end

            if SP.SPData.isThereAnyException()
                SP.SPToolstrip.enableIcon('ExceptionCheckbox');
            else
                SP.SPToolstrip.disableIcon('ExceptionCheckbox');
            end

            if SP.SPData.isThereAnyReset()
                SP.SPToolstrip.enableIcon('ResetCheckbox');
            else
                SP.SPToolstrip.disableIcon('ResetCheckbox');
            end


            SP.SPToolstrip.disableHiliteAndTrace();


            mdl=SP.SPData.getData('Model');
            status=get_param(mdl,'simulationstatus');
            if strcmp(status,'stopped')
                SP.SPToolstrip.changeRunButtonTo('Run');
                SP.SPToolstrip.enableIcon('RunButton');
                SP.SPToolstrip.enableIcon('OpenButton');
            elseif strcmp(status,'paused')
                SP.SPToolstrip.changeRunButtonTo('Continue');
                SP.SPToolstrip.enableIcon('RunButton');
            else
                SP.SPToolstrip.disableIcon('OpenButton');
            end

            if SP.SPData.isStateObjectValid()
                SP.SPToolstrip.enableIcon('SEButton');
            else
                SP.SPToolstrip.disableIcon('SEButton');
            end

            if SP.SPData.hasZCValue()
                SP.SPToolstrip.enableIcon('ZEButton');
            else
                SP.SPToolstrip.disableIcon('ZEButton');
            end

            SP.SPToolstrip.updateStatesExplorerButtonTooltip();
            if isempty(SP.SPData.getSimlog())
                SP.SPToolstrip.disableIcon('SSCButton');
            else
                SP.SPToolstrip.enableIcon('SSCButton');
            end

            SP.SPToolstrip.enableIcon('SaveButton');
            SP.SPToolstrip.enableIcon('ExportTabButton');
        end



        function pass=bufferTextboxCallback(SP,~,~)
            import solverprofiler.util.*
            pass=false;

            try
                number=utilInterpretVal(SP.SPToolstrip.getBufferValue());
                if number<=0||rem(number,1)~=0
                    utilPopErrDlg('',utilDAGetString('bufferSizeInvalid'),'bufferSizeInvalid');
                else
                    SP.ModelConfig.setPDLength(num2str(number));
                    pass=true;
                end
            catch
                utilPopErrDlg('',utilDAGetString('bufferSizeInvalid'),'bufferSizeInvalid');
            end
        end


        function pass=fromTextboxCallback(SP,~,~)
            import solverprofiler.util.*
            pass=false;

            try
                toTextboxValue=utilInterpretVal(SP.SPToolstrip.getToTime());
                fromTextboxValue=utilInterpretVal(SP.SPToolstrip.getFromTime());

                if fromTextboxValue>=toTextboxValue
                    utilPopErrDlg('',utilDAGetString('startExceedEnd'),'failedToStart:startExceedEnd');
                else
                    SP.ModelConfig.setFromTime(num2str(fromTextboxValue));
                    pass=true;
                end
            catch
                utilPopErrDlg('',utilDAGetString('startTimeInvalid'),'failedToStart:startTimeInvalid');
            end
        end


        function pass=toTextboxCallback(SP,~,~)
            import solverprofiler.util.*
            pass=false;

            try
                fromTextboxValue=utilInterpretVal(SP.SPToolstrip.getFromTime());
                toTextboxValue=utilInterpretVal(SP.SPToolstrip.getToTime());
                if fromTextboxValue>=toTextboxValue
                    utilPopErrDlg('',utilDAGetString('endBeforeStart'),'failedToStart:endBeforeStart');
                else
                    SP.ModelConfig.setToTime(num2str(toTextboxValue));
                    pass=true;
                end
            catch
                utilPopErrDlg('',utilDAGetString('endTimeInvalid'),'failedToStart:endTimeInvalid');
            end
        end


        function logStateCallback(SP,src,~)
            if src.Value
                SP.ModelConfig.enableStateLogging();
            else
                SP.ModelConfig.disableStateLogging();
            end
        end


        function logZCCallback(SP,src,~)
            if src.Value
                SP.ModelConfig.enableZCLogging();
            else
                SP.ModelConfig.disableZCLogging();
            end
        end


        function logSimscapeStateCallback(SP,src,~)
            if src.Value
                SP.ModelConfig.enableSimscapeStateLogging();
            else
                SP.ModelConfig.disableSimscapeStateLogging();
            end
        end


        function logJacobianCallback(SP,src,~)
            if src.Value
                SP.ModelConfig.enableJacobianLogging();
            else
                SP.ModelConfig.disableJacobianLogging();
            end
        end


        function ruleButtonCallback(SP,~,~)
            SP.SPData.openRuleWindow;
        end

        function sscStiffEditCallback(SP,src,~)
            import solverprofiler.util.*

            try
                if isempty(src.Value)
                    SP.ModelConfig.setSscStiffTimes(src.Value);
                    return;
                end

                times=eval(src.Value);

                [m,n]=size(times);
                if(m>1&&n>1)||~isa(times,'double')
                    id=utilDAGetString('SscStiffInvalidValues');
                    msg=utilDAGetString('SscStiffInvalidTimes');
                    utilPopErrDlg(id,msg,'SscStiffInvalidTimes');

                    if isvalid(src)
                        src.Value=SP.ModelConfig.getSscStiffTimes();
                    end
                    return;
                end

                SP.ModelConfig.setSscStiffTimes(src.Value);
            catch
                id=utilDAGetString('SscStiffInvalidValues');
                msg=utilDAGetString('SscStiffInvalidTimes');
                utilPopErrDlg(id,msg,'SscStiffInvalidTimes');

                if isvalid(src)
                    src.Value=SP.ModelConfig.getSscStiffTimes();
                end
                return;
            end
        end


        function launchZCExplorer(SP,~,~)
            import solverprofiler.internal.ZCExplorerClass;


            ZE=SP.SPData.getData('ZCExplorer');
            if~isempty(ZE)&&isvalid(ZE)
                ZE.moveFocusToZCExplorer();
            else
                mdl=SP.SPData.getData('Model');
                zcInfo=SP.SPData.getZcInfo();
                hfig=SP.SPDocument.getStepSizePlotHandle();
                sortedPD=SP.SPData.getData('SortedPD');
                tout=sortedPD.getData('Tout');
                try






                    ZE=ZCExplorerClass(mdl,zcInfo,hfig.CurrentAxes.XLim,[tout(1),tout(end)]);
                    SP.SPData.setData('ZCExplorer',ZE);
                catch
                end
            end
        end


        function launchStatesExplorer(SP,~,~)
            import solverprofiler.internal.StatesExplorerClass;
            import solverprofiler.util.*

            mdl=SP.SPData.getData('Model');
            if SP.SPData.isDataReady()

                if~SP.SPData.isStateObjectValid()

                    if SP.SPData.isStateStreamed()
                        utilPopMsgBox('',utilDAGetString('xoutFileMissing'),'xoutFileMissing');
                    end
                    SP.SPToolstrip.disableIcon('SEButton');
                    return;
                end

                sortedPD=SP.SPData.getData('SortedPD');
                hfig=SP.SPDocument.getStepSizePlotHandle();


                stateIdx=0;
                fName=SP.SPData.getData('TopTableName');
                if strcmp(fName,utilDAGetString('Solverexception'))
                    stateIdx=SP.SPData.getSelectedStateIdxFromExceptionTable();
                elseif strcmp(fName,utilDAGetString('JacobianAnalysis'))
                    stateIdx=SP.SPData.getSelectedStateIdxFromJacobianTable();
                end


                SE=SP.SPData.getData('StatesExplorer');
                if~isempty(SE)&&isvalid(SE)
                    tout=sortedPD.getData('Tout');
                    xout=sortedPD.getData('Xout');
                    failureInfo=sortedPD.getData('FailureInfo');
                    stats=sortedPD.getData('BlockStateStats');
                    SE.refresh(tout,xout,failureInfo,stats,hfig.CurrentAxes.XLim,stateIdx);
                    SE.moveFocusToStateExplorer();
                else
                    try
                        tout=sortedPD.getData('Tout');
                        xout=sortedPD.getData('Xout');
                        failureInfo=sortedPD.getData('FailureInfo');
                        stats=sortedPD.getData('BlockStateStats');
                        SE=StatesExplorerClass(mdl,tout,xout,failureInfo,...
                        stats,hfig.CurrentAxes.XLim,stateIdx);
                        SP.SPData.setData('StatesExplorer',SE);
                    catch
                    end
                end
            end

        end


        function launchSSCExplorer(SP,~,~)
            import solverprofiler.util.*

            simlog=SP.SPData.getSimlog();
            if isempty(simlog)
                id=utilDAGetString('failedToLaunchSSC');
                msg=utilDAGetString('noSimlogLogged');
                utilPopErrDlg(id,msg,'failedToLaunchSSC');
                return;
            end

            blockName=SP.SPData.getData('HilitePath');
            nodeName=SP.SPData.getSimscapeNodeNameForBlock(blockName);
            if~isempty(nodeName)
                try

                    blockNameAfterUnwrap=SP.SPData.SortedPD.unwrapIfModelRef(blockName);
                    blockHandle=get_param(blockNameAfterUnwrap,'Handle');
                    simscape.logging.sli.internal.explore(simlog,blockHandle,'');
                catch
                    sscexplore(simlog);
                end
            else
                sscexplore(simlog);
            end
        end


        function traceCallback(SP,~,~)
            traceCallbackMdlRefStudioReuse(SP);
        end

        function traceCallbackMdlRefStudioReuse(SP,~,~)








            blockName=SP.SPData.getData('HilitePath');

            bp=[];%#ok

            indices=strfind(blockName,'|');
            if~isempty(indices)

                indices=[0,indices,length(blockName)+1];
                numOfLevels=length(indices)-1;
                blockPathsToTargetBlock=cell(1,numOfLevels);
                for i=1:numOfLevels
                    currentPath=blockName(indices(i)+1:indices(i+1)-1);
                    blockPathsToTargetBlock{i}=currentPath;
                end
                blockName=blockName(indices(end-1)+1:end);
                bp=Simulink.BlockPath(blockPathsToTargetBlock);
            else
                bp=Simulink.BlockPath(blockName);
            end

            blockHandle=get_param(blockName,'Handle');

            if~isempty(blockName)
                SP.removeTraceCallback([],[]);
            else
                return;
            end

            if~isempty(blockHandle)
                Simulink.Structure.HiliteTool.AppManager.HighlightFromBlock(bp);

                SP.SPData.setData('HiliteTraceBlock',SP.SPData.getData('HilitePath'));
            end
            SP.SPToolstrip.enableIcon('RemoveButton');
        end


        function removeTraceCallback(SP,~,~)

            blockName=SP.SPData.getData('HiliteTraceBlock');
            if isempty(blockName),return;end


            indices=strfind(blockName,'|');
            if~isempty(indices)
                indices=[0,indices,length(blockName)+1];
                for i=1:length(indices)-1
                    currentPath=blockName(indices(i)+1:indices(i+1)-1);
                    nindices=strfind(currentPath,'/');
                    load_system(currentPath(1:nindices(1)-1));
                    set_param(currentPath(1:nindices(1)-1),'HiliteAncestors','off');
                    bdHandle=get_param(currentPath(1:nindices(1)-1),'Handle');
                    Simulink.Structure.HiliteTool.AppManager.removeAdvancedHighlighting(bdHandle);
                end
            end

            set_param(SP.SPData.getData('Model'),'HiliteAncestors','off');
            bdHandle=get_param(SP.SPData.getData('Model'),'Handle');
            Simulink.Structure.HiliteTool.AppManager.removeAdvancedHighlighting(bdHandle);


            SP.SPData.setData('HiliteTraceBlock',[]);
            SP.SPToolstrip.disableIcon('RemoveButton');
        end


        function gotoFileCallback(SP,~,~)
            fileInfo=SP.SPData.getData('FileInfo');
            fileName=fileInfo{1};
            fileRow=fileInfo{2};
            opentoline(fileName,fileRow);
        end


        function highlightCallback(SP,~,~)

            hilitePath=SP.SPData.getData('HilitePath');
            if isempty(hilitePath)
                return;
            end


            SP.removeTraceCallback([],[]);

            SP.SPData.setData('HiliteTraceBlock',hilitePath);


            w=warning('query','Simulink:blocks:HideContents');
            oldWarnState=w.state;
            warning('off','Simulink:blocks:HideContents');


            indices=strfind(hilitePath,'|');
            if isempty(indices)



                try
                    hilite_system(hilitePath,'find');
                catch
                    warning(oldWarnState,'Simulink:blocks:HideContents');
                    return;
                end
            else
                try
                    indices=[0,indices,length(hilitePath)+1];
                    for i=1:length(indices)-1
                        currentPath=hilitePath(indices(i)+1:indices(i+1)-1);

                        nindices=strfind(currentPath,'/');
                        load_system(currentPath(1:nindices(1)-1));
                        hilite_system(hilitePath(indices(i)+1:indices(i+1)-1),'find')
                    end
                catch
                    try
                        hilite_system(hilitePath(1:indices(2)-1),'find');
                    catch
                        warning(oldWarnState,'Simulink:blocks:HideContents');
                        return;
                    end
                end
            end

            warning(oldWarnState,'Simulink:blocks:HideContents');
            SP.SPToolstrip.enableIcon('RemoveButton');
        end


        function exportTabCallback(SP,~,~)
            import solverprofiler.util.*
            if SP.SPData.isStepSizeTabSelected()
                fig=SP.SPDocument.getStepSizePlotHandle;
                fnew=figure;
                copyobj(allchild(fig),fnew);
                title(utilDAGetString('Stepsize'));
            else

                strExportTable=utilDAGetString('exportTable');
                [filename,pathname]=uiputfile('*.csv',strExportTable,'Untitled.csv');
                if filename==0
                    return;
                end


                fObj=SP.SPDocument.getFigureHandle(SP.SPData.getData('TabSelected'));
                hObj=findobj(fObj,'RowName','');
                utilCreateCSVForTable(hObj.ColumnName,hObj.Data,pathname,filename);
            end
        end

        function adjustTraceHiliteSSCButtons(SP,hilitePath)
            import solverprofiler.util.*


            if~isempty(hilitePath)
                SP.SPToolstrip.enableIcon('HiliteButton');
            else
                SP.SPToolstrip.disableIcon('HiliteButton');
            end

            hilitePath=utilUnwrapBlockNameIfInModelRef(hilitePath);
            if utilIsBlockValidForTrace(hilitePath)
                SP.SPToolstrip.enableTraceIcons();
            else
                SP.SPToolstrip.disableTraceIcons();
            end


            nodeName=SP.SPData.getSimscapeNodeNameForBlock(hilitePath);
            if isempty(nodeName)||isempty(SP.SPData.getSimlog())
                SP.SPToolstrip.disableIcon('SSCButton');
            else
                SP.SPToolstrip.enableIcon('SSCButton');
            end
        end

    end

    methods(Access=private)

        function createSolverProfilerToolgroup(obj,mdl)

            import solverprofiler.util.*
            import matlab.ui.internal.*


            [~,randomName,~]=fileparts(tempname);
            appOptions.Tag=randomName;
            appOptions.Title=[utilDAGetString('Profiler'),': ',mdl,'@',utilGetTimeLabel()];
            obj.AppContainer=matlab.ui.container.internal.AppContainer(appOptions);




            arch=computer('arch');
            if strcmp(arch,'win32')||strcmp(arch,'win64')
                filename=fullfile(matlabroot,'toolbox','simulink',...
                'sl_solver_profiler','+solverprofiler','icons',...
                'spicon_solver_profiler_16.ico');
            else
                filename=fullfile(matlabroot,'toolbox','simulink',...
                'sl_solver_profiler','+solverprofiler','icons',...
                'spicon_solver_profiler_16.png');
            end





            obj.AppContainer.Icon=filename;


            obj.AppContainer.WindowBounds=[100,100,1340,840];


            spHelpBtn=matlab.ui.internal.toolstrip.qab.QABHelpButton();
            spHelpBtn.ButtonPushedFcn=@(~,~)SolverProfilerHelpCSH(obj);
            obj.AppContainer.add(spHelpBtn)

        end

        function createSolverProfilerToolstrip(obj,mdl)

            import solverprofiler.internal.SolverProfilerToolstripClass;

            validateattributes(obj.AppContainer,{'matlab.ui.container.internal.AppContainer'},{'nonempty'});
            obj.SPToolstrip=SolverProfilerToolstripClass(obj.AppContainer,mdl);




            obj.SPToolstrip.attachCallback('OpenButton','ButtonPushed',@obj.openButtonCallback);
            obj.SPToolstrip.attachCallback('OpenButtonPopup_data','ItemPushed',@obj.openLoadDataCallback);
            obj.SPToolstrip.attachCallback('OpenButtonPopup_rule','ItemPushed',@obj.openLoadRuleCallback);


            obj.SPToolstrip.attachCallback('SaveButton','ButtonPushed',@obj.saveButtonCallback);
            obj.SPToolstrip.attachCallback('SaveButtonPopup_data','ItemPushed',@obj.saveDataCallback);
            obj.SPToolstrip.attachCallback('SaveButtonPopup_rule','ItemPushed',@obj.saveRuleCallback);


            obj.SPToolstrip.attachCallback('BufferTextbox','ValueChanged',@obj.bufferTextboxCallback);
            obj.SPToolstrip.attachCallback('FromTextbox','ValueChanged',@obj.fromTextboxCallback);
            obj.SPToolstrip.attachCallback('ToTextbox','ValueChanged',@obj.toTextboxCallback);


            obj.SPToolstrip.attachCallback('StateCheckbox','ValueChanged',@obj.logStateCallback);
            obj.SPToolstrip.attachCallback('LogZCCheckbox','ValueChanged',@obj.logZCCallback);
            obj.SPToolstrip.attachCallback('SimlogCheckbox','ValueChanged',@obj.logSimscapeStateCallback);
            obj.SPToolstrip.attachCallback('JacobianCheckbox','ValueChanged',@obj.logJacobianCallback);
            obj.SPToolstrip.attachCallback('SscStiffEdit','ValueChanged',@obj.sscStiffEditCallback);


            obj.SPToolstrip.attachCallback('RuleButton','ButtonPushed',@obj.ruleButtonCallback);
            obj.SPToolstrip.attachCallback('RunButton','ButtonPushed',@obj.runButtonCallback);
            obj.SPToolstrip.attachCallback('StopButton','ButtonPushed',@obj.stopButtonCallback);
            obj.SPToolstrip.attachCallback('ZoomInButton','ValueChanged',@obj.zoomInCallback);
            obj.SPToolstrip.attachCallback('ZoomOutButton','ValueChanged',@obj.zoomOutCallback);
            obj.SPToolstrip.attachCallback('PanButton','ValueChanged',@obj.panCallback);


            obj.SPToolstrip.attachCallback('ZCCheckbox','ValueChanged',@obj.zcCheckboxCallback);
            obj.SPToolstrip.attachCallback('ExceptionCheckbox','ValueChanged',@obj.failureCheckboxCallback);
            obj.SPToolstrip.attachCallback('ResetCheckbox','ValueChanged',@obj.resetCheckboxCallback);
            obj.SPToolstrip.attachCallback('JacobianUpdateCheckbox','ValueChanged',@obj.jacobianCheckboxCallback);


            obj.SPToolstrip.attachCallback('HiliteButton','ButtonPushed',@obj.highlightCallback);
            obj.SPToolstrip.attachCallback('RemoveButton','ItemPushed',@obj.removeTraceCallback);
            obj.SPToolstrip.attachCallback('TraceSrcButton','ItemPushed',@obj.traceCallback);
            obj.SPToolstrip.attachCallback('SrcFileButton','ItemPushed',@obj.gotoFileCallback);
            obj.SPToolstrip.attachCallback('ExportTabButton','ButtonPushed',@obj.exportTabCallback);
            obj.SPToolstrip.attachCallback('SSCButton','ItemPushed',@obj.launchSSCExplorer);
            obj.SPToolstrip.attachCallback('SEButton','ItemPushed',@obj.launchStatesExplorer);
            obj.SPToolstrip.attachCallback('ZEButton','ItemPushed',@obj.launchZCExplorer);
        end

        function createSolverProfilerDocumentViews(obj,mdl)

            import solverprofiler.internal.SolverProfilerDocumentClass


            validateattributes(obj.AppContainer,{'matlab.ui.container.internal.AppContainer'},{'nonempty'});
            validateattributes(obj.SPToolstrip,{'solverprofiler.internal.SolverProfilerToolstripClass'},{'nonempty'});


            obj.SPDocument=SolverProfilerDocumentClass(obj.AppContainer);


            obj.SPDocument.attachStatisticsTableSelectCallback(@obj.statisticsTableSelectCallback);
            obj.SPDocument.attachTableSelectCallback(@obj.tableSelectCallback);


            obj.SPDocument.attachFigureZoomPanPostCallback(@obj.figureZoomPanPostCallback);


            addlistener(obj.AppContainer,'PropertyChanged',@obj.tabSelectCallback);


            mcosObj=get_param(mdl,'slObject');
            addlistener(mcosObj,'CloseEvent',@obj.modelCloseCallback);
        end
    end

    methods

        function SolverProfilerHelpCSH(obj)
            helpview(fullfile(docroot,"simulink","helptargets.map"),...
            "help_button_solver_profiler");
        end
    end
end