function editingMode=getmaskeditingmode(mo)





    hMdl=bdroot(mo.getOwner().Handle);
    if~bdIsLibrary(hMdl)

        rtm=PmSli.RunTimeModule;
        ac=rtm.getConfigSet(hMdl);


        if~pmsl_checklicense(pmsl_defaultproduct)
            ac.set_param('EditingMode','Restricted');
        end


        editingMode=ac.get_param('EditingMode');
    else
        editingMode='Full';
    end

end
