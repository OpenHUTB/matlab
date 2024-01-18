function hiliteAndFade(blkHOrSID)

    if ischar(blkHOrSID)
        blkH=Simulink.ID.getHandle(blkHOrSID);
    elseif length(blkHOrSID)>1

        for i=1:length(blkHOrSID)
            rmiut.hiliteAndFade(blkHOrSID(i));
        end
        return;
    elseif ishandle(blkHOrSID)
        blkH=blkHOrSID;
    elseif isnumeric(blkHOrSID)&&ceil(isnumeric(blkHOrSID))==isnumeric(blkHOrSID)

        if rmisf.isStateflowLoaded
            sfr=sfroot;
            blkH=sfr.idToHandle(blkHOrSID);
        else
            return;
        end
    elseif rmifa.isFaultInfoObj(blkHOrSID)
        return;
    elseif rmism.isSafetyManagerObj(blkHOrSID)
        return;
    end
    if isa(blkH,'Stateflow.Object')
        sfMachine=blkH.Machine;
        [~,rootModel]=fileparts(sfMachine.FullFileName);
        editor=rmisl.modelEditors(rootModel,true);
    else
        if isa(blkH(1),'Simulink.Object')
            parent=blkH(1).Path;
        else
            try
                parent=get_param(blkH(1),'Parent');
            catch ex %#ok<NASGU>

                parent='';
            end
        end
        if isempty(parent)
            return;
        end
        editor=rmisl.modelEditors(bdroot(parent),true);
    end

    if~isempty(editor)
        studio=editor.getStudio;
        if(slreq.internal.TempFlags.getInstance.get('InTestingMode'))
            studio.App.hiliteAndFadeObject(diagram.resolver.resolve(blkH),50000)
        else
            studio.App.hiliteAndFadeObject(diagram.resolver.resolve(blkH));
        end
    end
end
