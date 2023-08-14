function dlgStruct=DualScaledParameterDDG(obj,dlgStructBase)






    dlgStruct=dlgStructBase;
    tabBase=dlgStruct.Items{1,1}.Tabs{1,1};
    tabCal=dlgStruct.Items{1,1}.Tabs{1,3};
    tabCodeGen=dlgStruct.Items{1,1}.Tabs{1,2};

    tabBase.Name=DAStudio.message('Simulink:dialog:MainAttributesPrompt');
    tabCal.Name=DAStudio.message('Simulink:dialog:CalibrationAttributesPrompt');
    tabCalItems=tabCal.Items{1}.Items;













    propItemNum=numel(tabCalItems)/2;

    startIndex=propItemNum+1;
    offset=0;

    tabCalItems{startIndex}.Name=DAStudio.message('Simulink:dialog:CalibrationDataValuePrompt');
    tabCalItems{startIndex+1}.Name=DAStudio.message('Simulink:dialog:CalibrationDataMinimumPrompt');
    tabCalItems{startIndex+2}.Name=DAStudio.message('Simulink:dialog:CalibrationDataMaximumPrompt');
    tabCalItems{startIndex+3}.Name=DAStudio.message('Simulink:dialog:CalibrationDataNumeratorPrompt');
    tabCalItems{startIndex+4}.Name=DAStudio.message('Simulink:dialog:CalibrationDataDenominatorPrompt');
    tabCalItems{startIndex+5}.Name=DAStudio.message('Simulink:dialog:CalibrationDataNamePrompt');
    tabCalItems{startIndex+6}.Name=DAStudio.message('Simulink:dialog:CalibrationDataUnitsPrompt');
    tabCalItems{startIndex+7}.Name=DAStudio.message('Simulink:dialog:CalibrationDataValidation');
    tabCalItems{startIndex+7}.Enabled=1;
    tabCalItems{startIndex+8}.Name=DAStudio.message('Simulink:dialog:CalibrationDataMessage');
    tabCalItems{startIndex+8}.Enabled=1;



    tabCal.Items{1}.LayoutGrid=[8,4];

    for i=1:propItemNum
        tabCalItems{i}.ColSpan=[2,4];
    end


    CalibrationMinIdx=2+offset;
    CalibrationMaxIdx=3+offset;
    step=propItemNum;
    CalibrationMinLblIdx=2+step+offset;
    CalibrationMaxLblIdx=3+step+offset;

    tabCalItems{CalibrationMaxIdx}.RowSpan=tabCalItems{CalibrationMinIdx}.RowSpan;

    tabCalItems{CalibrationMaxLblIdx}.RowSpan=tabCalItems{CalibrationMinLblIdx}.RowSpan;

    tabCalItems{CalibrationMinIdx}.ColSpan=[2,2];
    tabCalItems{CalibrationMinLblIdx}.ColSpan=[1,1];
    tabCalItems{CalibrationMaxIdx}.ColSpan=[4,4];
    tabCalItems{CalibrationMaxLblIdx}.ColSpan=[3,3];



    IsConfigurationValidIdx=8+offset;
    DiagnosticMessageIdx=9+offset;
    IsConfigurationValidLblIdx=8+step+offset;
    DiagnosticMessageLblIdx=9+step+offset;
    IsConfigurationValid=tabCalItems{IsConfigurationValidIdx};
    DiagnosticMessage=tabCalItems{DiagnosticMessageIdx};
    IsConfigurationValidLbl=tabCalItems{IsConfigurationValidLblIdx};
    DiagnosticMessageLbl=tabCalItems{DiagnosticMessageLblIdx};

    tabCalItems([IsConfigurationValidIdx,DiagnosticMessageIdx,...
    IsConfigurationValidLblIdx,DiagnosticMessageLblIdx])=[];

    IsConfigurationValid.Bold=1;

    DiagnosticMessage.Type='editarea';
    DiagnosticMessage.WordWrap=1;

    grpVandD.Items={};
    grpVandD.Items{1}=IsConfigurationValid;
    grpVandD.Items{2}=DiagnosticMessage;
    grpVandD.Items{3}=IsConfigurationValidLbl;
    grpVandD.Items{4}=DiagnosticMessageLbl;

    grpVandD.Name=DAStudio.message('Simulink:dialog:ConfigurationValidationAndDiagnosticPrompt');
    grpVandD.Type='group';
    grpVandD.LayoutGrid=[2,2];
    grpVandD.RowSpan=[2,2];
    grpVandD.ColSpan=[1,2];
    grpVandD.Source=obj;
    grpVandD.Tag='GrpVandD';


    tabCal.Items{1}.Items=tabCalItems;
    tabCal.Items{3}=tabCal.Items{2};
    tabCal.Items{2}=grpVandD;

    tabCal.LayoutGrid=tabCal.LayoutGrid+[1,0];
    tabCal.Items{3}.RowSpan=tabCal.Items{3}.RowSpan+[1,0];

    dlgStruct.Items{1,1}.Tabs{1,1}=tabCal;
    dlgStruct.Items{1,1}.Tabs{1,2}=tabBase;
    dlgStruct.Items{1,1}.Tabs{1,3}=tabCodeGen;
    dlgStruct.HelpArgs=obj.getHelpLink();

end


