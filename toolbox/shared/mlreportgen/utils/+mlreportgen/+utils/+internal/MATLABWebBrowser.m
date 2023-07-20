classdef(Hidden)MATLABWebBrowser<handle



























    properties(Dependent)
        URL;
    end

    properties(SetAccess=private)
        ShowAddressBox=true;
    end

    properties(Access=private)
        StartURL=string.empty();
        ClosedURL=string.empty();
        Impl=[];
    end

    methods
        function this=MATLABWebBrowser(url,varargin)
            p=inputParser();
            addParameter(p,"ShowAddressBox",true,@(x)islogical(x));
            parse(p,varargin{:});
            args=p.Results;

            this.StartURL=string(url);
            this.ShowAddressBox=args.ShowAddressBox;
        end

        function delete(this)
            cleanup(this);
        end

        function url=get.URL(this)
            if isOpen(this)
                if isImplValid(this)
                    url=string(this.Impl.getCurrentLocation());
                else
                    url=this.StartURL;
                end
            else
                url=this.ClosedURL;
            end
        end

        function set.URL(this,url)
            if isOpen(this)
                if isImplValid(this)
                    this.Impl.setCurrentLocation(url);
                else
                    this.StartURL=string(url);
                end
            else
                throwAlreadyClosed(this);
            end
        end

        function show(this)



            if isOpen(this)
                if isImplValid(this)
                    hImpl=this.Impl;
                    md=com.mathworks.mde.desk.MLDesktop.getInstance();
                    md.showClient(hImpl,[],true);
                    drawnow();
                    mlreportgen.utils.internal.waitFor(@()hImpl.isShowing());
                    hImpl.requestFocus();
                else
                    url=this.StartURL;
                    if connector.isRunning
                        url=connector.applyNonce(url);
                    end




                    warnState=warning("query",...
                    "MATLAB:web:BrowserOuptputArgRemovedInFutureRelease");
                    warning("off",warnState.identifier);
                    scopedRestoreWarning=onCleanup(@()warning(warnState));

                    if~this.ShowAddressBox
                        [~,hImpl]=web(url,"-new","-noaddressbox");
                    else
                        [~,hImpl]=web(url,"-new");
                    end
                    drawnow();
                    mlreportgen.utils.internal.waitFor(...
                    @()compareURL(string(hImpl.getCurrentLocation()),this.StartURL));
                    this.Impl=hImpl;
                end
            else
                throwAlreadyClosed(this);
            end
        end

        function hide(this)



            if isOpen(this)
                if isVisible(this)
                    hImpl=this.Impl;
                    md=com.mathworks.mde.desk.MLDesktop.getInstance();
                    md.hideClient(hImpl);
                    mlreportgen.utils.internal.waitFor(@()~hImpl.isShowing);
                end
            else
                throwAlreadyClosed(this);
            end
        end

        function tf=isVisible(this)



            tf=false;
            if(isOpen(this)&&isImplValid(this))
                hImpl=this.Impl;
                tf=hImpl.isShowing;
            end
        end

        function tf=close(this)



            if isOpen(this)
                cleanup(this);
                tf=true;
            else
                throwAlreadyClosed(this);
            end
        end

        function tf=isOpen(this)



            tf=isempty(this.Impl)||isImplValid(this);


        end
    end

    methods(Access=private)
        function cleanup(this)
            hImpl=this.Impl;
            if isa(hImpl,"com.mathworks.mde.webbrowser.WebBrowser")
                this.ClosedURL=string(hImpl.getCurrentLocation());
                close(hImpl);
                this.Impl=-1;
            end
        end

        function throwAlreadyClosed(this)
            cleanup(this);
            url=this.ClosedURL;
            if isempty(url)||(strlength(url)==0)
                url=this.StartURL;
            end
            error(message("mlreportgen:utils:error:alreadyClosed",url));
        end

        function tf=isImplValid(this)
            hImpl=this.Impl;
            tf=isa(hImpl,"com.mathworks.mde.webbrowser.WebBrowser")...
            &&~isempty(hImpl.getParent());
        end
    end
end

function tf=compareURL(url1,url2)
    if isempty(url1)
        tf=isempty(url2);
    else
        normURL1=regexprep(url1,'/+','/');
        normURL2=regexprep(url2,'/+','/');


        normURL1=regexprep(normURL1,'\?snc=.*$','');
        normURL2=regexprep(normURL2,'\?snc=.*$','');

        if isempty(normURL1)
            tf=isempty(normURL2);
        else
            tf=strcmp(normURL1,normURL2);
        end
    end
end
