function[entitysigs]=createhdlports(this)






    entitysigs=struct('input',0,...
    'output',0,...
    'ceoutput',0);

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



    [~,clk]=hdlnewsignal(hdlgetparameter('clockname'),...
    'filter',-1,0,0,bdt,'boolean');
    hdladdinportsignal(clk);
    hdladdclocksignal(clk);
    hdlsetcurrentclock(clk);


    [~,clken]=hdlnewsignal(hdlgetparameter('clockenablename'),...
    'filter',-1,0,0,bdt,'boolean');
    hdladdinportsignal(clken);
    hdladdclockenablesignal(clken);
    hdlsetcurrentclockenable(clken);

    [~,reset]=hdlnewsignal(hdlgetparameter('resetname'),...
    'filter',-1,0,0,bdt,'boolean');
    hdladdinportsignal(reset);
    hdladdresetsignal(reset);
    hdlsetcurrentreset(reset);
    [~,entitysigs.input]=hdlnewsignal(hdlgetparameter('filter_input_name'),...
    'filter',-1,this.isInputPortComplex,0,...
    inputvtype,inputsltype);
    hdladdinportsignal(entitysigs.input);

    if hdlgetparameter('RateChangePort')
        esigs=createVarRatePorts(this);
        entitysigs.loadenb=esigs.loadenb;
        entitysigs.rate=esigs.rate;
    end

    if hdlgetparameter('clockinputs')==1
        multiclock=0;
    else
        multiclock=1;
    end

    if multiclock==1
        secondclockname=hdlgetparameter('filter_multiclock_portname');
        if isempty(secondclockname)
            secondclockname=[hdlgetparameter('clockname'),'1'];
        end
        [~,clk1]=hdlnewsignal(secondclockname,...
        'filter',-1,0,0,...
        bdt,'boolean');
        hdladdinportsignal(clk1);
        hdladdclocksignal(clk1);
        entitysigs.clk1=clk1;
        secondclockenablename=hdlgetparameter('filter_multiclock_enableportname');
        if isempty(secondclockenablename)
            secondclockenablename=[hdlgetparameter('clockenablename'),'1'];
        end

        [~,clken1]=hdlnewsignal(secondclockenablename,...
        'filter',-1,0,0,...
        bdt,'boolean');
        hdladdinportsignal(clken1);
        hdladdclockenablesignal(clken1);
        entitysigs.clken1=clken1;
        secresetname=hdlgetparameter('filter_multiclock_resetportname');
        if isempty(secresetname)
            secresetname=[hdlgetparameter('resetname'),'1'];
        end
        [~,reset1]=hdlnewsignal(secresetname,...
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

    [~,entitysigs.output]=hdlnewsignal(hdlgetparameter('filter_output_name'),...
    'filter',-1,this.isOutputPortComplex,0,outputvtype,outputsltype);
    hdladdoutportsignal(entitysigs.output);

    if multiclock==0&&hdlgetparameter('filter_generate_ceout')
        [~,entitysigs.ceoutput]=hdlnewsignal(hdlgetparameter('clockenableoutputname'),...
        'filter',-1,0,0,bdt,'boolean');
        hdladdoutportsignal(entitysigs.ceoutput);
    end

    if multiclock==0&&hdlgetparameter('filter_generate_datavalid_output')
        [~,entitysigs.ceoutput_datavld]=hdlnewsignal(hdlgetparameter('clockenableoutputvalidname'),...
        'filter',-1,0,0,bdt,'boolean');
        hdladdoutportsignal(entitysigs.ceoutput_datavld);
    end














