classdef(Hidden=true)UIContainerController...
    <globe.internal.WebWindowController...
    &matlab.mixin.SetGet
    properties(GetAccess=public,SetAccess=private)

        HTMLController matlab.ui.control.HTML=matlab.ui.control.HTML.empty
    end

    properties(Access=private)

Visible

        HTMLControllerParentIsCreated logical=false

        HTMLControllerIsCreated logical=false









        CallbackListener=event.listener.empty





        FocusListener=event.listener.empty
    end

    methods

        function controller=UIContainerController(varargin)




















            controller=controller@globe.internal.WebWindowController();
            if nargin==0
                firstArg=uifigure;
                controller.HTMLControllerParentIsCreated=true;
            else
                firstArg=varargin{1};
            end

            if isa(firstArg,'matlab.ui.control.HTML')

                htmlController=firstArg;
                htmlController.Internal=true;
                controller.Visible=htmlController.Visible;
            else

                htmlControllerParent=firstArg;
                htmlController=matlab.ui.control.HTML(...
                'Parent',htmlControllerParent,...
                'Visible','off',...
                'Internal',true);
                htmlController.Position=...
                [1,1,htmlControllerParent.Position(3:4)];
                controller.Visible='on';
                controller.HTMLControllerIsCreated=true;
            end

            controller.HTMLController=htmlController;
        end

        function constructWindow(controller,url)
            htmlController=controller.HTMLController;
            if~isempty(htmlController)&&isvalid(htmlController)
                controller.Window=setHTMLController(controller,url);
            else


                error(message('shared_globe:viewer:InvalidHandle',class(htmlController)))
            end
        end

        function addClosingCallback(controller,fcn)





            if controller.HTMLControllerIsCreated...
                &&isempty(controller.CallbackListener)
                obj=controller.HTMLController;
                controller.CallbackListener=event.listener(obj,...
                'ObjectBeingDestroyed',fcn);
            end
        end

        function bringToFront(controller)%#ok<MANU>




        end

        function tf=isVisible(controller)




            w=controller.Window;
            htmlIsValid=isValidWindow(controller);
            if htmlIsValid&&~isempty(w)&&isobject(w)&&isvalid(w)





                tf=w.isWindowValid;
            else
                tf=htmlIsValid;
            end
        end

        function tf=isWindowEnabled(controller)
            tf=isValidWindow(controller)...
            &&~isempty(controller.Window)&&isvalid(controller.Window);
        end

        function validWindow=isValidWindow(controller)



            html=controller.HTMLController;
            if~isempty(html)&&isvalid(html)&&~isempty(html.HTMLSource)
                hfig=ancestor(html,'figure');
                validWindow=~isempty(hfig)&&isvalid(hfig);
            else
                validWindow=false;
            end
        end


        function close(controller)
            if isvalid(controller)
                delete(controller)
            end
        end

        function makeActive(controller,fcn)


            w=controller.HTMLController.Parent;
            if isWindowEnabled(controller)&&isa(w,"matlab.ui.Figure")...
                &&nargin==2&&isa(fcn,'function_handle')
                controller.FocusListener=addlistener(w,...
                'FigureActivated',fcn);
            end
        end

        function delete(controller)
            listener=controller.CallbackListener;
            if~isempty(listener)&&isvalid(listener)
                delete(listener)
            end
            if~isempty(controller.FocusListener)&&isvalid(controller.FocusListener)
                delete(controller.FocusListener);
            end

            htmlController=controller.HTMLController;
            if~isempty(htmlController)
                w=controller.Window;
                if~isempty(w)&&isobject(w)&&isvalid(w)





                    w.CustomWindowClosingCallback=[];
                    controller.Window=matlab.internal.webwindow.empty;
                end

                if isvalid(htmlController)
                    if controller.HTMLControllerParentIsCreated
                        parent=htmlController.Parent;
                        if~isempty(parent)&&isvalid(parent)
                            delete(parent)
                        end
                    end

                    if controller.HTMLControllerIsCreated
                        delete(htmlController)
                    end
                end
            end
        end
    end

    methods(Access=protected)

        function pos=getPosition(controller)
            w=controller.Window;
            if~isempty(w)&&isobject(w)&&isvalid(w)
                pos=w.Position;
            else
                pos=controller.pPosition;
            end
        end

        function setPosition(controller,pos)
            w=controller.Window;
            if~isempty(w)&&isobject(w)&&isvalid(w)
                w.Position=pos;
            end
            controller.pPosition=pos;
        end

        function title=getTitle(controller)
            w=controller.Window;
            if~isempty(w)&&isobject(w)&&isvalid(w)
                title=w.Title;
            else
                title=controller.pTitle;
            end
        end

        function setTitle(controller,title)
            w=controller.Window;
            if~isempty(w)&&isobject(w)&&isvalid(w)
                w.Title=title;
            end
            controller.pTitle=title;
        end
    end

    methods(Access=private)
        function webwindow=setHTMLController(controller,URL)


            htmlController=controller.HTMLController;
            if~isempty(htmlController)&&isvalid(htmlController)...
                &&isscalar(htmlController)&&ishghandle(htmlController)



                if controller.UsingDesktop

                    hfig=ancestor(htmlController,'figure');
                    figURL=matlab.ui.internal.FigureServices.getFigureURL(hfig);


                    wmgr=matlab.internal.webwindowmanager.instance;
                    w=wmgr.windowList;
                    webwindow=findobj(w,'URL',figURL);
                else
                    webwindow=matlab.internal.webwindow.empty;
                end


                set(htmlController,'HTMLSource',URL,'Visible',controller.Visible);
            else
                error(message('shared_globe:viewer:InvalidHandle',class(htmlController)))
            end
        end
    end
end
