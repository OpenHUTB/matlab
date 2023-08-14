function[wiringbody,wiringsignals,wiringbodyassignments]=emit_topwiring(this,inputreg,...
    ncoouttoprod,finsignal,foutsignal,clkenboutsignal,entitysigs,~)



    wiringbody='';
    wiringsignals='';




    inputall=hdlgetallfromsltype(this.InputSLType);
    ncoall=hdlgetallfromsltype(this.NCO.Oscillator.outputsLType);
    productsltype=hdlgetsltypefromsizes(inputall.size+ncoall.size,inputall.bp+ncoall.bp,1);
    accumsltype=hdlgetsltypefromsizes(inputall.size+ncoall.size+1,inputall.bp+ncoall.bp,1);
    outrounding='nearest';
    outsaturation=0;


    [multbody,mixersignals,mixertempsigs,mixeroutsig]=...
    emit_mixer(this,inputreg,ncoouttoprod,productsltype,accumsltype);


    filtersinall=hdlgetallfromsltype(this.FiltersCastSLtype);
    [~,mixeroutcastsig]=hdlnewsignal('mixer_out_cast','filter',-1,hdlsignaliscomplex(mixeroutsig),0,filtersinall.vtype,filtersinall.sltype);
    mixercastbody=hdldatatypeassignment(mixeroutsig,mixeroutcastsig,outrounding,outsaturation);
    wiringbody=[wiringbody,multbody,mixercastbody];

    wiringsignals=[wiringsignals,...
    mixersignals,...
    mixertempsigs,...
    makehdlsignaldecl(mixeroutcastsig)];


    [tempbody,tempsignals]=hdlfinalassignment(mixeroutcastsig,finsignal);

    [outputarch]=emit_output(this,foutsignal,clkenboutsignal,entitysigs);

    wiringsignals=[wiringsignals,tempsignals,outputarch.signals];
    wiringbody=[wiringbody,tempbody,outputarch.body_blocks];
    wiringbodyassignments=outputarch.body_output_assignments;

