function dlgstruct=getDialogSchema(this,~)




    [pathstr,name,extension]=fileparts(this.documentName);
    dasRoot=DAStudio.Root;

    if this.CheckoutLicenseDuringLoad&&~isempty(this.BuildDir)
        try
            reportInfo=rtw.report.ReportInfo.getReportInfoFromBuildDir(this.BuildDir);
            reportInfo.checkoutLicense();
        catch e
            htmlitem.Text=e.message;
            htmlitem.Type='textbrowser';
            dlgstruct.DialogTitle='Code';
            dlgstruct.Items={htmlitem};
            return;
        end
    end


    if~exist(this.documentName,'file')
        this.displayDocument=this.documentName;
    else
        htmlVersion=fullfile(pathstr,'html',[name,strrep(extension,'.','_'),'.html']);
        if(exist(htmlVersion,'file'))&&rtwprivate('cmpTimeFlag',htmlVersion,this.documentName)<=0
            this.displayDocument=htmlVersion;
        else
            if strcmpi(extension,'.c')||strcmpi(extension,'.cpp')||...
                strcmpi(extension,'.h')

                rtwprivate('rtw_create_directory_path',pathstr,'html');

                doCSSStyle=true;
                bBlockSIDComment=false;
                arg={...
                false,...
                name,...
                [],...
                '',...
                '',...
                pathstr,...
                false,...
                false,...
                bBlockSIDComment};
                gentrace=false;
                rtwprivate('rtwctags',{this.documentName},arg,doCSSStyle,{htmlVersion},gentrace,'utf-8');
                this.displayDocument=htmlVersion;
            else
                this.displayDocument=this.documentName;
            end
        end
    end

    isHTML=false;
    if~isempty(this.displayDocument)
        [~,~,ext]=fileparts(this.displayDocument);
        if strcmpi(ext,'.html')||strcmpi(ext,'.htm')
            isHTML=true;
        end
    end
    enableWebKit=isHTML;

    linkitem.Name=this.documentName;
    linkitem.MatlabMethod='edit';
    linkitem.MatlabArgs={this.documentName};
    linkitem.RowSpan=[1,1];
    linkitem.ColSpan=[1,1];
    linkitem.Type='hyperlink';

    if~exist(this.displayDocument,'file')
        item1.Value=['<h3 align="center">',this.displayDocument,' doesn''t exist.</h3>'];
    else



        if isHTML&&(dasRoot.hasWebBrowser||enableWebKit)
            if isempty(this.SearchString)
                item1.Url=Simulink.document.fileURL(this.displayDocument,'');
            else
                item1.Url=Simulink.document.fileURL(this.displayDocument,...
                this.SearchString);
            end
        else
            item1.FilePath=this.documentName;
        end
    end

    item1.RowSpan=[2,10];
    item1.ColSpan=[1,1];
    item1.Tag='Tag_Coder_Report_Dialog';

    htmlrptFlag='_codegen_rpt.html';

    if enableWebKit
        item1.Type='webbrowser';
        item1.WebKit=true;
        item1.ClearCache=true;
        if rtw.report.ReportInfo.hasToolbar||...
            (rtw.report.ReportInfo.featureReportV2&&contains(this.documentName,htmlrptFlag))
            item1.WebKitToolBar={'Navigation','Search'};
        end
    else
        item1.Type='editarea';
    end


    IsCodeReportDocumentStyleFlag=this.IsCodeReportDocumentStyle;
    if strncmp(fliplr(htmlrptFlag),fliplr(this.displayDocument),length(htmlrptFlag))||...
IsCodeReportDocumentStyleFlag
        docIsHTMLreport=true;
    else
        docIsHTMLreport=false;
    end




    if~isempty(this.Title)
        dlgstruct.DialogTitle=this.Title;
    elseif docIsHTMLreport
        dlgstruct.DialogTitle='Code Generation Report';
    else
        dlgstruct.DialogTitle='Document';
    end

    if~isempty(this.HelpMethod)
        HelpMethod=this.helpMethod;
    else
        HelpMethod='helpview([docroot ''/toolbox/rtw/helptargets.map''],''validate_generated_code'')';
    end

    dlgstruct.LayoutGrid=[2,1];
    dlgstruct.RowStretch=[0,1];
    dlgstruct.ColStretch=1;

    dlgstruct.DispatcherEvents={};
    if docIsHTMLreport
        dlgstruct.Items={item1};
        dlgstruct.HelpMethod=HelpMethod;
        dlgstruct.MinMaxButtons=true;
        dlgstruct.StandaloneButtonSet={'OK','Help'};


        dlgstruct.DefaultOk=false;
        dlgstruct.ExplicitShow=this.ExplicitShow;
        dlgstruct.CloseMethod='closeCallback';
    else
        dlgstruct.Items={linkitem,item1};
        dlgstruct.HelpMethod='';
    end



