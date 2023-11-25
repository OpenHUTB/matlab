classdef(Hidden)PointCollectionViewer<globe.internal.VisualizationCollectionViewer...
    &globe.internal.VisualizationViewer


    properties
Locations
        PixelSize(1,1)double=4
        Transparency(1,1)double=1
        OutlineColor=[]
        OutlineWidth(1,1)double=1
        OutlineTransparency(1,1)double=1
    end

    properties(Constant)
        PointDefaults=struct(...
        'PixelSize',4,...
        'Transparency',1,...
        'OutlineColor',[],...
        'OutlineWidth',1,...
        'OutlineTransparency',1)
    end


    methods
        function viewer=PointCollectionViewer(globeController,varargin)

            if nargin<1
                globeController=globe.internal.GlobeController;
            end
            viewer=viewer@globe.internal.VisualizationViewer(globeController);


            primitiveController=globe.internal.PrimitiveController(globeController);
            viewer.PrimitiveController=primitiveController;

            globe.internal.setObjectNameValuePairs(viewer,varargin)
        end


        function[IDs,plotDescriptors]=pointCollection(viewer,locations,varargin)
            [IDs,plotDescriptors]=buildPlotDescriptors(viewer,locations,varargin{:});
            plot(viewer.PrimitiveController,'pointCollection',plotDescriptors);
        end


        function[id,plotDescriptors]=buildPlotDescriptors(viewer,locations,varargin)
            globe.internal.setObjectNameValuePairs(viewer,varargin)

            animation=char(viewer.Animation);
            enableWindowLaunch=viewer.EnableWindowLaunch;
            color=viewer.Color;
            transparency=viewer.Transparency;
            outlineColor=viewer.OutlineColor;
            outlineWidth=viewer.OutlineWidth;
            outlineTransparency=viewer.OutlineTransparency;
            pixelSize=viewer.PixelSize;
            id=viewer.ID;
            indices=viewer.Indices;
            waitForResponse=viewer.WaitForResponse;

            if(~iscell(locations))
                locations=num2cell(locations,2);
            end

            if isempty(id)
                id=viewer.PrimitiveController.getId(1);
            elseif(~iscell(id))
                if isnumeric(id)
                    id=num2cell(id);
                else
                    id=cellstr(id);
                end
            end

            if(~iscell(color))
                color={color};
            end

            if isempty(outlineColor)
                outlineColor=color;
            elseif~iscell(outlineColor)
                outlineColor={outlineColor};
            end

            if(~iscell(outlineWidth))
                outlineWidth=num2cell(outlineWidth);
            end

            if(~iscell(pixelSize))
                pixelSize=num2cell(pixelSize);
            end



            if(~iscell(indices)&&isscalar(indices))
                indices={{indices}};
            end

            try
                plotDescriptors=struct(...
                'EnableWindowLaunch',enableWindowLaunch,...
                'Animation',animation,...
                'Locations',{locations},...
                'Size',pixelSize,...
                'Color',color,...
                'Transparency',transparency,...
                'OutlineColor',outlineColor,...
                'OutlineWidth',outlineWidth,...
                'OutlineTransparency',outlineTransparency,...
                'ID',id,...
                'Indices',indices,...
                'WaitForResponse',waitForResponse);
            catch e
                reset(viewer);
                rethrow(e)
            end
            reset(viewer);
        end

        function defaultProperties=getDefaultProperties(viewer)
            defaultProperties=getDefaultProperties@globe.internal.VisualizationCollectionViewer(viewer);
            pointDefaults=viewer.PointDefaults;
            defaultProperties=[defaultProperties,{...
            'PixelSize',pointDefaults.PixelSize,...
            'Transparency',pointDefaults.Transparency,...
            'OutlineColor',pointDefaults.OutlineColor,...
            'OutlineWidth',pointDefaults.OutlineWidth,...
            'OutlineTransparency',pointDefaults.OutlineTransparency}];
        end

        function delete(viewer)
            if~isempty(viewer)&&~isempty(viewer.PrimitiveController)...
                &&isvalid(viewer.PrimitiveController)
                delete(viewer.PrimitiveController)
            end
        end
    end
end
