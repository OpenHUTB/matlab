function closeConsoleOfProduct(product,force,fromQxx)

    import si.utilities.*
    if nargin<2
        force=false;
    end
    if nargin<3
        fromQxx=false;
    end
    product=si.utilities.ss2mw(product);
    console=findConsole(product);
    dbg=getenv("SI_TOOLBOX_STARTUP_DEBUG");
    if~isempty(console)&&isa(console,'si.utilities.SiToolBoxConsole')&&...
        (force||isempty(dbg)||~strcmp(dbg,'on'))
        console.salida(fromQxx);
    end
end