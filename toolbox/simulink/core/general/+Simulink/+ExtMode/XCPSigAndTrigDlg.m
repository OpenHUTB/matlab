classdef XCPSigAndTrigDlg<handle
















    properties(Access=public)



        m_ctrlPanel=[];












        m_ExtModeLogAll;
        m_ExtModeTrigType;
        m_ExtModeTrigMode;
        m_ExtModeTrigDuration;
        m_ExtModeTrigDelay;
        m_ExtModeTrigLevel;
        m_ExtModeTrigHoldOff;
        m_ExtModeTrigDirection;
        m_ExtModeArmWhenConnect;
        m_ExtModeTrigSignalBlockPath;
        m_ExtModeTrigSignalOutputPortIndex;
        m_ExtModeSendContiguousSamples;






        m_instrumentedSignalData;
        m_modelLoggingInfo;






        m_initialRadioButtonValue;
        m_singleSelectionInTable;





        m_theDialog=[];
        m_theDialogPos=[];
    end

    properties(Access=public)










        m_Source_Manual='manual';
        m_Source_Manual_Index=0;
        m_Source_Signal='signal';
        m_Source_Signal_Index=1;
        m_sourceEntries={DAStudio.message('Simulink:dialog:ExtModeManual')...
        ,DAStudio.message('Simulink:dialog:ExtModeSignal')};

        m_Mode_OneShot='oneshot';
        m_Mode_OneShot_Index=0;
        m_Mode_Normal='normal';
        m_Mode_Normal_Index=1;
        m_modeEntries={DAStudio.message('Simulink:dialog:ExtModeOneShot')...
        ,DAStudio.message('Simulink:dialog:ExtModeNormal')};

        m_Direction_Rising='rising';
        m_Direction_Rising_Index=0;
        m_Direction_Falling='falling';
        m_Direction_Falling_Index=1;
        m_Direction_Either='either';
        m_Direction_Either_Index=2;
        m_directionEntries={DAStudio.message('Simulink:dialog:ExtModeRising')...
        ,DAStudio.message('Simulink:dialog:ExtModeFalling')...
        ,DAStudio.message('Simulink:dialog:ExtModeEither')};

        m_Radio_On='on';
        m_Radio_On_Index=0;
        m_Radio_Off='off';
        m_Radio_Off_Index=1;
        m_radioEntries={DAStudio.message('Simulink:dialog:ExtModeOn')...
        ,DAStudio.message('Simulink:dialog:ExtModeOff')};
    end

    properties(Constant,Access=public)



        m_EMSTD_Dialog_Tag='XCPExtModeSigAndTrigDlg_Dialog_Tag';
        m_EMSTD_SelectionTable_Tag='XCPExtModeSigAndTrigDlg_SelectionTable_Tag';
        m_EMSTD_SelectAll_Tag='XCPExtModeSigAndTrigDlg_SelectAll_Tag';
        m_EMSTD_ClearAll_Tag='XCPExtModeSigAndTrigDlg_ClearAll_Tag';
        m_EMSTD_SelectionRadioButton_Tag='XCPExtModeSigAndTrigDlg_SelectionRadioButton_Tag';
        m_EMSTD_HiddenCheckbox_Tag='XCPExtModeSigAndTrigDlg_HiddenCheckbox_Tag';
        m_EMSTD_TriggerSignalButton_Tag='XCPExtModeSigAndTrigDlg_TriggerSignalButton_Tag';
        m_EMSTD_GotoSignal_Tag='XCPExtModeSigAndTrigDlg_GotoSignal_Tag';
        m_EMSTD_SignalSelectionGroup_Tag='XCPExtModeSigAndTrigDlg_SignalSelectionGroup_Tag';
        m_EMSTD_Source_Tag='XCPExtModeSigAndTrigDlg_Source_Tag';
        m_EMSTD_Mode_Tag='XCPExtModeSigAndTrigDlg_Mode_Tag';
        m_EMSTD_Duration_Tag='XCPExtModeSigAndTrigDlg_Duration_Tag';
        m_EMSTD_Delay_Tag='XCPExtModeSigAndTrigDlg_Delay_Tag';
        m_EMSTD_ArmWhenConnect_Tag='XCPExtModeSigAndTrigDlg_ArmWhenConnect_Tag';
        m_EMSTD_UsePackedMode_Tag='XCPExtModeSigAndTrigDlg_UsePackedMode_Tag';
        m_EMSTD_TriggerGroup_Tag='XCPExtModeSigAndTrigDlg_TriggerGroup_Tag';
        m_EMSTD_Direction_Tag='XCPExtModeSigAndTrigDlg_Direction_Tag';
        m_EMSTD_Level_Tag='XCPExtModeSigAndTrigDlg_Level_Tag';
        m_EMSTD_HoldOff_Tag='XCPExtModeSigAndTrigDlg_HoldOff_Tag';
        m_EMSTD_TriggerSignalGroup_Tag='XCPExtModeSigAndTrigDlg_TriggerSignalGroup_Tag';
    end









    methods(Access={?Simulink.ExtMode.CtrlPanel})
        function obj=XCPSigAndTrigDlg(parent)
            obj.m_ctrlPanel=parent;
            obj.showDialog();
        end

        function showDialog(obj)











            if isempty(obj.m_theDialog)



                bd=obj.getModelName();



                obj.m_modelLoggingInfo=coder.internal.xcp.getModelLoggingInfo(bd);





                if strcmp(obj.m_modelLoggingInfo.LoggingMode,'LogAllAsSpecifiedInModel')
                    obj.m_ExtModeLogAll='on';
                else
                    obj.m_ExtModeLogAll='off';
                end

                obj.m_ExtModeTrigType=get_param(bd,'ExtModeTrigType');
                obj.m_ExtModeTrigMode=get_param(bd,'ExtModeTrigMode');
                obj.m_ExtModeTrigDuration=get_param(bd,'ExtModeTrigDuration');
                obj.m_ExtModeTrigDelay=get_param(bd,'ExtModeTrigDelay');
                obj.m_ExtModeTrigLevel=get_param(bd,'ExtModeTrigLevel');
                obj.m_ExtModeTrigHoldOff=get_param(bd,'ExtModeTrigHoldOff');
                obj.m_ExtModeTrigDirection=get_param(bd,'ExtModeTrigDirection');
                obj.m_ExtModeArmWhenConnect=get_param(bd,'ExtModeArmWhenConnect');
                obj.m_ExtModeTrigSignalBlockPath=get_param(bd,'ExtModeTrigSignalBlockPath');
                obj.m_ExtModeTrigSignalOutputPortIndex=get_param(bd,'ExtModeTrigSignalOutputPortIndex');
                obj.m_ExtModeSendContiguousSamples=get_param(bd,'ExtModeSendContiguousSamples');




                obj.m_instrumentedSignalData=obj.getInstrumentedSignalDataFromModel();




                obj.m_initialRadioButtonValue=obj.m_Radio_Off_Index;
                if obj.isSelectAllChecked()||isempty(obj.m_instrumentedSignalData)||obj.m_instrumentedSignalData(1).selected
                    obj.m_initialRadioButtonValue=obj.m_Radio_On_Index;
                end






                obj.m_singleSelectionInTable=true;




                obj.m_theDialog=DAStudio.Dialog(obj);
                assert(~isempty(obj.m_theDialog));
                if~isempty(obj.m_theDialogPos)
                    obj.m_theDialog.position=obj.m_theDialogPos;
                end









                rowIdx=obj.m_theDialog.getSelectedTableRows(obj.m_EMSTD_SelectionTable_Tag);
                obj.m_singleSelectionInTable=(length(rowIdx)==1);
                obj.refreshDialogEnables()
            end





            obj.m_theDialog.show;
        end
    end




    methods(Access={?Simulink.ExtMode.CtrlPanel})
        function modelName=getModelName(obj)
            modelName=obj.m_ctrlPanel.getModelName();
        end

        function title=createDialogTitle(obj)
            title=DAStudio.message('Simulink:dialog:ExtModeSigAndTrigDlgTitle',obj.getModelName());
        end
        function setDialogTitle(obj,title)
            if~isempty(obj.m_theDialog)
                obj.m_theDialog.setTitle(title);
            end
        end

        function deleteDialog(obj)
            if~isempty(obj.m_theDialog)
                obj.m_theDialogPos=obj.m_theDialog.position;
                obj.m_theDialog.delete;
                obj.m_theDialog=[];
            end
        end

        function val=isSelectAllChecked(obj)
            val=slprivate('onoff',obj.m_ExtModeLogAll);
        end

        function val=getUploadBlockDataForSelectedBlocksInTable(obj)
            val=[];
            rowIdxs=obj.m_theDialog.getSelectedTableRows(obj.m_EMSTD_SelectionTable_Tag);
            if~isempty(rowIdxs)
                val=obj.m_instrumentedSignalData(rowIdxs+1);
            end
        end

        function enableApplyButton(obj)
            val=obj.m_theDialog.getWidgetValue(obj.m_EMSTD_HiddenCheckbox_Tag);
            obj.m_theDialog.setWidgetValue(obj.m_EMSTD_HiddenCheckbox_Tag,~val);
        end

        function val=isExtModeUploadStatusInactive(obj)
            val=strcmp(get_param(obj.getModelName(),'ExtModeUploadStatus'),'inactive');
        end

        function val=isExtModeStatusDisconnected(obj)
            val=strcmp(get_param(obj.getModelName(),'SimulationStatus'),'stopped')||...
            strcmp(get_param(obj.getModelName(),'SimulationStatus'),'terminating');
        end

        function idx=radioButtonValueToIndex(obj,val)
            if strcmp(val,obj.m_Radio_On)
                idx=obj.m_Radio_On_Index;
            elseif strcmp(val,obj.m_Radio_Off)
                idx=obj.m_Radio_Off_Index;
            else
                assert(false);
            end
        end

        function val=radioButtonIndexToValue(obj,idx)
            if idx==obj.m_Radio_On_Index
                val=obj.m_Radio_On;
            elseif idx==obj.m_Radio_Off_Index
                val=obj.m_Radio_Off;
            else
                assert(false);
            end
        end

        function setRadioButtonValue(obj)
            val=obj.radioButtonValueToIndex(obj.m_Radio_Off);
            if obj.isSelectAllChecked()||isempty(obj.m_instrumentedSignalData)
                val=obj.radioButtonValueToIndex(obj.m_Radio_On);
            else
                data=obj.getUploadBlockDataForSelectedBlocksInTable();
                if all([data.selected])&&data(1).selected
                    val=obj.radioButtonValueToIndex(obj.m_Radio_On);
                end
            end
            obj.m_theDialog.setWidgetValue(obj.m_EMSTD_SelectionRadioButton_Tag,val);
        end

        function idx=sourceValueToIndex(obj,val)
            if strcmp(val,obj.m_Source_Manual)
                idx=obj.m_Source_Manual_Index;
            elseif strcmp(val,obj.m_Source_Signal)
                idx=obj.m_Source_Signal_Index;
            else
                assert(false);
            end
        end

        function val=sourceIndexToValue(obj,idx)
            if idx==obj.m_Source_Manual_Index
                val=obj.m_Source_Manual;
            elseif idx==obj.m_Source_Signal_Index
                val=obj.m_Source_Signal;
            else
                assert(false);
            end
        end

        function val=isTriggerSourceManual(obj)
            val=strcmp(obj.m_ExtModeTrigType,obj.m_Source_Manual);
        end

        function idx=modeValueToIndex(obj,val)
            if strcmp(val,obj.m_Mode_OneShot)
                idx=obj.m_Mode_OneShot_Index;
            elseif strcmp(val,obj.m_Mode_Normal)
                idx=obj.m_Mode_Normal_Index;
            else
                assert(false);
            end
        end

        function val=modeIndexToValue(obj,idx)
            if idx==obj.m_Mode_OneShot_Index
                val=obj.m_Mode_OneShot;
            elseif idx==obj.m_Mode_Normal_Index
                val=obj.m_Mode_Normal;
            else
                assert(false);
            end
        end

        function idx=directionValueToIndex(obj,val)
            if strcmp(val,obj.m_Direction_Rising)
                idx=obj.m_Direction_Rising_Index;
            elseif strcmp(val,obj.m_Direction_Falling)
                idx=obj.m_Direction_Falling_Index;
            elseif strcmp(val,obj.m_Direction_Either)
                idx=obj.m_Direction_Either_Index;
            else
                assert(false);
            end
        end

        function val=directionIndexToValue(obj,idx)
            if idx==obj.m_Direction_Rising_Index
                val=obj.m_Direction_Rising;
            elseif idx==obj.m_Direction_Falling_Index
                val=obj.m_Direction_Falling;
            elseif idx==obj.m_Direction_Either_Index
                val=obj.m_Direction_Either;
            else
                assert(false);
            end
        end
    end




    methods(Access=public)
        function signals=findAllInstrumentedSignals(obj)

            signals=struct('BlockPath',{},...
            'OutputPortIndex',{},...
            'DataLogging',{},...
            'ModelLoggingIndex',{});


            for i=length(obj.m_modelLoggingInfo.Signals):-1:1
                sig=struct('BlockPath',obj.m_modelLoggingInfo.Signals(i).BlockPath,...
                'OutputPortIndex',obj.m_modelLoggingInfo.Signals(i).OutputPortIndex,...
                'DataLogging',obj.m_modelLoggingInfo.Signals(i).LoggingInfo.DataLogging,...
                'ModelLoggingIndex',i);
                signals(i)=sig;
            end
        end

        function instrumentedSignalsData=getInstrumentedSignalDataFromModel(obj)
            instrumentedSignalsData=struct('trigger',{},'selected',{},...
            'dispName',{},'dispSourcePort',{},'BlockPath',{},...
            'blkPath',{},'blkOutputPortIndex',{},'ModelLoggingIndex',{});

            signals=obj.findAllInstrumentedSignals();


            for i=length(signals):-1:1
                signal=signals(i);

                blockPath=signal.BlockPath.toPipePath;
                outputPortIndex=signal.OutputPortIndex;

                dispName='';
                if signal.BlockPath.getLength()>=1


                    relativeBlockPath=signal.BlockPath.getBlock(signal.BlockPath.getLength());
                    blockHandle=get_param(relativeBlockPath,'Handle');
                    portHandles=get_param(blockHandle,'PortHandles');
                    lineHandle=get(portHandles.Outport(outputPortIndex),'Line');
                    dispName=get_param(lineHandle,'Name');
                end

                dispName=strrep(dispName,newline,' ');
                dispSourcePort=sprintf('%s:%d',blockPath,outputPortIndex);




                trig=false;

                if strcmp(obj.m_ExtModeTrigSignalBlockPath,blockPath)&&...
                    (obj.m_ExtModeTrigSignalOutputPortIndex==outputPortIndex)
                    trig=true;
                end




                selected=signal.DataLogging;




                data=struct('trigger',trig,'selected',selected,'dispName',dispName,'dispSourcePort',dispSourcePort,...
                'BlockPath',signal.BlockPath,...
                'blkPath',blockPath,'blkOutputPortIndex',signal.OutputPortIndex,...
                'ModelLoggingIndex',signal.ModelLoggingIndex);
                instrumentedSignalsData(i)=data;
            end
        end

        function instrumentedSignalsSelectionData=getInstrumentedSignalsSelectionTableData(obj,instrumentedSignalData)
            instrumentedSignalsSelectionData=cell(length(instrumentedSignalData),4);
            for i=1:length(instrumentedSignalData)
                trig=' ';
                if instrumentedSignalData(i).trigger
                    trig='T';
                end

                selected=' ';
                if strcmp(obj.m_ExtModeLogAll,'on')||instrumentedSignalData(i).selected
                    selected='X';
                end
                instrumentedSignalsSelectionData{i,1}=trig;
                instrumentedSignalsSelectionData{i,2}=selected;
                instrumentedSignalsSelectionData{i,3}=instrumentedSignalData(i).dispName;
                instrumentedSignalsSelectionData{i,4}=instrumentedSignalData(i).dispSourcePort;
            end
        end
    end




    methods(Access=public)
        function enabled=instrumentedSignalsSelectionTableEnabled(obj)
            enabled=obj.isExtModeStatusDisconnected();
        end
        function enabled=selectAllCheckboxEnabled(obj)
            enabled=obj.isExtModeStatusDisconnected();
        end
        function enabled=clearAllCheckboxEnabled(obj)
            enabled=obj.isExtModeStatusDisconnected()&&...
            ~obj.isSelectAllChecked()&&...
            ~isempty(obj.m_instrumentedSignalData);
        end
        function enabled=selectionRadioButtonEnabled(obj)
            enabled=obj.isExtModeStatusDisconnected()&&...
            ~obj.isSelectAllChecked()&&...
            ~isempty(obj.m_instrumentedSignalData);
        end
        function enabled=triggerSignalButtonEnabled(obj)
            enabled=obj.isExtModeStatusDisconnected()&&...
            obj.m_singleSelectionInTable;
        end
        function enabled=gotoSignalButtonEnabled(obj)
            enabled=obj.isExtModeStatusDisconnected()&&...
            obj.m_singleSelectionInTable;
        end
        function enabled=triggerSourceComboboxEnabled(obj)
            enabled=obj.isExtModeUploadStatusInactive();
        end
        function enabled=triggerModeComboboxEnabled(obj)
            enabled=obj.isExtModeUploadStatusInactive();
        end
        function enabled=triggerDurationEditEnabled(obj)

            if coder.internal.connectivity.featureOn('XcpPackedMode')&&...
                slprivate('onoff',obj.m_ExtModeSendContiguousSamples)
                enabled=obj.isExtModeStatusDisconnected();
            else
                enabled=obj.isExtModeUploadStatusInactive();
            end
        end
        function enabled=triggerDelayEditEnabled(obj)
            enabled=obj.isExtModeUploadStatusInactive();
        end
        function enabled=armWhenConnectCheckboxEnabled(obj)
            enabled=obj.isExtModeUploadStatusInactive();
        end
        function enabled=usePackedModeCheckboxEnabled(obj)
            enabled=obj.isExtModeStatusDisconnected();
        end
        function enabled=triggerSignalDirectionComboboxEnabled(obj)
            enabled=obj.isExtModeUploadStatusInactive()&&...
            ~obj.isTriggerSourceManual();
        end
        function enabled=triggerSignalLevelEditEnabled(obj)
            enabled=obj.isExtModeUploadStatusInactive()&&...
            ~obj.isTriggerSourceManual();
        end
        function enabled=triggerSignalHoldOffEditEnabled(obj)
            enabled=obj.isExtModeUploadStatusInactive()&&...
            ~obj.isTriggerSourceManual();
        end

        function refreshDialogEnables(obj)
            obj.m_theDialog.setEnabled(obj.m_EMSTD_SelectionTable_Tag,obj.instrumentedSignalsSelectionTableEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_SelectAll_Tag,obj.selectAllCheckboxEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_ClearAll_Tag,obj.clearAllCheckboxEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_SelectionRadioButton_Tag,obj.selectionRadioButtonEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_TriggerSignalButton_Tag,obj.triggerSignalButtonEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_GotoSignal_Tag,obj.gotoSignalButtonEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_Source_Tag,obj.triggerSourceComboboxEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_Mode_Tag,obj.triggerModeComboboxEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_Duration_Tag,obj.triggerDurationEditEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_Delay_Tag,obj.triggerDelayEditEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_ArmWhenConnect_Tag,obj.armWhenConnectCheckboxEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_UsePackedMode_Tag,obj.usePackedModeCheckboxEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_Direction_Tag,obj.triggerSignalDirectionComboboxEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_Level_Tag,obj.triggerSignalLevelEditEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_HoldOff_Tag,obj.triggerSignalHoldOffEditEnabled());
        end
    end




    methods(Access=public)
        function selectionTableCB(obj,~,~,~)








            obj.setRadioButtonValue();

            rowIdx=obj.m_theDialog.getSelectedTableRows(obj.m_EMSTD_SelectionTable_Tag);
            obj.m_singleSelectionInTable=(length(rowIdx)==1);

            obj.refreshDialogEnables();
        end

        function selectAllCheckBoxCB(obj,val)
            obj.m_ExtModeLogAll=slprivate('onoff',val);
            obj.setRadioButtonValue();
        end

        function clearAllButtonCB(obj)
            for i=1:length(obj.m_instrumentedSignalData)
                obj.m_instrumentedSignalData(i).selected=false;
            end
            obj.setRadioButtonValue();
        end

        function selectionRadioButtonCB(obj,val)
            rowIdxs=obj.m_theDialog.getSelectedTableRows(obj.m_EMSTD_SelectionTable_Tag);
            if~isempty(rowIdxs)
                radioVal=radioButtonIndexToValue(obj,val);
                selVal=strcmp(radioVal,obj.m_Radio_On);

                for i=1:length(rowIdxs)
                    obj.m_instrumentedSignalData(rowIdxs(i)+1).selected=selVal;
                end
            end
            obj.enableApplyButton();
        end

        function triggerSignalButtonCB(obj)
            rowIdx=obj.m_theDialog.getSelectedTableRows(obj.m_EMSTD_SelectionTable_Tag);
            assert(length(rowIdx)==1);

            for i=1:length(obj.m_instrumentedSignalData)
                if(i==rowIdx+1)&&~obj.m_instrumentedSignalData(rowIdx+1).trigger
                    obj.m_instrumentedSignalData(rowIdx+1).trigger=true;
                else
                    obj.m_instrumentedSignalData(i).trigger=false;
                end
            end
            obj.enableApplyButton();
        end

        function gotoSignalButtonCB(obj)
            rowIdx=obj.m_theDialog.getSelectedTableRows(obj.m_EMSTD_SelectionTable_Tag);
            assert(length(rowIdx)==1);


            if obj.m_instrumentedSignalData(rowIdx+1).BlockPath.getLength()==1
                blk=obj.m_instrumentedSignalData(rowIdx+1).blkPath;
                blkOutputPortIndex=obj.m_instrumentedSignalData(rowIdx+1).blkOutputPortIndex;

                parent=get_param(blk,'parent');
                open_system(parent);

                selectedLines=find_system(parent,'SearchDepth',1,'FindAll','on',...
                'type','line','Selected','on');
                for i=1:length(selectedLines)
                    set_param(selectedLines(i),'Selected','off')
                end

                blockPortHdl=get_param(blk,'PortHandles');
                if~isempty(blockPortHdl.Outport)&&blkOutputPortIndex<=length(blockPortHdl.Outport)
                    lineHdl=get(blockPortHdl.Outport(blkOutputPortIndex),'Line');
                    if lineHdl~=-1
                        set_param(lineHdl,'Selected','on');
                    end
                end
            end
        end

        function sourceComboboxCB(obj,val)
            obj.m_ExtModeTrigType=sourceIndexToValue(obj,val);
        end

        function modeComboboxCB(obj,val)
            obj.m_ExtModeTrigMode=modeIndexToValue(obj,val);
        end

        function durationEditCB(obj,val)
            obj.m_ExtModeTrigDuration=val;
        end

        function delayEditCB(obj,val)
            obj.m_ExtModeTrigDelay=val;
        end

        function armWhenConnectCheckBoxCB(obj,val)
            obj.m_ExtModeArmWhenConnect=slprivate('onoff',val);
        end

        function usePackedModeCheckBoxCB(obj,val)
            obj.m_ExtModeSendContiguousSamples=slprivate('onoff',val);
        end

        function directionComboboxCB(obj,val)
            obj.m_ExtModeTrigDirection=directionIndexToValue(obj,val);
        end

        function levelEditCB(obj,val)
            obj.m_ExtModeTrigLevel=val;
        end

        function holdOffEditCB(obj,val)
            obj.m_ExtModeTrigHoldOff=val;
        end

        function closeCB(obj)
            obj.m_theDialogPos=obj.m_theDialog.position;
            obj.m_theDialog=[];
        end

        function[closeDlg,errmsg]=preApplyCB(obj)
            closeDlg=true;
            errmsg='';

            if~obj.m_theDialog.hasUnappliedChanges


                return
            end




            duration=obj.m_ExtModeTrigDuration;
            if~isnumeric(duration)
                duration=str2double(obj.m_ExtModeTrigDuration);
            end
            if isempty(duration)||isnan(duration)||duration<=0
                closeDlg=false;
                errmsg=DAStudio.message('Simulink:dialog:ExtModeDurationGreaterThanZero');
                return;
            end




            numTrigSigs=0;
            for i=1:length(obj.m_instrumentedSignalData)
                if obj.m_instrumentedSignalData(i).trigger
                    numTrigSigs=numTrigSigs+1;
                end
            end
            if numTrigSigs>1
                closeDlg=false;
                errmsg=DAStudio.message('Simulink:dialog:ExtModeOneTriggerSigOnly');
                return;
            end




            delay=obj.m_ExtModeTrigDelay;
            if~isnumeric(delay)
                delay=str2double(obj.m_ExtModeTrigDelay);
            end
            if isempty(delay)||isnan(delay)
                closeDlg=false;
                errmsg=DAStudio.message('Simulink:dialog:ExtModeDelayVal');
                return;
            end
            if(delay<0)&&(-delay>duration)
                closeDlg=false;
                errmsg=DAStudio.message('Simulink:dialog:ExtModePreTrigDelay');
                return;
            end




            bd=obj.getModelName();
            try
                set_param(bd,'ExtModeTrigType',obj.m_ExtModeTrigType);
                set_param(bd,'ExtModeTrigMode',obj.m_ExtModeTrigMode);
                set_param(bd,'ExtModeTrigDuration',obj.m_ExtModeTrigDuration);
                set_param(bd,'ExtModeTrigDelay',obj.m_ExtModeTrigDelay);
                set_param(bd,'ExtModeTrigLevel',obj.m_ExtModeTrigLevel);
                set_param(bd,'ExtModeTrigHoldOff',obj.m_ExtModeTrigHoldOff);
                set_param(bd,'ExtModeTrigDirection',obj.m_ExtModeTrigDirection);
                set_param(bd,'ExtModeArmWhenConnect',obj.m_ExtModeArmWhenConnect);
                set_param(bd,'ExtModeSendContiguousSamples',obj.m_ExtModeSendContiguousSamples);


                if strcmp(obj.m_ExtModeLogAll,'on')
                    obj.m_modelLoggingInfo.LoggingMode='LogAllAsSpecifiedInModel';
                else
                    obj.m_modelLoggingInfo.LoggingMode='OverrideSignals';
                end

                triggerBlockPath='';
                triggerOutputPortIndex=0;

                for i=1:length(obj.m_instrumentedSignalData)
                    index=obj.m_instrumentedSignalData(i).ModelLoggingIndex;
                    obj.m_modelLoggingInfo.Signals(index).LoggingInfo.DataLogging=...
                    obj.m_instrumentedSignalData(i).selected;

                    if obj.m_instrumentedSignalData(i).trigger

                        triggerBlockPath=obj.m_instrumentedSignalData(i).blkPath;
                        triggerOutputPortIndex=obj.m_instrumentedSignalData(i).blkOutputPortIndex;
                    end
                end


                set_param(bd,'ExtModeTrigSignalBlockPath',triggerBlockPath);
                set_param(bd,'ExtModeTrigSignalOutputPortIndex',triggerOutputPortIndex);

                if obj.isExtModeStatusDisconnected()

                    set_param(bd,'DataLoggingOverride',obj.m_modelLoggingInfo);
                end

            catch ME




                closeDlg=false;
                errmsg=ME.message;
            end
        end
    end


    methods



        function dlg=getDialogSchema(obj,~)



            data=obj.getInstrumentedSignalsSelectionTableData(obj.m_instrumentedSignalData);

            widget=[];
            widget.Name='';
            widget.Type='table';
            widget.Tag=obj.m_EMSTD_SelectionTable_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeSignalSelectionTableTooltip',obj.getModelName());
            widget.ColHeader={DAStudio.message('Simulink:dialog:ExtModeTrigger'),DAStudio.message('Simulink:dialog:ExtModeSelected'),DAStudio.message('Simulink:dialog:ExtModeInstrumentedSignal'),DAStudio.message('Simulink:dialog:ExtModeSourcePort')};
            widget.ColumnCharacterWidth=[9,10,15,20];
            widget.ColumnStretchable=[0,0,1,1];
            widget.LastColumnStretchable=true;
            widget.HeaderVisibility=[0,1];
            widget.HideName=true;
            widget.Size=size(data);
            widget.Data=data;
            widget.Grid=false;
            widget.SelectionBehavior='row';
            widget.CurrentItemChangedCallback=@obj.selectionTableCB;
            widget.Enabled=obj.instrumentedSignalsSelectionTableEnabled();
            widget.RowSpan=[1,10];
            widget.ColSpan=[1,10];

            InstrumentedSignalsSelectionTable=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeSelectAll');
            widget.Type='checkbox';
            widget.Tag=obj.m_EMSTD_SelectAll_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeSelectAllTooltip',obj.getModelName());
            widget.Value=slprivate('onoff',obj.m_ExtModeLogAll);
            widget.ObjectMethod='selectAllCheckBoxCB';
            widget.MethodArgs={'%value'};
            widget.ArgDataTypes={'mxArray'};
            widget.Enabled=obj.selectAllCheckboxEnabled();
            widget.RowSpan=[1,1];
            widget.ColSpan=[11,11];
            widget.DialogRefresh=true;

            SelectAllCheckBox=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeClearAll');
            widget.Type='pushbutton';
            widget.Tag=obj.m_EMSTD_ClearAll_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeClearAllTooltip',obj.getModelName());
            widget.ObjectMethod='clearAllButtonCB';
            widget.Enabled=obj.clearAllCheckboxEnabled();
            widget.RowSpan=[3,3];
            widget.ColSpan=[11,11];
            widget.DialogRefresh=true;

            ClearAllButton=widget;




            widget=[];
            widget.Name='';
            widget.Type='radiobutton';
            widget.Tag=obj.m_EMSTD_SelectionRadioButton_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeRadioButtonTooltip');
            widget.Value=obj.m_initialRadioButtonValue;
            widget.ObjectMethod='selectionRadioButtonCB';
            widget.MethodArgs={'%value'};
            widget.ArgDataTypes={'mxArray'};
            widget.Entries=obj.m_radioEntries;
            widget.Enabled=obj.selectionRadioButtonEnabled();
            widget.RowSpan=[4,5];
            widget.ColSpan=[11,11];
            widget.Graphical=true;
            widget.DialogRefresh=true;

            OnOffRadioButton=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeTriggerSignalButton');
            widget.Type='pushbutton';
            widget.Tag=obj.m_EMSTD_TriggerSignalButton_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeTriggerSignalTooltip');
            widget.ObjectMethod='triggerSignalButtonCB';
            widget.Enabled=obj.triggerSignalButtonEnabled();
            widget.RowSpan=[9,9];
            widget.ColSpan=[11,11];
            widget.DialogRefresh=true;

            TriggerSignalButton=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeGoToSignal');
            widget.Type='pushbutton';
            widget.Tag=obj.m_EMSTD_GotoSignal_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeGoToSignalTooltip',obj.getModelName());
            widget.ObjectMethod='gotoSignalButtonCB';
            widget.Enabled=obj.gotoSignalButtonEnabled();
            widget.RowSpan=[10,10];
            widget.ColSpan=[11,11];

            GotoSignalButton=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeSignalSelection');
            widget.Tag=obj.m_EMSTD_SignalSelectionGroup_Tag;
            widget.Type='group';
            widget.Items={InstrumentedSignalsSelectionTable,SelectAllCheckBox,ClearAllButton,OnOffRadioButton,TriggerSignalButton,GotoSignalButton};
            widget.LayoutGrid=[10,11];

            SignalSelectionGroup=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeSource');
            widget.Type='combobox';
            widget.Tag=obj.m_EMSTD_Source_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeSourceTooltip');
            widget.Value=sourceValueToIndex(obj,obj.m_ExtModeTrigType);
            widget.ObjectMethod='sourceComboboxCB';
            widget.MethodArgs={'%value'};
            widget.ArgDataTypes={'mxArray'};
            widget.Entries=obj.m_sourceEntries;
            widget.Enabled=obj.triggerSourceComboboxEnabled();
            widget.RowSpan=[1,1];
            widget.ColSpan=[1,1];
            widget.DialogRefresh=true;

            TrigSourceCombobox=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeMode');
            widget.Type='combobox';
            widget.Tag=obj.m_EMSTD_Mode_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeModeTooltip');
            widget.Value=modeValueToIndex(obj,obj.m_ExtModeTrigMode);
            widget.ObjectMethod='modeComboboxCB';
            widget.MethodArgs={'%value'};
            widget.ArgDataTypes={'mxArray'};
            widget.Entries=obj.m_modeEntries;
            widget.Enabled=obj.triggerModeComboboxEnabled();
            widget.RowSpan=[1,1];
            widget.ColSpan=[2,2];
            widget.DialogRefresh=true;

            TrigModeCombobox=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeDuration');
            widget.Type='edit';
            widget.Tag=obj.m_EMSTD_Duration_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeDurationTooltip');
            widget.Value=obj.m_ExtModeTrigDuration;
            widget.ObjectMethod='durationEditCB';
            widget.MethodArgs={'%value'};
            widget.ArgDataTypes={'mxArray'};
            widget.Enabled=obj.triggerDurationEditEnabled();
            widget.RowSpan=[1,1];
            widget.ColSpan=[3,3];
            widget.MaximumSize=[100,30];
            widget.Alignment=1;
            widget.DialogRefresh=true;

            TrigDurationEdit=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeDelay');
            widget.Type='edit';
            widget.Tag=obj.m_EMSTD_Delay_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeDelayTooltip');
            widget.Value=obj.m_ExtModeTrigDelay;
            widget.ObjectMethod='delayEditCB';
            widget.MethodArgs={'%value'};
            widget.ArgDataTypes={'mxArray'};
            widget.Enabled=obj.triggerDelayEditEnabled();
            widget.RowSpan=[1,1];
            widget.ColSpan=[4,4];
            widget.MaximumSize=[100,30];
            widget.Alignment=1;
            widget.DialogRefresh=true;

            TrigDelayEdit=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeArmWhenConnect');
            widget.Type='checkbox';
            widget.Tag=obj.m_EMSTD_ArmWhenConnect_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeArmWhenConnectTooltip');
            widget.Value=slprivate('onoff',obj.m_ExtModeArmWhenConnect);
            widget.ObjectMethod='armWhenConnectCheckBoxCB';
            widget.MethodArgs={'%value'};
            widget.ArgDataTypes={'mxArray'};
            widget.Enabled=obj.armWhenConnectCheckboxEnabled();
            widget.RowSpan=[2,2];
            widget.ColSpan=[1,2];
            widget.Alignment=1;
            widget.DialogRefresh=true;

            ArmWhenConnectCheckBox=widget;




            widget=[];
            widget.Name=...
            DAStudio.message('Simulink:dialog:ExtModeUsePackedMode');
            widget.Type='checkbox';
            widget.Tag=obj.m_EMSTD_UsePackedMode_Tag;
            widget.ToolTip=...
            DAStudio.message('Simulink:dialog:ExtModeUsePackedModeTooltip');
            widget.Value=slprivate('onoff',obj.m_ExtModeSendContiguousSamples);
            widget.ObjectMethod='usePackedModeCheckBoxCB';
            widget.MethodArgs={'%value'};
            widget.ArgDataTypes={'mxArray'};
            widget.Enabled=obj.usePackedModeCheckboxEnabled();
            widget.RowSpan=[2,2];
            widget.ColSpan=[3,4];
            widget.Alignment=1;
            widget.DialogRefresh=true;

            UsePackedModeCheckBox=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeTriggerOptionsGroup');
            widget.Tag=obj.m_EMSTD_TriggerGroup_Tag;
            widget.Type='group';
            if coder.internal.connectivity.featureOn('XcpPackedMode')
                widget.Items={TrigSourceCombobox,TrigModeCombobox,TrigDurationEdit,TrigDelayEdit,ArmWhenConnectCheckBox,UsePackedModeCheckBox};
            else
                widget.Items={TrigSourceCombobox,TrigModeCombobox,TrigDurationEdit,TrigDelayEdit,ArmWhenConnectCheckBox};
            end
            widget.LayoutGrid=[2,4];

            TriggerGroup=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeDirection');
            widget.Type='combobox';
            widget.Tag=obj.m_EMSTD_Direction_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeDirectionTooltip');
            widget.Value=directionValueToIndex(obj,obj.m_ExtModeTrigDirection);
            widget.ObjectMethod='directionComboboxCB';
            widget.MethodArgs={'%value'};
            widget.ArgDataTypes={'mxArray'};
            widget.Entries=obj.m_directionEntries;
            widget.Enabled=obj.triggerSignalDirectionComboboxEnabled();
            widget.RowSpan=[2,2];
            widget.ColSpan=[1,2];
            widget.Alignment=1;
            widget.DialogRefresh=true;

            TrigDirectionCombobox=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeLevel');
            widget.Type='edit';
            widget.Tag=obj.m_EMSTD_Level_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeLevelTooltip');
            widget.Value=obj.m_ExtModeTrigLevel;
            widget.ObjectMethod='levelEditCB';
            widget.MethodArgs={'%value'};
            widget.ArgDataTypes={'mxArray'};
            widget.Enabled=obj.triggerSignalLevelEditEnabled();
            widget.RowSpan=[2,2];
            widget.ColSpan=[3,4];
            widget.MaximumSize=[100,30];
            widget.Alignment=1;
            widget.DialogRefresh=true;

            TrigLevelEdit=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeHoldOff');
            widget.Type='edit';
            widget.Tag=obj.m_EMSTD_HoldOff_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeHoldOffTooltip');
            widget.Value=obj.m_ExtModeTrigHoldOff;
            widget.ObjectMethod='holdOffEditCB';
            widget.MethodArgs={'%value'};
            widget.ArgDataTypes={'mxArray'};
            widget.Enabled=obj.triggerSignalHoldOffEditEnabled();
            widget.RowSpan=[2,2];
            widget.ColSpan=[5,6];
            widget.MaximumSize=[100,30];
            widget.Alignment=1;
            widget.DialogRefresh=true;

            TrigHoldOffEdit=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeTriggerSignalGroup');
            widget.Tag=obj.m_EMSTD_TriggerSignalGroup_Tag;
            widget.Type='group';
            widget.Items={TrigDirectionCombobox,TrigLevelEdit,TrigHoldOffEdit};
            widget.LayoutGrid=[2,12];

            TriggerSignalGroup=widget;












            widget=[];
            widget.Name='';
            widget.Type='checkbox';
            widget.Tag=obj.m_EMSTD_HiddenCheckbox_Tag;
            widget.Value=0;
            widget.Visible=false;

            hiddenCheckbox=widget;




            dlg.DialogTitle=obj.createDialogTitle();
            dlg.DialogTag=obj.m_EMSTD_Dialog_Tag;
            dlg.HelpMethod='helpview';
            dlg.HelpArgs={fullfile(docroot,'toolbox','rtw','helptargets.map'),'rtw_sigs_and_trigs_xcp'};
            dlg.Items={SignalSelectionGroup,TriggerGroup,TriggerSignalGroup,hiddenCheckbox};
            dlg.LayoutGrid=[3,1];
            dlg.RowStretch=[3,1,1];
            dlg.StandaloneButtonSet={'OK','Cancel','Help','Apply'};
            dlg.CloseMethod='closeCB';
            dlg.PreApplyMethod='preApplyCB';
            dlg.Sticky=false;
        end
    end
end
