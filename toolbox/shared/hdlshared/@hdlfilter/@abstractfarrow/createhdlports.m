function[entitysigs]=createhdlports(this)





    entitysigs=struct('input',0,...
    'output',0,...
    'fd_input',0);

    bdt=hdlgetparameter('base_data_type');
    hdlsetparameter('filter_target_language',hdlgetparameter('target_language'));

    disp(sprintf('%s',hdlcodegenmsgs(1)));

    hdlentitysignalsinit;

    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');
    inputvtype=inputall.portvtype;
    inputsltype=inputall.portsltype;


    outputall=hdlgetallfromsltype(this.outputSLtype,'outputport');
    outputvtype=outputall.portvtype;
    outputsltype=outputall.portsltype;

    fdall=hdlgetallfromsltype(this.fdSLtype,'inputport');
    fdvtype=fdall.portvtype;
    fdsltype=fdall.portsltype;


    [clkuname,clk]=hdlnewsignal(hdlgetparameter('clockname'),...
    'filter',-1,0,0,bdt,'boolean');
    hdladdinportsignal(clk);
    hdladdclocksignal(clk);
    hdlsetcurrentclock(clk);


    [clkenuname,clken]=hdlnewsignal(hdlgetparameter('clockenablename'),...
    'filter',-1,0,0,bdt,'boolean');
    hdladdinportsignal(clken);
    hdladdclockenablesignal(clken);
    hdlsetcurrentclockenable(clken);

    [rstuname,reset]=hdlnewsignal(hdlgetparameter('resetname'),...
    'filter',-1,0,0,bdt,'boolean');
    hdladdinportsignal(reset);
    hdladdresetsignal(reset);
    hdlsetcurrentreset(reset);
    [inuname,entitysigs.input]=hdlnewsignal(hdlgetparameter('filter_input_name'),...
    'filter',-1,0,0,...
    inputvtype,inputsltype);
    hdladdinportsignal(entitysigs.input);


    [fduname,entitysigs.fd_input]=hdlnewsignal(hdlgetparameter('filter_fracdelay_name'),...
    'filter',-1,0,0,...
    fdvtype,fdsltype);
    hdladdinportsignal(entitysigs.fd_input);

    [outuname,entitysigs.output]=hdlnewsignal(hdlgetparameter('filter_output_name'),...
    'filter',-1,0,0,outputvtype,outputsltype);
    hdladdoutportsignal(entitysigs.output);





