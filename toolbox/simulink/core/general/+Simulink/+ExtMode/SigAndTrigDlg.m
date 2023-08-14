classdef SigAndTrigDlg<handle














    properties(Access=public)



        m_ctrlPanel=[];












        m_ExtModeLogAll;
        m_ExtModeTrigType;
        m_ExtModeTrigMode;
        m_ExtModeTrigDuration;
        m_ExtModeTrigDelay;
        m_ExtModeTrigPort;
        m_ExtModeTrigElement;
        m_ExtModeTrigLevel;
        m_ExtModeTrigHoldOff;
        m_ExtModeTrigDirection;
        m_ExtModeArmWhenConnect;




        m_uploadBlockData;





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



        m_EMSTD_Dialog_Tag='ExtModeSigAndTrigDlg_Dialog_Tag';
        m_EMSTD_SelectionTable_Tag='ExtModeSigAndTrigDlg_SelectionTable_Tag';
        m_EMSTD_SelectAll_Tag='ExtModeSigAndTrigDlg_SelectAll_Tag';
        m_EMSTD_ClearAll_Tag='ExtModeSigAndTrigDlg_ClearAll_Tag';
        m_EMSTD_SelectionRadioButton_Tag='ExtModeSigAndTrigDlg_SelectionRadioButton_Tag';
        m_EMSTD_HiddenCheckbox_Tag='ExtModeSigAndTrigDlg_HiddenCheckbox_Tag';
        m_EMSTD_TriggerSignalButton_Tag='ExtModeSigAndTrigDlg_TriggerSignalButton_Tag';
        m_EMSTD_GotoBlock_Tag='ExtModeSigAndTrigDlg_GotoBlock_Tag';
        m_EMSTD_SignalSelectionGroup_Tag='ExtModeSigAndTrigDlg_SignalSelectionGroup_Tag';
        m_EMSTD_Source_Tag='ExtModeSigAndTrigDlg_Source_Tag';
        m_EMSTD_Mode_Tag='ExtModeSigAndTrigDlg_Mode_Tag';
        m_EMSTD_Duration_Tag='ExtModeSigAndTrigDlg_Duration_Tag';
        m_EMSTD_Delay_Tag='ExtModeSigAndTrigDlg_Delay_Tag';
        m_EMSTD_ArmWhenConnect_Tag='ExtModeSigAndTrigDlg_ArmWhenConnect_Tag';
        m_EMSTD_TriggerGroup_Tag='ExtModeSigAndTrigDlg_TriggerGroup_Tag';
        m_EMSTD_Port_Tag='ExtModeSigAndTrigDlg_Port_Tag';
        m_EMSTD_Element_Tag='ExtModeSigAndTrigDlg_Element_Tag';
        m_EMSTD_TriggerSignalPathLabel_Tag='ExtModeSigAndTrigDlg_TriggerSignalPathLabel_Tag';
        m_EMSTD_TriggerSignalPath_Tag='ExtModeSigAndTrigDlg_TriggerSignalPath_Tag';
        m_EMSTD_Direction_Tag='ExtModeSigAndTrigDlg_Direction_Tag';
        m_EMSTD_Level_Tag='ExtModeSigAndTrigDlg_Level_Tag';
        m_EMSTD_HoldOff_Tag='ExtModeSigAndTrigDlg_HoldOff_Tag';
        m_EMSTD_TriggerSignalGroup_Tag='ExtModeSigAndTrigDlg_TriggerSignalGroup_Tag';
    end









    methods(Access={?Simulink.ExtMode.CtrlPanel})
        function obj=SigAndTrigDlg(parent)
            obj.m_ctrlPanel=parent;
            obj.showDialog();
        end

        function showDialog(obj)











            if isempty(obj.m_theDialog)



                bd=obj.getModelName();
                obj.m_ExtModeLogAll=get_param(bd,'ExtModeLogAll');
                obj.m_ExtModeTrigType=get_param(bd,'ExtModeTrigType');
                obj.m_ExtModeTrigMode=get_param(bd,'ExtModeTrigMode');
                obj.m_ExtModeTrigDuration=get_param(bd,'ExtModeTrigDuration');
                obj.m_ExtModeTrigDelay=get_param(bd,'ExtModeTrigDelay');
                obj.m_ExtModeTrigPort=get_param(bd,'ExtModeTrigPort');
                obj.m_ExtModeTrigElement=get_param(bd,'ExtModeTrigElement');
                obj.m_ExtModeTrigLevel=get_param(bd,'ExtModeTrigLevel');
                obj.m_ExtModeTrigHoldOff=get_param(bd,'ExtModeTrigHoldOff');
                obj.m_ExtModeTrigDirection=get_param(bd,'ExtModeTrigDirection');
                obj.m_ExtModeArmWhenConnect=get_param(bd,'ExtModeArmWhenConnect');




                obj.m_uploadBlockData=obj.getUploadBlockDataFromModel();




                obj.m_initialRadioButtonValue=obj.m_Radio_Off_Index;
                if obj.isSelectAllChecked()||isempty(obj.m_uploadBlockData)||obj.m_uploadBlockData(1).selected
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
                val=obj.m_uploadBlockData(rowIdxs+1);
            end
        end

        function enableApplyButton(obj)
            val=obj.m_theDialog.getWidgetValue(obj.m_EMSTD_HiddenCheckbox_Tag);
            obj.m_theDialog.setWidgetValue(obj.m_EMSTD_HiddenCheckbox_Tag,~val);
        end

        function val=isExtModeUploadStatusInactive(obj)
            val=strcmp(get_param(obj.getModelName(),'ExtModeUploadStatus'),'inactive');
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
            if obj.isSelectAllChecked()||isempty(obj.m_uploadBlockData)
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
        function blocks=findAllUploadBlocks(obj)
            bd=obj.getModelName();






            blocks=find_system(bd,'LookUnderMasks','all','FollowLinks','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'AllBlocks','on','ExtModeLoggingSupported','on');









            userUploadBlocks=find_system(blocks,'SearchDepth',0,...
            'BlockType','SubSystem',...
            'SimViewingDevice','on');




            while~isempty(userUploadBlocks),
                hB=userUploadBlocks(1);







                hBAllUploadDescendants=...
                find_system(hB,'LookUnderMasks','all','FollowLinks','on',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'AllBlocks','on','ExtModeLoggingSupported','on');
                hBAllUploadDescendants(1)=[];

                blocks=setdiff(blocks,hBAllUploadDescendants)';





                done=[hB
                find_system(hBAllUploadDescendants,'SearchDepth',0,...
                'BlockType','SubSystem',...
                'SimViewingDevice','on')];
                userUploadBlocks=setdiff(userUploadBlocks,done)';
            end
        end

        function uploadBlockData=getUploadBlockDataFromModel(obj)
            uploadBlockData=[];

            blocks=obj.findAllUploadBlocks();

            for i=1:length(blocks),
                block=blocks{i};




                isSfSFunBlk=false;
                if strcmp(get_param(block,'BlockType'),'S-Function')
                    blkParent=get_param(block,'Parent');
                    if~isempty(blkParent)&&slprivate('is_stateflow_based_block',blkParent)
                        isSfSFunBlk=true;
                    end
                end




                if isSfSFunBlk
                    dispName=get_param(get_param(block,'Parent'),'name');
                    dispPath=getfullname(get_param(block,'Parent'));
                else
                    dispName=get_param(block,'name');
                    dispPath=getfullname(block);
                end
                dispName=strrep(dispName,sprintf('\n'),' ');
                dispPath=strrep(dispPath,sprintf('\n'),' ');




                trig=false;
                if strcmp(get_param(block,'ExtModeLoggingTrig'),'on')
                    trig=true;
                end




                selected=false;
                if strcmp(get_param(block,'ExtModeUploadOption'),'log')
                    selected=true;
                end




                data=struct('trigger',trig,'selected',selected,'dispName',dispName,'dispPath',dispPath,'blkPath',getfullname(block));
                if isempty(uploadBlockData)
                    uploadBlockData=data;
                else
                    uploadBlockData(end+1)=data;%#ok
                end
            end
        end

        function uploadBlockSelectionData=getUploadBlockSelectionTableData(obj,uploadBlockData)
            uploadBlockSelectionData=cell(length(uploadBlockData),4);
            for i=1:length(uploadBlockData)
                trig=' ';
                if uploadBlockData(i).trigger
                    trig='T';
                end

                selected=' ';
                if strcmp(obj.m_ExtModeLogAll,'on')||uploadBlockData(i).selected
                    selected='X';
                end
                uploadBlockSelectionData{i,1}=trig;
                uploadBlockSelectionData{i,2}=selected;
                uploadBlockSelectionData{i,3}=uploadBlockData(i).dispName;
                uploadBlockSelectionData{i,4}=uploadBlockData(i).dispPath;
            end
        end
    end




    methods(Access=public)
        function enabled=uploadBlockSelectionTableEnabled(obj)
            enabled=obj.isExtModeUploadStatusInactive();
        end
        function enabled=selectAllCheckboxEnabled(obj)
            enabled=obj.isExtModeUploadStatusInactive();
        end
        function enabled=clearAllCheckboxEnabled(obj)
            enabled=obj.isExtModeUploadStatusInactive()&&...
            ~obj.isSelectAllChecked()&&...
            ~isempty(obj.m_uploadBlockData);
        end
        function enabled=selectionRadioButtonEnabled(obj)
            enabled=obj.isExtModeUploadStatusInactive()&&...
            ~obj.isSelectAllChecked()&&...
            ~isempty(obj.m_uploadBlockData);
        end
        function enabled=triggerSignalButtonEnabled(obj)
            enabled=obj.isExtModeUploadStatusInactive()&&...
            obj.m_singleSelectionInTable;
        end
        function enabled=gotoBlockButtonEnabled(obj)
            enabled=obj.isExtModeUploadStatusInactive()&&...
            obj.m_singleSelectionInTable;
        end
        function enabled=triggerSourceComboboxEnabled(obj)
            enabled=obj.isExtModeUploadStatusInactive();
        end
        function enabled=triggerModeComboboxEnabled(obj)
            enabled=obj.isExtModeUploadStatusInactive();
        end
        function enabled=triggerDurationEditEnabled(obj)
            enabled=obj.isExtModeUploadStatusInactive();
        end
        function enabled=triggerDelayEditEnabled(obj)
            enabled=obj.isExtModeUploadStatusInactive();
        end
        function enabled=armWhenConnectCheckboxEnabled(obj)
            enabled=obj.isExtModeUploadStatusInactive();
        end
        function enabled=triggerSignalPathTextEnabled(obj)
            enabled=obj.isExtModeUploadStatusInactive()&&...
            ~obj.isTriggerSourceManual();
        end
        function enabled=triggerSignalPortEditEnabled(obj)
            enabled=obj.isExtModeUploadStatusInactive()&&...
            ~obj.isTriggerSourceManual();
        end
        function enabled=triggerSignalElementEditEnabled(obj)
            enabled=obj.isExtModeUploadStatusInactive()&&...
            ~obj.isTriggerSourceManual();
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
            obj.m_theDialog.setEnabled(obj.m_EMSTD_SelectionTable_Tag,obj.uploadBlockSelectionTableEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_SelectAll_Tag,obj.selectAllCheckboxEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_ClearAll_Tag,obj.clearAllCheckboxEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_SelectionRadioButton_Tag,obj.selectionRadioButtonEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_TriggerSignalButton_Tag,obj.triggerSignalButtonEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_GotoBlock_Tag,obj.gotoBlockButtonEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_Source_Tag,obj.triggerSourceComboboxEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_Mode_Tag,obj.triggerModeComboboxEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_Duration_Tag,obj.triggerDurationEditEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_Delay_Tag,obj.triggerDelayEditEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_ArmWhenConnect_Tag,obj.armWhenConnectCheckboxEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_TriggerSignalPath_Tag,obj.triggerSignalPathTextEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_Port_Tag,obj.triggerSignalPortEditEnabled());
            obj.m_theDialog.setEnabled(obj.m_EMSTD_Element_Tag,obj.triggerSignalElementEditEnabled());
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
            for i=1:length(obj.m_uploadBlockData)
                obj.m_uploadBlockData(i).selected=false;
            end
            obj.setRadioButtonValue();
        end

        function selectionRadioButtonCB(obj,val)
            rowIdxs=obj.m_theDialog.getSelectedTableRows(obj.m_EMSTD_SelectionTable_Tag);
            if~isempty(rowIdxs)
                radioVal=radioButtonIndexToValue(obj,val);
                selVal=strcmp(radioVal,obj.m_Radio_On);

                for i=1:length(rowIdxs)
                    obj.m_uploadBlockData(rowIdxs(i)+1).selected=selVal;
                end
            end
            obj.enableApplyButton();
        end

        function triggerSignalButtonCB(obj)
            rowIdx=obj.m_theDialog.getSelectedTableRows(obj.m_EMSTD_SelectionTable_Tag);
            assert(length(rowIdx)==1);

            for i=1:length(obj.m_uploadBlockData)
                if(i==rowIdx+1)&&~obj.m_uploadBlockData(rowIdx+1).trigger
                    obj.m_uploadBlockData(rowIdx+1).trigger=true;
                else
                    obj.m_uploadBlockData(i).trigger=false;
                end
            end
            obj.enableApplyButton();
        end

        function gotoBlockButtonCB(obj)
            rowIdx=obj.m_theDialog.getSelectedTableRows(obj.m_EMSTD_SelectionTable_Tag);
            assert(length(rowIdx)==1);

            blk=obj.m_uploadBlockData(rowIdx+1).blkPath;

            parent=get_param(blk,'parent');
            open_system(parent);
            selectedObjs=find_system(obj.getModelName(),...
            'SearchDepth',1,...
            'FindAll','on',...
            'AllBlocks','on',...
            'Selected','on');
            for i=1:length(selectedObjs),
                set_param(selectedObjs(i),'Selected','off')
            end
            set_param(blk,'Selected','on');
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

        function portEditCB(obj,val)
            obj.m_ExtModeTrigPort=val;
        end

        function elementEditCB(obj,val)
            obj.m_ExtModeTrigElement=val;
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

        function name=triggerSignalPathText(obj)
            for i=1:length(obj.m_uploadBlockData)
                if obj.m_uploadBlockData(i).trigger




                    name=obj.m_uploadBlockData(i).dispPath;
                    return;
                end
            end
            name='';
        end

        function closeCB(obj)
            obj.m_theDialogPos=obj.m_theDialog.position;
            obj.m_theDialog=[];
        end

        function[closeDlg,errmsg]=preApplyCB(obj)
            closeDlg=true;
            errmsg='';




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
            for i=1:length(obj.m_uploadBlockData)
                if obj.m_uploadBlockData(i).trigger
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
                set_param(bd,'ExtModeLogAll',obj.m_ExtModeLogAll);
                set_param(bd,'ExtModeTrigType',obj.m_ExtModeTrigType);
                set_param(bd,'ExtModeTrigMode',obj.m_ExtModeTrigMode);
                set_param(bd,'ExtModeTrigDuration',obj.m_ExtModeTrigDuration);
                set_param(bd,'ExtModeTrigDelay',obj.m_ExtModeTrigDelay);
                set_param(bd,'ExtModeTrigPort',obj.m_ExtModeTrigPort);
                set_param(bd,'ExtModeTrigElement',obj.m_ExtModeTrigElement);
                set_param(bd,'ExtModeTrigLevel',obj.m_ExtModeTrigLevel);
                set_param(bd,'ExtModeTrigHoldOff',obj.m_ExtModeTrigHoldOff);
                set_param(bd,'ExtModeTrigDirection',obj.m_ExtModeTrigDirection);
                set_param(bd,'ExtModeArmWhenConnect',obj.m_ExtModeArmWhenConnect);

                for i=1:length(obj.m_uploadBlockData)
                    block=obj.m_uploadBlockData(i).blkPath;
                    if obj.m_uploadBlockData(i).selected
                        set_param(block,'ExtModeUploadOption','log');
                    else
                        set_param(block,'ExtModeUploadOption','none');
                    end

                    if obj.m_uploadBlockData(i).trigger
                        set_param(block,'ExtModeLoggingTrig','on');
                    else
                        set_param(block,'ExtModeLoggingTrig','off');
                    end
                end
            catch ME




                closeDlg=false;
                errmsg=ME.message;
            end
        end
    end


    methods



        function dlg=getDialogSchema(obj,~)



            data=obj.getUploadBlockSelectionTableData(obj.m_uploadBlockData);

            widget=[];
            widget.Name='';
            widget.Type='table';
            widget.Tag=obj.m_EMSTD_SelectionTable_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeSignalSelectionTableTooltip',obj.getModelName());
            widget.ColHeader={DAStudio.message('Simulink:dialog:ExtModeTrigger'),DAStudio.message('Simulink:dialog:ExtModeSelected'),DAStudio.message('Simulink:dialog:ExtModeBlock'),DAStudio.message('Simulink:dialog:ExtModePath')};
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
            widget.Enabled=obj.uploadBlockSelectionTableEnabled();
            widget.RowSpan=[1,10];
            widget.ColSpan=[1,10];

            UploadBlockSelectionTable=widget;




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
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeGoToBlock');
            widget.Type='pushbutton';
            widget.Tag=obj.m_EMSTD_GotoBlock_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeGoToBlockTooltip',obj.getModelName());
            widget.ObjectMethod='gotoBlockButtonCB';
            widget.Enabled=obj.gotoBlockButtonEnabled();
            widget.RowSpan=[10,10];
            widget.ColSpan=[11,11];

            GotoBlockButton=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeSignalSelection');
            widget.Tag=obj.m_EMSTD_SignalSelectionGroup_Tag;
            widget.Type='group';
            widget.Items={UploadBlockSelectionTable,SelectAllCheckBox,ClearAllButton,OnOffRadioButton,TriggerSignalButton,GotoBlockButton};
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
            widget.ColSpan=[1,4];
            widget.Alignment=1;
            widget.DialogRefresh=true;

            ArmWhenConnectCheckBox=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeTriggerOptionsGroup');
            widget.Tag=obj.m_EMSTD_TriggerGroup_Tag;
            widget.Type='group';
            widget.Items={TrigSourceCombobox,TrigModeCombobox,TrigDurationEdit,TrigDelayEdit,ArmWhenConnectCheckBox};
            widget.LayoutGrid=[2,4];

            TriggerGroup=widget;




            widget=[];
            widget.Name=[DAStudio.message('Simulink:dialog:ExtModePath'),': '];
            widget.Type='text';
            widget.Tag=obj.m_EMSTD_TriggerSignalPathLabel_Tag;
            widget.RowSpan=[1,1];
            widget.ColSpan=[1,1];
            widget.MaximumSize=[50,30];

            TrigPathLabelText=widget;




            widget=[];
            widget.Name=obj.triggerSignalPathText();
            widget.Type='text';
            widget.Tag=obj.m_EMSTD_TriggerSignalPath_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeTriggerSourceTooltip');
            widget.Enabled=obj.triggerSignalPathTextEnabled();
            widget.RowSpan=[1,1];
            widget.ColSpan=[2,8];

            TrigPathText=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModePort');
            widget.Type='edit';
            widget.Tag=obj.m_EMSTD_Port_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModePortTooltip');
            widget.Value=obj.m_ExtModeTrigPort;
            widget.ObjectMethod='portEditCB';
            widget.MethodArgs={'%value'};
            widget.ArgDataTypes={'mxArray'};
            widget.Enabled=obj.triggerSignalPortEditEnabled();
            widget.RowSpan=[1,1];
            widget.ColSpan=[9,10];
            widget.MaximumSize=[100,30];
            widget.Alignment=1;
            widget.DialogRefresh=true;

            TrigPortEdit=widget;




            widget=[];
            widget.Name=DAStudio.message('Simulink:dialog:ExtModeElement');
            widget.Type='edit';
            widget.Tag=obj.m_EMSTD_Element_Tag;
            widget.ToolTip=DAStudio.message('Simulink:dialog:ExtModeElementTooltip');
            widget.Value=obj.m_ExtModeTrigElement;
            widget.ObjectMethod='elementEditCB';
            widget.MethodArgs={'%value'};
            widget.ArgDataTypes={'mxArray'};
            widget.Enabled=obj.triggerSignalElementEditEnabled();
            widget.RowSpan=[1,1];
            widget.ColSpan=[11,12];
            widget.MaximumSize=[100,30];
            widget.Alignment=1;
            widget.DialogRefresh=true;

            TrigElementEdit=widget;




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
            widget.Items={TrigPathLabelText,TrigPathText,TrigPortEdit,TrigElementEdit,TrigDirectionCombobox,TrigLevelEdit,TrigHoldOffEdit};
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
            dlg.HelpArgs={fullfile(docroot,'toolbox','rtw','helptargets.map'),'rtw_sigs_and_trigs'};
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
