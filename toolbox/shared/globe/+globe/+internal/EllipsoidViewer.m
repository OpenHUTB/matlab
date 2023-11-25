classdef(Hidden)EllipsoidViewer<globe.internal.VisualizationViewer

    methods
        function viewer=EllipsoidViewer(globeController)

            if nargin<1
                globeController=globe.internal.GlobeController;
            end

            viewer=viewer@globe.internal.VisualizationViewer(globeController);
            primitiveController=globe.internal.PrimitiveController(globeController);
            viewer.PrimitiveController=primitiveController;
        end


        function[IDs,plotDescriptors]=ellipsoid(viewer,location,radii,varargin)
            [IDs,plotDescriptors]=viewer.buildPlotDescriptors(location,radii,varargin{:});
            viewer.PrimitiveController.plot('ellipsoid',plotDescriptors);
        end

        function[ID,ellipsoidData]=buildPlotDescriptors(viewer,location,radii,varargin)
            controller=viewer.PrimitiveController;
            p=inputParser;
            p.addParameter('Animation','fly');
            p.addParameter('EnableWindowLaunch',true);
            p.addParameter('ID',controller.getId(1));
            p.addParameter('Transparency',0.4);
            p.addParameter('Color',{[1,1,1]});
            p.addParameter('Rotation',[0,0,0]);
            p.addParameter('ZoomDistance',50);
            p.addParameter('WaitForResponse',true);
            try
                p.parse(varargin{:});
            catch e
                throwAsCaller(e);
            end
            animation=p.Results.Animation;
            enableWindowLaunch=p.Results.EnableWindowLaunch;
            ID=p.Results.ID;
            transparency=p.Results.Transparency;
            rotation=p.Results.Rotation;
            waitForResponse=p.Results.WaitForResponse;
            color=p.Results.Color;
            zoomDistance=p.Results.ZoomDistance;
            if(~iscell(color))
                color={color};
            end
            ellipsoidData=struct("ID",ID,...
            'RadiusX',radii(1),...
            'RadiusY',radii(2),...
            'RadiusZ',radii(3),...
            'Color',color,...
            'ZoomDistance',zoomDistance,...
            'Location',{location},...
            'Transparency',transparency,...
            'Rotation',rotation,...
            'EnableWindowLaunch',enableWindowLaunch,...
            'Animation',animation,...
            'WaitForResponse',waitForResponse);
        end

        function delete(viewer)
            if~isempty(viewer)&&~isempty(viewer.PrimitiveController)...
                &&isvalid(viewer.PrimitiveController)
                delete(viewer.PrimitiveController)
            end
        end
    end
end