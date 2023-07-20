



classdef SimulationStepperDialog<handle




    properties(SetObservable=true)

        snapshotInterval=10;
        snapshotBufferSize=10;
        numberOfSteps=1;
        enablePauseTimes=false;
        pauseTimes='5';
        enableRollback=false;
        disableRollback=true;

        modelHandle='';
        dlgInstance={};
        propertyChangelistener=[];
        simStatusChangelistener=[];
        slToolStripOff=true;
    end

    methods
        function stepperDlg=SimulationStepperDialog(modelH)
            mlock;
            stepperDlg=stepperDlg@handle;
            stepperDlg.modelHandle=modelH;
            stepperDlg.propertyChangelistener=handle.listener(...
            DAStudio.EventDispatcher,...
            'PropertyChangedEvent',...
            {@refreshStepperDialog,stepperDlg});
            stepperDlg.simStatusChangelistener=handle.listener(...
            DAStudio.EventDispatcher,...
            'SimStatusChangedEvent',...
            {@refreshStepperDialog,stepperDlg});
            stepperDlg.slToolStripOff=false;
            copyModelParameters(stepperDlg);
        end



        function copyModelParameters(obj)

            modelH=obj.modelHandle;
            locSnapshotInterval=get_param(modelH,'SnapshotInterval');
            locSnapshotBufferSize=get_param(modelH,'SnapshotBufferSize');
            locNumberOfSteps=get_param(modelH,'NumberOfSteps');

            locEnablePauseTimes=get_param(modelH,'EnablePauseTimes');
            locEnableRollback=get_param(modelH,'EnableRollback');

            if locSnapshotInterval==-1
                obj.snapshotInterval='max';
            else
                obj.snapshotInterval=num2str(locSnapshotInterval);
            end
            if locSnapshotBufferSize==-1
                obj.snapshotBufferSize='max';
            else
                obj.snapshotBufferSize=num2str(locSnapshotBufferSize);
            end
            if locNumberOfSteps==-1
                obj.numberOfSteps='max';
            else
                obj.numberOfSteps=num2str(locNumberOfSteps);
            end
            if isequal(locEnablePauseTimes,'on')
                obj.enablePauseTimes=true;
            else
                obj.enablePauseTimes=false;
            end
            if isequal(locEnableRollback,'on')
                obj.enableRollback=true;
            else
                obj.enableRollback=false;
            end
            obj.disableRollback=...
            isequal(get_param(modelH,'SimulationRollbackCompliance'),...
            'noncompliant-fatal');

            obj.pauseTimes=get_param(modelH,'PauseTimes');
        end

        function showStepperDialog(obj)
            if isempty(obj.dlgInstance)
                obj.dlgInstance=DAStudio.Dialog(obj);
            else
                obj.dlgInstance.refresh;
                obj.dlgInstance.show;
            end
        end

        function deleteDialog(obj,~)
            if~isempty(obj.dlgInstance)
                delete(obj.dlgInstance);
                obj.dlgInstance=[];
            end
        end

        function closeStepperDialog(obj,~)
            obj.dlgInstance={};
        end

        function captureSnapshotCallback(obj,dlg)%#ok
            stepper=Simulink.SimulationStepper(obj.modelHandle);
            stepper.snapshot();
        end




        function enablePauseTimeCB(~,dlg,tag)
            dlg.setEnabled('pause_times_tag',dlg.getWidgetValue(tag));
        end




        function enableRollbackCB(~,dlg,tag)
            tags_to_toggle_enable={'snapshot_interval_tag',...
            'snapshot_interval_str_tag',...
            'snapshot_buffer_size_tag',...
            'snapshot_buffer_size_str_tag',...
            'snapshot_interval_str2_tag'};
            for idx=1:length(tags_to_toggle_enable)
                dlg.setEnabled(tags_to_toggle_enable{idx},...
                dlg.getWidgetValue(tag));
            end
        end


        function[status,msg]=simulationStepperDlgPreApplyCB(obj,dlg)








            function revertModelParams(widgetTagValueArray,mH)
                for id=1:length(widgetTagValueArray)
                    setVal=widgetValueToParamValue(obj.(widgetTagValueArray{id}{5}));



                    [~,internalVal]=isValidDataType(setVal,widgetTagValueArray{id}{3});
                    set_param(mH,widgetTagValueArray{id}{4},internalVal);

                    if(~ischar(setVal))
                        setVal=mat2str(setVal);
                    end
                    dlg.setWidgetValue(widgetTagValueArray{id}{1},setVal);
                end
            end


            copyModelParameters(obj);
            status=true;
            msg='';
            widgetTagValueArray={...
            {'snapshot_interval_tag',...
            'Simulink:studio:SnapshotInterval',...
            'PositiveInteger','SnapshotInterval',...
            'snapshotInterval'},...
            {'snapshot_buffer_size_tag',...
            'Simulink:studio:SnapshotBufferSize',...
            'PositiveInteger','SnapshotBufferSize',...
            'snapshotBufferSize'},...
            {'number_of_steps_tag','Simulink:studio:NumberOfSteps',...
            'PositiveInteger','NumberOfSteps','numberOfSteps'},...
            };
            if obj.slToolStripOff
                widgetTagValueArray{end+1}={...
                'pause_times_tag','Simulink:studio:PauseTimeValues',...
                'None','PauseTimes','pauseTimes'};
            end
            modelH=obj.modelHandle;






            for idx=1:length(widgetTagValueArray)
                tag=widgetTagValueArray{idx}{1};
                constraint=widgetTagValueArray{idx}{3};
                value=dlg.getWidgetValue(tag);
                name=widgetTagValueArray{idx}{2};
                [isValidType,newValue]=isValidDataType(value,constraint);
                if(~isValidType)
                    status=false;
                    msg=DAStudio.message(...
                    'Simulink:studio:StepperDialogInvalidInput',...
                    value,DAStudio.message(name));
                    revertModelParams(widgetTagValueArray,modelH);
                    return;
                else
                    try


                        param=widgetTagValueArray{idx}{4};
                        set_param(modelH,param,newValue);
                    catch E
                        status=false;
                        msg=E.message;
                        revertModelParams(widgetTagValueArray,modelH);
                        return;
                    end
                end
            end





            if obj.slToolStripOff
                tag='enable_pause_times_tag';
                pauseTimeVal=widgetValueToParamValue(dlg.getWidgetValue(tag));
                set_param(modelH,'EnablePauseTimes',pauseTimeVal);
            end

            tag='enable_rollback_tag';
            set_param(modelH,'EnableRollback',...
            widgetValueToParamValue(dlg.getWidgetValue(tag)));
        end

        function dlgstruct=getDialogSchema(obj)
















            copyModelParameters(obj);
            mdlName=get_param(obj.modelHandle,'Name');
            compliance=get_param(mdlName,'SimulationRollbackCompliance');







            wEnableRollback.Type='checkbox';
            wEnableRollback.ObjectProperty='enableRollback';
            wEnableRollback.ObjectMethod='enableRollbackCB';
            wEnableRollback.MethodArgs={'%dialog','%tag'};
            wEnableRollback.ArgDataTypes={'handle','string'};
            wEnableRollback.Mode=1;
            wEnableRollback.RowSpan=[2,2];
            wEnableRollback.ColSpan=[2,3];
            wEnableRollback.Tag='enable_rollback_tag';
            wEnableRollback.WidgetId='enable_rollback_widgetid';
            wEnableRollback.Alignment=1;
            wEnableRollback.Enabled=~obj.disableRollback;
            wEnableRollback.ToolTip=DAStudio.message(...
            'Simulink:Stepper:StepperToolTipEnableRollback');
            wEnableRollback.Name=DAStudio.message(...
            'Simulink:studio:SnapshotEnable');



            wSnapshotBufferSizeStr.Name=...
            ['      ',DAStudio.message('Simulink:studio:SnapshotBufferSize')];
            wSnapshotBufferSizeStr.Type='text';
            wSnapshotBufferSizeStr.RowSpan=[3,3];
            wSnapshotBufferSizeStr.ColSpan=[2,3];
            wSnapshotBufferSizeStr.Tag='snapshot_buffer_size_str_tag';
            wSnapshotBufferSizeStr.WidgetId='snapshot_buffer_size_str_widgetid';
            wSnapshotBufferSizeStr.ToolTip=DAStudio.message(...
            'Simulink:Stepper:StepperToolTipSnapshotBufferSize');
            wSnapshotBufferSizeStr.Alignment=1;
            wSnapshotBufferSizeStr.Enabled=obj.enableRollback;
            wSnapshotBufferSizeStr.Buddy='snapshot_buffer_size_tag';




            wSnapshotBufferSize.Type='edit';
            wSnapshotBufferSize.ObjectProperty='snapshotBufferSize';
            wSnapshotBufferSize.RowSpan=[3,3];
            wSnapshotBufferSize.ColSpan=[4,4];
            wSnapshotBufferSize.Tag='snapshot_buffer_size_tag';
            wSnapshotBufferSize.WidgetId='snapshot_buffer_size_widgetid';
            wSnapshotBufferSize.Alignment=6;
            wSnapshotBufferSize.Enabled=obj.enableRollback;
            wSnapshotBufferSize.ToolTip=DAStudio.message(...
            'Simulink:Stepper:StepperToolTipSnapshotBufferSize');


            wSnapshotIntervalStr.Name=...
            ['      ',DAStudio.message('Simulink:studio:SnapshotInterval')];
            wSnapshotIntervalStr.Type='text';
            wSnapshotIntervalStr.RowSpan=[4,4];
            wSnapshotIntervalStr.ColSpan=[2,3];
            wSnapshotIntervalStr.Tag='snapshot_interval_str_tag';
            wSnapshotIntervalStr.WidgetId='snapshot_interval_str_widgetid';
            wSnapshotIntervalStr.Enabled=obj.enableRollback;
            wSnapshotIntervalStr.ToolTip=DAStudio.message(...
            'Simulink:Stepper:StepperToolTipSnapshotInterval');
            wSnapshotIntervalStr.Buddy='snapshot_interval_tag';



            wSnapshotInterval.Type='edit';
            wSnapshotInterval.ObjectProperty='snapshotInterval';
            wSnapshotInterval.RowSpan=[4,4];
            wSnapshotInterval.ColSpan=[4,4];
            wSnapshotInterval.Tag='snapshot_interval_tag';
            wSnapshotInterval.WidgetId='snapshot_interval_widgetid';
            wSnapshotInterval.Alignment=6;
            wSnapshotInterval.Enabled=obj.enableRollback;
            wSnapshotInterval.ToolTip=DAStudio.message(...
            'Simulink:Stepper:StepperToolTipSnapshotInterval');

            wSnapshotIntervalStr2.Name=...
            DAStudio.message('Simulink:studio:Steps');
            wSnapshotIntervalStr2.Type='text';
            wSnapshotIntervalStr2.RowSpan=[4,4];
            wSnapshotIntervalStr2.ColSpan=[5,5];
            wSnapshotIntervalStr2.Tag='snapshot_interval_str2_tag';
            wSnapshotIntervalStr2.WidgetId='snapshot_interval_str2_widgetid';
            wSnapshotIntervalStr2.Enabled=obj.enableRollback;
            wSnapshotIntervalStr2.ToolTip=DAStudio.message(...
            'Simulink:Stepper:StepperToolTipSnapshotInterval');






















            wNumberOfStepsStr.Name=...
            DAStudio.message('Simulink:studio:NumberOfSteps');
            wNumberOfStepsStr.Type='text';
            wNumberOfStepsStr.RowSpan=[7,7];
            wNumberOfStepsStr.ColSpan=[2,3];
            wNumberOfStepsStr.Tag='number_of_steps_str_tag';
            wNumberOfStepsStr.WidgetId='number_of_steps_str_widgetid';
            wNumberOfStepsStr.Alignment=1;
            wNumberOfStepsStr.ToolTip=DAStudio.message(...
            'Simulink:Stepper:StepperToolTipNumberOfSteps');
            wNumberOfStepsStr.Buddy='number_of_steps_tag';





            wNumberOfSteps.Type='edit';
            wNumberOfSteps.ObjectProperty='numberOfSteps';
            wNumberOfSteps.RowSpan=[7,7];
            wNumberOfSteps.ColSpan=[4,4];
            wNumberOfSteps.Tag='number_of_steps_tag';
            wNumberOfSteps.WidgetId='number_of_steps_widgetid';
            wNumberOfSteps.Alignment=6;
            wNumberOfSteps.ToolTip=DAStudio.message(...
            'Simulink:Stepper:StepperToolTipNumberOfSteps');

            wNumberOfStepsStr2.Name=...
            DAStudio.message('Simulink:studio:Steps');
            wNumberOfStepsStr2.Type='text';
            wNumberOfStepsStr2.RowSpan=[7,7];
            wNumberOfStepsStr2.ColSpan=[5,5];
            wNumberOfStepsStr2.Tag='number_of_steps_str2_tag';
            wNumberOfStepsStr2.WidgetId='number_of_steps_str2_widgetid';
            wNumberOfStepsStr2.ToolTip=DAStudio.message(...
            'Simulink:Stepper:StepperToolTipNumberOfSteps');























            if obj.slToolStripOff
                wEnablePauseTime.Type='checkbox';
                wEnablePauseTime.ObjectProperty='enablePauseTimes';
                wEnablePauseTime.ObjectMethod='enablePauseTimeCB';
                wEnablePauseTime.MethodArgs={'%dialog','%tag'};
                wEnablePauseTime.ArgDataTypes={'handle','string'};
                wEnablePauseTime.Mode=1;
                wEnablePauseTime.RowSpan=[10,10];
                wEnablePauseTime.ColSpan=[2,3];
                wEnablePauseTime.Alignment=1;
                wEnablePauseTime.Tag='enable_pause_times_tag';
                wEnablePauseTime.WidgetId='enable_pause_times_widgetid';
                wEnablePauseTime.ToolTip=DAStudio.message(...
                'Simulink:Stepper:StepperToolTipEnablePauseTimes');
                wEnablePauseTime.Name=...
                DAStudio.message('Simulink:studio:PauseTimeValues');



                wPauseTime.Type='edit';
                wPauseTime.ObjectProperty='pauseTimes';
                wPauseTime.RowSpan=[10,10];
                wPauseTime.ColSpan=[4,4];
                wPauseTime.Enabled=obj.enablePauseTimes;
                wPauseTime.Alignment=6;
                wPauseTime.Tag='pause_times_tag';
                wPauseTime.WidgetId='pause_times_widgetid';
                wPauseTime.ToolTip=DAStudio.message(...
                'Simulink:Stepper:StepperToolTipPauseTimes');
            end



















            gHorizLine1.Type='group';
            gHorizLine1.Flat=true;
            gHorizLine1.RowSpan=[6,6];
            gHorizLine1.ColSpan=[2,5];
            gHorizLine1.Items={};

            if obj.slToolStripOff
                gHorizLine2.Type='group';
                gHorizLine2.Flat=true;
                gHorizLine2.RowSpan=[9,9];
                gHorizLine2.ColSpan=[2,5];
                gHorizLine2.Items={};
            end


            wBlank.Type='text';
            wBlank.Name='  ';
            wBlank.RowSpan=[5,5];
            wBlank.ColSpan=[1,6];









            wBlank3.Type='text';
            wBlank3.Name='   ';
            wBlank3.RowSpan=[8,8];
            wBlank3.ColSpan=[1,1];


            wBlank4.Type='text';
            wBlank4.Name='   ';
            wBlank4.RowSpan=[8,8];
            wBlank4.ColSpan=[6,6];


            wBlank5.Type='text';
            wBlank5.Name='  ';
            wBlank5.RowSpan=[1,1];
            wBlank5.ColSpan=[2,4];

            if obj.slToolStripOff
                wBlank6.Type='text';
                wBlank6.Name='  ';
                wBlank6.RowSpan=[11,11];
                wBlank6.ColSpan=[2,4];


                wBlank7.Type='text';
                wBlank7.Name='  ';
                wBlank7.RowSpan=[3,4];
                wBlank7.ColSpan=[2,2];
            end


            dlgstruct.LayoutGrid=[11,6];

            items={wEnableRollback,wSnapshotBufferSize,wSnapshotInterval,...
            wSnapshotBufferSizeStr,...
            wSnapshotIntervalStr,...
            wSnapshotIntervalStr2,wNumberOfSteps,wNumberOfStepsStr,...
            wNumberOfStepsStr2};


            if obj.slToolStripOff
                items=cat(2,items,{wEnablePauseTime,wPauseTime});
            end
            if(ispc)
                items=cat(2,items,{gHorizLine1,wBlank,wBlank3,wBlank4,wBlank5});



                if obj.slToolStripOff
                    items=cat(2,items,{gHorizLine2,wBlank6,wBlank7});
                end
            else

                items=cat(2,items,{wBlank,wBlank3,wBlank4,wBlank5});

                if obj.slToolStripOff
                    items=cat(2,items,{wBlank6});
                end
            end
            dlgstruct.Items=items;
            dlgstruct.DialogTitle=...
            DAStudio.message('Simulink:studio:SteppingOptions',mdlName);

            dlgstruct.SmartApply=0;
            dlgstruct.PreApplyCallback='simulationStepperDlgPreApplyCB';
            dlgstruct.PreApplyArgs={'%source','%dialog'};


            dlgstruct.CloseMethod='closeStepperDialog';
            dlgstruct.CloseMethodArgs={'%closeaction'};
            dlgstruct.CloseMethodArgsDT={'string'};
            dlgstruct.DialogCSHTag='SimulationStepperDialog';
            dlgstruct.HelpMethod='helpview';
            dlgstruct.HelpArgs={fullfile(docroot,'simulink',...
            'helptargets.map'),'SimStepper','CSHelpWindow'};
        end






        function dt=getPropDataType(~,propName)
            switch(propName)
            case{'enableRollback','enablePauseTimes'}
                dt='bool';
            case{'snapshotBufferSize','snapshotInterval','numberOfSteps'}
                dt='double';
            case{'pauseTimes'}
                dt='string';
            otherwise
                dt='invalid';
            end

        end

        function registerDAListeners(obj)
            bd=get_param(obj.modelHandle,'Object');
            bd.registerDAListeners;
        end

    end
end




function paramValue=widgetValueToParamValue(widgetValue)
    if islogical(widgetValue)
        if widgetValue
            paramValue='on';
        else
            paramValue='off';
        end
    else
        paramValue=widgetValue;
    end
end




function[isValid,dblValue]=isValidDataType(value,dataTypeConstraint)
    switch(dataTypeConstraint)
    case 'Float',
        dblValue=str2double(value);
        isValid=~isnan(dblValue);
    case 'NonNegativeFloat',
        dblValue=str2double(value);
        isValid=~(isnan(dblValue)||dblValue<0);
    case 'PositiveInteger',
        if strcmpi(value,'max')
            isValid=true;
            dblValue=-1;
            return;
        end
        dblValue=str2double(value);
        isValid=~(isnan(dblValue)||dblValue<=0||...
        (dblValue~=round(dblValue)));
    case 'FloatVector',
        isValid=true;
        try
            dblValues=eval(value);
        catch E %#ok  
            isValid=false;
            return;
        end
        bdlValSizes=size(dblValues);
        if(max(bdlValSizes)~=numel(dblValues))
            isValid=false;
        end
        if any(isnan(dblValues))||any(dblValues<0)||~all(isreal(dblValues))
            isValid=false;
        end
    otherwise,
        isValid=true;
        dblValue=value;
    end
end

function refreshStepperDialog(~,~,obj)
    if~isempty(obj.dlgInstance)
        obj.dlgInstance.refresh;
    end
end


