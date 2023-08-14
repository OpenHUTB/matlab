function entitysigs=createhdlports(this)






    entitysigs=struct('input',0,...
    'output',0,...
    'cein_output',0,...
    'ceout_output',0);

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
    'filter',-1,this.isInputPortComplex,0,...
    inputvtype,inputsltype);
    hdladdinportsignal(entitysigs.input);

    [outuname,entitysigs.output]=hdlnewsignal(hdlgetparameter('filter_output_name'),...
    'filter',-1,this.isOutputPortComplex,0,outputvtype,outputsltype);
    hdladdoutportsignal(entitysigs.output);


    if hdlgetparameter('clockinputs')==1
        multiclock=0;
    else
        multiclock=1;
    end

    if multiclock==1
        [clk1uname,clk1]=hdlnewsignal([hdlgetparameter('clockname'),'1'],...
        'filter',-1,0,0,...
        bdt,'boolean');
        hdladdinportsignal(clk1);
        hdladdclocksignal(clk1);
        entitysigs.clk1=clk1;
        [clken1uname,clken1]=hdlnewsignal([hdlgetparameter('clockenablename'),'1'],...
        'filter',-1,0,0,...
        bdt,'boolean');
        hdladdinportsignal(clken1);
        hdladdclockenablesignal(clken1);
        entitysigs.clken1=clken1;
        [rst1uname,reset1]=hdlnewsignal([hdlgetparameter('resetname'),'1'],...
        'filter',-1,0,0,...
        bdt,'boolean');
        hdladdinportsignal(reset1);
        hdladdresetsignal(reset1);
        entitysigs.reset1=reset1;
    else
        entitysigs.clk1=0;
        entitysigs.clken1=0;
        entitysigs.reset1=0;
    end

    if multiclock==0
        [outuname,entitysigs.cein_output]=hdlnewsignal(hdlgetparameter('clockenableinputname'),...
        'filter',-1,0,0,bdt,'boolean');
        hdladdoutportsignal(entitysigs.cein_output);
        [outuname,entitysigs.ceout_output]=hdlnewsignal(hdlgetparameter('clockenableoutputname'),...
        'filter',-1,0,0,bdt,'boolean');
        hdladdoutportsignal(entitysigs.ceout_output);
    end

