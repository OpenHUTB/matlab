function dlgstruct=getDialogSchema(this,mdlName)







    dialogTitle=[DAStudio.message('Simulink:utility:VariantConditionLegendTitle'),': ',mdlName];
    dlgstruct.DialogTitle=dialogTitle;


    dlgstruct.DialogTag=mdlName;
    dlgstruct.CloseCallback='closeLegend';
    dlgstruct.CloseArgs={this,mdlName};
    dlgstruct.EmbeddedButtonSet={''};
    dlgstruct.StandaloneButtonSet={''};



    buttonPanel.Type='panel';
    buttonPanel.Name='';
    buttonPanel.RowSpan=[3,3];
    buttonPanel.ColSpan=[1,1];
    buttonPanel.Alignment=10;


    legendData=get_param(mdlName,'VariantAnnotations');
    varCondReady=get_param(mdlName,'VariantAnnotationsAreReady');

    if isempty(legendData)&&strcmp(varCondReady,'off')
        constructDialogWithNoSpreadsheetData(mdlName);

    elseif isempty(legendData)&&strcmp(varCondReady,'on')
        constructDialogWithNoSpreadsheetData(mdlName);

    else
        dlgstructChild.Items=cell(1,3);

        printButton.Type='pushbutton';
        printButton.Name=DAStudio.message('Simulink:utility:LegendPrint');
        printButton.MatlabMethod='printLegend';
        printButton.MatlabArgs={this,mdlName};
        printButton.RowSpan=[1,1];
        printButton.ColSpan=[1,1];
        printButton.Tag='PrintButtonTAG';
        printButton.ToolTip=...
        DAStudio.message('Simulink:utility:VariantLegendPrintTooltip');
        printButton.Alignment=1;
        buttonPanel.Items{1}=printButton;

        helpButton.Type='pushbutton';
        helpButton.Name=DAStudio.message('Simulink:utility:SEMenuHelp');
        helpButton.MatlabMethod='helpview';
        helpButton.MatlabArgs={[docroot,'/toolbox/simulink/helptargets.map'],...
        'conditionannotation'};

        helpButton.RowSpan=[1,1];
        helpButton.ColSpan=[2,2];
        helpButton.Tag='HelpButtonTAG';
        helpButton.Alignment=1;
        buttonPanel.Items{2}=helpButton;
        buttonPanel.LayoutGrid=[1,2];
        dlgstructChild.Items{1}=buttonPanel;

        [dlgstructChild.Items{2},dlgstructChild.Items{3}]=constructSpreadSheetAndFilterPanel(mdlName);

        dlgstruct.LayoutGrid=[3,1];
        dlgstruct.RowStretch=[0,1,0];
        dlgstruct.ColStretch=0;


        dlgstruct.Items={dlgstructChild.Items{1},dlgstructChild.Items{2},dlgstructChild.Items{3}};


    end

    function constructDialogWithNoSpreadsheetData(mdlName)








        printButton.Type='pushbutton';
        printButton.Name=DAStudio.message('Simulink:utility:LegendPrint');
        printButton.MatlabMethod='printLegend';
        printButton.MatlabArgs={this,mdlName};
        printButton.RowSpan=[1,1];
        printButton.ColSpan=[1,1];
        printButton.Tag='PrintButtonTAG';
        printButton.ToolTip=...
        DAStudio.message('Simulink:utility:VariantLegendPrintTooltip');
        printButton.Alignment=1;
        buttonPanel.Items{1}=printButton;

        helpButton.Type='pushbutton';
        helpButton.Name=DAStudio.message('Simulink:utility:SEMenuHelp');
        helpButton.MatlabMethod='helpview';
        helpButton.MatlabArgs={[docroot,'/toolbox/simulink/helptargets.map'],...
        'conditionannotation'};

        helpButton.RowSpan=[1,1];
        helpButton.ColSpan=[2,2];
        helpButton.Tag='HelpButtonTAG';
        helpButton.Alignment=1;
        buttonPanel.Items{2}=helpButton;
        buttonPanel.LayoutGrid=[1,2];
        dlgstructChild.Items{1}=buttonPanel;

        [dlgstructChild.Items{2},dlgstructChild.Items{3}]=constructSpreadSheetAndFilterPanel(mdlName);

        dlgstruct.LayoutGrid=[3,1];
        dlgstruct.RowStretch=[0,1,0];
        dlgstruct.ColStretch=0;


        dlgstruct.Items={dlgstructChild.Items{1},dlgstructChild.Items{2},dlgstructChild.Items{3}};

    end


    function[searchCheckboxButtonPanel,legendMainGroup]=constructSpreadSheetAndFilterPanel(mdlName)
        showCGVCE=this.checkBoxValueForModel(mdlName);

        searchCheckboxButtonPanel.Type='panel';
        searchCheckboxButtonPanel.Name='';
        searchCheckboxButtonPanel.Items=cell(1,2);
        searchCheckboxButtonPanel.RowSpan=[1,1];
        searchCheckboxButtonPanel.ColSpan=[1,1];
        searchCheckboxButtonPanel.Alignment=0;
        searchCheckboxButtonPanel.Tag='searchButtonTAG';



        searchBox.Type='spreadsheetfilter';
        searchBox.RowSpan=[1,1];
        searchBox.ColSpan=[2,2];
        searchBox.Tag='VariantAnnotationDDGSpreadsheetSearch';
        searchBox.TargetSpreadsheet='VariantsDDGSpreadsheet';
        searchBox.PlaceholderText=DAStudio.message('Simulink:dialog:VariantAnnotationsLegendFilterText');
        searchBox.Visible=true;
        searchBox.Clearable=true;
        searchCheckboxButtonPanel.Items{1}=searchBox;

        widCheckBox.Type='checkbox';
        widCheckBox.Name=DAStudio.message('Simulink:utility:VariantCodeGenCheckbox');
        widCheckBox.ColSpan=[1,1];
        widCheckBox.RowSpan=[1,1];
        widCheckBox.Tag='generated_code_conditions';
        widCheckBox.ToolTip='';
        widCheckBox.Value=showCGVCE;
        widCheckBox.MatlabMethod='controlCodeGenColumn';
        widCheckBox.MatlabArgs={this,'%value',mdlName};
        searchCheckboxButtonPanel.LayoutGrid=[1,2];

        searchCheckboxButtonPanel.RowStretch=0;
        searchCheckboxButtonPanel.ColStretch=[1,1];
        searchCheckboxButtonPanel.Items{2}=widCheckBox;


        legendMainGroup.Type='spreadsheet';

        if~showCGVCE
            legendMainGroup.Columns={DAStudio.message('Simulink:utility:AnnotationWithoutColon'),...
            DAStudio.message('Simulink:utility:VariantConditions'),...
            DAStudio.message('Simulink:utility:VariantConditionSRC')};
        else
            legendMainGroup.Columns={DAStudio.message('Simulink:utility:AnnotationWithoutColon'),...
            DAStudio.message('Simulink:utility:VariantConditions'),...
            DAStudio.message('Simulink:utility:VariantConditionSRC'),...
            DAStudio.message('Simulink:utility:VariantConditionCG')};
        end

        legendMainGroup.SortOrder=true;
        legendMainGroup.Enabled=1;
        legendMainGroup.Visible=true;

        legendMainGroup.Source=Simulink.variant.legend.Spreadsheet(this,dlgstruct,mdlName);
        legendMainGroup.Tag=this.spreadSheetTag;
        legendMainGroup.RowSpan=[2,2];
        legendMainGroup.ColSpan=[1,1];

    end

end




