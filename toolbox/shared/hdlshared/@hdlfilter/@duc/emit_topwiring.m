function[wiringbody,wiringsignals,wiringbodyassignments]=emit_topwiring(this,inputreg,...
    ncoouttoprod,finsignal,foutsignal,clkenboutsignal,entitysigs,fclkvalidsignal)



    wiringbody='';
    wiringsignals='';


    [tempbody,tempsignals]=hdlfinalassignment(inputreg,finsignal);
    wiringbody=[wiringbody,tempbody];
    wiringsignals=[wiringsignals,tempsignals];



    filtersoutsltype=this.FiltersCastSLtype;

    filtersoutall=hdlgetallfromsltype(filtersoutsltype);
    ncoall=hdlgetallfromsltype(this.NCO.Oscillator.outputsLType);
    productsltype=hdlgetsltypefromsizes(filtersoutall.size+ncoall.size,filtersoutall.bp+ncoall.bp,1);
    accumsltype=hdlgetsltypefromsizes(filtersoutall.size+ncoall.size+1,filtersoutall.bp+ncoall.bp,1);
    outrounding='nearest';
    outsaturation=1;





    foutregname=[hdlsignalname(foutsignal),'_reg'];

    [~,foutputreg]=hdlnewsignal(foutregname,'filter',-1,...
    hdlsignaliscomplex(foutsignal),0,filtersoutall.vtype,filtersoutall.sltype);
    hdlregsignal(foutputreg);
    [tempbody,tempsignals]=hdlunitdelay(foutsignal,foutputreg,...
    ['Filters_Output_Register',hdlgetparameter('clock_process_label')],0);
    wiringbody=[wiringbody,tempbody];
    wiringsignals=[wiringsignals,...
    makehdlsignaldecl(foutputreg),...
    tempsignals];

    [multbody,mixersignals,mixertempsigs,mixeroutsig]=...
    emit_mixer(this,foutputreg,ncoouttoprod,productsltype,accumsltype);

    wiringbody=[wiringbody,multbody];

    wiringsignals=[wiringsignals,...
    mixersignals,...
    mixertempsigs];


    outputtype=this.OutputSLtype;
    outputall=hdlgetallfromsltype(outputtype);
    [~,mixeroutcastsig]=hdlnewsignal('mixer_out_cast','filter',-1,...
    this.isOutputPortComplex,0,outputall.vtype,outputall.sltype);
    wiringsignals=[wiringsignals,makehdlsignaldecl(mixeroutcastsig)];
    fcastbody=hdldatatypeassignment(mixeroutsig,mixeroutcastsig,outrounding,outsaturation);
    wiringbody=[wiringbody,fcastbody];


    [outputarch]=emit_output(this,mixeroutcastsig,clkenboutsignal,entitysigs,...
    fclkvalidsignal);

    wiringsignals=[wiringsignals,tempsignals,outputarch.signals];
    wiringbody=[wiringbody,outputarch.body_blocks];
    wiringbodyassignments=outputarch.body_output_assignments;

