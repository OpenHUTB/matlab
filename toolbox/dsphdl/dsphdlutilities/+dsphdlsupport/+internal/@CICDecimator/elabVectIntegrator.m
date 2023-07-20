function iSection=elabVectIntegrator(~,hTopN,blockInfo,slRate,dataInreg,validInreg,internalReset,...
    integOut_re,integOut_im,i_vout,i_rstout)





    in1=dataInreg;
    in2=validInreg;
    in3=internalReset;

    out1=integOut_re;
    out2=integOut_im;
    out3=i_vout;
    out4=i_rstout;

    sfixTypeN=[];
    for i=1:blockInfo.NumSections
        sfixTypeN=[sfixTypeN,pir_sfixpt_t(blockInfo.stageDT{i}.WordLength,blockInfo.stageDT{i}.FractionLength)];
    end
    dTypeN=[];
    for i=1:blockInfo.NumSections
        dTypeN=[dTypeN,pirelab.getPirVectorType(sfixTypeN(i),blockInfo.vecsize)];
    end


    iSection=pirelab.createNewNetwork(...
    'Network',hTopN,...
    'Name','iSection',...
    'InportNames',{'dataInreg','validInreg','internalReset'},...
    'InportTypes',[in1.Type,in2.Type,in3.Type],...
    'Inportrates',[slRate,slRate,slRate],...
    'OutportNames',{'integOut_re','integOut_im','i_vout','i_rstout'},...
    'OutportTypes',[out1.Type,out2.Type,out3.Type,out4.Type]...
    );


    dataInreg=iSection.PirInputSignals(1);
    validInreg=iSection.PirInputSignals(2);
    internalReset=iSection.PirInputSignals(3);

    integOut_re=iSection.PirOutputSignals(1);
    integOut_im=iSection.PirOutputSignals(2);
    i_vout=iSection.PirOutputSignals(3);
    i_rstout=iSection.PirOutputSignals(4);


    for i=1:blockInfo.vecsize
        iIn_re(i)=iSection.addSignal(pir_sfixpt_t(blockInfo.dlen,blockInfo.flen),['iIn_re',num2str(i)]);
        iIn_re(i).SimulinkRate=slRate;
        iIn_im(i)=iSection.addSignal(pir_sfixpt_t(blockInfo.dlen,blockInfo.flen),['iIn_im',num2str(i)]);
        iIn_im(i).SimulinkRate=slRate;

        iIn_re1(i)=iSection.addSignal(pir_sfixpt_t(blockInfo.dlen,blockInfo.flen),['iIn_re',num2str(i)]);
        iIn_re1(i).SimulinkRate=slRate;
        iIn_im1(i)=iSection.addSignal(pir_sfixpt_t(blockInfo.dlen,blockInfo.flen),['iIn_im',num2str(i)]);
        iIn_im1(i).SimulinkRate=slRate;

        dataInreg_cast(i)=iSection.addSignal2('Type',pir_complex_t(pir_sfixpt_t(blockInfo.dlen,blockInfo.flen)),'Name','dataInreg_cast');%#ok<*AGROW>
        dataInreg_cast(i).SimulinkRate=slRate;
        din_re(i)=iSection.addSignal(pir_sfixpt_t(blockInfo.dlen,blockInfo.flen),'din_re');
        din_re(i).SimulinkRate=slRate;
        din_im(i)=iSection.addSignal(pir_sfixpt_t(blockInfo.dlen,blockInfo.flen),'din_im');
        din_im(i).SimulinkRate=slRate;
        pirelab.getDTCComp(iSection,dataInreg.split.PirOutputSignals(i),dataInreg_cast(i));
        pirelab.getComplex2RealImag(iSection,dataInreg_cast(i),[din_re(i),din_im(i)],'real and img');
        pirelab.getDTCComp(iSection,din_re(i),iIn_re(i),'Floor','Wrap');
        pirelab.getDTCComp(iSection,din_im(i),iIn_im(i),'Floor','Wrap');
    end


    ioutWL=integOut_re.Type.BaseType.WordLength;
    ioutFL=integOut_re.Type.BaseType.FractionLength;
    stage1WL=dTypeN(1).BaseType.WordLength;
    stage1FL=dTypeN(1).BaseType.FractionLength;
    for i=1:blockInfo.vecsize
        iOutreg_re(i)=iSection.addSignal(pir_sfixpt_t(ioutWL,ioutFL),['iOutreg_re',num2str(i)]);
        iOutreg_re(i).SimulinkRate=slRate;
        iOutreg_im(i)=iSection.addSignal(pir_sfixpt_t(ioutWL,ioutFL),['iOutreg_im',num2str(i)]);
        iOutreg_im(i).SimulinkRate=slRate;
        iOut_re(i)=iSection.addSignal(pir_sfixpt_t(ioutWL,ioutFL),['iOut_re',num2str(i)]);
        iOut_re(i).SimulinkRate=slRate;
        iOut_im(i)=iSection.addSignal(pir_sfixpt_t(ioutWL,ioutFL),['iOut_im',num2str(i)]);
        iOut_im(i).SimulinkRate=slRate;
    end %#ok<*AGROW>


    i_voutreg=iSection.addSignal(out3.Type,'i_voutreg');
    i_rstoutreg=iSection.addSignal(out3.Type,'i_rstoutreg');

    dtype=pir_sfixpt_t(blockInfo.dlen,blockInfo.flen);
    dvtype=pirelab.getPirVectorType(dtype,blockInfo.vecsize);


    inmuxre=iSection.addSignal(dvtype,'inmuxre');
    inmuxim=iSection.addSignal(dvtype,'inmuxim');
    inbufferre=iSection.addSignal(dvtype,'inbufferre');
    inbufferim=iSection.addSignal(dvtype,'inbufferim');
    pirelab.getMuxComp(iSection,iIn_re(1:end),inmuxre);
    pirelab.getMuxComp(iSection,iIn_im(1:end),inmuxim);

    Nsec=blockInfo.NumSections;
    VecSize=blockInfo.vecsize;
    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal',...
    '@CICDecimator','cgireml','inputBuffer1.m'),'r');
    inbuff_0=fread(fid,Inf,'char=>char');
    fclose(fid);
    iSection.addComponent2(...
    'kind','cgireml',...
    'Name','inputBuffer1',...
    'InputSignals',[inmuxre,validInreg,internalReset],...
    'OutputSignals',inbufferre,...
    'EMLFileName','inputBuffer1',...
    'EMLFileBody',inbuff_0,...
    'EmlParams',{Nsec,VecSize},...
    'EMLFlag_TreatInputIntsAsFixpt',true);
    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
    '@CICDecimator','cgireml','inputBuffer2.m'),'r');
    inbuff_1=fread(fid,Inf,'char=>char');
    fclose(fid);
    iSection.addComponent2(...
    'kind','cgireml',...
    'Name','inputBuffer2',...
    'InputSignals',[inmuxim,validInreg,internalReset],...
    'OutputSignals',inbufferim,...
    'EMLFileName','inputBuffer2',...
    'EMLFileBody',inbuff_1,...
    'EmlParams',{Nsec,VecSize},...
    'EMLFlag_TreatInputIntsAsFixpt',true);


    inmuxoutre=[];
    for i=1:blockInfo.vecsize
        dins(i)=iSection.addSignal(dtype,['inmuxoutre',num2str(i)]);%#ok<*AGROW>
        inmuxoutre=[inmuxoutre,dins(i)];
    end

    inmuxoutim=[];
    for i=1:blockInfo.vecsize
        dins(i)=iSection.addSignal(dtype,['inmuxoutre',num2str(i)]);%#ok<*AGROW>
        inmuxoutim=[inmuxoutim,dins(i)];
    end

    pirelab.getDemuxComp(iSection,inbufferre,inmuxoutre);
    pirelab.getDemuxComp(iSection,inbufferim,inmuxoutim);




    switch blockInfo.NumSections
    case 1
        for i=1:blockInfo.vecsize

            for j=1:blockInfo.vecsize
                addOutregN1_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['addOutregN1_re_',num2str(i),'_',num2str(j)]);
                addOutregN1_re(i,j).SimulinkRate=slRate;
                addOutregN1_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['addOutregN1_im_',num2str(i),'_',num2str(j)]);
                addOutregN1_im(i,j).SimulinkRate=slRate;
                addOutregN1out_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['addOutregN1out_re_',num2str(i),'_',num2str(j)]);
                addOutregN1out_re(i,j).SimulinkRate=slRate;
                addOutregN1out_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['addOutregN1out_im_',num2str(i),'_',num2str(j)]);
                addOutregN1out_im(i,j).SimulinkRate=slRate;
            end


            part1RegN1_re(i)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['part1RegN1_re',num2str(i)]);
            part1RegN1_re(i).SimulinkRate=slRate;
            part1RegN1_im(i)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['part1RegN1_im',num2str(i)]);
            part1RegN1_im(i).SimulinkRate=slRate;


            dataOutIntN1_re(i)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['dataOutIntN1_re',num2str(i)]);
            dataOutIntN1_re(i).SimulinkRate=slRate;
            dataOutIntN1_im(i)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['dataOutIntN1_im',num2str(i)]);
            dataOutIntN1_im(i).SimulinkRate=slRate;
        end


        for i=1:blockInfo.vecsize
            pirelab.getAddComp(iSection,[inmuxoutre(i),addOutregN1_re(i,1)],addOutregN1out_re(i,1));
            pirelab.getAddComp(iSection,[inmuxoutim(i),addOutregN1_im(i,1)],addOutregN1out_im(i,1));
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_re(i,1),addOutregN1_re(i,1),validInreg,internalReset,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_im(i,1),addOutregN1_im(i,1),validInreg,internalReset,1);
        end
        validInregN1=iSection.addSignal(out3.Type,'validInregN1');
        pirelab.getIntDelayComp(iSection,validInreg,validInregN1,blockInfo.vecsize+1,'',0);
        internalResetN1=iSection.addSignal(out3.Type,'internalResetN1');
        pirelab.getIntDelayComp(iSection,internalReset,internalResetN1,blockInfo.vecsize+1,'',0);


        for part=2:blockInfo.vecsize
            pirelab.getIntDelayComp(iSection,addOutregN1_re(part,1),part1RegN1_re(part),part-1);
            pirelab.getIntDelayComp(iSection,addOutregN1_im(part,1),part1RegN1_im(part),part-1);
            for i=1:blockInfo.vecsize
                if i<part
                    pirelab.getAddComp(iSection,[addOutregN1_re(i,part-1),part1RegN1_re(part)],addOutregN1out_re(i,part));
                    pirelab.getAddComp(iSection,[addOutregN1_im(i,part-1),part1RegN1_im(part)],addOutregN1out_im(i,part));
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_re(i,part),addOutregN1_re(i,part),1,internalReset,1);
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_im(i,part),addOutregN1_im(i,part),1,internalReset,1);
                else
                    if part==2
                        pirelab.getAddComp(iSection,[addOutregN1_re(1,part-1),addOutregN1_re(part,1)],addOutregN1out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN1_im(1,part-1),addOutregN1_im(part,1)],addOutregN1out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_re(i,part),addOutregN1_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_im(i,part),addOutregN1_im(i,part),1,internalReset,1);
                    else
                        partN1_re=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),'partN1_re');
                        partN1_im=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),'partN1_im');
                        pirelab.getIntDelayComp(iSection,addOutregN1_re(part,1),partN1_re,part-2);
                        pirelab.getIntDelayComp(iSection,addOutregN1_im(part,1),partN1_im,part-2);
                        pirelab.getAddComp(iSection,[addOutregN1_re(i,part-1),partN1_re],addOutregN1out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN1_im(i,part-1),partN1_im],addOutregN1out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_re(i,part),addOutregN1_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_im(i,part),addOutregN1_im(i,part),1,internalReset,1);
                    end
                end
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1_re(i,blockInfo.vecsize),dataOutIntN1_re(i),1,internalReset,1);
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1_im(i,blockInfo.vecsize),dataOutIntN1_im(i),1,internalReset,1);
            end
        end


        for i=1:blockInfo.vecsize
            pirelab.getWireComp(iSection,dataOutIntN1_re(i),iOutreg_re(i));
            pirelab.getWireComp(iSection,dataOutIntN1_im(i),iOutreg_im(i));
            pirelab.getIntDelayEnabledResettableComp(iSection,iOutreg_re(i),iOut_re(i),1,internalReset,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,iOutreg_im(i),iOut_im(i),1,internalReset,1);
        end
        pirelab.getIntDelayComp(iSection,validInregN1,i_voutreg,1);
        pirelab.getIntDelayComp(iSection,internalResetN1,i_rstoutreg,1);
    case 2
        stage2WL=dTypeN(2).BaseType.WordLength;
        stage2FL=dTypeN(2).BaseType.FractionLength;
        for i=1:blockInfo.vecsize

            for j=1:blockInfo.vecsize
                addOutregN1_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['addOutregN1_re_',num2str(i),'_',num2str(j)]);
                addOutregN1_re(i,j).SimulinkRate=slRate;
                addOutregN1_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['addOutregN1_im_',num2str(i),'_',num2str(j)]);
                addOutregN1_im(i,j).SimulinkRate=slRate;
                addOutregN1out_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['addOutregN1out_re_',num2str(i),'_',num2str(j)]);
                addOutregN1out_re(i,j).SimulinkRate=slRate;
                addOutregN1out_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['addOutregN1out_im_',num2str(i),'_',num2str(j)]);
                addOutregN1out_im(i,j).SimulinkRate=slRate;
                addOutregN2_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['addOutregN2_re_',num2str(i),'_',num2str(j)]);
                addOutregN2_re(i,j).SimulinkRate=slRate;
                addOutregN2_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['addOutregN2_im_',num2str(i),'_',num2str(j)]);
                addOutregN2_im(i,j).SimulinkRate=slRate;
                addOutregN2out_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['addOutregN2out_re_',num2str(i),'_',num2str(j)]);
                addOutregN2out_re(i,j).SimulinkRate=slRate;
                addOutregN2out_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['addOutregN2out_im_',num2str(i),'_',num2str(j)]);
                addOutregN2out_im(i,j).SimulinkRate=slRate;
            end


            part1RegN1_re(i)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['part1RegN1_re',num2str(i)]);
            part1RegN1_re(i).SimulinkRate=slRate;
            part1RegN1_im(i)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['part1RegN1_im',num2str(i)]);
            part1RegN1_im(i).SimulinkRate=slRate;
            part1RegN2_re(i)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['part1RegN2_re',num2str(i)]);
            part1RegN2_re(i).SimulinkRate=slRate;
            part1RegN2_im(i)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['part1RegN2_im',num2str(i)]);
            part1RegN2_im(i).SimulinkRate=slRate;


            dataOutIntN1_re(i)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['dataOutIntN1_re',num2str(i)]);
            dataOutIntN1_re(i).SimulinkRate=slRate;
            dataOutIntN1_im(i)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['dataOutIntN1_im',num2str(i)]);
            dataOutIntN1_im(i).SimulinkRate=slRate;
            dataOutIntN2_re(i)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['dataOutIntN2_re',num2str(i)]);
            dataOutIntN2_re(i).SimulinkRate=slRate;
            dataOutIntN2_im(i)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['dataOutIntN2_im',num2str(i)]);
            dataOutIntN2_im(i).SimulinkRate=slRate;
        end


        for i=1:blockInfo.vecsize
            pirelab.getAddComp(iSection,[inmuxoutre(i),addOutregN1_re(i,1)],addOutregN1out_re(i,1));
            pirelab.getAddComp(iSection,[inmuxoutim(i),addOutregN1_im(i,1)],addOutregN1out_im(i,1));
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_re(i,1),addOutregN1_re(i,1),validInreg,internalReset,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_im(i,1),addOutregN1_im(i,1),validInreg,internalReset,1);
        end


        for part=2:blockInfo.vecsize
            pirelab.getIntDelayComp(iSection,addOutregN1_re(part,1),part1RegN1_re(part),part-1);
            pirelab.getIntDelayComp(iSection,addOutregN1_im(part,1),part1RegN1_im(part),part-1);
            for i=1:blockInfo.vecsize
                if i<part
                    pirelab.getAddComp(iSection,[addOutregN1_re(i,part-1),part1RegN1_re(part)],addOutregN1out_re(i,part));
                    pirelab.getAddComp(iSection,[addOutregN1_im(i,part-1),part1RegN1_im(part)],addOutregN1out_im(i,part));
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_re(i,part),addOutregN1_re(i,part),1,internalReset,1);
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_im(i,part),addOutregN1_im(i,part),1,internalReset,1);
                else
                    if part==2
                        pirelab.getAddComp(iSection,[addOutregN1_re(1,part-1),addOutregN1_re(part,1)],addOutregN1out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN1_im(1,part-1),addOutregN1_im(part,1)],addOutregN1out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_re(i,part),addOutregN1_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_im(i,part),addOutregN1_im(i,part),1,internalReset,1);
                    else
                        partN1_re=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),'partN1_re');
                        partN1_im=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),'partN1_im');
                        pirelab.getIntDelayComp(iSection,addOutregN1_re(part,1),partN1_re,part-2);
                        pirelab.getIntDelayComp(iSection,addOutregN1_im(part,1),partN1_im,part-2);
                        pirelab.getAddComp(iSection,[addOutregN1_re(i,part-1),partN1_re],addOutregN1out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN1_im(i,part-1),partN1_im],addOutregN1out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_re(i,part),addOutregN1_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_im(i,part),addOutregN1_im(i,part),1,internalReset,1);
                    end
                end
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1_re(i,blockInfo.vecsize),dataOutIntN1_re(i),1,internalReset,1);
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1_im(i,blockInfo.vecsize),dataOutIntN1_im(i),1,internalReset,1);
            end
        end


        validInregN2=iSection.addSignal(out3.Type,'validInregN2');
        pirelab.getIntDelayComp(iSection,validInreg,validInregN2,blockInfo.vecsize+1,'',0);
        internalResetN2=iSection.addSignal(out3.Type,'internalResetN2');
        pirelab.getIntDelayComp(iSection,internalReset,internalResetN2,blockInfo.vecsize+1,'',0);
        for i=1:blockInfo.vecsize
            pirelab.getAddComp(iSection,[dataOutIntN1_re(i),addOutregN2_re(i,1)],addOutregN2out_re(i,1));
            pirelab.getAddComp(iSection,[dataOutIntN1_im(i),addOutregN2_im(i,1)],addOutregN2out_im(i,1));
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_re(i,1),addOutregN2_re(i,1),validInregN2,internalResetN2,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_im(i,1),addOutregN2_im(i,1),validInregN2,internalResetN2,1);
        end


        for part=2:blockInfo.vecsize
            pirelab.getIntDelayComp(iSection,addOutregN2_re(part,1),part1RegN2_re(part),part-1);
            pirelab.getIntDelayComp(iSection,addOutregN2_im(part,1),part1RegN2_im(part),part-1);
            for i=1:blockInfo.vecsize
                if i<part
                    pirelab.getAddComp(iSection,[addOutregN2_re(i,part-1),part1RegN2_re(part)],addOutregN2out_re(i,part));
                    pirelab.getAddComp(iSection,[addOutregN2_im(i,part-1),part1RegN2_im(part)],addOutregN2out_im(i,part));
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_re(i,part),addOutregN2_re(i,part),1,internalReset,1);
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_im(i,part),addOutregN2_im(i,part),1,internalReset,1);
                else
                    if part==2
                        pirelab.getAddComp(iSection,[addOutregN2_re(1,part-1),addOutregN2_re(part,1)],addOutregN2out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN2_im(1,part-1),addOutregN2_im(part,1)],addOutregN2out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_re(i,part),addOutregN2_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_im(i,part),addOutregN2_im(i,part),1,internalReset,1);
                    else
                        partN2_re=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),'partN2_re');
                        partN2_im=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),'partN2_im');
                        pirelab.getIntDelayComp(iSection,addOutregN2_re(part,1),partN2_re,part-2);
                        pirelab.getIntDelayComp(iSection,addOutregN2_im(part,1),partN2_im,part-2);
                        pirelab.getAddComp(iSection,[addOutregN2_re(i,part-1),partN2_re],addOutregN2out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN2_im(i,part-1),partN2_im],addOutregN2out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_re(i,part),addOutregN2_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_im(i,part),addOutregN2_im(i,part),1,internalReset,1);
                    end
                end
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2_re(i,blockInfo.vecsize),dataOutIntN2_re(i),1,internalReset,1);
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2_im(i,blockInfo.vecsize),dataOutIntN2_im(i),1,internalReset,1);
            end
        end


        validInregN3=iSection.addSignal(out3.Type,'validInregN3');
        pirelab.getIntDelayComp(iSection,validInregN2,validInregN3,blockInfo.vecsize+1,'',0);
        internalResetN3=iSection.addSignal(out3.Type,'internalResetN3');
        pirelab.getIntDelayComp(iSection,internalResetN2,internalResetN3,blockInfo.vecsize+1,'',0);
        for i=1:blockInfo.vecsize
            pirelab.getWireComp(iSection,dataOutIntN2_re(i),iOutreg_re(i));
            pirelab.getWireComp(iSection,dataOutIntN2_im(i),iOutreg_im(i));
            pirelab.getIntDelayEnabledResettableComp(iSection,iOutreg_re(i),iOut_re(i),validInregN3,internalResetN3,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,iOutreg_im(i),iOut_im(i),validInregN3,internalResetN3,1);
        end
        pirelab.getIntDelayComp(iSection,validInregN3,i_voutreg,1);
        pirelab.getIntDelayComp(iSection,internalResetN3,i_rstoutreg,1);
    case 3
        stage2WL=dTypeN(2).BaseType.WordLength;
        stage2FL=dTypeN(2).BaseType.FractionLength;
        stage3WL=dTypeN(3).BaseType.WordLength;
        stage3FL=dTypeN(3).BaseType.FractionLength;
        for i=1:blockInfo.vecsize

            for j=1:blockInfo.vecsize
                addOutregN1_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['addOutregN1_re_',num2str(i),'_',num2str(j)]);
                addOutregN1_re(i,j).SimulinkRate=slRate;
                addOutregN1_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['addOutregN1_im_',num2str(i),'_',num2str(j)]);
                addOutregN1_im(i,j).SimulinkRate=slRate;
                addOutregN1out_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['addOutregN1out_re_',num2str(i),'_',num2str(j)]);
                addOutregN1out_re(i,j).SimulinkRate=slRate;
                addOutregN1out_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['addOutregN1out_im_',num2str(i),'_',num2str(j)]);
                addOutregN1out_im(i,j).SimulinkRate=slRate;
                addOutregN2_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['addOutregN2_re_',num2str(i),'_',num2str(j)]);
                addOutregN2_re(i,j).SimulinkRate=slRate;
                addOutregN2_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['addOutregN2_im_',num2str(i),'_',num2str(j)]);
                addOutregN2_im(i,j).SimulinkRate=slRate;
                addOutregN2out_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['addOutregN2out_re_',num2str(i),'_',num2str(j)]);
                addOutregN2out_re(i,j).SimulinkRate=slRate;
                addOutregN2out_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['addOutregN2out_im_',num2str(i),'_',num2str(j)]);
                addOutregN2out_im(i,j).SimulinkRate=slRate;
                addOutregN3_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['addOutregN3_re_',num2str(i),'_',num2str(j)]);
                addOutregN3_re(i,j).SimulinkRate=slRate;
                addOutregN3_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['addOutregN3_im_',num2str(i),'_',num2str(j)]);
                addOutregN3_im(i,j).SimulinkRate=slRate;
                addOutregN3out_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['addOutregN3out_re_',num2str(i),'_',num2str(j)]);
                addOutregN3out_re(i,j).SimulinkRate=slRate;
                addOutregN3out_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['addOutregN3out_im_',num2str(i),'_',num2str(j)]);
                addOutregN3out_im(i,j).SimulinkRate=slRate;
            end


            part1RegN1_re(i)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['part1RegN1_re',num2str(i)]);
            part1RegN1_re(i).SimulinkRate=slRate;
            part1RegN1_im(i)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['part1RegN1_im',num2str(i)]);
            part1RegN1_im(i).SimulinkRate=slRate;
            part1RegN2_re(i)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['part1RegN2_re',num2str(i)]);
            part1RegN2_re(i).SimulinkRate=slRate;
            part1RegN2_im(i)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['part1RegN2_im',num2str(i)]);
            part1RegN2_im(i).SimulinkRate=slRate;
            part1RegN3_re(i)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['part1RegN3_re',num2str(i)]);
            part1RegN3_re(i).SimulinkRate=slRate;
            part1RegN3_im(i)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['part1RegN3_im',num2str(i)]);
            part1RegN3_im(i).SimulinkRate=slRate;


            dataOutIntN1_re(i)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['dataOutIntN1_re',num2str(i)]);
            dataOutIntN1_re(i).SimulinkRate=slRate;
            dataOutIntN1_im(i)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['dataOutIntN1_im',num2str(i)]);
            dataOutIntN1_im(i).SimulinkRate=slRate;
            dataOutIntN2_re(i)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['dataOutIntN2_re',num2str(i)]);
            dataOutIntN2_re(i).SimulinkRate=slRate;
            dataOutIntN2_im(i)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['dataOutIntN2_im',num2str(i)]);
            dataOutIntN2_im(i).SimulinkRate=slRate;
            dataOutIntN3_re(i)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['dataOutIntN3_re',num2str(i)]);
            dataOutIntN3_re(i).SimulinkRate=slRate;
            dataOutIntN3_im(i)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['dataOutIntN3_im',num2str(i)]);
            dataOutIntN3_im(i).SimulinkRate=slRate;
        end


        for i=1:blockInfo.vecsize
            pirelab.getAddComp(iSection,[inmuxoutre(i),addOutregN1_re(i,1)],addOutregN1out_re(i,1));
            pirelab.getAddComp(iSection,[inmuxoutim(i),addOutregN1_im(i,1)],addOutregN1out_im(i,1));
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_re(i,1),addOutregN1_re(i,1),validInreg,internalReset,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_im(i,1),addOutregN1_im(i,1),validInreg,internalReset,1);
        end


        for part=2:blockInfo.vecsize
            pirelab.getIntDelayComp(iSection,addOutregN1_re(part,1),part1RegN1_re(part),part-1);
            pirelab.getIntDelayComp(iSection,addOutregN1_im(part,1),part1RegN1_im(part),part-1);
            for i=1:blockInfo.vecsize
                if i<part
                    pirelab.getAddComp(iSection,[addOutregN1_re(i,part-1),part1RegN1_re(part)],addOutregN1out_re(i,part));
                    pirelab.getAddComp(iSection,[addOutregN1_im(i,part-1),part1RegN1_im(part)],addOutregN1out_im(i,part));
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_re(i,part),addOutregN1_re(i,part),1,internalReset,1);
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_im(i,part),addOutregN1_im(i,part),1,internalReset,1);
                else
                    if part==2
                        pirelab.getAddComp(iSection,[addOutregN1_re(1,part-1),addOutregN1_re(part,1)],addOutregN1out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN1_im(1,part-1),addOutregN1_im(part,1)],addOutregN1out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_re(i,part),addOutregN1_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_im(i,part),addOutregN1_im(i,part),1,internalReset,1);
                    else
                        partN1_re=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),'partN1_re');
                        partN1_im=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),'partN1_im');
                        pirelab.getIntDelayComp(iSection,addOutregN1_re(part,1),partN1_re,part-2);
                        pirelab.getIntDelayComp(iSection,addOutregN1_im(part,1),partN1_im,part-2);
                        pirelab.getAddComp(iSection,[addOutregN1_re(i,part-1),partN1_re],addOutregN1out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN1_im(i,part-1),partN1_im],addOutregN1out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_re(i,part),addOutregN1_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_im(i,part),addOutregN1_im(i,part),1,internalReset,1);
                    end
                end
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1_re(i,blockInfo.vecsize),dataOutIntN1_re(i),1,internalReset,1);
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1_im(i,blockInfo.vecsize),dataOutIntN1_im(i),1,internalReset,1);
            end
        end


        validInregN2=iSection.addSignal(out3.Type,'validInregN2');
        pirelab.getIntDelayComp(iSection,validInreg,validInregN2,blockInfo.vecsize+1,'',0);
        internalResetN2=iSection.addSignal(out3.Type,'internalResetN2');
        pirelab.getIntDelayComp(iSection,internalReset,internalResetN2,blockInfo.vecsize+1,'',0);
        for i=1:blockInfo.vecsize
            pirelab.getAddComp(iSection,[dataOutIntN1_re(i),addOutregN2_re(i,1)],addOutregN2out_re(i,1));
            pirelab.getAddComp(iSection,[dataOutIntN1_im(i),addOutregN2_im(i,1)],addOutregN2out_im(i,1));
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_re(i,1),addOutregN2_re(i,1),validInregN2,internalResetN2,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_im(i,1),addOutregN2_im(i,1),validInregN2,internalResetN2,1);
        end


        for part=2:blockInfo.vecsize
            pirelab.getIntDelayComp(iSection,addOutregN2_re(part,1),part1RegN2_re(part),part-1);
            pirelab.getIntDelayComp(iSection,addOutregN2_im(part,1),part1RegN2_im(part),part-1);
            for i=1:blockInfo.vecsize
                if i<part
                    pirelab.getAddComp(iSection,[addOutregN2_re(i,part-1),part1RegN2_re(part)],addOutregN2out_re(i,part));
                    pirelab.getAddComp(iSection,[addOutregN2_im(i,part-1),part1RegN2_im(part)],addOutregN2out_im(i,part));
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_re(i,part),addOutregN2_re(i,part),1,internalReset,1);
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_im(i,part),addOutregN2_im(i,part),1,internalReset,1);
                else
                    if part==2
                        pirelab.getAddComp(iSection,[addOutregN2_re(1,part-1),addOutregN2_re(part,1)],addOutregN2out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN2_im(1,part-1),addOutregN2_im(part,1)],addOutregN2out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_re(i,part),addOutregN2_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_im(i,part),addOutregN2_im(i,part),1,internalReset,1);
                    else
                        partN2_re=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),'partN2_re');
                        partN2_im=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),'partN2_im');
                        pirelab.getIntDelayComp(iSection,addOutregN2_re(part,1),partN2_re,part-2);
                        pirelab.getIntDelayComp(iSection,addOutregN2_im(part,1),partN2_im,part-2);
                        pirelab.getAddComp(iSection,[addOutregN2_re(i,part-1),partN2_re],addOutregN2out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN2_im(i,part-1),partN2_im],addOutregN2out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_re(i,part),addOutregN2_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_im(i,part),addOutregN2_im(i,part),1,internalReset,1);
                    end
                end
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2_re(i,blockInfo.vecsize),dataOutIntN2_re(i),1,internalReset,1);
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2_im(i,blockInfo.vecsize),dataOutIntN2_im(i),1,internalReset,1);
            end
        end


        validInregN3=iSection.addSignal(out3.Type,'validInregN3');
        pirelab.getIntDelayComp(iSection,validInregN2,validInregN3,blockInfo.vecsize+1,'',0);
        internalResetN3=iSection.addSignal(out3.Type,'internalResetN3');
        pirelab.getIntDelayComp(iSection,internalResetN2,internalResetN3,blockInfo.vecsize+1,'',0);
        for i=1:blockInfo.vecsize
            pirelab.getAddComp(iSection,[dataOutIntN2_re(i),addOutregN3_re(i,1)],addOutregN3out_re(i,1));
            pirelab.getAddComp(iSection,[dataOutIntN2_im(i),addOutregN3_im(i,1)],addOutregN3out_im(i,1));
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_re(i,1),addOutregN3_re(i,1),validInregN3,internalResetN3,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_im(i,1),addOutregN3_im(i,1),validInregN3,internalResetN3,1);
        end


        for part=2:blockInfo.vecsize
            pirelab.getIntDelayComp(iSection,addOutregN3_re(part,1),part1RegN3_re(part),part-1);
            pirelab.getIntDelayComp(iSection,addOutregN3_im(part,1),part1RegN3_im(part),part-1);
            for i=1:blockInfo.vecsize
                if i<part
                    pirelab.getAddComp(iSection,[addOutregN3_re(i,part-1),part1RegN3_re(part)],addOutregN3out_re(i,part));
                    pirelab.getAddComp(iSection,[addOutregN3_im(i,part-1),part1RegN3_im(part)],addOutregN3out_im(i,part));
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_re(i,part),addOutregN3_re(i,part),1,internalReset,1);
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_im(i,part),addOutregN3_im(i,part),1,internalReset,1);
                else
                    if part==2
                        pirelab.getAddComp(iSection,[addOutregN3_re(1,part-1),addOutregN3_re(part,1)],addOutregN3out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN3_im(1,part-1),addOutregN3_im(part,1)],addOutregN3out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_re(i,part),addOutregN3_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_im(i,part),addOutregN3_im(i,part),1,internalReset,1);
                    else
                        partN3_re=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),'partN3_re');
                        partN3_im=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),'partN3_im');
                        pirelab.getIntDelayComp(iSection,addOutregN3_re(part,1),partN3_re,part-2);
                        pirelab.getIntDelayComp(iSection,addOutregN3_im(part,1),partN3_im,part-2);
                        pirelab.getAddComp(iSection,[addOutregN3_re(i,part-1),partN3_re],addOutregN3out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN3_im(i,part-1),partN3_im],addOutregN3out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_re(i,part),addOutregN3_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_im(i,part),addOutregN3_im(i,part),1,internalReset,1);
                    end
                end
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3_re(i,blockInfo.vecsize),dataOutIntN3_re(i),1,internalReset,1);
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3_im(i,blockInfo.vecsize),dataOutIntN3_im(i),1,internalReset,1);
            end
        end


        validInregN4=iSection.addSignal(out3.Type,'validInregN4');
        pirelab.getIntDelayComp(iSection,validInregN3,validInregN4,blockInfo.vecsize+1,'',0);
        internalResetN4=iSection.addSignal(out3.Type,'internalResetN4');
        pirelab.getIntDelayComp(iSection,internalResetN3,internalResetN4,blockInfo.vecsize+1,'',0);
        for i=1:blockInfo.vecsize
            pirelab.getWireComp(iSection,dataOutIntN3_re(i),iOutreg_re(i));
            pirelab.getWireComp(iSection,dataOutIntN3_im(i),iOutreg_im(i));
            pirelab.getIntDelayEnabledResettableComp(iSection,iOutreg_re(i),iOut_re(i),validInregN4,internalResetN4,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,iOutreg_im(i),iOut_im(i),validInregN4,internalResetN4,1);
        end
        pirelab.getIntDelayComp(iSection,validInregN4,i_voutreg,1);
        pirelab.getIntDelayComp(iSection,internalResetN4,i_rstoutreg,1);
    case 4
        stage2WL=dTypeN(2).BaseType.WordLength;
        stage2FL=dTypeN(2).BaseType.FractionLength;
        stage3WL=dTypeN(3).BaseType.WordLength;
        stage3FL=dTypeN(3).BaseType.FractionLength;
        stage4WL=dTypeN(4).BaseType.WordLength;
        stage4FL=dTypeN(4).BaseType.FractionLength;
        for i=1:blockInfo.vecsize

            for j=1:blockInfo.vecsize
                addOutregN1_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['addOutregN1_re_',num2str(i),'_',num2str(j)]);
                addOutregN1_re(i,j).SimulinkRate=slRate;
                addOutregN1_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['addOutregN1_im_',num2str(i),'_',num2str(j)]);
                addOutregN1_im(i,j).SimulinkRate=slRate;
                addOutregN1out_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['addOutregN1out_re_',num2str(i),'_',num2str(j)]);
                addOutregN1out_re(i,j).SimulinkRate=slRate;
                addOutregN1out_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['addOutregN1out_im_',num2str(i),'_',num2str(j)]);
                addOutregN1out_im(i,j).SimulinkRate=slRate;
                addOutregN2_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['addOutregN2_re_',num2str(i),'_',num2str(j)]);
                addOutregN2_re(i,j).SimulinkRate=slRate;
                addOutregN2_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['addOutregN2_im_',num2str(i),'_',num2str(j)]);
                addOutregN2_im(i,j).SimulinkRate=slRate;
                addOutregN2out_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['addOutregN2out_re_',num2str(i),'_',num2str(j)]);
                addOutregN2out_re(i,j).SimulinkRate=slRate;
                addOutregN2out_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['addOutregN2out_im_',num2str(i),'_',num2str(j)]);
                addOutregN2out_im(i,j).SimulinkRate=slRate;
                addOutregN3_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['addOutregN3_re_',num2str(i),'_',num2str(j)]);
                addOutregN3_re(i,j).SimulinkRate=slRate;
                addOutregN3_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['addOutregN3_im_',num2str(i),'_',num2str(j)]);
                addOutregN3_im(i,j).SimulinkRate=slRate;
                addOutregN3out_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['addOutregN3out_re_',num2str(i),'_',num2str(j)]);
                addOutregN3out_re(i,j).SimulinkRate=slRate;
                addOutregN3out_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['addOutregN3out_im_',num2str(i),'_',num2str(j)]);
                addOutregN3out_im(i,j).SimulinkRate=slRate;
                addOutregN4_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['addOutregN4_re_',num2str(i),'_',num2str(j)]);
                addOutregN4_re(i,j).SimulinkRate=slRate;
                addOutregN4_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['addOutregN4_im_',num2str(i),'_',num2str(j)]);
                addOutregN4_im(i,j).SimulinkRate=slRate;
                addOutregN4out_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['addOutregN4out_re_',num2str(i),'_',num2str(j)]);
                addOutregN4out_re(i,j).SimulinkRate=slRate;
                addOutregN4out_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['addOutregN4out_im_',num2str(i),'_',num2str(j)]);
                addOutregN4out_im(i,j).SimulinkRate=slRate;
            end


            part1RegN1_re(i)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['part1RegN1_re',num2str(i)]);
            part1RegN1_re(i).SimulinkRate=slRate;
            part1RegN1_im(i)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['part1RegN1_im',num2str(i)]);
            part1RegN1_im(i).SimulinkRate=slRate;


            dataOutIntN1_re(i)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['dataOutIntN1_re',num2str(i)]);
            dataOutIntN1_re(i).SimulinkRate=slRate;
            dataOutIntN1_im(i)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['dataOutIntN1_im',num2str(i)]);
            dataOutIntN1_im(i).SimulinkRate=slRate;
            part1RegN2_re(i)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['part1RegN2_re',num2str(i)]);
            part1RegN2_re(i).SimulinkRate=slRate;
            part1RegN2_im(i)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['part1RegN2_im',num2str(i)]);
            part1RegN2_im(i).SimulinkRate=slRate;
            dataOutIntN2_re(i)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['dataOutIntN2_re',num2str(i)]);
            dataOutIntN2_re(i).SimulinkRate=slRate;
            dataOutIntN2_im(i)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['dataOutIntN2_im',num2str(i)]);
            dataOutIntN2_im(i).SimulinkRate=slRate;
            part1RegN3_re(i)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['part1RegN3_re',num2str(i)]);
            part1RegN3_re(i).SimulinkRate=slRate;
            part1RegN3_im(i)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['part1RegN3_im',num2str(i)]);
            part1RegN3_im(i).SimulinkRate=slRate;
            dataOutIntN3_re(i)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['dataOutIntN3_re',num2str(i)]);
            dataOutIntN3_re(i).SimulinkRate=slRate;
            dataOutIntN3_im(i)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['dataOutIntN3_im',num2str(i)]);
            dataOutIntN3_im(i).SimulinkRate=slRate;
            part1RegN4_re(i)=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['part1RegN4_re',num2str(i)]);
            part1RegN4_re(i).SimulinkRate=slRate;
            part1RegN4_im(i)=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['part1RegN4_im',num2str(i)]);
            part1RegN4_im(i).SimulinkRate=slRate;
            dataOutIntN4_re(i)=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['dataOutIntN4_re',num2str(i)]);
            dataOutIntN4_re(i).SimulinkRate=slRate;
            dataOutIntN4_im(i)=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['dataOutIntN4_im',num2str(i)]);
            dataOutIntN4_im(i).SimulinkRate=slRate;
        end


        for i=1:blockInfo.vecsize
            pirelab.getAddComp(iSection,[inmuxoutre(i),addOutregN1_re(i,1)],addOutregN1out_re(i,1));
            pirelab.getAddComp(iSection,[inmuxoutim(i),addOutregN1_im(i,1)],addOutregN1out_im(i,1));
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_re(i,1),addOutregN1_re(i,1),validInreg,internalReset,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_im(i,1),addOutregN1_im(i,1),validInreg,internalReset,1);
        end
        for part=2:blockInfo.vecsize
            pirelab.getIntDelayComp(iSection,addOutregN1_re(part,1),part1RegN1_re(part),part-1);
            pirelab.getIntDelayComp(iSection,addOutregN1_im(part,1),part1RegN1_im(part),part-1);
            for i=1:blockInfo.vecsize
                if i<part
                    pirelab.getAddComp(iSection,[addOutregN1_re(i,part-1),part1RegN1_re(part)],addOutregN1out_re(i,part));
                    pirelab.getAddComp(iSection,[addOutregN1_im(i,part-1),part1RegN1_im(part)],addOutregN1out_im(i,part));
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_re(i,part),addOutregN1_re(i,part),1,internalReset,1);
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_im(i,part),addOutregN1_im(i,part),1,internalReset,1);
                else
                    if part==2
                        pirelab.getAddComp(iSection,[addOutregN1_re(1,part-1),addOutregN1_re(part,1)],addOutregN1out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN1_im(1,part-1),addOutregN1_im(part,1)],addOutregN1out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_re(i,part),addOutregN1_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_im(i,part),addOutregN1_im(i,part),1,internalReset,1);
                    else
                        partN1_re=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),'partN1_re');
                        partN1_im=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),'partN1_im');
                        pirelab.getIntDelayComp(iSection,addOutregN1_re(part,1),partN1_re,part-2);
                        pirelab.getIntDelayComp(iSection,addOutregN1_im(part,1),partN1_im,part-2);
                        pirelab.getAddComp(iSection,[addOutregN1_re(i,part-1),partN1_re],addOutregN1out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN1_im(i,part-1),partN1_im],addOutregN1out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_re(i,part),addOutregN1_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_im(i,part),addOutregN1_im(i,part),1,internalReset,1);
                    end
                end
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1_re(i,blockInfo.vecsize),dataOutIntN1_re(i),1,internalReset,1);
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1_im(i,blockInfo.vecsize),dataOutIntN1_im(i),1,internalReset,1);
            end
        end
        validInregN2=iSection.addSignal(out3.Type,'validInregN2');
        pirelab.getIntDelayComp(iSection,validInreg,validInregN2,blockInfo.vecsize+1,'',0);
        internalResetN2=iSection.addSignal(out3.Type,'internalResetN2');
        pirelab.getIntDelayComp(iSection,internalReset,internalResetN2,blockInfo.vecsize+1,'',0);
        for i=1:blockInfo.vecsize
            pirelab.getAddComp(iSection,[dataOutIntN1_re(i),addOutregN2_re(i,1)],addOutregN2out_re(i,1));
            pirelab.getAddComp(iSection,[dataOutIntN1_im(i),addOutregN2_im(i,1)],addOutregN2out_im(i,1));
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_re(i,1),addOutregN2_re(i,1),validInregN2,internalResetN2,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_im(i,1),addOutregN2_im(i,1),validInregN2,internalResetN2,1);
        end
        for part=2:blockInfo.vecsize
            pirelab.getIntDelayComp(iSection,addOutregN2_re(part,1),part1RegN2_re(part),part-1);
            pirelab.getIntDelayComp(iSection,addOutregN2_im(part,1),part1RegN2_im(part),part-1);
            for i=1:blockInfo.vecsize
                if i<part
                    pirelab.getAddComp(iSection,[addOutregN2_re(i,part-1),part1RegN2_re(part)],addOutregN2out_re(i,part));
                    pirelab.getAddComp(iSection,[addOutregN2_im(i,part-1),part1RegN2_im(part)],addOutregN2out_im(i,part));
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_re(i,part),addOutregN2_re(i,part),1,internalReset,1);
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_im(i,part),addOutregN2_im(i,part),1,internalReset,1);
                else
                    if part==2
                        pirelab.getAddComp(iSection,[addOutregN2_re(1,part-1),addOutregN2_re(part,1)],addOutregN2out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN2_im(1,part-1),addOutregN2_im(part,1)],addOutregN2out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_re(i,part),addOutregN2_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_im(i,part),addOutregN2_im(i,part),1,internalReset,1);
                    else
                        partN2_re=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),'partN2_re');
                        partN2_im=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),'partN2_im');
                        pirelab.getIntDelayComp(iSection,addOutregN2_re(part,1),partN2_re,part-2);
                        pirelab.getIntDelayComp(iSection,addOutregN2_im(part,1),partN2_im,part-2);
                        pirelab.getAddComp(iSection,[addOutregN2_re(i,part-1),partN2_re],addOutregN2out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN2_im(i,part-1),partN2_im],addOutregN2out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_re(i,part),addOutregN2_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_im(i,part),addOutregN2_im(i,part),1,internalReset,1);
                    end
                end
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2_re(i,blockInfo.vecsize),dataOutIntN2_re(i),1,internalReset,1);
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2_im(i,blockInfo.vecsize),dataOutIntN2_im(i),1,internalReset,1);
            end
        end
        validInregN3=iSection.addSignal(out3.Type,'validInregN3');
        pirelab.getIntDelayComp(iSection,validInregN2,validInregN3,blockInfo.vecsize+1,'',0);
        internalResetN3=iSection.addSignal(out3.Type,'internalResetN3');
        pirelab.getIntDelayComp(iSection,internalResetN2,internalResetN3,blockInfo.vecsize+1,'',0);
        for i=1:blockInfo.vecsize
            pirelab.getAddComp(iSection,[dataOutIntN2_re(i),addOutregN3_re(i,1)],addOutregN3out_re(i,1));
            pirelab.getAddComp(iSection,[dataOutIntN2_im(i),addOutregN3_im(i,1)],addOutregN3out_im(i,1));
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_re(i,1),addOutregN3_re(i,1),validInregN3,internalResetN3,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_im(i,1),addOutregN3_im(i,1),validInregN3,internalResetN3,1);
        end
        for part=2:blockInfo.vecsize
            pirelab.getIntDelayComp(iSection,addOutregN3_re(part,1),part1RegN3_re(part),part-1);
            pirelab.getIntDelayComp(iSection,addOutregN3_im(part,1),part1RegN3_im(part),part-1);
            for i=1:blockInfo.vecsize
                if i<part
                    pirelab.getAddComp(iSection,[addOutregN3_re(i,part-1),part1RegN3_re(part)],addOutregN3out_re(i,part));
                    pirelab.getAddComp(iSection,[addOutregN3_im(i,part-1),part1RegN3_im(part)],addOutregN3out_im(i,part));
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_re(i,part),addOutregN3_re(i,part),1,internalReset,1);
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_im(i,part),addOutregN3_im(i,part),1,internalReset,1);
                else
                    if part==2
                        pirelab.getAddComp(iSection,[addOutregN3_re(1,part-1),addOutregN3_re(part,1)],addOutregN3out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN3_im(1,part-1),addOutregN3_im(part,1)],addOutregN3out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_re(i,part),addOutregN3_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_im(i,part),addOutregN3_im(i,part),1,internalReset,1);
                    else
                        partN3_re=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),'partN3_re');
                        partN3_im=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),'partN3_im');
                        pirelab.getIntDelayComp(iSection,addOutregN3_re(part,1),partN3_re,part-2);
                        pirelab.getIntDelayComp(iSection,addOutregN3_im(part,1),partN3_im,part-2);
                        pirelab.getAddComp(iSection,[addOutregN3_re(i,part-1),partN3_re],addOutregN3out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN3_im(i,part-1),partN3_im],addOutregN3out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_re(i,part),addOutregN3_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_im(i,part),addOutregN3_im(i,part),1,internalReset,1);
                    end
                end
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3_re(i,blockInfo.vecsize),dataOutIntN3_re(i),1,internalReset,1);
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3_im(i,blockInfo.vecsize),dataOutIntN3_im(i),1,internalReset,1);
            end
        end
        validInregN4=iSection.addSignal(out3.Type,'validInregN4');
        pirelab.getIntDelayComp(iSection,validInregN3,validInregN4,blockInfo.vecsize+1,'',0);
        internalResetN4=iSection.addSignal(out3.Type,'internalResetN4');
        pirelab.getIntDelayComp(iSection,internalResetN3,internalResetN4,blockInfo.vecsize+1,'',0);
        for i=1:blockInfo.vecsize
            pirelab.getAddComp(iSection,[dataOutIntN3_re(i),addOutregN4_re(i,1)],addOutregN4out_re(i,1));
            pirelab.getAddComp(iSection,[dataOutIntN3_im(i),addOutregN4_im(i,1)],addOutregN4out_im(i,1));
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4out_re(i,1),addOutregN4_re(i,1),validInregN4,internalResetN4,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4out_im(i,1),addOutregN4_im(i,1),validInregN4,internalResetN4,1);
        end
        for part=2:blockInfo.vecsize
            pirelab.getIntDelayComp(iSection,addOutregN4_re(part,1),part1RegN4_re(part),part-1);
            pirelab.getIntDelayComp(iSection,addOutregN4_im(part,1),part1RegN4_im(part),part-1);
            for i=1:blockInfo.vecsize
                if i<part
                    pirelab.getAddComp(iSection,[addOutregN4_re(i,part-1),part1RegN4_re(part)],addOutregN4out_re(i,part));
                    pirelab.getAddComp(iSection,[addOutregN4_im(i,part-1),part1RegN4_im(part)],addOutregN4out_im(i,part));
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4out_re(i,part),addOutregN4_re(i,part),1,internalReset,1);
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4out_im(i,part),addOutregN4_im(i,part),1,internalReset,1);
                else
                    if part==2
                        pirelab.getAddComp(iSection,[addOutregN4_re(1,part-1),addOutregN4_re(part,1)],addOutregN4out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN4_im(1,part-1),addOutregN4_im(part,1)],addOutregN4out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4out_re(i,part),addOutregN4_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4out_im(i,part),addOutregN4_im(i,part),1,internalReset,1);
                    else
                        partN4_re=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),'partN4_re');
                        partN4_im=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),'partN4_im');
                        pirelab.getIntDelayComp(iSection,addOutregN4_re(part,1),partN4_re,part-2);
                        pirelab.getIntDelayComp(iSection,addOutregN4_im(part,1),partN4_im,part-2);
                        pirelab.getAddComp(iSection,[addOutregN4_re(i,part-1),partN4_re],addOutregN4out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN4_im(i,part-1),partN4_im],addOutregN4out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4out_re(i,part),addOutregN4_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4out_im(i,part),addOutregN4_im(i,part),1,internalReset,1);
                    end
                end
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4_re(i,blockInfo.vecsize),dataOutIntN4_re(i),1,internalReset,1);
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4_im(i,blockInfo.vecsize),dataOutIntN4_im(i),1,internalReset,1);
            end
        end
        validInregN5=iSection.addSignal(out3.Type,'validInregN5');
        pirelab.getIntDelayComp(iSection,validInregN4,validInregN5,blockInfo.vecsize+1,'',0);
        internalResetN5=iSection.addSignal(out3.Type,'internalResetN5');
        pirelab.getIntDelayComp(iSection,internalResetN4,internalResetN5,blockInfo.vecsize+1,'',0);
        for i=1:blockInfo.vecsize
            pirelab.getWireComp(iSection,dataOutIntN4_re(i),iOutreg_re(i));
            pirelab.getWireComp(iSection,dataOutIntN4_im(i),iOutreg_im(i));
            pirelab.getIntDelayEnabledResettableComp(iSection,iOutreg_re(i),iOut_re(i),validInregN5,internalResetN5,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,iOutreg_im(i),iOut_im(i),validInregN5,internalResetN5,1);
        end
        pirelab.getIntDelayComp(iSection,validInregN5,i_voutreg,1);
        pirelab.getIntDelayComp(iSection,internalResetN5,i_rstoutreg,1);
    case 5
        stage2WL=dTypeN(2).BaseType.WordLength;
        stage2FL=dTypeN(2).BaseType.FractionLength;
        stage3WL=dTypeN(3).BaseType.WordLength;
        stage3FL=dTypeN(3).BaseType.FractionLength;
        stage4WL=dTypeN(4).BaseType.WordLength;
        stage4FL=dTypeN(4).BaseType.FractionLength;
        stage5WL=dTypeN(5).BaseType.WordLength;
        stage5FL=dTypeN(5).BaseType.FractionLength;
        for i=1:blockInfo.vecsize

            for j=1:blockInfo.vecsize
                addOutregN1_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['addOutregN1_re_',num2str(i),'_',num2str(j)]);
                addOutregN1_re(i,j).SimulinkRate=slRate;
                addOutregN1_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['addOutregN1_im_',num2str(i),'_',num2str(j)]);
                addOutregN1_im(i,j).SimulinkRate=slRate;
                addOutregN1out_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['addOutregN1out_re_',num2str(i),'_',num2str(j)]);
                addOutregN1out_re(i,j).SimulinkRate=slRate;
                addOutregN1out_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['addOutregN1out_im_',num2str(i),'_',num2str(j)]);
                addOutregN1out_im(i,j).SimulinkRate=slRate;
                addOutregN2_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['addOutregN2_re_',num2str(i),'_',num2str(j)]);
                addOutregN2_re(i,j).SimulinkRate=slRate;
                addOutregN2_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['addOutregN2_im_',num2str(i),'_',num2str(j)]);
                addOutregN2_im(i,j).SimulinkRate=slRate;
                addOutregN2out_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['addOutregN2out_re_',num2str(i),'_',num2str(j)]);
                addOutregN2out_re(i,j).SimulinkRate=slRate;
                addOutregN2out_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['addOutregN2out_im_',num2str(i),'_',num2str(j)]);
                addOutregN2out_im(i,j).SimulinkRate=slRate;
                addOutregN3_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['addOutregN3_re_',num2str(i),'_',num2str(j)]);
                addOutregN3_re(i,j).SimulinkRate=slRate;
                addOutregN3_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['addOutregN3_im_',num2str(i),'_',num2str(j)]);
                addOutregN3_im(i,j).SimulinkRate=slRate;
                addOutregN3out_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['addOutregN3out_re_',num2str(i),'_',num2str(j)]);
                addOutregN3out_re(i,j).SimulinkRate=slRate;
                addOutregN3out_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['addOutregN3out_im_',num2str(i),'_',num2str(j)]);
                addOutregN3out_im(i,j).SimulinkRate=slRate;
                addOutregN4_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['addOutregN4_re_',num2str(i),'_',num2str(j)]);
                addOutregN4_re(i,j).SimulinkRate=slRate;
                addOutregN4_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['addOutregN4_im_',num2str(i),'_',num2str(j)]);
                addOutregN4_im(i,j).SimulinkRate=slRate;
                addOutregN4out_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['addOutregN4out_re_',num2str(i),'_',num2str(j)]);
                addOutregN4out_re(i,j).SimulinkRate=slRate;
                addOutregN4out_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['addOutregN4out_im_',num2str(i),'_',num2str(j)]);
                addOutregN4out_im(i,j).SimulinkRate=slRate;
                addOutregN5_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),['addOutregN5_re_',num2str(i),'_',num2str(j)]);
                addOutregN5_re(i,j).SimulinkRate=slRate;
                addOutregN5_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),['addOutregN5_im_',num2str(i),'_',num2str(j)]);
                addOutregN5_im(i,j).SimulinkRate=slRate;
                addOutregN5out_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),['addOutregN5out_re_',num2str(i),'_',num2str(j)]);
                addOutregN5out_re(i,j).SimulinkRate=slRate;
                addOutregN5out_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),['addOutregN5out_im_',num2str(i),'_',num2str(j)]);
                addOutregN5out_im(i,j).SimulinkRate=slRate;
            end


            part1RegN1_re(i)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['part1RegN1_re',num2str(i)]);
            part1RegN1_re(i).SimulinkRate=slRate;
            part1RegN1_im(i)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['part1RegN1_im',num2str(i)]);
            part1RegN1_im(i).SimulinkRate=slRate;


            dataOutIntN1_re(i)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['dataOutIntN1_re',num2str(i)]);
            dataOutIntN1_re(i).SimulinkRate=slRate;
            dataOutIntN1_im(i)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['dataOutIntN1_im',num2str(i)]);
            dataOutIntN1_im(i).SimulinkRate=slRate;
            part1RegN2_re(i)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['part1RegN2_re',num2str(i)]);
            part1RegN2_re(i).SimulinkRate=slRate;
            part1RegN2_im(i)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['part1RegN2_im',num2str(i)]);
            part1RegN2_im(i).SimulinkRate=slRate;
            dataOutIntN2_re(i)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['dataOutIntN2_re',num2str(i)]);
            dataOutIntN2_re(i).SimulinkRate=slRate;
            dataOutIntN2_im(i)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['dataOutIntN2_im',num2str(i)]);
            dataOutIntN2_im(i).SimulinkRate=slRate;
            part1RegN3_re(i)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['part1RegN3_re',num2str(i)]);
            part1RegN3_re(i).SimulinkRate=slRate;
            part1RegN3_im(i)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['part1RegN3_im',num2str(i)]);
            part1RegN3_im(i).SimulinkRate=slRate;
            dataOutIntN3_re(i)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['dataOutIntN3_re',num2str(i)]);
            dataOutIntN3_re(i).SimulinkRate=slRate;
            dataOutIntN3_im(i)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['dataOutIntN3_im',num2str(i)]);
            dataOutIntN3_im(i).SimulinkRate=slRate;
            part1RegN4_re(i)=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['part1RegN4_re',num2str(i)]);
            part1RegN4_re(i).SimulinkRate=slRate;
            part1RegN4_im(i)=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['part1RegN4_im',num2str(i)]);
            part1RegN4_im(i).SimulinkRate=slRate;
            dataOutIntN4_re(i)=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['dataOutIntN4_re',num2str(i)]);
            dataOutIntN4_re(i).SimulinkRate=slRate;
            dataOutIntN4_im(i)=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['dataOutIntN4_im',num2str(i)]);
            dataOutIntN4_im(i).SimulinkRate=slRate;
            part1RegN5_re(i)=iSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),['part1RegN5_re',num2str(i)]);
            part1RegN5_re(i).SimulinkRate=slRate;
            part1RegN5_im(i)=iSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),['part1RegN5_im',num2str(i)]);
            part1RegN5_im(i).SimulinkRate=slRate;
            dataOutIntN5_re(i)=iSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),['dataOutIntN5_re',num2str(i)]);
            dataOutIntN5_re(i).SimulinkRate=slRate;
            dataOutIntN5_im(i)=iSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),['dataOutIntN5_im',num2str(i)]);
            dataOutIntN5_im(i).SimulinkRate=slRate;
        end


        for i=1:blockInfo.vecsize
            pirelab.getAddComp(iSection,[inmuxoutre(i),addOutregN1_re(i,1)],addOutregN1out_re(i,1));
            pirelab.getAddComp(iSection,[inmuxoutim(i),addOutregN1_im(i,1)],addOutregN1out_im(i,1));
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_re(i,1),addOutregN1_re(i,1),validInreg,internalReset,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_im(i,1),addOutregN1_im(i,1),validInreg,internalReset,1);
        end
        for part=2:blockInfo.vecsize
            pirelab.getIntDelayComp(iSection,addOutregN1_re(part,1),part1RegN1_re(part),part-1);
            pirelab.getIntDelayComp(iSection,addOutregN1_im(part,1),part1RegN1_im(part),part-1);
            for i=1:blockInfo.vecsize
                if i<part
                    pirelab.getAddComp(iSection,[addOutregN1_re(i,part-1),part1RegN1_re(part)],addOutregN1out_re(i,part));
                    pirelab.getAddComp(iSection,[addOutregN1_im(i,part-1),part1RegN1_im(part)],addOutregN1out_im(i,part));
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_re(i,part),addOutregN1_re(i,part),1,internalReset,1);
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_im(i,part),addOutregN1_im(i,part),1,internalReset,1);
                else
                    if part==2
                        pirelab.getAddComp(iSection,[addOutregN1_re(1,part-1),addOutregN1_re(part,1)],addOutregN1out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN1_im(1,part-1),addOutregN1_im(part,1)],addOutregN1out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_re(i,part),addOutregN1_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_im(i,part),addOutregN1_im(i,part),1,internalReset,1);
                    else
                        partN1_re=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),'partN1_re');
                        partN1_im=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),'partN1_im');
                        pirelab.getIntDelayComp(iSection,addOutregN1_re(part,1),partN1_re,part-2);
                        pirelab.getIntDelayComp(iSection,addOutregN1_im(part,1),partN1_im,part-2);
                        pirelab.getAddComp(iSection,[addOutregN1_re(i,part-1),partN1_re],addOutregN1out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN1_im(i,part-1),partN1_im],addOutregN1out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_re(i,part),addOutregN1_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_im(i,part),addOutregN1_im(i,part),1,internalReset,1);
                    end
                end
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1_re(i,blockInfo.vecsize),dataOutIntN1_re(i),1,internalReset,1);
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1_im(i,blockInfo.vecsize),dataOutIntN1_im(i),1,internalReset,1);
            end
        end
        validInregN2=iSection.addSignal(out3.Type,'validInregN2');
        pirelab.getIntDelayComp(iSection,validInreg,validInregN2,blockInfo.vecsize+1,'',0);
        internalResetN2=iSection.addSignal(out3.Type,'internalResetN2');
        pirelab.getIntDelayComp(iSection,internalReset,internalResetN2,blockInfo.vecsize+1,'',0);
        for i=1:blockInfo.vecsize
            pirelab.getAddComp(iSection,[dataOutIntN1_re(i),addOutregN2_re(i,1)],addOutregN2out_re(i,1));
            pirelab.getAddComp(iSection,[dataOutIntN1_im(i),addOutregN2_im(i,1)],addOutregN2out_im(i,1));
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_re(i,1),addOutregN2_re(i,1),validInregN2,internalResetN2,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_im(i,1),addOutregN2_im(i,1),validInregN2,internalResetN2,1);
        end
        for part=2:blockInfo.vecsize
            pirelab.getIntDelayComp(iSection,addOutregN2_re(part,1),part1RegN2_re(part),part-1);
            pirelab.getIntDelayComp(iSection,addOutregN2_im(part,1),part1RegN2_im(part),part-1);
            for i=1:blockInfo.vecsize
                if i<part
                    pirelab.getAddComp(iSection,[addOutregN2_re(i,part-1),part1RegN2_re(part)],addOutregN2out_re(i,part));
                    pirelab.getAddComp(iSection,[addOutregN2_im(i,part-1),part1RegN2_im(part)],addOutregN2out_im(i,part));
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_re(i,part),addOutregN2_re(i,part),1,internalReset,1);
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_im(i,part),addOutregN2_im(i,part),1,internalReset,1);
                else
                    if part==2
                        pirelab.getAddComp(iSection,[addOutregN2_re(1,part-1),addOutregN2_re(part,1)],addOutregN2out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN2_im(1,part-1),addOutregN2_im(part,1)],addOutregN2out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_re(i,part),addOutregN2_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_im(i,part),addOutregN2_im(i,part),1,internalReset,1);
                    else
                        partN2_re=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),'partN2_re');
                        partN2_im=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),'partN2_im');
                        pirelab.getIntDelayComp(iSection,addOutregN2_re(part,1),partN2_re,part-2);
                        pirelab.getIntDelayComp(iSection,addOutregN2_im(part,1),partN2_im,part-2);
                        pirelab.getAddComp(iSection,[addOutregN2_re(i,part-1),partN2_re],addOutregN2out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN2_im(i,part-1),partN2_im],addOutregN2out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_re(i,part),addOutregN2_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_im(i,part),addOutregN2_im(i,part),1,internalReset,1);
                    end
                end
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2_re(i,blockInfo.vecsize),dataOutIntN2_re(i),1,internalReset,1);
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2_im(i,blockInfo.vecsize),dataOutIntN2_im(i),1,internalReset,1);
            end
        end
        validInregN3=iSection.addSignal(out3.Type,'validInregN3');
        pirelab.getIntDelayComp(iSection,validInregN2,validInregN3,blockInfo.vecsize+1,'',0);
        internalResetN3=iSection.addSignal(out3.Type,'internalResetN3');
        pirelab.getIntDelayComp(iSection,internalResetN2,internalResetN3,blockInfo.vecsize+1,'',0);
        for i=1:blockInfo.vecsize
            pirelab.getAddComp(iSection,[dataOutIntN2_re(i),addOutregN3_re(i,1)],addOutregN3out_re(i,1));
            pirelab.getAddComp(iSection,[dataOutIntN2_im(i),addOutregN3_im(i,1)],addOutregN3out_im(i,1));
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_re(i,1),addOutregN3_re(i,1),validInregN3,internalResetN3,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_im(i,1),addOutregN3_im(i,1),validInregN3,internalResetN3,1);
        end
        for part=2:blockInfo.vecsize
            pirelab.getIntDelayComp(iSection,addOutregN3_re(part,1),part1RegN3_re(part),part-1);
            pirelab.getIntDelayComp(iSection,addOutregN3_im(part,1),part1RegN3_im(part),part-1);
            for i=1:blockInfo.vecsize
                if i<part
                    pirelab.getAddComp(iSection,[addOutregN3_re(i,part-1),part1RegN3_re(part)],addOutregN3out_re(i,part));
                    pirelab.getAddComp(iSection,[addOutregN3_im(i,part-1),part1RegN3_im(part)],addOutregN3out_im(i,part));
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_re(i,part),addOutregN3_re(i,part),1,internalReset,1);
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_im(i,part),addOutregN3_im(i,part),1,internalReset,1);
                else
                    if part==2
                        pirelab.getAddComp(iSection,[addOutregN3_re(1,part-1),addOutregN3_re(part,1)],addOutregN3out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN3_im(1,part-1),addOutregN3_im(part,1)],addOutregN3out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_re(i,part),addOutregN3_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_im(i,part),addOutregN3_im(i,part),1,internalReset,1);
                    else
                        partN3_re=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),'partN3_re');
                        partN3_im=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),'partN3_im');
                        pirelab.getIntDelayComp(iSection,addOutregN3_re(part,1),partN3_re,part-2);
                        pirelab.getIntDelayComp(iSection,addOutregN3_im(part,1),partN3_im,part-2);
                        pirelab.getAddComp(iSection,[addOutregN3_re(i,part-1),partN3_re],addOutregN3out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN3_im(i,part-1),partN3_im],addOutregN3out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_re(i,part),addOutregN3_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_im(i,part),addOutregN3_im(i,part),1,internalReset,1);
                    end
                end
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3_re(i,blockInfo.vecsize),dataOutIntN3_re(i),1,internalReset,1);
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3_im(i,blockInfo.vecsize),dataOutIntN3_im(i),1,internalReset,1);
            end
        end
        validInregN4=iSection.addSignal(out3.Type,'validInregN4');
        pirelab.getIntDelayComp(iSection,validInregN3,validInregN4,blockInfo.vecsize+1,'',0);
        internalResetN4=iSection.addSignal(out3.Type,'internalResetN4');
        pirelab.getIntDelayComp(iSection,internalResetN3,internalResetN4,blockInfo.vecsize+1,'',0);
        for i=1:blockInfo.vecsize
            pirelab.getAddComp(iSection,[dataOutIntN3_re(i),addOutregN4_re(i,1)],addOutregN4out_re(i,1));
            pirelab.getAddComp(iSection,[dataOutIntN3_im(i),addOutregN4_im(i,1)],addOutregN4out_im(i,1));
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4out_re(i,1),addOutregN4_re(i,1),validInregN4,internalResetN4,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4out_im(i,1),addOutregN4_im(i,1),validInregN4,internalResetN4,1);
        end
        for part=2:blockInfo.vecsize
            pirelab.getIntDelayComp(iSection,addOutregN4_re(part,1),part1RegN4_re(part),part-1);
            pirelab.getIntDelayComp(iSection,addOutregN4_im(part,1),part1RegN4_im(part),part-1);
            for i=1:blockInfo.vecsize
                if i<part
                    pirelab.getAddComp(iSection,[addOutregN4_re(i,part-1),part1RegN4_re(part)],addOutregN4out_re(i,part));
                    pirelab.getAddComp(iSection,[addOutregN4_im(i,part-1),part1RegN4_im(part)],addOutregN4out_im(i,part));
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4out_re(i,part),addOutregN4_re(i,part),1,internalReset,1);
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4out_im(i,part),addOutregN4_im(i,part),1,internalReset,1);
                else
                    if part==2
                        pirelab.getAddComp(iSection,[addOutregN4_re(1,part-1),addOutregN4_re(part,1)],addOutregN4out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN4_im(1,part-1),addOutregN4_im(part,1)],addOutregN4out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4out_re(i,part),addOutregN4_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4out_im(i,part),addOutregN4_im(i,part),1,internalReset,1);
                    else
                        partN4_re=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),'partN4_re');
                        partN4_im=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),'partN4_im');
                        pirelab.getIntDelayComp(iSection,addOutregN4_re(part,1),partN4_re,part-2);
                        pirelab.getIntDelayComp(iSection,addOutregN4_im(part,1),partN4_im,part-2);
                        pirelab.getAddComp(iSection,[addOutregN4_re(i,part-1),partN4_re],addOutregN4out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN4_im(i,part-1),partN4_im],addOutregN4out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4out_re(i,part),addOutregN4_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4out_im(i,part),addOutregN4_im(i,part),1,internalReset,1);
                    end
                end
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4_re(i,blockInfo.vecsize),dataOutIntN4_re(i),1,internalReset,1);
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4_im(i,blockInfo.vecsize),dataOutIntN4_im(i),1,internalReset,1);
            end
        end
        validInregN5=iSection.addSignal(out3.Type,'validInregN5');
        pirelab.getIntDelayComp(iSection,validInregN4,validInregN5,blockInfo.vecsize+1,'',0);
        internalResetN5=iSection.addSignal(out3.Type,'internalResetN5');
        pirelab.getIntDelayComp(iSection,internalResetN4,internalResetN5,blockInfo.vecsize+1,'',0);
        for i=1:blockInfo.vecsize
            pirelab.getAddComp(iSection,[dataOutIntN4_re(i),addOutregN5_re(i,1)],addOutregN5out_re(i,1));
            pirelab.getAddComp(iSection,[dataOutIntN4_im(i),addOutregN5_im(i,1)],addOutregN5out_im(i,1));
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN5out_re(i,1),addOutregN5_re(i,1),validInregN5,internalResetN5,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN5out_im(i,1),addOutregN5_im(i,1),validInregN5,internalResetN5,1);
        end
        for part=2:blockInfo.vecsize
            pirelab.getIntDelayComp(iSection,addOutregN5_re(part,1),part1RegN5_re(part),part-1);
            pirelab.getIntDelayComp(iSection,addOutregN5_im(part,1),part1RegN5_im(part),part-1);
            for i=1:blockInfo.vecsize
                if i<part
                    pirelab.getAddComp(iSection,[addOutregN5_re(i,part-1),part1RegN5_re(part)],addOutregN5out_re(i,part));
                    pirelab.getAddComp(iSection,[addOutregN5_im(i,part-1),part1RegN5_im(part)],addOutregN5out_im(i,part));
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN5out_re(i,part),addOutregN5_re(i,part),1,internalReset,1);
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN5out_im(i,part),addOutregN5_im(i,part),1,internalReset,1);
                else
                    if part==2
                        pirelab.getAddComp(iSection,[addOutregN5_re(1,part-1),addOutregN5_re(part,1)],addOutregN5out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN5_im(1,part-1),addOutregN5_im(part,1)],addOutregN5out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN5out_re(i,part),addOutregN5_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN5out_im(i,part),addOutregN5_im(i,part),1,internalReset,1);
                    else
                        partN5_re=iSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),'partN5_re');
                        partN5_im=iSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),'partN5_im');
                        pirelab.getIntDelayComp(iSection,addOutregN5_re(part,1),partN5_re,part-2);
                        pirelab.getIntDelayComp(iSection,addOutregN5_im(part,1),partN5_im,part-2);
                        pirelab.getAddComp(iSection,[addOutregN5_re(i,part-1),partN5_re],addOutregN5out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN5_im(i,part-1),partN5_im],addOutregN5out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN5out_re(i,part),addOutregN5_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN5out_im(i,part),addOutregN5_im(i,part),1,internalReset,1);
                    end
                end
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN5_re(i,blockInfo.vecsize),dataOutIntN5_re(i),1,internalReset,1);
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN5_im(i,blockInfo.vecsize),dataOutIntN5_im(i),1,internalReset,1);
            end
        end
        validInregN6=iSection.addSignal(out3.Type,'validInregN6');
        pirelab.getIntDelayComp(iSection,validInregN5,validInregN6,blockInfo.vecsize+1,'',0);
        internalResetN6=iSection.addSignal(out3.Type,'internalResetN6');
        pirelab.getIntDelayComp(iSection,internalResetN5,internalResetN6,blockInfo.vecsize+1,'',0);
        for i=1:blockInfo.vecsize
            pirelab.getWireComp(iSection,dataOutIntN5_re(i),iOutreg_re(i));
            pirelab.getWireComp(iSection,dataOutIntN5_im(i),iOutreg_im(i));
            pirelab.getIntDelayEnabledResettableComp(iSection,iOutreg_re(i),iOut_re(i),validInregN6,internalResetN6,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,iOutreg_im(i),iOut_im(i),validInregN6,internalResetN6,1);
        end
        pirelab.getIntDelayComp(iSection,validInregN6,i_voutreg,1);
        pirelab.getIntDelayComp(iSection,internalResetN6,i_rstoutreg,1);
    case 6
        stage2WL=dTypeN(2).BaseType.WordLength;
        stage2FL=dTypeN(2).BaseType.FractionLength;
        stage3WL=dTypeN(3).BaseType.WordLength;
        stage3FL=dTypeN(3).BaseType.FractionLength;
        stage4WL=dTypeN(4).BaseType.WordLength;
        stage4FL=dTypeN(4).BaseType.FractionLength;
        stage5WL=dTypeN(5).BaseType.WordLength;
        stage5FL=dTypeN(5).BaseType.FractionLength;
        stage6WL=dTypeN(6).BaseType.WordLength;
        stage6FL=dTypeN(6).BaseType.FractionLength;
        for i=1:blockInfo.vecsize

            for j=1:blockInfo.vecsize
                addOutregN1_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['addOutregN1_re_',num2str(i),'_',num2str(j)]);
                addOutregN1_re(i,j).SimulinkRate=slRate;
                addOutregN1_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['addOutregN1_im_',num2str(i),'_',num2str(j)]);
                addOutregN1_im(i,j).SimulinkRate=slRate;
                addOutregN1out_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['addOutregN1out_re_',num2str(i),'_',num2str(j)]);
                addOutregN1out_re(i,j).SimulinkRate=slRate;
                addOutregN1out_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['addOutregN1out_im_',num2str(i),'_',num2str(j)]);
                addOutregN1out_im(i,j).SimulinkRate=slRate;
                addOutregN2_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['addOutregN2_re_',num2str(i),'_',num2str(j)]);
                addOutregN2_re(i,j).SimulinkRate=slRate;
                addOutregN2_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['addOutregN2_im_',num2str(i),'_',num2str(j)]);
                addOutregN2_im(i,j).SimulinkRate=slRate;
                addOutregN2out_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['addOutregN2out_re_',num2str(i),'_',num2str(j)]);
                addOutregN2out_re(i,j).SimulinkRate=slRate;
                addOutregN2out_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['addOutregN2out_im_',num2str(i),'_',num2str(j)]);
                addOutregN2out_im(i,j).SimulinkRate=slRate;
                addOutregN3_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['addOutregN3_re_',num2str(i),'_',num2str(j)]);
                addOutregN3_re(i,j).SimulinkRate=slRate;
                addOutregN3_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['addOutregN3_im_',num2str(i),'_',num2str(j)]);
                addOutregN3_im(i,j).SimulinkRate=slRate;
                addOutregN3out_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['addOutregN3out_re_',num2str(i),'_',num2str(j)]);
                addOutregN3out_re(i,j).SimulinkRate=slRate;
                addOutregN3out_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['addOutregN3out_im_',num2str(i),'_',num2str(j)]);
                addOutregN3out_im(i,j).SimulinkRate=slRate;
                addOutregN4_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['addOutregN4_re_',num2str(i),'_',num2str(j)]);
                addOutregN4_re(i,j).SimulinkRate=slRate;
                addOutregN4_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['addOutregN4_im_',num2str(i),'_',num2str(j)]);
                addOutregN4_im(i,j).SimulinkRate=slRate;
                addOutregN4out_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['addOutregN4out_re_',num2str(i),'_',num2str(j)]);
                addOutregN4out_re(i,j).SimulinkRate=slRate;
                addOutregN4out_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['addOutregN4out_im_',num2str(i),'_',num2str(j)]);
                addOutregN4out_im(i,j).SimulinkRate=slRate;
                addOutregN5_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),['addOutregN5_re_',num2str(i),'_',num2str(j)]);
                addOutregN5_re(i,j).SimulinkRate=slRate;
                addOutregN5_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),['addOutregN5_im_',num2str(i),'_',num2str(j)]);
                addOutregN5_im(i,j).SimulinkRate=slRate;
                addOutregN5out_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),['addOutregN5out_re_',num2str(i),'_',num2str(j)]);
                addOutregN5out_re(i,j).SimulinkRate=slRate;
                addOutregN5out_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),['addOutregN5out_im_',num2str(i),'_',num2str(j)]);
                addOutregN5out_im(i,j).SimulinkRate=slRate;
                addOutregN6_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage6WL,stage6FL),['addOutregN6_re_',num2str(i),'_',num2str(j)]);
                addOutregN6_re(i,j).SimulinkRate=slRate;
                addOutregN6_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage6WL,stage6FL),['addOutregN6_im_',num2str(i),'_',num2str(j)]);
                addOutregN6_im(i,j).SimulinkRate=slRate;
                addOutregN6out_re(i,j)=iSection.addSignal(pir_sfixpt_t(stage6WL,stage6FL),['addOutregN6out_re_',num2str(i),'_',num2str(j)]);
                addOutregN6out_re(i,j).SimulinkRate=slRate;
                addOutregN6out_im(i,j)=iSection.addSignal(pir_sfixpt_t(stage6WL,stage6FL),['addOutregN6out_im_',num2str(i),'_',num2str(j)]);
                addOutregN6out_im(i,j).SimulinkRate=slRate;
            end


            part1RegN1_re(i)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['part1RegN1_re',num2str(i)]);
            part1RegN1_re(i).SimulinkRate=slRate;
            part1RegN1_im(i)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['part1RegN1_im',num2str(i)]);
            part1RegN1_im(i).SimulinkRate=slRate;


            dataOutIntN1_re(i)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['dataOutIntN1_re',num2str(i)]);
            dataOutIntN1_re(i).SimulinkRate=slRate;
            dataOutIntN1_im(i)=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),['dataOutIntN1_im',num2str(i)]);
            dataOutIntN1_im(i).SimulinkRate=slRate;
            part1RegN2_re(i)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['part1RegN2_re',num2str(i)]);
            part1RegN2_re(i).SimulinkRate=slRate;
            part1RegN2_im(i)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['part1RegN2_im',num2str(i)]);
            part1RegN2_im(i).SimulinkRate=slRate;
            dataOutIntN2_re(i)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['dataOutIntN2_re',num2str(i)]);
            dataOutIntN2_re(i).SimulinkRate=slRate;
            dataOutIntN2_im(i)=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),['dataOutIntN2_im',num2str(i)]);
            dataOutIntN2_im(i).SimulinkRate=slRate;
            part1RegN3_re(i)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['part1RegN3_re',num2str(i)]);
            part1RegN3_re(i).SimulinkRate=slRate;
            part1RegN3_im(i)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['part1RegN3_im',num2str(i)]);
            part1RegN3_im(i).SimulinkRate=slRate;
            dataOutIntN3_re(i)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['dataOutIntN3_re',num2str(i)]);
            dataOutIntN3_re(i).SimulinkRate=slRate;
            dataOutIntN3_im(i)=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),['dataOutIntN3_im',num2str(i)]);
            dataOutIntN3_im(i).SimulinkRate=slRate;
            part1RegN4_re(i)=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['part1RegN4_re',num2str(i)]);
            part1RegN4_re(i).SimulinkRate=slRate;
            part1RegN4_im(i)=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['part1RegN4_im',num2str(i)]);
            part1RegN4_im(i).SimulinkRate=slRate;
            dataOutIntN4_re(i)=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['dataOutIntN4_re',num2str(i)]);
            dataOutIntN4_re(i).SimulinkRate=slRate;
            dataOutIntN4_im(i)=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),['dataOutIntN4_im',num2str(i)]);
            dataOutIntN4_im(i).SimulinkRate=slRate;
            part1RegN5_re(i)=iSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),['part1RegN5_re',num2str(i)]);
            part1RegN5_re(i).SimulinkRate=slRate;
            part1RegN5_im(i)=iSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),['part1RegN5_im',num2str(i)]);
            part1RegN5_im(i).SimulinkRate=slRate;
            dataOutIntN5_re(i)=iSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),['dataOutIntN5_re',num2str(i)]);
            dataOutIntN5_re(i).SimulinkRate=slRate;
            dataOutIntN5_im(i)=iSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),['dataOutIntN5_im',num2str(i)]);
            dataOutIntN5_im(i).SimulinkRate=slRate;
            part1RegN6_re(i)=iSection.addSignal(pir_sfixpt_t(stage6WL,stage6FL),['part1RegN6_re',num2str(i)]);
            part1RegN6_re(i).SimulinkRate=slRate;
            part1RegN6_im(i)=iSection.addSignal(pir_sfixpt_t(stage6WL,stage6FL),['part1RegN6_im',num2str(i)]);
            part1RegN6_im(i).SimulinkRate=slRate;
            dataOutIntN6_re(i)=iSection.addSignal(pir_sfixpt_t(stage6WL,stage6FL),['dataOutIntN6_re',num2str(i)]);
            dataOutIntN6_re(i).SimulinkRate=slRate;
            dataOutIntN6_im(i)=iSection.addSignal(pir_sfixpt_t(stage6WL,stage6FL),['dataOutIntN6_im',num2str(i)]);
            dataOutIntN6_im(i).SimulinkRate=slRate;
        end


        for i=1:blockInfo.vecsize
            pirelab.getAddComp(iSection,[inmuxoutre(i),addOutregN1_re(i,1)],addOutregN1out_re(i,1));
            pirelab.getAddComp(iSection,[inmuxoutim(i),addOutregN1_im(i,1)],addOutregN1out_im(i,1));
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_re(i,1),addOutregN1_re(i,1),validInreg,internalReset,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_im(i,1),addOutregN1_im(i,1),validInreg,internalReset,1);
        end
        for part=2:blockInfo.vecsize
            pirelab.getIntDelayComp(iSection,addOutregN1_re(part,1),part1RegN1_re(part),part-1);
            pirelab.getIntDelayComp(iSection,addOutregN1_im(part,1),part1RegN1_im(part),part-1);
            for i=1:blockInfo.vecsize
                if i<part
                    pirelab.getAddComp(iSection,[addOutregN1_re(i,part-1),part1RegN1_re(part)],addOutregN1out_re(i,part));
                    pirelab.getAddComp(iSection,[addOutregN1_im(i,part-1),part1RegN1_im(part)],addOutregN1out_im(i,part));
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_re(i,part),addOutregN1_re(i,part),1,internalReset,1);
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_im(i,part),addOutregN1_im(i,part),1,internalReset,1);
                else
                    if part==2
                        pirelab.getAddComp(iSection,[addOutregN1_re(1,part-1),addOutregN1_re(part,1)],addOutregN1out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN1_im(1,part-1),addOutregN1_im(part,1)],addOutregN1out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_re(i,part),addOutregN1_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_im(i,part),addOutregN1_im(i,part),1,internalReset,1);
                    else
                        partN1_re=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),'partN1_re');
                        partN1_im=iSection.addSignal(pir_sfixpt_t(stage1WL,stage1FL),'partN1_im');
                        pirelab.getIntDelayComp(iSection,addOutregN1_re(part,1),partN1_re,part-2);
                        pirelab.getIntDelayComp(iSection,addOutregN1_im(part,1),partN1_im,part-2);
                        pirelab.getAddComp(iSection,[addOutregN1_re(i,part-1),partN1_re],addOutregN1out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN1_im(i,part-1),partN1_im],addOutregN1out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_re(i,part),addOutregN1_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1out_im(i,part),addOutregN1_im(i,part),1,internalReset,1);
                    end
                end
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1_re(i,blockInfo.vecsize),dataOutIntN1_re(i),1,internalReset,1);
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN1_im(i,blockInfo.vecsize),dataOutIntN1_im(i),1,internalReset,1);
            end
        end
        validInregN2=iSection.addSignal(out3.Type,'validInregN2');
        pirelab.getIntDelayComp(iSection,validInreg,validInregN2,blockInfo.vecsize+1,'',0);
        internalResetN2=iSection.addSignal(out3.Type,'internalResetN2');
        pirelab.getIntDelayComp(iSection,internalReset,internalResetN2,blockInfo.vecsize+1,'',0);
        for i=1:blockInfo.vecsize
            pirelab.getAddComp(iSection,[dataOutIntN1_re(i),addOutregN2_re(i,1)],addOutregN2out_re(i,1));
            pirelab.getAddComp(iSection,[dataOutIntN1_im(i),addOutregN2_im(i,1)],addOutregN2out_im(i,1));
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_re(i,1),addOutregN2_re(i,1),validInregN2,internalResetN2,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_im(i,1),addOutregN2_im(i,1),validInregN2,internalResetN2,1);
        end
        for part=2:blockInfo.vecsize
            pirelab.getIntDelayComp(iSection,addOutregN2_re(part,1),part1RegN2_re(part),part-1);
            pirelab.getIntDelayComp(iSection,addOutregN2_im(part,1),part1RegN2_im(part),part-1);
            for i=1:blockInfo.vecsize
                if i<part
                    pirelab.getAddComp(iSection,[addOutregN2_re(i,part-1),part1RegN2_re(part)],addOutregN2out_re(i,part));
                    pirelab.getAddComp(iSection,[addOutregN2_im(i,part-1),part1RegN2_im(part)],addOutregN2out_im(i,part));
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_re(i,part),addOutregN2_re(i,part),1,internalReset,1);
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_im(i,part),addOutregN2_im(i,part),1,internalReset,1);
                else
                    if part==2
                        pirelab.getAddComp(iSection,[addOutregN2_re(1,part-1),addOutregN2_re(part,1)],addOutregN2out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN2_im(1,part-1),addOutregN2_im(part,1)],addOutregN2out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_re(i,part),addOutregN2_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_im(i,part),addOutregN2_im(i,part),1,internalReset,1);
                    else
                        partN2_re=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),'partN2_re');
                        partN2_im=iSection.addSignal(pir_sfixpt_t(stage2WL,stage2FL),'partN2_im');
                        pirelab.getIntDelayComp(iSection,addOutregN2_re(part,1),partN2_re,part-2);
                        pirelab.getIntDelayComp(iSection,addOutregN2_im(part,1),partN2_im,part-2);
                        pirelab.getAddComp(iSection,[addOutregN2_re(i,part-1),partN2_re],addOutregN2out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN2_im(i,part-1),partN2_im],addOutregN2out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_re(i,part),addOutregN2_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2out_im(i,part),addOutregN2_im(i,part),1,internalReset,1);
                    end
                end
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2_re(i,blockInfo.vecsize),dataOutIntN2_re(i),1,internalReset,1);
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN2_im(i,blockInfo.vecsize),dataOutIntN2_im(i),1,internalReset,1);
            end
        end
        validInregN3=iSection.addSignal(out3.Type,'validInregN3');
        pirelab.getIntDelayComp(iSection,validInregN2,validInregN3,blockInfo.vecsize+1,'',0);
        internalResetN3=iSection.addSignal(out3.Type,'internalResetN3');
        pirelab.getIntDelayComp(iSection,internalResetN2,internalResetN3,blockInfo.vecsize+1,'',0);
        for i=1:blockInfo.vecsize
            pirelab.getAddComp(iSection,[dataOutIntN2_re(i),addOutregN3_re(i,1)],addOutregN3out_re(i,1));
            pirelab.getAddComp(iSection,[dataOutIntN2_im(i),addOutregN3_im(i,1)],addOutregN3out_im(i,1));
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_re(i,1),addOutregN3_re(i,1),validInregN3,internalResetN3,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_im(i,1),addOutregN3_im(i,1),validInregN3,internalResetN3,1);
        end
        for part=2:blockInfo.vecsize
            pirelab.getIntDelayComp(iSection,addOutregN3_re(part,1),part1RegN3_re(part),part-1);
            pirelab.getIntDelayComp(iSection,addOutregN3_im(part,1),part1RegN3_im(part),part-1);
            for i=1:blockInfo.vecsize
                if i<part
                    pirelab.getAddComp(iSection,[addOutregN3_re(i,part-1),part1RegN3_re(part)],addOutregN3out_re(i,part));
                    pirelab.getAddComp(iSection,[addOutregN3_im(i,part-1),part1RegN3_im(part)],addOutregN3out_im(i,part));
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_re(i,part),addOutregN3_re(i,part),1,internalReset,1);
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_im(i,part),addOutregN3_im(i,part),1,internalReset,1);
                else
                    if part==2
                        pirelab.getAddComp(iSection,[addOutregN3_re(1,part-1),addOutregN3_re(part,1)],addOutregN3out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN3_im(1,part-1),addOutregN3_im(part,1)],addOutregN3out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_re(i,part),addOutregN3_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_im(i,part),addOutregN3_im(i,part),1,internalReset,1);
                    else
                        partN3_re=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),'partN3_re');
                        partN3_im=iSection.addSignal(pir_sfixpt_t(stage3WL,stage3FL),'partN3_im');
                        pirelab.getIntDelayComp(iSection,addOutregN3_re(part,1),partN3_re,part-2);
                        pirelab.getIntDelayComp(iSection,addOutregN3_im(part,1),partN3_im,part-2);
                        pirelab.getAddComp(iSection,[addOutregN3_re(i,part-1),partN3_re],addOutregN3out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN3_im(i,part-1),partN3_im],addOutregN3out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_re(i,part),addOutregN3_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3out_im(i,part),addOutregN3_im(i,part),1,internalReset,1);
                    end
                end
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3_re(i,blockInfo.vecsize),dataOutIntN3_re(i),1,internalReset,1);
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN3_im(i,blockInfo.vecsize),dataOutIntN3_im(i),1,internalReset,1);
            end
        end
        validInregN4=iSection.addSignal(out3.Type,'validInregN4');
        pirelab.getIntDelayComp(iSection,validInregN3,validInregN4,blockInfo.vecsize+1,'',0);
        internalResetN4=iSection.addSignal(out3.Type,'internalResetN4');
        pirelab.getIntDelayComp(iSection,internalResetN3,internalResetN4,blockInfo.vecsize+1,'',0);
        for i=1:blockInfo.vecsize
            pirelab.getAddComp(iSection,[dataOutIntN3_re(i),addOutregN4_re(i,1)],addOutregN4out_re(i,1));
            pirelab.getAddComp(iSection,[dataOutIntN3_im(i),addOutregN4_im(i,1)],addOutregN4out_im(i,1));
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4out_re(i,1),addOutregN4_re(i,1),validInregN4,internalResetN4,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4out_im(i,1),addOutregN4_im(i,1),validInregN4,internalResetN4,1);
        end
        for part=2:blockInfo.vecsize
            pirelab.getIntDelayComp(iSection,addOutregN4_re(part,1),part1RegN4_re(part),part-1);
            pirelab.getIntDelayComp(iSection,addOutregN4_im(part,1),part1RegN4_im(part),part-1);
            for i=1:blockInfo.vecsize
                if i<part
                    pirelab.getAddComp(iSection,[addOutregN4_re(i,part-1),part1RegN4_re(part)],addOutregN4out_re(i,part));
                    pirelab.getAddComp(iSection,[addOutregN4_im(i,part-1),part1RegN4_im(part)],addOutregN4out_im(i,part));
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4out_re(i,part),addOutregN4_re(i,part),1,internalReset,1);
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4out_im(i,part),addOutregN4_im(i,part),1,internalReset,1);
                else
                    if part==2
                        pirelab.getAddComp(iSection,[addOutregN4_re(1,part-1),addOutregN4_re(part,1)],addOutregN4out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN4_im(1,part-1),addOutregN4_im(part,1)],addOutregN4out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4out_re(i,part),addOutregN4_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4out_im(i,part),addOutregN4_im(i,part),1,internalReset,1);
                    else
                        partN4_re=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),'partN4_re');
                        partN4_im=iSection.addSignal(pir_sfixpt_t(stage4WL,stage4FL),'partN4_im');
                        pirelab.getIntDelayComp(iSection,addOutregN4_re(part,1),partN4_re,part-2);
                        pirelab.getIntDelayComp(iSection,addOutregN4_im(part,1),partN4_im,part-2);
                        pirelab.getAddComp(iSection,[addOutregN4_re(i,part-1),partN4_re],addOutregN4out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN4_im(i,part-1),partN4_im],addOutregN4out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4out_re(i,part),addOutregN4_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4out_im(i,part),addOutregN4_im(i,part),1,internalReset,1);
                    end
                end
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4_re(i,blockInfo.vecsize),dataOutIntN4_re(i),1,internalReset,1);
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN4_im(i,blockInfo.vecsize),dataOutIntN4_im(i),1,internalReset,1);
            end
        end
        validInregN5=iSection.addSignal(out3.Type,'validInregN5');
        pirelab.getIntDelayComp(iSection,validInregN4,validInregN5,blockInfo.vecsize+1,'',0);
        internalResetN5=iSection.addSignal(out3.Type,'internalResetN5');
        pirelab.getIntDelayComp(iSection,internalResetN4,internalResetN5,blockInfo.vecsize+1,'',0);
        for i=1:blockInfo.vecsize
            pirelab.getAddComp(iSection,[dataOutIntN4_re(i),addOutregN5_re(i,1)],addOutregN5out_re(i,1));
            pirelab.getAddComp(iSection,[dataOutIntN4_im(i),addOutregN5_im(i,1)],addOutregN5out_im(i,1));
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN5out_re(i,1),addOutregN5_re(i,1),validInregN5,internalResetN5,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN5out_im(i,1),addOutregN5_im(i,1),validInregN5,internalResetN5,1);
        end
        for part=2:blockInfo.vecsize
            pirelab.getIntDelayComp(iSection,addOutregN5_re(part,1),part1RegN5_re(part),part-1);
            pirelab.getIntDelayComp(iSection,addOutregN5_im(part,1),part1RegN5_im(part),part-1);
            for i=1:blockInfo.vecsize
                if i<part
                    pirelab.getAddComp(iSection,[addOutregN5_re(i,part-1),part1RegN5_re(part)],addOutregN5out_re(i,part));
                    pirelab.getAddComp(iSection,[addOutregN5_im(i,part-1),part1RegN5_im(part)],addOutregN5out_im(i,part));
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN5out_re(i,part),addOutregN5_re(i,part),1,internalReset,1);
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN5out_im(i,part),addOutregN5_im(i,part),1,internalReset,1);
                else
                    if part==2
                        pirelab.getAddComp(iSection,[addOutregN5_re(1,part-1),addOutregN5_re(part,1)],addOutregN5out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN5_im(1,part-1),addOutregN5_im(part,1)],addOutregN5out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN5out_re(i,part),addOutregN5_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN5out_im(i,part),addOutregN5_im(i,part),1,internalReset,1);
                    else
                        partN5_re=iSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),'partN5_re');
                        partN5_im=iSection.addSignal(pir_sfixpt_t(stage5WL,stage5FL),'partN5_im');
                        pirelab.getIntDelayComp(iSection,addOutregN5_re(part,1),partN5_re,part-2);
                        pirelab.getIntDelayComp(iSection,addOutregN5_im(part,1),partN5_im,part-2);
                        pirelab.getAddComp(iSection,[addOutregN5_re(i,part-1),partN5_re],addOutregN5out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN5_im(i,part-1),partN5_im],addOutregN5out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN5out_re(i,part),addOutregN5_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN5out_im(i,part),addOutregN5_im(i,part),1,internalReset,1);
                    end
                end
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN5_re(i,blockInfo.vecsize),dataOutIntN5_re(i),1,internalReset,1);
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN5_im(i,blockInfo.vecsize),dataOutIntN5_im(i),1,internalReset,1);
            end
        end
        validInregN6=iSection.addSignal(out3.Type,'validInregN6');
        pirelab.getIntDelayComp(iSection,validInregN5,validInregN6,blockInfo.vecsize+1,'',0);
        internalResetN6=iSection.addSignal(out3.Type,'internalResetN6');
        pirelab.getIntDelayComp(iSection,internalResetN5,internalResetN6,blockInfo.vecsize+1,'',0);
        for i=1:blockInfo.vecsize
            pirelab.getAddComp(iSection,[dataOutIntN5_re(i),addOutregN6_re(i,1)],addOutregN6out_re(i,1));
            pirelab.getAddComp(iSection,[dataOutIntN5_im(i),addOutregN6_im(i,1)],addOutregN6out_im(i,1));
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN6out_re(i,1),addOutregN6_re(i,1),validInregN6,internalResetN6,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN6out_im(i,1),addOutregN6_im(i,1),validInregN6,internalResetN6,1);
        end
        for part=2:blockInfo.vecsize
            pirelab.getIntDelayComp(iSection,addOutregN6_re(part,1),part1RegN6_re(part),part-1);
            pirelab.getIntDelayComp(iSection,addOutregN6_im(part,1),part1RegN6_im(part),part-1);
            for i=1:blockInfo.vecsize
                if i<part
                    pirelab.getAddComp(iSection,[addOutregN6_re(i,part-1),part1RegN6_re(part)],addOutregN6out_re(i,part));
                    pirelab.getAddComp(iSection,[addOutregN6_im(i,part-1),part1RegN6_im(part)],addOutregN6out_im(i,part));
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN6out_re(i,part),addOutregN6_re(i,part),1,internalReset,1);
                    pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN6out_im(i,part),addOutregN6_im(i,part),1,internalReset,1);
                else
                    if part==2
                        pirelab.getAddComp(iSection,[addOutregN6_re(1,part-1),addOutregN6_re(part,1)],addOutregN6out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN6_im(1,part-1),addOutregN6_im(part,1)],addOutregN6out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN6out_re(i,part),addOutregN6_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN6out_im(i,part),addOutregN6_im(i,part),1,internalReset,1);
                    else
                        partN6_re=iSection.addSignal(pir_sfixpt_t(stage6WL,stage6FL),'partN6_re');
                        partN6_im=iSection.addSignal(pir_sfixpt_t(stage6WL,stage6FL),'partN6_im');
                        pirelab.getIntDelayComp(iSection,addOutregN6_re(part,1),partN6_re,part-2);
                        pirelab.getIntDelayComp(iSection,addOutregN6_im(part,1),partN6_im,part-2);
                        pirelab.getAddComp(iSection,[addOutregN6_re(i,part-1),partN6_re],addOutregN6out_re(i,part));
                        pirelab.getAddComp(iSection,[addOutregN6_im(i,part-1),partN6_im],addOutregN6out_im(i,part));
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN6out_re(i,part),addOutregN6_re(i,part),1,internalReset,1);
                        pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN6out_im(i,part),addOutregN6_im(i,part),1,internalReset,1);
                    end
                end
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN6_re(i,blockInfo.vecsize),dataOutIntN6_re(i),1,internalReset,1);
                pirelab.getIntDelayEnabledResettableComp(iSection,addOutregN6_im(i,blockInfo.vecsize),dataOutIntN6_im(i),1,internalReset,1);
            end
        end
        validInregN7=iSection.addSignal(out3.Type,'validInregN7');
        pirelab.getIntDelayComp(iSection,validInregN6,validInregN7,blockInfo.vecsize+1,'',0);
        internalResetN7=iSection.addSignal(out3.Type,'internalResetN7');
        pirelab.getIntDelayComp(iSection,internalResetN6,internalResetN7,blockInfo.vecsize+1,'',0);
        for i=1:blockInfo.vecsize
            pirelab.getWireComp(iSection,dataOutIntN6_re(i),iOutreg_re(i));
            pirelab.getWireComp(iSection,dataOutIntN6_im(i),iOutreg_im(i));
            pirelab.getIntDelayEnabledResettableComp(iSection,iOutreg_re(i),iOut_re(i),validInregN7,internalReset,1);
            pirelab.getIntDelayEnabledResettableComp(iSection,iOutreg_im(i),iOut_im(i),validInregN7,internalReset,1);
        end
        pirelab.getIntDelayComp(iSection,validInregN7,i_voutreg,1);
        pirelab.getIntDelayComp(iSection,internalResetN7,i_rstoutreg,1);
    end

    pirelab.getMuxComp(iSection,iOut_re,integOut_re);
    pirelab.getMuxComp(iSection,iOut_im,integOut_im);
    intOff=blockInfo.intOff;

    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
    '@CICDecimator','cgireml','vectIntValid.m'),'r');
    vectIntValid=fread(fid,Inf,'char=>char');
    fclose(fid);
    iSection.addComponent2(...
    'kind','cgireml',...
    'Name','vectIntValid',...
    'InputSignals',[i_voutreg,i_rstoutreg],...
    'OutputSignals',[i_vout,i_rstout],...
    'EMLFileName','vectIntValid',...
    'EMLFileBody',vectIntValid,...
    'EmlParams',{intOff},...
    'EMLFlag_TreatInputIntsAsFixpt',true);
end
