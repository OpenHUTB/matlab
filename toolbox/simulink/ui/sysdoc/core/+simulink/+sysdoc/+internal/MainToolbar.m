

classdef MainToolbar<handle
    properties(Constant)



        RTC_EDIT_PANEL_TAG='rtcEditPanel';
        HTTP_EDIT_PANEL_TAG='httpEditPanel';

        BTN_TOGGLE_EDIT_BIND_TAG='editBinding';
        BTN_COPY_BIND_TAG='copyBinding';
        BTN_GOTO_ROOT_TAG='gotoRoot';
        BTN_REMOVE_INHERIT_TAG='removeInheritance';

        BTN_DOC_SET_OPTION_TAG='gearStartup';

        CB_BIND_TYPE_TAG='bindTypeCombo';
        CB_BIND_TYPE_ROOT_TAG='bindTypeRootCombo';

        BTN_GO_FORWARD_TAG='goForward';
        BTN_GO_BACKWARD_TAG='goBackward';
        BTN_GO_HOME_TAG='goHome';
        EDIT_URL_TAG='urlEdit';
        BTN_APPLY_BIND_TAG='applyBinding';

        NAME_TAG='sysdoc_main_toolbar';






        RTC_BUTTON_TAGS={'','','',false;...
        'rtc_undo',resStr('Undo'),'pushbutton',false;...
        'rtc_redo',resStr('Redo'),'pushbutton',false;...
        'rtc_paraformat_title',resStr('SwitchToTitle'),'togglebutton',true;...
        'rtc_paraformat_heading',resStr('SwitchToHeading'),'togglebutton',true;...
        'rtc_paraformat_text',resStr('SwitchToText'),'togglebutton',true;...
        'rtc_toggle_bold',resStr('Bold'),'togglebutton',true;...
        'rtc_toggle_italic',resStr('Italic'),'togglebutton',true;...
        'rtc_toggle_underline',resStr('Underline'),'togglebutton',true;...
        'rtc_toggle_monospace',resStr('Monospace'),'togglebutton',true;...
        'rtc_unordered_list',resStr('SwitchUnordered'),'togglebutton',true;...
        'rtc_ordered_list',resStr('SwitchOrdered'),'togglebutton',true;...
        'rtc_align_left',resStr('AlignLeft'),'togglebutton',true;...
        'rtc_align_center',resStr('AlignCenter'),'togglebutton',true;...
        'rtc_align_right',resStr('AlignRight'),'togglebutton',true;...
        'rtc_image',resStr('Image'),'pushbutton',true;...
        'rtc_hyperlink',resStr('Hyperlink'),'pushbutton',true;...
        'rtc_equation',resStr('Equation'),'pushbutton',true...


        };

        RTC_BUTTON_TAGS_TOTAL=length(simulink.sysdoc.internal.MainToolbar.RTC_BUTTON_TAGS);

        RTC_IS_GROUP_MULTICHOICE=[false,false,false,true,true,false,false,false,false];
        RTC_BUTTON_SPLIT_GROUP=[1,1,3,4,2,3,1,1,1];
        RTC_SPLIT_GROUP_TAG={'rtc_undo_split',...
        'rtc_redo_split',...
        'rtc_paraformat_title_split',...
        'rtc_toggle_bold_split',...
        'rtc_unordered_list_split',...
        'rtc_align_left_split',...
        'rtc_image_split',...
        'rtc_hyperlink_split',...
        'rtc_equation_split'};
        RTC_BUTTON_GROUP_TOTAL=length(simulink.sysdoc.internal.MainToolbar.RTC_BUTTON_SPLIT_GROUP);



        RTC_BUTTON_TAGS_QUERY=strjoin(simulink.sysdoc.internal.MainToolbar.RTC_BUTTON_TAGS(:,1),'&buttonTag=');



        TT_EDIT_BIND_SELECTED=resStr('ReadDocumentation');
        TT_EDIT_BIND_UNSELECTED=resStr('EditDocumentation');

        TT_SHOW_OPTION_SELECTED=resStr('ExitOptionsTooltip');
        TT_SHOW_OPTION_UNSELECTED=resStr('ShowOptionsTooltip');
    end

    properties(Access=protected)
        m_studio=[];
        m_sysdocObj=[];
        m_studioWidgetMgr=[];
        m_tagToSplitItem=[];
    end

    methods(Access=public)
        function obj=MainToolbar(studio)
            obj.m_tagToSplitItem=containers.Map;


            import simulink.sysdoc.internal.SysDocUtil;
            obj.m_studio=studio;
            obj.m_sysdocObj=[];
            obj.m_studioWidgetMgr=[];
            assert(SysDocUtil.isNotEmptyAndValid(studio),'MainToolbar - main toolbar should be created in a valid studio.');
            obj.m_sysdocObj=SysDocUtil.getSystemDocumentation(studio);
            assert(~isempty(obj.m_sysdocObj),'MainToolbar - main toolbar should be created for a valid notes.');
            obj.m_studioWidgetMgr=obj.m_sysdocObj.getStudioWidgetManager(studio);
            assert(~isempty(obj.m_studioWidgetMgr),'MainToolbar - main toolbar should be created by a valid studio widget manager.');
        end

        function dlgStruct=getDialogSchema(this,~)
            dlgStruct=this.onGetDialogSchema(this.m_studio,this.m_sysdocObj,this.m_studioWidgetMgr);
        end

        function itemMap=getTagToSplitItemMap(this,~)
            itemMap=this.m_tagToSplitItem;
        end
    end


    methods(Access=protected)
        function dlgStruct=onGetDialogSchema(this,studio,sysdocObj,studioWidgetMgr)
            import simulink.sysdoc.internal.MainToolbar;
            import simulink.sysdoc.internal.MixedMapRouter;
            import simulink.sysdoc.internal.RTCSplitItem;
            studioTag=studio.getStudioTag();





            rowMax=5;
            panelMax=10;
            colMax=10;
            titlePanel.Type='panel';
            titlePanel.RowSpan=[1,1];
            titlePanel.ColSpan=[1,1];
            titlePanel.Items=cell(1,rowMax);
            row=0;



            row=row+1;
            assert(row<=rowMax);
            firstRowPanel=struct('Type','panel','RowSpan',[row,row],'ColSpan',[1,1],'ContentsMargins',[0,0,0,0]);
            firstRowPanel.Items=cell(1,panelMax);
            panelCol=0;



            panelCol=panelCol+1;
            assert(panelCol<=panelMax);
            widgetOperationPanel=struct('Type','panel',...
            'Alignment',3,...
            'RowSpan',[1,1],...
            'ColSpan',[panelCol,panelCol],...
            'ContentsMargins',[1,0,1,1],...
            'Spacing',0);
            widgetOperationPanel.Items=cell(1,panelMax);
            col=0;


            col=col+1;
            assert(col<=colMax);
            fakeSeperator=struct('Type','text',...
            'Tag','sep',...
            'FontPointSize',18,...
            'Name','|',...
            'ForegroundColor',[175,175,175],...
            'Alignment',3,...
            'RowSpan',[1,1],...
            'ColSpan',[col,col]);
            widgetOperationPanel.Items{col}=fakeSeperator;

            widgetOperationPanel.LayoutGrid=[1,col+1];
            widgetOperationPanel.Items=widgetOperationPanel.Items(~cellfun('isempty',widgetOperationPanel.Items));
            widgetOperationPanel.Visible=false;
            firstRowPanel.Items{panelCol}=widgetOperationPanel;



            panelCol=panelCol+1;
            assert(panelCol<=panelMax);
            slmxOperationPanel=struct('Type','panel','RowSpan',[1,1],'ColSpan',[panelCol,panelCol],'ContentsMargins',[0,0,0,0],'Spacing',0);
            slmxOperationPanel.Items=cell(1,panelMax);
            col=0;
            colSpan=0;


            col=col+1;
            assert(col<=colMax);
            colSpan=colSpan+1;
            gotoRoot=struct('Type','pushbutton',...
            'Tag',MainToolbar.BTN_GOTO_ROOT_TAG,...
            'ToolTip',resStr('GoToParent'),...
            'FilePath',fullfile(matlabroot,'toolbox','simulink','ui','sysdoc','core','icons','Up_16.png'),...
            'RowSpan',[1,1],'ColSpan',[colSpan,colSpan]);
            gotoRoot.Enabled=true;
            gotoRoot.MatlabMethod='simulink.sysdoc.internal.StudioWidgetManager.onGotoRoot';
            gotoRoot.MatlabArgs={studioWidgetMgr};
            slmxOperationPanel.Items{col}=gotoRoot;


            col=col+1;
            assert(col<=colMax);
            colSpan=colSpan+1;
            editBinding=struct('Type','togglebutton',...
            'Tag',MainToolbar.BTN_TOGGLE_EDIT_BIND_TAG,...
            'ToolTip',MainToolbar.TT_EDIT_BIND_UNSELECTED,...
            'FilePath',fullfile(matlabroot,'toolbox','simulink','ui','sysdoc','core','icons','Edit_16.png'),...
            'RowSpan',[1,1],'ColSpan',[colSpan,colSpan]);
            editBinding.Enabled=true;
            editBinding.MatlabMethod='simulink.sysdoc.internal.StudioWidgetManager.onToggleEditMode';
            editBinding.MatlabArgs={'%source'};
            editBinding.Mode=true;
            slmxOperationPanel.Items{col}=editBinding;

            slmxOperationPanel.Visible=true;
            slmxOperationPanel.LayoutGrid=[1,colSpan+1];
            slmxOperationPanel.Items=slmxOperationPanel.Items(~cellfun('isempty',slmxOperationPanel.Items));
            firstRowPanel.Items{panelCol}=slmxOperationPanel;



            panelCol=panelCol+1;
            assert(panelCol<=panelMax);
            bindingControlPanel=struct('Type','panel','RowSpan',[1,1],'ColSpan',[panelCol,panelCol],'ContentsMargins',[0,0,0,0],'Spacing',0);
            bindingControlPanel.Items=cell(1,panelMax);
            col=0;
            colSpan=0;


            col=col+1;
            assert(col<=colMax);
            colSpan=colSpan+1;
            bindTypeCombo=struct('Type','combobox',...
            'Tag',MainToolbar.CB_BIND_TYPE_TAG,...
            'Name','',...
            'Graphical',true,...
            'RowSpan',[1,1],'ColSpan',[colSpan,colSpan]);

            bindTypeCombo.Entries={resStr('ComboTypeRTC'),...
            resStr('ComboTypeHttp'),...
            resStr('ComboTypeInherit'),...
            resStr('ComboTypeNone')};
            bindTypeCombo.Values=[MixedMapRouter.BINDING_TYPE_RTC,...
            MixedMapRouter.BINDING_TYPE_HTTP,...
            MixedMapRouter.BINDING_TYPE_INHERIT,...
            MixedMapRouter.BINDING_TYPE_NONE];
            bindTypeCombo.Value=length(bindTypeCombo.Values);
            bindTypeCombo.DialogRefresh=false;
            bindTypeCombo.MatlabMethod='simulink.sysdoc.internal.StudioWidgetManager.onChangeBinding';
            bindTypeCombo.MatlabArgs={studioWidgetMgr,'%value'};
            bindingControlPanel.Items{col}=bindTypeCombo;


            col=col+1;
            assert(col<=colMax);
            bindTypeRootCombo=bindTypeCombo;
            bindTypeRootCombo.Tag=MainToolbar.CB_BIND_TYPE_ROOT_TAG;
            bindTypeRootCombo.Entries={bindTypeCombo.Entries{1:2},bindTypeCombo.Entries{4}};
            bindTypeRootCombo.Values=[bindTypeCombo.Values(1:2),bindTypeCombo.Values(4)];
            bindTypeRootCombo.Value=3;
            bindTypeRootCombo.Visible=false;
            bindingControlPanel.Items{col}=bindTypeRootCombo;

            bindingControlPanel.LayoutGrid=[1,colSpan+1];
            bindingControlPanel.Items=bindingControlPanel.Items(~cellfun('isempty',bindingControlPanel.Items));
            firstRowPanel.Items{panelCol}=bindingControlPanel;



            panelCol=panelCol+1;
            assert(panelCol<=panelMax);
            docSetGearPanel=struct('Type','panel','RowSpan',[1,1],'ColSpan',[panelCol,panelCol],'ContentsMargins',[0,0,0,0],'Spacing',0);
            docSetGearPanel.Items=cell(1,panelMax);
            col=0;
            colSpan=0;


            col=col+1;
            assert(col<=colMax);
            col=col+1;
            assert(col<=colMax);
            gearStartup=struct('Type','togglebutton',...
            'Tag',MainToolbar.BTN_DOC_SET_OPTION_TAG,...
            'ToolTip',MainToolbar.TT_SHOW_OPTION_UNSELECTED,...
            'FilePath',fullfile(matlabroot,'toolbox','simulink','ui','sysdoc','core','icons','Settings_16.png'),...
            'RowSpan',[1,1],'ColSpan',[colSpan,colSpan]);
            gearStartup.Enabled=true;
            gearStartup.MatlabMethod='simulink.sysdoc.internal.StudioWidgetManager.onGearButtonToggled';
            gearStartup.MatlabArgs={studioWidgetMgr};
            gearStartup.Mode=true;
            docSetGearPanel.Items{col}=gearStartup;

            docSetGearPanel.LayoutGrid=[1,col+1];
            docSetGearPanel.Items=docSetGearPanel.Items(~cellfun('isempty',docSetGearPanel.Items));
            firstRowPanel.Items{panelCol}=docSetGearPanel;



            firstRowPanel.LayoutGrid=[1,panelCol+1];
            firstRowPanel.ColStretch=[zeros(1,panelCol),1];
            firstRowPanel.Items=firstRowPanel.Items(~cellfun('isempty',firstRowPanel.Items));
            titlePanel.Items{row}=firstRowPanel;



            row=row+1;
            assert(row<=rowMax);
            secondRowPanel=struct('Type','panel','Tag',MainToolbar.RTC_EDIT_PANEL_TAG,'RowSpan',[row,row],'ColSpan',[1,1],'ContentsMargins',[0,0,0,0]);
            secondRowPanel.Items=cell(1,panelMax);
            secondRowPanel.Visible=false;
            panelCol=0;
            panelColSpan=0;



            panelCol=panelCol+1;
            assert(panelCol<=panelMax);
            panelColSpan=panelColSpan+1;
            rtcEditPanel=struct('Type','panel','Tag','rtcEditPanelNotUsed','RowSpan',[1,1],'ColSpan',[panelColSpan,panelColSpan],'ContentsMargins',[0,0,0,0],'Spacing',0);

            rtcEditPanel.Items=cell(1,MainToolbar.RTC_BUTTON_GROUP_TOTAL);

            buttonNum=2;
            for groupNum=1:MainToolbar.RTC_BUTTON_GROUP_TOTAL
                col=groupNum;
                buttonTotal=MainToolbar.RTC_BUTTON_SPLIT_GROUP(groupNum);
                isMultiChoice=MainToolbar.RTC_IS_GROUP_MULTICHOICE(groupNum);

                if buttonTotal==1

                    rtcButton=struct('Type',MainToolbar.RTC_BUTTON_TAGS{buttonNum,3},...
                    'Tag',MainToolbar.RTC_BUTTON_TAGS{buttonNum,1},...
                    'ToolTip',MainToolbar.RTC_BUTTON_TAGS{buttonNum,2},...
                    'FilePath',fullfile(matlabroot,'toolbox','simulink','ui','sysdoc','core','icons',[MainToolbar.RTC_BUTTON_TAGS{buttonNum,1},'.png']),...
                    'RowSpan',[1,1],...
                    'ColSpan',[col,col]);
                    rtcButton.MatlabMethod='simulink.sysdoc.internal.StudioWidgetManager.onRTCEditAction';
                    rtcButton.MatlabArgs={studioWidgetMgr,MainToolbar.RTC_BUTTON_TAGS{buttonNum,1},strcmp(MainToolbar.RTC_BUTTON_TAGS{buttonNum,3},'togglebutton')};
                    rtcButton.Mode=true;
                    rtcButton.Enabled=MainToolbar.RTC_BUTTON_TAGS{buttonNum,4};

                    rtcEditPanel.Items{col}=rtcButton;
                    buttonNum=buttonNum+1;
                else
                    rtcSplit=struct('Type','splitbutton');
                    rtcSplit.Name='';
                    rtcSplit.Tag=MainToolbar.RTC_SPLIT_GROUP_TAG{groupNum};
                    rtcSplit.DefaultAction=MainToolbar.RTC_BUTTON_TAGS{buttonNum,1};
                    rtcSplit.ButtonStyle='IconOnly';
                    rtcSplit.ActionEntries=cell(1,buttonTotal);
                    rtcSplit.ToolTip=MainToolbar.RTC_BUTTON_TAGS{buttonNum,2};
                    rtcSplit.Mode=true;

                    for grpBtnNum=1:buttonTotal
                        iconPath=fullfile(matlabroot,'toolbox','simulink','ui','sysdoc','core','icons',[MainToolbar.RTC_BUTTON_TAGS{buttonNum,1},'.png']);
                        rtcGroupItem=RTCSplitItem(...
                        MainToolbar.RTC_BUTTON_TAGS{buttonNum,2},...
                        MainToolbar.RTC_BUTTON_TAGS{buttonNum,1},...
                        true,...
                        false,...
                        iconPath,...
                        isMultiChoice);
                        rtcSplit.ActionEntries{grpBtnNum}=rtcGroupItem;
                        this.m_tagToSplitItem(MainToolbar.RTC_BUTTON_TAGS{buttonNum,1})=struct('SplitTag',rtcSplit.Tag,'Item',rtcGroupItem);
                        buttonNum=buttonNum+1;
                    end
                    rtcSplit.UseButtonStyleForDefaultAction=false;
                    rtcSplit.ActionCallback=@(dlg,tag,actiontag)(simulink.sysdoc.internal.StudioWidgetManager.onRTCEditAction(studioWidgetMgr,actiontag,false));
                    rtcSplit.ColSpan=[col,col];
                    rtcSplit.RowSpan=[1,1];
                    rtcEditPanel.Items{col}=rtcSplit;
                end
            end

            rtcEditPanel.Items{4}.ToolTip=resStr('FontSplitTooltip');
            rtcEditPanel.LayoutGrid=[1,MainToolbar.RTC_BUTTON_TAGS_TOTAL];
            rtcEditPanel.ColStretch=[zeros(1,MainToolbar.RTC_BUTTON_TAGS_TOTAL-1),1];

            secondRowPanel.Items{panelCol}=rtcEditPanel;





































































            secondRowPanel.LayoutGrid=[1,panelColSpan+1];
            secondRowPanel.ColStretch=[zeros(1,panelColSpan),1];
            secondRowPanel.Items=secondRowPanel.Items(~cellfun('isempty',secondRowPanel.Items));
            titlePanel.Items{row}=secondRowPanel;



            titlePanel.Items=titlePanel.Items(~cellfun('isempty',titlePanel.Items));



            dlgStruct.DialogTitle='';
            dlgStruct.IsScrollable=false;
            dlgStruct.Items={titlePanel};
            dlgStruct.DialogTag=MainToolbar.NAME_TAG;
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.EmbeddedButtonSet={''};
        end
    end
end




function string=resStr(entryKey)
    string=message(['simulink_ui:sysdoc:resources:',entryKey]).getString();
end
