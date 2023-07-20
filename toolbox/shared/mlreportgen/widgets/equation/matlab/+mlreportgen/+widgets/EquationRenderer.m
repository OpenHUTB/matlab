classdef(Hidden)EquationRenderer<handle



















    properties

        TexContent=[]



        Style=[]


        SnapshotFormat=[]

    end

    properties(Hidden)




        Debug=false;
    end

    properties(Access=private,Constant)



        HTMLSource='toolbox/shared/mlreportgen/widgets/equation/index.html';


        HTMLDebugSource='toolbox/shared/mlreportgen/widgets/equation/index-debug.html';


        NodeId='TeXnode';



        Channel='/mlreportgen/js_equation_renderer';
    end

    properties(Access=private)

        ImageURL=[];
    end

    methods
        function this=EquationRenderer(texContent)
            if(nargin==1)
                this.TexContent=texContent;
            end


            this.Style=struct(...
            "FontSize",[],...
            "Color",[],...
            "BackgroundColor",[]);


            if isempty(this.SnapshotFormat)

                this.SnapshotFormat="png";
            end
        end

        function img=createEquationImage(this)



            if isempty(this.TexContent)

                error(message("shared_mlreportgen_js_equation:error:emptyEquationContent"));
            else
                this.ImageURL=[];
                eqnExportIdler=mlreportgen.utils.internal.Idler;




                subscription=message.subscribe(this.Channel,@(msg)this.subscriptionCallback(msg,eqnExportIdler));



                if this.Debug
                    htmlSource=this.HTMLDebugSource;
                else
                    htmlSource=this.HTMLSource;
                end

                connector.ensureServiceOn;
                connector.newNonce;
                url=connector.getUrl(htmlSource);
                browser=matlab.internal.webwindow(url);
                cleanup=onCleanup(@()delete(browser));
                idler=mlreportgen.utils.internal.Idler;
                browser.PageLoadFinishedCallback=@(a,b)pageLoadCallback(a,b,idler);


                pageLoaded=idler.startIdling(10);
                if~pageLoaded
                    error(message("shared_mlreportgen_js_equation:error:browserFailure"));
                end


                if this.Debug
                    browser.show;
                    executeJS(browser,'cefclient.sendMessage("openDevTools");');
                end



                executeJS(browser,char(getJSToApplyStyles(this)));






                executeJS(browser,char(getJSToRenderTex(this)));





                eqnExported=eqnExportIdler.startIdling(10);
                if~eqnExported
                    error(message("shared_mlreportgen_js_equation:error:equationExportFailure"));
                end


                message.unsubscribe(subscription);


                img=this.ImageURL;
            end
        end

        function subscriptionCallback(this,msg,eqnExportIdler)



            if isstruct(msg)&&isfield(msg,'dataURL')&&~isempty(msg.dataURL)


                this.ImageURL=string(msg.dataURL);



                eqnExportIdler.stopIdling();
            end
        end

        function imgFormat=getSnapshotFormat(this)

            imgFormat=strcat("image/",this.SnapshotFormat);
        end

        function str=getJSToApplyStyles(this)




            str=strcat(...
            "var texNode = document.getElementById('",this.NodeId,"');");


            if~isempty(this.Style.FontSize)
                str=strcat(str,...
                "texNode.style.fontSize = '",this.Style.FontSize,"';");
            end


            if~isempty(this.Style.Color)
                str=strcat(str,...
                "texNode.style.color = '",this.Style.Color,"';");
            end


            if~isempty(this.Style.BackgroundColor)
                str=strcat(str,...
                "texNode.style.backgroundColor = '",this.Style.BackgroundColor,"';");
            end
        end

        function str=getJSToRenderTex(this)




            eqnContent=replace(this.TexContent,'\','\\');
            eqnContent=strcat('$$',eqnContent,'$$');

            str=strcat(...
            "require([",...
            "'equationrenderercore/EquationRenderer',",...
            "'mw-messageservice/MessageService',",...
            "'dojo/domReady!'",...
            "], function(EquationRenderer, MessageService) {",...
            "MessageService.start();",...
            "channel = '",this.Channel,"';",...
            " ",...
            "var texNode = document.getElementById('",this.NodeId,"');",...
            "EquationRenderer.renderTeX('",eqnContent,"',",...
            "texNode);",...
            " ",...
            "var equationRendered = EquationRenderer.waitForEquations();",...
            "let equationExported = equationRendered.then(function () {",...
            "var imgObj = EquationRenderer.exportDomnodeToImageURL(",...
            "texNode.firstElementChild, 1, '",getSnapshotFormat(this),"');",...
            "return imgObj;",...
            "});",...
            " ",...
            "equationExported.then(value => {",...
            "MessageService.publish(channel, value);",...
            "});",...
"});"...
            );
        end

    end
end


function pageLoadCallback(~,~,idler)
    idler.stopIdling();
end
