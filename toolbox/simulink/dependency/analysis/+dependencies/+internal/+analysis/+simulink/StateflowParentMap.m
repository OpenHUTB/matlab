classdef StateflowParentMap




    properties(GetAccess=public,SetAccess=immutable)
parentMap
    end

    methods

        function obj=StateflowParentMap(node,allChartIDs,stateIDs,stateParents,allMachineIDs)

            obj.parentMap=containers.Map;

            for n=1:length(allChartIDs)
                obj.parentMap(allChartIDs{n})=[];
            end


            if~dependencies.internal.analysis.simulink.hasSlxQueries(node.Location{1})
                spIDs=i_getParent(stateParents);
                for n=1:length(spIDs)
                    obj.parentMap(stateIDs{n})=spIDs{n};
                end
            end

            if(nargin>4)
                for n=1:length(allMachineIDs)
                    obj.parentMap(allMachineIDs{n})='machine';
                end
            end

        end

        function chartIDs=getChartFromParentMap(obj,matches)

            chartIDs=i_getParent(matches);
            for n=1:length(chartIDs)
                chartIDs{n}=obj.getChartID(chartIDs{n});
            end

        end

        function chartID=getChartID(obj,id)
            chartID=id;

            while obj.parentMap.isKey(chartID)&&~isempty(obj.parentMap(chartID))
                chartID=obj.parentMap(chartID);
            end
        end

    end

end

function parents=i_getParent(matches)

    num=length(matches);
    parents=cell(num,1);

    for n=1:length(matches)
        if isempty(matches{n})
            parents{n}='machine';
        else
            [~,ids]=evalc(matches{n});
            parents{n}=num2str(ids(1));
        end
    end
end
