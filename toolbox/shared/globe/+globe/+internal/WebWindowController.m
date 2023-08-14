classdef WebWindowController<handle

































    properties(Dependent)
        Title char
Position
    end

    properties(SetAccess='protected',Dependent)
URL
    end

    properties(SetAccess=protected,Hidden)
        Window matlab.internal.webwindow=matlab.internal.webwindow.empty
        UsingDesktop(1,1)logical=matlab.internal.lang.capability.Capability.isSupported('LocalClient')
    end

    properties(Access=protected)
pPosition
        pTitle char=''
    end

    properties(Constant,Hidden)
        MinWidth=300
        MinHeight=300
    end

    properties(Constant,Hidden)
        DefaultWidth=800
        DefaultHeight=600
    end

    methods

        function controller=WebWindowController()






            controller.Position=globe.internal.WebWindowController.defaultWindowPosition;
        end

        function constructWindow(controller,url)

            pos=controller.Position;
            minSize=[controller.MinWidth,controller.MinHeight];

            if controller.UsingDesktop

                w=matlab.internal.webwindow(url,...
                matlab.internal.getDebugPort,'Position',pos);
                setMinSize(w,minSize);
            else


                w=matlab.internal.webwindow(url,'Position',pos);
                setMinSize(w,minSize);
                show(w);
            end
            w.Title=controller.Title;
            controller.Window=w;
        end


        function validWindow=isValidWindow(controller)
            w=controller.Window;
            validWindow=~isempty(w)&&isobject(w)&&isvalid(w)&&w.isWindowValid;
        end


        function tf=isWindowEnabled(controller)
            tf=isValidWindow(controller)...
            &&controller.Window.isWindowActive();
        end


        function makeActive(controller,fcn)
            w=controller.Window;
            if isWindowEnabled(controller)&&isprop(w,'FocusGained')...
                &&nargin==2&&isa(fcn,'function_handle')
                w.FocusGained=fcn;
            end
        end

        function bringToFront(controller)
            if isValidWindow(controller)
                controller.Window.bringToFront;
            end
        end

        function close(controller)
            if isWindowEnabled(controller)
                close(controller.Window)
            end
        end

        function delete(controller)
            if isValidWindow(controller)
                delete(controller.Window)
            end
        end

        function cdata=snapshot(controller,~)
            cdata=getScreenshot(controller.Window);
        end


        function tf=isVisible(controller)
            tf=isValidWindow(controller)&&...
            controller.Window.isVisible;
        end


        function addClosingCallback(controller,fcn)
            w=controller.Window;
            if isValidWindow(controller)
                w.CustomWindowClosingCallback=fcn;
            end
        end

        function url=get.URL(controller)
            if isValidWindow(controller)
                url=controller.Window.URL;
            else
                url='';
            end
        end

        function pos=get.Position(controller)
            pos=getPosition(controller);
        end


        function set.Position(controller,pos)
            validateattributes(pos,{'double'},...
            {'real','finite','nonsparse','size',[1,4]},'','Position');
            setPosition(controller,pos)
        end


        function title=get.Title(controller)
            title=getTitle(controller);
        end

        function set.Title(controller,title)
            setTitle(controller,title)
        end
    end

    methods(Access=protected)

        function pos=getPosition(controller)
            if isValidWindow(controller)
                pos=controller.Window.Position;
            else
                pos=controller.pPosition;
            end
        end

        function setPosition(controller,pos)
            if isValidWindow(controller)
                controller.Window.Position=pos;
            end
            controller.pPosition=pos;
        end


        function title=getTitle(controller)
            if isValidWindow(controller)
                title=controller.Window.Title;
            else
                title=controller.pTitle;
            end
        end

        function setTitle(controller,title)
            if isValidWindow(controller)
                controller.Window.Title=title;
            end
            controller.pTitle=title;
        end
    end

    methods(Static)
        function pos=defaultWindowPosition


            oldUnits=get(groot,'Units');
            if~strcmpi(oldUnits,'pixels')
                set(groot,'Units','pixels');
                screenSize=get(groot,'ScreenSize');
                set(groot,'Units',oldUnits);
            else
                screenSize=get(groot,'ScreenSize');
            end

            width=globe.internal.WebWindowController.DefaultWidth;
            height=globe.internal.WebWindowController.DefaultHeight;


            pos(1)=(screenSize(3)-width)/2;
            pos(2)=(screenSize(4)-height)/2;
            pos(3)=width;
            pos(4)=height;
        end
    end
end
