
function junctions=getJunctions(context,depth,checkInsideBoxes)
    junctions=[];
    if isempty(context)
        return;
    end

    junctions=context.find('-isa','Stateflow.Junction',...
    '-depth',1,'Type','CONNECTIVE');

    if checkInsideBoxes
        boxes=context.find('-isa','Stateflow.Box','-depth',depth);
        if~isempty(boxes)
            junctions=[junctions;boxes.find('-isa','Stateflow.Junction',...
            '-depth',depth,'Type','CONNECTIVE')];
        end
    end
end