function isBeingDestroyed=closeWarningDlgs(h)




    isBeingDestroyed=false;


    for idx=1:length(h.cachedWarningDlgs)
        if isgraphics(h.cachedWarningDlgs(idx))
            isBeingDestroyed=true;
            dlg=handle(h.cachedWarningDlgs(idx));
            delete(dlg);
        end
    end


    h.isBeingDestroyed=isBeingDestroyed;

end
