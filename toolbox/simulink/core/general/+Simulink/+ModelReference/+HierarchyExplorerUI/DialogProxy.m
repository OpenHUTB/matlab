classdef DialogProxy<matlab.mixin.SetGet&matlab.mixin.Copyable



    properties(SetAccess=private,GetAccess=public)
        m_instructions='';
        m_main=[];
        m_uitag='';
    end

    methods

        function this=DialogProxy(main,instructions,uitag)
            this.m_main=main;
            this.m_instructions=instructions;
            this.m_uitag=uitag;
        end

    end

    methods


        function dlg=getDialogSchema(this,~)
            dlg=this.m_main.m_dialog;
            if~isempty(dlg)
                dlg=loc_enable_buttons(this,dlg);
                return;
            end

            text1.Name=this.m_instructions;
            text1.Type='text';
            text1.WordWrap=true;

            textG.Type='group';
            textG.Name=DAStudio.message('Simulink:modelReference:HierarchyExplorerInstructionsPrompt');
            textG.RowSpan=[1,1];
            textG.ColSpan=[1,2];
            textG.Items={text1};

            imagepath=fullfile(matlabroot,'toolbox','shared','dastudio','resources');
            normalIcon.Type='image';
            normalIcon.Tag='image_normalIcon';
            normalIcon.RowSpan=[1,1];
            normalIcon.ColSpan=[1,1];
            normalIcon.FilePath=fullfile(imagepath,'MdlRefBlockIconNormal.png');

            normalText.Name=DAStudio.message('Simulink:modelReference:HierarchyExplorerLegendNormal');
            normalText.Type='text';
            normalText.Tag='text_normalText';
            normalText.WordWrap=true;
            normalText.RowSpan=[1,1];
            normalText.ColSpan=[2,2];

            acceleratedIcon.Type='image';
            acceleratedIcon.Tag='image_acceleratedIcon';
            acceleratedIcon.RowSpan=[2,2];
            acceleratedIcon.ColSpan=[1,1];
            acceleratedIcon.FilePath=fullfile(imagepath,'MdlRefBlockIcon.png');

            acceleratedText.Name=DAStudio.message('Simulink:modelReference:HierarchyExplorerLegendAccelerator');
            acceleratedText.Type='text';
            acceleratedText.Tag='text_acceleratedText';
            acceleratedText.WordWrap=true;
            acceleratedText.RowSpan=[2,2];
            acceleratedText.ColSpan=[2,2];

            LegendGroup.Type='group';
            LegendGroup.Name=DAStudio.message('Simulink:tools:MALegend');
            LegendGroup.RowSpan=[2,2];
            LegendGroup.ColSpan=[1,2];
            LegendGroup.LayoutGrid=[2,1];
            LegendGroup.RowStretch=[0,0];
            LegendGroup.ColStretch=0;
            LegendGroup.Items={normalText,normalIcon,acceleratedText,acceleratedIcon};

            refreshB.RowSpan=[2,2];
            refreshB.ColSpan=[1,1];
            refreshB=loc_create_button(this,refreshB,...
            DAStudio.message('Simulink:modelReference:HierarchyExplorerRefreshButton'),...
            'Refresh');

            mdlRefSpacer.Type='panel';
            mdlRefSpacer.RowSpan=[2,2];
            mdlRefSpacer.ColSpan=[2,2];
            mdlRefSpacer.Tag=loc_getTag('buttonSpacer');

            okB.RowSpan=[2,2];
            okB.ColSpan=[3,3];
            okB=loc_create_button(this,okB,...
            DAStudio.message('Simulink:modelReference:HierarchyExplorerOKButton'),...
            'OK');

            cancelB.RowSpan=[2,2];
            cancelB.ColSpan=[4,4];
            cancelB=loc_create_button(this,cancelB,...
            DAStudio.message('Simulink:modelReference:HierarchyExplorerCancelButton'),...
            'Cancel');

            helpB.RowSpan=[2,2];
            helpB.ColSpan=[5,5];
            helpB=loc_create_button(this,helpB,...
            DAStudio.message('Simulink:modelReference:HierarchyExplorerHelpButton'),...
            'Help');

            applyB.RowSpan=[2,2];
            applyB.ColSpan=[6,6];
            applyB=loc_create_button(this,applyB,...
            DAStudio.message('Simulink:modelReference:HierarchyExplorerApplyButton'),...
            'Apply');

            buttonG.Type='group';
            buttonG.LayoutGrid=[2,6];
            buttonG.RowStretch=[1,0];
            buttonG.ColStretch=[0,1,0,0,0,0];
            buttonG.RowSpan=[3,3];
            buttonG.ColSpan=[2,2];
            buttonG.Flat=true;
            buttonG.Items={refreshB,mdlRefSpacer,okB,cancelB,helpB,applyB};


            dlg.DialogTitle='';
            dlg.LayoutGrid=[3,2];
            dlg.RowStretch=[0,0,1];
            dlg.ColStretch=[0,0];
            dlg.Sticky=true;

            dlg.Items={LegendGroup,textG,buttonG};
            dlg.DialogTag=loc_getTag(this.m_uitag);

            dlg.EmbeddedButtonSet={''};
            dlg=loc_enable_buttons(this,dlg);

            this.m_main.setDialog(dlg);
        end



    end

end

function dlg=loc_enable_buttons(this,dlg)
    readyButtons={loc_getTag('Apply'),loc_getTag('OK'),loc_getTag('Refresh')};


    buttons=dlg.Items{3}.Items;
    buttonTags=cellfun(@(x)x.Tag,buttons,'UniformOutput',false);

    [~,readyIndexes]=intersect(buttonTags,readyButtons);
    assert(length(readyIndexes)==length(readyButtons));

    for i=1:length(readyIndexes)



        if(isempty(this.m_main.m_dialog))||isempty(this.m_main.m_editor.getDialog())
            val=false;
        else
            tag=dlg.Items{3}.Items{readyIndexes(i)}.Tag;
            val=this.m_main.m_editor.getDialog().isEnabled(tag);
        end

        dlg.Items{3}.Items{readyIndexes(i)}.Enabled=val;
    end
end


function button=loc_create_button(this,button,name,tag)
    button.Name=name;
    button.Tag=loc_getTag(tag);
    button.Type='pushbutton';
    button.Source=this.m_main;
    button.ObjectMethod='closeCallback';
    button.MethodArgs={button.Tag};
    button.ArgDataTypes={'string'};
end



function tag=loc_getTag(extension)
    tag=[Simulink.ModelReference.HierarchyExplorerUI.UI.getUITagBase(),extension];
end