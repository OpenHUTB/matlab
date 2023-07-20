classdef Utils<handle




    methods(Static)
        function m3iSwcTiming=findM3iTimingForM3iComponent(m3iModel,m3iComponent)

            m3iSwcTimings=autosar.timing.Utils.findM3iSwcTimings(m3iModel);
            m3iSwcTiming=autosar.timing.Utils.findM3iTimingAmongstTimingsForM3iComp(m3iSwcTimings,m3iComponent);
        end

        function m3iSwcTimings=findM3iSwcTimings(m3iModel)

            m3iSwcTimings=...
            Simulink.metamodel.arplatform.ModelFinder.findObjectByMetaClass(...
            m3iModel,...
            Simulink.metamodel.arplatform.timingExtension.SwcTiming.MetaClass,...
            true);
        end

        function m3iSwcTiming=findM3iTimingAmongstTimingsForM3iComp(m3iSwcTimings,m3iComponent)

            m3iBehavior=m3iComponent.Behavior;
            m3iSwcTiming='';
            for sIndex=1:m3iSwcTimings.size()
                if m3iSwcTimings.at(sIndex).Behavior==m3iBehavior
                    m3iSwcTiming=m3iSwcTimings.at(sIndex);
                    return
                end
            end
        end
    end
end
