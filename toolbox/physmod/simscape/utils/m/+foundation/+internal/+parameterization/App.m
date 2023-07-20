classdef App




    methods(Access=private)
        function obj=App()
        end
    end

    methods(Static)
        function showInstance(BlockPath)
            persistent map;

            if isempty(map)
                map=containers.Map('KeyType','double','ValueType','any');
            end
            blockHandle=get_param(BlockPath,'handle');



            if~map.isKey(blockHandle)


                [model,view]=createModelView(blockHandle);
                control=foundation.internal.parameterization.SelectorControl(model,view);
                view.Controller=control;
                map(blockHandle)={control,blockHandle};

            else

                control=map(blockHandle);
                control=control{1};

                if control.View.Visible


                    close_system(blockHandle)
                    control.View.bringToFront;

                else

                    [model,view]=createModelView(blockHandle);
                    control=foundation.internal.parameterization.SelectorControl(model,view);
                    view.Controller=control;
                    map(blockHandle)={control,blockHandle};
                end
            end
        end
    end
end


function[model,view]=createModelView(blockHandle)

    model=foundation.internal.parameterization.SelectorModel(blockHandle);
    view=foundation.internal.parameterization.TableView;


    close_system(blockHandle)
end