function[hdl_arch,preaddlist]=emit_par_preadd(this,delayline,coeffs,sym)





    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    firlen=length(coeffs);
    halflen=floor(firlen/2);
    oddtaps=mod(firlen,2);
    if strcmpi(this.implementation,'parallel')
        cplxity=this.isInputPortComplex;
    else
        cplxity=0;
    end
    if strcmpi(this.InputSLType,'double')

        tapsumvtype='real';
        tapsumsltype='double';
    else
        [inputsize,inputbp,inputsigned]=hdlgetsizesfromtype(this.InputSLType);
        tapsumsize=inputsize+1;
        tapsumbp=inputbp;
        tapsumsigned=inputsigned;
        [tapsumvtype,tapsumsltype]=hdlgettypesfromsizes(tapsumsize,tapsumbp,tapsumsigned);
    end

    preaddlist=[];
    count=1;
    for tap=1:halflen
        coeffn=coeffs(tap);
        if coeffn~=0
            [~,sumout]=hdlnewsignal(['tapsum',num2str(count)],'filter',-1,cplxity,0,...
            tapsumvtype,tapsumsltype);

            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(sumout)];

            input1=delayline(tap);
            input2=delayline(firlen-(tap-1));
            output=sumout;


            [tempbody,tempsignals]=gettapsumout(this,input1,input2,output,sym);

            hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
            hdl_arch.signals=[hdl_arch.signals,tempsignals];

            [hdl_arch,castsumout]=cast_tapsum(this,hdl_arch,sumout);
        else
            castsumout=0;
        end
        preaddlist=[preaddlist,castsumout];
        count=count+1;
    end
    if oddtaps==1
        preaddlist=[preaddlist,delayline(halflen+1)];
    end





