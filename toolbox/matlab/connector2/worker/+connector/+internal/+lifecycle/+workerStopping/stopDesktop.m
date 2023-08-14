function stopDesktop()
    s=settings;
    s.matlab.desktop.currentfolder.autorefresh.Enabled.clearTemporaryValue();

    if usejava('swing')
        try
            if~isempty(which('com.mathworks.mde.desk.MLDesktop.getInstance'))
                desktop=feval('com.mathworks.mde.desk.MLDesktop.getInstance');
                javaMethodEDT('restoreLayout',desktop,'WorkerPrevious');
            end
        catch
        end
    end
end