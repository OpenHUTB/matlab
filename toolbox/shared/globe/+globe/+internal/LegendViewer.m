classdef(Hidden)LegendViewer<globe.internal.VisualizationViewer




















    properties(Access=?globe.internal.GlobeViewer)
        InfoboxLegend=false
    end
    methods
        function viewer=LegendViewer(globeController)

            if nargin<1
                globeController=globe.internal.GlobeController;
            end

            viewer=viewer@globe.internal.VisualizationViewer(globeController);
            primitiveController=globe.internal.PrimitiveController(globeController);
            viewer.PrimitiveController=primitiveController;
        end


        function[IDs,plotDescriptors]=legend(viewer,title,colors,values,varargin)
            [IDs,plotDescriptors]=viewer.buildPlotDescriptors(title,colors,values,varargin{:});
            if(viewer.InfoboxLegend)
                viewer.PrimitiveController.plot('infoboxColorLegend',plotDescriptors);
            else
                viewer.PrimitiveController.plot('colorLegend',plotDescriptors);
            end
        end

        function[ID,legendData]=buildPlotDescriptors(viewer,title,colors,values,varargin)
            p=inputParser;
            p.addParameter('ID','colorLegend_MW');
            p.addParameter('InfoboxLegend',false);
            p.addParameter('ParentGraphicID',[]);
            p.addParameter('WaitForResponse',true);
            try
                p.parse(varargin{:});
            catch e
                throwAsCaller(e);
            end
            ID=p.Results.ID;
            waitForResponse=p.Results.WaitForResponse;
            parentGraphicID=p.Results.ParentGraphicID;
            viewer.InfoboxLegend=p.Results.InfoboxLegend;
            legendData=struct(...
            "LegendTitle",title,...
            "LegendColors",colors,...
            "LegendColorValues",values,...
            "ID",ID,...
            'EnableWindowLaunch',false,...
            'WaitForResponse',waitForResponse,...
            'Animation','');


            if(~isempty(parentGraphicID))
                legendData.ParentGraphicID=parentGraphicID;
            end
        end

        function delete(viewer)
            if~isempty(viewer)&&~isempty(viewer.PrimitiveController)...
                &&isvalid(viewer.PrimitiveController)
                delete(viewer.PrimitiveController)
            end
        end
    end
end