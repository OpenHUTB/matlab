function valueSources=getAllValidValueSources(hObj)





    if isempty(hObj.ZData)
        valueSources=["[XData,YData]";"[UData,VData]"];
    else
        valueSources=["[XData,YData,ZData]";"[UData,VData,WData]"];
    end

    valueSources=[valueSources;"XData";"YData";"ZData";"UData";"VData";"WData"];
end
