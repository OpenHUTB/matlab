

classdef WebGUI<handle


    properties(Hidden)
AppContainer
IsDebug
IsOpenInBrowser
WebPageHTML
    end


    methods
        function this=WebGUI(webPageHTML,isDebug,isOpenInBrowser,clientID)

            this.IsDebug=isDebug;
            this.IsOpenInBrowser=isOpenInBrowser;

            if this.IsDebug
                webPageHTML=webPageHTML+"-debug";
            end

            webPageHTML=webPageHTML+".html";

            webPageHTML=webPageHTML+"?clientID="+clientID;
            this.WebPageHTML=webPageHTML;

            if~this.IsOpenInBrowser
                appOptions.CleanStart=true;
                appOptions.AppPage=this.WebPageHTML;
                this.AppContainer=matlab.ui.container.internal.AppContainer(appOptions);
            end
        end

        function open(this)
            if~this.IsOpenInBrowser
                this.AppContainer.Visible=true;
            else
                url=connector.getUrl(this.WebPageHTML);

                web(connector.applyNonce(url),'-browser');
            end
        end

        function delete(this)
            delete(this.AppContainer);
        end
    end
end