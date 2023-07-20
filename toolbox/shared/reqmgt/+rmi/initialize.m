function status=initialize()



    rmi.linktype_mgr('clear');


    rmi.loadLinktype('linktype_rmi_text');
    rmi.loadLinktype('linktype_rmi_html');
    rmi.loadLinktype('linktype_rmi_matlab');
    rmi.loadLinktype('linktype_rmi_data');
    rmi.loadLinktype('linktype_rmi_slreq');
    if reqmgt('rmiFeature','SafetyManagerLinking')
        rmi.loadLinktype('rmism.linktype_rmi_safetymanager');
    end

    if ispc
        rmi.loadLinktype('linktype_rmi_word');
        rmi.loadLinktype('linktype_rmi_excel');
        rmi.loadLinktype('linktype_rmi_doors');
    end
    rmi.loadLinktype('linktype_rmi_pdf');
    rmi.loadLinktype('linktype_rmi_url');



    rmi.loadLinktype('oslc.linktype_rmi_oslc');

    if dig.isProductInstalled('Simulink')&&is_simulink_loaded()

        rmi.loadLinktype('linktype_rmi_simulink');


        rmipref('DuplicateOnCopy');


        if~isempty(which('stm.view'))
            rmi.loadLinktype('linktype_rmi_testmgr');
        end
    end


    regLinkTypes=rmi.settings_mgr('get','regTargets');
    for custLinkType=regLinkTypes(:)'
        name=custLinkType{1};
        if name(1)~='%'
            rmi.loadLinktype(name);
        end
    end


    rmide.registerCallback();

    status=true;
end


