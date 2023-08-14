function onSelect(obj,src,data)





    doc=data.Document;
    elements=data.SelectedElements;
    isStateObj=false;

    sids=[];
    if isa(doc.getModel,'SLM3I.Model')
        for i=1:elements.size
            try
                el=elements.at(i);
                sid='';
                if isa(el,'SLM3I.Block')
                    sid=Simulink.ID.getSID(el.handle);
                end
                if~isempty(sid)
                    sids=[sids,string(sid)];%#ok<AGROW>
                end
            catch
            end
        end
    elseif isa(doc.getModel,'StateflowDI.Model')
        for i=1:elements.size
            try
                sid=Simulink.ID.getSID(idToHandle(sfroot,double(elements.at(i).backendId)));
                if~isempty(sid)
                    sids=[sids,string(sid)];%#ok<AGROW>
                    isStateObj=true;
                end
            catch
            end
        end
    end

    if isempty(sids)
        return;
    end

    if strcmpi(obj.traceStyleForLastBuild,'Line Level')
        for i=1:length(sids)
            sid=sids(i);
            highlightForSid(obj,sid,isStateObj);
        end
    else
        obj.publish('m2c',sids);
    end


