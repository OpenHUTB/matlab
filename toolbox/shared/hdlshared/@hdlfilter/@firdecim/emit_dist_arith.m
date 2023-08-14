function[hdl_arch,entitysigs,prodlist,ce]=emit_dist_arith(this,entitysigs,ce)






    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    arch=this.implementation;

    coeffall=hdlgetallfromsltype(this.coeffSLtype);
    coeffsvbp=coeffall.bp;

    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');
    inputsize=inputall.size;
    inputbp=inputall.bp;
    inputsigned=inputall.signed;

    clken=hdlsignalfindname(hdlgetparameter('clockenablename'));

    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];
    phases=this.decimationfactor;
    polycoeffs=this.polyphasecoefficients;

    daengineindx=any(polycoeffs,2);
    daengines=length(find(daengineindx));

    lpi=hdlgetparameter('filter_dalutpartition');
    radix=hdlgetparameter('filter_daradix');
    baat=log2(radix);

    if size(lpi,1)==1
        lpi=resolveDALUTPartition(this,lpi);
    end


    [inputcastvtype,inputcastsltype]=hdlgettypesfromsizes(inputsize,inputbp,inputsigned);
    [ignored,inputcastptr]=hdlnewsignal('filter_in_cast','filter',-1,0,0,inputcastvtype,inputcastsltype);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(inputcastptr)];
    inputcastbody=hdldatatypeassignment(entitysigs.input,inputcastptr,'floor',0);
    hdl_arch.body_blocks=[hdl_arch.body_blocks,inputcastbody];


    [tc_arch,ce,phasece,ignored]=emit_timingcontrol(this,ce);
    hdl_arch=combinehdlcode(this,hdl_arch,tc_arch);

    [inputcastvtype,inputcastsltype]=hdlgettypesfromsizes(inputsize,inputbp,inputsigned);
    prodlist=zeros(1,daengines);
    lut_max=0;
    for n=1:size(polycoeffs,1)
        lut_max=sum(abs(polycoeffs(n,:)))+lut_max;
    end
    fp_accumbp=inputbp+coeffsvbp;
    rmax=(2^(inputsize-inputbp-1)-2^(-1*inputbp))*lut_max;
    fp_accumsize=ceil(log2(rmax))+fp_accumbp+1;
    prodlist_indx=1;
    for n=1:phases
        if daengineindx(n)
            hdl_arch.body_blocks=[hdl_arch.body_blocks,...
            indentedcomment,...
            '  ------------ Polyphase Subfilter # ',num2str(n),' ------------------------\n\n'];
            if baat==inputsize
                [ignored,inputreg]=hdlnewsignal(['input_register_',num2str(n)],'filter',-1,0,0,inputcastvtype,inputcastsltype);
                hdlregsignal(inputreg);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(inputreg)];
                oldce=hdlgetcurrentclockenable;
                hdlsetcurrentclockenable(phasece(n));
                [tempbody,tempsignals]=hdlunitdelay(inputcastptr,inputreg,...
                ['Input_Register_',num2str(n),hdlgetparameter('clock_process_label')],0);
                hdlsetcurrentclockenable(oldce);
                hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
                hdl_arch.signals=[hdl_arch.signals,tempsignals];
                inputcastsig=inputreg;
            else
                inputcastsig=inputcastptr;
            end

            lpi_n=lpi(n,:);
            lpi_n=lpi_n(lpi_n~=0);
            if baat~=inputsize
                load_en=ce.load_en;
                controlsigs=[load_en(n),ce.accum(n),ce.afinal(n),load_en(n)];
            else
                controlsigs(1)=hdlgetcurrentclockenable;
                controlsigs(2)=phasece(n);
                ce.ceout=phasece(phases);
            end
            if any(polycoeffs(n,:))
                if prodlist_indx==1
                    [hdlbody,hdlsignals,hdltypedefs,ignoreconst,prodlist(daengines-prodlist_indx+1)]=...
                    this.emit_damac(inputcastsig,polycoeffs(n,:),'fir',controlsigs,lpi_n,fp_accumsize,...
                    'tree',n);
                    hdl_arch.typedefs=[hdl_arch.typedefs,hdltypedefs];
                else
                    [hdlbody,hdlsignals,ignoretypedefs,ignoreconst,prodlist(daengines-prodlist_indx+1)]=...
                    this.emit_damac(inputcastsig,polycoeffs(n,:),'fir',controlsigs,lpi_n,fp_accumsize,...
                    'tree',n);
                end
                hdl_arch.body_blocks=[hdl_arch.body_blocks,hdlbody];
                hdl_arch.signals=[hdl_arch.signals,hdlsignals];
            end
            prodlist_indx=prodlist_indx+1;
        end
    end
    hdlsetcurrentclockenable(ce.ceout);





    function lpi_modified=resolvelpi(lpi,polyc)
        lpi=sort(lpi,'descend');
        lpi_modified=[];

        out={};
        for n=1:size(polyc,1)
            allowedin=length(find(polyc(n,:)));
            m=1;
            done=0;
            out1=[];
            while~done
                if allowedin>lpi(m)
                    out1=[out1,lpi(m)];
                    allowedin=allowedin-lpi(m);
                else
                    out1=[out1,allowedin];
                    done=1;
                end
                m=m+1;
            end
            out{n}=out1;
        end
        maxlen=0;
        for n=1:length(out)
            if maxlen<length(out{n})
                maxlen=length(out{n});
            end
        end
        for n=1:length(out)
            if length(out{n})<maxlen
                lpi_modified(n,:)=[out{n},zeros(1,(maxlen-length(out{n})))];
            else
                lpi_modified(n,:)=out{n};
            end
        end




