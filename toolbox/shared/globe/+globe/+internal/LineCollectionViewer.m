classdef(Hidden)LineCollectionViewer<globe.internal.VisualizationCollectionViewer...
    &globe.internal.VisualizationViewer

    properties
        Width=3
        HistoryDepth(1,1)double=0
        Dashed=false
        DashLength=16
    end

    properties(Constant)
        LineDefaults=struct(...
        'Width',3,...
        'HistoryDepth',0,...
        'Dashed',false,...
        'DashLength',16)
    end

    methods
        function viewer=LineCollectionViewer(globeController,varargin)

            if nargin<1
                globeController=globe.internal.GlobeController;
            end
            viewer=viewer@globe.internal.VisualizationViewer(globeController);

            primitiveController=globe.internal.PrimitiveController(globeController);
            viewer.PrimitiveController=primitiveController;

            globe.internal.setObjectNameValuePairs(viewer,varargin)
        end


        function[ID,plotDescriptors]=lineCollection(viewer,locations,varargin)
            [ID,plotDescriptors]=viewer.buildPlotDescriptors(locations,varargin{:});
            viewer.PrimitiveController.plot('lineCollection',plotDescriptors);
        end

        function[ID,plotDescriptors]=buildPlotDescriptors(viewer,locations,varargin)
            globe.internal.setObjectNameValuePairs(viewer,varargin);

            animation=viewer.Animation;
            enableWindowLaunch=viewer.EnableWindowLaunch;
            color=viewer.Color;
            width=viewer.Width;
            ID=viewer.ID;
            waitForResponse=viewer.WaitForResponse;
            historyDepth=viewer.HistoryDepth;
            indices=viewer.Indices;
            dashed=viewer.Dashed;
            dashLength=viewer.DashLength;


            if(historyDepth==0)
                historyDepth=max(cellfun(@(b)size(b,1),locations));
            end


            if(isempty(ID))
                ID=viewer.PrimitiveController.getId(1);
            elseif(~iscell(ID))
                if(isnumeric(ID))
                    ID=num2cell(ID);
                else
                    ID=cellstr(ID);
                end
            end
            if(~iscell(color))
                color={color};
            end
            if(~iscell(width))
                width=num2cell(width);
            end
            try
                plotDescriptors=struct(...
                'ID',ID,...
                'Locations',{locations},...
                'Color',{color},...
                'HistoryDepth',historyDepth,...
                'Width',{width},...
                'Animation',animation,...
                'WaitForResponse',waitForResponse,...
                'Indices',indices,...
                'Dashed',dashed,...
                'DashLength',dashLength,...
                'EnableWindowLaunch',enableWindowLaunch);
            catch e
                reset(viewer);
                rethrow(e);
            end
            reset(viewer);
        end

        function defaultProperties=getDefaultProperties(viewer)
            defaultProperties=getDefaultProperties@globe.internal.VisualizationCollectionViewer(viewer);
            defaultProperties=[defaultProperties,{...
            'Width',viewer.LineDefaults.Width,...
            'HistoryDepth',viewer.LineDefaults.HistoryDepth,...
            'Dashed',viewer.LineDefaults.Dashed,...
            'DashLength',viewer.LineDefaults.DashLength}];
        end

        function delete(viewer)
            if~isempty(viewer)&&~isempty(viewer.PrimitiveController)...
                &&isvalid(viewer.PrimitiveController)
                delete(viewer.PrimitiveController)
            end
        end
    end
end