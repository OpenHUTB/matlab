

classdef TimeMetadataDialog<handle


    properties(Access=protected)
        AppsUsingControllerList=[];
    end



    methods(Static)
        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                engObj=Simulink.sdi.Instance.engine();
                ctrlObj=signal.sigappsshared.controllers.TimeMetadataDialog(dispatcherObj,engObj);
            end


            ret=ctrlObj;
        end


        function cb_HelpButton(~)

            signal.sigappsshared.controllers.SigAppsHelp('editTimeDlgHelp');
        end
    end



    methods(Access=protected)
        function this=TimeMetadataDialog(dispatcherObj,eng)

            this.Engine=eng;
            this.Dispatcher=dispatcherObj;
            import signal.sigappsshared.controllers.TimeMetadataDialog;


            this.Dispatcher.subscribe(...
            [TimeMetadataDialog.ControllerID,'/','help'],...
            @(arg)TimeMetadataDialog.cb_HelpButton(arg));


            this.Dispatcher.subscribe(...
            [TimeMetadataDialog.ControllerID,'/','ok'],...
            @(arg)cb_OKButton(this,arg));

            this.Dispatcher.subscribe(...
            [TimeMetadataDialog.ControllerID,'/','preshowdialog'],...
            @(arg)cb_PreShowDialog(this,arg));

            this.Dispatcher.subscribe(...
            [TimeMetadataDialog.ControllerID,'/','proceedmetadataupdate'],...
            @(arg)cb_SetTimeMetadataAfterWarning(this,arg));
        end
    end

    methods(Hidden)

        function addAppNameToAppsUsingControllerList(this,appName)
            appName=validatestring(appName,["SignalAnalyzer","SignalLabeler"]);
            if~any(strcmp(appName,this.AppsUsingControllerList))
                this.AppsUsingControllerList=[this.AppsUsingControllerList;appName];
            end
        end

        function removeAppNameFromAppsUsingControllerList(this,appName)
            appName=validatestring(appName,["SignalAnalyzer","SignalLabeler"]);
            appIdx=strcmp(appName,this.AppsUsingControllerList);
            this.AppsUsingControllerList(appIdx)=[];
        end

        function appNames=getAppsUsingControllerList(this)
            appNames=this.AppsUsingControllerList;
        end


        function[flag,errStr,s]=checkTimeMetadata(this,args)

            s=struct;
            flag=true;
            clientID=[];

            updateObjectFlag=true;
            validateSignalLengthFlag=true;
            sendWarningFlag=true;

            if nargin==1
                args=this.CurrentOkArgs.data;
                clientID=this.CurrentOkArgs.clientID;
            else
                updateObjectFlag=args.updateObjectFlag;
                validateSignalLengthFlag=args.validateSignalLengthFlag;
                sendWarningFlag=args.sendWarningFlag;
            end


            switch args.tmMode
            case 'samples'
                s.TmMode='samples';
                if(updateObjectFlag)
                    this.CurrentTimeMetadataValues=s;
                end
                return;

            case 'fs'


                [fs,errStr]=evaluateValue(this,args.sampleTimeOrRate,'scalar',false);
                if~isempty(errStr)
                    if(sendWarningFlag)
                        sendWarning(this,'fs',errStr,clientID);
                    end
                    flag=false;
                    return;
                end

                [startTime,errStr]=evaluateValue(this,args.startTime,'scalar',[]);
                if~isempty(errStr)
                    if(sendWarningFlag)
                        sendWarning(this,'startTime',errStr,clientID);
                    end
                    flag=false;
                    return;
                end


                s.TmMode='fs';
                s.fs=double(fs);
                s.startTime=double(startTime);
                if updateObjectFlag
                    this.CurrentTimeMetadataValues=s;
                end

            case 'ts'


                [ts,errStr]=evaluateValue(this,args.sampleTimeOrRate,'scalar',false);
                if~isempty(errStr)
                    if(sendWarningFlag)
                        sendWarning(this,'ts',errStr,clientID);
                    end
                    flag=false;
                    return;
                end

                [startTime,errStr]=evaluateValue(this,args.startTime,'scalar',[]);
                if~isempty(errStr)
                    if(sendWarningFlag)
                        sendWarning(this,'startTime',errStr,clientID);
                    end
                    flag=false;
                    return;
                end


                s.TmMode='ts';
                s.ts=double(ts);
                s.startTime=double(startTime);
                if updateObjectFlag
                    this.CurrentTimeMetadataValues=s;
                end

            case 'tv'
                [tv,errStr]=evaluateValue(this,args.timeVector,'timevector');
                if~isempty(errStr)
                    sendWarning(this,'tv',errStr,clientID);
                    flag=false;
                    return;
                end


                if length(tv)~=length(unique(tv))
                    errStr=getString(message('SDI:dialogs:TimeVectorUnique'));
                    if(sendWarningFlag)
                        sendWarning(this,'tv',errStr,clientID);
                    end
                    flag=false;
                    return;
                end


                if~issorted(tv)
                    errStr=getString(message('SDI:dialogs:TimeVectorSorted'));
                    if(sendWarningFlag)
                        sendWarning(this,'tv',errStr,clientID);
                    end
                    flag=false;
                    return;
                end

                if validateSignalLengthFlag



                    safeTransaction(this.Engine,...
                    @this.validateTimeVectorLength,args.signalIDs,length(tv));

                    if(~this.ValidateVectorLengthFlag)
                        errStr=getString(message('SDI:dialogs:TimeVectorLength'));
                        if(sendWarningFlag)
                            sendWarning(this,'tv',errStr,clientID);
                        end
                        flag=false;
                        return;
                    end
                end


                [isValidNonUnifData,errObj]=this.validateNonUniformTimeValues(tv);
                if~isValidNonUnifData
                    if(sendWarningFlag)
                        sendWarning(this,'tv',getString(errObj),clientID);
                    else
                        errStr=getString(message(errObj.Identifier));
                    end
                    flag=false;
                    return;
                end


                s.TmMode='tv';
                s.tv=double(tv);
                s.timeVectorString=args.timeVector;
                if updateObjectFlag
                    this.CurrentTimeMetadataValues=s;
                end
            end
        end
    end



    methods(Access=protected)

        function cb_OKButton(this,args)

            this.CurrentOkArgs=args;
            this.CurrentOkArgs.signalsNeedResampling=false;


            success=checkTimeMetadata(this);

            if(success)





                outStruct=safeTransaction(this.Engine,...
                @checkCompatibilityWithDisplays,this);

                this.CurrentEvent=outStruct.evt;

                if outStruct.needToShowWarningDlg

                    this.Dispatcher.publishToClient(args.clientID,...
                    this.ControllerID,'showIncompatibleWarning',...
                    this.CurrentEvent);
                else

                    updateTimeMetadataAndNotifyClient(this);
                    notifyWithUpdateTableSelectionFlags(this);
                    closeDialogOnOK(this,args.clientID);
                end
            end
        end


        function cb_SetTimeMetadataAfterWarning(this,args)

            updateTimeMetadataAndNotifyClient(this);
            notifyWithUpdateTableSelectionFlags(this);
            closeDialogOnOK(this,args.clientID);
        end


        function cb_PreShowDialog(this,arg)



            info=arg.data;
            runIDs=[];
            signalIDs=[];
            if isfield(info,'idArray')&&~isempty(info.idArray)

                [runIDs,signalIDs]=...
                Simulink.sdi.getIDsFromViewIndices(...
                this.Engine.sigRepository,int32(info.idArray),info.clientID);
            elseif isfield(info,'signalID')&&~isempty(info.signalID)
                signalIDs=info.signalID;
            end






            for idx=1:length(runIDs)
                foundSigIDs=this.getAllNonResampledSignals(runIDs(idx));
                signalIDs=[signalIDs;foundSigIDs];%#ok<*AGROW>
            end



            children=[];
            parentIdx=[];
            for idx=1:length(signalIDs)
                newChildren=this.Engine.getSignalChildren(signalIDs(idx));
                if~isempty(newChildren)
                    parentIdx=[parentIdx;idx];
                    children=[children;newChildren(:)];
                end
            end
            signalIDs(parentIdx)=[];
            signalIDs=unique([signalIDs;children]);

            data.signalIDs=signalIDs;
            data.runIDs=runIDs;


            if checkSignalsEditable(this,data.signalIDs)
                data.timeMetadata=safeTransaction(...
                this.Engine,@getSignalsTimeMetadata,this,signalIDs);

                this.Dispatcher.publishToClient(arg.clientID,...
                this.ControllerID,'postShowDialog',data);
            else
                this.Dispatcher.publishToClient(arg.clientID,...
                this.ControllerID,'showCannotEditTimeWarning',[]);
            end
        end


        function updateTimeMetadataAndNotifyClient(this)
            setTimeMetadata(this);



            evt.eventData=this.CurrentEvent;
            evt.clientID=this.CurrentOkArgs.clientID;
            evt.tmMode=this.CurrentOkArgs.data.tmMode;
            this.notifyClientOfTimeMetadataChange(evt);
        end


        function notifyWithUpdateTableSelectionFlags(this)


            clientData.clientID=double(string(this.CurrentOkArgs.clientID));
            clientData.messageID='updatedSelectionFlags';


            isHomogeneousSampleSignalsSelected=strcmp(this.CurrentOkArgs.data.tmMode,'samples');
            isHomogeneousUniformSignalsSelected=~isHomogeneousSampleSignalsSelected&&~this.CurrentOkArgs.signalsNeedResampling;
            clientData.data=struct('isHomogeneousUniformSignalsSelected',isHomogeneousUniformSignalsSelected,...
            'isHomogeneousNonUniformSignalsSelected',this.CurrentOkArgs.signalsNeedResampling,...
            'isHomogeneousSampleSignalsSelected',isHomogeneousSampleSignalsSelected,...
            'isEnableUndoPreprocessForSignalsSelected',false,...
            'isEnableGenerateFunctionForSignalsSelected',false);
            message.publish('/sdi/tableApplication',clientData);
        end

        function flag=checkSignalsEditable(this,sigVect)


            flag=true;
            for idx=1:length(sigVect)
                if strcmp(this.Engine.getSignalTmMode(sigVect(idx)),'')||...
                    strcmp(this.Engine.getSignalTmMode(sigVect(idx)),'none')
                    flag=false;
                    break;
                end
            end
        end


        function setTimeMetadata(this)

            args=this.CurrentOkArgs.data;

            switch this.CurrentTimeMetadataValues.TmMode
            case 'samples'
                safeTransaction(this.Engine,...
                @this.setTimeMetadataBySamples,args.signalIDs);
                return;

            case 'fs'
                fs=this.CurrentTimeMetadataValues.fs;
                startTime=this.CurrentTimeMetadataValues.startTime;
                safeTransaction(this.Engine,...
                @this.setTimeMetadataByFs,...
                args.signalIDs,...
                fs,args.sampleTimeOrRateUnits,...
                startTime,args.startTimeUnits);
                return;

            case 'ts'
                ts=this.CurrentTimeMetadataValues.ts;
                startTime=this.CurrentTimeMetadataValues.startTime;
                safeTransaction(this.Engine,...
                @this.setTimeMetadataByTs,...
                args.signalIDs,...
                ts,args.sampleTimeOrRateUnits,...
                startTime,args.startTimeUnits);
                return;

            case 'tv'
                tv=this.CurrentTimeMetadataValues.tv;
                timeVectorStr=this.CurrentTimeMetadataValues.timeVectorString;

                safeTransaction(this.Engine,...
                @this.setTimeMetadataByTimeVector,...
                args.signalIDs,...
                tv,timeVectorStr);
            end

        end



        function removeAllAuxilarySignals(this,sigID)
            signal.sigappsshared.SignalUtilities.removeAllAuxilarySignals(this.Engine,sigID);
        end


        function removeDomainSignals(this,sigID)
            signal.sigappsshared.SignalUtilities.removeDomainSignals(this.Engine,sigID);
        end


        function resetActionNameThatCreatedSignal(this,sigID)


            this.Engine.setMetaDataV2(sigID,'ActionNameThatCreatedSignal','');
        end


        function validateTimeVectorLength(this,sigIDs,timeVectLength)
            flag=true;
            for idx=1:length(sigIDs)
                sigLength=this.Engine.getSignalNumberOfPoints(sigIDs(idx));
                if sigLength~=timeVectLength
                    flag=false;
                    break;
                end
            end
            this.ValidateVectorLengthFlag=flag;
        end


        function updateSignalTimeValues(this,sigID,startValue,timeFactor,updateStruct)

            this.Engine.safeTransaction(@updateSignalTimeValuesImpl,this.Engine,sigID,startValue,timeFactor,updateStruct);

            function updateSignalTimeValuesImpl(eng,sigID,startValue,timeFactor,updateStruct)
                sig=eng.getSignalObject(sigID);
                values=sig.Values;
                if isempty(updateStruct)
                    sigLength=length(values.Data);
                    s.Data=values.Data;
                else
                    sigLength=updateStruct.sigLength;
                    s.Data=updateStruct.sigDataValues;
                end
                s.Time=startValue+(0:sigLength-1)*timeFactor;
                if isempty(eng.getSignalChildren(sigID))
                    sig.Values=s;
                end
                eng.setSignalTmNumPoints(sigID,sigLength);
                eng.setSignalTmTimeRange(sigID,[s.Time(1),s.Time(end)]);
            end
        end


        function updateSignalTimeValuesForTimeVectorCase(this,sigID,timeVector,avgSampleRate,needsResampling,updateStruct,notifyFlag)

            sig=this.Engine.getSignalObject(sigID);
            if isempty(updateStruct)
                s.Data=sig.Values.Data;
            else
                s.Data=updateStruct.sigDataValues;
            end
            s.Time=double(timeVector);
            if isempty(this.Engine.getSignalChildren(sigID))
                sig.Values=s;
            end
            this.updateResampledSignal(sigID,s,needsResampling,avgSampleRate,notifyFlag);
        end


        function[v,errStr]=evaluateValue(~,value,type,nonnegativeFlag)
            if nargin<3
                type='scalar';
            end

            if nargin<4
                nonnegativeFlag=false;
            end
            [v,errStr]=signal.sigappsshared.Utilities.evaluateValue(value,type,nonnegativeFlag);
        end


        function flag=isNewFsTimeMetadataEqual(this,sigID,fs,fsUnits,startTime,startTimeUnits)
            eng=this.Engine;
            flag=...
            strcmpi(eng.getSignalTmMode(sigID),'fs')&&...
            eng.getSignalTmSampleRate(sigID)==fs&&...
            strcmpi(eng.getSignalTmSampleRateUnits(sigID),fsUnits)&&...
            eng.getSignalTmStartTime(sigID)==startTime&&...
            strcmpi(eng.getSignalTmStartTimeUnits(sigID),startTimeUnits);
        end


        function flag=isNewTsTimeMetadataEqual(this,sigID,ts,tsUnits,startTime,startTimeUnits)
            eng=this.Engine;
            flag=...
            strcmpi(eng.getSignalTmMode(sigID),'ts')&&...
            eng.getSignalTmSampleTime(sigID)==ts&&...
            strcmpi(eng.getSignalTmSampleTimeUnits(sigID),tsUnits)&&...
            eng.getSignalTmStartTime(sigID)==startTime&&...
            strcmpi(eng.getSignalTmStartTimeUnits(sigID),startTimeUnits);
        end


        function sendWarning(this,target,msg,clientID)
            data.warningTarget=target;
            data.warningMsg=msg;
            this.Dispatcher.publishToClient(clientID,...
            this.ControllerID,'showWarning',data);
        end


        function closeDialogOnOK(this,clientID)
            this.Dispatcher.publishToClient(clientID,...
            this.ControllerID,'closeDialog',[]);

            this.CurrentOkArgs=[];
            this.CurrentEvent=[];
            this.AllSignalsWithTimeMetadataChange=[];
            this.CurrentTimeMetadataValues=[];
        end


        function axes=getAxesByClientByID(~,clientID)
            clientVect=Simulink.sdi.WebClient.getAllClients;
            idx=strcmp({clientVect.ClientID},clientID);
            axes=clientVect(idx).Axes;
        end


        function timeType=getTimeType(~,tmMode)
            if(strcmp(tmMode,'samples'))
                timeType='samples';
            else
                timeType='time';
            end
        end


        function m=getTimeMultiplier(~,units)
            m=signal.sigappsshared.Utilities.getTimeMultiplier(units);
        end


        function m=getFrequencyMultiplier(~,units)
            m=signal.sigappsshared.Utilities.getFrequencyMultiplier(units);
        end


        function sigIDs=getAllNonResampledSignals(this,runID)
            allSigIDs=this.Engine.getAllSignalIDs(int32(runID));
            sigIDs=[];
            for idx=1:length(allSigIDs)
                sigID=allSigIDs(idx);
                if~strcmp(this.Engine.getSignalTmMode(sigID),'resampled')
                    sigIDs=[sigIDs,sigID];
                end
            end
        end


        function dispNum=getDisplayNumFromAxesNum(this,axesNum)
            dispNum=mod(axesNum,this.MaxNumAxes);
            if dispNum==0
                dispNum=this.MaxNumAxes;
            end
        end
    end



    methods(Hidden)

        function setTimeMetadataBySamples(this,signalIDs,updateStruct,updateValuesFlag,updateTmModeFlag,notifyFlag)

            if nargin>2
                forceUpdate=true;
            else
                forceUpdate=false;
                updateStruct=[];
            end

            if nargin<4
                updateValuesFlag=true;
            end

            if nargin<5
                updateTmModeFlag=true;
            end

            if nargin<6
                notifyFlag=true;
            end

            for idx=1:length(signalIDs)
                sigID=signalIDs(idx);
                removeAllAuxilarySignals(this,sigID);
                clearResampledSignal(this,sigID);
                resetActionNameThatCreatedSignal(this,sigID);
                this.Engine.setSignalTmAvgSampleRate(int32(sigID),-1,false);

                if~strcmpi(this.Engine.getSignalTmMode(sigID),'samples')||forceUpdate
                    if updateTmModeFlag
                        this.Engine.setSignalTmMode(sigID,'samples',notifyFlag);
                    end

                    if updateValuesFlag
                        updateSignalTimeValues(this,sigID,0,1,updateStruct);
                    else
                        numPoints=this.Engine.getSignalTmNumPoints(sigID);
                        this.Engine.setSignalTmTimeRange(sigID,[0,numPoints-1]);
                    end
                end
            end
        end


        function setTimeMetadataByFs(this,signalIDs,fs,fsUnits,startTime,startTimeUnits,updateStruct,updateValuesFlag,removePreprocessSignal,updateTmModeFlag,notifyFlag)

            if nargin>6
                forceUpdate=true;
            else
                forceUpdate=false;
                updateStruct=[];
            end

            if nargin<8
                updateValuesFlag=true;
            end

            if nargin<9
                removePreprocessSignal=true;
            end

            if nargin<10
                updateTmModeFlag=true;
            end

            if nargin<11
                notifyFlag=true;
            end


            fsActual=fs*getFrequencyMultiplier(this,fsUnits);
            startTimeActual=startTime*getTimeMultiplier(this,startTimeUnits);

            for idx=1:length(signalIDs)
                sigID=signalIDs(idx);
                if removePreprocessSignal
                    removeAllAuxilarySignals(this,sigID);
                    resetActionNameThatCreatedSignal(this,sigID);
                else
                    removeDomainSignals(this,sigID);
                end
                clearResampledSignal(this,sigID);
                this.Engine.setSignalTmAvgSampleRate(int32(sigID),-1,false);

                if~isNewFsTimeMetadataEqual(this,sigID,fs,fsUnits,startTime,startTimeUnits)||forceUpdate
                    this.Engine.setSignalTmSampleRate(sigID,fs,false);
                    this.Engine.setSignalTmSampleRateUnits(sigID,fsUnits,false);
                    this.Engine.setSignalTmStartTime(sigID,startTime,false);
                    this.Engine.setSignalTmStartTimeUnits(sigID,startTimeUnits,false);
                    if updateTmModeFlag
                        this.Engine.setSignalTmMode(sigID,'fs',notifyFlag);
                    end

                    if updateValuesFlag
                        updateSignalTimeValues(this,sigID,startTimeActual,1/fsActual,updateStruct);
                    else
                        numPoints=this.Engine.getSignalTmNumPoints(sigID);
                        endTime=startTimeActual+(numPoints-1)/fsActual;
                        this.Engine.setSignalTmTimeRange(sigID,[startTimeActual,endTime]);
                    end
                end
            end
        end


        function setTimeMetadataByTs(this,signalIDs,ts,tsUnits,startTime,startTimeUnits,updateStruct,updateValuesFlag,removePreprocessSignal,updateTmModeFlag,notifyFlag)

            if nargin>6
                forceUpdate=true;
            else
                forceUpdate=false;
                updateStruct=[];
            end

            if nargin<8
                updateValuesFlag=true;
            end

            if nargin<9
                removePreprocessSignal=true;
            end

            if nargin<10
                updateTmModeFlag=true;
            end

            if nargin<11
                notifyFlag=true;
            end

            tsActual=ts*getTimeMultiplier(this,tsUnits);
            startTimeActual=startTime*getTimeMultiplier(this,startTimeUnits);

            for idx=1:length(signalIDs)
                sigID=signalIDs(idx);
                if removePreprocessSignal
                    removeAllAuxilarySignals(this,sigID);
                    resetActionNameThatCreatedSignal(this,sigID);
                else
                    removeDomainSignals(this,sigID);
                end
                clearResampledSignal(this,sigID);
                this.Engine.setSignalTmAvgSampleRate(int32(sigID),-1,false);

                if~isNewTsTimeMetadataEqual(this,sigID,ts,tsUnits,startTime,startTimeUnits)||forceUpdate



                    this.Engine.setSignalTmSampleTime(sigID,ts,false);
                    this.Engine.setSignalTmSampleTimeUnits(sigID,tsUnits,false);
                    this.Engine.setSignalTmStartTime(sigID,startTime,false);
                    this.Engine.setSignalTmStartTimeUnits(sigID,startTimeUnits,false);
                    if updateTmModeFlag
                        this.Engine.setSignalTmMode(sigID,'ts',notifyFlag);
                    end

                    if updateValuesFlag
                        updateSignalTimeValues(this,sigID,startTimeActual,tsActual,updateStruct);
                    else
                        numPoints=this.Engine.getSignalTmNumPoints(sigID);
                        endTime=startTimeActual+(numPoints-1)*tsActual;
                        this.Engine.setSignalTmTimeRange(sigID,[startTimeActual,endTime]);
                    end
                end
            end
        end


        function setTimeMetadataByTimeVector(this,signalIDs,timeVector,timeVectorStr,updateStruct,updateTmModeFlag,notifyFlag)

            if nargin<5
                updateStruct=[];
            end

            if nargin<6
                updateTmModeFlag=true;
            end

            if nargin<7
                notifyFlag=true;
            end



            needsResampling=checkIfSignalNeedsResampling(this,timeVector);
            avgSampleRate=getTimeVectorAvgSampleRate(this,timeVector,needsResampling);
            if~isempty(this.CurrentOkArgs)
                this.CurrentOkArgs.signalsNeedResampling=needsResampling;
            end


            for idx=1:length(signalIDs)
                sigID=signalIDs(idx);
                removeAllAuxilarySignals(this,sigID);
                resetActionNameThatCreatedSignal(this,sigID);
                if updateTmModeFlag
                    this.Engine.setSignalTmMode(sigID,'tv',notifyFlag);
                end
                this.Engine.setSignalTmTimeVectorStr(sigID,timeVectorStr);
                updateSignalTimeValuesForTimeVectorCase(this,sigID,timeVector,avgSampleRate,needsResampling,updateStruct,notifyFlag);
            end
        end


        function avgSampleRate=getTimeVectorAvgSampleRate(~,timeVector,needsResampling)
            avgSampleRate=signal.internal.utilities.getEffectiveFs(sort(timeVector),needsResampling);
        end


        function needsResampling=checkIfSignalNeedsResampling(~,tv)
            tv=sort(tv);
            needsResampling=signal.internal.utilities.isIrregular(tv);
        end


        function clearResampledSignal(this,sigID)


            signal.sigappsshared.SignalUtilities.removeResampledSignal(this.Engine,sigID);
        end


        function varargout=updateResampledSignal(this,sigID,sigData,varargin)

            [varargout{1:nargout}]=this.Engine.safeTransaction(@updateResampledSignalImpl,this,sigID,sigData,varargin{:});

            function needsResampling=updateResampledSignalImpl(this,sigID,sigData,needsResampling,avgSampleRate,notifyFlag)
                if isempty(sigData)
                    sigData=this.Engine.getSignalObject(sigID).Values;
                end



                if isempty(sigData.Data)
                    if nargin<4
                        needsResampling=[];
                    end
                    return;
                end

                if nargin<4||isempty(needsResampling)
                    needsResampling=checkIfSignalNeedsResampling(this,sigData.Time);
                end
                if nargin<5||isempty(avgSampleRate)
                    avgSampleRate=getTimeVectorAvgSampleRate(this,sigData.Time,needsResampling);
                end
                if nargin<6
                    notifyFlag=true;
                end

                resampledSignalID=this.Engine.getSignalTmResampledSigID(sigID);
                isResampledSignalExists=(resampledSignalID~=-1&&this.Engine.isValidSignalID(resampledSignalID));





                if(needsResampling)


                    [sResampled.Data,sResampled.Time]=resample(sigData.Data,sigData.Time,avgSampleRate,'linear');

                    if(isResampledSignalExists)
                        resampledSigObj=this.Engine.getSignalObject(int32(resampledSignalID));

                        resampledSigObj.Values=sResampled;
                        this.Engine.setSignalTmAvgSampleRate(int32(resampledSignalID),avgSampleRate,false);
                        this.Engine.setSignalTmAvgSampleRate(int32(sigID),avgSampleRate,notifyFlag);

                        this.Engine.setSignalTmNumPoints(resampledSignalID,length(sResampled.Time));
                        this.Engine.setSignalTmTimeRange(resampledSignalID,[sResampled.Time(1),sResampled.Time(end)]);

                        this.Engine.setSignalTmNumPoints(sigID,length(sigData.Time));
                        this.Engine.setSignalTmTimeRange(sigID,[sigData.Time(1),sigData.Time(end)]);

                    else

                        runID=this.Engine.getSignalRunID(sigID);
                        signalIDsBefore=this.Engine.getAllSignalIDs(int32(runID));
                        newVar=struct('VarName','','VarValue',[sResampled.Time(:),double(sResampled.Data(:))],'TimeSourceRule','siganalyzer');
                        wksParser=Simulink.sdi.internal.import.WorkspaceParser();
                        varParser=parseVariables(wksParser,newVar);
                        addToRun(wksParser,this.Engine,runID,varParser);
                        signalIDsAfter=this.Engine.getAllSignalIDs(int32(runID));
                        resampledSignalID=setdiff(signalIDsAfter,signalIDsBefore);
                        if length(resampledSignalID)==2



                            resampledSignalID=resampledSignalID(2);
                        end
                        this.Engine.setSignalTmResampledSigParentID(int32(resampledSignalID),int32(sigID));
                        this.Engine.setSignalTmAvgSampleRate(int32(resampledSignalID),avgSampleRate,false);
                        this.Engine.setSignalTmMode(int32(resampledSignalID),'resampled',false);
                        this.Engine.setSignalTmNumPoints(resampledSignalID,length(sResampled.Time));
                        this.Engine.setSignalTmTimeRange(resampledSignalID,[sResampled.Time(1),sResampled.Time(end)]);

                        this.Engine.setSignalTmResampledSigID(int32(sigID),int32(resampledSignalID));
                        this.Engine.setSignalTmAvgSampleRate(int32(sigID),avgSampleRate,notifyFlag);

                        this.Engine.setSignalTmNumPoints(sigID,length(sigData.Time));
                        this.Engine.setSignalTmTimeRange(sigID,[sigData.Time(1),sigData.Time(end)]);
                    end
                else


                    clearResampledSignal(this,sigID);
                    this.Engine.setSignalTmAvgSampleRate(int32(sigID),avgSampleRate,notifyFlag);
                    this.Engine.setSignalTmNumPoints(sigID,length(sigData.Time));
                    this.Engine.setSignalTmTimeRange(sigID,[sigData.Time(1),sigData.Time(end)]);
                end
            end
        end


        function[flag,errObj]=validateNonUniformTimeValues(~,tv)

            errObj='';

            flag=signal.sigappsshared.Utilities.validateNonUniformTimeValues(sort(tv));

            if~flag
                errObj=message('SDI:sigAnalyzer:InvalidNonUnifSampledTime');
            end
        end

        function notifyClientOfTimeMetadataChange(this,data)



            evt.data=data.eventData;
            evt.clientID=data.clientID;
            evt.tmMode=data.tmMode;
            evt.allSignalsWithTimeMetadataChange=this.AllSignalsWithTimeMetadataChange;
            evt.ResampledSigIDsForSignalsWithTimeMetadataChange=...
            zeros(length(evt.allSignalsWithTimeMetadataChange),1);
            for idx=1:length(evt.allSignalsWithTimeMetadataChange)
                sigID=evt.allSignalsWithTimeMetadataChange(idx);
                evt.ResampledSigIDsForSignalsWithTimeMetadataChange(idx)=...
                this.Engine.getSignalTmResampledSigID(sigID);
            end

            this.Dispatcher.publishToClient(evt.clientID,...
            'displayWidget',...
            'updateSignalTimeMetadata',...
            evt);
        end

        function y=isScalogramVisibleInDisplay(this,dispNum)
            y=false;
            if~isempty(this.CurrentOkArgs)&&isfield(this.CurrentOkArgs.data,'scalogramVisibilityPerDisplay')&&...
                isfield(this.CurrentOkArgs.data.scalogramVisibilityPerDisplay,['x',num2str(dispNum)])
                y=this.CurrentOkArgs.data.scalogramVisibilityPerDisplay.(['x',num2str(dispNum)]);
            end
        end

        function outStruct=checkCompatibilityWithDisplay(this,data)
            clientID=data.clientID;
            axes=getAxesByClientByID(this,clientID);
            L=length(axes);
            needToShowWarningDlg=false;

            newSignalTimeType=getTimeType(this,data.tmMode);

            signalsToUpdate=data.signalIDs;




            removeIdx=[];
            for idx=1:length(signalsToUpdate)
                if~this.Engine.getSignalChecked(signalsToUpdate(idx))
                    removeIdx=[removeIdx,idx];
                end
            end
            signalsToUpdate(removeIdx)=[];
            this.AllSignalsWithTimeMetadataChange=signalsToUpdate;


            displayList=cell(1,this.MaxNumAxes);
            for idx=1:L
                thisAxes=axes(idx);
                dispNum=this.getDisplayNumFromAxesNum(thisAxes.AxisID);
                displayList{dispNum}=unique([displayList{dispNum};thisAxes.DatabaseIDs(:)]);
            end

            numNonEmptyDisplays=sum(cellfun(@(x)~isempty(x),displayList));

            evt=repmat(struct(...
            'dispNum',-1,...
            'isCompatible',true,...
            'isCompatibleWithScalogram',true,...
            'signalsToUpdate',[],...
            'signalsToDelete',[],...
            'newUnitsUpdate',false,...
            'newUnits',''),numNonEmptyDisplays,1);

            idx=0;
            for dispNum=1:this.MaxNumAxes
                if isempty(displayList{dispNum})
                    continue;
                end
                idx=idx+1;

                evt(idx).dispNum=dispNum;


                signalsInDisplay=int32(displayList{dispNum});

                isSclogramVisbleInDisplay=this.isScalogramVisibleInDisplay(dispNum);






                removeIdx=[];
                resampledSignalsWithScalogram=[];
                for ii=1:numel(signalsInDisplay)
                    if~this.Engine.isValidSignalID(signalsInDisplay(ii))
                        removeIdx=[removeIdx,ii];
                        continue;
                    end
                    resampledSigParentID=this.Engine.getSignalTmResampledSigParentID(signalsInDisplay(ii));
                    if(resampledSigParentID~=-1)
                        signalsInDisplay(ii)=resampledSigParentID;
                    end
                end
                signalsInDisplay(removeIdx)=[];
                signalsInDisplay=unique(signalsInDisplay);


                signalsToUpdateFoundInDisplay=intersect(signalsToUpdate,signalsInDisplay);
                removeIdx=[];

                if(isSclogramVisbleInDisplay)
                    for jdx=1:numel(signalsToUpdateFoundInDisplay)

                        if(strcmp(data.tmMode,'tv')&&sum(this.AllSignalsWithTimeMetadataChange==signalsToUpdateFoundInDisplay(jdx)))
                            if isfield(data,'needsResampling')
                                needsResampling=data.needsResampling;
                            else
                                tv=this.CurrentTimeMetadataValues.tv;
                                needsResampling=checkIfSignalNeedsResampling(this,tv);
                            end
                            if needsResampling


                                resampledSignalsWithScalogram=[resampledSignalsWithScalogram,signalsToUpdateFoundInDisplay(jdx)];
                                removeIdx=[removeIdx,jdx];
                            end
                        end
                    end
                    signalsToUpdateFoundInDisplay(removeIdx)=[];
                    signalsToUpdateFoundInDisplay=unique(signalsToUpdateFoundInDisplay);
                end

                if isempty(signalsToUpdateFoundInDisplay)
                    evt(idx).isCompatible=true;
                else


                    plottedSigTmMode=this.Engine.getSignalTmMode(signalsToUpdateFoundInDisplay(1));
                    displayTimeType=getTimeType(this,plottedSigTmMode);
                    if(strcmp(displayTimeType,newSignalTimeType))


                        evt(idx).isCompatible=true;
                        evt(idx).signalsToUpdate=signalsToUpdateFoundInDisplay;
                    else



                        if isempty(setdiff(signalsInDisplay,signalsToUpdateFoundInDisplay))
                            evt(idx).isCompatible=true;
                            evt(idx).newUnitsUpdate=true;
                            evt(idx).newUnits=newSignalTimeType;
                            evt(idx).signalsToUpdate=signalsToUpdateFoundInDisplay;
                        else



                            evt(idx).isCompatible=false;
                            evt(idx).signalsToDelete=signalsToUpdateFoundInDisplay;
                            needToShowWarningDlg=true;
                        end
                    end
                end
                if(~isempty(resampledSignalsWithScalogram))


                    evt(idx).isCompatibleWithScalogram=false;
                    evt(idx).signalsToDelete=[evt(idx).signalsToDelete,resampledSignalsWithScalogram];
                    needToShowWarningDlg=true;
                end
            end
            outStruct.needToShowWarningDlg=needToShowWarningDlg;
            outStruct.evt=evt;
        end
    end



    properties
        Engine;
    end

    properties(Access=private)
        Dispatcher;
        CurrentOkArgs;
        CurrentEvent;
        CurrentTimeMetadataValues;
        ValidateVectorLengthFlag;
        AllSignalsWithTimeMetadataChange;
    end

    events
        treeSignalPropertyEvent;
propertyChangeEvent
    end

    properties(Constant)
        ControllerID='setTimeMetadataDialog';
        MaxNumAxes=64;
    end
end


function dataVect=getSignalsTimeMetadata(this,signalIDs)

    numSignals=length(signalIDs);
    dataVect=repmat(struct(...
    'SigID','',...
    'TmMode','',...
    'SampleRate',[],...
    'SampleRateUnits','',...
    'SampleTime',[],...
    'SampleTimeUnits','',...
    'StartTime',[],...
    'StartTimeUnits','',...
    'TimeVector',''),numSignals,1);

    eng=this.Engine;
    for idx=1:numSignals
        signalID=signalIDs(idx);
        dataVect(idx).SigID=signalID;
        dataVect(idx).TmMode=eng.getSignalTmMode(signalID);
        dataVect(idx).SampleRate=eng.getSignalTmSampleRate(signalID);
        dataVect(idx).SampleRateUnits=eng.getSignalTmSampleRateUnits(signalID);
        dataVect(idx).SampleTime=eng.getSignalTmSampleTime(signalID);
        dataVect(idx).SampleTimeUnits=eng.getSignalTmSampleTimeUnits(signalID);
        dataVect(idx).StartTime=eng.getSignalTmStartTime(signalID);
        dataVect(idx).StartTimeUnits=eng.getSignalTmStartTimeUnits(signalID);
        dataVect(idx).TimeVector=eng.getSignalTmTimeVectorStr(signalID);
    end
end


function outStruct=checkCompatibilityWithDisplays(this)






























    data=this.CurrentOkArgs.data;
    data.clientID=this.CurrentOkArgs.clientID;
    outStruct=this.checkCompatibilityWithDisplay(data);
end


