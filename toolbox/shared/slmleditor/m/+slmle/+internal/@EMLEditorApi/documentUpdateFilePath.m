function bool=documentUpdateFilePath(obj,id)





    if obj.logger
        disp(mfilename);
    end

    m=slmle.internal.slmlemgr.getInstance;
    eds=m.getMLFBEditorsFromAllStudios(id);
    for i=1:length(eds)
        ed=eds{i};

        data=[];

        sfx=Stateflow.App.IsStateflowApp(ed.objectId);
        modelH=bdroot(ed.blkH);
        if sfx
            [~,data.filepath]=Stateflow.App.Studio.isSfxModelAssociatedWithFileOnDisk(modelH);
        else
            data.filepath=get_param(modelH,'FileName');
        end

        ed.publish('updateFilePath',data)
    end

    bool=true;
