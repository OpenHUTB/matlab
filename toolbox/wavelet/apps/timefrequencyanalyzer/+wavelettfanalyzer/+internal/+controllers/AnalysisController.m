classdef AnalysisController<handle




    properties(Access=private)
Model
    end

    events

UpdateBoundaryLine
UpdateShadeRegion
UpdatePlot
CalculateAxes
CalculateAxesAndUpdatePlot
RenameAxes
DuplicateAxes

ClearStatusBar
UpdateStatusBar

UpdateTable
UpdateTableSelection
DeleteTableRow
RevertCellEdit
RenameTableSignal

UpdateToolstripTimeSettings
UpdateToolstripCWTParameters
UpdateMorseParamSettings
UpdateFrequencyLimits
RevertSampleRate
RevertVoices
RevertMinFrequency
RevertMaxFrequency
RevertSymmetry
RevertTimeBandwidthProduct
EnableComputeButton
DisableComputeButton
    end

    methods(Hidden)

        function this=AnalysisController(model)
            this.Model=model;
        end


        function cb_RenameSignal(this,args)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.show();
            newName=matlab.lang.makeValidName(args.NewData);
            if this.Model.signalExists(newName)
                this.alertNameExists();
                revertCellEditEventData.indices=args.DisplayIndices;
                revertCellEditEventData.name=args.PreviousData;
                this.notify("RevertCellEdit",wavelettfanalyzer.internal.EventData(revertCellEditEventData));
            else
                this.Model.renameSignal(args.PreviousData,newName);
                renameAxesEventData.oldName=args.PreviousData;
                renameAxesEventData.newName=newName;
                this.notify("RenameAxes",wavelettfanalyzer.internal.EventData(renameAxesEventData));
                if~strcmp(newName,args.NewData)
                    updateTableEventData.indices=args.DisplayIndices;
                    updateTableEventData.name=newName;
                    this.notify("RenameTableSignal",wavelettfanalyzer.internal.EventData(updateTableEventData));
                end
            end
            busyOverlay.hide();
        end

        function cb_DuplicateSignal(this)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.show();
            originalName=this.Model.getCurrentSignalName();
            copyName=originalName+"Copy";

            exists=this.Model.signalExists(copyName);
            if exists
                count=1;
                while(this.Model.signalExists(copyName+"_"+count))
                    count=count+1;
                end
                copyName=copyName+"_"+count;
            end

            this.Model.duplicateSignal(copyName);
            updateTableEventData.tableData=this.Model.getTableData(copyName);
            this.notify("UpdateTable",wavelettfanalyzer.internal.EventData(updateTableEventData));
            updateTableSelectionEventData.name=copyName;
            this.notify("UpdateTableSelection",wavelettfanalyzer.internal.EventData(updateTableSelectionEventData));
            duplicateAxesEventData.originalName=originalName;
            duplicateAxesEventData.duplicateName=copyName;
            this.notify("DuplicateAxes",wavelettfanalyzer.internal.EventData(duplicateAxesEventData));
            updatePlotEventData=this.Model.getUpdatePlotData();
            this.notify("UpdatePlot",wavelettfanalyzer.internal.EventData(updatePlotEventData));
            busyOverlay.hide();
        end

        function cb_DeleteSignal(this)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.show();
            name=this.Model.getCurrentSignalName();
            this.Model.deleteSignal();
            deleteTableRowEventData.name=name;
            this.notify("DeleteTableRow",wavelettfanalyzer.internal.EventData(deleteTableRowEventData));
            this.notify("ClearStatusBar");
            busyOverlay.hide();
        end

        function cb_TimeSettingsButtonChanged(this,args,buttonName,sampleRate,params)
            sampleRate=str2double(sampleRate);
            if args.EventData.NewValue==1
                busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
                busyOverlay.show();
                switch buttonName
                case "WorkInSamples"
                    if this.Model.getUseBackgroundPool()
                        bp=backgroundPool;
                        bkgpcwt=parfeval(bp,@()this.Model.updateTimeSettings(true,1),1);
                        afterEach(bkgpcwt,@(varargin)this.updateTimeSettingsComplete(params.waveletName,params.morseParams,varargin{:}),0);
                    else
                        info=this.Model.updateTimeSettings(true,1);
                        this.updateTimeSettingsComplete(params.waveletName,params.morseParams,info);
                    end
                case "SampleRate"
                    if this.Model.getUseBackgroundPool()
                        bp=backgroundPool;
                        bkgpcwt=parfeval(bp,@()this.Model.updateTimeSettings(false,sampleRate),1);
                        afterEach(bkgpcwt,@(varargin)this.updateTimeSettingsComplete(params.waveletName,params.morseParams,varargin{:}),0);
                    else
                        info=this.Model.updateTimeSettings(false,sampleRate);
                        this.updateTimeSettingsComplete(params.waveletName,params.morseParams,info);
                    end
                end
            end
        end

        function cb_SampleRateChanged(this,args,params)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.show();
            sampleRate=str2double(args.EventData.NewValue);
            if~this.Model.sampleRateIsValid(sampleRate)
                revertSampleRateEventData.value=args.EventData.OldValue;
                this.notify("RevertSampleRate",wavelettfanalyzer.internal.EventData(revertSampleRateEventData));
                busyOverlay.hide();
            else
                if this.Model.getUseBackgroundPool()
                    bp=backgroundPool;
                    bkgpcwt=parfeval(bp,@()this.Model.updateTimeSettings(false,sampleRate),1);
                    afterEach(bkgpcwt,@(varargin)this.updateTimeSettingsComplete(params.waveletName,params.morseParams,varargin{:}),0);
                else
                    info=this.Model.updateTimeSettings(false,sampleRate);
                    this.updateTimeSettingsComplete(params.waveletName,params.morseParams,info);
                end
            end
        end

        function cb_SeparatePlotsChanged(this,args)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.show();
            this.Model.setSeparatePlots(args.EventData.NewValue);
            if~this.Model.isEmpty()&&this.Model.getIsComplex(this.Model.getCurrentSignalName())
                updatePlotEventData=this.Model.getUpdatePlotData();
                this.notify("UpdatePlot",wavelettfanalyzer.internal.EventData(updatePlotEventData));
            end
            busyOverlay.hide();
        end

        function cb_BoundaryLineChanged(this,args)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.show();
            this.Model.setBoundaryLine(args.EventData.NewValue);
            if~this.Model.isEmpty()
                updatePlotEventData.value=args.EventData.NewValue;
                this.notify("UpdateBoundaryLine",wavelettfanalyzer.internal.EventData(updatePlotEventData));
            end
            busyOverlay.hide();
        end

        function cb_ShadeRegionChanged(this,args)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.show();
            this.Model.setShadeRegion(args.EventData.NewValue);
            if~this.Model.isEmpty()
                updatePlotEventData.value=args.EventData.NewValue;
                this.notify("UpdateShadeRegion",wavelettfanalyzer.internal.EventData(updatePlotEventData));
            end
            busyOverlay.hide();
        end

        function cb_WaveletChanged(this,args,params)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.show();

            if strcmp(params.waveletName,"morse")
                params.morseParams=[3,60];
            end

            morseParamEventData.waveletName=params.waveletName;
            this.notify("UpdateMorseParamSettings",wavelettfanalyzer.internal.EventData(morseParamEventData));
            oldParams=params;
            oldParams.waveletName=this.getWavelet(args.EventData.OldValue);
            this.updateFrequencyLimits(oldParams,params);
            this.notifyCWTParametersChanged();
            busyOverlay.hide();
        end

        function cb_VoicesChanged(this,args,params)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.show();
            if~this.Model.voicesIsValid(params.voices)
                revertVoicesEventData.value=args.EventData.OldValue;
                this.notify("RevertVoices",wavelettfanalyzer.internal.EventData(revertVoicesEventData));
            else
                oldParams=params;
                oldParams.voices=str2double(args.EventData.OldValue);
                this.updateFrequencyLimits(oldParams,params);
                this.notifyCWTParametersChanged();
            end
            busyOverlay.hide();
        end

        function cb_ExtendSignalChanged(this)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.show();
            this.notifyCWTParametersChanged();
            busyOverlay.hide();
        end

        function cb_FrequencyLimitsChanged(this,args,label,params)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.show();
            if strcmp(label,"min")&&~this.Model.freqLimsAreValid(params.freqLims)
                revertMinFrequencyEventData.value=args.EventData.OldValue;
                this.notify("RevertMinFrequency",wavelettfanalyzer.internal.EventData(revertMinFrequencyEventData));
            elseif strcmp(label,"max")&&~this.Model.freqLimsAreValid(params.freqLims)
                revertMaxFrequencyEventData.value=args.EventData.OldValue;
                this.notify("RevertMaxFrequency",wavelettfanalyzer.internal.EventData(revertMaxFrequencyEventData));
            else



                this.updateFrequencyLimits(params,params);
                this.notifyCWTParametersChanged();
            end
            busyOverlay.hide();
        end

        function cb_SymmetryChanged(this,args,params)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.show();
            if~this.Model.morseParamsAreValid(params.morseParams)
                revertSymmetryEventData.value=args.EventData.OldValue;
                this.notify("RevertSymmetry",wavelettfanalyzer.internal.EventData(revertSymmetryEventData));
            else
                oldParams=params;
                oldParams.morseParams(1)=str2double(args.EventData.OldValue);
                this.updateFrequencyLimits(oldParams,params);
                this.notifyCWTParametersChanged();
            end
            busyOverlay.hide();
        end

        function cb_TimeBandwidthProductChanged(this,args,params)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.show();
            if~this.Model.morseParamsAreValid(params.morseParams)
                revertTimeBandwidthProductEventData.value=args.EventData.OldValue;
                this.notify("RevertTimeBandwidthProduct",wavelettfanalyzer.internal.EventData(revertTimeBandwidthProductEventData));
            else
                oldParams=params;
                oldParams.morseParams(2)=str2double(args.EventData.OldValue);
                this.updateFrequencyLimits(oldParams,params);
                this.notifyCWTParametersChanged();
            end
            busyOverlay.hide();
        end

        function cb_ResetParameters(this)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.show();
            if this.Model.getUseBackgroundPool()
                bp=backgroundPool;
                bkgpcwt=parfeval(bp,@()this.Model.updateScalogramDefaultParams(),1);
                afterEach(bkgpcwt,@(varargin)this.resetParametersComplete(varargin{:}),0);
            else
                info=this.Model.updateScalogramDefaultParams();
                this.resetParametersComplete(info);
                this.notifyCWTParametersChanged();
            end
            busyOverlay.hide();
        end

        function cb_UpdateParameters(this,args)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.show();
            if this.Model.getUseBackgroundPool()
                bp=backgroundPool;
                bkgpcwt=parfeval(bp,@()this.Model.updateScalogram(args),1);
                afterEach(bkgpcwt,@(varargin)this.updateParametersComplete(varargin{:}),0);
            else
                info=this.Model.updateScalogram(args);
                this.updateParametersComplete(info);
            end
        end
    end

    methods(Access=protected)

        function alertNameExists(this)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.hide();
            dialog=wavelettfanalyzer.internal.Dialog.setGetDialog();
            dialogTitle=string(getString(message("wavelet_tfanalyzer:dialog:renameSignalDuplicateDialogTitle")));
            dialogMessage=string(getString(message("wavelet_tfanalyzer:dialog:renameSignalDuplicateDialogMessage")));
            dialog.showAlert(dialogTitle,dialogMessage);
        end

        function updateFrequencyLimits(this,oldParams,newParams)


            info=this.Model.getCWTInfo();
            defaultFreqLims=this.Model.getFrequencyBounds(info.length,info.sampleRate,oldParams.waveletName,oldParams.morseParams);
            if all(abs(defaultFreqLims-oldParams.freqLims)<1e-4)

                newFreqLims=this.Model.getFrequencyBounds(info.length,info.sampleRate,newParams.waveletName,newParams.morseParams);
            else

                [minFreq,maxFreq]=wavelet.internal.cwt.validFreqRange(info.length,info.sampleRate,newParams.freqLims(1),newParams.freqLims(2),...
                newParams.waveletName,newParams.morseParams,newParams.voices);
                newFreqLims=[minFreq,maxFreq];
            end
            updateFreqLimsData.freqLims=newFreqLims;
            this.notify("UpdateFrequencyLimits",wavelettfanalyzer.internal.EventData(updateFreqLimsData));
        end

        function notifyCWTParametersChanged(this)
            this.notify("EnableComputeButton");
            updateStatusBarEventData.status=string(getString(message("wavelet_tfanalyzer:wavelettfanalyzer:statusBarPending")));
            this.notify("UpdateStatusBar",wavelettfanalyzer.internal.EventData(updateStatusBarEventData));
        end

        function updateTimeSettingsComplete(this,waveletName,morseParams,varargin)
            info=varargin{1};
            this.Model.storeCWTInfo(info.name,info);

            newFreqLims=this.Model.getUpdatedFreqLimsSampleRateChanged(waveletName,morseParams);
            updateFreqLimsEventData.freqLims=newFreqLims;
            this.notify("UpdateFrequencyLimits",wavelettfanalyzer.internal.EventData(updateFreqLimsEventData));
            updateToolstripEventData=this.Model.getToolstripData();
            this.notify("UpdateToolstripTimeSettings",wavelettfanalyzer.internal.EventData(updateToolstripEventData));
            updateAxesEventData.calculateAxesData=info;
            updateAxesEventData.updatePlotData=this.Model.getUpdatePlotData();
            this.notify("CalculateAxesAndUpdatePlot",wavelettfanalyzer.internal.EventData(updateAxesEventData));
        end

        function resetParametersComplete(this,varargin)
            updateToolstripEventData=varargin{1};
            this.notify("UpdateToolstripCWTParameters",wavelettfanalyzer.internal.EventData(updateToolstripEventData));
        end

        function updateParametersComplete(this,varargin)
            info=varargin{1};
            this.Model.storeCWTInfo(info.name,info);
            this.notify("ClearStatusBar");
            this.notify("DisableComputeButton");
            updateAxesEventData.calculateAxesData=info;
            updateAxesEventData.updatePlotData=this.Model.getUpdatePlotData();
            this.notify("CalculateAxesAndUpdatePlot",wavelettfanalyzer.internal.EventData(updateAxesEventData));
        end

        function waveletName=getWavelet(this,value)
            switch(value)
            case 'Morse'
                waveletName="morse";
            case 'Morlet'
                waveletName="amor";
            case 'bump'
                waveletName="bump";
            end
        end
    end
end
