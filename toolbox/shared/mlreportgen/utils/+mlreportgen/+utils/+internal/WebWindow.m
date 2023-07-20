classdef(Hidden)WebWindow<handle
























    properties(Dependent)
        URL;
        Title;
        Position;
    end

    properties(Access=private)
        Impl;
        IsOpen=true;
        TimeOut=5;
        MinDelay=0.1;

        ClosedURL;
        ClosedPosition;
        ClosedTitle;
    end

    methods
        function this=WebWindow(url,varargin)
            p=inputParser();
            addParameter(p,"Title","",@(x)ischar(x)||isstring(x));
            addParameter(p,"Position",this.defaultPosition(),@(x)isnumeric(x)&&(numel(x)==4));
            parse(p,varargin{:});
            args=p.Results;

            mlreportgen.utils.internal.logmsg('Create webwindow');
            hImpl=matlab.internal.webwindow(...
            char(url),...
            'Origin','TopLeft',...
            'Position',args.Position);

            mlreportgen.utils.internal.logmsg('Set webwindow title');
            hImpl.Title=char(args.Title);

            mlreportgen.utils.internal.logmsg('Set webwindow CustomWindowClosingCallback');
            hImpl.CustomWindowClosingCallback=@(src,evt)close(this);

            this.Impl=hImpl;
        end

        function delete(this)
            try
                cleanup(this);
            catch
            end
        end

        function url=get.URL(this)
            mlreportgen.utils.internal.logmsg('Get url');
            if isImplValid(this)
                hImpl=this.Impl;
                mlreportgen.utils.internal.logmsg('Get webwindow url');
                url=string(hImpl.URL);
            else
                mlreportgen.utils.internal.logmsg('Get closed url');
                url=this.ClosedURL;
            end
        end

        function set.URL(this,url)
            this.ClosedURL=url;
            mlreportgen.utils.internal.logmsg('Set webwindow url');
            hImpl=impl(this);
            hImpl.URL=char(url);
        end

        function pos=get.Position(this)
            mlreportgen.utils.internal.logmsg('Get position');
            if isImplValid(this)
                hImpl=this.Impl;
                mlreportgen.utils.internal.logmsg('Get webwindow position');
                pos=hImpl.Position;
            else
                mlreportgen.utils.internal.logmsg('Get closed position');
                pos=this.ClosedPosition;
            end
        end

        function set.Position(this,pos)
            this.ClosedPosition=pos;
            mlreportgen.utils.internal.logmsg('Set webwindow position');
            hImpl=this.impl();
            hImpl.Position=pos;
        end

        function title=get.Title(this)
            mlreportgen.utils.internal.logmsg('Get title');
            if isImplValid(this)
                mlreportgen.utils.internal.logmsg('Get webwindow title');
                hImpl=impl(this);
                title=string(hImpl.Title);
            else
                mlreportgen.utils.internal.logmsg('Get closed title');
                title=this.ClosedTitle;
            end
        end

        function set.Title(this,title)
            this.ClosedTitle=title;
            mlreportgen.utils.internal.logmsg('Set webvindow title');
            hImpl=impl(this);
            hImpl.Title=char(title);
        end

        function show(this)


            hImpl=impl(this);
            mlreportgen.utils.internal.logmsg('show webwindow');
            show(hImpl);

            mlreportgen.utils.internal.logmsg('bring webwindow to front');
            bringToFront(hImpl);

            mlreportgen.utils.internal.logmsg('wait for webwindow to be visible');
            mlreportgen.utils.internal.waitFor(@()(hImpl.isVisible),...
            "TimeOut",this.TimeOut,...
            "MinDelay",this.MinDelay);
            mlreportgen.utils.internal.logmsg('done waiting for webview to be visible');
        end

        function hide(this)


            mlreportgen.utils.internal.logmsg('hide webwindow');
            hImpl=impl(this);
            hide(hImpl);

            mlreportgen.utils.internal.waitFor(@()(~hImpl.isVisible),...
            "TimeOut",this.TimeOut,...
            "MinDelay",this.MinDelay);

            mlreportgen.utils.internal.logmsg('done waiting for webview to be invisible');
        end

        function tf=isVisible(this)



            if isImplValid(this)
                hImpl=this.Impl;
                tf=isVisible(hImpl);
            else
                tf=false;
            end
        end

        function tf=close(this)



            if~isOpen(this)
                throwAlreadyClosed(this);
            end
            cleanup(this);
            tf=true;
        end

        function tf=isOpen(this)



            tf=isImplValid(this);
        end

        function result=executeJS(this,query)



            mlreportgen.utils.internal.logmsg('test webwindow execute JS query');
            hImpl=impl(this);
            result=hImpl.executeJS(query);
        end
    end

    methods(Access=private)
        function cleanup(this)

            mlreportgen.utils.internal.logmsg('cleanup');

            if isImplValid(this)
                hImpl=this.Impl;

                mlreportgen.utils.internal.logmsg('save webwindow position');
                this.ClosedPosition=hImpl.Position;

                mlreportgen.utils.internal.logmsg('save webwindow title');
                this.ClosedTitle=string(hImpl.Title);

                mlreportgen.utils.internal.logmsg('save webwindow url');
                this.ClosedURL=string(hImpl.URL);

                mlreportgen.utils.internal.logmsg('closed webwindow');
                close(hImpl);

                mlreportgen.utils.internal.waitFor(@()~isOpen(this),...
                "TimeOut",this.TimeOut,...
                "MinDelay",this.MinDelay);

                this.Impl=[];

                mlreportgen.utils.internal.logmsg('done waiting for webwindow');
            end
        end

        function tf=isImplValid(this)
            hImpl=this.Impl;
            tf=~isempty(hImpl)&&isvalid(hImpl)&&hImpl.isWindowValid;
        end

        function hImpl=impl(this)
            mlreportgen.utils.internal.logmsg('get validated webwindow');
            if isImplValid(this)
                hImpl=this.Impl;
            else
                throwAlreadyClosed(this);
            end
        end

        function throwAlreadyClosed(this)
            cleanup(this);
            label=this.ClosedTitle;
            if(label.strlength==0)
                label=this.ClosedURL;
            end
            error(message("mlreportgen:utils:error:alreadyClosed",label));
        end
    end

    methods(Static,Access=private)
        function pos=defaultPosition()
            persistent POS
            if isempty(POS)
                ss=get(0,"ScreenSize");
                sh=double(ss(4));
                sw=double(ss(3));
                h=sh*.8;
                w=h*8.5/11;
                x=(sw-w)/2;
                y=(sh-h)/2;
                POS=round([x,y,w,h]);
            end
            pos=POS;
        end
    end
end