function hObj=doloadobj(hObj)





    runSetup=false;
    if isa(hObj.BoxEdge_I,'matlab.graphics.primitive.world.LineStrip')
        hObj.BoxEdge_I=matlab.graphics.primitive.world.LineLoop;
        runSetup=true;
    end






    ts=hObj.TitleSeparator_I;
    if isempty(ts)||~isvalid(ts)
        hObj.TitleSeparator_I=matlab.graphics.primitive.world.LineStrip;
        runSetup=true;
    end

    if runSetup
        setupBoxEdge(hObj);
    end




    if isscalar(hObj.Title_I)&&isvalid(hObj.Title_I)
        hObj.DecorationContainer.addNode(hObj.Title_I);
        addlistener(hObj.Title_I,'MarkedDirty',@(h,e)doMethod(hObj,'doMarkDirty','all'));
        addlistener(hObj.Title_I,'ObjectBeingDestroyed',@(h,e)doMethod(hObj,'doMarkDirty','all'));
    end










    if isempty(hObj.PlotChildrenSpecified)&&isempty(hObj.PlotChildrenExcluded)
        hObj.PlotChildrenSpecified=hObj.PlotChildren_I;

        all_ch=matlab.graphics.illustration.internal.getLegendableChildren(hObj.Axes);
        chToExclude=setdiff(all_ch,hObj.PlotChildren_I,'stable');
        hObj.PlotChildrenExcluded_I=chToExclude;
    end



    removeAllEntries(hObj)
end
