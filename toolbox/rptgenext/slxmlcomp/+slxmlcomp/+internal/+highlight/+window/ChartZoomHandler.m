classdef ChartZoomHandler<slxmlcomp.internal.highlight.window.SLEditorZoomHandler




    properties(Access=private)
        ChartTypes=["SFBlock","junction","state","transition"]
    end

    methods(Access=public)

        function canHandle=canHandle(obj,location)
            canHandle=any(obj.ChartTypes==location.Type);
        end

        function zoomTo(obj,location)
            stateflowInfo=slxmlcomp.internal.stateflow.stateflowPathToStruct(char(location.Location));
            chart=slxmlcomp.internal.stateflow.chart.get(stateflowInfo.Block);

            if isempty(chart)
                chart=slxmlcomp.internal.stateflow.chart.get(stateflowInfo.Block,'Stateflow.StateTransitionTableChart');
                if isempty(chart)
                    slxmlcomp.internal.error('reverseannotation:ChartNotFound',stateflowInfo.Block);
                end
            end

            handle=[];
            if~strcmp(location.Type,'chart')

                handle=sfprivate('ssIdToHandle',location.Location);
            end

            obj.openChartFitToView(chart,handle);
        end

    end

    methods(Access=private)

        function openChartFitToView(obj,chart,handle)
            if~isempty(handle)



                if isprop(handle,'Subviewer')&&~isempty(handle.Subviewer)
                    viewer=handle.Subviewer;
                else
                    viewer=chart;
                end


                sf('Select',chart.Id,[]);

                if isa(viewer,'Stateflow.StateTransitionTableChart')||isa(viewer,'Stateflow.State')
                    sf('ViewContent',viewer.Id);
                else
                    if~viewer.visible
                        sf('Open',viewer.Id);
                    end
                end

            else






                sf('Select',chart.Id,[]);

                if isa(chart,'Stateflow.StateTransitionTableChart')
                    sf('ViewContent',chart.Id);
                else
                    sf('Open',chart.Id);
                end
                viewer=chart;
            end



            if(~isempty(handle))
                try
                    handle.fitToView;
                catch
                    obj.pFitToView(viewer)
                end
            end

        end

        function pFitToView(~,viewer)


            editors=GLUE2.Util.findAllEditors(viewer.path);
            if~isempty(editors)
                editor=editors(1);
                editor.getCanvas.zoomToSceneRect;
                return
            end
        end
    end
end
