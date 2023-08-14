function url=makeUrl(linkType,doc,id,ref)







    if local_isURL(linkType.Registration)


        makeExternalURL=true;
    else



        makeExternalURL=rmipref('ReportNavUseMatlab');
    end

    if makeExternalURL


        domainAdapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain(linkType.Registration);
        url=domainAdapter.getURL(doc,id);
    else

        url=rmi.Informer.matlabNavCmd(linkType,doc,id,ref);
    end
end

function tf=local_isURL(domain)


    tf=any(strcmp(domain,{'linktype_rmi_url','linktype_rmi_oslc'}));
end


