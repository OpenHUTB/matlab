function[cont,info]=rmidlg_preapply(dlgSrc,dlgH)




    if dlgH.hasUnappliedChanges()


        ReqMgr.rmidlg_hasChanges(dlgH.getTitle,true);
    else

        ReqMgr.rmidlg_hasChanges(dlgH.getTitle,false);
        cont=true;
        info='';
        return;
    end


    if(dlgSrc.tabIndex==1&&dlgH.isEnabled('contentlb')...
        &&~isempty(dlgH.getWidgetValue('contentlb')))

        selectContent(dlgSrc,dlgH);
    end




    try
        docSystems=rmi.linktype_mgr('all');
        for i=1:length(dlgSrc.reqItems)

            if isempty(dlgSrc.reqItems(i).doc)
                info=getString(message('Slvnv:reqmgt:LinkSet:updateContents:ItemNotValidDocument',i));
                cont=false;
                return;
            else
                [~,~,fExt]=fileparts(dlgSrc.reqItems(i).doc);
            end

            if dlgSrc.typeItems(i)==0
                if isempty(fExt)
                    info=getString(message('Slvnv:reqmgt:LinkSet:updateContents:ItemNotValidType',i));
                    cont=false;
                    return;
                end
            else
                uddLinkType=docSystems(dlgSrc.typeItems(i));
                dlgSrc.reqItems(i).reqsys=uddLinkType.Registration;
            end




            dlgSrc.reqItems(i).description=verifyDescription(dlgSrc.reqItems(i).description,i,dlgSrc.reqItems(i).reqsys);
        end
    catch ex
        info=ex.message;
        cont=false;
        return;
    end



    document=dlgH.getWidgetValue('docEdit');
    trimmed=strtrim(document);
    currentIdx=dlgSrc.reqIdx;
    if~isempty(trimmed)&&currentIdx>0&&currentIdx<=length(dlgSrc.reqItems)


        if dig.isProductInstalled('Simulink')&&is_simulink_loaded()&&...
            strcmp(dlgSrc.reqItems(currentIdx).reqsys,'linktype_rmi_simulink')&&...
            rmisl.isComponentHarness(trimmed)
            [trimmed,dlgSrc.reqItems(currentIdx).id]=rmisl.linkTargetFromHarness(trimmed,dlgSrc.reqItems(currentIdx).id);
        end




        if strcmp(dlgSrc.source,'matlab')&&...
            strcmp(dlgSrc.reqItems(currentIdx).reqsys,'linktype_rmi_matlab')
            if~isempty(strfind(dlgSrc.objectH,[trimmed,'|']))
                currentId=dlgSrc.reqItems(currentIdx).id;
                if isempty(currentId)||...
                    ~isempty(strfind(dlgSrc.objectH,currentId(2:end)))

                    info=getString(message('Slvnv:rmiml:RequirementsUseCurrentConflict'));
                    cont=false;
                    return;
                end
            end
        end

        if~strcmp(document,trimmed)
            dlgH.setWidgetValue('docEdit',trimmed);
            dlgSrc.reqItems(currentIdx).doc=trimmed;
        end
    end


    cont=true;
    info='';
end

function label=verifyDescription(label,idx,domain)
    persistent descriptions
    if slreq.data.Link.isDefaultDisplayLabel(label)
        label='';
    elseif strcmp(label,getString(message('Slvnv:reqmgt:NoDescriptionEntered')))
        label='';
    end
    if idx==1
        descriptions={label};
    elseif isempty(label)&&strcmp(domain,'linktype_rmi_slreq')
        return;
    elseif any(strcmp(descriptions,label))
        error(message('Slvnv:slreq:DuplicateLabelNotAllowed',label));
    else
        descriptions{end+1}=label;
    end
end




