
function axList=vectorizeAxes(hAx)




    axList=hAx;
    if~isempty(axList)
        if isappdata(hAx,'graphicsPlotyyPeer')
            newAx=getappdata(hAx,'graphicsPlotyyPeer');
            if ishghandle(newAx)
                axList=[axList;newAx];
            end
        end
    end

end
