classdef(Sealed)siteviewer<handle&matlab.mixin.CustomDisplay





















































































    properties(Dependent)



Name







Position



















Basemap
    end

    properties(Dependent,Hidden)
Visible
UseTerrain
isTerrainURLAvailable
TerrainSource
LaunchWebWindow
MaxImageSize
    end

    properties(Constant,Hidden)
        SettingsGroup=rfpropSettingsGroup
        GlobeSettingsGroup=globeSettingsGroup
        TerrainSettingsGroup=sharedTerrainSettingsGroup
        Appdataname='managed_siteviewer_objects'
        DefaultSize=[800,600]
    end

    properties(Dependent,SetAccess=immutable)









Terrain
    end

    properties(Dependent,Hidden,SetAccess=private)
HasBuildings
    end

    properties(Hidden,Transient,SetAccess=private)
Instance
Visualizer
    end

    properties(SetAccess=immutable)






        Buildings=''







        CoordinateSystem=""










        SceneModel='none'





        ShowEdges(1,1)logical=true
    end

    properties(Dependent)





        Transparency(1,1)double{mustBeNonnegative,mustBeLessThanOrEqual(Transparency,1)}
    end

    properties(Access=private)
        pTransparency(1,1)double{mustBeNonnegative,mustBeLessThanOrEqual(pTransparency,1)}=0.1
        pShowOrigin(1,1)logical=true
    end

    properties(Dependent)




        ShowOrigin(1,1)logical
    end

    properties(Hidden)
BuildingsArray
BuildingsLimits
BuildingsTerrainTriangulation
BuildingsModel
BuildingsCenter
        ModelTriangulation='none'
        LegendID=''
        LegendEntities=strings(0)
        TempFiles={}
        Clipping=false
FigureHandle
ProgressDialogHandle
        OnGlobeDestroyedListener=event.listener.empty
        SiteGraphics=struct()
        ColorGraphics=struct()
        IsCartesian=false
        FocusListener=event.listener.empty
    end

    methods
        function viewer=siteviewer(varargin)


            try
                rfprop.PropagationModel.initializePropModels;

                p=inputParser;
                p.addParameter("Name",message('shared_channel:rfprop:SiteViewerTitle').getString);
                p.addParameter("Buildings",'');
                p.addParameter("Terrain",defaultTerrainName);
                p.addParameter("Basemap",globe.internal.GlobeModel.defaultBasemap);
                p.addParameter("Position",globe.internal.getCenterPosition(siteviewer.DefaultSize));
                p.addParameter("Visible",true);
                p.addParameter("UseDebug",false);
                p.addParameter("SceneModel",'',@(model)mustBeFileOrTriangulation(model));
                p.addParameter("ShowEdges",true);
                p.addParameter("Transparency",0.1);
                p.addParameter("ShowOrigin",true);
                p.addParameter("Hidden",false);
                p.parse(varargin{:});
                opt=globe.internal.GlobeOptions;


                opt=enableAll(opt);
                opt.EnableDayNightLighting=false;
                opt.EnableInertialCamera=false;
                opt.Enable2DLaunch=false;

                opt.UseDebug=p.Results.UseDebug;
                name=validateName(p.Results.Name);
                terrainName=validateTerrain(p.Results.Terrain);
                basemap=p.Results.Basemap;
                position=validatePosition(p.Results.Position);
                visible=p.Results.Visible;
                model=p.Results.SceneModel;
                viewer.ShowEdges=p.Results.ShowEdges;
                hidden=p.Results.Hidden;
                if~hidden
                    viewer.FigureHandle=uifigure('Position',position,'Visible',false,'Tag','siteviewerUIFigure','Name',name);
                end
                if~viewer.ShowEdges&&ismember('Transparency',p.UsingDefaults)



                    viewer.pTransparency=1;
                else
                    viewer.pTransparency=p.Results.Transparency;
                end
                if(~ismember('SceneModel',p.UsingDefaults))
                    viewer.IsCartesian=true;
                    viewer.CoordinateSystem="cartesian";
                    if isempty(p.Results.SceneModel)
                        viewer.SceneModel='none';
                    else
                        viewer.SceneModel=model;
                    end
                else
                    viewer.CoordinateSystem="geographic";




                    viewer.FigureHandle.AutoResizeChildren=false;
                end

                if~viewer.IsCartesian
                    if~hidden
                        viewer.Instance=globe.graphics.GeographicGlobe('Parent',viewer.FigureHandle,...
                        'GlobeOptions',opt,...
                        'Terrain',terrainName,...
                        'Basemap',basemap);


                        viewer.OnGlobeDestroyedListener=listener(...
                        viewer.Instance,...
                        'ObjectBeingDestroyed',...
                        @(~,~)close(viewer));

                        viewer.Visualizer=viewer.Instance.GlobeViewer;
                        viewer.Visualizer.addViewer("LOS",globe.internal.LOSViewer(viewer.Visualizer.Controller));
                        viewer.Visualizer.Name=name;
                    else


                        viewer.Instance=struct;
                        viewer.Visualizer=viewer.Instance;
                        viewer.Visualizer.Controller.TerrainSource=...
                        terrain.internal.TerrainSource.createFromSettings('gmted2010');
                    end
                else
                    viewer.Visualizer=matlabshared.threejs.CartesianViewer(...
                    "Name",name,...
                    "Position",position,...
                    "Parent",viewer.FigureHandle,...
                    "UseDebug",p.Results.UseDebug);


                    if~strcmp(viewer.SceneModel,'none')
                        if isa(model,'triangulation')
                            viewer.SceneModel=model;
                            TR=model;
                        else
                            viewer.SceneModel=string(model);
                            TR=stlread(model);
                        end
                        geomodel=globe.internal.Geographic3DModel(TR);
                        viewer.Visualizer.model3DScene(geomodel,...
                        "ID","sceneModel",...
                        "EnableLighting",true,...
                        "ShowEdges",viewer.ShowEdges,...
                        "Persistent",true,...
                        "Opacity",viewer.Transparency);
                        viewer.ModelTriangulation=TR;
                    end
                    viewer.ShowOrigin=p.Results.ShowOrigin;
                end


                siteviewer.current(viewer);
                if~hidden
                    viewer.addClosingCallback();
                    viewer.addFocusGainedCallback();
                end
                viewer.Visible=visible;


                if~viewer.IsCartesian&&~ismember('Buildings',p.UsingDefaults)
                    buildings=p.Results.Buildings;
                    validateattributes(buildings,{'char','string'},{'scalartext'},'siteviewer','Buildings');
                    viewer.Buildings=char(buildings);
                    showBuildings(viewer)
                end






                if strcmp(viewer.GlobeSettingsGroup.DefaultTerrain.ActiveValue,'none')...
                    &&~viewer.isTerrainURLAvailable

                    viewer.SettingsGroup.DefaultTerrain.TemporaryValue='none';
                end
            catch e


                if~isempty(viewer.FigureHandle)&&isvalid(viewer.FigureHandle)
                    close(viewer.FigureHandle);
                end
                throw(e)
            end
        end

        function clearMap(viewer)





            try
                viewer.SiteGraphics=struct();
                viewer.ColorGraphics=struct();
                viewer.clearLegend;
                clear(viewer.Visualizer)
            catch e
                throwAsCaller(e)
            end
        end

        function close(viewer)




            delete(viewer);
        end

        function delete(viewer)
            try
                manager=globe.internal.LifeCycleManager(siteviewer.Appdataname);
                manager.remove(viewer);
                if(~isempty(viewer.FigureHandle)&&~isstruct(viewer.FigureHandle)&&isvalid(viewer.FigureHandle))
                    delete(viewer.FigureHandle);
                end
                if(~isempty(viewer.OnGlobeDestroyedListener))
                    delete(viewer.OnGlobeDestroyedListener);
                end
                viewer.deleteTempFiles;
                if(isvalid(viewer.FocusListener))
                    delete(viewer.FocusListener);
                end
            catch e
                throwAsCaller(e)
            end
        end

        function visible=get.Visible(viewer)
            visible=strcmpi(viewer.FigureHandle.Visible,'on');
        end

        function set.Visible(viewer,visible)
            viewer.FigureHandle.Visible=visible;
        end

        function terrain=get.Terrain(viewer)
            if viewer.IsCartesian
                terrain='none';
            else
                terrain=viewer.Instance.Terrain;
            end
        end

        function terrainSource=get.TerrainSource(viewer)
            terrainSource=viewer.Visualizer.Controller.TerrainSource;
        end

        function launchWebWindow=get.LaunchWebWindow(viewer)
            launchWebWindow=viewer.Visualizer.LaunchWebWindow;
        end

        function maxImageSize=get.MaxImageSize(viewer)
            maxImageSize=viewer.Visualizer.Controller.MaxImageSize;
        end

        function set.MaxImageSize(viewer,imageSize)
            viewer.Visualizer.Controller.MaxImageSize=imageSize;
        end

        function set.ShowOrigin(viewer,showOrigin)
            if viewer.IsCartesian
                if viewer.pShowOrigin~=showOrigin
                    viewer.pShowOrigin=showOrigin;
                    viewer.Visualizer.setOriginVisibility(viewer.pShowOrigin);
                end
            end
        end

        function showOrigin=get.ShowOrigin(viewer)
            showOrigin=viewer.pShowOrigin;
        end

        function transparency=get.Transparency(viewer)
            transparency=viewer.pTransparency;
        end

        function set.Transparency(viewer,transparency)
            if viewer.IsCartesian&&transparency~=viewer.pTransparency
                viewer.pTransparency=transparency;
                viewer.Visualizer.updateModel3DScene("sceneModel","Opacity",transparency);
            end
        end

        function useTerrain=get.UseTerrain(viewer)
            if viewer.IsCartesian
                useTerrain=false;
            else
                useTerrain=viewer.Visualizer.UseTerrain;
            end
        end

        function urlAvailable=get.isTerrainURLAvailable(viewer)
            urlAvailable=viewer.Visualizer.Controller.GlobeModel.isTerrainURLAvailable;
        end

        function hasBldgs=get.HasBuildings(viewer)
            hasBldgs=~isempty(viewer.BuildingsModel);
        end

        function name=get.Name(viewer)
            name=viewer.FigureHandle.Name;
        end

        function set.Name(viewer,name)
            try
                viewer.FigureHandle.Name=validateName(name);
            catch e
                throwAsCaller(e);
            end
        end

        function pos=get.Position(viewer)
            pos=viewer.FigureHandle.Position;
        end

        function set.Position(viewer,pos)
            try
                viewer.FigureHandle.Position=validatePosition(pos);
            catch e
                throwAsCaller(e);
            end
        end

        function bmap=get.Basemap(viewer)
            if viewer.IsCartesian
                bmap='none';
            else
                bmap=viewer.Instance.Basemap;
                bmap=strrep(bmap,'_','-');
            end
        end

        function set.Basemap(viewer,bmap)
            try
                if~viewer.IsCartesian
                    viewer.Instance.Basemap=bmap;
                end
            catch e
                throw(e)
            end
        end
    end

    methods(Hidden)

        function bringToFront(viewer)
            figure(viewer.FigureHandle);
        end

        function remove(viewer,IDs)
            if(isempty(IDs))
                return
            end
            if(~iscell(IDs))
                IDs=mat2cell(IDs,1);
            end
            viewer.Visualizer.remove(unique(IDs));
        end

        function removeColorData(viewer,id)
            if(isfield(viewer.ColorGraphics,id))
                viewer.ColorGraphics=rmfield(viewer.ColorGraphics,id);
            end
        end

        function IDs=getGraphicsIDs(viewer,siteID)

            site=viewer.SiteGraphics.(siteID);
            IDs={};
            IDs=[IDs;site.contour];
            IDs=[IDs;site.pattern];
            IDs=[IDs;site.legend];
            IDs=[IDs;site.infoboxLegend];
            losFields=fieldnames(site.los);
            if(~isempty(losFields))
                for i=1:numel(losFields)
                    IDs=[IDs;site.los.(losFields{i})];
                end
            end
            linkFields=fieldnames(site.link);
            if(~isempty(linkFields))
                for i=1:numel(linkFields)
                    IDs=[IDs;site.link.(linkFields{i})];
                end
            end
            raysFields=fieldnames(site.rays);
            if(~isempty(raysFields))
                for i=1:numel(raysFields)
                    IDs=[IDs;site.rays.(raysFields{i})];
                end
            end
        end

        function IDs=getRayGraphicsIDs(viewer,siteID)



            site=viewer.SiteGraphics.(siteID);
            fields=fieldnames(site.rays);
            numFields=numel(fields);
            IDs={};
            for i=1:numFields
                IDs=[IDs;site.rays.(fields{i})];
            end
        end

        function setGraphic(viewer,siteID,graphicID,graphicName)
            if(~isfield(viewer.SiteGraphics,siteID))
                viewer.SiteGraphics.(siteID)=rfprop.AntennaSite.SiteGraphicsTemplate;
            end
            viewer.SiteGraphics.(siteID).(graphicName)=graphicID;
        end

        function showBuildings(viewer)




            onForcedExit=rfprop.internal.onExit(@()hideBusyMessage(viewer));
            if viewer.Visible
                viewer.showBusyMessage(message('shared_channel:rfprop:LoadingSiteViewer').getString);
            end
            viewer.BuildingsModel=globe.internal.Buildings3DModel(viewer.Buildings,...
            viewer.TerrainSource);

            if viewer.Visible
                buildings3DModel(viewer.Instance.GlobeViewer,viewer.BuildingsModel)
            end


            viewer.BuildingsArray=viewer.BuildingsModel.BuildingsArray;
            viewer.BuildingsTerrainTriangulation=viewer.BuildingsModel.BuildingsTerrainTriangulation;
            viewer.BuildingsLimits=viewer.BuildingsModel.BuildingsLimits;
            viewer.BuildingsCenter=viewer.BuildingsModel.BuildingsCenter;


            if(viewer.Visible)
                viewer.bringToFront;
                viewer.turnClippingOn;
            end


            try
                delete(model.File);
            catch

            end


            if(viewer.Visible)
                viewer.hideBusyMessage;
            end
            cancel(onForcedExit);
        end

        function showBusyMessage(viewer,msg)
            try
                viewer.Visualizer.Controller.showBusyMessage(msg);
            catch e
                throwAsCaller(e)
            end
        end

        function hideBusyMessage(viewer)
            try
                viewer.Visualizer.Controller.hideBusyMessage;
            catch e
                throwAsCaller(e)
            end
        end

        function showProgressDialog(viewer,varargin)
            try

                if isempty(viewer.ProgressDialogHandle)||~isvalid(viewer.ProgressDialogHandle)
                    viewer.ProgressDialogHandle=uiprogressdlg(viewer.FigureHandle);
                end


                dlg=viewer.ProgressDialogHandle;
                for argInd=1:2:numel(varargin)
                    param=varargin{argInd};
                    value=varargin{argInd+1};
                    if~isequal(dlg.(param),value)
                        dlg.(param)=value;
                    end
                end
            catch e
                throwAsCaller(e)
            end
        end

        function hideProgressDialog(viewer)
            try
                delete(viewer.ProgressDialogHandle);
                viewer.ProgressDialogHandle=[];
            catch e
                throwAsCaller(e)
            end
        end

        function ID=getId(viewer,numIds)
            try
                if viewer.IsCartesian
                    ID=viewer.Visualizer.Controller.getID(numIds);
                else
                    ID=viewer.Visualizer.Controller.getId(numIds);
                end
            catch e
                throwAsCaller(e)
            end
        end

        function checkForGraphicsConflict(viewer,newType,id,newColorData)

            try


                if(~viewer.Visible||isempty(fieldnames(viewer.ColorGraphics)))
                    viewer.ColorGraphics.(id).VisualizationType=newType;
                    viewer.ColorGraphics.(id).ColorData=newColorData;
                    return
                end



                colorGraphics=fieldnames(viewer.ColorGraphics);
                numImages=numel(colorGraphics);



                for k=1:numImages
                    currentImage=viewer.ColorGraphics.(colorGraphics{k});
                    currentType=currentImage.VisualizationType;
                    if~isempty(currentType)&&~isequal(currentType,newType)
                        error(message('shared_channel:rfprop:SiteViewerVisualizationConflict',...
                        newType,currentType))
                    end

                    currentData=currentImage.ColorData;
                    if~isempty(currentData)&&~isequal(currentData,newColorData)
                        if iscell(newType)
                            newType=newType{1};
                        end
                        error(message('shared_channel:rfprop:SiteViewerVisualizationColorConflict',newType))
                    end
                end


                viewer.ColorGraphics.(id)=struct(...
                'VisualizationType',{newType},...
                'ColorData',newColorData);
            catch e
                throwAsCaller(e)
            end
        end

        function clearSiteGraphics(viewer,siteID)
            contourID=viewer.SiteGraphics.(siteID).contour;
            if~isempty(contourID)
                viewer.removeColorData(contourID);
            end
            viewer.removeFromLegendEntities(viewer.getRayGraphicsIDs(siteID));
            viewer.removeFromLegendEntities(contourID);
            viewer.SiteGraphics=rmfield(viewer.SiteGraphics,siteID);
        end

        function associateSiteGraphics(viewer,site1ID,site2ID,graphic,id)
            site1Graphics=viewer.SiteGraphics.(site1ID);
            site2Graphics=viewer.SiteGraphics.(site2ID);

            if(isfield(site1Graphics.(graphic),site2ID))
                site1Graphics.(graphic).(site2ID)=[site1Graphics.(graphic).(site2ID);id];
            else
                site1Graphics.(graphic).(site2ID)=cellstr(id);
            end


            if(isfield(site2Graphics.(graphic),site1ID))
                site2Graphics.(graphic).(site1ID)=[site2Graphics.(graphic).(site1ID);id];
            else
                site2Graphics.(graphic).(site1ID)=cellstr(id);
            end
            viewer.SiteGraphics.(site1ID)=site1Graphics;
            viewer.SiteGraphics.(site2ID)=site2Graphics;
        end

        function disassociateSiteGraphics(viewer,site1ID,site2ID,graphic)
            site1Graphics=viewer.SiteGraphics.(site1ID).(graphic);
            site2Graphics=viewer.SiteGraphics.(site2ID).(graphic);
            if(isfield(site1Graphics,site2ID))
                site1Graphics=rmfield(site1Graphics,site2ID);
            end
            if(isfield(site2Graphics,site1ID))
                site2Graphics=rmfield(site2Graphics,site1ID);
            end
            viewer.SiteGraphics.(site1ID).(graphic)=site1Graphics;
            viewer.SiteGraphics.(site2ID).(graphic)=site2Graphics;
        end

        function initializeSiteGraphics(viewer,siteID)
            if(~isfield(viewer.SiteGraphics,siteID))
                viewer.SiteGraphics.(siteID)=rfprop.AntennaSite.SiteGraphicsTemplate;
            end
        end

        function graphic=getGraphic(viewer,siteID,graphicName)
            if isfield(viewer.SiteGraphics,siteID)&&...
                isfield(viewer.SiteGraphics.(siteID),graphicName)
                graphic=viewer.SiteGraphics.(siteID).(graphicName);
            else
                graphic=[];
            end
        end

        function addTempFile(viewer,tmpFile)

            viewer.TempFiles=[viewer.TempFiles,tmpFile];
        end


        function addClosingCallback(viewer)
            f=viewer.FigureHandle;
            f.CloseRequestFcn=@(~,~)delete(viewer);
        end

        function showInspector(viewer)
            viewer.Visualizer.Controller.visualRequest('showInspector',...
            struct('EnableWindowLaunch',false,...
            'Animation',''));
        end

        function FocusGained(viewer)
            siteviewerManager=globe.internal.LifeCycleManager(siteviewer.Appdataname);
            siteviewerManager.makeCurrent(viewer);
            if~viewer.IsCartesian
                globeviewerManager=globe.internal.LifeCycleManager;
                globeviewerManager.makeCurrent(viewer.Visualizer);
            end
        end

        function addFocusGainedCallback(viewer)
            viewer.FocusListener=addlistener(viewer.FigureHandle,...
            'FigureActivated',@(src,evt)FocusGained(viewer));
        end

        function viewerstruct=saveobj(viewer)



            if viewer.IsCartesian
                viewerstruct=struct(...
                'Name',viewer.Name,...
                'ShowOrigin',viewer.ShowOrigin,...
                'ShowEdges',viewer.ShowEdges,...
                'SceneModel',viewer.SceneModel,...
                'Transparency',viewer.Transparency,...
                'CoordinateSystem',viewer.CoordinateSystem);
            else
                viewerstruct=struct(...
                'Name',viewer.Name,...
                'Basemap',viewer.Basemap,...
                'Terrain',viewer.Terrain,...
                'Buildings',viewer.Buildings,...
                'CoordinateSystem',viewer.CoordinateSystem);
            end

        end

        function addToLegendEntities(viewer,entityID)



            if(~isstring(entityID))
                entityID=string(entityID);
            end



            contained=ismember(entityID,viewer.LegendEntities);
            viewer.LegendEntities=[viewer.LegendEntities;entityID(~contained)];
        end

        function removeFromLegendEntities(viewer,entityID)

            if(isempty(viewer.LegendID))
                return
            end
            if(~isstring(entityID))
                entityID=string(entityID);
            end


            [contained,indices]=ismember(entityID,viewer.LegendEntities);
            indicesToRemove=indices(contained);
            viewer.LegendEntities(indicesToRemove)=[];
            if(isempty(viewer.LegendEntities))
                clearLegend(viewer);
            end
        end

        function clearLegend(viewer)
            if~isempty(viewer.LegendID)
                viewer.remove({viewer.LegendID});
            end
            viewer.LegendID='';
            viewer.LegendEntities=strings(0);
        end

        function turnClippingOn(viewer)
            if(~viewer.Clipping)
                viewer.Clipping=true;
                if~viewer.IsCartesian
                    viewer.Visualizer.Controller.forceClipping();
                end
            end
        end

        function[bmaps,selectedIndex]=basemaps(viewer)
            [bmaps,selectedIndex]=globe.internal.GlobeModel.mapConfigurationFromSettings(viewer.Visualizer.Controller.GlobeModel,viewer.Basemap);
        end

    end

    methods(Static,Hidden)

        function migrateTerrainSettings



            s=settings;



            if(s.hasGroup('antenna')&&s.antenna.hasGroup('rfprop')&&s.antenna.rfprop.hasGroup('terrain'))




                terrainNames=setdiff(properties(s.antenna.rfprop.terrain),properties(s.shared.terrain));
                numTerrains=numel(terrainNames);
                for i=1:numTerrains
                    terrainGroup=s.antenna.rfprop.terrain.(terrainNames{i});
                    terrainProperties=properties(terrainGroup);
                    numProperties=numel(terrainProperties);
                    s.shared.terrain.addGroup(terrainNames{i});
                    for j=1:numProperties
                        s.shared.terrain.(terrainNames{i}).addSetting(...
                        terrainProperties{j},...
                        "PersonalValue",terrainGroup.(terrainProperties{j}).PersonalValue);
                    end
                end


                s.antenna.rfprop.removeGroup('terrain');
            end
        end

        function choices=basemapchoices
            choices=globe.internal.GlobeModel.basemapchoices;
        end

        function viewer=current(newCurrent)












            for k=siteviewer.all

                if isprop(k.Visualizer,'GlobeViewer')
                    invalidViewer=~isvalid(k.Visualizer)||...
                    ~isvalid(k.Visualizer.GlobeViewer)||...
                    ~isvalid(k.Visualizer.GlobeViewer.Controller)||...
                    ~isvalid(k.Visualizer.GlobeViewer.Controller.WindowController)||...
                    ~k.Visualizer.GlobeViewer.Controller.WindowController.isValidWindow;
                    if(invalidViewer)
                        close(k);
                    end
                end
            end


            manager=globe.internal.LifeCycleManager(siteviewer.Appdataname);
            oldObjects=manager.AllObjects;


            if isempty(oldObjects)
                viewer=siteviewer.empty;
            else


                if nargin==1&&ischar(newCurrent)
                    if strcmp(manager.CurrentObject.CoordinateSystem,newCurrent)
                        viewer=manager.CurrentObject;
                    else



                        viewer=siteviewer.empty;
                        for k=1:numel(oldObjects)
                            if strcmp(oldObjects(k).CoordinateSystem,newCurrent)
                                viewer=oldObjects(k);
                                makeCurrent(manager,viewer);
                                break
                            end
                        end


                    end
                else


                    viewer=manager.CurrentObject;
                end
            end




            if isempty(viewer)
                if nargin==0

                    viewer=siteviewer("Visible",false);
                elseif ischar(newCurrent)


                    if strcmp(newCurrent,'cartesian')
                        viewer=siteviewer("SceneModel","none","Visible",false);
                    else
                        viewer=siteviewer("Visible",false);
                    end
                end
            end


            if nargin>0&&~ischar(newCurrent)


                makeCurrent(manager,newCurrent);


                viewer=newCurrent;
            end
        end

        function oldViewers=all

            manager=globe.internal.LifeCycleManager(siteviewer.Appdataname);
            oldViewers=manager.AllObjects;
        end

        function viewer=loadobj(viewerstruct)



            name=viewerstruct.Name;
            args={'Name',name};

            if strcmp(viewerstruct.CoordinateSystem,'geographic')

                basemap=viewerstruct.Basemap;
                if ismember(basemap,siteviewer.basemapchoices)
                    args=[args,{'Basemap',basemap}];
                end


                terrainName=viewerstruct.Terrain;
                if ismember(terrainName,terrain.internal.TerrainSource.terrainchoices)
                    args=[args,{'Terrain',terrainName}];
                end


                bldgs=viewerstruct.Buildings;
                if~isempty(bldgs)&&(~isempty(which(bldgs))||exist(bldgs,'file')==2)
                    args=[args,{'Buildings',bldgs}];
                end
            else

                args=[args,{'Transparency',viewerstruct.Transparency,...
                'ShowOrigin',viewerstruct.ShowOrigin,'ShowEdges',viewerstruct.ShowEdges,...
                'SceneModel',viewerstruct.SceneModel}];
            end


            viewer=siteviewer(args{:});
        end


        function terrain=defaultTerrainName
            srf=rfpropSettingsGroup;
            terrain=srf.DefaultTerrain.ActiveValue;
        end

        function srf=rfpropSettingsGroup
            s=settings;
            srf=s.shared.channel.rfprop;
        end

        function[displayElevation,surfaceElevation]=computeSurfaceHeight(lat,lon,clickSurfaceHeight)




            viewer=siteviewer.current;
            coords=rfprop.internal.AntennaSiteCoordinates([lat,lon],0,viewer);
            displayElevation=coords.computeSurfaceHeight('geoid');
            surfaceElevation=coords.SurfaceHeightAboveTerrainReference;





            if abs(clickSurfaceHeight-surfaceElevation)>rfprop.Constants.ShowLocationBuildingSideThreshold
                surfaceElevation=clickSurfaceHeight;


                if viewer.UseTerrain
                    Z=terrain.internal.HeightTransformation.ellipsoidalToOrthometric(clickSurfaceHeight,lat,lon);
                    displayElevation=terrain.internal.TerrainSource.snapMeanSeaLevel(Z);
                else
                    displayElevation=surfaceElevation;
                end

            end
        end

    end

    methods(Access=private)
        function deleteTempFiles(viewer)
            tmpFiles=viewer.TempFiles;
            undeletedTmpFiles={};
            for k=1:numel(tmpFiles)
                tmpFile=tmpFiles{k};
                try
                    delete(tmpFile);
                catch e %#ok<NASGU>
                    if exist(tmpFile,'file')

                        undeletedTmpFiles{end+1}=tmpFile;
                    end
                end
            end
            viewer.TempFiles=undeletedTmpFiles;
        end
    end

    methods(Access=protected)
        function propgrp=getPropertyGroups(viewer)
            if all([viewer.IsCartesian])
                proplist={'Name','Position','CoordinateSystem','SceneModel','Transparency','ShowOrigin','ShowEdges'};
                propgrp=matlab.mixin.util.PropertyGroup(proplist);
            elseif all(~[viewer.IsCartesian])
                proplist={'Name','Position','CoordinateSystem','Basemap','Terrain','Buildings'};
                propgrp=matlab.mixin.util.PropertyGroup(proplist);
            else



                proplist={'Name','Position','CoordinateSystem','Basemap','Terrain','Buildings','SceneModel','Transparency','ShowOrigin','ShowEdges'};
                propgrp=matlab.mixin.util.PropertyGroup(proplist);
            end
        end
    end
end

function name=validateName(name)
    validateattributes(name,{'char','string'},{'scalartext'},'siteviewer','Name');
    name=char(name);
end

function terrainName=validateTerrain(terrainName)
    terrainName=validatestring(terrainName,terrain.internal.TerrainSource.terrainchoices,'siteviewer','Terrain');
end

function position=validatePosition(position)
    validateattributes(position,{'double'},{'real','finite','nonsparse','size',[1,4]},'siteviewer','Position');
end

function terrain=defaultTerrainName
    srf=rfpropSettingsGroup;
    terrain=srf.DefaultTerrain.ActiveValue;
end

function sst=sharedTerrainSettingsGroup
    siteviewer.migrateTerrainSettings;
    s=settings;
    sst=s.shared.terrain;
end


function srf=rfpropSettingsGroup
    s=settings;
    srf=s.shared.channel.rfprop;
end

function sg=globeSettingsGroup
    s=settings;
    sg=s.shared.globe;
end

function ex=notSupportedError








    stack=dbstack(1);
    topfile=stack(end).name;
    if contains(topfile,'.')
        topfile=extractBefore(topfile,'.');
    end
    productName=connector.internal.getProductNameByClientType;

    if isempty(productName)
        ex=MException(message('MATLAB:connector:Platform:FunctionNotSupported',topfile));
    else
        ex=MException(message('MATLAB:connector:Platform:FunctionNotSupportedForProduct',topfile,productName));
    end

    if strcmp(productName,'MATLAB Online')

        exTripwire=MException(message('MATLAB:connector:Platform:FunctionTripwireSuffix'));
        ex=MException(ex.identifier,[ex.message,' ',exTripwire.message]);
    end
end

function mustBeFileOrTriangulation(model)
    if~ischar(model)&&~isscalar(model)&&~isa(model,'triangulation')
        error(message("shared_channel:rfprop:SceneModelMustBeSTLOrTriangulation"));
    end
    if~isempty(model)&&~strcmp(model,'none')
        if isstring(model)||ischar(model)
            if isempty(which(model))&&exist(model,'file')~=2
                error(message("shared_channel:rfprop:UnableToFindSceneModelFile",model));
            end
            [~,~,ext]=fileparts(model);
            if~strcmp(ext,'.stl')
                error(message("shared_channel:rfprop:SceneModelMustBeSTLOrTriangulation"));
            end
        elseif~isa(model,"triangulation")
            error(message("shared_channel:rfprop:SceneModelMustBeSTLOrTriangulation"));
        end
    end
end
