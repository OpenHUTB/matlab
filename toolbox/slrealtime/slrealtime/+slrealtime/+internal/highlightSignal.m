function highlightSignal(bpath,portIdx,varargin)




    removePreviousHighlight=true;
    if nargin>2
        removePreviousHighlight=logical(varargin{1});
    end


    blockPath=bpath.getBlock(bpath.getLength());
    mdl=Simulink.SimulationData.BlockPath.getModelNameForPath(blockPath);
    if~isempty(mdl)&&~bdIsLoaded(mdl)
        try
            load_system(mdl);
        catch ME
            locUnhighlightSignal();
            DAStudio.error('slrealtime:explorer:highlightSignalNoModelError');
        end
    end


    try
        subSys=get_param(blockPath,'Parent');
        open_system(subSys,'force');
    catch ME
        locUnhighlightSignal();
        DAStudio.error('slrealtime:explorer:highlightSignalInvalidPathError');
    end



    [studio,editor]=locGetCurrentStudio(subSys);
    if isempty(studio)
        open_system(subSys,'force');
        [studio,editor]=locGetCurrentStudio(subSys);
    end


    studio.show();
    studio.raise();
    clearSelection(editor);

    bdHandle=get_param(bdroot(blockPath),'Handle');


    if removePreviousHighlight
        SLStudio.HighlightSignal.removeHighlighting(bdHandle);
    end













    try
        ph=get_param(blockPath,'PortHandles');
        hPort=ph.Outport(portIdx);
        hLine=get_param(hPort,'Line');
    catch ME %#ok<NASGU>

        locUnhighlightSignal();
        Simulink.ID.hilite(Simulink.ID.getSID(blockPath));
        return
    end


    SLStudio.HighlightSignal.HighlightSignalToSource(hLine,bdHandle);
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
