classdef(Hidden)GlobeModelViewer<matlab.mixin.SetGet

    properties(Dependent)

Parent

Name

Position

Basemap

Terrain
    end


    properties(GetAccess=public,SetAccess=private,Dependent)

Visible

UseTerrain
    end


    properties(Hidden,Dependent)
URL
UseDebug
GlobeOptions
    end


    properties(Hidden)
        LaunchWebWindow(1,1)logical=true
    end


    properties(GetAccess=public,SetAccess=protected,Hidden)
        Controller globe.internal.GlobeController=globe.internal.GlobeController.empty
        Launched(1,1)logical=false
    end


    properties(GetAccess=public,SetAccess=private,Dependent,Hidden)
Window
CesiumVersion
    end


    properties(Access=protected,Constant)
        TitleString=message('shared_globe:viewer:GlobeViewerTitle').getString()
    end


    properties(Access=private)
        pParent=matlab.ui.Figure.empty
    end

    methods
        function viewer=GlobeModelViewer(varargin)

            if nargin>0&&rem(length(varargin),2)
                controller=varargin{1};
                varargin(1)=[];
            else
                controller=globe.internal.GlobeController();
            end
            viewer.Controller=controller;


            viewer.Controller.GlobeModel.Name=viewer.TitleString;

            try
                globe.internal.setObjectNameValuePairs(viewer,varargin)
                if~isempty(viewer.Parent)
                    windowController=globe.internal.UIContainerController(viewer.Parent);
                else
                    windowController=globe.internal.WebWindowController;
                end
                viewer.Controller.WindowController=windowController;
            catch e
                throwAsCaller(e)
            end
            viewer.UseDebug=viewer.GlobeOptions.UseDebug;
            viewer.Controller.LaunchWebWindow=viewer.LaunchWebWindow;

            if viewer.LaunchWebWindow&&~isempty(viewer.Parent)
                validateBasemapAccess(controller)
            end

            show(viewer)
            w=controller.WindowController;
            if isValidWindow(w)
                addClosingCallback(w,@(evt,src)close(viewer))
            end
        end


        function name=get.Name(viewer)
            name=viewer.Controller.Name;
        end


        function set.Name(viewer,name)
            viewer.Controller.Name=name;
        end


        function pos=get.Position(viewer)
            pos=viewer.Controller.Position;

        end


        function set.Position(viewer,pos)
            viewer.Controller.Position=pos;
        end


        function basemap=get.Basemap(viewer)
            basemap=viewer.Controller.Basemap;
        end


        function set.Basemap(viewer,basemap)
            viewer.Controller.Basemap=basemap;
        end


        function terrain=get.Terrain(viewer)
            terrain=viewer.Controller.Terrain;
        end


        function set.Terrain(viewer,terrain)
            if~viewer.Launched
                viewer.Controller.GlobeModel.TerrainName=terrain;
            else
                error(message('MATLAB:class:SetProhibited','Terrain',mfilename))
            end
        end


        function vis=get.Visible(viewer)
            vis=viewer.Controller.Visible;
        end


        function url=get.URL(viewer)
            url=viewer.Controller.URL;
        end


        function useterrain=get.UseTerrain(viewer)
            useterrain=viewer.Controller.UseTerrain;
        end


        function w=get.Window(viewer)
            w=viewer.Controller.WindowController.Window;
        end


        function v=get.CesiumVersion(viewer)
            v=viewer.Controller.CesiumVersion;
        end


        function options=get.GlobeOptions(viewer)
            options=viewer.Controller.GlobeModel.GlobeOptions;
        end

        function set.GlobeOptions(viewer,options)
            viewer.Controller.GlobeModel.GlobeOptions=options;
        end

        function tf=get.UseDebug(viewer)
            tf=viewer.Controller.UseDebug;
        end


        function set.UseDebug(viewer,tf)
            viewer.Controller.UseDebug=tf;
        end


        function set.Parent(viewer,parent)
            if~viewer.Launched
                viewer.pParent=parent;
            else
                error(message('MATLAB:class:SetProhibited','Parent',mfilename))
            end
        end

        function parent=get.Parent(viewer)
            parent=viewer.pParent;
        end

        function show(viewer)
            if viewer.LaunchWebWindow&&~viewer.Launched
                show(viewer.Controller)
                viewer.Launched=true;
            end
            fcn=@(src,evnt)globe.internal.GlobeViewer.current(viewer);
            makeActive(viewer.Controller.WindowController,fcn)
        end


        function close(viewer)
            close(viewer.Controller)
            delete(viewer)
        end


        function delete(viewer)
            delete(viewer.Controller)
            delete(viewer)
        end
    end

    methods(Hidden)
        function visualRequest(viewer,request,data)



            visualRequest(viewer.Controller,request,data)
        end
    end
end
