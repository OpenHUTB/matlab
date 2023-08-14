classdef App




    methods(Access=private)
        function obj=App()
        end
    end

    methods(Static)
        function showInstance(modelName)
            persistent map;

            if isempty(map)
                map=containers.Map;
            end

            if~exist('modelName','var')
                modelName=bdroot;
            end

            if isempty(modelName)...
                ||exist(modelName)~=4...
                ||~bdIsLoaded(modelName)...
                ||strcmp('library',get_param(modelName,'BlockDiagramType'))%#ok<EXIST>
                error(message('physmod:ee:loadflow:LoadOrOpenSimulinkModel'));
            end


            if~map.isKey(modelName)

                model=ee.internal.loadflow.Model(modelName);
                view=ee.internal.loadflow.View();
                control=ee.internal.loadflow.Control(model,view);
                map(modelName)=control;
            else

                control=map.values({modelName});
                control=control{1};
                if isvalid(control)...
                    &&isvalid(control.View)...
                    &&~strcmp('TERMINATED',control.View.State)


                    control.View.bringToFront();
                else

                    model=ee.internal.loadflow.Model(modelName);
                    view=ee.internal.loadflow.View();
                    control=ee.internal.loadflow.Control(model,view);
                    map(modelName)=control;
                end
            end
        end
    end
end