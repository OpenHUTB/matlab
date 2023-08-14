function setPropertyForChart(path,propName,value)

    rt=sfroot();
    try
        find_system(path,'SearchDepth',1);
    catch
        error(message('Stateflow:reactive:InvalidTestSequence',path))

    end
    chart=rt.find('-isa','Stateflow.Chart','Path',path);
    if(isempty(chart))
        error(message('Stateflow:reactive:InvalidTestSequence',path))
    end
    chart.set(propName,value);
end