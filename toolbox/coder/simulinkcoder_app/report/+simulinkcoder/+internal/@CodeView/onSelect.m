function onSelect(obj,src,data)


    doc=data.Document;
    elements=data.SelectedElements;

    sids=[];
    if isa(doc.getModel,'SLM3I.Model')
        for i=1:elements.size
            try
                el=elements.at(i);
                sid='';
                if isa(el,'SLM3I.Block')
                    sid=Simulink.ID.getSID(el.handle);
                elseif slfeature('TraceVarSource')>0&&isa(el,'SLM3I.Segment')
                    port=get_param(el.srcElement.handle,'Object');
                    blkPath=port.Parent;
                    assert(strcmp(port.PortType,'outport'));
                    sid=[Simulink.ID.getSID(blkPath),'#out:',num2str(port.PortNumber)];
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
                end
            catch
            end
        end
    end

    obj.publish('m2c',sids);