































function out=FddOCNS(config,varargin)
    validateUMTSParameter('OCNSType',config);
    ocns=hGetOCNS(config.OCNSType);

    if nargin>1
        if strcmpi(varargin{1},'poweronly')
            out=sum(db2pow(ocns.Power));
            if isfield(ocns,'HSDPA')


                out=out+sum(db2pow([ocns.HSDPA.HSPDSCHPower]).*[ocns.HSDPA.CodeGroup])+sum(db2pow([ocns.HSDPA.HSSCCHPower]));
            end
            out=pow2db(out);

            return;
        else
            error('umts:error','For OCNS power output, the second input argument must be ''poweronly''');
        end
    end


    channels=numel(ocns.SpreadingCode);
    dims=FddDLDPCHDims(ocns.SlotFormat);
    out=zeros(dims.BitsPerFrame/2*dims.SF,channels);
    ocnsConfig=struct('ScramblingCode',config.ScramblingCode);
    for ch=1:channels

        tpcSource=vectorDataSource([0,1]);
        ocnsConfig.SpreadingCode=ocns.SpreadingCode(ch);
        ocnsConfig.SlotFormat=ocns.SlotFormat;
        if isfield(ocns,'TimingOffset')
            ocnsConfig.TimingOffset=ocns.TimingOffset(ch);
        end
        src=vectorDataSource({'PN9',ocnsConfig.SpreadingCode});
        dpdchData=src.getPacket(dims.NDataPerFrame);

        ocnsConfig.Enable2Interleaving=0;

        out(:,ch)=FddDLDPCH(ocnsConfig,dpdchData,tpcSource.getPacket(15))*db2mag(ocns.Power(ch));
    end


    out=sum(out,2);

    out=repmat(out,config.TotFrames,1);





    if isfield(ocns,'HSDPA')
        for hs=1:numel(ocns.HSDPA)
            hsocns=ocns.HSDPA(hs);
            hsocns.ScramblingCode=ocnsConfig.ScramblingCode;
            hsocns.TotFrames=config.TotFrames;
            [hspdschchips,hsscchchips]=GenerateHSDPATMframes(hsocns);
            out=out+hspdschchips*db2mag(hsocns.HSPDSCHPower);
            out=out+hsscchchips(:)*db2mag(hsocns.HSSCCHPower);
        end
    end
end

function ocns=hGetOCNS(ocnsdef)

    switch upper(ocnsdef)
    case 'RMC_16DPCH'
        ocns.SF=128;
        ocns.SpreadingCode=[2,11,17,23,31,38,47,55,62,69,78,85,94,125,113,119];
        ocns.Power=[-1,-3,-3,-5,-2,-4,-8,-7,-4,-6,-5,-9,-10,-8,-6,0];
    case 'H-SET_6DPCH'
        ocns.SF=128;
        ocns.SpreadingCode=122:1:127;
        ocns.Power=[0,-2,-2,-4,-1,-3];
    case 'H-SET_4DPCH'
        ocns.SF=128;
        ocns.SpreadingCode=4:1:7;
        ocns.Power=[0,-2,-4,-1];
    case 'TM1_4DPCH'
        ocns.SF=128;
        ocns.SpreadingCode=[2,38,78,119];
        ocns.Power=[-5,-7,-9,-9];
        ocns.TimingOffset=[86,112,30,143];
    case 'TM1_8DPCH'
        ocns.SF=128;
        ocns.SpreadingCode=[2,11,38,55,78,85,113,119];
        ocns.Power=[-7,-16,-11,-11,-10,-12,-8,-12];
        ocns.TimingOffset=[86,134,112,23,30,18,128,143];
    case 'TM1_16DPCH'
        ocns=hGetDPCHCodePower('TM1',16);
        ocns.Power=[-10,-12,-12,-14,-11,-13,-17,-16,-13,-15,-14,-18,-19,-17,-15,-9];
        ocns.SF=128;
    case 'TM1_32DPCH'
        ocns=hGetDPCHCodePower('TM1',32);
        ocns.Power=[-13,-13,-14,-15,-17,-14,-16,-18,-16,-19,-17,-15,-17,-22,-20,-24,-20,-18,-14,-14,-16,-19,-18,-17,-22,-19,-19,-16,-18,-15,-17,-12];
        ocns.SF=128;
    case 'TM1_64DPCH'
        ocns=hGetDPCHCodePower('TM1',64);
        ocns.SF=128;
    case 'TM2_3DPCH'
        ocns.SpreadingCode=[24,72,120];
        ocns.Power=[-10,-10,-3];
        ocns.TimingOffset=[1,7,2];
        ocns.SF=128;
    case 'TM3_4DPCH'
        ocns.SpreadingCode=[64,89,109,125];
        ocns.Power=ones(1,4)*-8;
        ocns.TimingOffset=[86,112,30,143];
        ocns.SF=256;
    case 'TM3_8DPCH'
        ocns.SpreadingCode=[64,74,89,96,109,111,122,125];
        ocns.Power=ones(1,8)*-11;
        ocns.TimingOffset=[86,52,112,23,30,18,128,143];
        ocns.SF=256;
    case 'TM3_16DPCH'
        ocns=hGetDPCHCodePower('TM3',16);
        ocns.SF=256;
    case 'TM3_32DPCH'
        ocns=hGetDPCHCodePower('TM3',32);
        ocns.SF=256;
    case 'TM5_4DPCH_4HSPDSCH'
        ocns=hGetDPCHCodePower('TM5',4);
        ocns.SF=128;
        ocns.HSDPA=hGetHSConfig('TM5_4HSPDSCH');
    case 'TM5_6DPCH_2HSPDSCH'
        ocns=hGetDPCHCodePower('TM5',6);
        ocns.SF=128;
        ocns.HSDPA=hGetHSConfig('TM5_2HSPDSCH');
    case 'TM5_14DPCH_4HSPDSCH'
        ocns=hGetDPCHCodePower('TM5',14);
        ocns.SF=128;
        ocns.HSDPA=hGetHSConfig('TM5_4HSPDSCH');
    case 'TM5_30DPCH_8HSPDSCH'
        ocns=hGetDPCHCodePower('TM5',30);
        ocns.SF=128;
        ocns.HSDPA=hGetHSConfig('TM5_8HSPDSCH');
    case 'TM6_4DPCH_4HSPDSCH'
        ocns=hGetDPCHCodePower('TM6',4);
        ocns.SF=128;
        ocns.HSDPA=hGetHSConfig('TM6_4HSPDSCH');
    case 'TM6_30DPCH_8HSPDSCH'
        ocns=hGetDPCHCodePower('TM6',30);
        ocns.SF=128;
        ocns.HSDPA=hGetHSConfig('TM6_8HSPDSCH');
    otherwise
        error('umts:error','Unsupported OCNSType specified');
    end
    ocns.SlotFormat=10;
    if ocns.SF==256
        ocns.SlotFormat=6;
    end

end

function ocns=hGetDPCHCodePower(TM,Ncodes)
    switch upper(TM)
    case 'TM1'
        SpreadingCode=[2,11,17,23,31,38,47,55,62,69,78,85,94,102,113,119,7,13,20,27,35,41,51...
        ,58,64,74,82,88,97,108,117,125,4,9,12,14,19,22,26,28,34,36,40,44,49,53...
        ,56,61,63,66,71,76,80,84,87,91,95,99,105,110,116,118,122,126];
        Power=[-16,-16,-16,-17,-18,-20,-16,-17,-16,-19,-22,-20,-16,-17,-19,-21,-19,-21,-18,-20,-24,-24,-22...
        ,-21,-18,-20,-17,-18,-19,-23,-22,-21,-17,-18,-20,-17,-19,-21,-19,-23,-22,-19,-24,-23,-22,-19...
        ,-22,-21,-18,-19,-22,-21,-19,-21,-19,-21,-20,-25,-25,-25,-24,-22,-20,-15];
        TimingOffset=[86,134,52,45,143,112,59,23,1,88,30,18,30,61,128,143,83,25,103,97,56,104,51...
        ,26,137,65,37,125,149,123,83,5,91,7,32,21,29,59,22,138,31,17,9,69,49,20...
        ,57,121,127,114,100,76,141,82,64,149,87,98,46,37,87,149,85,69];
        ocns.Power=Power(1:Ncodes);
    case 'TM3'
        SpreadingCode=[64,69,74,78,83,89,93,96,100,105,109,111,115,118,122,125,67,71,76,81,86,90,95...
        ,98,103,108,110,112,117,119,123,126];
        TimingOffset=[86,134,52,45,143,112,59,23,1,88,30,18,30,61,128,143,83,25,103,97,56,104,51...
        ,26,137,65,37,125,149,123,83,5];
        if Ncodes==16
            ocns.Power=ones(1,16)*-14;
        else
            ocns.Power=ones(1,32)*-16;
        end
    case 'TM5'
        SpreadingCode=[15,23,68,76,82,90,5,11,17,27,64,72,86,94,3,7,13,19,21,25,31,66,70...
        ,74,78,80,84,88,89,92];
        TimingOffset=[86,134,52,45,143,112,59,23,1,88,30,18,30,61,128,143,83,25,103,97,56,104,51...
        ,26,137,65,37,125,149,123];
        if Ncodes==4
            ocns.Power=[-15,-15,-18,-12];
        elseif Ncodes==6
            ocns.Power=[-17,-15,-15,-18,-16,-17];
        elseif Ncodes==14
            ocns.Power=[-17,-19,-19,-20,-18,-20,-25,-23,-20,-22,-21,-22,-19,-20];
        else
            ocns.Power=[-20,-20,-21,-22,-24,-21,-23,-25,-23,-26,-24,-22,-24,-28,-27,-26,-27,-25,-21,-21,-23,-26,-25...
            ,-24,-27,-26,-23,-25,-22,-24];
        end
    case 'TM6'
        SpreadingCode=[15,23,68,76,82,90,5,11,17,27,64,72,86,94,3,7,13,19,21,25,31,66,70...
        ,74,78,80,84,88,89,92];
        TimingOffset=[86,134,52,45,143,112,59,23,1,88,30,18,30,61,128,143,83,25,103,97,56,104,51...
        ,26,137,65,37,125,149,123];
        if Ncodes==4
            ocns.Power=[-13,-15,-9,-12];
        else
            ocns.Power=[-17,-17,-18,-19,-21,-18,-20,-22,-20,-23,-21,-19,-21,-25,-24,-23,-24,-22,-18,-18,-20,-23,-22...
            ,-21,-24,-23,-22,-22,-22,-21];
        end
    otherwise
        error('umts:error','Unsupported TM specified');
    end
    ocns.SpreadingCode=SpreadingCode(1:Ncodes);
    ocns.TimingOffset=TimingOffset(1:Ncodes);
end

function ocns=hGetHSConfig(TM)
    switch upper(TM)
    case 'TM5_4HSPDSCH'
        ocns=hGetHSGeneralParams('TM5');
        ocns(2)=ocns;
        ocns(2).CodeOffset=12;
        ocns(2).HSSCCHSpreadingCode=29;
        ocns(2).HSSCCHPower=-21;
    case 'TM5_2HSPDSCH'
        ocns=hGetHSGeneralParams('TM5');
        ocns.CodeGroup=1;
        ocns.HSPDSCHPower=-5;
        ocns(2)=ocns;
        ocns(2).CodeOffset=12;
        ocns(2).HSSCCHSpreadingCode=29;
        ocns(2).HSSCCHPower=-21;
    case 'TM5_8HSPDSCH'
        ocns=hGetHSGeneralParams('TM5');
        ocns.CodeGroup=4;
        ocns.HSPDSCHPower=-11;
        ocns(2)=ocns;
        ocns(2).CodeOffset=12;
        ocns(2).HSSCCHSpreadingCode=29;
        ocns(2).HSSCCHPower=-21;
    case 'TM6_4HSPDSCH'
        ocns=hGetHSGeneralParams('TM6');
        ocns(2)=ocns;
        ocns(2).CodeOffset=12;
        ocns(2).HSSCCHSpreadingCode=29;
        ocns(2).HSSCCHPower=-21;
    case 'TM6_8HSPDSCH'
        ocns=hGetHSGeneralParams('TM6');
        ocns.CodeGroup=4;
        ocns.HSPDSCHPower=-12;
        ocns(2)=ocns;
        ocns(2).CodeOffset=12;
        ocns(2).HSSCCHSpreadingCode=29;
        ocns(2).HSSCCHPower=-21;
    end
end

function ocns=hGetHSGeneralParams(TM)
    switch upper(TM)
    case 'TM5'
        ocns.Modulation='16QAM';
        ocns.BitsPerSlot=640;
        ocns.HSPDSCHPower=-8;
    case 'TM6'
        ocns.Modulation='64QAM';
        ocns.BitsPerSlot=960;
        ocns.HSPDSCHPower=-9;
    end
    ocns.CodeGroup=2;
    ocns.CodeOffset=4;
    ocns.HSSCCHSpreadingCode=9;
    ocns.HSSCCHPower=-15;
end

function[hspdschchips,hsscchchips]=GenerateHSDPATMframes(config)

    dbitspersubframe=config.BitsPerSlot*3;
    cbitspersubframe=40*3;
    config.ConstellationVersion=0;
    config.Enable2Interleaving=0;
    config.TimingOffset=0;
    hspdschchips=zeros(38400,config.CodeGroup);


    initoffset=config.CodeOffset;
    for ch=1:config.CodeGroup





        config.CodeGroup=1;
        config.CodeOffset=initoffset+ch-1;
        config.NSubframe=0;


        hsdpschsrc=vectorDataSource({'PN9-ITU',(config.CodeOffset)*23});


        hspdschchips(:,ch)=FddHSPDSCH(config,hsdpschsrc.getPacket(dbitspersubframe*5));
    end


    hsscchsrc=vectorDataSource({'PN9-ITU',config.HSSCCHSpreadingCode});
    config.NSubframe=0;
    hsscchchips=zeros(7680,5);
    for s=1:5

        hsscchchips(:,s)=FddHSSCCH(config,hsscchsrc.getPacket(cbitspersubframe));
        config.NSubframe=config.NSubframe+1;
    end
    hsscchchips=hsscchchips(:);

    if~isvector(hspdschchips)
        hspdschchips=sum(hspdschchips,2);
    end

    hspdschchips=repmat(hspdschchips,config.TotFrames,1);
    hsscchchips=repmat(hsscchchips,config.TotFrames,1);
end