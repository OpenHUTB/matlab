classdef(Hidden)ImageViewer<globe.internal.VisualizationViewer




















    methods
        function viewer=ImageViewer(globeController)

            if nargin<1
                globeController=globe.internal.GlobeController;
            end

            viewer=viewer@globe.internal.VisualizationViewer(globeController);
            primitiveController=globe.internal.PrimitiveController(globeController);
            viewer.PrimitiveController=primitiveController;
        end


        function[IDs,plotDescriptors]=image(viewer,fileLoc,cornerLocations,varargin)
            [IDs,plotDescriptors]=viewer.buildPlotDescriptors(fileLoc,cornerLocations,varargin{:});
            viewer.PrimitiveController.plot('image',plotDescriptors);
        end

        function[IDs,plotDescriptors]=buildPlotDescriptors(viewer,fileLoc,cornerLocations,varargin)
            primitiveController=viewer.PrimitiveController;

            p=inputParser;
            p.addParameter('Animation','');
            p.addParameter('EnableWindowLaunch',true);
            p.addParameter('Transparency',0.4);
            p.addParameter('WaitForResponse',true);
            p.addParameter('ID',primitiveController.getId(1));
            try
                p.parse(varargin{:});
            catch e
                throwAsCaller(e);
            end
            animation=p.Results.Animation;
            enableWindowLaunch=p.Results.EnableWindowLaunch;
            transparency=p.Results.Transparency;
            waitForResponse=p.Results.WaitForResponse;
            IDs=p.Results.ID;
            imageURL={globe.internal.ConnectorServiceProvider.getResourceURL(fileLoc,['image',num2str(IDs{1})])};
            plotDescriptors=struct(...
            'ID',IDs{1},...
            'CornerLocations',{cornerLocations},...
            'ImageURL',imageURL,...
            'Transparency',transparency,...
            'Animation',animation,...
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