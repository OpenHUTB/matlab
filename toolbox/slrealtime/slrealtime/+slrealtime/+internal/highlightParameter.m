function highlightParameter(bpath)





    if isempty(bpath)
        sfexplr;
        return;
    end


    if iscell(bpath)
        bpath=bpath{end};
    end


    s=split(bpath,'/');
    mdl=s{1};
    if~isempty(mdl)&&~bdIsLoaded(mdl)
        try
            load_system(mdl);
        catch ME
            locUnhighlightSignal();
            DAStudio.error('slrealtime:explorer:highlightParameterNoModelError');
        end
    end


    try
        subSys=get_param(bpath,'Parent');
        open_system(subSys,'force');
    catch ME
        locUnhighlightSignal();
        DAStudio.error('slrealtime:explorer:highlightParameterInvalidPathError');
    end



    [studio,editor]=locGetCurrentStudio(subSys);
    if isempty(studio)
        open_system(subSys,'force');
        [studio,editor]=locGetCurrentStudio(subSys);
    end


    studio.show();
    studio.raise();
    clearSelection(editor);


    locUnhighlightSignal();

    Simulink.ID.hilite(Simulink.ID.getSID(bpath));
end

function locUnhighlightSignal()
    Simulink.ID.hilite('');

    [studio,~]=locGetCurrentStudio(gcs);
    if~isempty(studio)
        SLStudio.HighlightSignal.removeHighlighting(studio.App.blockDiagramHandle);
    end
end

function[studio,editor]=locGetCurrentStudio(subSys)
    studio=[];
    editor=[];
    editors=GLUE2.Util.findAllEditors(subSys);
    for idx=1:length(editors)
        if strcmpi(subSys,editors(idx).getName())
            studio=editors(idx).getStudio();
            editor=editors(idx);
        end
    end
end
