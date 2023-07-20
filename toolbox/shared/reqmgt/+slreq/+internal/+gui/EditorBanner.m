classdef EditorBanner<slreq.das.BaseObject




    properties
        suggestionreason;
        suggestionId;


        reasonStack;
        idStack;
    end


    methods(Access=public)
        function this=EditorBanner()

            this.suggestionreason='<a href="matlab:noop"></a>';
            this.suggestionId='no Id';


        end

        function closeCB(this)
            slreq.app.MainManager.getInstance.requirementsEditor.dismissNotificationBanner;
        end


        function html=createMsgHtml(this)
            html=sprintf('<span class="content" id="SuggestionReason">%s</span>',this.suggestionreason);
        end

        function html=createDismissHtml(this)
            linkIcon=slreq.gui.LinkDetails.deletIcon;
            linkHyper=sprintf('slreq.app.MainManager.getInstance.requirementsEditor.dismissNotificationBanner');
            linktooltip=getString(message('Slvnv:slreq:DeleteLink'));
            linkImage=Advisor.Image;
            linkImage.ImageSource=linkIcon;
            linkImage.setAttribute('class','dismissicon');
            imageHtml=linkImage.emitHTML;

            html=createItemWithTooltip(imageHtml,linkHyper,linktooltip,'deletelink');
        end

        function dlg=getDialogSchema(this,dummy)
            dlg=this.getDdgDialogSchema(dummy);
        end


        function dlg=getHtmlDialogSchema(this,~)
            dlg.DialogTitle='';
            dlg.DialogStyle='frameless';
            dlg.DialogTag='req_editor_button_dlg';
            dlg.StandaloneButtonSet={''};
            dlg.EmbeddedButtonSet={''};
            dlg.LayoutGrid=[1,1];

            msgItem.Type='webbrowser';
            msgItem.RowSpan=[1,1];
            msgItem.ColSpan=[1,1];
            msgItem.Tag='bannerDDG';
            msgItem.WebKit=1;
            msgHtml=this.createMsgHtml();
            dismissHtml=this.createDismissHtml();
            html=[msgHtml,dismissHtml];

            msgItem.HTML=create_doc(html);
            msgItem.PreferredSize=[10,10];

            dlg.Items={msgItem};
        end


        function dlg=getDdgDialogSchema(this,~)

            dlg.DialogTitle='';
            dlg.DialogStyle='frameless';
            dlg.EmbeddedButtonSet={''};
            dlg.DialogTag='req_editor_button_dlg';
            dlg.StandaloneButtonSet={''};
            dlg.EmbeddedButtonSet={''};






            view_suggestion_panel.Type='panel';
            view_suggestion_panel.Tag='views_suggestion_panel';
            view_suggestion_panel.Items={};

            currentCol=1;
            suggestion_info_icon.Type='image';
            suggestion_info_icon.Tag='suggestion_info_icon';
            suggestion_info_icon.ToolTip='';
            suggestion_info_icon.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','info_suggestion.png');
            suggestion_info_icon.RowSpan=[1,1];
            suggestion_info_icon.ColSpan=[currentCol,currentCol];

            currentCol=currentCol+1;
            suggestion_content.Type='text';
            suggestion_content.Tag='views_suggestion_reason';
            suggestion_content.RowSpan=[1,1];
            suggestion_content.ColSpan=[currentCol,currentCol+1];
            suggestion_content.Name=this.suggestionreason;

            currentCol=currentCol+2;
            suggestion_help.Type='image';
            suggestion_help.Tag='views_suggestion_help';
            suggestion_help.MatlabMethod='slreq.gui.Toolbar.suggestionHelpLink';
            suggestion_help.MatlabArgs={'%dialog',this.suggestionId};
            suggestion_help.RowSpan=[1,1];
            suggestion_help.ToolTip=getString(message('Slvnv:slreq:GoToDoc'));
            suggestion_help.ColSpan=[currentCol,currentCol];
            suggestion_help.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','help.png');

            currentCol=currentCol+1;
            suggestion_spacer.Type='panel';
            suggestion_spacer.RowSpan=[1,1];
            suggestion_spacer.ColSpan=[currentCol,currentCol];

            currentCol=currentCol+1;
            suggestion_close_icon.Type='pushbutton';
            suggestion_close_icon.Tag='suggestion_close_button';
            suggestion_close_icon.MaximumSize=[15,15];
            suggestion_close_icon.BackgroundColor=[255,255,225];
            suggestion_close_icon.MatlabMethod='slreq.internal.gui.EditorBanner.closeBanner';
            suggestion_close_icon.MatlabArgs={this.suggestionId};
            suggestion_close_icon.Name='';
            suggestion_close_icon.ToolTip='';
            suggestion_close_icon.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','CloseTabButton-Clicked.png');
            suggestion_close_icon.Flat=true;
            suggestion_close_icon.RowSpan=[1,1];
            suggestion_close_icon.ColSpan=[currentCol,currentCol];


            view_suggestion_panel.BackgroundColor=[255,255,225];
            view_suggestion_panel.LayoutGrid=[1,currentCol];
            view_suggestion_panel.ColStretch=[0,0,0,0,1,0];

            view_suggestion_panel.Items={suggestion_info_icon,...
            suggestion_content,...
            suggestion_help,...
            suggestion_spacer,suggestion_close_icon};

            dlg.Items={view_suggestion_panel};
        end

    end

    methods(Static)
        function closeBanner(suggestionId)
            slreq.app.MainManager.getInstance.requirementsEditor.dismissNotificationBanner(suggestionId);
        end
    end
end


function out=createItemWithTooltip(content,navCmd,tooltip,hyperlinkclass,status)
    if nargin<5
        status='invalid';
    end
    out=sprintf('<span class="content"><a class="%s" href="matlab:%s"><span class="%s">%s</span><span class="tooltip">%s</span></a></span> ',...
    hyperlinkclass,navCmd,status,content,tooltip);
end


function htmlStr=create_doc(htmlStr)
    document=Advisor.Document;

    enc=Advisor.Element('meta','charset','UTF-8');
    document.addHeadItem(enc);


    css_ms=Advisor.Element('style','type','text/css');
    css_ms.setContent(fileread(fullfile(matlabroot,'toolbox','shared',...
    'reqmgt','icons','editorBanner.css')));


    document.addHeadItem(css_ms);

    document.addItem(htmlStr);

    htmlStr=document.emitHTML;
end
