function ret=highlightSignal(this,sid,fullpath,portIdx,metaData)
    fullpathcopy=fullpath;
    bpath=fullpath{end};
    ret=false;
    if isempty(sid)&&isempty(fullpath{1})
        this.unhighlightSignal(sid,bpath,portIdx,metaData);
        return
    end


    mdl=locGetModelForSignal(bpath,sid);
    if~isempty(mdl)&&~bdIsLoaded(mdl)
        try
            load_system(mdl);
        catch me %#ok<NASGU>
            this.unhighlightSignal(sid,bpath,portIdx,metaData);
            return
        end
    end


    try
        hBlk=Simulink.ID.getHandle(sid);
        obj=get_param(hBlk,'Object');
        if~isa(obj,'Simulink.BlockDiagram')
            blockPath=obj.getFullName();
        else

            blockPath=bpath;
            sid='';
        end
    catch me %#ok<NASGU>
        blockPath=bpath;
    end


    if isempty(sid)&&~isempty(bpath)
        try
            sid=Simulink.ID.getSID(bpath);
        catch me %#ok<NASGU>
        end
    end


    if isfield(metaData,'cb')&&~isempty(metaData.cb)
        if metaData.cb(sid,fullpath,portIdx,metaData,true)
            ret=true;
            return
        end
    end


    try

        subSys=get_param(blockPath,'Parent');
        bp='';

        if length(fullpath)>1

            parentSys=get_param(subSys,'Parent');
            if isempty(parentSys)

                fullpath(end)=[];
            else

                fullpath{end}=subSys;
            end
            bp=Simulink.BlockPath(fullpath);

            try
                validate(bp);
                open(bp);
            catch me %#ok<NASGU>

                open_system(subSys);
            end
        else
            open_system(subSys);
        end
    catch me %#ok<NASGU>
        this.unhighlightSignal(sid,bpath,portIdx,metaData);
        return
    end



    [studio,editor]=this.getCurrentStudio(subSys);
    if isempty(studio)
        if~isempty(bp)
            open(bp,'Force','on');
        else
            open_system(subSys,'force');
        end
        [studio,editor]=this.getCurrentStudio(subSys);
    end


    if isempty(studio)
        return
    end


    studio.show();
    studio.raise();
    clearSelection(editor);


    bdHandle=get_param(bdroot(blockPath),'Handle');
    SLStudio.HighlightSignal.removeHighlighting(bdHandle);


    ret=true;


    if isequal(metaData.IsStateflow,true)||...
        isequal(metaData.IsAssessment,true)
        Simulink.ID.hilite(sid);
        if~isempty(metaData.SSIDNumber)
            Stateflow.Debug.Runtime.open_object(blockPath,double(metaData.SSIDNumber));
        end
        return
    end


    try
        ph=get_param(blockPath,'PortHandles');
        hPort=ph.Outport(portIdx);
        hLine=get_param(hPort,'Line');
    catch me %#ok<NASGU>

        this.unhighlightSignal(sid,bpath,portIdx,metaData);
        fullbp=Simulink.BlockPath(fullpathcopy);
        hilite_system(fullbp,'find');
        return
    end


    SLStudio.HighlightSignal.HighlightSignalToSource(hLine,bdHandle);
end

function mdl=locGetModelForSignal(bpath,sid)



    import Simulink.SimulationData.BlockPath;
    mdl=BlockPath.getModelNameForPath(bpath);
    if~isempty(sid)
        indexes=strfind(sid,':');
        if(~isempty(indexes))
            index=indexes(1);
            mdl=sid(1:(index-1));
        end
    end
end
