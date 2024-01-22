function app=findConsole(product)

    import si.utilities.*
    app=[];
    product=validatestring(product,["parallelLinkDesigner","serialLinkDesigner",...
    "siViewer"]);
    figs=findall(groot,'Name',qxx2FullName(product)+" Console");
    for figIdx=1:numel(figs)
        fig=figs(figIdx);
        if~isempty(fig)
            console=fig.RunningAppInstance;
            if console.isRunningApp
                app=console;
            else
                console.delete
            end
        end
    end
end

