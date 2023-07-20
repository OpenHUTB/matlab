function saveView(ax)






    resetplotview(ax,'SaveCurrentView');
    l=addlistener(ax,'ClaReset',@(o,e)noOp);
    for i=1:numel(l)
        l(i).Callback=@(axh,e)resetViewOnce(axh,l(i));
    end

    function resetViewOnce(hAxes,l)
        resetplotview(hAxes,'SetViewStruct',[]);
        if isvalid(l)
            delete(l);
        end

        function noOp