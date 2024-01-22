function[process,instance]=startProduct(app,product,fileNames)
    validateattributes(product,{'char','string'},{'nonempty'})
    product=validatestring(product,["parallelLinkDesigner",...
    "serialLinkDesigner",...
    "siViewer"]);
    import si.utilities.*
    if~consoleInit(product)
        app.salida
        process=[];
        instance=1;
    else
        instance=1;
        dbg=getenv("SI_TOOLBOX_STARTUP_DEBUG");
        if isempty(dbg)||~strcmp(dbg,'on')
            app.DummyFigure.Visible='off';
        end
        app.DummyFigure.Name=qxx2FullName(product)+" Console";
        process=qxx(product,fileNames);



        if isempty(process)||~process.isAlive
            app.salida
        end
    end
end