function preCloseCallback(dialog,UD)






    if~isempty(dialog)&&ishghandle(dialog,'figure')

        sigbuilder('close',dialog,UD);
    end
