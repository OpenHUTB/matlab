classdef OptionalViewExporter<slreportgen.webview.ViewExporter








    properties




        Id='';




        Name='';




        Icon='';





        WidgetEnableValue(1,1)logical=false;



        HelpTitle='';



        HelpText='';
    end

    methods
        function h=OptionalViewExporter()
            h@slreportgen.webview.ViewExporter();
        end

        function tf=isEnabled(h)

            tf=(isWidgetVisible(h)&&isWidgetEnabled(h)&&h.WidgetEnableValue);
        end

        function tf=isWidgetVisible(h)%#ok







            tf=true;
        end

        function tf=isWidgetEnabled(h)%#ok













            tf=true;
        end

        function schema=getDialogSchema(h)













            name=h.Name;

            wInclude.Type='checkbox';
            wInclude.Name=...
            getString(message('slreportgen_webview:exporter:ViewIncludeLabel',name));
            wInclude.ToolTip=...
            getString(message('slreportgen_webview:exporter:ViewIncludeToolTip',name));
            wInclude.Tag=['WebView_View_',h.Id];
            wInclude.Enabled=isWidgetEnabled(h);
            wInclude.RowSpan=[1,1];
            wInclude.ColSpan=[1,1];
            wInclude.Source=h;
            wInclude.Mode=true;
            wInclude.Graphical=true;
            wInclude.ObjectProperty='WidgetEnableValue';
            wInclude.DialogRefresh=true;

            wHelp.Type='pushbutton';
            wHelp.Name=getString(message('slreportgen_webview:exporter:ViewHelpButtonLabel'));
            wHelp.RowSpan=[1,1];
            wHelp.ColSpan=[3,3];
            wHelp.Source=h;
            wHelp.ObjectMethod='displayHelp';
            wHelp.MatlabArgs={'%source'};

            schema.Type='group';
            schema.Name=name;
            schema.LayoutGrid=[1,3];
            schema.ColStretch=[0,1,0];
            spacer.Type='panel';
            schema.Items={wInclude,spacer,wHelp};
        end

        function displayHelp(h)






            name=h.Name;
            if isempty(h.HelpTitle)
                helpTitle=getString(message('slreportgen_webview:exporter:ViewHelpTitle',name));
            else
                helpTitle=h.HelpTitle;
            end

            if isempty(h.HelpText)
                helpText=getString(message('slreportgen_webview:exporter:ViewHelpText',name));
            else
                helpText=h.HelpText;
            end

            web(sprintf('text://<html><h1>%s</h1><p>%s</p></html>',helpTitle,helpText));
        end

        function init(h,homeSystem)
            h.HomeSystem=slreportgen.utils.getSlSfHandle(homeSystem);
            h.Model=slreportgen.utils.getModelHandle(h.HomeSystem);
        end

        function preExport(h,varargin)
            if(~isSystemView(h)&&isempty(h.BaseName))
                assert(~isempty(h.Id));

                h.BaseName=lower(h.Id);
            end

            preExport@slreportgen.webview.ViewExporter(h,varargin{:});


            homeSystem=h.HomeSystem;
            model=h.Model;


            assert(isempty(homeSystem)||(homeSystem==h.HomeSystem));
            assert(isempty(model)||model==h.Model);
        end
    end

    methods(Hidden)
        function tf=isCacheEnabled(h)
            tf=false;
        end
    end
end
