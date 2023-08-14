function[entitysigs]=createhdlports(this)










    emitMode=isempty(pirNetworkForFilterComp);

    if hdlgetparameter('clockinputs')==1
        multiclock=0;
    else
        multiclock=1;
    end

    coeffs_internal=strcmpi(hdlgetparameter('filter_coefficient_source'),'internal');
    coeffs_port=hdlgetparameter('filter_generate_coeff_port');

    entitysigs=struct('input',0,...
    'output',0,...
    'wrenb',0,...
    'coeffs',0,...
    'wraddr',0,...
    'wrdone',0);

    bdt=hdlgetparameter('base_data_type');
    hdlsetparameter('filter_target_language',hdlgetparameter('target_language'));

    if emitMode
        hdlentitysignalsinit;

        fprintf('%s\n',hdlcodegenmsgs(1));


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

    end



    entitysigs=createInputOutputPorts(this,entitysigs);




    if emitMode&&~coeffs_internal
        entitysigs=create_procint_extra_ports(this,entitysigs);
    end


    if multiclock==0&&hdlgetparameter('filter_generate_datavalid_output')
        [~,entitysigs.ceoutput_datavld]=hdlnewsignal(hdlgetparameter('clockenableoutputvalidname'),...
        'filter',-1,0,0,bdt,'boolean');
        hdladdoutportsignal(entitysigs.ceoutput_datavld);
    end


    if coeffs_port
        entitysigs=createCoeffPorts(this,entitysigs);
    end
