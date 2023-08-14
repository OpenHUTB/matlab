function showDialog(h)




    if h.isLoaded&&~isempty(h.daobject)
        if(h.daobject.isMasked)
            open_system(h.daobject.getFullName,'mask');
        else
            open_system(h.daobject.getFullName,'parameter');
        end
    end

end
