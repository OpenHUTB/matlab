





classdef Operation<handle
    properties(SetObservable=true)
        m3iObj;
        modelName;
        opName;
        CloseListener;
    end

    methods
        function obj=Operation(mObj,modelName,opName)
            obj.m3iObj=mObj;
            obj.modelName=modelName;
            obj.opName=opName;


            modelH=get_param(obj.modelName,'Handle');
            obj.CloseListener=Simulink.listener(modelH,'CloseEvent',...
            @CloseCB);
        end

        function varType=getPropDataType(~,~)
            varType='ustring';
        end


        function[isValid,msg]=hApplyCB(obj,dlg)

            modelM3I=obj.m3iObj.ParentM3I.modelM3I;
            maxShortNameLength=autosar.ui.utils.getAutosarMaxShortNameLength(modelM3I);
            opNameValue=dlg.getWidgetValue('opName');
            isValid=1;

            msg=autosar.ui.utils.isValidARIdentifier({opNameValue},'shortName',maxShortNameLength);
            if~isempty(msg)
                return;
            end

            isValid=autosar.ui.utils.checkDuplicateInSequence(obj.m3iObj.ParentM3I.Operations,opNameValue);
            if~isValid
                msg=DAStudio.message('RTW:autosar:errorDuplicateOperation',opNameValue);
                return;
            end


            autosar.ui.utils.addNode(obj.m3iObj,{opNameValue},-1);
            m3iOp=obj.m3iObj.ParentM3I.Operations.at(obj.m3iObj.ParentM3I.Operations.size());
            serverFcnValue=dlg.getWidgetValue('SimulinkServerFcnCombo');

            if serverFcnValue~=0

                assert(modelM3I.RootPackage.size==1);

                serverFcn=dlg.getComboBoxText('SimulinkServerFcnCombo');
                t=M3I.Transaction(modelM3I);
                autosar.ui.utils.addArguments(obj.modelName,serverFcn,m3iOp);
                t.commit();
            end
        end


        function dlg=getDialogSchema(obj)
            textBrowser.Type='textbrowser';
            textBrowser.Text=DAStudio.message('RTW:autosar:addOperationTip');
            textBrowser.Tag='textBrowser_tag';
            textBrowser.RowSpan=[1,2];
            textBrowser.ColSpan=[1,4];

            ServerFcnLabel.Type='text';
            ServerFcnLabel.Name=[autosar.ui.metamodel.PackageString.SimulinkFcnLabel,':'];
            ServerFcnLabel.Tag='ServerFcnLabel_tag';
            ServerFcnLabel.RowSpan=[3,3];
            ServerFcnLabel.ColSpan=[1,4];

            serverFcns={autosar.ui.metamodel.PackageString.NoneStr};


            serverFcnBlocks=find_system(obj.modelName,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FollowLinks','on','blocktype','SubSystem',...
            'IsSimulinkFunction','on');
            for ii=1:length(serverFcnBlocks)
                trigPort=find_system(serverFcnBlocks{ii},...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'FollowLinks','on','BlockType','TriggerPort');

                if strcmp(get_param(trigPort,'FunctionVisibility'),'global')
                    serverFcns{end+1}=autosar.ui.utils.getSlFunctionName(serverFcnBlocks{ii});%#ok<AGROW>
                end
            end

            ServerFcnCombo.Type='combobox';
            ServerFcnCombo.Tag='SimulinkServerFcnCombo';
            ServerFcnCombo.Entries=serverFcns;
            ServerFcnCombo.RowSpan=[4,4];
            ServerFcnCombo.ColSpan=[1,4];

            opNameLabel.Type='text';
            opNameLabel.Name=[autosar.ui.metamodel.PackageString.OperationLabel,':'];
            opNameLabel.Tag='opNameLabel_tag';
            opNameLabel.RowSpan=[5,5];
            opNameLabel.ColSpan=[1,4];

            opNameEdit.Type='edit';
            opNameEdit.Tag='opName';
            opNameEdit.Value=obj.opName;
            opNameEdit.RowSpan=[6,6];
            opNameEdit.ColSpan=[1,4];

            spacer.Type='text';
            spacer.Name='';
            spacer.Tag='spacer_tag';
            spacer.RowSpan=[7,7];
            spacer.ColSpan=[1,4];





            dlg.DialogTitle=DAStudio.message('autosarstandard:ui:uiWizardOperationTitle');
            dlg.Items={textBrowser,ServerFcnLabel,ServerFcnCombo,opNameLabel,opNameEdit,spacer};
            dlg.Sticky=true;
            dlg.StandaloneButtonSet={'Help','Cancel','OK'};
            dlg.PreApplyCallback='hApplyCB';
            dlg.PreApplyArgs={obj,'%dialog'};
            dlg.Source=obj;
            dlg.DialogTag='AddOperation';
            dlg.HelpMethod='helpview';
            dlg.HelpArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_build_component_add_csinterface_op'};
        end
    end
end


function CloseCB(eventSrc,~)
    root=DAStudio.ToolRoot;
    arDialog=root.getOpenDialogs.find('dialogTag','AddOperation');
    for i=1:length(arDialog)
        dlgSrc=arDialog.getDialogSource();
        modelH=get_param(dlgSrc.modelName,'Handle');
        if modelH==eventSrc.Handle
            dlgSrc.delete;
            break;
        end
    end
end



