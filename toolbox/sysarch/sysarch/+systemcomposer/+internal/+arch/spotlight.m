function spotlightObj=spotlight(app,component,varargin)















    nargoutchk(0,2);
    narginchk(2,5);

    openViewer=false;
    studioTag='StudioDefault';
    debugMode=0;
    if(nargin==2)
    elseif(nargin==3)
        openViewer=varargin{1};
    elseif(nargin==4)
        openViewer=varargin{1};
        debugMode=varargin{2};
    elseif(nargin==5)
        openViewer=varargin{1};
        debugMode=varargin{2};
        studioTag=varargin{3};
    end

    if~openViewer
        assert(nargout<=1,'Second output argument only supported if openViewer is true');
    end


    connector.ensureServiceOn;
    if ischar(app)
        app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(...
        get_param(app,'handle'));
    end

    if ischar(component)||isStringScalar(component)
        compToSpotlight=systemcomposer.internal.arch.findElement(component,app.getTopLevelCompositionArchitecture);
    elseif isa(component,'systemcomposer.arch.BaseComponent')
        compToSpotlight=component.getImpl;
    elseif isa(component,'systemcomposer.architecture.model.design.BaseComponent')
        compToSpotlight=component;
    else
        error('Please provide either the component object or the component path');
    end


    spotlightObj=app.createSpotlight(compToSpotlight,studioTag);

    if openViewer

        switch debugMode
        case 1

            app.openSpotlight(compToSpotlight,studioTag,true,true);
        case 2

            if(isequal(studioTag,'StudioDefault'))


                app.initSpotlight(compToSpotlight,studioTag,true);
            else

                app.openSpotlight(compToSpotlight,studioTag,false,true);
            end
        case 3

            error('Not supported');
        otherwise

            app.openSpotlight(compToSpotlight,studioTag,false,false);
        end
    end


