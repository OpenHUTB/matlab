function showHideQxxConsole(product,visible)




    import si.utilities.*
    validateattributes(product,{'char','string'},{'nonempty'})
    product=string(product).lower;
    console=findConsole(product);
    if~isempty(console)&&isa(console,'si.utilities.SiToolBoxConsole')
        console.DummyFigure.Visible=visible;
    else
        disp("Console for "+qxx2FullName(product)+" is not available")
    end
end

