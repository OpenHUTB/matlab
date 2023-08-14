function createtbportlist(this)





    disp(sprintf('%s',hdlcodegenmsgs(1)));

    hdlentitysignalsinit;
    bdt=hdlgetparameter('base_data_type');

    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');

    inputvtype=inputall.portvtype;
    inputsltype=inputall.portsltype;


    outputall=hdlgetallfromsltype(this.outputSLtype,'outputport');

    outputvtype=outputall.portvtype;
    outputsltype=outputall.portsltype;

    [convipportname,convopportname]=getIOPortNames(this);


    hdlnewsignal(hdlgetparameter('clockname'),...
    'filter',-1,0,0,bdt,'boolean');


    hdlnewsignal(hdlgetparameter('clockenablename'),...
    'filter',-1,0,0,bdt,'boolean');

    hdlnewsignal(hdlgetparameter('resetname'),...
    'filter',-1,0,0,bdt,'boolean');


    hdlnewsignal(convipportname,...
    'filter',-1,this.isInputPortComplex,0,...
    inputvtype,inputsltype);


    if hdlgetparameter('RateChangePort')
        esigs=createVarRatePorts(this);
        entitysigs.loadenb=esigs.loadenb;
        entitysigs.rate=esigs.rate;
    end

    hdllastinputsignal;
    if hdlgetparameter('clockinputs')==1
        multiclock=0;
    else
        multiclock=1;
    end

















    hdlnewsignal(convopportname,...
    'filter',-1,this.isOutputPortComplex,0,outputvtype,outputsltype);


    if multiclock==0&&hdlgetparameter('filter_generate_ceout')
        hdlnewsignal(hdlgetparameter('clockenableoutputname'),...
        'filter',-1,0,0,bdt,'boolean');
    end

    if multiclock==0&&hdlgetparameter('filter_generate_datavalid_output')
        hdlnewsignal(hdlgetparameter('clockenableoutputvalidname'),...
        'filter',-1,0,0,bdt,'boolean');
    end
    if strcmpi(this.Implementation,'localmultirate')&&...
        strcmpi(this.getCascadeType,'interpolating')
        ceoutvldname=hdlgetparameter('clockenableoutputvalidname');
        if isempty(ceoutvldname)
            ceoutvldname='ce_valid';
        end
        hdlnewsignal(ceoutvldname,'filter',-1,0,0,bdt,'boolean');
    end
    hdllastoutputsignal;

