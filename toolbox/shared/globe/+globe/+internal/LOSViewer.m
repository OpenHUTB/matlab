classdef(Hidden)LOSViewer<globe.internal.VisualizationViewer


    properties(Access=public,Hidden)
        CompositeController globe.internal.CompositeController=globe.internal.CompositeController.empty
    end

    methods
        function viewer=LOSViewer(globeController)

            if nargin<1
                globeController=globe.internal.GlobeController;
            end

            viewer=viewer@globe.internal.VisualizationViewer(globeController);
            CompositeController=globe.internal.CompositeController(globeController);
            viewer.CompositeController=CompositeController;
        end


        function nestedComposite=los(viewer,lineLocations,pointLocations,lineViewer,pointViewer,lineNVs,pointNVs,showObstruction,animation)


            numLOS=numel(lineLocations);
            composites=cell(numLOS,1);

            for i=1:numLOS
                currentComposite=globe.internal.CompositeModel;

                linePositions=lineLocations{i};
                currentLineNVs=lineNVs{i};
                [~,lineData]=lineViewer.buildPlotDescriptors(linePositions,currentLineNVs{:});
                currentComposite.addGraphic("line",lineData);


                if(showObstruction(i))
                    pointPositions=pointLocations{i};
                    currentPointNVs=pointNVs{i};
                    [~,pointData]=pointViewer.buildPlotDescriptors(pointPositions,currentPointNVs{:});
                    currentComposite.addGraphic("point",pointData);
                end
                composites{i}=currentComposite;
            end

            nestedComposite=globe.internal.CompositeModel;
            for i=1:numel(composites)
                nestedComposite.addGraphic("composite",composites{i}.buildPlotDescriptors);
            end
            compositeArgs=nestedComposite.buildPlotDescriptors;
            compositeArgs.Animation=animation;
            viewer.CompositeController.composite(compositeArgs);
        end

        function[IDs,data]=buildPlotDescriptors(viewer,locations,varargin)

        end


        function delete(viewer)
            if~isempty(viewer)&&~isempty(viewer.CompositeController)...
                &&isvalid(viewer.CompositeController)
                delete(viewer.CompositeController)
            end
        end
    end
end
