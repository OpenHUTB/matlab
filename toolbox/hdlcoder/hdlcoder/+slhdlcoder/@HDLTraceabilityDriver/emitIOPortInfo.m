function jsCmds=emitIOPortInfo(this,p,w,io_data,jsCmds)%#ok<INUSL>



    totalIOPorts=length(io_data.inputs)+length(io_data.outputs);
    if totalIOPorts==0
        return;
    end

    section=w.createSection(DAStudio.message('hdlcoder:report:create_section_ioports',num2str(io_data.pin_count.inputs+io_data.pin_count.outputs)),5);
    w.commitSection(section);


    function info_list=generatePort(port_info)
        info_list=w.createList();
        for itr=1:length(port_info)
            port=port_info(itr);


            if~strcmpi(port.Kind,'data')
                port_handle=-1;
            else
                port_handle=port.SimulinkHandle;
            end
            port_path=port.Name;
            parts=strsplit(port_path,'/');

            npins_str=num2str(port.numberofelements*port.bitlength);
            if strcmp(npins_str,'1')
                suffix=' bit';
            else
                suffix=' bits';
            end
            if(port_handle==-1)
                info_list.createEntry([parts{end},': ',npins_str,suffix]);
            else
                try
                    port_path=getfullname(port_handle);
                    info_list.createEntry([hdlhtml.reportingWizard.generateSystemLink(port_path,port_handle),': ',npins_str,suffix]);
                catch mEx %#ok<NASGU>

                    info_list.createEntry([port_path,': ',npins_str,suffix]);
                end
            end
        end
    end

    inport_info=generatePort(io_data.inputs);
    jsCmd=addOnclickEvent(w,['Number of Input Bits: ',num2str(io_data.pin_count.inputs)],length(io_data.inputs),'Input_Port',0);
    addCompLinks(w,inport_info,length(io_data.inputs),'Input_Port');
    w.addBreak;
    jsCmds=[jsCmds,jsCmd,';'];

    outport_info=generatePort(io_data.outputs);
    jsCmd=addOnclickEvent(w,['Number of Output Bits: ',num2str(io_data.pin_count.outputs)],length(io_data.outputs),'Output_Port',0);
    addCompLinks(w,outport_info,length(io_data.outputs),'Output_Port');
    w.addBreak;
    jsCmds=[jsCmds,jsCmd,';'];
end


function jsCmd=addOnclickEvent(w,compInfo,numElem,typeid,isUserDefined)
    jsCmd='';
    if numElem>0&&~isUserDefined
        jsCmd=['hdlTableShrink(this, ''',typeid,''')'];
        section=w.createSection('[+]','span');
        section.setAttribute('name','collapsible');
        section.setAttribute('id','collapsible');
        section.setAttribute('style','font-family:monospace');
        section.setAttribute('onclick',jsCmd);
        section.setAttribute('onmouseover','this.style.cursor = ''pointer''');
        w.commitSection(section);
    end

    section=w.createSection(compInfo,'span');
    section.setAttribute('style','font-family:monospace');
    w.commitSection(section);
end


function addCompLinks(w,list,numElem,typeid)
    if(numElem)>0
        section=w.createSection('','span');
        section.setAttribute('name',typeid);
        section.setAttribute('id',typeid);
        section.createEntry(list);
        w.commitSection(section);
    end
end


