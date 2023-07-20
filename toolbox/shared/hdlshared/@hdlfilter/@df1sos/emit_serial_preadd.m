function[hdl_arch,preaddlist,pairs]=emit_serial_preadd(this,pairs,ctr_out,delaylist)






    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    arch=this.implementation;
    arch='serial';
    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');

    delayvtype=inputall.vtype;
    delaysltype=inputall.sltype;
    coeffs=this.Coefficients;
    dlist_modifier=find(coeffs);

    if strcmpi(arch,'serialcascade')
        tmp_pairs=pairs;
        for n=1:length(pairs)-1
            pairs{n}(1)=pairs{n}(1)-1;
        end
    end
    preaddlist=[];
    strt=1;
    mac_idx=1;
    for n=1:length(pairs)
        if pairs{n}(1)>1
            for m=1:pairs{n}(2)
                [uname,preaddlist(mac_idx)]=hdlnewsignal(hdllegalname(['inputmux_',num2str(mac_idx)]),'filter',-1,0,0,...
                delayvtype,delaysltype);
                if hdlgetparameter('filter_registered_input')==1
                    muxbody=hdlmux(delaylist(strt:strt+pairs{n}(1)-1),preaddlist(mac_idx),...
                    ctr_out,'=',[0:pairs{n}(1)-1],'when-else');
                else
                    dlindx=[dlist_modifier(strt),dlist_modifier(strt+1:strt+pairs{n}(1)-1)+1];
                    muxbody=hdlmux(delaylist(dlindx),preaddlist(mac_idx),...
                    ctr_out,'=',[0:pairs{n}(1)-1],'when-else');
                end
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(preaddlist(mac_idx))];
                hdl_arch.body_blocks=[hdl_arch.body_blocks,muxbody,'\n'];
                m=m+1;
                mac_idx=mac_idx+1;
                strt=strt+pairs{n}(1);
            end
        else
            for m=1:pairs{n}(2)
                if hdlgetparameter('filter_registered_input')==1
                    preaddlist(mac_idx)=delaylist(strt);
                else
                    preaddlist(mac_idx)=delaylist(dlist_modifier(strt));
                end
                mac_idx=mac_idx+1;
                strt=strt+pairs{n}(1);
            end
        end
        n=n+1;
    end
    if strcmpi(arch,'serialcascade')
        pairs=tmp_pairs;
    end
