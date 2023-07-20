function srcStr=getSourceName(this)

    hExt=this.Application.getExtInst('Core','General UI');
    displ_full_src=getPropertyValue(hExt,'DisplayFullSourceName');
    if displ_full_src
        srcStr=this.Name;
    else
        srcStr=this.NameShort;
    end




    if slfeature('slPbcModelRefEditorReuse')&&...
        ~isempty(this.BlockHandle)&&isprop(this.BlockHandle,'StudioTopLevel')
        hModelString=get_param(this.BlockHandle.handle,'StudioTopLevel');
        if isempty(hModelString)
            mdlName=bdroot(this.BlockHandle.Parent);
        else
            storedHandle=str2double(hModelString);
            mdlName=get_param(storedHandle,'Name');
        end

        if~strcmp(bdroot(this.BlockHandle.Parent),mdlName)

            srcStr=[srcStr,' - [',mdlName,']'];
        end
    end
end
