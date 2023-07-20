classdef(Hidden)LineViewer<globe.internal.VisualizationViewer




















    methods
        function viewer=LineViewer(globeController)

            if nargin<1
                globeController=globe.internal.GlobeController;
            end

            viewer=viewer@globe.internal.VisualizationViewer(globeController);
            primitiveController=globe.internal.PrimitiveController(globeController);
            viewer.PrimitiveController=primitiveController;
        end


        function[IDs,plotDescriptors]=line(viewer,locations,varargin)
            [IDs,plotDescriptors]=viewer.buildPlotDescriptors(locations,varargin{:});
            viewer.PrimitiveController.plot('line',plotDescriptors);
        end

        function[IDs,plotDescriptors]=buildPlotDescriptors(viewer,locations,varargin)
            primitiveController=viewer.PrimitiveController;

            p=inputParser;
            p.addParameter('Animation','');
            p.addParameter('EnableWindowLaunch',true);
            p.addParameter('Color',{[1,1,1]});
            p.addParameter('Name',{'Line'});
            p.addParameter('Width',3);
            p.addParameter('FollowEllipsoid',false);
            p.addParameter('ShowArrow',false);
            p.addParameter('Description','');
            p.addParameter('LinkedGraphics','');
            p.addParameter('WaitForResponse',true);
            p.addParameter('Dashed',false);
            p.addParameter('DashLength',4);
            p.addParameter('ID',primitiveController.getId(size(locations,1)-1));
            try
                p.parse(varargin{:});
            catch e
                throwAsCaller(e);
            end
            animation=p.Results.Animation;
            enableWindowLaunch=p.Results.EnableWindowLaunch;
            color=p.Results.Color;
            name=p.Results.Name;
            width=p.Results.Width;
            followEllipsoid=p.Results.FollowEllipsoid;
            description=p.Results.Description;
            showArrow=p.Results.ShowArrow;
            IDs=p.Results.ID;
            linkedGraphics=p.Results.LinkedGraphics;
            waitForResponse=p.Results.WaitForResponse;
            dashed=p.Results.Dashed;
            dashLength=p.Results.DashLength;
            if(~iscell(IDs))
                if(isnumeric(IDs))
                    IDs=num2cell(IDs);
                else
                    IDs=cellstr(IDs);
                end
            end
            if(~iscell(color))
                color={color};
            end
            if(~iscell(showArrow))
                showArrow=num2cell(showArrow);
            end
            if(~iscell(name))
                name=cellstr(name);
            end
            if(~iscell(description))
                description=cellstr(description);
            end
            if(~iscell(followEllipsoid))
                followEllipsoid=num2cell(followEllipsoid);
            end
            if(~iscell(width))
                width=num2cell(width);
            end
            plotDescriptors=struct(...
            'IDs',{IDs},...
            'Locations',{locations},...
            'Color',{color},...
            'Name',{name},...
            'Width',{width},...
            'ShowArrow',{showArrow},...
            'Description',{description},...
            'FollowEllipsoid',{followEllipsoid},...
            'Animation',animation,...
            'LinkedGraphics',linkedGraphics,...
            'Dashed',dashed,...
            'DashLength',dashLength,...
            'WaitForResponse',waitForResponse,...
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