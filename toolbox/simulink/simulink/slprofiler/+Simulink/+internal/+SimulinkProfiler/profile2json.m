function jsonStr=profile2json(inObj,isLast)

    jsonStr=sprintf('{"value":%.3f,',inObj.totalTime);
    newLabel=replace(inObj.shortLabel,newline,' ');
    jsonStr=append(jsonStr,'"name":"',newLabel,'","children":[');


    nChildren=numel(inObj.children);
    for i=1:nChildren
        lastChild=i==nChildren;
        jsonStr=append(jsonStr,...
        Simulink.internal.SimulinkProfiler.profile2json(inObj.children(i),...
        lastChild));
    end

    if~isLast
        jsonStr=append(jsonStr,']},');
    else
        jsonStr=append(jsonStr,']}');
    end
end