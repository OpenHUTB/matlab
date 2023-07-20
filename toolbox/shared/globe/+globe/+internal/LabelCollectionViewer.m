classdef(Hidden)LabelCollectionViewer<globe.internal.VisualizationCollectionViewer...
    &globe.internal.VisualizationViewer



    properties
Locations
Labels
        Scale double=1
    end

    properties(Constant)
        LabelDefaults=struct('Scale',1);
    end

    methods
        function viewer=LabelCollectionViewer(globeController,varargin)













            if nargin<1
                globeController=globe.internal.GlobeController;
            end
            viewer=viewer@globe.internal.VisualizationViewer(globeController);


            primitiveController=globe.internal.PrimitiveController(globeController);
            viewer.PrimitiveController=primitiveController;

            globe.internal.setObjectNameValuePairs(viewer,varargin)
        end


        function[IDs,plotDescriptors]=labelCollection(viewer,locations,labels,varargin)
            [IDs,plotDescriptors]=buildPlotDescriptors(viewer,locations,labels,varargin{:});
            plot(viewer.PrimitiveController,'labelCollection',plotDescriptors);
        end


        function[id,plotDescriptors]=buildPlotDescriptors(viewer,locations,labels,varargin)
            globe.internal.setObjectNameValuePairs(viewer,varargin)

            animation=char(viewer.Animation);
            enableWindowLaunch=viewer.EnableWindowLaunch;
            color=viewer.Color;
            scale=viewer.Scale;
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
            if(~iscell(locations))
                locations={locations};
            end
            if(~iscell(labels))


                if(ischar(labels)||isscalar(labels))
                    labels={{labels}};
                else
                    labels={labels};
                end
            end


            if(~iscell(indices)&&isscalar(indices))
                indices={{indices}};
            end
            try
                plotDescriptors=struct(...
                'EnableWindowLaunch',enableWindowLaunch,...
                'Animation',animation,...
                'Locations',{locations},...
                'Color',color,...
                'Scale',scale,...
                'Labels',labels,...
                'ID',id,...
                'Indices',indices,...
                'WaitForResponse',waitForResponse);
            catch e
                reset(viewer);
                rethrow(e);
            end
            reset(viewer);
        end

        function defaultProperties=getDefaultProperties(viewer)
            defaultProperties=getDefaultProperties@globe.internal.VisualizationCollectionViewer(viewer);
            defaultProperties=[defaultProperties...
            ,{'Scale',viewer.LabelDefaults.Scale}];
        end

        function delete(viewer)
            if~isempty(viewer)&&~isempty(viewer.PrimitiveController)...
                &&isvalid(viewer.PrimitiveController)
                delete(viewer.PrimitiveController)
            end
        end
    end
end
