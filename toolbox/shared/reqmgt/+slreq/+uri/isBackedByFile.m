function tf=isBackedByFile(domain)






    switch domain
    case{'linktype_rmi_word','linktype_rmi_excel',...
        'linktype_rmi_text','linktype_rmi_html',...
        'linktype_rmi_pdf',...
        'linktype_rmi_simulink','linktype_rmi_data',...
        'linktype_rmi_testmgr','linktype_rmi_matlab',...
        'linktype_rmi_slreq'}
        tf=true;
    case{'linktype_rmi_doors','linktype_rmi_url','linktype_rmi_oslc'}
        tf=false;
    otherwise
        if slreq.uri.isImportedReqIF(domain)



            tf=true;
        else
            customDomainDef=rmi.linktype_mgr('resolveByRegName',domain);
            if~isempty(customDomainDef)
                tf=customDomainDef.isFile;
            else
                tf=false;
            end
        end
    end
end

