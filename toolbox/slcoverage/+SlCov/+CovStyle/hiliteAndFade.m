function hiliteAndFade(blkHOrSID)




    if iscell(blkHOrSID)&&(length(blkHOrSID)==1)
        blkHOrSID=blkHOrSID{1};
    end

    if ischar(blkHOrSID)
        blkH=Simulink.ID.getHandle(blkHOrSID);
    elseif length(blkHOrSID)>1

        for i=1:length(blkHOrSID)
            SlCov.CovStyle.hiliteAndFade(blkHOrSID(i));
        end
        return;
    elseif ishandle(blkHOrSID)
        blkH=blkHOrSID;
    elseif isnumeric(blkHOrSID)&&ceil(isnumeric(blkHOrSID))==isnumeric(blkHOrSID)

        sfr=sfroot;
        blkH=sfr.idToHandle(blkHOrSID);
    end
    if isa(blkH,'Stateflow.Object')
        editor=[];
        if isprop(blkH,'Subviewer')
            editor=GLUE2.Util.findAllEditors(blkH.Subviewer.Path);
        end



        curBlk=blkH;
        while isempty(editor)&&~isempty(curBlk)
            editor=GLUE2.Util.findAllEditors(curBlk.Path);
            curBlk=curBlk.getParent;
        end
    else
        if isa(blkH(1),'Simulink.Object')
            parent=blkH(1).Path;
        else
            try
                parent=get_param(blkH(1),'Parent');
            catch

                parent='';
            end
        end
        if isempty(parent)
            return;
        end
        editor=GLUE2.Util.findAllEditors(parent);
    end
    if~isempty(editor)
        studio=editor.getStudio;
        studio.App.hiliteAndFadeObject(diagram.resolver.resolve(blkH));
    end
end