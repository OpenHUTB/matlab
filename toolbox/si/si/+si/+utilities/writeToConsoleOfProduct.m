function writeToConsoleOfProduct(product,log)

    import si.utilities.*
    product=validatestring(product,["parallelLinkDesigner","serialLinkDesigner",...
    "siViewer"]);
    console=findConsole(product);
    if~isempty(console)&&isa(console,'si.utilities.SiToolBoxConsole')
        console.ConsoleText.Value=string(console.ConsoleText.Value)+newline+" "+log;
    end
end