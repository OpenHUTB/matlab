function LogicAnalyzer(obj)




    if obj.ver.isR2016b

        j=get_param(obj.modelName,'logicAnalyzerGraphicalSettings');
        if~isempty(j)
            d=jsondecode(j);

            newTraces={};
            traces=d.panels.traces;
            numChildren=size(traces,1);
            for i=1:numChildren
                diveIntoGroup(structOrCellIndex(traces,i));
            end
            d.panels.traces=newTraces;
            j=jsonencode(d);
            set_param(obj.modelName,'logicAnalyzerGraphicalSettings',j);
        end
    end


    function diveIntoGroup(current)
        if strcmp(current.type,'group')
            numSubWaves=size(current.subWaves,1);
            for jdx=1:numSubWaves
                diveIntoGroup(structOrCellIndex(current.subWaves,jdx));
            end
        else
            newTraces{end+1,1}=current;
        end

    end

    function element=structOrCellIndex(data,index)
        if iscell(data)
            element=data{index};
        elseif isstruct(data)
            element=data(index);
        end
    end
end
