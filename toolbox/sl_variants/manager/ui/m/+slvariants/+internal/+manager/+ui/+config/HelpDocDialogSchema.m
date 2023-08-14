classdef HelpDocDialogSchema<handle




    properties(SetAccess=private,GetAccess=public)
        IsStandalone=false;

        BDHandle;
    end

    properties(Dependent,SetAccess=private,GetAccess=public)
        TagId;
    end

    properties(Access=public)
        ActiveTab=0;
    end

    properties(Constant)
        NRowsWithSpacer=50;
    end

    methods

        function obj=HelpDocDialogSchema(isStandalone,bdHandle)
            obj.IsStandalone=isStandalone;
            obj.BDHandle=bdHandle;
        end

        function tagId=get.TagId(obj)
            tagId=getfullname(obj.BDHandle);
        end

        function dlgstruct=getDialogSchema(obj,~)
            tabStruct.Type='tab';
            tabStruct.ActiveTab=obj.ActiveTab;














            tabStruct.Tabs={...
            obj.getDefineConfigsTab,...
            obj.getActivateConfigTab,...
            obj.getGenerateConfigsTab,...
            obj.getComposeComponentsTab,...
            obj.getReduceTab,...
            obj.getAnalyzeTab};
            tabStruct.Tag='VMGRHelpTabsTag';

            dlgstruct.DialogTitle='';
            dlgstruct.DialogTag='gettingStartedHelpTag';
            dlgstruct.DialogMode='Slim';
            dlgstruct.Items={tabStruct};
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.EmbeddedButtonSet={''};
            dlgstruct.Spacing=0;

        end

        function helpHdr=getHelpHeaderWidget(~)

            helpHdr.Type='text';
            helpHdr.Bold=true;

            helpHdr.WordWrap=true;
            helpHdr.RowSpan=[1,1];
            helpHdr.ColSpan=[1,1];

        end

        function helpTxt=getHelpTxtWidget(~)

            helpTxt.Type='text';
            helpTxt.WordWrap=true;
            helpTxt.PreferredSize=[300,-1];
            helpTxt.RowSpan=[2,2];
            helpTxt.ColSpan=[1,1];
            helpTxt.FontPointSize=8;
            helpTxt.ForegroundColor=[50,50,50];

        end

        function spacer=getSpacer(obj)

            spacer.Name='';
            spacer.Type='text';
            spacer.RowSpan=[3,obj.NRowsWithSpacer];
            spacer.ColSpan=[1,1];

        end

        function tabField=getDefineConfigsTab(obj)
            defineConfigsHelpHdr=obj.getHelpHeaderWidget();
            defineConfigsHelpHdr.Name=slvariants.internal.manager.ui.config.VMgrConstants.DefineConfigsHelpHeader;
            defineConfigsHelpHdr.Tag='DefineConfigsHelpHeader';

            defineConfigsHelpTxt=obj.getHelpTxtWidget();
            defineConfigsHelpTxt.Name=slvariants.internal.manager.ui.config.VMgrConstants.DefineConfigsHelpText;
            defineConfigsHelpTxt.Tag='DefineConfigsHelpText';

            defineConstraintsHelpHdr=obj.getHelpHeaderWidget();
            defineConstraintsHelpHdr.RowSpan=[3,3];
            defineConstraintsHelpHdr.Name=slvariants.internal.manager.ui.config.VMgrConstants.DefineConstraintsHelpHeader;
            defineConstraintsHelpHdr.Tag='DefineConstraintsHelpHeader';

            defineConstraintsHelpTxt=obj.getHelpTxtWidget();
            defineConstraintsHelpTxt.RowSpan=[4,4];
            defineConstraintsHelpTxt.Name=slvariants.internal.manager.ui.config.VMgrConstants.DefineConstraintsHelpText;
            defineConstraintsHelpTxt.Tag='DefineConstraintsHelpText';

            tabField.Name=slvariants.internal.manager.ui.config.VMgrConstants.DefineConfigsHelpTabLabel;
            tabField.Tag='DefineConfingsHelpTab';
            tabField.LayoutGrid=[obj.NRowsWithSpacer,1];
            spacer=obj.getSpacer();
            spacer.RowSpan(1)=5;
            tabField.Items={defineConfigsHelpHdr,defineConfigsHelpTxt,...
            defineConstraintsHelpHdr,defineConstraintsHelpTxt,spacer};
        end

        function tabField=getActivateConfigTab(obj)
            activateConfigHelpHdr=obj.getHelpHeaderWidget();
            activateConfigHelpHdr.Name=slvariants.internal.manager.ui.config.VMgrConstants.ActivateConfigHelpHeader;
            activateConfigHelpHdr.Tag='ActivateConfigHelpHeader';

            activateConfigHelpTxt=obj.getHelpTxtWidget();
            activateConfigHelpTxt.Name=slvariants.internal.manager.ui.config.VMgrConstants.ActivateConfigHelpText;
            activateConfigHelpTxt.Tag='ActivateConfigHelpText';

            tabField.Name=slvariants.internal.manager.ui.config.VMgrConstants.ActivateConfigHelpTabLabel;
            tabField.Tag='ActivateConfigHelpTab';
            tabField.LayoutGrid=[obj.NRowsWithSpacer,1];
            tabField.Items={activateConfigHelpHdr,activateConfigHelpTxt,obj.getSpacer()};
        end

        function tabField=getGenerateConfigsTab(obj)
            generateConfigsHelpHdr=obj.getHelpHeaderWidget();
            generateConfigsHelpHdr.Name=slvariants.internal.manager.ui.config.VMgrConstants.GenerateConfigsHelpHeader;
            generateConfigsHelpHdr.Tag='GenerateConfigsHelpHeader';

            generateConfigsHelpTxt=obj.getHelpTxtWidget();
            generateConfigsHelpTxt.Name=slvariants.internal.manager.ui.config.VMgrConstants.GenerateConfigsHelpText;
            generateConfigsHelpTxt.Tag='GenerateConfigsHelpText';

            tabField.Name=slvariants.internal.manager.ui.config.VMgrConstants.GenerateConfigsHelpTabLabel;
            tabField.Tag='GenerateConfigsHelpTab';
            tabField.LayoutGrid=[obj.NRowsWithSpacer,1];
            tabField.Items={generateConfigsHelpHdr,generateConfigsHelpTxt,obj.getSpacer()};
        end

        function tabField=getComposeComponentsTab(obj)
            composeComponentsHelpHdr=obj.getHelpHeaderWidget();
            composeComponentsHelpHdr.Name=slvariants.internal.manager.ui.config.VMgrConstants.ComposeComponentsHelpHeader;
            composeComponentsHelpHdr.Tag='ComposeComponentsHelpHeader';

            composeComponentsHelpTxt=obj.getHelpTxtWidget();
            composeComponentsHelpTxt.Name=slvariants.internal.manager.ui.config.VMgrConstants.ComposeComponentsHelpText;
            composeComponentsHelpTxt.Tag='ComposeComponentsHelpText';

            tabField.Name=slvariants.internal.manager.ui.config.VMgrConstants.ComposeComponentsHelpTabLabel;
            tabField.Tag='ComposeComponentsHelpTab';
            tabField.LayoutGrid=[obj.NRowsWithSpacer,1];
            tabField.Items={composeComponentsHelpHdr,composeComponentsHelpTxt,obj.getSpacer()};
        end

        function tabField=getReduceTab(obj)
            reduceHelpHdr=obj.getHelpHeaderWidget();
            reduceHelpHdr.Name=slvariants.internal.manager.ui.config.VMgrConstants.ReduceHelpHeader;
            reduceHelpHdr.Tag='ReduceHelpHeader';

            reduceHelpTxt=obj.getHelpTxtWidget();
            reduceHelpTxt.Name=slvariants.internal.manager.ui.config.VMgrConstants.ReduceHelpText;
            reduceHelpTxt.Tag='ReduceHelpText';

            tabField.Name=slvariants.internal.manager.ui.config.VMgrConstants.ReduceHelpTabLabel;
            tabField.Tag='ReduceHelpTab';
            tabField.LayoutGrid=[obj.NRowsWithSpacer,1];
            tabField.Items={reduceHelpHdr,reduceHelpTxt,obj.getSpacer()};
        end

        function tabField=getAnalyzeTab(obj)
            analyzeHelpHdr=obj.getHelpHeaderWidget();
            analyzeHelpHdr.Name=slvariants.internal.manager.ui.config.VMgrConstants.AnalyzeHelpHeader;
            analyzeHelpHdr.Tag='AnalyzeHelpHeader';

            analyzeHelpTxt=obj.getHelpTxtWidget();
            analyzeHelpTxt.Name=slvariants.internal.manager.ui.config.VMgrConstants.AnalyzeHelpText;
            analyzeHelpTxt.Tag='AnalyzeHelpText';

            tabField.Name=slvariants.internal.manager.ui.config.VMgrConstants.AnalyzeHelpTabLabel;
            tabField.Tag='AnalyzeHelpTab';
            tabField.LayoutGrid=[obj.NRowsWithSpacer,1];
            tabField.Items={analyzeHelpHdr,analyzeHelpTxt,obj.getSpacer()};
        end
    end

end


