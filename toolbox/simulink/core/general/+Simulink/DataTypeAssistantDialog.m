classdef(Hidden=true)DataTypeAssistantDialog<handle





    properties(Access=public)
        m_blockDeleteListener;
    end
    properties

p_dlg
p_hDlgSource
        p_dtName='';
        p_dtPrompt='';
        p_dtTag='';
p_dtVal
p_dtaItems
p_dtaOn

    end

    methods


        function obj=DataTypeAssistantDialog(pDlg,hDlgSource,dtName,dtPrompt,dtTag,dtVal,dtaItems,dtaOn)
            obj.p_dlg=pDlg;
            obj.p_hDlgSource=hDlgSource;
            obj.p_dtName=dtName;
            obj.p_dtPrompt=dtPrompt;
            obj.p_dtTag=dtTag;
            obj.p_dtVal=dtVal;
            obj.p_dtaItems=dtaItems;
            obj.p_dtaOn=dtaOn;
        end


        function dlg=getDialogSchema(obj)

            curItems={};



            try
                if~isempty(obj.p_hDlgSource.UDTAssistOpen)
                    whichTag=find(strcmp(obj.p_dtTag,obj.p_hDlgSource.UDTAssistOpen.tags),1);
                    assert(~isempty(whichTag));
                    dtaOnTemp=obj.p_hDlgSource.UDTAssistOpen.status{whichTag};
                    obj.p_hDlgSource.UDTAssistOpen.status{whichTag}=true;
                end
            catch ME
                if strcmp(ME.identifier,'MATLAB:noSuchMethodOrField')


                else
                    rethrow(ME);
                end
            end

            if~isempty(obj.p_hDlgSource.UDTIPOpen)
                whichTag=find(strcmp(obj.p_dtTag,obj.p_hDlgSource.UDTIPOpen.tags),1);
                assert(~isempty(whichTag));
                UDTIPOpenTemp=obj.p_hDlgSource.UDTIPOpen.status{whichTag};
                obj.p_hDlgSource.UDTIPOpen.status{whichTag}=true;
            end


            dtwPanel=Simulink.DataTypePrmWidget.getDataTypeWidget(obj.p_hDlgSource,obj.p_dtName,obj.p_dtPrompt,obj.p_dtTag,obj.p_dtVal,obj.p_dtaItems,true);


            obj.p_hDlgSource.UDTAssistOpen.status{whichTag}=dtaOnTemp;
            obj.p_hDlgSource.UDTIPOpen.status{whichTag}=UDTIPOpenTemp;


            for i=1:length(dtwPanel.Items)
                if isfield(dtwPanel.Items{i},'Tag')

                    if strcmp(dtwPanel.Items{i}.Tag,obj.p_dtTag)
                        if isfield(dtwPanel.Items{i},'ObjectProperty')
                            dtwPanel.Items{i}=rmfield(dtwPanel.Items{i},'ObjectProperty');
                        end
                        if isfield(dtwPanel.Items{i},'Source')
                            dtwPanel.Items{i}=rmfield(dtwPanel.Items{i},'Source');
                        end

                        dtwPanel.Items{i}.Value=obj.p_dlg.getWidgetValue(obj.p_dtTag);

                        if isfield(dtwPanel.Items{i},'Entries')
                            for j=1:length(dtwPanel.Items{i}.Entries)
                                if strcmp(dtwPanel.Items{i}.Entries{j},DAStudio.message('Simulink:DataType:RefreshDataTypeInWorkspace'))
                                    dtwPanel.Items{i}.Entries{j}=[];
                                end
                            end
                        end
                    end

                    if strcmp(dtwPanel.Items{i}.Tag,[obj.p_dtTag,'|UDTShowDataTypeAssistBtn'])
                        dtwPanel.Items{i}.Visible=false;
                    end

                    if strcmp(dtwPanel.Items{i}.Tag,[obj.p_dtTag,'|UDTHideDataTypeAssistBtn'])
                        dtwPanel.Items{i}.Visible=false;
                    end

                    if strcmp(dtwPanel.Items{i}.Tag,[obj.p_dtTag,'|UDTExpandDataTypeAssistBtn'])
                        dtwPanel.Items{i}.Visible=false;
                    end

                    if strcmp(dtwPanel.Items{i}.Tag,[obj.p_dtTag,'|UDTDataTypeAssistGrp'])
                        dtwPanel.Items{i}.Visible=true;
                        dtwPanel.Items{i}.Name='';
                        for j=1:length(dtwPanel.Items{i}.Items)
                            if strcmp(dtwPanel.Items{i}.Items{j}.Tag,[obj.p_dtTag,'|UDTDataTypeInfoPnl'])
                                for k=1:length(dtwPanel.Items{i}.Items{j}.Items)
                                    if strcmp(dtwPanel.Items{i}.Items{j}.Items{k}.Tag,[obj.p_dtTag,'|UDTDataTypeInfoContract'])||...
                                        strcmp(dtwPanel.Items{i}.Items{j}.Items{k}.Tag,[obj.p_dtTag,'|UDTDataTypeInfoExpand'])
                                        dtwPanel.Items{i}.Items{j}.Items{k}.Visible=false;
                                    end
                                    if strcmp(dtwPanel.Items{i}.Items{j}.Items{k}.Tag,[obj.p_dtTag,'|UDTDataTypeInfoLink'])
                                        fixDtl.Tag=dtwPanel.Items{i}.Items{j}.Items{k}.Tag;
                                        fixDtl.Name=dtwPanel.Items{i}.Items{j}.Items{k}.Name;
                                        fixDtl.Type='text';
                                        fixDtl.RowSpan=[1,1];
                                        fixDtl.ColSpan=[2,2];
                                        dtwPanel.Items{i}.Items{j}.Items{k}=fixDtl;
                                    end

                                end

                            end
                        end
                    end

                end
            end

            dtwPanel.RowSpan=[1,1];
            dtwPanel.ColSpan=[1,1];
            curItems{end+1}=dtwPanel;

            createHiddenMin=~isempty(obj.p_dtaItems.scalingMinTag);
            createHiddenMax=~isempty(obj.p_dtaItems.scalingMaxTag);
            createHiddenValue=~isempty(obj.p_dtaItems.scalingValueTags);
            if createHiddenMin
                minEdit.Type='edit';
                minEdit.Tag=obj.p_dtaItems.scalingMinTag{1};
                minEdit.Name=obj.p_dlg.getWidgetPrompt(minEdit.Tag);
                minEdit.Value=obj.p_dlg.getWidgetValue(minEdit.Tag);
                minEdit.Visible=false;
                minEdit.RowSpan=[1,1];
                minEdit.ColSpan=[1,1];
                curItems{end+1}=minEdit;
            end
            if createHiddenMax
                maxEdit.Type='edit';
                maxEdit.Tag=obj.p_dtaItems.scalingMaxTag{1};
                maxEdit.Name=obj.p_dlg.getWidgetPrompt(maxEdit.Tag);
                maxEdit.Value=obj.p_dlg.getWidgetValue(maxEdit.Tag);
                maxEdit.Visible=false;
                maxEdit.RowSpan=[1,1];
                maxEdit.ColSpan=[1,1];
                curItems{end+1}=maxEdit;
            end
            if createHiddenValue
                valueTagsLength=length(obj.p_dtaItems.scalingValueTags);
                for i=1:valueTagsLength
                    valueEdit.Type='edit';
                    valueEdit.Tag=obj.p_dtaItems.scalingValueTags{i};
                    valueEdit.Name=getPromptForWidget(obj.p_dlg,valueEdit.Tag);
                    valueEdit.Value=obj.p_dlg.getWidgetValue(valueEdit.Tag);
                    valueEdit.Visible=false;
                    valueEdit.RowSpan=[1,1];
                    valueEdit.ColSpan=[1,1];
                    valueEdit.Enabled=obj.p_dlg.isEnabled(obj.p_dtaItems.scalingValueTags{i});
                    curItems{end+1}=valueEdit;
                end
            end
            spacerPanel.Type='panel';
            spacerPanel.ColSpan=[1,1];
            spacerPanel.RowSpan=[2,2];
            spacerPanel.Enabled=0;
            curItems{end+1}=spacerPanel;

            dlg.Items=curItems;


            dlg.DialogTitle=DAStudio.message('Simulink:dialog:UDTDataTypeAssistGrp');
            dlg.RowStretch=[0,1];
            dlg.ColStretch=1;
            dlg.LayoutGrid=[2,1];
            dlg.DialogTag='DTAFlyout';
            dlg.DialogStyle='Normal';
            dlg.StandaloneButtonSet={'Ok','Cancel'};
            dlg.MinMaxButtons=false;
            dlg.Sticky=true;
            dlg.AlwaysOnTop=true;

            slmDlg=obj.p_dlg;
            comboboxTag=obj.p_dtTag;
            dlg.PreApplyCallback='Simulink.dataTypeAssistantPreApplyCallback';
            dlg.PreApplyArgs={slmDlg,comboboxTag,'%dialog',obj.p_dtaItems.PropertyName};

            dlg.ExplicitShow=true;

        end
        function showDialog(obj,tag,dtTag)

            dlg=DAStudio.Dialog(obj);



            refreshWidgetTag=[dtTag,'|UDTDataTypeInfoUpdate'];
            if dlg.isWidgetValid(refreshWidgetTag)
                Simulink.DataTypePrmWidget.callbackDataTypeWidget('buttonPushEvent',dlg,refreshWidgetTag);
            end

            dlgWidth=460;
            dlgLength=1000;
            dlgPos=obj.p_dlg.getWidgetPosition(tag);
            dlg.Position=[dlgPos(1)+0.5*dlgPos(3)-dlgLength,dlgPos(2)+0.5*dlgPos(4),dlgLength,dlgWidth];
            dlg.show;
            obj.m_blockDeleteListener=handle.listener(obj.p_dlg,...
            'ObjectBeingDestroyed',{@Simulink.DataTypeAssistantDialog.removeDlg,dlg});

        end

    end
    methods(Static=true,Hidden=true)
        function removeDlg(~,~,dlg)
            if ishandle(dlg)
                dlg.delete;
            end
        end
    end

end



function prompt=getPromptForWidget(hDialog,widgetTag)










    prompt=hDialog.getWidgetPrompt(widgetTag);
    if isempty(prompt)
        userData=hDialog.getUserData(widgetTag);
        if isfield(userData,'detailPrompt')
            prompt=userData.detailPrompt;
        end
        if isempty(prompt)
            try
                widgetSrc=hDialog.getWidgetSource(widgetTag);
                prompt=widgetSrc.IntrinsicDialogParameters.(widgetTag).Prompt;
            catch %#ok<CTCH>
                prompt='';
            end
            if isempty(prompt)
                try
                    prompt=hDialog.getWidgetValue([widgetTag,'_Prompt_Tag']);
                catch
                    prompt='';
                end
            end
        end
    end

end
