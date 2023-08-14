


function val=getInlinedParameterPlacement(obj,v)


    val=v;


    cs=obj.getConfigSet;
    if~isempty(cs)
        inlineParams=cs.getProp('InlineParams');
        if isequal(inlineParams,'off')
            val='Hierarchical';
        end
    end

