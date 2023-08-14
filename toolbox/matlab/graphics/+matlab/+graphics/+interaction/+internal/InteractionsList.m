classdef InteractionsList<handle


    properties
InteractionObjects
    end

    methods
        function hObj=InteractionsList(InteractionObjects)
            hObj.InteractionObjects=InteractionObjects;
        end

        function status=hasValidInteractions(hObj)
            list=hObj.InteractionObjects;
            status=true;
            if isempty(list)
                status=false;
            else
                for i=1:numel(list)
                    if~isvalid(list{i})
                        status=false;
                        break;
                    end
                end
            end
        end
    end
end

