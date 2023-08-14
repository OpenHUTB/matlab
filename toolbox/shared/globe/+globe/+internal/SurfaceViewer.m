classdef(Hidden)SurfaceViewer<globe.internal.VisualizationViewer



















    properties(Constant,Hidden)
        ProjectionMargin=0.0001
    end


    methods
        function viewer=SurfaceViewer(globeController)

            if nargin<1
                globeController=globe.internal.GlobeController;
            end

            viewer=viewer@globe.internal.VisualizationViewer(globeController);
            primitiveController=globe.internal.PrimitiveController(globeController);
            viewer.PrimitiveController=primitiveController;
        end


        function[IDs,plotDescriptors]=surface(viewer,location,xyzCoordinates,indices,colors,varargin)
            [IDs,plotDescriptors]=viewer.buildPlotDescriptors(location,xyzCoordinates,indices,colors,varargin{:});
            viewer.PrimitiveController.plot('surface',plotDescriptors);
        end

        function[ID,surfaceData]=buildPlotDescriptors(viewer,location,xyzCoordinates,indices,colors,varargin)
            controller=viewer.PrimitiveController;
            p=inputParser;
            p.addParameter('Animation','fly');
            p.addParameter('EnableWindowLaunch',true);
            p.addParameter('ID',controller.getId(1));
            p.addParameter('Transparency',0.4);
            p.addParameter('ZoomDistance',100);
            p.addParameter('Rotation',[0,0,0]);
            p.addParameter('WaitForResponse',true);
            try
                p.parse(varargin{:});
            catch e
                throwAsCaller(e);
            end
            update=false;



            if(isempty(xyzCoordinates)&&isempty(indices)&&isempty(colors)&&~ismember('ID',p.UsingDefaults))
                update=true;
                xyzCoordinates=zeros(1,3);
            else


                xyzCoordinates(abs(xyzCoordinates)<viewer.ProjectionMargin)=viewer.ProjectionMargin;
            end
            animation=p.Results.Animation;
            enableWindowLaunch=p.Results.EnableWindowLaunch;
            ID=p.Results.ID;
            transparency=p.Results.Transparency;
            zoomDistance=p.Results.ZoomDistance;




            if(ismember('Rotation',p.UsingDefaults)&&update)
                rotation=[];
            else


                rotation=p.Results.Rotation;
                if numel(rotation)==1
                    rotation(2:3)=0;
                elseif numel(rotation)==2
                    rotation(3)=0;
                end
            end
            waitForResponse=p.Results.WaitForResponse;
            surfaceData=struct("ID",ID,...
            'EnableWindowLaunch',enableWindowLaunch,...
            'Animation',animation,...
            'Location',{location},...
            'Xcoordinates',xyzCoordinates(:,1),...
            'Ycoordinates',xyzCoordinates(:,2),...
            'Zcoordinates',xyzCoordinates(:,3),...
            'CData',colors,...
            'ZoomDistance',zoomDistance,...
            'Transparency',transparency,...
            'Rotation',rotation,...
            'WaitForResponse',waitForResponse,...
            'Update',update,...
            'TriangulationIndices',indices);
        end

        function delete(viewer)
            if~isempty(viewer)&&~isempty(viewer.PrimitiveController)...
                &&isvalid(viewer.PrimitiveController)
                delete(viewer.PrimitiveController)
            end
        end
    end
end