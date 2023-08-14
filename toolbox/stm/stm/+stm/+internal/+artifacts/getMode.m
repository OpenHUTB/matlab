function mode=getMode(hFig)





    axes=findobj(hFig,'type','axes');
    mArr=arrayfun(@(x)x.NextPlot,axes,'UniformOutput',false);

    if(any(strcmp('add',mArr)))
        mode='add';
    else
        mode='replace';
    end

end

