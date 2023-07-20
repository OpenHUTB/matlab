classdef(Hidden=true)TimingLegendManager<handle

    methods(Static)
        function legend=getLegend(modelHandle)
            import simulink.timinglegend.internal.TimingLegendManager;

            TimingLegendManager.addLegendToMapIfNeeded(modelHandle);

            legendMap=TimingLegendManager.getLegendMap;
            legend=legendMap(modelHandle);
        end

        function removeLegend(modelHandle)
            import simulink.timinglegend.internal.TimingLegendManager;

            if TimingLegendManager.legendExists(modelHandle)
                legendMap=TimingLegendManager.getLegendMap();
                legend=legendMap(modelHandle);
                remove(legendMap,modelHandle);
                delete(legend);
                bd=get_param(modelHandle,'Object');
                bd.removeCallback('PreDestroy','TimingLegend');
            end
        end

        function bool=legendExists(modelHandle)
            legendMap=simulink.timinglegend.internal.TimingLegendManager.getLegendMap;
            bool=isKey(legendMap,modelHandle);
        end
    end

    methods(Access=private)
        function delete(~)
            legendMap=simulink.timinglegend.internal.TimingLegendManager.getLegendMap;
            legendKeys=keys(legendMap);
            for i=1:length(legendKeys)
                simulink.timinglegend.internal.TimingLegendManager.removeLegend(legendKeys{i});
            end
        end
    end

    methods(Static,Access=private)

        function ret=getLegendMap()
            persistent hashMap;
            mlock;
            if isempty(hashMap)||~isvalid(hashMap)
                hashMap=containers.Map('KeyType','double','ValueType','any');
            end

            ret=hashMap;
        end

        function addLegendToMapIfNeeded(modelHandle)
            import simulink.timinglegend.internal.TimingLegendManager;

            if~TimingLegendManager.legendExists(modelHandle)


                legend=simulink.timinglegend.internal.TimingLegend(modelHandle);


                legendMap=TimingLegendManager.getLegendMap;
                legendMap(modelHandle)=legend;%#ok<NASGU>

                bd=get_param(modelHandle,'Object');
                bd.addCallback('PreDestroy','TimingLegend',...
                @()TimingLegendManager.removeLegend(modelHandle));
            end
        end
    end
end

