function refreshModelBlockDialogs()
    try
        dlgs=findDDGByTag('ModelReference');
        for n=1:numel(dlgs)
            try
                dlgs(n).refresh();
            catch me


                warning(me.getReport)
            end
        end
    catch me
        warning(me.getReport)
    end
end
