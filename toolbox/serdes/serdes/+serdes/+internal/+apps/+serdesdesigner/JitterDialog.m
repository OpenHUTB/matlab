classdef JitterDialog<handle

    properties
Parent
Panel
Layout
        Width=0
        Height=0
Listeners

jitter
unitSeconds_Text
unitUI_Text
unitOptions
    end


    properties(Constant)

        unitToolTip=getString(message('serdes:serdesdesigner:UnitJitter_ToolTip'));
        editToolTip=getString(message('serdes:serdesdesigner:EditJitter_ToolTip'));
    end

    properties(Access=private)

textTitle


textClockModeTitle
buttonGroupIsMode
radioButtonIsModeClocked
radioButtonIsModeIdeal


textTxJitterSpace
textTxJitterTitle
textTxJitterName
textTxJitterValue
textTxJitterUnit
textTxSjFrequencyUnit
checkboxTxDCD
checkboxTxRj
checkboxTxDj
checkboxTxSj
checkboxTxSjFrequency
editTxDCD
editTxRj
editTxDj
editTxSj
editTxSjFrequency
popupmenuTxDCD
popupmenuTxRj
popupmenuTxDj
popupmenuTxSj


textRxJitterSpace
textRxJitterTitle
textRxJitterName
textRxJitterValue
textRxJitterUnit
checkboxRxDCD
checkboxRxRj
checkboxRxDj
checkboxRxSj
editRxDCD
editRxRj
editRxDj
editRxSj
popupmenuRxDCD
popupmenuRxRj
popupmenuRxDj
popupmenuRxSj


textRxClockRecoveryJitterSpace
textRxClockRecoveryJitterTitle
textRxClockRecoveryJitterName
textRxClockRecoveryJitterValue
textRxClockRecoveryJitterUnit
checkboxRxClockRecoveryMean
checkboxRxClockRecoveryRj
checkboxRxClockRecoveryDj
checkboxRxClockRecoverySj
checkboxRxClockRecoveryDCD
editRxClockRecoveryMean
editRxClockRecoveryRj
editRxClockRecoveryDj
editRxClockRecoverySj
editRxClockRecoveryDCD
popupmenuRxClockRecoveryMean
popupmenuRxClockRecoveryRj
popupmenuRxClockRecoveryDj
popupmenuRxClockRecoverySj
popupmenuRxClockRecoveryDCD


textRxNoiseSpace
textRxNoiseTitle
textRxNoiseName
textRxNoiseValue
textRxNoiseUnit
textRxReceiverSensitivityUnit
textRxGaussianNoiseUnit
textRxUniformNoiseUnit
checkboxRxReceiverSensitivity
checkboxRxGaussianNoise
checkboxRxUniformNoise
editRxReceiverSensitivity
editRxGaussianNoise
editRxUniformNoise


textParametersNotUsed


ParameterLabels
ParameterEdits
    end

    methods

        function obj=JitterDialog(parent,dialogPanel)
            if nargin==0
                parent=figure;
            end
            obj.Parent=parent;
            obj.Panel=dialogPanel;
            obj.Panel.AutoResizeChildren='off';


            obj.jitter=serdes.internal.apps.serdesdesigner.jitter;
            obj.unitSeconds_Text=obj.jitter.UnitsSeconds_Text;
            obj.unitUI_Text=obj.jitter.UnitsUI_Text;
            obj.unitOptions={obj.unitSeconds_Text,obj.unitUI_Text};

            obj.createUIControls();
            obj.layoutUIControls();
            obj.addListeners();

            obj.refreshDisplayedValues();
        end


        function deleteDialog(obj)

            obj.removeListeners();
            obj.deleteUIControls();
            delete(obj);
        end
        function setListenersEnable(obj,val)

            if val
                obj.addListeners();
            else
                obj.removeListeners();
            end
        end
        function refreshDisplayedValues(obj)

            obj.radioButtonIsModeClocked.Value=obj.jitter.isModeClocked;
            obj.radioButtonIsModeIdeal.Value=obj.jitter.isModeIdeal;


            obj.checkboxTxDCD.Value=obj.jitter.isTxDCD;
            obj.checkboxTxRj.Value=obj.jitter.isTxRj;
            obj.checkboxTxDj.Value=obj.jitter.isTxDj;
            obj.checkboxTxSj.Value=obj.jitter.isTxSj;
            obj.checkboxTxSjFrequency.Value=obj.jitter.isTxSjFrequency;
            obj.editTxDCD.Value=num2str(obj.jitter.TxDCD,15);
            obj.editTxRj.Value=num2str(obj.jitter.TxRj,15);
            obj.editTxDj.Value=num2str(obj.jitter.TxDj,15);
            obj.editTxSj.Value=num2str(obj.jitter.TxSj,15);
            obj.editTxSjFrequency.Value=num2str(obj.jitter.TxSjFrequency,15);
            obj.popupmenuTxDCD.Value=obj.unit2str(obj.jitter.unitsTxDCD);
            obj.popupmenuTxRj.Value=obj.unit2str(obj.jitter.unitsTxRj);
            obj.popupmenuTxDj.Value=obj.unit2str(obj.jitter.unitsTxDj);
            obj.popupmenuTxSj.Value=obj.unit2str(obj.jitter.unitsTxSj);


            obj.checkboxRxDCD.Value=obj.jitter.isRxDCD;
            obj.checkboxRxRj.Value=obj.jitter.isRxRj;
            obj.checkboxRxDj.Value=obj.jitter.isRxDj;
            obj.checkboxRxSj.Value=obj.jitter.isRxSj;
            obj.editRxDCD.Value=num2str(obj.jitter.RxDCD,15);
            obj.editRxRj.Value=num2str(obj.jitter.RxRj,15);
            obj.editRxDj.Value=num2str(obj.jitter.RxDj,15);
            obj.editRxSj.Value=num2str(obj.jitter.RxSj,15);
            obj.popupmenuRxDCD.Value=obj.unit2str(obj.jitter.unitsRxDCD);
            obj.popupmenuRxRj.Value=obj.unit2str(obj.jitter.unitsRxRj);
            obj.popupmenuRxDj.Value=obj.unit2str(obj.jitter.unitsRxDj);
            obj.popupmenuRxSj.Value=obj.unit2str(obj.jitter.unitsRxSj);


            obj.checkboxRxClockRecoveryMean.Value=obj.jitter.isRxClockRecoveryMean;
            obj.checkboxRxClockRecoveryRj.Value=obj.jitter.isRxClockRecoveryRj;
            obj.checkboxRxClockRecoveryDj.Value=obj.jitter.isRxClockRecoveryDj;
            obj.checkboxRxClockRecoverySj.Value=obj.jitter.isRxClockRecoverySj;
            obj.checkboxRxClockRecoveryDCD.Value=obj.jitter.isRxClockRecoveryDCD;
            obj.editRxClockRecoveryMean.Value=num2str(obj.jitter.RxClockRecoveryMean,15);
            obj.editRxClockRecoveryRj.Value=num2str(obj.jitter.RxClockRecoveryRj,15);
            obj.editRxClockRecoveryDj.Value=num2str(obj.jitter.RxClockRecoveryDj,15);
            obj.editRxClockRecoverySj.Value=num2str(obj.jitter.RxClockRecoverySj,15);
            obj.editRxClockRecoveryDCD.Value=num2str(obj.jitter.RxClockRecoveryDCD,15);
            obj.popupmenuRxClockRecoveryMean.Value=obj.unit2str(obj.jitter.unitsRxClockRecoveryMean);
            obj.popupmenuRxClockRecoveryRj.Value=obj.unit2str(obj.jitter.unitsRxClockRecoveryRj);
            obj.popupmenuRxClockRecoveryDj.Value=obj.unit2str(obj.jitter.unitsRxClockRecoveryDj);
            obj.popupmenuRxClockRecoverySj.Value=obj.unit2str(obj.jitter.unitsRxClockRecoverySj);
            obj.popupmenuRxClockRecoveryDCD.Value=obj.unit2str(obj.jitter.unitsRxClockRecoveryDCD);


            obj.checkboxRxReceiverSensitivity.Value=obj.jitter.isRxReceiverSensitivity;
            obj.checkboxRxGaussianNoise.Value=obj.jitter.isRxGaussianNoise;
            obj.checkboxRxUniformNoise.Value=obj.jitter.isRxUniformNoise;
            obj.editRxReceiverSensitivity.Value=num2str(obj.jitter.RxReceiverSensitivity,15);
            obj.editRxGaussianNoise.Value=num2str(obj.jitter.RxGaussianNoise,15);
            obj.editRxUniformNoise.Value=num2str(obj.jitter.RxUniformNoise,15);
        end
    end

    methods(Access=private)

        function unitStr=unit2str(obj,unitIndex)
            if unitIndex==1
                unitStr=obj.unitSeconds_Text;
            else
                unitStr=obj.unitUI_Text;
            end
        end


        function createUIControls(obj)

            heights{33}=[];
            for i=1:length(heights)
                heights{i}='fit';
            end
            obj.Layout=uigridlayout(obj.Panel,'RowHeight',heights,'ColumnWidth',{'fit','1x','fit'},'Scrollable','on');


            obj.textTitle=uilabel(obj.Layout,'Text',getString(message('serdes:serdesdesigner:JitterParametersTitle')),...
            'Tag','textTitle','FontWeight','bold','FontColor',[.94,.94,.94],'BackgroundColor',[.1,.1,.8]);


            obj.textClockModeTitle=uilabel(obj.Layout,'Text',getString(message('serdes:serdesdesigner:SectionClockMode')),...
            'Tag','textClockModeTitle','FontWeight','bold');




            obj.buttonGroupIsMode=uibuttongroup(obj.Layout,'BorderType','none',...
            'Tag','buttonGroupIsMode');
            obj.radioButtonIsModeClocked=uiradiobutton(obj.buttonGroupIsMode,'Text',obj.jitter.isModeClocked_NameInGUI,...
            'Tag','radioButtonIsModeClocked','Tooltip',getString(message('serdes:serdesdesigner:Clocked_ToolTip')));
            obj.radioButtonIsModeIdeal=uiradiobutton(obj.buttonGroupIsMode,'Text',obj.jitter.isModeIdeal_NameInGUI,...
            'Tag','radioButtonIsModeIdeal','Tooltip',getString(message('serdes:serdesdesigner:Ideal_ToolTip')));
            r1Size=getRadioButtonSize(obj.radioButtonIsModeClocked);
            r2Size=getRadioButtonSize(obj.radioButtonIsModeIdeal);
            obj.radioButtonIsModeClocked.Position=[0,0,r1Size(1),r1Size(2)];
            obj.radioButtonIsModeIdeal.Position=[r1Size(1)+20,0,r2Size(1),r2Size(2)];
            obj.Layout.RowHeight{3}=max(r1Size(2),r2Size(2));


            obj.textTxJitterSpace=uilabel(obj.Layout,'Text',' ',...
            'Tag','textTxJitterSpace');
            obj.textTxJitterTitle=uilabel(obj.Layout,'Text',getString(message('serdes:serdesdesigner:SectionTxJitter')),...
            'Tag','textTxJitterTitle','FontWeight','bold');
            obj.textTxJitterName=uilabel(obj.Layout,'Text',obj.jitter.ColumnName_Text,...
            'Tag','textTxJitterName','FontWeight','bold');
            obj.textTxJitterValue=uilabel(obj.Layout,'Text',obj.jitter.ColumnValue_Text,...
            'Tag','textTxJitterValue','FontWeight','bold');
            obj.textTxJitterUnit=uilabel(obj.Layout,'Text',obj.jitter.ColumnUnit_Text,...
            'Tag','textTxJitterUnit','FontWeight','bold');
            obj.checkboxTxDCD=uicheckbox(obj.Layout,'Text',obj.jitter.TxDCD_NameInGUI,...
            'Tag','checkboxTxDCD','Tooltip',getString(message('serdes:serdesdesigner:CheckBoxTx_DCD_ToolTip')));
            obj.editTxDCD=uieditfield(obj.Layout,'Value','','UserData',obj.jitter.TxDCD_NameInGUI,...
            'Tag','editTxDCD','Tooltip',obj.editToolTip);
            obj.popupmenuTxDCD=uidropdown(obj.Layout,'Items',obj.unitOptions,'Value',obj.unitUI_Text,...
            'Tag','popupmenuTxDCD','Tooltip',obj.unitToolTip);
            obj.checkboxTxRj=uicheckbox(obj.Layout,'Text',obj.jitter.TxRj_NameInGUI,...
            'Tag','checkboxTxRj','Tooltip',getString(message('serdes:serdesdesigner:CheckBoxTx_Rj_ToolTip')));
            obj.editTxRj=uieditfield(obj.Layout,'Value','','UserData',obj.jitter.TxRj_NameInGUI,...
            'Tag','editTxRj','Tooltip',obj.editToolTip);
            obj.popupmenuTxRj=uidropdown(obj.Layout,'Items',obj.unitOptions,'Value',obj.unitUI_Text,...
            'Tag','popupmenuTxRj','Tooltip',obj.unitToolTip);
            obj.checkboxTxDj=uicheckbox(obj.Layout,'Text',obj.jitter.TxDj_NameInGUI,...
            'Tag','checkboxTxDj','Tooltip',getString(message('serdes:serdesdesigner:CheckBoxTx_Dj_ToolTip')));
            obj.editTxDj=uieditfield(obj.Layout,'Value','','UserData',obj.jitter.TxDj_NameInGUI,...
            'Tag','editTxDj','Tooltip',obj.editToolTip);
            obj.popupmenuTxDj=uidropdown(obj.Layout,'Items',obj.unitOptions,'Value',obj.unitUI_Text,...
            'Tag','popupmenuTxDj','Tooltip',obj.unitToolTip);
            obj.checkboxTxSj=uicheckbox(obj.Layout,'Text',obj.jitter.TxSj_NameInGUI,...
            'Tag','checkboxTxSj','Tooltip',getString(message('serdes:serdesdesigner:CheckBoxTx_Sj_ToolTip')));
            obj.editTxSj=uieditfield(obj.Layout,'Value','','UserData',obj.jitter.TxSj_NameInGUI,...
            'Tag','editTxSj','Tooltip',obj.editToolTip);
            obj.popupmenuTxSj=uidropdown(obj.Layout,'Items',obj.unitOptions,'Value',obj.unitUI_Text,...
            'Tag','popupmenuTxSj','Tooltip',obj.unitToolTip);
            obj.checkboxTxSjFrequency=uicheckbox(obj.Layout,'Text',obj.jitter.TxSjFrequency_NameInGUI,...
            'Tag','checkboxTxSjFrequency','Tooltip',getString(message('serdes:serdesdesigner:CheckBoxTx_Sj_Frequency_ToolTip')));
            obj.editTxSjFrequency=uieditfield(obj.Layout,'Value','','UserData',obj.jitter.TxSjFrequency_NameInGUI,...
            'Tag','editTxSjFrequency','Tooltip',obj.editToolTip);
            obj.textTxSjFrequencyUnit=uilabel(obj.Layout,'Text',obj.jitter.UnitsHz_Text,...
            'Tag','textTxSjFrequencyUnit');


            obj.textRxJitterSpace=uilabel(obj.Layout,'Text',' ',...
            'Tag','textRxJitterSpace');
            obj.textRxJitterTitle=uilabel(obj.Layout,'Text',getString(message('serdes:serdesdesigner:SectionRxJitter')),...
            'Tag','textRxJitterTitle','FontWeight','bold');
            obj.textRxJitterName=uilabel(obj.Layout,'Text',obj.jitter.ColumnName_Text,...
            'Tag','textRxJitterName','FontWeight','bold');
            obj.textRxJitterValue=uilabel(obj.Layout,'Text',obj.jitter.ColumnValue_Text,...
            'Tag','textRxJitterValue','FontWeight','bold');
            obj.textRxJitterUnit=uilabel(obj.Layout,'Text',obj.jitter.ColumnUnit_Text,...
            'Tag','textRxJitterUnit','FontWeight','bold');
            obj.checkboxRxDCD=uicheckbox(obj.Layout,'Text',obj.jitter.RxDCD_NameInGUI,...
            'Tag','checkboxRxDCD','Tooltip',getString(message('serdes:serdesdesigner:CheckBoxRx_DCD_ToolTip')));
            obj.editRxDCD=uieditfield(obj.Layout,'Value','','UserData',obj.jitter.RxDCD_NameInGUI,...
            'Tag','editRxDCD','Tooltip',obj.editToolTip);
            obj.popupmenuRxDCD=uidropdown(obj.Layout,'Items',obj.unitOptions,'Value',obj.unitUI_Text,...
            'Tag','popupmenuRxDCD','Tooltip',obj.unitToolTip);
            obj.checkboxRxRj=uicheckbox(obj.Layout,'Text',obj.jitter.RxRj_NameInGUI,...
            'Tag','checkboxRxRj','Tooltip',getString(message('serdes:serdesdesigner:CheckBoxRx_Rj_ToolTip')));
            obj.editRxRj=uieditfield(obj.Layout,'Value','','UserData',obj.jitter.RxRj_NameInGUI,...
            'Tag','editRxRj','Tooltip',obj.editToolTip);
            obj.popupmenuRxRj=uidropdown(obj.Layout,'Items',obj.unitOptions,'Value',obj.unitUI_Text,...
            'Tag','popupmenuRxRj','Tooltip',obj.unitToolTip);
            obj.checkboxRxDj=uicheckbox(obj.Layout,'Text',obj.jitter.RxDj_NameInGUI,...
            'Tag','checkboxRxDj','Tooltip',getString(message('serdes:serdesdesigner:CheckBoxRx_Dj_ToolTip')));
            obj.editRxDj=uieditfield(obj.Layout,'Value','','UserData',obj.jitter.RxDj_NameInGUI,...
            'Tag','editRxDj','Tooltip',obj.editToolTip);
            obj.popupmenuRxDj=uidropdown(obj.Layout,'Items',obj.unitOptions,'Value',obj.unitUI_Text,...
            'Tag','popupmenuRxDj','Tooltip',obj.unitToolTip);
            obj.checkboxRxSj=uicheckbox(obj.Layout,'Text',obj.jitter.RxSj_NameInGUI,...
            'Tag','checkboxRxSj','Tooltip',getString(message('serdes:serdesdesigner:CheckBoxRx_Sj_ToolTip')));
            obj.editRxSj=uieditfield(obj.Layout,'Value','','UserData',obj.jitter.RxSj_NameInGUI,...
            'Tag','editRxSj','Tooltip',obj.editToolTip);
            obj.popupmenuRxSj=uidropdown(obj.Layout,'Items',obj.unitOptions,'Value',obj.unitUI_Text,...
            'Tag','popupmenuRxSj','Tooltip',obj.unitToolTip);


            obj.textRxClockRecoveryJitterSpace=uilabel(obj.Layout,'Text',' ',...
            'Tag','textRxClockRecoveryJitterSpace');
            obj.textRxClockRecoveryJitterTitle=uilabel(obj.Layout,'Text',getString(message('serdes:serdesdesigner:SectionRxClockRecoveryJitter')),...
            'Tag','textRxClockRecoveryJitterTitle','FontWeight','bold');
            obj.textRxClockRecoveryJitterName=uilabel(obj.Layout,'Text',obj.jitter.ColumnName_Text,...
            'Tag','textRxClockRecoveryJitterName','FontWeight','bold');
            obj.textRxClockRecoveryJitterValue=uilabel(obj.Layout,'Text',obj.jitter.ColumnValue_Text,...
            'Tag','textRxClockRecoveryJitterValue','FontWeight','bold');
            obj.textRxClockRecoveryJitterUnit=uilabel(obj.Layout,'Text',obj.jitter.ColumnUnit_Text,...
            'Tag','textRxClockRecoveryJitterUnit','FontWeight','bold');
            obj.checkboxRxClockRecoveryMean=uicheckbox(obj.Layout,'Text',obj.jitter.RxClockRecoveryMean_NameInGUI,...
            'Tag','checkboxRxClockRecoveryMean','Tooltip',getString(message('serdes:serdesdesigner:CheckBoxRx_Clock_Recovery_Mean_ToolTip')));
            obj.editRxClockRecoveryMean=uieditfield(obj.Layout,'Value','','UserData',obj.jitter.RxClockRecoveryMean_NameInGUI,...
            'Tag','editRxClockRecoveryMean','Tooltip',obj.editToolTip);
            obj.popupmenuRxClockRecoveryMean=uidropdown(obj.Layout,'Items',obj.unitOptions,'Value',obj.unitUI_Text,...
            'Tag','popupmenuRxClockRecoveryMean','Tooltip',obj.unitToolTip);
            obj.checkboxRxClockRecoveryRj=uicheckbox(obj.Layout,'Text',obj.jitter.RxClockRecoveryRj_NameInGUI,...
            'Tag','checkboxRxClockRecoveryRj','Tooltip',getString(message('serdes:serdesdesigner:CheckBoxRx_Clock_Recovery_Rj_ToolTip')));
            obj.editRxClockRecoveryRj=uieditfield(obj.Layout,'Value','','UserData',obj.jitter.RxClockRecoveryRj_NameInGUI,...
            'Tag','editRxClockRecoveryRj','Tooltip',obj.editToolTip);
            obj.popupmenuRxClockRecoveryRj=uidropdown(obj.Layout,'Items',obj.unitOptions,'Value',obj.unitUI_Text,...
            'Tag','popupmenuRxClockRecoveryRj','Tooltip',obj.unitToolTip);
            obj.checkboxRxClockRecoveryDj=uicheckbox(obj.Layout,'Text',obj.jitter.RxClockRecoveryDj_NameInGUI,...
            'Tag','checkboxRxClockRecoveryDj','Tooltip',getString(message('serdes:serdesdesigner:CheckBoxRx_Clock_Recovery_Dj_ToolTip')));
            obj.editRxClockRecoveryDj=uieditfield(obj.Layout,'Value','','UserData',obj.jitter.RxClockRecoveryDj_NameInGUI,...
            'Tag','editRxClockRecoveryDj','Tooltip',obj.editToolTip);
            obj.popupmenuRxClockRecoveryDj=uidropdown(obj.Layout,'Items',obj.unitOptions,'Value',obj.unitUI_Text,...
            'Tag','popupmenuRxClockRecoveryDj','Tooltip',obj.unitToolTip);
            obj.checkboxRxClockRecoverySj=uicheckbox(obj.Layout,'Text',obj.jitter.RxClockRecoverySj_NameInGUI,...
            'Tag','checkboxRxClockRecoverySj','Tooltip',getString(message('serdes:serdesdesigner:CheckBoxRx_Clock_Recovery_Sj_ToolTip')));
            obj.editRxClockRecoverySj=uieditfield(obj.Layout,'Value','','UserData',obj.jitter.RxClockRecoverySj_NameInGUI,...
            'Tag','editRxClockRecoverySj','Tooltip',obj.editToolTip);
            obj.popupmenuRxClockRecoverySj=uidropdown(obj.Layout,'Items',obj.unitOptions,'Value',obj.unitUI_Text,...
            'Tag','popupmenuRxClockRecoverySj','Tooltip',obj.unitToolTip);
            obj.checkboxRxClockRecoveryDCD=uicheckbox(obj.Layout,'Text',obj.jitter.RxClockRecoveryDCD_NameInGUI,...
            'Tag','checkboxRxClockRecoveryDCD','Tooltip',getString(message('serdes:serdesdesigner:CheckBoxRx_Clock_Recovery_DCD_ToolTip')));
            obj.editRxClockRecoveryDCD=uieditfield(obj.Layout,'Value','','UserData',obj.jitter.RxClockRecoveryDCD_NameInGUI,...
            'Tag','editRxClockRecoveryDCD','Tooltip',obj.editToolTip);
            obj.popupmenuRxClockRecoveryDCD=uidropdown(obj.Layout,'Items',obj.unitOptions,'Value',obj.unitUI_Text,...
            'Tag','popupmenuRxClockRecoveryDCD','Tooltip',obj.unitToolTip);


            obj.textRxNoiseSpace=uilabel(obj.Layout,'Text',' ',...
            'Tag','textRxNoiseSpace');
            obj.textRxNoiseTitle=uilabel(obj.Layout,'Text',getString(message('serdes:serdesdesigner:SectionRxNoise')),...
            'Tag','textRxNoiseTitle','FontWeight','bold');
            obj.textRxNoiseName=uilabel(obj.Layout,'Text',obj.jitter.ColumnName_Text,...
            'Tag','textRxNoiseName','FontWeight','bold');
            obj.textRxNoiseValue=uilabel(obj.Layout,'Text',obj.jitter.ColumnValue_Text,...
            'Tag','textRxNoiseValue','FontWeight','bold');
            obj.textRxNoiseUnit=uilabel(obj.Layout,'Text',obj.jitter.ColumnUnit_Text,...
            'Tag','textRxNoiseUnit','FontWeight','bold');
            obj.checkboxRxReceiverSensitivity=uicheckbox(obj.Layout,'Text',obj.jitter.RxReceiverSensitivity_NameInGUI,...
            'Tag','checkboxRxReceiverSensitivity','Tooltip',getString(message('serdes:serdesdesigner:CheckBoxRx_Receiver_Sensitivity_ToolTip')));
            obj.editRxReceiverSensitivity=uieditfield(obj.Layout,'Value','','UserData',obj.jitter.RxReceiverSensitivity_NameInGUI,...
            'Tag','editRxReceiverSensitivity','Tooltip',obj.editToolTip);
            obj.textRxReceiverSensitivityUnit=uilabel(obj.Layout,'Text',obj.jitter.UnitsVolts_Text,...
            'Tag','textRxReceiverSensitivityUnit');
            obj.checkboxRxGaussianNoise=uicheckbox(obj.Layout,'Text',obj.jitter.RxGaussianNoise_NameInGUI,...
            'Tag','checkboxRxGaussianNoise','Tooltip',getString(message('serdes:serdesdesigner:CheckBoxRx_GaussianNoise_ToolTip')));
            obj.editRxGaussianNoise=uieditfield(obj.Layout,'Value','','UserData',obj.jitter.RxGaussianNoise_NameInGUI,...
            'Tag','editRxGaussianNoise','Tooltip',obj.editToolTip);
            obj.textRxGaussianNoiseUnit=uilabel(obj.Layout,'Text',obj.jitter.UnitsVolts_Text,...
            'Tag','textRxGaussianNoiseUnit');
            obj.checkboxRxUniformNoise=uicheckbox(obj.Layout,'Text',obj.jitter.RxUniformNoise_NameInGUI,...
            'Tag','checkboxRxUniformNoise','Tooltip',getString(message('serdes:serdesdesigner:CheckBoxRx_UniformNoise_ToolTip')));
            obj.editRxUniformNoise=uieditfield(obj.Layout,'Value','','UserData',obj.jitter.RxUniformNoise_NameInGUI,...
            'Tag','editRxUniformNoise','Tooltip',obj.editToolTip);
            obj.textRxUniformNoiseUnit=uilabel(obj.Layout,'Text',obj.jitter.UnitsVolts_Text,...
            'Tag','textRxUniformNoiseUnit');


            obj.textParametersNotUsed=uilabel(obj.Layout,'Text',getString(message('serdes:serdesdesigner:ParameterNotUsed')),...
            'Tag','textParametersNotUsed','HorizontalAlignment','center');


            obj.ParameterEdits={...
...
            obj.buttonGroupIsMode,...
            obj.radioButtonIsModeClocked,...
            obj.radioButtonIsModeIdeal,...
...
...
            obj.checkboxTxDCD,...
            obj.checkboxTxRj,...
            obj.checkboxTxDj,...
            obj.checkboxTxSj,...
            obj.checkboxTxSjFrequency,...
            obj.editTxDCD,...
            obj.editTxRj,...
            obj.editTxDj,...
            obj.editTxSj,...
            obj.editTxSjFrequency,...
            obj.popupmenuTxDCD,...
            obj.popupmenuTxRj,...
            obj.popupmenuTxDj,...
            obj.popupmenuTxSj,...
...
...
            obj.checkboxRxDCD,...
            obj.checkboxRxRj,...
            obj.checkboxRxDj,...
            obj.checkboxRxSj,...
            obj.editRxDCD,...
            obj.editRxRj,...
            obj.editRxDj,...
            obj.editRxSj,...
            obj.popupmenuRxDCD,...
            obj.popupmenuRxRj,...
            obj.popupmenuRxDj,...
            obj.popupmenuRxSj,...
...
...
            obj.checkboxRxClockRecoveryMean,...
            obj.checkboxRxClockRecoveryRj,...
            obj.checkboxRxClockRecoveryDj,...
            obj.checkboxRxClockRecoverySj,...
            obj.checkboxRxClockRecoveryDCD,...
            obj.editRxClockRecoveryMean,...
            obj.editRxClockRecoveryRj,...
            obj.editRxClockRecoveryDj,...
            obj.editRxClockRecoverySj,...
            obj.editRxClockRecoveryDCD,...
            obj.popupmenuRxClockRecoveryMean,...
            obj.popupmenuRxClockRecoveryRj,...
            obj.popupmenuRxClockRecoveryDj,...
            obj.popupmenuRxClockRecoverySj,...
            obj.popupmenuRxClockRecoveryDCD,...
...
...
            obj.checkboxRxReceiverSensitivity,...
            obj.checkboxRxGaussianNoise,...
            obj.checkboxRxUniformNoise,...
            obj.editRxReceiverSensitivity,...
            obj.editRxGaussianNoise,...
            obj.editRxUniformNoise,...
            };


            obj.ParameterLabels={...
...
            obj.textTitle,...
...
...
            obj.textClockModeTitle,...
...
...
            obj.textTxJitterSpace,...
            obj.textTxJitterTitle,...
            obj.textTxJitterName,...
            obj.textTxJitterValue,...
            obj.textTxJitterUnit,...
            obj.textTxSjFrequencyUnit,...
...
...
            obj.textRxJitterSpace,...
            obj.textRxJitterTitle,...
            obj.textRxJitterName,...
            obj.textRxJitterValue,...
            obj.textRxJitterUnit,...
...
...
            obj.textRxClockRecoveryJitterSpace,...
            obj.textRxClockRecoveryJitterTitle,...
            obj.textRxClockRecoveryJitterName,...
            obj.textRxClockRecoveryJitterValue,...
            obj.textRxClockRecoveryJitterUnit,...
...
...
            obj.textRxNoiseSpace,...
            obj.textRxNoiseTitle,...
            obj.textRxNoiseName,...
            obj.textRxNoiseValue,...
            obj.textRxNoiseUnit,...
            obj.textRxReceiverSensitivityUnit,...
            obj.textRxGaussianNoiseUnit,...
            obj.textRxUniformNoiseUnit,...
...
...
            obj.textParametersNotUsed,...
            };
        end
        function deleteUIControls(obj)
            if~isempty(obj.ParameterEdits)
                for i=numel(obj.ParameterEdits):-1:1
                    if~isempty(obj.ParameterEdits{i})&&isvalid(obj.ParameterEdits{i})
                        delete(obj.ParameterEdits{i});
                    end
                end
            end
            if~isempty(obj.ParameterLabels)
                for i=numel(obj.ParameterLabels):-1:1
                    if~isempty(obj.ParameterLabels{i})&&isvalid(obj.ParameterLabels{i})
                        delete(obj.ParameterLabels{i});
                    end
                end
            end
        end


        function layoutUIControls(obj)
            row=0;


            row=row+1;
            obj.textTitle.Layout.Row=row;
            obj.textTitle.Layout.Column=[1,3];


            row=row+1;
            obj.textClockModeTitle.Layout.Row=row;
            obj.textClockModeTitle.Layout.Column=[1,3];
            row=row+1;
            obj.buttonGroupIsMode.Layout.Row=row;
            obj.buttonGroupIsMode.Layout.Column=[1,3];


            row=row+1;
            obj.textTxJitterSpace.Layout.Row=row;
            obj.textTxJitterSpace.Layout.Column=[1,3];
            row=row+1;
            obj.textTxJitterTitle.Layout.Row=row;
            obj.textTxJitterTitle.Layout.Column=[1,3];
            row=row+1;
            obj.textTxJitterName.Layout.Row=row;
            obj.textTxJitterName.Layout.Column=1;
            obj.textTxJitterValue.Layout.Row=row;
            obj.textTxJitterValue.Layout.Column=2;
            obj.textTxJitterUnit.Layout.Row=row;
            obj.textTxJitterUnit.Layout.Column=3;
            row=row+1;
            obj.checkboxTxDCD.Layout.Row=row;
            obj.checkboxTxDCD.Layout.Column=1;
            obj.editTxDCD.Layout.Row=row;
            obj.editTxDCD.Layout.Column=2;
            obj.popupmenuTxDCD.Layout.Row=row;
            obj.popupmenuTxDCD.Layout.Column=3;
            row=row+1;
            obj.checkboxTxRj.Layout.Row=row;
            obj.checkboxTxRj.Layout.Column=1;
            obj.editTxRj.Layout.Row=row;
            obj.editTxRj.Layout.Column=2;
            obj.popupmenuTxRj.Layout.Row=row;
            obj.popupmenuTxRj.Layout.Column=3;
            row=row+1;
            obj.checkboxTxDj.Layout.Row=row;
            obj.checkboxTxDj.Layout.Column=1;
            obj.editTxDj.Layout.Row=row;
            obj.editTxDj.Layout.Column=2;
            obj.popupmenuTxDj.Layout.Row=row;
            obj.popupmenuTxDj.Layout.Column=3;
            row=row+1;
            obj.checkboxTxSj.Layout.Row=row;
            obj.checkboxTxSj.Layout.Column=1;
            obj.editTxSj.Layout.Row=row;
            obj.editTxSj.Layout.Column=2;
            obj.popupmenuTxSj.Layout.Row=row;
            obj.popupmenuTxSj.Layout.Column=3;
            row=row+1;
            obj.checkboxTxSjFrequency.Layout.Row=row;
            obj.checkboxTxSjFrequency.Layout.Column=1;
            obj.editTxSjFrequency.Layout.Row=row;
            obj.editTxSjFrequency.Layout.Column=2;
            obj.textTxSjFrequencyUnit.Layout.Row=row;
            obj.textTxSjFrequencyUnit.Layout.Column=3;


            row=row+1;
            obj.textRxJitterSpace.Layout.Row=row;
            obj.textRxJitterSpace.Layout.Column=[1,3];
            row=row+1;
            obj.textRxJitterTitle.Layout.Row=row;
            obj.textRxJitterTitle.Layout.Column=[1,3];
            row=row+1;
            obj.textRxJitterName.Layout.Row=row;
            obj.textRxJitterName.Layout.Column=1;
            obj.textRxJitterValue.Layout.Row=row;
            obj.textRxJitterValue.Layout.Column=2;
            obj.textRxJitterUnit.Layout.Row=row;
            obj.textRxJitterUnit.Layout.Column=3;
            row=row+1;
            obj.checkboxRxDCD.Layout.Row=row;
            obj.checkboxRxDCD.Layout.Column=1;
            obj.editRxDCD.Layout.Row=row;
            obj.editRxDCD.Layout.Column=2;
            obj.popupmenuRxDCD.Layout.Row=row;
            obj.popupmenuRxDCD.Layout.Column=3;
            row=row+1;
            obj.checkboxRxRj.Layout.Row=row;
            obj.checkboxRxRj.Layout.Column=1;
            obj.editRxRj.Layout.Row=row;
            obj.editRxRj.Layout.Column=2;
            obj.popupmenuRxRj.Layout.Row=row;
            obj.popupmenuRxRj.Layout.Column=3;
            row=row+1;
            obj.checkboxRxDj.Layout.Row=row;
            obj.checkboxRxDj.Layout.Column=1;
            obj.editRxDj.Layout.Row=row;
            obj.editRxDj.Layout.Column=2;
            obj.popupmenuRxDj.Layout.Row=row;
            obj.popupmenuRxDj.Layout.Column=3;
            row=row+1;
            obj.checkboxRxSj.Layout.Row=row;
            obj.checkboxRxSj.Layout.Column=1;
            obj.editRxSj.Layout.Row=row;
            obj.editRxSj.Layout.Column=2;
            obj.popupmenuRxSj.Layout.Row=row;
            obj.popupmenuRxSj.Layout.Column=3;


            row=row+1;
            obj.textRxClockRecoveryJitterSpace.Layout.Row=row;
            obj.textRxClockRecoveryJitterSpace.Layout.Column=[1,3];
            row=row+1;
            obj.textRxClockRecoveryJitterTitle.Layout.Row=row;
            obj.textRxClockRecoveryJitterTitle.Layout.Column=[1,3];
            row=row+1;
            obj.textRxClockRecoveryJitterName.Layout.Row=row;
            obj.textRxClockRecoveryJitterName.Layout.Column=1;
            obj.textRxClockRecoveryJitterValue.Layout.Row=row;
            obj.textRxClockRecoveryJitterValue.Layout.Column=2;
            obj.textRxClockRecoveryJitterUnit.Layout.Row=row;
            obj.textRxClockRecoveryJitterUnit.Layout.Column=3;
            row=row+1;
            obj.checkboxRxClockRecoveryMean.Layout.Row=row;
            obj.checkboxRxClockRecoveryMean.Layout.Column=1;
            obj.editRxClockRecoveryMean.Layout.Row=row;
            obj.editRxClockRecoveryMean.Layout.Column=2;
            obj.popupmenuRxClockRecoveryMean.Layout.Row=row;
            obj.popupmenuRxClockRecoveryMean.Layout.Column=3;
            row=row+1;
            obj.checkboxRxClockRecoveryRj.Layout.Row=row;
            obj.checkboxRxClockRecoveryRj.Layout.Column=1;
            obj.editRxClockRecoveryRj.Layout.Row=row;
            obj.editRxClockRecoveryRj.Layout.Column=2;
            obj.popupmenuRxClockRecoveryRj.Layout.Row=row;
            obj.popupmenuRxClockRecoveryRj.Layout.Column=3;
            row=row+1;
            obj.checkboxRxClockRecoveryDj.Layout.Row=row;
            obj.checkboxRxClockRecoveryDj.Layout.Column=1;
            obj.editRxClockRecoveryDj.Layout.Row=row;
            obj.editRxClockRecoveryDj.Layout.Column=2;
            obj.popupmenuRxClockRecoveryDj.Layout.Row=row;
            obj.popupmenuRxClockRecoveryDj.Layout.Column=3;
            row=row+1;
            obj.checkboxRxClockRecoverySj.Layout.Row=row;
            obj.checkboxRxClockRecoverySj.Layout.Column=1;
            obj.editRxClockRecoverySj.Layout.Row=row;
            obj.editRxClockRecoverySj.Layout.Column=2;
            obj.popupmenuRxClockRecoverySj.Layout.Row=row;
            obj.popupmenuRxClockRecoverySj.Layout.Column=3;
            row=row+1;
            obj.checkboxRxClockRecoveryDCD.Layout.Row=row;
            obj.checkboxRxClockRecoveryDCD.Layout.Column=1;
            obj.editRxClockRecoveryDCD.Layout.Row=row;
            obj.editRxClockRecoveryDCD.Layout.Column=2;
            obj.popupmenuRxClockRecoveryDCD.Layout.Row=row;
            obj.popupmenuRxClockRecoveryDCD.Layout.Column=3;


            row=row+1;
            obj.textRxNoiseSpace.Layout.Row=row;
            obj.textRxNoiseSpace.Layout.Column=[1,3];
            row=row+1;
            obj.textRxNoiseTitle.Layout.Row=row;
            obj.textRxNoiseTitle.Layout.Column=[1,3];
            row=row+1;
            obj.textRxNoiseName.Layout.Row=row;
            obj.textRxNoiseName.Layout.Column=1;
            obj.textRxNoiseValue.Layout.Row=row;
            obj.textRxNoiseValue.Layout.Column=2;
            obj.textRxNoiseUnit.Layout.Row=row;
            obj.textRxNoiseUnit.Layout.Column=3;
            row=row+1;
            obj.checkboxRxReceiverSensitivity.Layout.Row=row;
            obj.checkboxRxReceiverSensitivity.Layout.Column=1;
            obj.editRxReceiverSensitivity.Layout.Row=row;
            obj.editRxReceiverSensitivity.Layout.Column=2;
            obj.textRxReceiverSensitivityUnit.Layout.Row=row;
            obj.textRxReceiverSensitivityUnit.Layout.Column=3;
            row=row+1;
            obj.checkboxRxGaussianNoise.Layout.Row=row;
            obj.checkboxRxGaussianNoise.Layout.Column=1;
            obj.editRxGaussianNoise.Layout.Row=row;
            obj.editRxGaussianNoise.Layout.Column=2;
            obj.textRxGaussianNoiseUnit.Layout.Row=row;
            obj.textRxGaussianNoiseUnit.Layout.Column=3;
            row=row+1;
            obj.checkboxRxUniformNoise.Layout.Row=row;
            obj.checkboxRxUniformNoise.Layout.Column=1;
            obj.editRxUniformNoise.Layout.Row=row;
            obj.editRxUniformNoise.Layout.Column=2;
            obj.textRxUniformNoiseUnit.Layout.Row=row;
            obj.textRxUniformNoiseUnit.Layout.Column=3;


            row=row+1;
            obj.textParametersNotUsed.Layout.Row=row;
            obj.textParametersNotUsed.Layout.Column=[1,3];
        end


        function addListeners(obj)
            if~isempty(obj.Panel)

                obj.Panel.SizeChangedFcn=@(h,e)sizeChanged(obj,e);
            end
            if~isempty(obj.ParameterEdits)

                for i=1:numel(obj.ParameterEdits)
                    if strcmpi(obj.ParameterEdits{i}.Type,'uicheckbox')||...
                        strcmpi(obj.ParameterEdits{i}.Type,'uidropdown')||...
                        strcmpi(obj.ParameterEdits{i}.Type,'uieditfield')
                        obj.ParameterEdits{i}.ValueChangedFcn=@(h,e)parameterChanged(obj,e);
                    elseif strcmpi(obj.ParameterEdits{i}.Type,'uibuttongroup')
                        obj.ParameterEdits{i}.SelectionChangedFcn=@(h,e)parameterChanged(obj,e);
                    end
                end
            end
        end
        function removeListeners(obj)
            if~isempty(obj.Panel)

                obj.Panel.SizeChangedFcn='';
            end
            if~isempty(obj.ParameterEdits)

                for i=1:numel(obj.ParameterEdits)
                    if strcmpi(obj.ParameterEdits{i}.Type,'uicheckbox')||...
                        strcmpi(obj.ParameterEdits{i}.Type,'uidropdown')||...
                        strcmpi(obj.ParameterEdits{i}.Type,'uieditfield')
                        obj.ParameterEdits{i}.ValueChangedFcn='';
                    elseif strcmpi(obj.ParameterEdits{i}.Type,'uibuttongroup')
                        obj.ParameterEdits{i}.SelectionChangedFcn='';
                    end
                end
            end
        end


        function parameterChanged(obj,e)
            if isempty(e)||isempty(e.Source)||isempty(e.Source.Tag)
                return;
            end
            switch e.Source.Tag
            case 'buttonGroupIsMode'
                obj.jitter.isModeClocked=obj.getRadioButtonValue(obj.radioButtonIsModeClocked);
                obj.jitter.isModeIdeal=obj.getRadioButtonValue(obj.radioButtonIsModeIdeal);
            case 'checkboxTxDCD'
                obj.jitter.isTxDCD=obj.getCheckboxValue(e.Source);
            case 'checkboxTxRj'
                obj.jitter.isTxRj=obj.getCheckboxValue(e.Source);
            case 'checkboxTxDj'
                obj.jitter.isTxDj=obj.getCheckboxValue(e.Source);
            case 'checkboxTxSj'
                obj.jitter.isTxSj=obj.getCheckboxValue(e.Source);
            case 'checkboxTxSjFrequency'
                obj.jitter.isTxSjFrequency=obj.getCheckboxValue(e.Source);
            case 'editTxDCD'
                obj.jitter.TxDCD=obj.getEditValue(e.Source,obj.jitter.TxDCD);
            case 'editTxRj'
                obj.jitter.TxRj=obj.getEditValue(e.Source,obj.jitter.TxRj);
            case 'editTxDj'
                obj.jitter.TxDj=obj.getEditValue(e.Source,obj.jitter.TxDj);
            case 'editTxSj'
                obj.jitter.TxSj=obj.getEditValue(e.Source,obj.jitter.TxSj);
            case 'editTxSjFrequency'
                obj.jitter.TxSjFrequency=obj.getEditValue(e.Source,obj.jitter.TxSjFrequency);
            case 'popupmenuTxDCD'
                obj.jitter.unitsTxDCD=obj.getPopupMenuValue(e.Source);
            case 'popupmenuTxRj'
                obj.jitter.unitsTxRj=obj.getPopupMenuValue(e.Source);
            case 'popupmenuTxDj'
                obj.jitter.unitsTxDj=obj.getPopupMenuValue(e.Source);
            case 'popupmenuTxSj'
                obj.jitter.unitsTxSj=obj.getPopupMenuValue(e.Source);
            case 'checkboxRxDCD'
                obj.jitter.isRxDCD=obj.getCheckboxValue(e.Source);
            case 'checkboxRxRj'
                obj.jitter.isRxRj=obj.getCheckboxValue(e.Source);
            case 'checkboxRxDj'
                obj.jitter.isRxDj=obj.getCheckboxValue(e.Source);
            case 'checkboxRxSj'
                obj.jitter.isRxSj=obj.getCheckboxValue(e.Source);
            case 'editRxDCD'
                obj.jitter.RxDCD=obj.getEditValue(e.Source,obj.jitter.RxDCD);
            case 'editRxRj'
                obj.jitter.RxRj=obj.getEditValue(e.Source,obj.jitter.RxRj);
            case 'editRxDj'
                obj.jitter.RxDj=obj.getEditValue(e.Source,obj.jitter.RxDj);
            case 'editRxSj'
                obj.jitter.RxSj=obj.getEditValue(e.Source,obj.jitter.RxSj);
            case 'popupmenuRxDCD'
                obj.jitter.unitsRxDCD=obj.getPopupMenuValue(e.Source);
            case 'popupmenuRxRj'
                obj.jitter.unitsRxRj=obj.getPopupMenuValue(e.Source);
            case 'popupmenuRxDj'
                obj.jitter.unitsRxDj=obj.getPopupMenuValue(e.Source);
            case 'popupmenuRxSj'
                obj.jitter.unitsRxSj=obj.getPopupMenuValue(e.Source);
            case 'checkboxRxClockRecoveryMean'
                obj.jitter.isRxClockRecoveryMean=obj.getCheckboxValue(e.Source);
            case 'checkboxRxClockRecoveryRj'
                obj.jitter.isRxClockRecoveryRj=obj.getCheckboxValue(e.Source);
            case 'checkboxRxClockRecoveryDj'
                obj.jitter.isRxClockRecoveryDj=obj.getCheckboxValue(e.Source);
            case 'checkboxRxClockRecoverySj'
                obj.jitter.isRxClockRecoverySj=obj.getCheckboxValue(e.Source);
            case 'checkboxRxClockRecoveryDCD'
                obj.jitter.isRxClockRecoveryDCD=obj.getCheckboxValue(e.Source);
            case 'editRxClockRecoveryMean'
                obj.jitter.RxClockRecoveryMean=obj.getEditValue(e.Source,obj.jitter.RxClockRecoveryMean);
            case 'editRxClockRecoveryRj'
                obj.jitter.RxClockRecoveryRj=obj.getEditValue(e.Source,obj.jitter.RxClockRecoveryRj);
            case 'editRxClockRecoveryDj'
                obj.jitter.RxClockRecoveryDj=obj.getEditValue(e.Source,obj.jitter.RxClockRecoveryDj);
            case 'editRxClockRecoverySj'
                obj.jitter.RxClockRecoverySj=obj.getEditValue(e.Source,obj.jitter.RxClockRecoverySj);
            case 'editRxClockRecoveryDCD'
                obj.jitter.RxClockRecoveryDCD=obj.getEditValue(e.Source,obj.jitter.RxClockRecoveryDCD);
            case 'popupmenuRxClockRecoveryMean'
                obj.jitter.unitsRxClockRecoveryMean=obj.getPopupMenuValue(e.Source);
            case 'popupmenuRxClockRecoveryRj'
                obj.jitter.unitsRxClockRecoveryRj=obj.getPopupMenuValue(e.Source);
            case 'popupmenuRxClockRecoveryDj'
                obj.jitter.unitsRxClockRecoveryDj=obj.getPopupMenuValue(e.Source);
            case 'popupmenuRxClockRecoverySj'
                obj.jitter.unitsRxClockRecoverySj=obj.getPopupMenuValue(e.Source);
            case 'popupmenuRxClockRecoveryDCD'
                obj.jitter.unitsRxClockRecoveryDCD=obj.getPopupMenuValue(e.Source);
            case 'checkboxRxReceiverSensitivity'
                obj.jitter.isRxReceiverSensitivity=obj.getCheckboxValue(e.Source);
            case 'checkboxRxGaussianNoise'
                obj.jitter.isRxGaussianNoise=obj.getCheckboxValue(e.Source);
            case 'checkboxRxUniformNoise'
                obj.jitter.isRxUniformNoise=obj.getCheckboxValue(e.Source);
            case 'editRxReceiverSensitivity'
                obj.jitter.RxReceiverSensitivity=obj.getEditValue(e.Source,obj.jitter.RxReceiverSensitivity);
            case 'editRxGaussianNoise'
                obj.jitter.RxGaussianNoise=obj.getEditValue(e.Source,obj.jitter.RxGaussianNoise);
            case 'editRxUniformNoise'
                obj.jitter.RxUniformNoise=obj.getEditValue(e.Source,obj.jitter.RxUniformNoise);
            end
        end
        function value=getRadioButtonValue(obj,widget)
            value=widget.Value;
            obj.setModelChanged(widget,value);
        end
        function value=getCheckboxValue(obj,widget)
            value=widget.Value;
            obj.setModelChanged(widget,value);
        end
        function value=getPopupMenuValue(obj,widget)
            value=widget.Value;
            obj.setModelChanged(widget,value);
        end
        function value=getEditValue(obj,widget,lastParamValue)
            try
                value=str2num(widget.Value);%#ok<ST2NM> %str2double fails for '0,1' input.  g2218572
                if any(isnan(value))||isempty(value)

                    obj.badEditValue(...
                    getString(message('serdes:serdesdesigner:NonNumericEntryMessage',widget.Value,widget.UserData)),...
                    widget,lastParamValue);
                    value=lastParamValue;
                else

                    validateattributes(value,{'numeric'},{'nonempty','finite','real','nonnan','nonnegative','scalar'},'',widget.UserData);
                    obj.setModelChanged(widget,value);
                end
            catch err

                obj.badEditValue(err.message,widget,lastParamValue);
                value=lastParamValue;
            end
        end
        function badEditValue(obj,errMsg,widget,lastParamValue)

            title=getString(message('serdes:serdesdesigner:BadEntryTitle'));
            h=errordlg(errMsg,title,'modal');
            uiwait(h);


            widget.Value=num2str(lastParamValue,15);
        end
        function setModelChanged(obj,widget,value)
            obj.Parent.notify('ElementParameterChanged',...
            serdes.internal.apps.serdesdesigner.ElementParameterChangedEventData(NaN,widget.Tag,value));
        end


        function sizeChanged(obj,e)
            if obj.Panel.Position(3)<350
                obj.Layout.ColumnWidth{2}=50;
            else
                obj.Layout.ColumnWidth{2}='1x';
            end
        end
    end
end

function size=getRadioButtonSize(rbtn)
    pos=getRadioButtonTextSize(rbtn);
    radioBtnGap=17;
    size=[ceil(pos(3)+radioBtnGap),ceil(pos(4))];
end
function position=getRadioButtonTextSize(rbtn)
    persistent ax;
    persistent txtObj;
    if isempty(ax)||isempty(txtObj)
        ax=uiaxes('Parent',[],'Units','pixels','Visible','off','Internal',true);
        txtObj=text(ax,1,1,'','Units','pixels','FontUnits','pixels','Internal',true);
    end

    p=rbtn.Parent;
    ax.Parent=p;
    txtObj.String=rbtn.Text;

    props=["FontName","FontSize","FontAngle","FontWeight"];
    for propi=1:length(props)
        txtObj.(props(propi))=rbtn.(props(propi));
    end

    position=txtObj.Extent;
    ax.Parent=[];
end
