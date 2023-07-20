function tf=isArtifactLoaded(domain,artifact)




    domain=convertStringsToChars(domain);
    artifact=convertStringsToChars(artifact);

    switch domain

    case 'linktype_rmi_matlab'
        tf=rmiut.RangeUtils.isOpenInEditor(artifact);

    case 'linktype_rmi_simulink'
        if dig.isProductInstalled('Simulink')&&is_simulink_loaded()
            [~,mdlName]=fileparts(artifact);
            try
                fPath=get_param(mdlName,'FileName');
                tf=strcmp(fPath,artifact);
            catch ME %#ok<NASGU>
                tf=false;
            end
        else
            tf=false;
        end

    case 'linktype_rmi_data'
        if dig.isProductInstalled('Simulink')&&is_simulink_loaded()
            shortName=slreq.uri.getShortNameExt(artifact);
            fPaths=Simulink.dd.getOpenDictionaryPaths(shortName);
            tf=any(strcmp(fPaths,artifact));
        else
            tf=false;
        end

    case 'linktype_rmi_testmgr'
        if isempty(which('stm.view'))
            tf=false;
        else
            fPaths=sltest.testmanager.getTestFiles();
            tf=any(strcmp({fPaths.FilePath},artifact));
        end

    case 'linktype_rmi_slreq'
        rdata=slreq.data.ReqData.getInstance;
        [~,reqSetName]=fileparts(artifact);
        tf=~isempty(rdata.getReqSet(reqSetName));

    otherwise
        rmiut.warnNoBacktrace('Slvnv:slreq:UnsupportedDomain',domain);
        tf=false;
    end

end