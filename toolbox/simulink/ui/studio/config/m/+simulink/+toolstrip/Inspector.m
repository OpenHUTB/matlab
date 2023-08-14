


classdef(Hidden)Inspector<handle
    methods(Static,Access=private)
        function ret=data(operation,key,value)
            persistent panels;

            if(isempty(panels))
                panels=containers.Map;
            end


            keys=panels.keys;
            for i=1:length(keys)
                k=keys{i};
                panel=panels(k);

                if(~panel.isValid())
                    panels.remove(k);
                end
            end

            switch operation
            case 'clear'
                panels=containers.Map;
            case 'set'
                if(nargin>2)
                    panels(key)=value;
                end
            case 'get'
                ret=panels.values;
            case 'has'
                ret=panels.isKey(key);
            end
        end
    end

    methods(Static)
        function Show()
            allStudios=DAS.Studio.getAllStudios;
            idx=cellfun(@(studio)~isempty(studio.getToolStrip()),allStudios);
            studios=allStudios(idx);

            for i=1:length(studios)
                studio=studios{i};
                ts=studio.getToolStrip;
                id=ts.Id;

                if(~simulink.toolstrip.Inspector.data('has',id))
                    simulink.toolstrip.Inspector.data('set',id,simulink.toolstrip.InspectorPanel(studio));
                end
            end
        end

        function Hide()
            panels=simulink.toolstrip.Inspector.data('get');

            for i=1:length(panels)
                panel=panels{i};
                panel.hide;
            end

            simulink.toolstrip.Inspector.data('clear');
        end
    end
end