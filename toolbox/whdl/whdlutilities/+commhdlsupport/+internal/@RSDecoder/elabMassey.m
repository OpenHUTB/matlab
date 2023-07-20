function masseyNet=elabMassey(~,topNet,blockInfo,datarate)







    messageLength=double(blockInfo.MessageLength);
    codewordLength=double(blockInfo.CodewordLength);

    primPoly=double(blockInfo.PrimitivePolynomial);

    if strcmp(blockInfo.BSource,'Auto')
        B=1;
    else
        B=double(blockInfo.B);
    end



    if strcmp(blockInfo.PrimitivePolynomialSource,'Auto')
        [~,~,tCorr,tWordSize,tAntiLogTable,tLogTable]=HDLRSGenPoly(codewordLength,messageLength,B);
    else
        [~,~,tCorr,tWordSize,tAntiLogTable,tLogTable]=HDLRSGenPoly(codewordLength,messageLength,B,primPoly);
    end

    wordSize=double(tWordSize);
    corr=double(tCorr);
    alogTable=ufi([uint32(1);tAntiLogTable],wordSize,0);
    logTable=ufi([uint32(0);tLogTable],wordSize,0);



    inType=pir_ufixpt_t(wordSize,0);
    carryType=pir_ufixpt_t(wordSize+1,0);
    countType=pir_ufixpt_t(ceil(log2(2*corr)),0);
    count2Type=pir_ufixpt_t(1+ceil(log2(2*corr)),0);


    inportNames=cell(2*corr+1,1);



    outportNames=cell(2*corr+1,1);


    for ii=1:2*corr
        inportNames{ii}=sprintf('FinalSyndrome%d',ii);
        inTypes(ii)=inType;%#ok
        inDataRate(ii)=datarate;%#ok

        outportNames{ii}=sprintf('errlocpoly%d',ii);
        outTypes(ii)=inType;%#ok

    end
    inportNames{ii+1}='endInDelay3';
    inTypes(ii+1)=pir_ufixpt_t(1,0);
    inDataRate(ii+1)=datarate;

    outportNames{ii+1}='fsmdone';
    outTypes(ii+1)=pir_ufixpt_t(1,0);

    outportNames{ii+2}='errlocpolysub';
    outTypes(ii+2)=countType;

    outportNames{ii+3}='errlocpolylength';
    outTypes(ii+3)=countType;

    masseyNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','masseyNet',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',inDataRate,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );


    for ii=1:2*corr
        finalsyndromereg(ii)=masseyNet.PirInputSignals(ii);%#ok
        errlocpoly(ii)=masseyNet.PirOutputSignals(ii);%#ok
    end
    endInDelay3=masseyNet.PirInputSignals(ii+1);
    fsmdone=masseyNet.PirOutputSignals(ii+1);
    errlocpolysub=masseyNet.PirOutputSignals(ii+2);
    errlocpolylen=masseyNet.PirOutputSignals(ii+3);

    endInDelay4=newControlSignal(masseyNet,'endInDelay4',datarate);
    pirelab.getUnitDelayComp(masseyNet,endInDelay3,endInDelay4);

    endInDelay5=newControlSignal(masseyNet,'endInDelay5',datarate);
    pirelab.getUnitDelayComp(masseyNet,endInDelay4,endInDelay5);

    endInDelay6=newControlSignal(masseyNet,'endInDelay6',datarate);
    pirelab.getUnitDelayComp(masseyNet,endInDelay5,endInDelay6);

    fsmdoneearly=newControlSignal(masseyNet,'fsmdoneearly',datarate);
    correctionadd=newDataSignal(masseyNet,'correctionadd',carryType,datarate);
    correctionslice=newDataSignal(masseyNet,'correctionslice',inType,datarate);
    correctionwrap=newControlSignal(masseyNet,'correctionwrap',datarate);
    correctionreduced=newDataSignal(masseyNet,'correctionreduced',inType,datarate);
    correctionlog=newDataSignal(masseyNet,'correctionlog',inType,datarate);

    holdregen=newControlSignal(masseyNet,'holdregen',datarate);

    fsmrun=newControlSignal(masseyNet,'fsmrun',datarate);
    fsmrunnext=newControlSignal(masseyNet,'fsmrunnext',datarate);
    fsmrunearly=newControlSignal(masseyNet,'fsmrunearly',datarate);
    fsmcontinue=newControlSignal(masseyNet,'fsmcontinue',datarate);
    fsmnotmax=newControlSignal(masseyNet,'fsmnotmax',datarate);
    fsmmax=newControlSignal(masseyNet,'fsmmax',datarate);
    fsmrundelay=newControlSignal(masseyNet,'fsmrundelay',datarate);
    fsmcount=newDataSignal(masseyNet,'fsmcount',countType,datarate);
    fsmonecount=newDataSignal(masseyNet,'fsmonecount',countType,datarate);
    fsmonecountdelay=newDataSignal(masseyNet,'fsmonecountdelay',countType,datarate);
    comparelength=newControlSignal(masseyNet,'comparelength',datarate);
    updatelength=newControlSignal(masseyNet,'updatelength',datarate);

    cpolyen=newControlSignal(masseyNet,'cpolyen',datarate);
    currentshiften=newControlSignal(masseyNet,'currentshiften',datarate);

    lregen=newControlSignal(masseyNet,'lregen',datarate);
    lregshiften=newControlSignal(masseyNet,'lregshiften',datarate);
    lcount=newDataSignal(masseyNet,'lcount',countType,datarate);

    nextlcount=newDataSignal(masseyNet,'nextlcount',countType,datarate);
    lcountsub=newDataSignal(masseyNet,'lcountsub',countType,datarate);
    twolcount=newDataSignal(masseyNet,'twolcount',count2Type,datarate);
    lcountextend=newDataSignal(masseyNet,'lcountextend',count2Type,datarate);
    lcounterrloclen=newDataSignal(masseyNet,'lcounterrloclen',countType,datarate);

    errlocpolylength=newDataSignal(masseyNet,'errlocpolylength',countType,datarate);

    moduloconst=newDataSignal(masseyNet,'moduloconst',inType,datarate);
    pirelab.getConstComp(masseyNet,moduloconst,2.^wordSize-1,'modconst');

    oneconst=newDataSignal(masseyNet,'oneconst',inType,datarate);
    pirelab.getConstComp(masseyNet,oneconst,1,'oneconst');

    zeroconst=newDataSignal(masseyNet,'zeroconst',inType,datarate);
    pirelab.getConstComp(masseyNet,zeroconst,0,'zeroconst');

    onebit=newControlSignal(masseyNet,'onebit',datarate);
    pirelab.getConstComp(masseyNet,onebit,1,'onebitconst');
    zerobit=newControlSignal(masseyNet,'zerobit',datarate);
    pirelab.getConstComp(masseyNet,zerobit,0,'zerobitconst');

    countzero=newDataSignal(masseyNet,'countzero',countType,datarate);
    pirelab.getConstComp(masseyNet,countzero,0,'countzero');

    countone=newDataSignal(masseyNet,'countone',countType,datarate);
    pirelab.getConstComp(masseyNet,countone,1,'countone');

    currentshift=newDataSignal(masseyNet,'currentshift',countType,datarate);
    nextshift=newDataSignal(masseyNet,'nextshift',countType,datarate);
    shiftadd=newDataSignal(masseyNet,'shiftadd',countType,datarate);

    syndromeholdmux=newDataSignal(masseyNet,'syndromeholdmux',inType,datarate);
    synlog=newDataSignal(masseyNet,'synlog',inType,datarate);
    synzero=newControlSignal(masseyNet,'synzero',datarate);

    dvalue=newDataSignal(masseyNet,'dvalue',inType,datarate);
    dvaluelog=newDataSignal(masseyNet,'dvaluelog',inType,datarate);

    valueDDelay=newDataSignal(masseyNet,'valueDDelay',inType,datarate);

    dzero=newControlSignal(masseyNet,'dzero',datarate);
    dnotzero=newControlSignal(masseyNet,'dnotzero',datarate);
    dupdate=newControlSignal(masseyNet,'dupdate',datarate);

    dm=newDataSignal(masseyNet,'dm',inType,datarate);
    dmlog=newDataSignal(masseyNet,'dmlog',inType,datarate);
    dmmux=newDataSignal(masseyNet,'dmmux',inType,datarate);
    dminvlog=newDataSignal(masseyNet,'dminvlog',inType,datarate);
    dminvlogdelay=newDataSignal(masseyNet,'dminvlogdelay',inType,datarate);
    dmzero=newControlSignal(masseyNet,'dmzero',datarate);
    dmone=newControlSignal(masseyNet,'dmone',datarate);

    for ii=1:2*corr
        nextcpoly(ii)=newDataSignal(masseyNet,sprintf('next%dcpoly',ii),inType,datarate);%#ok
        cpoly(ii)=newDataSignal(masseyNet,sprintf('c%dpoly',ii),inType,datarate);%#ok
        cpolydelay(ii)=newDataSignal(masseyNet,sprintf('c%dpolydelay',ii),inType,datarate);%#ok
        cpolylog(ii)=newDataSignal(masseyNet,sprintf('cpolylog%d',ii),inType,datarate);%#ok
        cpolyxor(ii)=newDataSignal(masseyNet,sprintf('cpoly%dxor',ii),inType,datarate);%#ok
        cpolyxordelay(ii)=newDataSignal(masseyNet,sprintf('cpoly%dxordelay',ii),inType,datarate);%#ok


        nextppoly(ii)=newDataSignal(masseyNet,sprintf('next%dppoly',ii),inType,datarate);%#ok
        ppoly(ii)=newDataSignal(masseyNet,sprintf('p%dpoly',ii),inType,datarate);%#ok

        ppolyshift(ii)=newDataSignal(masseyNet,sprintf('p%dpolyshift',ii),inType,datarate);%#ok
        ppolyshiftdelay(ii)=newDataSignal(masseyNet,sprintf('p%dpolyshiftdelay',ii),inType,datarate);%#ok

        ppolyzero(ii)=newControlSignal(masseyNet,sprintf('ppolyzero%d',ii),datarate);%#ok
        ppolylogwrap(ii)=newControlSignal(masseyNet,sprintf('ppolylogwrap%d',ii),datarate);%#ok

        ppolylog(ii)=newDataSignal(masseyNet,sprintf('ppolylog%d',ii),inType,datarate);%#ok
        ppolylogdelay(ii)=newDataSignal(masseyNet,sprintf('ppolylog%ddelay',ii),inType,datarate);%#ok
        ppolylogadd(ii)=newDataSignal(masseyNet,sprintf('ppolylogadd%d',ii),carryType,datarate);%#ok
        ppolylogslice(ii)=newDataSignal(masseyNet,sprintf('ppolylogslice%d',ii),inType,datarate);%#ok
        ppolyreduced(ii)=newDataSignal(masseyNet,sprintf('ppolyreduced%d',ii),inType,datarate);%#ok
        ppolymodresult(ii)=newDataSignal(masseyNet,sprintf('ppolymodresult%d',ii),inType,datarate);%#ok
        ppolyalogout(ii)=newDataSignal(masseyNet,sprintf('ppolyalogout%d',ii),inType,datarate);%#ok
        ppolymulresult(ii)=newDataSignal(masseyNet,sprintf('ppolymulresult%d',ii),inType,datarate);%#ok

        holdin(ii)=newDataSignal(masseyNet,sprintf('holdin%d',ii),inType,datarate);%#ok
        syndromeholdreg(ii)=newDataSignal(masseyNet,sprintf('syndromeholdreg%d',ii),inType,datarate);%#ok
        syndromeshiftreg(ii)=newDataSignal(masseyNet,sprintf('syndromeshiftreg%d',ii),inType,datarate);%#ok
        syndromezeroshiftnext(ii)=newControlSignal(masseyNet,sprintf('syndromezeroshiftnext%d',ii),datarate);%#ok
        syndromezeroshiftreg(ii)=newControlSignal(masseyNet,sprintf('syndromezeroshiftreg%d',ii),datarate);%#ok

        logadd(ii)=newDataSignal(masseyNet,sprintf('logadd%d',ii),carryType,datarate);%#ok
        logslice(ii)=newDataSignal(masseyNet,sprintf('logslice%d',ii),inType,datarate);%#ok
        logaddreduced(ii)=newDataSignal(masseyNet,sprintf('logaddreduced%d',ii),inType,datarate);%#ok
        modresult(ii)=newDataSignal(masseyNet,sprintf('modresult%d',ii),inType,datarate);%#ok
        alogout(ii)=newDataSignal(masseyNet,sprintf('alogout%d',ii),inType,datarate);%#ok
        mulresult(ii)=newDataSignal(masseyNet,sprintf('mulresult%d',ii),inType,datarate);%#ok

        xortree(ii)=newDataSignal(masseyNet,sprintf('xortree%d',ii),inType,datarate);%#ok


        lreg(ii)=newControlSignal(masseyNet,sprintf('lreg%d',ii),datarate);%#ok
        lgreatereq(ii)=newControlSignal(masseyNet,sprintf('lgreatereq%d',ii),datarate);%#ok
        lregmux(ii)=newControlSignal(masseyNet,sprintf('lregmux%d',ii),datarate);%#ok
        lreginv(ii)=newControlSignal(masseyNet,sprintf('lreginv%d',ii),datarate);%#ok

        logwrap(ii)=newControlSignal(masseyNet,sprintf('logwrap%d',ii),datarate);%#ok
        cpolyzero(ii)=newControlSignal(masseyNet,sprintf('cpolyzero%d',ii),datarate);%#ok
        mulzero(ii)=newControlSignal(masseyNet,sprintf('mulzero%d',ii),datarate);%#ok
    end



    shiftvector=[fliplr(ppoly),repmat(zeroconst,1,2*corr)];


    for ii=1:2*corr

        if ii==2*corr
            pirelab.getSwitchComp(masseyNet,[zeroconst,finalsyndromereg(ii)],holdin(ii),endInDelay4,'holdmux1');
        else
            pirelab.getSwitchComp(masseyNet,[syndromeholdreg(ii+1),finalsyndromereg(ii)],holdin(ii),endInDelay4,'holdmux1');
        end
        pirelab.getUnitDelayEnabledComp(masseyNet,holdin(ii),syndromeholdreg(ii),holdregen,...
        'synholdregproc',0.0,'',false);
        if ii==1

            pirelab.getUnitDelayEnabledComp(masseyNet,synlog,syndromeshiftreg(ii),holdregen,...
            'synshiftreg',0.0,'',false);

            pirelab.getCompareToValueComp(masseyNet,syndromeholdmux,synzero,'==',0,'synlogcomp');


            pirelab.getBitwiseOpComp(masseyNet,[fsmrunnext,fsmrun,holdregen],fsmrunearly,'OR');

            pirelab.getBitwiseOpComp(masseyNet,[synzero,fsmrunearly,holdregen],syndromezeroshiftnext(ii),'AND');

            pirelab.getUnitDelayEnabledComp(masseyNet,syndromezeroshiftnext(ii),syndromezeroshiftreg(ii),holdregen,...
            'synzeroshiftreg',0.0,'',false);
            pirelab.getUnitDelayEnabledComp(masseyNet,onebit,lreg(ii),lregen,...
            'lshiftreg',0.0,'',false);

        else
            pirelab.getUnitDelayEnabledComp(masseyNet,syndromeshiftreg(ii-1),syndromeshiftreg(ii),holdregen,...
            'synshiftreg',0.0,'',false);

            pirelab.getBitwiseOpComp(masseyNet,[syndromezeroshiftreg(ii-1),fsmrundelay],syndromezeroshiftnext(ii),'AND');
            pirelab.getUnitDelayEnabledComp(masseyNet,syndromezeroshiftnext(ii),syndromezeroshiftreg(ii),holdregen,...
            'synzeroshiftreg',0.0,'',false);
            pirelab.getCompareToValueComp(masseyNet,nextlcount,lgreatereq(ii),'>=',ii-1);
            pirelab.getSwitchComp(masseyNet,[lgreatereq(ii),zerobit],lregmux(ii),endInDelay4,'lregmux');
            pirelab.getUnitDelayEnabledComp(masseyNet,lregmux(ii),lreg(ii),lregen,...
            'lshiftreg',0.0,'',false);

        end


        pirelab.getDirectLookupComp(masseyNet,cpoly(ii),cpolylog(ii),logTable,'cpolylogtable');
        pirelab.getAddComp(masseyNet,[cpolylog(ii),syndromeshiftreg(ii)],logadd(ii),'Floor','Wrap');
        pirelab.getCompareToValueComp(masseyNet,logadd(ii),logwrap(ii),'>',2.^wordSize-1,'modcompare');
        pirelab.getSubComp(masseyNet,[logadd(ii),moduloconst],logaddreduced(ii),'Floor','Wrap');
        pirelab.getBitSliceComp(masseyNet,logadd(ii),logslice(ii),wordSize-1,0);
        pirelab.getSwitchComp(masseyNet,[logslice(ii),logaddreduced(ii)],modresult(ii),logwrap(ii),'modmux');
        pirelab.getDirectLookupComp(masseyNet,modresult(ii),alogout(ii),alogTable,'alogtable');
        pirelab.getCompareToValueComp(masseyNet,cpoly(ii),cpolyzero(ii),'==',0,'cpolycompare');

        pirelab.getBitwiseOpComp(masseyNet,lreg(ii),lreginv(ii),'NOT');
        pirelab.getBitwiseOpComp(masseyNet,[lreginv(ii),syndromezeroshiftreg(ii),cpolyzero(ii)],mulzero(ii),'OR');
        pirelab.getSwitchComp(masseyNet,[alogout(ii),zeroconst],mulresult(ii),mulzero(ii),'mulzeromux');

        if ii==2*corr
            pirelab.getBitwiseOpComp(masseyNet,[xortree(ii-1),mulresult(ii)],dvalue,'XOR');
        elseif ii==1

        elseif ii==2
            pirelab.getBitwiseOpComp(masseyNet,[mulresult(ii-1),mulresult(ii)],xortree(ii),'XOR');
        else
            pirelab.getBitwiseOpComp(masseyNet,[xortree(ii-1),mulresult(ii)],xortree(ii),'XOR');
        end




        pirelab.getUnitDelayEnabledComp(masseyNet,nextcpoly(ii),cpoly(ii),cpolyen,...
        'cpolyreg',0.0,'',false);

        pirelab.getUnitDelayEnabledComp(masseyNet,nextppoly(ii),ppoly(ii),lregen,...
        'ppolyreg',0.0,'',false);


        pirelab.getUnitDelayEnabledComp(masseyNet,cpoly(ii),errlocpoly(ii),fsmdone,...
        'errlocpolyreg',0.0,'',false);

        if ii==1
            pirelab.getSwitchComp(masseyNet,[cpolyxor(ii),oneconst],nextcpoly(ii),endInDelay4,'cpolymux');
            pirelab.getSwitchComp(masseyNet,[cpoly(ii),oneconst],nextppoly(ii),endInDelay4,'ppolymux');
        elseif ii==2
            pirelab.getSwitchComp(masseyNet,[cpolyxor(ii),zeroconst],nextcpoly(ii),endInDelay4,'cpolymux');
            pirelab.getSwitchComp(masseyNet,[cpoly(ii),zeroconst],nextppoly(ii),endInDelay4,'ppolymux');
        else
            pirelab.getSwitchComp(masseyNet,[cpolyxor(ii),zeroconst],nextcpoly(ii),endInDelay4,'cpolymux');
            pirelab.getSwitchComp(masseyNet,[cpoly(ii),zeroconst],nextppoly(ii),endInDelay4,'ppolymux');
        end






        startIndex=2*corr-ii+2;
        pirelab.getMultiPortSwitchComp(masseyNet,[currentshift,shiftvector(startIndex:startIndex+2*corr-1)],...
        ppolyshift(ii),...
        1,1,'floor','Wrap','ppolyshiftmux');
        pirelab.getUnitDelayComp(masseyNet,ppolyshift(ii),ppolyshiftdelay(ii));
        insig=ppolyshift(ii);
        pirelab.getDirectLookupComp(masseyNet,insig,ppolylog(ii),logTable,'ppolylogtable');
        pirelab.getUnitDelayComp(masseyNet,ppolylog(ii),ppolylogdelay(ii));
        pirelab.getAddComp(masseyNet,[ppolylogdelay(ii),correctionlog],ppolylogadd(ii),'Floor','Wrap');
        pirelab.getCompareToValueComp(masseyNet,ppolylogadd(ii),ppolylogwrap(ii),'>',2.^wordSize-1,'ppolymodcompare');
        pirelab.getSubComp(masseyNet,[ppolylogadd(ii),moduloconst],ppolyreduced(ii),'Floor','Wrap');
        pirelab.getBitSliceComp(masseyNet,ppolylogadd(ii),ppolylogslice(ii),wordSize-1,0);
        pirelab.getSwitchComp(masseyNet,[ppolylogslice(ii),ppolyreduced(ii)],ppolymodresult(ii),ppolylogwrap(ii),'ppolymodmux');
        pirelab.getDirectLookupComp(masseyNet,ppolymodresult(ii),ppolyalogout(ii),alogTable,'ppolyalogtable');
        pirelab.getCompareToValueComp(masseyNet,ppolyshiftdelay(ii),ppolyzero(ii),'==',0,'ppolycompare');
        pirelab.getSwitchComp(masseyNet,[ppolyalogout(ii),zeroconst],ppolymulresult(ii),ppolyzero(ii),'ppolymulzeromux');

        pirelab.getUnitDelayComp(masseyNet,cpoly(ii),cpolydelay(ii));
        pirelab.getBitwiseOpComp(masseyNet,[cpolydelay(ii),ppolymulresult(ii)],cpolyxor(ii),'XOR');

    end
    pirelab.getUnitDelayComp(masseyNet,dvalue,valueDDelay);

    pirelab.getUnitDelayEnabledComp(masseyNet,dmmux,dm,lregen,'dmreg',0.0,'',false);
    pirelab.getSwitchComp(masseyNet,[valueDDelay,oneconst],dmmux,endInDelay4,'dmmuxcomp');

    pirelab.getCompareToValueComp(masseyNet,valueDDelay,dzero,'==',0,'dcompare');
    pirelab.getCompareToValueComp(masseyNet,valueDDelay,dnotzero,'~=',0,'dnotcompare');
    pirelab.getDirectLookupComp(masseyNet,valueDDelay,dvaluelog,logTable,'dvaluelogtable');

    pirelab.getCompareToValueComp(masseyNet,dm,dmzero,'==',0,'dmcompare');
    pirelab.getCompareToValueComp(masseyNet,dm,dmone,'==',1,'dmcompare2');
    pirelab.getDirectLookupComp(masseyNet,dm,dmlog,logTable,'synlogtable');
    pirelab.getSubComp(masseyNet,[moduloconst,dmlog],dminvlog,'Floor','Wrap');

    pirelab.getBitwiseOpComp(masseyNet,[fsmrundelay,dnotzero],dupdate,'AND');
    pirelab.getBitwiseOpComp(masseyNet,[endInDelay4,fsmrundelay],holdregen,'OR');

    pirelab.getBitwiseOpComp(masseyNet,[endInDelay4,dupdate],cpolyen,'OR');
    lcountswitchen=newControlSignal(masseyNet,'lcountswitchen',datarate);

    pirelab.getBitwiseOpComp(masseyNet,[endInDelay4,updatelength],lregen,'OR');

    pirelab.getUnitDelayComp(masseyNet,fsmonecount,fsmonecountdelay);

    pirelab.getRelOpComp(masseyNet,[twolcount,fsmonecountdelay],comparelength,'<');
    pirelab.getBitwiseOpComp(masseyNet,[dupdate,comparelength],updatelength,'AND');



    lregenxor=newControlSignal(masseyNet,'lregenxor',datarate);

    notenddelay6=newControlSignal(masseyNet,'notenddelay6',datarate);

    pirelab.getBitwiseOpComp(masseyNet,[endInDelay3,endInDelay4],lcountswitchen,'OR');

    pirelab.getBitwiseOpComp(masseyNet,endInDelay6,notenddelay6,'NOT');
    pirelab.getBitwiseOpComp(masseyNet,[lregshiften,notenddelay6],lregenxor,'AND');


    pirelab.getBitwiseOpComp(masseyNet,[lregen,endInDelay5],lregshiften,'OR');


    pirelab.getUnitDelayEnabledComp(masseyNet,lcounterrloclen,errlocpolylength,...
    fsmdone,'errlocpolylenreg',0.0,'',false);




    pirelab.getDTCComp(masseyNet,errlocpolylength,errlocpolylen);

    pirelab.getSubComp(masseyNet,[errlocpolylength,countone],errlocpolysub,'Floor','Wrap');



    pirelab.getUnitDelayEnabledComp(masseyNet,nextlcount,lcount,lregen,...
    'lcountreg',0.0,'',false);

    pirelab.getUnitDelayEnabledComp(masseyNet,nextlcount,lcounterrloclen,lregen,...
    'lcountreg1',0.0,'',false);

    pirelab.getDTCComp(masseyNet,lcount,lcountextend,'Floor','Wrap');

    pirelab.getBitShiftComp(masseyNet,lcountextend,twolcount,'sll',1);

    pirelab.getBitwiseOpComp(masseyNet,[cpolyen,dzero],currentshiften,'OR');

    pirelab.getUnitDelayEnabledComp(masseyNet,nextshift,currentshift,currentshiften,...
    'currentshiftreg',0.0,'',false);
    pirelab.getAddComp(masseyNet,[currentshift,countone],shiftadd,'Floor','Wrap');
    pirelab.getSwitchComp(masseyNet,[shiftadd,countzero],nextshift,lregshiften,'shiftmux');

    pirelab.getAddComp(masseyNet,[fsmcount,countone],fsmonecount,'Floor','Wrap');
    fsmonecountdelay=newDataSignal(masseyNet,'fsmonecountdelay',countType,datarate);
    pirelab.getUnitDelayComp(masseyNet,fsmonecount,fsmonecountdelay);
    pirelab.getSubComp(masseyNet,[fsmonecountdelay,lcount],lcountsub,'Floor','Wrap');
    pirelab.getSwitchComp(masseyNet,[lcountsub,countzero],nextlcount,endInDelay4,'lcountmux');


    pirelab.getSwitchComp(masseyNet,[syndromeholdreg(2),finalsyndromereg(1)],syndromeholdmux,endInDelay4,'synholdmux');
    pirelab.getDirectLookupComp(masseyNet,syndromeholdmux,synlog,logTable,'synlogtable');


    pirelab.getUnitDelayComp(masseyNet,dminvlog,dminvlogdelay);
    pirelab.getAddComp(masseyNet,[dvaluelog,dminvlogdelay],correctionadd,'Floor','Wrap');
    pirelab.getCompareToValueComp(masseyNet,correctionadd,correctionwrap,'>',2.^wordSize-1,'modcomparecorrection');
    pirelab.getBitSliceComp(masseyNet,correctionadd,correctionslice,wordSize-1,0);
    pirelab.getSubComp(masseyNet,[correctionadd,moduloconst],correctionreduced,'Floor','Wrap');
    pirelab.getSwitchComp(masseyNet,[correctionslice,correctionreduced],correctionlog,correctionwrap,'modmux');

    enbCtrl=newControlSignal(masseyNet,'enbCtrl',datarate);
    fsmruntemp=newControlSignal(masseyNet,'fsmruntemp',datarate);
    fsmmaxtemp=newControlSignal(masseyNet,'fsmmaxtemp',datarate);




    toggleCount=newControlSignal(masseyNet,'toggleCount',datarate);
    oneconst1=newControlSignal(masseyNet,'oneconst1',datarate);
    pirelab.getConstComp(masseyNet,oneconst1,1,'oneconst1');

    pirelab.getCounterComp(masseyNet,[endInDelay4,oneconst1,oneconst1],toggleCount,...
    'Count limited',...
    0.0,...
    1.0,...
    1,...
    false,...
    true,...
    true,...
    false,...
    'togglecount');
    pirelab.getCompareToValueComp(masseyNet,toggleCount,enbCtrl,'==',1,'togglecountproc');

    pirelab.getUnitDelayComp(masseyNet,fsmrunnext,fsmruntemp,'fsmrunreg',0.0);

    pirelab.getBitwiseOpComp(masseyNet,[fsmruntemp,enbCtrl],fsmrun,'AND');
    pirelab.getCounterComp(masseyNet,fsmrun,fsmcount,...
    'Count limited',...
    0.0,...
    1.0,...
    2*corr-1,...
    false,...
    false,...
    true,...
    false,...
    'fsmcountproc');
    pirelab.getCompareToValueComp(masseyNet,fsmcount,fsmmaxtemp,'==',2*corr-1,'fsmmaxproc');
    pirelab.getBitwiseOpComp(masseyNet,[fsmmaxtemp,enbCtrl],fsmmax,'AND');

    pirelab.getBitwiseOpComp(masseyNet,[fsmruntemp,fsmnotmax],fsmcontinue,'AND');
    pirelab.getBitwiseOpComp(masseyNet,[endInDelay4,fsmcontinue],fsmrunnext,'OR');
    pirelab.getBitwiseOpComp(masseyNet,fsmmax,fsmnotmax,'NOT');
    pirelab.getUnitDelayComp(masseyNet,fsmmax,fsmdoneearly,'fsmrunreg',0.0);

    pirelab.getUnitDelayComp(masseyNet,fsmrun,fsmrundelay,'fsmrundelayreg',0.0);
    pirelab.getUnitDelayComp(masseyNet,fsmdoneearly,fsmdone,'fsmdonedelayreg',0.0);
end

function signal=newControlSignal(masseyNet,name,rate)
    controlType=pir_ufixpt_t(1,0);
    signal=masseyNet.addSignal(controlType,name);
    signal.SimulinkRate=rate;
end

function signal=newDataSignal(masseyNet,name,inType,rate)
    signal=masseyNet.addSignal(inType,name);
    signal.SimulinkRate=rate;
end