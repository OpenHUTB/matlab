function startDesktop()
    s=settings;
    s.matlab.desktop.currentfolder.autorefresh.Enabled.TemporaryValue=false;

    if usejava('swing')
        try
            if~isempty(which('com.mathworks.mde.desk.MLDesktop.getInstance'))
                desktop=feval('com.mathworks.mde.desk.MLDesktop.getInstance');
                javaMethodEDT('saveLayout',desktop,'WorkerPrevious');
                javaMethodEDT('restoreLayout',desktop,'Command Window Only');
            end
        catch
        end
    end

    feature('hotlinks',1);
end
