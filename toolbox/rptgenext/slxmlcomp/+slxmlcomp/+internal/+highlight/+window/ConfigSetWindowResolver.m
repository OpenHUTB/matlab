classdef ConfigSetWindowResolver<handle




    methods(Access=public)

        function windowInfo=getInfo(obj,location)
            if location.Type=="ConfigSet"
                windowInfo.Type='ConfigSet';
                windowInfo.Id=obj.getConfigSetWindow(location.Location);
            else
                windowInfo=[];
            end
        end

    end

    methods(Access=private)

        function window=getConfigSetWindow(~,location)
            parts=regexp(location,'(?<!/)/(?!/)','split');
            if numel(parts)<1
                window='';
            elseif numel(parts)<2
                window=parts{1};
            else
                window=[parts{1},'/',parts{2}];
            end
        end

    end
end
