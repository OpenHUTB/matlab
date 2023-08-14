function[conv_output,hdl_arch]=emit_shiftOutputVarRate(this,current_input,ratereg,maxrate)






    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    complexity=this.isInputPortComplex;

    outputall=hdlgetallfromsltype(this.outputSLtype,'outputport');
    outregvtype=outputall.vtype;
    outregsltype=outputall.sltype;


    rates=1:maxrate;
    bitgain=ceil(this.NumberOfSections*log2(rates));
    maxbitgain=max(bitgain);
    bits_bitgain=ceil(log2(maxbitgain+1));
    [lktopvtype,lktopsltype]=hdlgettypesfromsizes(bits_bitgain,0,0);
    [~,lktopsig]=hdlnewsignal('bitgain','filter',...
    -1,0,0,lktopvtype,lktopsltype);

    [lktbody,lktsignals]=hdllookuptable(ratereg,lktopsig,rates,bitgain);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(lktopsig),lktsignals];

    hdl_arch.body_blocks=[hdl_arch.body_blocks,lktbody];


    [~,conv_output]=hdlnewsignal('output_typeconvert','filter',-1,complexity,0,...
    outregvtype,outregsltype);
    hdl_arch.signals=[hdl_arch.signals,...
    makehdlsignaldecl(conv_output)];


    uniq_bg=unique(bitgain);
    lpcnt=1;
    muxinputbody=[];
    muxinputsignals=[];
    muxinsigs=zeros(1,length(uniq_bg));
    for bg=uniq_bg
        [muxvtype,muxsltype]=hdlgettypesfromsizes(outputall.size,outputall.bp-bg,1);
        [~,muxinsigs(lpcnt)]=hdlnewsignal(['muxinput_',num2str(bg)],'filter',...
        -1,complexity,0,muxvtype,muxsltype);
        muxinputsignals=[muxinputsignals,makehdlsignaldecl(muxinsigs(lpcnt))];
        muxinputbody=[muxinputbody,...
        hdldatatypeassignment(current_input,muxinsigs(lpcnt),'floor',0)];
        lpcnt=lpcnt+1;
    end
    hdl_arch.signals=[hdl_arch.signals,muxinputsignals];
    muxbody=hdlmux(muxinsigs,conv_output,lktopsig,{'='},uniq_bg,'when-else');
    hdl_arch.body_blocks=[hdl_arch.body_blocks,muxinputbody,muxbody];


