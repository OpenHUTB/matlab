function[entitysigs]=createhdlports(this)





    entitysigs=struct('input',0,...
    'output',0,...
    'ceoutput',0);

    bdt=hdlgetparameter('base_data_type');
    hdlsetparameter('filter_target_language',hdlgetparameter('target_language'));
    castype=getCascadeType(this);
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
    entitysigs.clken=clken;
    [~,reset]=hdlnewsignal(hdlgetparameter('resetname'),...
    'filter',-1,0,0,bdt,'boolean');
    hdladdinportsignal(reset);
    hdladdresetsignal(reset);
    hdlsetcurrentreset(reset);
    [convipportname,convopportname]=getIOPortNames(this);
    innamename=hdlgetparameter('filter_input_name');
    if isempty(innamename)
        innamename=convipportname;
    end
    [~,entitysigs.input]=hdlnewsignal(innamename,...
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
        [~,clk1]=hdlnewsignal([hdlgetparameter('clockname'),'1'],...
        'filter',-1,0,0,...
        bdt,'boolean');
        hdladdinportsignal(clk1);
        hdladdclocksignal(clk1);
        entitysigs.clk1=clk1;
        [~,clken1]=hdlnewsignal([hdlgetparameter('clockenablename'),'1'],...
        'filter',-1,0,0,...
        bdt,'boolean');
        hdladdinportsignal(clken1);
        hdladdclockenablesignal(clken1);
        entitysigs.clken1=clken1;
        [~,reset1]=hdlnewsignal([hdlgetparameter('resetname'),'1'],...
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

    outnamename=hdlgetparameter('filter_output_name');
    if isempty(outnamename)
        outnamename=convopportname;
    end

    [~,entitysigs.output]=hdlnewsignal(outnamename,...
    'filter',-1,this.isOutputPortComplex,0,outputvtype,outputsltype);
    hdladdoutportsignal(entitysigs.output);














    [~,entitysigs.ceoutput]=hdlnewsignal(hdlgetparameter('clockenableoutputname'),...
    'filter',-1,0,0,bdt,'boolean');
    hdladdoutportsignal(entitysigs.ceoutput);

    if strcmpi(this.Implementation,'localmultirate')&&...
        (strcmpi(castype,'singlerate')||strcmpi(castype,'interpolating'))
        [~,entitysigs.ceoutput_datavld]=hdlnewsignal(hdlgetparameter('clockenableoutputvalidname'),...
        'filter',-1,0,0,bdt,'boolean');
        hdladdoutportsignal(entitysigs.ceoutput_datavld);
    end














