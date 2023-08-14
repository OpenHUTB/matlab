function updateEmbeddedData(modelH,force)






    if nargin<2
        force=false;
    end

    if~rmisl.modelHasEmbeddedReqInfo(modelH)


        if force
            rmidata.storageModeCache('set',modelH,true);
        end
        return;
    end



    artifact=get_param(modelH,'FileName');
    slreq.data.DataModelObj.checkLicense(['allow ',artifact]);
    cll=onCleanup(@()slreq.data.DataModelObj.checkLicense('clear'));




    if~rmi.isInstalled
        msg1=getString(message('Slvnv:slreq:UnableToMigrateData'));
        msg2=getString(message('Slvnv:reqmgt:installation','Requirements Toolbox'));
        if force
            rmiut.warnNoBacktrace([msg1,' : ',msg2]);
        else
            errordlg(msg2,msg1);
        end
        return;
    end




    slreq.uri.getPreferredPath(false);
    clp=onCleanup(@()slreq.uri.getPreferredPath(true));

    [~,~,objs2clean]=rmidata.export(modelH,false);

    lockState='off';
    if(bdIsLibrary(modelH))
        lockState=get_param(modelH,'Lock');
        set_param(modelH,'Lock','off');
    end
    rmidata.cleanEmbeddedLinks(objs2clean);
    set_param(modelH,'HasReqInfo','off');

    fileName=get_param(modelH,'FileName');
    if isempty(fileName)
        isSlx=false;
    else
        [~,~,ext]=fileparts(fileName);
        isSlx=strcmpi(ext,'.slx');
    end

    if(isSlx)
        rmidata.embed(modelH);
    end

    if(bdIsLibrary(modelH))
        set_param(modelH,'Lock',lockState);
    end


    rmidata.storageModeCache('set',modelH,true);


    if slreq.app.MainManager.exists()
        appmgr=slreq.app.MainManager.getInstance;
        if~isempty(appmgr.perspectiveManager)
            appmgr.perspectiveManager.removeFromDisabledModelList(modelH);
        end
    end


    rmisl.notify(modelH,'');

end

