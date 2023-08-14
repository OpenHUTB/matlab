function refreshBlockComponent(hBlock)






    s=warning('off','backtrace');
    C=onCleanup(@()warning(s));

    sourceFile=simscape.getBlockComponent(hBlock);
    clear(which(sourceFile));

    try
        Simulink.Block.eval(hBlock);
    catch ME
        lResetDialogSource(hBlock);

        if~isempty(ME.cause)&&(numel(ME.cause)==1)
            ME.cause{1}.throwAsCaller();
        else
            ME.throwAsCaller();
        end
    end

end

function lResetDialogSource(hBlock)





    obj=get_param(hBlock,'Object');
    dlgSource=obj.getDialogSource;
    if isa(dlgSource,'PMDialogs.DynDlgSource')
        dlgSource.BuilderObj=[];
        dlgs=dlgSource.getOpenDialogs();
        for idx=1:numel(dlgs)
            dlgs{idx}.refresh();
            dlgs{idx}.resetSize();
        end
    end

end
