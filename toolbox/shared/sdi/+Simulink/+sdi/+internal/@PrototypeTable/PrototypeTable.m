

classdef PrototypeTable


    methods(Static,Hidden)


        function initializeTableSubscriber()

            Simulink.HMI.uninitializeSubscriber('/prototypeTable/store');

            Simulink.HMI.initializeSubscriber(...
            '/prototypeTable/store',...
            'table_message_handler',false);





            Simulink.sdi.initTableRequests();
        end


        function eventListeners=initializeEventListeners

            eventListeners=cell(11,1);
            eng=Simulink.sdi.Instance.engine;
            eventListeners{1}=addlistener(eng,...
            'updateFlag','PostSet',...
            @Simulink.sdi.internal.PrototypeTable.cb_HandleEngineEvents);
            eventListeners{2}=...
            event.listener(eng,'signalDeleteEvent',...
            @Simulink.sdi.internal.PrototypeTable.cb_HandleEngineEvents);
            eventListeners{3}=...
            event.listener(eng,'runDeleteEvent',...
            @Simulink.sdi.internal.PrototypeTable.cb_HandleEngineEvents);
            eventListeners{4}=...
            event.listener(eng,'signalsInsertedEvent',...
            @Simulink.sdi.internal.PrototypeTable.cb_HandleEngineEvents);
            eventListeners{5}=...
            event.listener(eng,'compareRunsEvent',...
            @Simulink.sdi.internal.PrototypeTable.cb_HandleEngineEvents);
            eventListeners{6}=...
            event.listener(eng,'treeSignalPropertyEvent',...
            @Simulink.sdi.internal.PrototypeTable.cb_HandleEngineEvents);
            eventListeners{7}=...
            event.listener(eng,'treeRunPropertyEvent',...
            @Simulink.sdi.internal.PrototypeTable.cb_HandleEngineEvents);
            eventListeners{8}=...
            event.listener(eng,'clearSDIEvent',...
            @Simulink.sdi.internal.PrototypeTable.cb_HandleEngineEvents);
            eventListeners{9}=...
            event.listener(eng,'recompareSignalsEvent',...
            @Simulink.sdi.internal.PrototypeTable.cb_HandleEngineEvents);
            eventListeners{10}=...
            event.listener(eng,'runsAndSignalsDeleteEvent',...
            @Simulink.sdi.internal.PrototypeTable.cb_HandleEngineEvents);
            eventListeners{11}=...
            event.listener(eng,'loadSaveEvent',...
            @Simulink.sdi.internal.PrototypeTable.cb_HandleEngineEvents);

            Simulink.sdi.internal.PrototypeTable.initializeTableSubscriber();
            Simulink.HMI.initializeSubscriber(...
            '/sdi/tableApplication',...
            'sdi_app_message_handler',false);
            Simulink.HMI.initializeSubscriber(...
            '/sdi/comparisonTableApplication',...
            'sdi_comparisons_app_message_handler',false);
            Simulink.HMI.initializeSubscriber(...
            '/sdi/propertiesTableApplication',...
            'sdi_properties_app_message_handler',false);
            Simulink.HMI.initializeSubscriber(...
            '/sdi/comparisonPropertiesTableApplication',...
            'sdi_comparisons_properties_app_message_handler',false);
            Simulink.HMI.initializeSubscriber(...
            '/sdi/importTableApplication',...
            'import_table_app_message_handler',false);
        end


        function UpdateTestersFromCPP(action,varargin)
            import Simulink.sdi.internal.PrototypeTable;
            if strcmp(action,'insert')
                evt.EventName='insertFromCPP';
                evt.dbID=varargin{1};
                Simulink.sdi.internal.PrototypeTable.cb_HandleEngineEvents([],evt);
            end
        end


        function cb_HandleEngineEvents(~,evt)
            import Simulink.sdi.internal.PrototypeTable;
            persistent testerObjects
            mlock;

            interface=Simulink.sdi.internal.Framework.getFramework();
            eng=Simulink.sdi.Instance.engine;
            switch evt.EventName
            case 'PostSet'
                if~isinteger(eng.updateFlag)&&length(eng.newRunIDs)==1
                    eng.safeTransaction(...
                    @(obj,runID)Simulink.sdi.insertRowInTable...
                    (obj,runID),eng.sigRepository,...
                    eng.newRunIDs(1));
                    testerObjects=PrototypeTable.updateTesters(testerObjects,'insert',eng.newRunIDs(1));
                end
            case 'insertFromCPP'

                testerObjects=PrototypeTable.updateTesters(testerObjects,'insert',evt.dbID);
            case 'signalDeleteEvent'
                eng.safeTransaction(...
                @(obj,dbID,app)Simulink.sdi.removeRowFromTable(...
                obj,dbID,0,app),eng.sigRepository,...
                evt.signalID,evt.app);
                testerObjects=PrototypeTable.updateTesters(testerObjects,'remove',[evt.signalID]);
                clearNewDataNotification(interface);
            case 'runDeleteEvent'
                eng.safeTransaction(...
                @(obj,dbID,app)Simulink.sdi.removeRowFromTable(...
                obj,0,dbID,app),eng.sigRepository,evt.runID,...
                evt.app);
                testerObjects=PrototypeTable.updateTesters(testerObjects,'remove',[evt.runID]);
                clearNewDataNotification(interface);
            case 'signalsInsertedEvent'
                eng.safeTransaction(...
                @(x,y,z)Simulink.sdi.insertSignalsInRun(x,y,z),...
                eng.sigRepository,evt.runID,evt.useProgressTracker);
                testerObjects=PrototypeTable.updateTesters(testerObjects,'insertChildren',evt.runID);
            case 'compareRunsEvent'
                eng.safeTransaction(...
                @(obj,runID,signalID,prevRunID,run1ID,run2ID,comparisonSigID)...
                Simulink.sdi.overwriteComparisonRun...
                (obj,runID,signalID,prevRunID,run1ID,run2ID,comparisonSigID),...
                eng.sigRepository,...
                evt.runID{3},...
                evt.signalID,...
                evt.oldRunID,...
                evt.runID{1},...
                evt.runID{2},...
                evt.comparisonSigID);
            case 'treeSignalPropertyEvent'
                try
                    appEnum=...
                    Simulink.sdi.internal.PrototypeTable.getApp(evt.signalID);
                    Simulink.sdi.updateRowInTable(eng.sigRepository,evt.signalID,appEnum,evt.enumstr);
                catch me
                    if~strcmpi(me.identifier,...
                        'simulation_data_repository:sdr:NoSuchRun')
                        throw me;
                    end
                end
                testerObjects=PrototypeTable.updateTesters(testerObjects,'update');
            case 'treeRunPropertyEvent'
                appEnum=...
                Simulink.sdi.internal.PrototypeTable.getApp(evt.runID);
                Simulink.sdi.updateRowInTable(eng.sigRepository,evt.runID,appEnum,evt.enumstr);
                testerObjects=PrototypeTable.updateTesters(testerObjects,'update');
            case 'clearSDIEvent'
                if isempty(evt.app)
                    Simulink.sdi.clearSDIEvent();
                else
                    Simulink.sdi.clearSDIEvent(evt.app);
                end
                testerObjects=PrototypeTable.updateTesters(testerObjects,'destroy');
                clearNewDataNotification(interface);
            case 'recompareSignalsEvent'
                eng.safeTransaction(...
                @(obj,comparisonSigID,oldDiffSigID,oldTolSigID,oldTolLowerSigID,...
                oldTolUpperSigID,oldDiffTolLowerSigID,oldDiffTolUpperSigID,...
                oldCompMinusBaseSigID,oldPassSigID,oldFailureRegionSigID)...
                Simulink.sdi.recompareSignalEvent...
                (obj,comparisonSigID,oldDiffSigID,oldTolSigID,oldTolLowerSigID,...
                oldTolUpperSigID,oldDiffTolLowerSigID,oldDiffTolUpperSigID,...
                oldCompMinusBaseSigID,oldPassSigID,oldFailureRegionSigID),...
                eng.sigRepository,...
                evt.comparisonSigID,evt.oldDiffSigID,evt.oldTolSigID,evt.oldTolLowerSigID,...
                evt.oldTolUpperSigID,evt.oldDiffTolLowerSigID,evt.oldDiffTolUpperSigID,...
                evt.oldCompMinusBaseSigID,evt.oldPassSigID,evt.oldFailureRegionSigID);
            case 'runsAndSignalsDeleteEvent'
                deletedSignalsIDs=[evt.signalsIDInfo(:).signalID];
                if isempty(deletedSignalsIDs)
                    deletedSignalsIDs=int32.empty(0,1);
                end
                eng.safeTransaction(...
                @(obj,sigIDs,runIDs,appStr)Simulink.sdi.removeRowsFromTable...
                (obj,sigIDs,runIDs,appStr),eng.sigRepository,deletedSignalsIDs,...
                evt.deletedRunIDs,evt.appStr);
                testerObjects=PrototypeTable.updateTesters(testerObjects,'remove',evt.dbIDs);
                clearNewDataNotification(interface);
            case 'loadSaveEvent'
                try
                    replot=evt.replot;
                    appName=evt.app;
                catch me %#ok<NASGU>
                    replot=true;
                    appName='sdi';
                end
                bSDIActive=Simulink.sdi.Instance.isSDIRunning();
                Simulink.sdi.internalLoadSDIEvent(replot,bSDIActive,appName);
            end
        end


        function testers=updateTesters(testers,action,varargin)
            idxToRemove=[];
            for idx=1:length(testers)
                if isvalid(testers(idx))
                    if isempty(varargin)
                        testers(idx).invalidateView(action);
                    elseif length(varargin)>1
                        testers(idx).invalidateView(action,varargin{1},varargin{2});
                    else
                        testers(idx).invalidateView(action,varargin{1});
                    end
                else
                    idxToRemove(end+1)=idx;%#ok<AGROW>
                end
            end

            if~isempty(idxToRemove)
                testers(idxToRemove)=[];
            end
        end


        function uninitializeEventListeners(eventListeners)
            for idx=1:length(eventListeners)
                delete(eventListeners{idx});
            end
            Simulink.HMI.uninitializeSubscriber('/prototypeTable/store');
            Simulink.HMI.uninitializeSubscriber('/sdi/tableApplication');
            Simulink.HMI.uninitializeSubscriber('/sdi/comparisonTableApplication');
            Simulink.HMI.uninitializeSubscriber('/sdi/propertiesTableApplication');
            Simulink.HMI.uninitializeSubscriber('/sdi/comparisonPropertiesTableApplication');
            Simulink.HMI.uninitializeSubscriber('/sdi/importTableApplication');
        end

        function appEnum=getApp(dbID)
            eng=Simulink.sdi.Instance.engine;
            if eng.isValidSignalID(dbID)
                runID=eng.getSignalRunID(dbID);
            else
                runID=dbID;
            end
            appEnum=eng.sigRepository.getRunApp(runID);
        end

        function setRunName(dbID,name,varargin)
            eng=Simulink.sdi.Instance.engine;
            if eng.isValidRunID(dbID)
                eng.setRunName(dbID,name);
            end
        end

        function setRunStatus(dbID,status,varargin)
            r=Simulink.sdi.getRun(dbID);
            r.Status=status;
        end

        function setSignalName(dbID,name)
            eng=Simulink.sdi.Instance.engine;
            if eng.isValidSignalID(dbID)
                eng.setSignalLabel(dbID,name);
            end
        end

        function setRunTag(dbID,runTag,varargin)
            eng=Simulink.sdi.Instance.engine;
            if eng.isValidRunID(dbID)
                eng.setRunTag(dbID,runTag);
            end
        end

        function setRunDescription(dbID,runDescription,varargin)
            eng=Simulink.sdi.Instance.engine;
            if eng.isValidRunID(dbID)
                eng.setRunDescription(dbID,runDescription);
            end
        end

        function setSignalLineColor(dbID,color,varargin)
            import Simulink.sdi.internal.LineSettings;
            colorDoubleArray=LineSettings.hexStringToColor(color);
            if~isempty(colorDoubleArray)
                Simulink.sdi.Instance.engine.setSignalLineColor(...
                dbID,colorDoubleArray);
            end
        end

        function setSignalLineStyle(dbID,linestyle,varargin)
            Simulink.sdi.Instance.engine.setSignalLineDashed(...
            dbID,linestyle);
        end

        function setSignalLineWidth(dbID,linewidth,varargin)
            Simulink.sdi.Instance.engine.setSignalLineWidth(...
            dbID,linewidth);
        end

        function setSignalInterpMethod(dbID,interpMethod,varargin)
            if strcmpi(interpMethod,message('SDI:sdi:NoneEventBased').getString)
                interpMethod='none';
            end
            Simulink.sdi.Instance.engine.setSignalInterpMethod(...
            dbID,interpMethod);
        end

        function setSignalDataType(dbID,dataType,varargin)
            sig=Simulink.sdi.getSignal(dbID);
            try
                sig.convertDataType(dataType,true);

                Simulink.sdi.redrawSignalAfterRescale(dbID);
            catch me
                if strcmp(me.identifier,'simulation_data_repository:sdr:ChangeSignalTypeInvalid')
                    titleStr=getString(message('SDI:sdi:DataTypeConvertErrorTitle'));
                    msgStr=me.message;
                    okStr=getString(message('SDI:sdi:OKShortcut'));

                    Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                    'default',...
                    titleStr,...
                    msgStr,...
                    {okStr},...
                    1,...
                    -1,...
                    @(x)Simulink.sdi.internal.PrototypeTable.setSignalDataTypeMsgResponse(dbID,dataType,x,[],'SDR:sdr:ChangeSignalTypeInvalid'),...
                    varargin{:});
                elseif strcmp(me.identifier,'SDI:sdi:DataTypeConvertWhileStreaming')
                    titleStr=getString(message('SDI:sdi:DataTypeConvertErrorTitle'));
                    msgStr=me.message;
                    okStr=getString(message('SDI:sdi:OKShortcut'));

                    Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                    'default',...
                    titleStr,...
                    msgStr,...
                    {okStr},...
                    1,...
                    -1,...
                    @(x)Simulink.sdi.internal.PrototypeTable.setSignalDataTypeMsgResponse(dbID,dataType,x,[],'SDI:sdi:DataTypeConvertWhileStreaming'),...
                    varargin{:});
                elseif strcmp(me.identifier,'SDI:sdi:DataTypeConvertNoFixedPointLicense')
                    titleStr=getString(message('SDI:sdi:DataTypeConvertErrorTitle'));
                    msgStr=me.message;
                    okStr=getString(message('SDI:sdi:OKShortcut'));

                    Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                    'default',...
                    titleStr,...
                    msgStr,...
                    {okStr},...
                    1,...
                    -1,...
                    @(x)Simulink.sdi.internal.PrototypeTable.setSignalDataTypeMsgResponse(dbID,dataType,x,[],'SDI:sdi:DataTypeConvertNoFixedPointLicense'),...
                    varargin{:});
                elseif strcmp(me.identifier,'SDI:sdi:DataTypeDownConversionError')
                    titleStr=getString(message('SDI:sdi:DataTypeDownConversionTitle'));
                    msgStr=getString(message('SDI:sdi:DataTypeDownConversionDesc',me.message,dataType));
                    okStr=getString(message('SDI:sdi:ContinueDataTypeShortcut'));
                    cancelStr=getString(message('SDI:sdi:CancelShortcut'));

                    Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                    'default',...
                    titleStr,...
                    msgStr,...
                    {okStr,cancelStr},...
                    1,...
                    -1,...
                    @(x)Simulink.sdi.internal.PrototypeTable.setSignalDataTypeMsgResponse(dbID,dataType,x,[],'SDI:sdi:DataTypeDownConversionError'),...
                    varargin{:});
                else
                    titleStr=getString(message('SDI:sdi:DataTypeConvertErrorTitle'));
                    msgStr=me.message;
                    okStr=getString(message('SDI:sdi:OKShortcut'));

                    Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                    'default',...
                    titleStr,...
                    msgStr,...
                    {okStr},...
                    1,...
                    -1,...
                    @(x)Simulink.sdi.internal.PrototypeTable.setSignalDataTypeMsgResponse(dbID,dataType,x,[],'SDR:sdr:ChangeSignalTypeInvalid'),...
                    varargin{:});
                end
            end
        end

        function setSignalDataTypeMsgResponse(dbID,dataType,choice,recompareOpts,errorMsg)
            eng=Simulink.sdi.Instance.engine;
            if choice==0
                if strcmp(errorMsg,'SDI:sdi:DataTypeDownConversionError')

                    eng.setSignalDataType(dbID,dataType);
                    if~isempty(recompareOpts)
                        appEnum=Simulink.sdi.internal.PrototypeTable.getApp(recompareOpts.signalID);
                        Simulink.sdi.updateRowInTable(eng.sigRepository,recompareOpts.signalID,appEnum,'dataType');
                        Simulink.sdi.recompareSignalsWithTolerance(...
                        eng.sigRepository,recompareOpts.comparisonParentID,recompareOpts.globalTol);
                    end
                else

                    signalDbID=dbID;
                    if~isempty(recompareOpts)
                        signalDbID=recompareOpts.signalID;
                    end
                    appEnum=Simulink.sdi.internal.PrototypeTable.getApp(signalDbID);
                    Simulink.sdi.updateRowInTable(eng.sigRepository,signalDbID,appEnum,'dataType');
                    message.publish('/sdi2/hideProgressSpinner','hideProgressSpinner');
                end
            elseif choice==1
                signalDbID=dbID;
                if~isempty(recompareOpts)
                    signalDbID=recompareOpts.signalID;
                end
                appEnum=Simulink.sdi.internal.PrototypeTable.getApp(signalDbID);
                Simulink.sdi.updateRowInTable(eng.sigRepository,signalDbID,appEnum,'dataType');
                message.publish('/sdi2/hideProgressSpinner','hideProgressSpinner');
            end
        end

        function setSignalComplexFormat(dbID,fmt,varargin)
            sig=Simulink.sdi.getSignal(dbID);
            try
                sig.ComplexFormat=fmt;
            catch me
                msgStr=me.message;
                titleStr=getString(message('SDI:sdi:InvalidValue'));
                okStr=getString(message('SDI:sdi:OKShortcut'));

                Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                'default',...
                titleStr,...
                msgStr,...
                {okStr},...
                0,...
                -1,...
                [],...
                varargin{:});

                eng=Simulink.sdi.Instance.engine;
                appEnum=Simulink.sdi.internal.PrototypeTable.getApp(dbID);
                Simulink.sdi.updateRowInTable(eng.sigRepository,dbID,appEnum,'complexFormat');
            end
        end

        function setSignalSyncMethod(dbID,syncMethod,varargin)
            Simulink.sdi.Instance.engine.setSignalSyncMethod(...
            dbID,syncMethod);
        end

        function setSignalOverrideGlobalTol(dbID,overrideGlobalTol,varargin)
            try
                Simulink.sdi.Instance.engine.setSignalOverrideGlobalTol(...
                dbID,overrideGlobalTol);
            catch me
                msgStr=me.message;
                titleStr=getString(message('SDI:sdi:InvalidValue'));
                okStr=getString(message('SDI:sdi:OKShortcut'));

                Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                'default',...
                titleStr,...
                msgStr,...
                {okStr},...
                0,...
                -1,...
                [],...
                varargin{:});
            end
        end

        function setSignalAbsTol(dbID,absTol,varargin)
            try
                Simulink.sdi.Instance.engine.setSignalAbsTol(...
                dbID,absTol);


                Simulink.sdi.internal.PrototypeTable.setSignalOverrideGlobalTol(dbID,true);
            catch me
                msgStr=me.message;
                titleStr=getString(message('SDI:sdi:InvalidValue'));
                okStr=getString(message('SDI:sdi:OKShortcut'));

                Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                'default',...
                titleStr,...
                msgStr,...
                {okStr},...
                0,...
                -1,...
                [],...
                varargin{:});
            end
        end

        function setSignalRelTol(dbID,relTol,varargin)
            try
                Simulink.sdi.Instance.engine.setSignalRelTol(...
                dbID,relTol);


                Simulink.sdi.internal.PrototypeTable.setSignalOverrideGlobalTol(dbID,true);
            catch me
                msgStr=me.message;
                titleStr=getString(message('SDI:sdi:InvalidValue'));
                okStr=getString(message('SDI:sdi:OKShortcut'));

                Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                'default',...
                titleStr,...
                msgStr,...
                {okStr},...
                0,...
                -1,...
                [],...
                varargin{:});
            end
        end

        function setSignalLaggingTol(dbID,laggingTol)
            try



                eng=Simulink.sdi.Instance.engine;
                eng.setSignalBackwardTimeTol(dbID,laggingTol);


                Simulink.sdi.internal.PrototypeTable.setSignalOverrideGlobalTol(dbID,true);
            catch me
                msgStr=me.message;
                titleStr=getString(message('SDI:sdi:InvalidValue'));
                okStr=getString(message('SDI:sdi:OKShortcut'));

                Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                'default',...
                titleStr,...
                msgStr,...
                {okStr},...
                0,...
                -1,...
                []);
            end
        end

        function setSignalLeadingTol(dbID,leadingTol)
            try



                eng=Simulink.sdi.Instance.engine;
                eng.setSignalForwardTimeTol(dbID,leadingTol);


                Simulink.sdi.internal.PrototypeTable.setSignalOverrideGlobalTol(dbID,true);
            catch me
                msgStr=me.message;
                titleStr=getString(message('SDI:sdi:InvalidValue'));
                okStr=getString(message('SDI:sdi:OKShortcut'));

                Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                'default',...
                titleStr,...
                msgStr,...
                {okStr},...
                0,...
                -1,...
                []);
            end
        end

        function setSignalTimeTol(dbID,timeTol,varargin)
            try
                eng=Simulink.sdi.Instance.engine;
                eng.setSignalTimeTol(dbID,timeTol);


                Simulink.sdi.internal.PrototypeTable.setSignalOverrideGlobalTol(dbID,true);
            catch me
                msgStr=me.message;
                titleStr=getString(message('SDI:sdi:InvalidValue'));
                okStr=getString(message('SDI:sdi:OKShortcut'));

                Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                'default',...
                titleStr,...
                msgStr,...
                {okStr},...
                0,...
                -1,...
                [],...
                varargin{:});
            end
        end

        function triggerSetSignalCheckedPlots(dbID)
            eng=Simulink.sdi.Instance.engine;
            plotIndices=eng.getSignalCheckedPlots(dbID);
            Simulink.sdi.Instance.engine.setSignalCheckedPlots(...
            dbID,plotIndices);
        end

        function highlightSignalInModel(dbID,clientID)
            [~,ret]=Simulink.sdi.Instance.engine.showSourceBlockInModel(dbID);
            if~ret
                titleStr=message('SDI:sdi:HighlightErrorTitle').getString;
                msgStr=message('SDI:sdi:HighlightErrorMsg').getString;
                okStr=message('SDI:sdi:OKShortcut').getString;

                Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                'default',...
                titleStr,...
                msgStr,...
                {okStr},...
                0,...
                -1,...
                [],...
                'clientID',clientID);
            end
        end

        function triggerRunComparison(runIDs,...
            alignmentOptions,...
            globalAbsTol,globalRelTol,globalLaggingTol,globalLeadingTol)
            try
                Simulink.sdi.compareRuns(...
                runIDs(1),runIDs(2),...
                Simulink.sdi.AlignType(alignmentOptions),true,...
                'abstol',globalAbsTol,'reltol',globalRelTol,'timetol',globalLaggingTol);
            catch me
                msgStr=me.message;
                titleStr=getString(message('SDI:sdi:CompareRunsError'));
                okStr=getString(message('SDI:sdi:OKShortcut'));

                Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                'default',...
                titleStr,...
                msgStr,...
                {okStr},...
                0,...
                -1,...
                []);
            end
        end

        function triggerSignalsComparison(signalIDs,...
            globalAbsTol,globalRelTol,globalLaggingTol,globalLeadingTol)
            try
                globalTol=struct('absolute',globalAbsTol,'relative',globalRelTol,...
                'lagging',globalLaggingTol,'leading',globalLeadingTol);



                eng=Simulink.sdi.Instance.engine;
                runID=Simulink.sdi.internal.compareSignalsAndAddToRun(...
                eng.sigRepository,signalIDs(1),signalIDs(2),globalTol);
                eng.setDiffRunResult(runID);
            catch me
                msgStr=me.message;
                titleStr=getString(message('SDI:sdi:CompareSignalsError'));
                okStr=getString(message('SDI:sdi:OKShortcut'));

                Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                'default',...
                titleStr,...
                msgStr,...
                {okStr},...
                0,...
                -1,...
                []);
            end
        end

        function signalsComparisonResult(compareRunID)
            try
                eng=Simulink.sdi.Instance.engine;
                eng.setDiffRunResult(compareRunID);
            catch me %#ok<NASGU>

            end
        end



        function enableCompareButton(~)
            message.publish('/sdi2/updateCompareButton',true);
        end

        function deleteArchiveRun(dbIDs,appStr,appVariant)
            if nargin==2
                appVariant='sdi';
            end

            Simulink.sdi.checkPendingRunDelete();
        end

        function deleteInEngine(dbIDs,appStr,appVariant)
            if nargin==2
                appVariant='sdi';
            end

            try
                eng=Simulink.sdi.Instance.engine;
                sigIDs=[];
                resampledSigIDs=[];
                for idx=1:length(dbIDs)
                    if eng.isValidSignalID(dbIDs(idx))
                        sigIDs=[sigIDs;dbIDs(idx)];%#ok<AGROW>
                        if strcmp(appVariant,'siganalyzer')


                            resampledSigID=eng.sigRepository.getSignalTmResampledSigID(dbIDs(idx));
                            if eng.isValidSignalID(resampledSigID)
                                resampledSigIDs=[resampledSigIDs;resampledSigID];%#ok<AGROW>
                            end
                        end
                    elseif eng.isValidRunID(dbIDs(idx))
                        sigIDs=[sigIDs;eng.getAllSignalIDs(dbIDs(idx),'leaf')];%#ok<AGROW>
                    end
                end
                if~isempty(sigIDs)
                    Simulink.sdi.SignalClient.publishSignalLabels(sigIDs,appStr,true);
                end
                eng.deleteRunsAndSignals(dbIDs,appStr,true,'appName',appVariant);
                if~isempty(resampledSigIDs)
                    eng.deleteRunsAndSignals(resampledSigIDs,appStr,true,'appName',appVariant);
                end
            catch me %#ok<NASGU>
                Simulink.sdi.internal.PrototypeTable.displayCannotDeleteWhileStreamingMessage();
            end
        end

        function deleteAllInEngine(appStr)
            try
                eng=Simulink.sdi.Instance.engine;
                runIDs=eng.getAllRunIDs(appStr);
                sigIDs=[];
                for idx=1:length(runIDs)
                    sigIDs=[sigIDs;eng.getAllSignalIDs(runIDs(idx),'leaf')];%#ok<AGROW>
                end
                if~isempty(sigIDs)
                    Simulink.sdi.SignalClient.publishSignalLabels(sigIDs,appStr,true);
                end
                Simulink.sdi.Instance.engine.deleteAllRuns(appStr);
                Simulink.sdi.Instance.engine.publishUpdateLabelsNotification();
            catch me %#ok<NASGU>
                Simulink.sdi.internal.PrototypeTable.displayCannotDeleteWhileStreamingMessage();
            end
        end

        function displayCannotDeleteWhileStreamingMessage()
            msgStr=getString(message('SDI:sdi:DeleteRunsOrSignalsWhileSimulating'));
            titleStr=getString(message('SDI:sdi:DeleteError'));
            okStr=getString(message('SDI:sdi:OKShortcut'));

            Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
            'default',...
            titleStr,...
            msgStr,...
            {okStr},...
            0,...
            -1,...
            []);
        end

        function setComparisonRunName(dbID,name)
            Simulink.sdi.Instance.engine.setRunName(dbID,name);
        end

        function setComparisonSigOverrideGlobalTol(comparisonParentID,childDbID,...
            value,sourceTypeStr,globalAbsTol,globalRelTol,globalLaggingTol,globalLeadingTol)
            try
                globalTol=struct('absolute',globalAbsTol,'relative',globalRelTol,...
                'lagging',globalLaggingTol,'leading',globalLeadingTol);
                eng=Simulink.sdi.Instance.engine;
                if childDbID~=0
                    if strcmpi(sourceTypeStr,'baseline')
                        sourceDbID=eng.getSignalSource(childDbID);
                        sourceIsValid=eng.isValidSignalID(sourceDbID);
                        if sourceIsValid
                            eng.setSignalOverrideGlobalTol(sourceDbID,value);
                        end
                        if eng.isValidSignalID(childDbID)
                            eng.setSignalOverrideGlobalTol(childDbID,value);
                        end
                        Simulink.sdi.recompareSignalsWithTolerance(...
                        eng.sigRepository,comparisonParentID,globalTol);
                    else
                        if eng.isValidSignalID(childDbID)
                            eng.setSignalOverrideGlobalTol(childDbID,value);
                        end
                    end
                end
            catch me
                msgStr=me.message;
                titleStr=getString(message('SDI:sdi:InvalidValue'));
                okStr=getString(message('SDI:sdi:OKShortcut'));

                Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                'default',...
                titleStr,...
                msgStr,...
                {okStr},...
                0,...
                -1,...
                []);
            end
        end

        function setComparisonSigAbsTol(comparisonParentID,childDbID,...
            value,sourceTypeStr)
            try
                eng=Simulink.sdi.Instance.engine;
                if childDbID~=0
                    if strcmpi(sourceTypeStr,'baseline')
                        sourceDbID=eng.getSignalSource(childDbID);
                        sourceIsValid=eng.isValidSignalID(sourceDbID);
                        if sourceIsValid
                            eng.setSignalAbsTol(sourceDbID,value);


                            Simulink.sdi.internal.PrototypeTable.setSignalOverrideGlobalTol(sourceDbID,true);
                        end
                        if eng.isValidSignalID(childDbID)
                            eng.setSignalAbsTol(childDbID,value);


                            Simulink.sdi.internal.PrototypeTable.setSignalOverrideGlobalTol(childDbID,true);
                        end
                        Simulink.sdi.recompareSignalsWithTolerance(...
                        eng.sigRepository,comparisonParentID,[]);
                    else
                        if eng.isValidSignalID(childDbID)
                            eng.setSignalAbsTol(childDbID,value);


                            Simulink.sdi.internal.PrototypeTable.setSignalOverrideGlobalTol(childDbID,true);
                        end
                    end
                end
            catch me
                msgStr=me.message;
                titleStr=getString(message('SDI:sdi:InvalidValue'));
                okStr=getString(message('SDI:sdi:OKShortcut'));

                Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                'default',...
                titleStr,...
                msgStr,...
                {okStr},...
                0,...
                -1,...
                []);
            end
        end

        function setComparisonSigRelTol(comparisonParentID,childDbID,...
            value,sourceTypeStr)
            try
                eng=Simulink.sdi.Instance.engine;
                if childDbID~=0
                    if strcmpi(sourceTypeStr,'baseline')
                        sourceDbID=eng.getSignalSource(childDbID);
                        sourceIsValid=eng.isValidSignalID(sourceDbID);
                        if sourceIsValid
                            eng.setSignalRelTol(sourceDbID,value);


                            Simulink.sdi.internal.PrototypeTable.setSignalOverrideGlobalTol(sourceDbID,true);
                        end
                        if eng.isValidSignalID(childDbID)
                            eng.setSignalRelTol(childDbID,value);


                            Simulink.sdi.internal.PrototypeTable.setSignalOverrideGlobalTol(childDbID,true);
                        end
                        Simulink.sdi.recompareSignalsWithTolerance(...
                        eng.sigRepository,comparisonParentID,[]);
                    else
                        if eng.isValidSignalID(childDbID)
                            eng.setSignalRelTol(childDbID,value);


                            Simulink.sdi.internal.PrototypeTable.setSignalOverrideGlobalTol(childDbID,true);
                        end
                    end
                end
            catch me
                msgStr=me.message;
                titleStr=getString(message('SDI:sdi:InvalidValue'));
                okStr=getString(message('SDI:sdi:OKShortcut'));

                Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                'default',...
                titleStr,...
                msgStr,...
                {okStr},...
                0,...
                -1,...
                []);
            end
        end

        function setSignalUnits(dbID,units,varargin)
            sig=Simulink.sdi.getSignal(dbID);
            try
                sig.convertUnits(units);

                Simulink.sdi.redrawSignalAfterRescale(dbID);
            catch me
                titleStr=getString(message('SDI:sdi:UnitConvertErrorTitle'));
                msgStr=getString(message('SDI:sdi:UnitConvertErrorDesc',me.message));
                okStr=getString(message('SDI:sdi:UnitConvertErrorOverrideShortcut'));
                cancelStr=getString(message('SDI:sdi:CancelShortcut'));

                Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                'default',...
                titleStr,...
                msgStr,...
                {okStr,cancelStr},...
                1,...
                -1,...
                @(x)Simulink.sdi.internal.PrototypeTable.setSignalUnitsMsgResponse(dbID,units,x,[]),...
                varargin{:});
            end
        end

        function setSignalDisplayUnits(dbID,units,varargin)
            sig=Simulink.sdi.getSignal(dbID);
            try
                sig.setDisplayUnit(units);
                eng=Simulink.sdi.Instance.engine;
                if eng.isValidSignalID(dbID)
                    eng.setSignalDisplayUnit(dbID,units);
                end

                Simulink.sdi.redrawSignalAfterRescale(dbID);
            catch me
                switch me.identifier
                case 'SDI:sdi:UnresolvedUnit'
                    titleStr=getString(message('SDI:sdi:UnitConvertErrorTitle'));
                    msgStr=me.message;
                    okStr=getString(message('SDI:sdi:ContinueDataTypeShortcut'));
                    cancelStr=getString(message('SDI:sdi:CancelShortcut'));

                    Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                    'default',...
                    titleStr,...
                    msgStr,...
                    {okStr,cancelStr},...
                    1,...
                    -1,...
                    @(x)Simulink.sdi.internal.PrototypeTable.setUnresolvedUnitMsgResponse(dbID,units,x),...
                    varargin{:});
                otherwise
                    titleStr=getString(message('SDI:sdi:UnitConvertErrorTitle'));
                    msgStr=me.message;
                    okStr=getString(message('SDI:sdi:OKShortcut'));

                    Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                    'default',...
                    titleStr,...
                    msgStr,...
                    {okStr},...
                    1,...
                    -1,...
                    @(x)Simulink.sdi.internal.PrototypeTable.setSignalDisplayUnitsMsgResponse(dbID),...
                    varargin{:});
                end
            end
        end

        function setSignalUnitsMsgResponse(dbID,units,choice,recompareOpts)
            if choice==0
                sig=Simulink.sdi.getSignal(dbID);
                sig.Units=units;
                if~isempty(recompareOpts)
                    eng=Simulink.sdi.Instance.engine;
                    Simulink.sdi.recompareSignalsWithTolerance(...
                    eng.sigRepository,recompareOpts.comparisonParentID,recompareOpts.globalTol);
                end
            elseif~isempty(recompareOpts)


                eng=Simulink.sdi.Instance.engine;
                appEnum=Simulink.sdi.internal.PrototypeTable.getApp(recompareOpts.signalID);
                Simulink.sdi.updateRowInTable(eng.sigRepository,recompareOpts.signalID,appEnum,'units');
            end
        end

        function setSignalDisplayUnitsMsgResponse(dbID)
            eng=Simulink.sdi.Instance.engine;
            appEnum=Simulink.sdi.internal.PrototypeTable.getApp(dbID);
            Simulink.sdi.updateRowInTable(eng.sigRepository,dbID,appEnum,'displayUnits');
        end

        function setUnresolvedUnitMsgResponse(dbID,unit,choice)
            eng=Simulink.sdi.Instance.engine;
            if choice==0
                eng.setSignalUnit(dbID,unit);
            end
            appEnum=Simulink.sdi.internal.PrototypeTable.getApp(dbID);
            Simulink.sdi.updateRowInTable(eng.sigRepository,dbID,...
            appEnum,'displayUnits');
        end

        function setSignalDisplayScaling(dbID,val,varargin)
            sig=Simulink.sdi.getSignal(dbID);
            sig.DisplayScaling=val;
        end

        function setSignalDisplayOffset(dbID,val,varargin)
            sig=Simulink.sdi.getSignal(dbID);
            sig.DisplayOffset=val;
        end

        function setSignalDescription(dbID,str,varargin)
            sig=Simulink.sdi.getSignal(dbID);
            sig.Description=str;
        end

        function setComparisonSigLaggingTol(comparisonParentID,childDbID,...
            value,sourceTypeStr)
            try
                eng=Simulink.sdi.Instance.engine;
                if childDbID~=0
                    if strcmpi(sourceTypeStr,'baseline')
                        sourceDbID=eng.getSignalSource(childDbID);
                        sourceIsValid=eng.isValidSignalID(sourceDbID);
                        if sourceIsValid



                            eng.setSignalBackwardTimeTol(sourceDbID,value);


                            Simulink.sdi.internal.PrototypeTable.setSignalOverrideGlobalTol(sourceDbID,true);
                        end
                        if eng.isValidSignalID(childDbID)



                            eng.setSignalBackwardTimeTol(childDbID,value);


                            Simulink.sdi.internal.PrototypeTable.setSignalOverrideGlobalTol(childDbID,true);
                        end
                        Simulink.sdi.recompareSignalsWithTolerance(...
                        eng.sigRepository,comparisonParentID,[]);
                    else
                        if eng.isValidSignalID(childDbID)



                            eng.setSignalBackwardTimeTol(childDbID,value);


                            Simulink.sdi.internal.PrototypeTable.setSignalOverrideGlobalTol(childDbID,true);
                        end
                    end
                end
            catch me
                msgStr=me.message;
                titleStr=getString(message('SDI:sdi:InvalidValue'));
                okStr=getString(message('SDI:sdi:OKShortcut'));

                Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                'default',...
                titleStr,...
                msgStr,...
                {okStr},...
                0,...
                -1,...
                []);
            end
        end

        function setComparisonSigLeadingTol(comparisonParentID,childDbID,...
            value,sourceTypeStr)
            try
                eng=Simulink.sdi.Instance.engine;
                if childDbID~=0
                    if strcmpi(sourceTypeStr,'baseline')
                        sourceDbID=eng.getSignalSource(childDbID);
                        sourceIsValid=eng.isValidSignalID(sourceDbID);
                        if sourceIsValid



                            eng.setSignalForwardTimeTol(sourceDbID,value);


                            Simulink.sdi.internal.PrototypeTable.setSignalOverrideGlobalTol(sourceDbID,true);
                        end
                        if eng.isValidSignalID(childDbID)



                            eng.setSignalForwardTimeTol(childDbID,value);


                            Simulink.sdi.internal.PrototypeTable.setSignalOverrideGlobalTol(childDbID,true);
                        end
                        Simulink.sdi.recompareSignalsWithTolerance(...
                        eng.sigRepository,comparisonParentID,[]);
                    else
                        if eng.isValidSignalID(childDbID)



                            eng.setSignalForwardTimeTol(childDbID,value);


                            Simulink.sdi.internal.PrototypeTable.setSignalOverrideGlobalTol(childDbID,true);
                        end
                    end
                end
            catch me
                msgStr=me.message;
                titleStr=getString(message('SDI:sdi:InvalidValue'));
                okStr=getString(message('SDI:sdi:OKShortcut'));

                Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                'default',...
                titleStr,...
                msgStr,...
                {okStr},...
                0,...
                -1,...
                []);
            end
        end

        function setComparisonSigTimeTol(comparisonParentID,childDbID,...
            value,sourceTypeStr)
            try
                eng=Simulink.sdi.Instance.engine;
                if childDbID~=0
                    if strcmpi(sourceTypeStr,'baseline')
                        sourceDbID=eng.getSignalSource(childDbID);
                        sourceIsValid=eng.isValidSignalID(sourceDbID);
                        if sourceIsValid
                            eng.setSignalTimeTol(sourceDbID,value);


                            Simulink.sdi.internal.PrototypeTable.setSignalOverrideGlobalTol(sourceDbID,true);
                        end
                        if eng.isValidSignalID(childDbID)
                            eng.setSignalTimeTol(childDbID,value);


                            Simulink.sdi.internal.PrototypeTable.setSignalOverrideGlobalTol(childDbID,true);
                        end
                        Simulink.sdi.recompareSignalsWithTolerance(...
                        eng.sigRepository,comparisonParentID,[]);
                    else
                        if eng.isValidSignalID(childDbID)
                            eng.setSignalTimeTol(childDbID,value);


                            Simulink.sdi.internal.PrototypeTable.setSignalOverrideGlobalTol(childDbID,true);
                        end
                    end
                end
            catch me
                msgStr=me.message;
                titleStr=getString(message('SDI:sdi:InvalidValue'));
                okStr=getString(message('SDI:sdi:OKShortcut'));

                Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                'default',...
                titleStr,...
                msgStr,...
                {okStr},...
                0,...
                -1,...
                []);
            end
        end

        function setComparisonSigSyncMethod(comparisonParentID,childDbID,...
            value,sourceTypeStr,globalAbsTol,globalRelTol,globalLaggingTol,globalLeadingTol)
            eng=Simulink.sdi.Instance.engine;
            globalTol=struct('absolute',globalAbsTol,'relative',globalRelTol,...
            'lagging',globalLaggingTol,'leading',globalLeadingTol);
            if childDbID~=0
                if strcmpi(sourceTypeStr,'baseline')
                    sourceDbID=eng.getSignalSource(childDbID);
                    sourceIsValid=eng.isValidSignalID(sourceDbID);
                    if sourceIsValid
                        eng.setSignalSyncMethod(sourceDbID,value);
                    end
                    if eng.isValidSignalID(childDbID)
                        eng.setSignalSyncMethod(childDbID,value);
                    end
                    Simulink.sdi.recompareSignalsWithTolerance(...
                    eng.sigRepository,comparisonParentID,globalTol);
                else
                    if eng.isValidSignalID(childDbID)
                        eng.setSignalSyncMethod(childDbID,value);
                    end
                end
            end
        end

        function setComparisonSigUnitsMethod(comparisonParentID,childDbID,...
            value,globalAbsTol,globalRelTol,globalLaggingTol,globalLeadingTol)
            eng=Simulink.sdi.Instance.engine;
            globalTol=struct('absolute',globalAbsTol,'relative',globalRelTol,...
            'lagging',globalLaggingTol,'leading',globalLeadingTol);


            if eng.isValidSignalID(childDbID)
                sourceDbID=eng.getSignalSource(childDbID);
                if eng.isValidSignalID(sourceDbID)

                    origSig=Simulink.sdi.getSignal(sourceDbID);
                    cmpSig=Simulink.sdi.getSignal(childDbID);
                    try
                        origSig.convertUnits(value);
                        cmpSig.convertUnits(value);


                        Simulink.sdi.recompareSignalsWithTolerance(...
                        eng.sigRepository,comparisonParentID,globalTol);
                    catch me
                        opts.comparisonParentID=comparisonParentID;
                        opts.globalTol=globalTol;
                        opts.signalID=childDbID;
                        titleStr=getString(message('SDI:sdi:UnitConvertErrorTitle'));
                        msgStr=getString(message('SDI:sdi:UnitConvertErrorDesc',me.message));
                        okStr=getString(message('SDI:sdi:UnitConvertErrorOverrideShortcut'));
                        cancelStr=getString(message('SDI:sdi:CancelShortcut'));

                        Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                        'default',...
                        titleStr,...
                        msgStr,...
                        {okStr,cancelStr},...
                        1,...
                        -1,...
                        @(x)Simulink.sdi.internal.PrototypeTable.setSignalUnitsMsgResponse(sourceDbID,value,x,opts));
                    end
                else

                    Simulink.sdi.internal.PrototypeTable.setSignalUnits(childDbID,value);


                    Simulink.sdi.recompareSignalsWithTolerance(...
                    eng.sigRepository,comparisonParentID,globalTol);
                end
            end
        end

        function setComparisonSigInterpMethod(comparisonParentID,childDbID,...
            value,~,globalAbsTol,globalRelTol,globalLaggingTol,globalLeadingTol,varargin)
            eng=Simulink.sdi.Instance.engine;
            globalTol=struct('absolute',globalAbsTol,'relative',globalRelTol,...
            'lagging',globalLaggingTol,'leading',globalLeadingTol);
            if strcmpi(value,message('SDI:sdi:NoneEventBased').getString)
                value='none';
            end
            if childDbID~=0
                sourceDbID=eng.getSignalSource(childDbID);
                sourceIsValid=eng.isValidSignalID(sourceDbID);
                if sourceIsValid
                    eng.setSignalInterpMethod(sourceDbID,value);
                end
                if eng.isValidSignalID(childDbID)
                    eng.setSignalInterpMethod(childDbID,value);
                end
                Simulink.sdi.recompareSignalsWithTolerance(...
                eng.sigRepository,comparisonParentID,globalTol);
            end
        end

        function setComparisonSigDataType(comparisonParentID,childDbID,...
            value,globalAbsTol,globalRelTol,globalLaggingTol,globalLeadingTol)
            eng=Simulink.sdi.Instance.engine;
            globalTol=struct('absolute',globalAbsTol,'relative',globalRelTol,...
            'lagging',globalLaggingTol,'leading',globalLeadingTol);

            if childDbID~=0
                sourceDbID=eng.getSignalSource(childDbID);
                if eng.isValidSignalID(sourceDbID)
                    origSig=Simulink.sdi.getSignal(sourceDbID);
                    cmpSig=Simulink.sdi.getSignal(childDbID);
                    try
                        origSig.convertDataType(value,true);
                        cmpSig.convertDataType(value,true);
                        Simulink.sdi.recompareSignalsWithTolerance(...
                        eng.sigRepository,comparisonParentID,globalTol);
                    catch me
                        opts.comparisonParentID=comparisonParentID;
                        opts.globalTol=globalTol;
                        opts.signalID=childDbID;
                        if strcmp(me.identifier,'simulation_data_repository:sdr:ChangeSignalTypeInvalid')
                            titleStr=getString(message('SDI:sdi:DataTypeConvertErrorTitle'));
                            msgStr=me.message;
                            okStr=getString(message('SDI:sdi:OKShortcut'));

                            Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                            'default',...
                            titleStr,...
                            msgStr,...
                            {okStr},...
                            1,...
                            -1,...
                            @(x)Simulink.sdi.internal.PrototypeTable.setSignalDataTypeMsgResponse(sourceDbID,value,x,opts,'SDR:sdr:ChangeSignalTypeInvalid'));
                        elseif strcmp(me.identifier,'SDI:sdi:DataTypeConvertNoFixedPointLicense')
                            titleStr=getString(message('SDI:sdi:DataTypeConvertErrorTitle'));
                            msgStr=me.message;
                            okStr=getString(message('SDI:sdi:OKShortcut'));

                            Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                            'default',...
                            titleStr,...
                            msgStr,...
                            {okStr},...
                            1,...
                            -1,...
                            @(x)Simulink.sdi.internal.PrototypeTable.setSignalDataTypeMsgResponse(sourceDbID,value,x,opts,'SDI:sdi:DataTypeConvertNoFixedPointLicense'));
                        elseif strcmp(me.identifier,'SDI:sdi:DataTypeDownConversionError')
                            titleStr=getString(message('SDI:sdi:DataTypeDownConversionTitle'));
                            msgStr=getString(message('SDI:sdi:DataTypeDownConversionDesc',me.message,value));
                            okStr=getString(message('SDI:sdi:ContinueDataTypeShortcut'));
                            cancelStr=getString(message('SDI:sdi:CancelShortcut'));

                            Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                            'default',...
                            titleStr,...
                            msgStr,...
                            {okStr,cancelStr},...
                            1,...
                            -1,...
                            @(x)Simulink.sdi.internal.PrototypeTable.setSignalDataTypeMsgResponse(sourceDbID,value,x,opts,'SDI:sdi:DataTypeDownConversionError'));
                        else
                            titleStr=getString(message('SDI:sdi:DataTypeConvertErrorTitle'));
                            msgStr=me.message;
                            okStr=getString(message('SDI:sdi:OKShortcut'));

                            Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                            'default',...
                            titleStr,...
                            msgStr,...
                            {okStr},...
                            1,...
                            -1,...
                            @(x)Simulink.sdi.internal.PrototypeTable.setSignalDataTypeMsgResponse(sourceDbID,value,x,opts,'SDR:sdr:ChangeSignalTypeInvalid'));
                        end
                    end
                end
            end
        end

        function setComparisonSigLineColor(childDbID,color)
            import Simulink.sdi.internal.LineSettings;
            colorDoubleArray=LineSettings.hexStringToColor(color);
            if~isempty(colorDoubleArray)
                eng=Simulink.sdi.Instance.engine;
                eng.setSignalLineColor(childDbID,colorDoubleArray);
            end
        end

        function setComparisonSigLineStyle(childDbID,linestyle)
            eng=Simulink.sdi.Instance.engine;
            eng.setSignalLineDashed(childDbID,linestyle);
        end

        function setComparisonSigLineWidth(childDbID,linewidth)
            eng=Simulink.sdi.Instance.engine;
            eng.setSignalLineWidth(childDbID,linewidth);
        end

        function saveViewPreferences(varargin)
            Simulink.sdi.Instance.engine.savePreferences(varargin{:});
        end
    end
end


