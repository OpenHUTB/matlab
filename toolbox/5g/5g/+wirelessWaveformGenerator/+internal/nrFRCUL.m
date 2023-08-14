function waveconfig=nrFRCUL(rc,varargin)















    if nargin==1
        ptrs=false;
    else
        ptrs=varargin{1};
    end


    if~startsWith(rc,'G-FR')||~isequal(rc([6,7,9]),'-A-')
        error(message('nr5g:nrFRC:InvalidRC'));
    end
    FR=rc(3:5);
    frNum=str2double(FR(end));
    secNum=str2double(rc(8));
    frcNum=str2double(rc(10:end));


    waveconfig.Name=rc;
    waveconfig.FrequencyRange=FR;
    waveconfig.DisplayGrids=0;


    waveconfig.NumSubframes=10;
    waveconfig.NCellID=1;



    carriers.SubcarrierSpacing=wirelessWaveformGenerator.internal.getSCSUplinkFRC(frNum,secNum,frcNum);

    NRB=wirelessWaveformGenerator.internal.getNRBUplinkFRC(frNum,secNum,frcNum);
    carriers.NRB=NRB;
    carriers.RBStart=0;


    waveconfig.ChannelBandwidth=wirelessWaveformGenerator.internal.getBandwidth(FR,carriers.SubcarrierSpacing,carriers.NRB);


    bwp.SubcarrierSpacing=carriers.SubcarrierSpacing;
    bwp.CyclicPrefix='Normal';
    bwp.NRB=NRB;
    bwp.RBOffset=0;


    pucch.Enable=0;
    srs=[];


    pusch.Enable=1;
    pusch.BWP=1;


    switch secNum
    case{1,3}
        pusch.Modulation='QPSK';
    case{2,4}
        pusch.Modulation='16QAM';
    otherwise
        pusch.Modulation='64QAM';
    end


    targetRatesPerSec=[308,658,193,658,567]/1024;
    pusch.TargetCodeRate=targetRatesPerSec(secNum);
    pusch.EnableCoding=1;


    if(any(secNum==[3,4])&&frNum==1&&(frcNum>=15&&frcNum<=28))||...
        (any(secNum==[3,4])&&frNum==2&&(frcNum>=6&&frcNum<=10))
        pusch.NLayers=2;
    else
        pusch.NLayers=1;
    end


    if(secNum==3&&frNum==1&&any(frcNum==[29,30,31,32]))||...
        (secNum==3&&frNum==2&&any(frcNum==[11,12]))
        pusch.TransformPrecoding=1;
    else
        pusch.TransformPrecoding=0;
    end



    pusch.RNTI=1;
    pusch.Power=0;
    pusch.PowerDMRS=3;
    pusch.TxScheme='codebook';
    pusch.GroupHopping='neither';
    pusch.IntraSlotFreqHopping='disabled';
    pusch.InterSlotFreqHopping='disabled';


    pusch.NID=[];
    pusch.NIDNSCID=0;
    pusch.NSCID=0;
    pusch.NRSID=[];

    pusch.TPMI=0;
    pusch.Xoh_PUSCH=0;




    pusch.IntraSlotFreqHopping='disabled';
    pusch.RVSequence=0;
    pusch.NumCDMGroupsWithoutData=2;




    pusch.DMRSConfigurationType=1;
    pusch.DMRSLength=1;



    pusch.PUSCHMappingType='A';
    pusch.DMRSTypeAPosition=2;


    if frNum==2&&secNum>=3

        pusch.PUSCHMappingType='B';
    end


    if(frNum==1&&any(secNum==[3,4,5])&&any(frcNum==[1:7,15:21,29,30]))
        pusch.DMRSAdditionalPosition=0;
    elseif(frNum==2&&secNum>1)
        pusch.DMRSAdditionalPosition=0;
    else
        pusch.DMRSAdditionalPosition=1;
    end



    pusch.AllocatedPRB=0:NRB-1;
    pusch.AllocatedSlots=0;
    pusch.AllocatedPeriod=1;

    if frNum==2&&secNum>=3
        pusch.AllocatedSymbols=0:9;
    else
        pusch.AllocatedSymbols=0:13;
    end


    pusch.EnablePTRS=ptrs;
    pusch.PTRSTimeDensity=1;
    pusch.PTRSFrequencyDensity=2;
    pusch.PTRSREOffset='00';
    pusch.PTRSPortSet=0:(pusch.NLayers-1);
    pusch.PTRSNID=[];
    pusch.PowerPTRS=0;


    waveconfig.Carriers=carriers;
    waveconfig.BWP=bwp;
    waveconfig.PUSCH=pusch;
    waveconfig.PUCCH=pucch;
    waveconfig.SRS=srs;





