function[type,overridden]=getInstanceType(node)




    overridden=false;

    if node.isFile()&&length(node.Location)>2
        for n=3:length(node.Location)
            path=split(node.Location{n},"/");
            load_system(path(1));
        end

        blockType=get_param(node.Location{end},"BlockType");
        if blockType=="ModelReference"
            type=string(get_param(node.Location{end},"SimulationMode"));
            overridden=i_isOverridden(node,type);
        elseif blockType=="SubSystem"
            type="Subsystem";
        else
            type="Normal";
        end
    else
        type="TopModel";
    end

end


function overridden=i_isOverridden(node,configured)

    overridden=false;
    pathLength=length(node.Location);

    if pathLength>3
        for n=3:pathLength-1
            if get_param(node.Location{n},"BlockType")~="ModelReference"
                return;
            end

            actual=get_param(node.Location{n},"SimulationMode");
            if~ismember(actual,["Normal",configured])
                overridden=true;
                return;
            end
        end
    end

end
