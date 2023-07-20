function[total_objects,modified_links,total_links]=updateLabels(modelH)





    if ischar(modelH)
        modelH=get_param(modelH,'Handle');
    end


    objects=rmisl.getObjWithReqs(modelH);
    total_objects=length(objects);
    total_links=0;
    modified_links=0;
    if total_objects==0
        return;
    else
        if isempty(rmidoors.customLabel())
            use_default=true;
        else
            use_default=false;
        end
        if~rmidoors.isAppRunning('nodialog')
            disp(getString(message('Slvnv:reqmgt:customLabel:DoorsNotRunning')));
            return;
        end
        for obj=objects'

            reqs=rmi('get',obj);
            if isempty(reqs)
                continue;
            end
            total_links=total_links+length(reqs);
            if~any(strcmp({reqs.reqsys},'linktype_rmi_doors'))
                continue;
            end
            [~,objLabel]=rmi.objinfo(obj);
            objLabel=strrep(objLabel,char(10),' ');
            modified=false;
            for i=1:length(reqs)
                if strcmp(reqs(i).reqsys,'linktype_rmi_doors')
                    module=strtok(reqs(i).doc);
                    object=reqs(i).id;
                    if use_default
                        if object(1)=='#'
                            object=object(2:end);
                        end
                        newLabel=rmidoors.getObjAttribute(module,object,'labelText');
                    else
                        newLabel=rmidoors.customLabel(module,object);
                    end
                    if~strcmp(newLabel,reqs(i).description)
                        disp(getString(message('Slvnv:reqmgt:doorssync:UpdatingLabel',objLabel,reqs(i).description,newLabel)));
                        reqs(i).description=newLabel;
                        modified_links=modified_links+1;
                        modified=true;
                    end
                end
            end
            if modified
                if rmisl.is_signal_builder_block(obj)
                    rmi('set',obj,reqs,1,length(reqs));
                else
                    rmi('set',obj,reqs);
                end
            end
        end
    end
end


