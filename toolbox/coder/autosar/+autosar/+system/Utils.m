classdef Utils<handle




    methods(Static)
        function m3iSystem=findM3iSystemAmongstSystemsForM3iComp(m3iSystems,m3iComponent)
            m3iSystem=[];
            for i=1:size(m3iSystems)
                if~isempty(m3iSystems.at(i).RootSoftwareComposition)&&...
                    m3iSystems.at(i).RootSoftwareComposition.SwComposition==m3iComponent
                    m3iSystem=m3iSystems.at(i);
                    return
                end
            end
        end
    end
end
