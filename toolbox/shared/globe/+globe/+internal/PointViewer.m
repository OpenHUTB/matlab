classdef(Hidden)PointViewer<globe.internal.VisualizationViewer



















    methods
        function viewer=PointViewer(globeController)









            if nargin<1
                globeController=globe.internal.GlobeController;
            end

            viewer=viewer@globe.internal.VisualizationViewer(globeController);
            primitiveController=globe.internal.PrimitiveController(globeController);
            viewer.PrimitiveController=primitiveController;
        end


        function[IDs,plotDescriptors]=point(viewer,positions,varargin)
            [IDs,plotDescriptors]=viewer.buildPlotDescriptors(positions,varargin{:});
            viewer.PrimitiveController.plot('point',plotDescriptors);
        end

        function[IDs,plotDescriptors]=buildPlotDescriptors(viewer,locations,varargin)
            primitiveController=viewer.PrimitiveController;

            if(~iscell(locations))
                locations=num2cell(locations,2);
            end

            p=inputParser;
            p.addParameter('Animation','fly');
            p.addParameter('EnableWindowLaunch',true);
            p.addParameter('Color',{[1,1,1]});
            p.addParameter('Name',{'Point'});
            p.addParameter('Size',8);
            p.addParameter('Description','');
            p.addParameter('ShowTooltip',false);
            p.addParameter('LinkedGraphic','');
            p.addParameter('OutlineWidth',0);
            p.addParameter('DisplayDistance',Inf);
            p.addParameter('WaitForResponse',true);
            p.addParameter('ID',primitiveController.getId(numel(locations)));

            try
                p.parse(varargin{:});
            catch e
                throwAsCaller(e);
            end
            animation=p.Results.Animation;
            enableWindowLaunch=p.Results.EnableWindowLaunch;
            color=p.Results.Color;
            name=p.Results.Name;
            size=p.Results.Size;
            description=p.Results.Description;
            showTooltip=p.Results.ShowTooltip;
            linkedGraphic=p.Results.LinkedGraphic;
            IDs=p.Results.ID;
            waitForResponse=p.Results.WaitForResponse;
            outlineWidth=p.Results.OutlineWidth;
            displayDistance=p.Results.DisplayDistance;
            if(~iscell(IDs))
                IDs=num2cell(IDs);
            end
            if(~iscell(color))
                color={color};
            end
            if(~iscell(name))
                name=cellstr(name);
            end
            if(~iscell(size))
                size={size};
            end
            if(~iscell(description))
                description=cellstr(description);
            end
            plotDescriptors=struct(...
            'IDs',{IDs},...
            'Location',{locations},...
            'Color',{color},...
            'Name',{name},...
            'Size',{size},...
            'Description',{description},...
            'Animation',animation,...
            'ShowTooltip',showTooltip,...
            'WaitForResponse',waitForResponse,...
            'LinkedGraphic',linkedGraphic,...
            'OutlineWidth',outlineWidth,...
            'DisplayDistance',displayDistance,...
            'EnableWindowLaunch',enableWindowLaunch);
        end


        function delete(viewer)
            if~isempty(viewer)&&~isempty(viewer.PrimitiveController)...
                &&isvalid(viewer.PrimitiveController)
                delete(viewer.PrimitiveController)
            end
        end
    end
end