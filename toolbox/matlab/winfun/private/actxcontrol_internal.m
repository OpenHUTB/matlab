function[hControl,hContainer,javacanvas]=actxcontrol_internal(progID,varargin)































































    if~(strcmpi(computer,'PCWIN')||strcmpi(computer,'PCWIN64'))
        error(message('MATLAB:actxcontrol:nonWindows'));
    end

    if(nargin==0)
        hControl=matlab.ui.internal.JavaMigrationTools.suppressedActXControllist;
        return;
    end

    position=[20,20,60,60];
    callback='';
    parent=[];
    filename='';
    licensekey='';
    parent_string='';

    progID=convertStringsToChars(progID);
    [varargin{:}]=convertStringsToChars(varargin{:});

    if((nargin>1)&&ischar(varargin{1}))

        param={'position','parent','callback','filename','licensekey'};

        if mod(length(varargin),2)==1
            error(message('MATLAB:actxcontrol:numargs'));
        end

        for i=1:2:length(varargin)
            p=lower(varargin{i});
            v=varargin{i+1};

            try
                fieldmatch=ismember(p,param);
            catch e
                error('MATLAB:actxcontrol:unknownparam','%s',...
                getString(message('MATLAB:actxcontrol:unknownparamPosition',i+1)));
            end

            if(~fieldmatch)
                if ischar(p)
                    warning(message('MATLAB:actxcontrol:unknownparam',p));
                else
                    warning('MATLAB:actxcontrol:unknownparam','%s',...
                    getString(message('MATLAB:actxcontrol:unknownparamPosition',i+1)));
                end
            end

            switch p
            case 'position'
                position=v;

            case 'parent'
                [parent,parent_string]=validateParent(v);

            case 'callback'
                callback=v;

            case 'filename'
                filename=v;

            case 'licensekey'
                licensekey=v;
            end
        end

    elseif(nargin>1)

        if nargin>1,
            position=varargin{1};
        end

        if nargin>2,
            [parent,parent_string]=validateParent(varargin{2});
        end

        if nargin>3,
            callback=varargin{3};
        end

        if nargin>4,
            filename=varargin{4};
        end

        if nargin>5
            licensekey=varargin{5};
        end
    end

    if isempty(parent)
        parent=gcf;
    end

    createContainer=false;
    javacanvas=[];
    deletedYet=false;

    hActxListeners=[];
    hObjListeners=[];

    if isfigurescalar(parent)&&usejava('awt')==1

        [javacanvas,hwnd]=getCurrentCanvasAndHwnd(parent);


        if~strcmpi(get(parent,'WindowStyle'),'docked')
            set(parent,'DockControls','off');
        end



        if nargout>1
            hContainer=[];
            createContainer=true;
        end
    else

        hwnd=0;
    end


    convertedProgID=newprogid(progID);


    try


        comstr=['COM.',convertedProgID];
        hControl=createControl;
    catch originalException
        if(strcmpi(originalException.identifier,'MATLAB:Undefinedfunction'))
            newException=MException('MATLAB:COM:InvalidProgid',getString(message('MATLAB:COM:controlcreationfailedProgid',progID)));
            throw(newException);
        else
            rethrow(originalException);
        end
    end


    hControl.move(position);
    if isfigurescalar(parent)


        hControl.move(matlab.ui.internal.PositionUtils.getPixelRectangleInDevicePixels(position,parent));
    end
    if~isempty(javacanvas)
        drawnow;
    end

    filename=tempname;

    if~isempty(callback)
        registerevent(hControl,callback);
    end

    if createContainer
        hContainer=createPanel;
        setappdata(hContainer,'JavaCanvas',javacanvas);
    end


    function ctrl=createControl
        ctrl=feval(comstr,'control',position,double(parent),'',...
        filename,hwnd,licensekey,false,parent_string);

        controlSetup();


        function controlSetup()
            if~isempty(javacanvas)



                p=ctrl.findprop('MMProperty_Container');
                if isempty(p)
                    p=schema.prop(ctrl,'MMProperty_Container','mxArray');
                end


                p.AccessFlags.Publicget='on';
                p.AccessFlags.Publicset='on';
                p.Visible='off';
                p.AccessFlags.Serialize='off';

                set(ctrl,'MMProperty_Container',java(javacanvas));

                if isempty(hActxListeners)
                    parentfig=ancestor(parent,'figure');
                    fighandle=handle(parentfig);



                    hActxListeners=[hActxListeners,handle.listener(ctrl,'ObjectBeingDestroyed',{@controlDelete})];


                    hObjListeners=[hObjListeners,addlistener(fighandle,'SizeChanged',@(o,e)controlReposition(o,e,parentfig,false))];
                    hObjListeners=[hObjListeners,addlistener(fighandle,'ObjectBeingDestroyed',@(o,e)figureDelete(ctrl))];



                    set(javacanvas,'PositionChangedCallback',@(o,e)controlReposition(o,e,parentfig,true));
                end
            end


            function controlDelete(~,~)
                deletedYet=true;

                set(ctrl,'MMProperty_Container',[]);


                delete(hActxListeners);
                delete(hObjListeners);



                fig=ancestor(parent,'figure');
                removeCurrentCanvasAndHWnd(fig,javacanvas);


                if createContainer
                    if ishghandle(hContainer)
                        delete(hContainer);
                    end
                end
            end


            function controlReposition(obj,evd,fig,reposition)
                if~deletedYet&&strcmp(get(fig,'BeingDeleted'),'off')
                    if isequal(obj,javacanvas)

                        pos=evd.getCurrentPosition;
                    else

                        pos=hControl.move;
                    end



                    hControl.move(pos,reposition);
                end
            end


            function figureDelete(ctr)
                delete(ctr);
            end
        end
    end


    function out=createPanel
        out=uicontainer('Parent',parent,'Units','pixels','Position',position,'Visible','off','Serializable','off');
        setappdata(out,'InResize',false);


        h1=addlistener(parent,'SizeChanged',@handleResize);
        h2=addlistener(out,'SizeChanged',@handleResize);


        handleResize(parent,[]);


        set(out,'DeleteFcn',@panelDelete)


        function panelDelete(~,~)
            deletedYet=true;


            delete(h1);
            delete(h2);




            if ishandle(hControl)
                delete(hControl)
            end
        end


        function handleResize(~,~)
            if getappdata(out,'InResize')
                return
            end
            setappdata(out,'InResize',true);

            hControl.move(matlab.ui.internal.PositionUtils.getDevicePixelPosition(out));
            setappdata(out,'InResize',false);
        end
    end
end


function isfig=isfigurescalar(parent)

    isfig=isequal(ishghandle(parent,'figure'),1);
end


function[par,parent_string]=validateParent(parent)
    par=parent;
    parent_string='';
    if ischar(parent)
        parent_string=parent;
        if~strcmpi(parent_string,'command')
            try
                par=get_param(parent,'Handle');
            catch ex
                error(message('MATLAB:COM:InvalidFigureContainer'));
            end
        end
    elseif~ishandle(parent)||(ishghandle(parent)&&~ishghandle(parent,'figure'))
        error(message('MATLAB:COM:InvalidFigureContainer'));
    end
end


function[canvas,hwnd]=getCurrentCanvasAndHwnd(parent)
    jf=getJavaFrame(parent);

    if(isempty(jf))
        error(message('MATLAB:COM:InvalidFigureContainer'));
    end

    canvas=jf.getActiveXCanvas;
    if isempty(canvas)
        for i=1:100
            drawnow;
            canvas=jf.getActiveXCanvas;
            if~isempty(canvas)
                break;
            end
        end
        if isempty(canvas)&&i==100
            error('MATLAB:COM:InvalidFigureContainer','%s',getString(message('MATLAB:COM:InvalidFigureContainerCanvas')));
        end
    end
    canvas=handle(canvas,'callbackproperties');

    counter=0;
    valid=canvas.isNativeWindowHandleValid;
    while~valid&&counter<100
        counter=counter+1;
        drawnow;

        valid=canvas.isNativeWindowHandleValid;
    end

    hwnd=canvas.getNativeWindowHandle;

    if~valid
        error('MATLAB:COM:InvalidFigureContainer','%s',getString(message('MATLAB:COM:InvalidFigureContainerWindow')));
    end
end


function removeCurrentCanvasAndHWnd(parent,canvas)
    if ishandle(canvas)
        if strcmp(get(parent,'BeingDeleted'),'off')
            jf=getJavaFrame(parent);
            jf.removeActiveXControl(canvas);
        end
        delete(canvas);
    end
end


function javaFrame=getJavaFrame(f)

    [lastWarnMsg,lastWarnId]=lastwarn;



    oldJFWarning=warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
    javaFrame=matlab.ui.internal.JavaMigrationTools.suppressedJavaFrame(f);
    warning(oldJFWarning.state,'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');


    lastwarn(lastWarnMsg,lastWarnId);
end
