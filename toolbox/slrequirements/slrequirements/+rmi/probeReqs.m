function[has_doors,has_word,has_excel]=probeReqs(model)



    has_doors=false;
    has_word=false;
    has_excel=false;

    if ischar(model)
        modelH=get_param(model,'Handle');
    else
        modelH=model;
    end

    objects=rmisl.getObjWithReqs(modelH);
    for obj=objects'
        if has_doors&&has_word&&has_excel
            break;
        end
        reqs=rmi.getReqs(obj);
        for req=reqs'


            if isempty(req.doc)
                continue;
            end


            if~has_doors&&strcmpi(req.reqsys,'doors')||strcmpi(req.reqsys,'linktype_rmi_doors')
                has_doors=true;
                continue;
            end



            if has_word&&has_excel
                continue;
            end
            dot=find(req.doc=='.',1,'last');
            if~isempty(dot)
                ext=req.doc(dot:end);
                linkType=rmi.linktype_mgr('resolve',req.reqsys,ext);
                if isempty(linkType)
                    continue;
                end
                if~has_word&&strcmp(linkType.Registration,'linktype_rmi_word')
                    has_word=true;
                elseif~has_excel&&strcmp(linkType.Registration,'linktype_rmi_excel')
                    has_excel=true;
                end
            end
        end
    end
end
