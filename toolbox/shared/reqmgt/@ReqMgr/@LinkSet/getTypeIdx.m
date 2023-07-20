function myType=getTypeIdx(~,reqItem)




    if(isempty(reqItem))
        myType=1;
    else
        reqSys=reqItem.reqsys;
        docTypes=rmi.linktype_mgr('all');
        myType=0;
        if strcmp(reqSys,'other')||any(strcmp(reqSys,{'OTHERS','WORD','HTML','EXCEL'}))
            [~,~,extension]=fileparts(reqItem.doc);
            for typeIdx=1:length(docTypes)
                if any(strcmp(extension,docTypes(typeIdx).Extensions))
                    myType=typeIdx;
                    return;
                end
            end
        elseif strcmpi(reqSys,'doors')
            for typeIdx=1:length(docTypes)
                if strcmp(docTypes(typeIdx).Registration,'linktype_rmi_doors')
                    myType=typeIdx;
                    return;
                end
            end
        else
            for typeIdx=1:length(docTypes)
                if strcmp(docTypes(typeIdx).Registration,reqSys)
                    myType=typeIdx;
                    return;
                end
            end
        end





        if strcmp(reqSys,'linktype_rmi_simulink')
            rmi.loadLinktype('linktype_rmi_simulink');
            rmipref('DuplicateOnCopy');
            myType=length(docTypes)+1;
        elseif strcmp(reqSys,'linktype_rmi_testmgr')
            if~isempty(which('stm.view'))
                rmi.loadLinktype('linktype_rmi_testmgr');
                myType=length(docTypes)+1;
            end
        end
    end
end
