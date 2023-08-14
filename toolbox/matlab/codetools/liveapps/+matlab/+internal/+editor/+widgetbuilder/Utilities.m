classdef Utilities


    methods(Static)





















        function parse(data,handler)
            import matlab.internal.editor.widgetbuilder.Utilities;

            if iscell(data)
                dim=size(data);
                for i=1:dim(2)
                    for j=1:dim(1)
                        elem=data{j,i};
                        Utilities.parse(elem,handler);
                    end
                end
            elseif isstruct(data)
                canHandleOwnChildren=false;
                if isfield(data.widget,'type')
                    handlerKey=data.widget.type;
                    canHandleOwnChildren=handler(data,handlerKey);
                end


                if~canHandleOwnChildren&&isfield(data.widget,'children')
                    Utilities.parse(data.widget.children,handler);
                end
            end
        end
    end
end