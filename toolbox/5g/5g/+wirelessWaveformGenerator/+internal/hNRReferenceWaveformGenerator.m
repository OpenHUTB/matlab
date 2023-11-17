classdef hNRReferenceWaveformGenerator


    properties(Constant,Access=private)
        DLRMConfigs=getRMConfigs();
        DLModels=[wirelessWaveformGenerator.internal.hNRReferenceWaveformGenerator.DLRMConfigs.Name];
        ULModels=getULModels();
    end


    properties(Constant)
        FR1BandwidthTable=getFR1BandwidthTable();
        FR2BandwidthTable=getFR2BandwidthTable();
        FR1TestModels=wirelessWaveformGenerator.internal.hNRReferenceWaveformGenerator.DLModels(contains(wirelessWaveformGenerator.internal.hNRReferenceWaveformGenerator.DLModels,'FR1-TM'))';
        FR2TestModels=wirelessWaveformGenerator.internal.hNRReferenceWaveformGenerator.DLModels(contains(wirelessWaveformGenerator.internal.hNRReferenceWaveformGenerator.DLModels,'FR2-TM'))';
        FR1DownlinkFRC=wirelessWaveformGenerator.internal.hNRReferenceWaveformGenerator.DLModels(contains(wirelessWaveformGenerator.internal.hNRReferenceWaveformGenerator.DLModels,'FRC-FR1'))';
        FR2DownlinkFRC=wirelessWaveformGenerator.internal.hNRReferenceWaveformGenerator.DLModels(contains(wirelessWaveformGenerator.internal.hNRReferenceWaveformGenerator.DLModels,'FRC-FR2'))';
        FR1UplinkFRC=wirelessWaveformGenerator.internal.hNRReferenceWaveformGenerator.ULModels(contains(wirelessWaveformGenerator.internal.hNRReferenceWaveformGenerator.ULModels,'G-FR1'))';
        FR2UplinkFRC=wirelessWaveformGenerator.internal.hNRReferenceWaveformGenerator.ULModels(contains(wirelessWaveformGenerator.internal.hNRReferenceWaveformGenerator.ULModels,'G-FR2'))';
    end

    properties(Dependent,Access=public)
        Config;
    end

    properties(SetAccess=private)
        IsReadOnly=1;
        ConfiguredModel;
        TargetRNTI;
    end

    properties(Access=private)
        LinkDirection;
    end


    methods
        function obj=makeConfigWritable(obj)






            obj.IsReadOnly=0;
        end


        function obj=set.Config(obj,c)
            if obj.IsReadOnly

                return;
            end
            obj.ConfigValue=c;
        end


        function c=get.Config(obj)
            c=obj.ConfigValue;
        end

    end

    properties(Access=private)
        ConfigValue;
    end


    methods


        function obj=hNRReferenceWaveformGenerator(rc,bw,scs,duplexmode,ncellid,sv,cs,ocng)









































            if nargin<8
                ocng=0;
                if nargin<7
                    cs=[];
                    if nargin<6
                        sv="15.2.0";
                        if nargin<5
                            ncellid=[];
                            if nargin<4
                                duplexmode=[];
                                if nargin<3
                                    scs=[];
                                    if nargin<2
                                        bw=[];
                                        if nargin<1
                                            rc=wirelessWaveformGenerator.internal.hNRReferenceWaveformGenerator.DLModels(1);
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end


            if startsWith(rc,'G-','IgnoreCase',true)
                obj.LinkDirection="uplink";
                refnames=wirelessWaveformGenerator.internal.hNRReferenceWaveformGenerator.ULModels;
            else
                obj.LinkDirection="downlink";
                refnames=wirelessWaveformGenerator.internal.hNRReferenceWaveformGenerator.DLModels;

                frselect=1+contains(rc,'FR2','IgnoreCase',true);
                if isempty(scs)
                    scsdefs=["15kHz","120kHz"];
                    scs=scsdefs(frselect);
                end
                if isempty(bw)
                    bwdefs=["10MHz","100MHz"];
                    bw=bwdefs(frselect);
                end
            end


            if isempty(cs)
                cs=0;
            end



            if isempty(ncellid)
                ncellid=double(obj.LinkDirection=="downlink");
            end


            selected=strcmpi(rc,refnames);



            if obj.LinkDirection=="uplink"
                tdef=getULFRCDefinition(rc,bw,scs);
            else
                tdef=wirelessWaveformGenerator.internal.hNRReferenceWaveformGenerator.DLRMConfigs(selected);
            end




            if~isempty(duplexmode)
                duplexingmodes=["FDD","TDD"];
                selected=strcmpi(string(duplexmode),duplexingmodes);

                tdef.DuplexMode=duplexingmodes(selected);
            end


            if obj.LinkDirection=="uplink"

                obj.ConfigValue=getFRCPUSCHParameters(tdef,ncellid);
                obj.ConfiguredModel={rc,bw,scs,tdef.DuplexMode,ncellid};
            else

                if contains(rc,'FRC','IgnoreCase',true)

                    waveconfig=getCommonParameters(tdef,bw,scs,ncellid);
                    waveconfig=getFRCPDSCHParameters(tdef,waveconfig);


                    waveconfig.CORESET.AllocatedSlots=waveconfig.PDSCH.AllocatedSlots;
                    waveconfig.CORESET.AllocatedPeriod=waveconfig.PDSCH.AllocatedPeriod;

                    obj.ConfigValue=waveconfig;
                    obj.ConfiguredModel={rc,bw,scs,tdef.DuplexMode,ncellid};
                else

                    waveconfig=getCommonParameters(tdef,bw,scs,ncellid);
                    obj.ConfigValue=getTestModelPDSCHParameters(tdef,waveconfig,sv);
                    obj.ConfiguredModel={rc,bw,scs,tdef.DuplexMode,ncellid,sv};
                end
            end


            if~cs
                obj.ConfigValue=getGenConfigObj(obj);

                if contains(rc,'FRC','IgnoreCase',true)&&obj.LinkDirection=="downlink"&&ocng==1
                    obj.ConfigValue.PDSCH=[obj.ConfigValue.PDSCH,nr5g.internal.wavegen.getOCNGPDSCHs(obj.ConfigValue)];
                end
            end


            if contains(rc,["TM3.1","TM3.1a"],'IgnoreCase',true)
                targets=[0,2];
            elseif contains(rc,["TM3.2","TM3.3"],'IgnoreCase',true)
                targets=1;
            elseif contains(rc,["TM1.2","TM2","TM2a"],'IgnoreCase',true)
                targets=2;
            else
                targets=0;
            end
            obj.TargetRNTI=targets;
        end

        function varargout=generateWaveform(obj,numsf)








            nsf=obj.ConfigValue.NumSubframes;
            if nargin>1
                obj.ConfigValue.NumSubframes=numsf;
            end

            cv=getGenConfigObj(obj);
            [wave,winfo]=nrWaveformGenerator(cv);


            winfo.WaveformResources.Label=obj.ConfiguredModel{1};


            rg=winfo.ResourceGrids;
            for n=1:length(rg)
                rg(n).Info.NSubcarriers=size(rg(n).ResourceGridInCarrier,1);
                rg(n).Info.SymbolsPerSubframe=rg(n).Info.SymbolsPerSlot*rg(n).Info.SlotsPerSubframe;
                rg(n).Info.SamplesPerSubframe=rg(n).Info.SampleRate/1000;
                rg(n).Info.SamplingRate=rg(n).Info.SampleRate;
            end


            varargout={wave,rg,winfo};

            obj.ConfigValue.NumSubframes=nsf;
        end

        function displayResourceGrid(obj,numsf)







            nsf=obj.ConfigValue.NumSubframes;
            if nargin>1
                obj.ConfigValue.NumSubframes=numsf;
            end

            cv=getGenConfigObj(obj);


            [~,winfo]=nrWaveformGenerator(cv);
            rg=winfo.ResourceGrids;


            sv.Name=obj.ConfiguredModel{1};
            sv.ChannelBandwidth=cv.ChannelBandwidth;
            sv.FrequencyRange=cv.FrequencyRange;


            sv.Carriers(length(cv.SCSCarriers))=struct();
            for n=1:length(sv.Carriers)
                sv.Carriers(n).SubcarrierSpacing=cv.SCSCarriers{n}.SubcarrierSpacing;
                sv.Carriers(n).NRB=cv.SCSCarriers{n}.NSizeGrid;
                sv.Carriers(n).RBStart=cv.SCSCarriers{n}.NStartGrid;
            end

            carrierscs=[sv.Carriers.SubcarrierSpacing];


            sv.BWP(length(cv.BandwidthParts))=struct();
            for n=1:length(sv.BWP)
                bwpscs=cv.BandwidthParts{n}.SubcarrierSpacing;
                sv.BWP(n).SubcarrierSpacing=bwpscs;
                sv.BWP(n).RBOffset=cv.BandwidthParts{n}.NStartBWP-sv.Carriers(find(bwpscs==carrierscs,1)).RBStart;
            end


            sv.Carriers(~ismember(carrierscs,[sv.BWP.SubcarrierSpacing]))=[];


            figure;
            gridPRB=wirelessWaveformGenerator.internal.computeResourceGridPRB(cv);

            plotResourceGrid(gca,sv,cv,gridPRB,obj.LinkDirection=="downlink");



            figure;
            wirelessWaveformGenerator.internal.plotCarriers(gca,sv,rg);


            figure;
            cmap=parula(64);
            for bp=1:length(rg)

                subplot(length(rg),1,bp)
                im=image(40*abs(rg(bp).ResourceGridInCarrier(:,:,1)));axis xy;
                colormap(im.Parent,cmap);
                title(sprintf('BWP %d in Carrier (SCS=%dkHz)',bp,sv.BWP(bp).SubcarrierSpacing));xlabel('Symbols');ylabel('Subcarriers');
            end

            obj.ConfigValue.NumSubframes=nsf;


            h=get(gca,'Title');
            titletext=get(h,'String');
            set(h,'String',sprintf('%s: %s',obj.ConfiguredModel{1},titletext));
        end

    end
end




function table=getFR1BandwidthTable()




    nrbtable=[25,52,79,106,133,160,216,270,NaN,NaN,NaN,NaN,NaN;
    11,24,38,51,65,78,106,133,162,189,217,245,273;
    NaN,11,18,24,31,38,51,65,79,93,107,121,135];


    table=array2table(nrbtable,"RowNames",["15kHz","30kHz","60kHz"],"VariableNames",["5MHz","10MHz","15MHz","20MHz","25MHz","30MHz","40MHz","50MHz","60MHz","70MHz","80MHz","90MHz","100MHz"]);
    table.Properties.Description='TS 38.104 Table 5.3.2-1: Transmission bandwidth configuration NRB for FR1';
end


function table=getFR2BandwidthTable()




    nrbtable=[66,132,264,NaN;
    32,66,132,264];


    table=array2table(nrbtable,"RowNames",["60kHz","120kHz"],"VariableNames",["50MHz","100MHz","200MHz","400MHz"]);
    table.Properties.Description='TS 38.104 Table 5.3.2-2: Transmission bandwidth configuration NRB for FR2';
end


function names=getULModels()


    expa=@(s,e,n)reshape(s+e+string(n(:)),1,[]);

    nr={getNRBUplinkFRC(1),getNRBUplinkFRC(2)};
    lens=cellfun(@(x)cellfun('length',x),nr,'uniformoutput',false);
    lens=reshape([lens{:}],[],2);
    tn=size(lens,1);
    zn=arrayfun(@(f,x,y)expa(expa(expa("G-FR","",f),"-A",x),"-",1:y),...
    [1,2].*ones(tn,1),((1:tn).*ones(2,1))',lens,'uniformoutput',0);
    names=[zn{:}];

end


function p=getRMConfigs()



    ptm.Name="NR-FR1-TM1.1";
    ptm.FR="FR1";
    ptm.DuplexMode="FDD";
    ptm.BoostedPercent=100;
    ptm.BoostedPower=0;
    ptm.Modulation="QPSK";

    ptm(end+1).Name="NR-FR1-TM1.2";
    ptm(end).FR="FR1";
    ptm(end).DuplexMode="FDD";
    ptm(end).BoostedPercent=40;
    ptm(end).BoostedPower=3;
    ptm(end).Modulation=["QPSK","QPSK"];

    ptm(end+1).Name="NR-FR1-TM2";
    ptm(end).FR="FR1";
    ptm(end).DuplexMode="FDD";
    ptm(end).BoostedPercent=1;
    ptm(end).BoostedPower=0;
    ptm(end).Modulation="64QAM";

    ptm(end+1).Name="NR-FR1-TM2a";
    ptm(end).FR="FR1";
    ptm(end).DuplexMode="FDD";
    ptm(end).BoostedPercent=1;
    ptm(end).BoostedPower=0;
    ptm(end).Modulation="256QAM";

    ptm(end+1).Name="NR-FR1-TM3.1";
    ptm(end).FR="FR1";
    ptm(end).DuplexMode="FDD";
    ptm(end).BoostedPercent=100;
    ptm(end).BoostedPower=0;
    ptm(end).Modulation="64QAM";

    ptm(end+1).Name="NR-FR1-TM3.1a";
    ptm(end).FR="FR1";
    ptm(end).DuplexMode="FDD";
    ptm(end).BoostedPercent=100;
    ptm(end).BoostedPower=0;
    ptm(end).Modulation="256QAM";

    ptm(end+1).Name="NR-FR1-TM3.2";
    ptm(end).FR="FR1";
    ptm(end).DuplexMode="FDD";
    ptm(end).BoostedPercent=60;
    ptm(end).BoostedPower=-3;
    ptm(end).Modulation=["16QAM","QPSK"];

    ptm(end+1).Name="NR-FR1-TM3.3";
    ptm(end).FR="FR1";
    ptm(end).DuplexMode="FDD";
    ptm(end).BoostedPercent=50;
    ptm(end).BoostedPower=-6;
    ptm(end).Modulation=["QPSK","16QAM"];



    ptm(end+1).Name="NR-FR2-TM1.1";
    ptm(end).FR="FR2";
    ptm(end).DuplexMode="TDD";
    ptm(end).BoostedPercent=100;
    ptm(end).BoostedPower=0;
    ptm(end).Modulation="QPSK";

    ptm(end+1).Name="NR-FR2-TM2";
    ptm(end).FR="FR2";
    ptm(end).DuplexMode="TDD";
    ptm(end).BoostedPercent=1;
    ptm(end).BoostedPower=0;
    ptm(end).Modulation="64QAM";

    ptm(end+1).Name="NR-FR2-TM2a";
    ptm(end).FR="FR2";
    ptm(end).DuplexMode="TDD";
    ptm(end).BoostedPercent=1;
    ptm(end).BoostedPower=0;
    ptm(end).Modulation="256QAM";

    ptm(end+1).Name="NR-FR2-TM3.1";
    ptm(end).FR="FR2";
    ptm(end).DuplexMode="TDD";
    ptm(end).BoostedPercent=100;
    ptm(end).BoostedPower=0;
    ptm(end).Modulation="64QAM";

    ptm(end+1).Name="NR-FR2-TM3.1a";
    ptm(end).FR="FR2";
    ptm(end).DuplexMode="TDD";
    ptm(end).BoostedPercent=100;
    ptm(end).BoostedPower=0;
    ptm(end).Modulation="256QAM";



    [ptm.ControlNRB]=deal(6);
    [ptm.NumCCE]=deal(1);
    [ptm.MCSIndex]=deal(-1);


    pfrc.Name="DL-FRC-FR1-QPSK";
    pfrc.FR="FR1";
    pfrc.DuplexMode="FDD";
    pfrc.BoostedPercent=100;
    pfrc.BoostedPower=0;
    pfrc.Modulation="QPSK";
    pfrc.MCSIndex=4;

    pfrc(end+1).Name="DL-FRC-FR1-64QAM";
    pfrc(end).FR="FR1";
    pfrc(end).DuplexMode="FDD";
    pfrc(end).BoostedPercent=100;
    pfrc(end).BoostedPower=0;
    pfrc(end).Modulation="64QAM";
    pfrc(end).MCSIndex=24;

    pfrc(end+1).Name="DL-FRC-FR1-256QAM";
    pfrc(end).FR="FR1";
    pfrc(end).DuplexMode="FDD";
    pfrc(end).BoostedPercent=100;
    pfrc(end).BoostedPower=0;
    pfrc(end).Modulation="256QAM";
    pfrc(end).MCSIndex=23;


    pfrc(end+1).Name="DL-FRC-FR2-QPSK";
    pfrc(end).FR="FR2";
    pfrc(end).DuplexMode="TDD";
    pfrc(end).BoostedPercent=100;
    pfrc(end).BoostedPower=0;
    pfrc(end).Modulation="QPSK";
    pfrc(end).MCSIndex=4;

    pfrc(end+1).Name="DL-FRC-FR2-16QAM";
    pfrc(end).FR="FR2";
    pfrc(end).DuplexMode="TDD";
    pfrc(end).BoostedPercent=100;
    pfrc(end).BoostedPower=0;
    pfrc(end).Modulation="16QAM";
    pfrc(end).MCSIndex=13;

    pfrc(end+1).Name="DL-FRC-FR2-64QAM";
    pfrc(end).FR="FR2";
    pfrc(end).DuplexMode="TDD";
    pfrc(end).BoostedPercent=100;
    pfrc(end).BoostedPower=0;
    pfrc(end).Modulation="64QAM";
    pfrc(end).MCSIndex=19;


    [pfrc.ControlNRB]=deal(-1);
    [pfrc.NumCCE]=deal(-1);


    p=[ptm,pfrc];

end


function[nrb,bw,scs]=getValidNRB(fr,bw,scs)


    bwtable=[char(fr),'BandwidthTable'];


    scslist=reshape(wirelessWaveformGenerator.internal.hNRReferenceWaveformGenerator.(bwtable).Properties.RowNames,1,[]);
    scsnumbers=str2double(extractBefore(scslist,'k'));


    bwlist=wirelessWaveformGenerator.internal.hNRReferenceWaveformGenerator.(bwtable).Properties.VariableNames;
    bwnumbers=str2double(extractBefore(bwlist,'M'));


    bwsel=ones(1,length(bwnumbers),'logical');
    if~isempty(bw)
        if isstring(bw)||ischar(bw)
            bwsel=strcmpi(erase(lower(bw),'bw_'),bwlist);
        else
            bwlist=bwnumbers;
            bwsel=(bw==bwlist);
        end

    end


    scssel=ones(1,length(scsnumbers),'logical');
    if~isempty(scs)
        if isstring(scs)||ischar(scs)
            scssel=strcmpi(scs,scslist);
        else
            scslist=scsnumbers;
            scssel=(scs==scslist);
        end

    end


    nrb=wirelessWaveformGenerator.internal.hNRReferenceWaveformGenerator.(bwtable){scssel,bwsel};



    bw=bwnumbers(bwsel);
    scs=scsnumbers(scssel);

end


function[config,txpattern]=getTDDConfiguration(fr,scs,link,dlfrc)


    if nargin<4
        dlfrc=0;

        if nargin<3
            link="downlink";
        end
    end


    persistent patterns;
    if isempty(patterns)




        patterns(1).referenceSubcarrierSpacing=15;
        patterns(1).dl_UL_TransmissionPeriodicity=5;
        patterns(1).nrofDownlinkSlots=3;
        patterns(1).nrofDownlinkSymbols=10;
        patterns(1).nrofUplinkSlots=1;
        patterns(1).nrofUplinkSymbols=2;


        patterns(2).referenceSubcarrierSpacing=30;
        patterns(2).dl_UL_TransmissionPeriodicity=5;
        patterns(2).nrofDownlinkSlots=7;
        patterns(2).nrofDownlinkSymbols=6;
        patterns(2).nrofUplinkSlots=2;
        patterns(2).nrofUplinkSymbols=4;


        patterns(3).referenceSubcarrierSpacing=60;
        patterns(3).dl_UL_TransmissionPeriodicity=5;
        patterns(3).nrofDownlinkSlots=14;
        patterns(3).nrofDownlinkSymbols=12;
        patterns(3).nrofUplinkSlots=4;
        patterns(3).nrofUplinkSymbols=8;





        patterns(4).referenceSubcarrierSpacing=60;
        patterns(4).dl_UL_TransmissionPeriodicity=1.25;
        patterns(4).nrofDownlinkSlots=3;
        patterns(4).nrofDownlinkSymbols=10;
        patterns(4).nrofUplinkSlots=1;
        patterns(4).nrofUplinkSymbols=2;


        patterns(5).referenceSubcarrierSpacing=120;
        patterns(5).dl_UL_TransmissionPeriodicity=1.25;
        patterns(5).nrofDownlinkSlots=7;
        patterns(5).nrofDownlinkSymbols=6;
        patterns(5).nrofUplinkSlots=2;
        patterns(5).nrofUplinkSymbols=4;





        patterns(6).referenceSubcarrierSpacing=60;
        patterns(6).dl_UL_TransmissionPeriodicity=1.25;
        patterns(6).nrofDownlinkSlots=3;
        patterns(6).nrofDownlinkSymbols=4;
        patterns(6).nrofUplinkSlots=1;
        patterns(6).nrofUplinkSymbols=4;


        patterns(7).referenceSubcarrierSpacing=120;
        patterns(7).dl_UL_TransmissionPeriodicity=0.625;
        patterns(7).nrofDownlinkSlots=3;
        patterns(7).nrofDownlinkSymbols=10;
        patterns(7).nrofUplinkSlots=1;
        patterns(7).nrofUplinkSymbols=2;

























    end


    scsidx=1+log2(scs/15);
    if link=="downlink"
        index=scsidx+strcmpi(fr,'FR2')*(1+2*logical(dlfrc));
        config=patterns(index);
    else
        ulselection=[1,2,7,7];
        index=ulselection(scsidx);
        config=patterns(index);
        config.referenceSubcarrierSpacing=scs;
        config.dl_UL_TransmissionPeriodicity=(1+double(scsidx==3))*config.dl_UL_TransmissionPeriodicity;
    end


    slotspertddperiod=config.dl_UL_TransmissionPeriodicity*fix(scs/15);
    txpattern=2*ones(1,slotspertddperiod);

    if link=="downlink"
        txpattern(config.nrofDownlinkSlots+(1:config.nrofDownlinkSymbols~=0))=1;
        txpattern(1:config.nrofDownlinkSlots)=0;
    else
        txpattern(end-config.nrofUplinkSlots+(0:config.nrofUplinkSymbols==0))=1;
        txpattern(end-config.nrofUplinkSlots+1:end)=0;
    end
end


function waveconfig=getCommonParameters(tdef,bw,scs,ncellid)


    frc=contains(tdef.Name,"FRC");











    [nrb,bw,scs]=getValidNRB(tdef.FR,bw,scs);

    tdd=strcmpi(tdef.DuplexMode,'TDD');


    waveconfig.Name=tdef.Name;
    waveconfig.NCellID=ncellid;
    waveconfig.ChannelBandwidth=bw;
    waveconfig.FrequencyRange=tdef.FR;
    waveconfig.NumSubframes=10+10*tdd;
    waveconfig.Windowing=0;
    waveconfig.DisplayGrids=0;



    carriers(1).SubcarrierSpacing=scs;
    carriers(1).NRB=nrb;
    carriers(1).RBStart=0;



























    ssbcases=["A","B","B","D","E"];
    bmplengths=[4,4,4,64,64];

    scsind=log2(scs/15)+1;


    if nrb==11&&scs==30
        scsind=scsind-1;
    end

    if tdef.FR=="FR2"&&scs==60
        scsind=scsind+1;
    end

    ssbbp=strcat("Case ",ssbcases(scsind));
    ssbbmap=zeros(1,bmplengths(scsind));
    ssbbmap(1)=1;

    ssburst=[];
    ssburst.Enable=frc;
    ssburst.BlockPattern=ssbbp;
    ssburst.SSBTransmitted=ssbbmap;
    ssburst.SSBPeriodicity=10;
    ssburst.FrequencySSB=0*5000;
    ssburst.Power=0;



    bwp(1).SubcarrierSpacing=scs;
    bwp(1).CyclicPrefix='Normal';
    bwp(1).NRB=nrb;
    bwp(1).RBOffset=0;


    if strcmpi(tdef.DuplexMode,'FDD')

        dlallocatedslots=0;
        dlallocatedperiod=1;
    else

        [~,dltxpattern]=getTDDConfiguration(tdef.FR,scs,"downlink",frc);
        dlallocatedslots=find(dltxpattern<(2-frc))-1;
        dlallocatedperiod=length(dltxpattern);
    end


    ncontrolsymbs=2;
    ncontrolrb=tdef.ControlNRB;
    if ncontrolrb<0
        ncontrolrb=nrb;
    end
    ncontrolcce=tdef.NumCCE;
    if ncontrolcce<0
        ncontrolcce=1;

    end


    coreset(1).Duration=ncontrolsymbs;
    coreset(1).AllocatedSymbols=0;
    coreset(1).AllocatedSlots=dlallocatedslots;
    coreset(1).AllocatedPeriod=dlallocatedperiod;
    coreset(1).AllocatedPRB=0:ncontrolrb-1;
    coreset(1).CCEREGMapping='noninterleaved';
    coreset(1).REGBundleSize=2;
    coreset(1).InterleaverSize=2;
    coreset(1).ShiftIndex=0;


    pdcch(1).Enable=tdef.NumCCE>0;
    pdcch(1).BWP=1;
    pdcch(1).CORESET=1;
    pdcch(1).Power=0;
    pdcch(1).AllocatedSearchSpaces=0;
    pdcch(1).AllocatedPeriod=1;
    pdcch(1).NumCCE=ncontrolcce;
    pdcch(1).StartCCE=0;
    pdcch(1).RNTI=0;
    pdcch(1).NID=ncellid;
    pdcch(1).PowerDMRS=0;
    pdcch(1).EnableCoding=0;
    pdcch(1).DataBlkSize=20;
    pdcch(1).DataSource=0;


    targetal=16;
    ntargetdci=fix(ncontrolcce/targetal);
    naremdci=mod(ncontrolcce,targetal);


    alset=[ones(1,ntargetdci)*targetal,ones(1,naremdci)];
    startset=cumsum([0,alset(1:end-1)]);
    alset=num2cell(alset);
    startset=num2cell(startset);


    pdcch=repmat(pdcch,1,length(alset));
    [pdcch.NumCCE]=alset{:};
    [pdcch.StartCCE]=startset{:};
    rntiset=num2cell(0:length(alset)-1);
    [pdcch.RNTI]=rntiset{:};


    csirs.Enable=0;
    csirs.BWP=1;
    csirs.Power=0;
    csirs.CSIRSType='nzp';
    csirs.RowNumber=1;
    csirs.Density='three';
    csirs.SubcarrierLocations=0;
    csirs.NumRB=nrb;
    csirs.RBOffset=0;
    csirs.SymbolLocations=0;
    csirs.AllocatedSlots=0;
    csirs.AllocatedPeriod=1;
    csirs.NID=ncellid;


    waveconfig.SSBurst=ssburst;
    waveconfig.Carriers=carriers;
    waveconfig.BWP=bwp;
    waveconfig.CORESET=coreset;
    waveconfig.PDCCH=pdcch;
    waveconfig.CSIRS=csirs;

end


function waveconfig=getFRCPDSCHParameters(tdef,waveconfig)






























    nrb=waveconfig.Carriers.NRB;
    scs=waveconfig.BWP.SubcarrierSpacing;



    pdsch=getPDSCHCommonParameters(tdef.FR,nrb,waveconfig.NCellID,tdef.Modulation,tdef.MCSIndex);


    pdsch.AllocatedSymbols=2:max(pdsch.AllocatedSymbols);
    pdsch.DMRSAdditionalPosition=2;
    pdsch.NumCDMGroupsWithoutData=2;
    pdsch.PowerDMRS=3;


    pdsch.EnablePTRS=(tdef.FR=="FR2")&&(tdef.Modulation=="64QAM");
    pdsch.PTRSTimeDensity=1;
    pdsch.PTRSFrequencyDensity=2;
    pdsch.Xoh_PDSCH=6*pdsch.EnablePTRS;


    if waveconfig.SSBurst.BlockPattern<="Case C"&&...
        waveconfig.Carriers.SubcarrierSpacing==60
        startslot=2;
    else
        startslot=1;
    end


    pdsch=setFRCSlotAllocation(pdsch,tdef,scs,startslot);


    waveconfig.PDSCH=pdsch;

end


function pxsch=setFRCSlotAllocation(pxsch,tdef,scs,startslot)

    if nargin<4
        startslot=0;
    end


    links=["uplink","downlink"];
    linkdirection=links(1+double(startsWith(tdef.Name,'DL')));

    spf=10*scs/15;
    pxsch.AllocatedSlots=startslot:spf-1;
    pxsch.AllocatedPeriod=spf;



    if strcmpi(tdef.DuplexMode,'TDD')

        [~,tp]=getTDDConfiguration(tdef.FR,scs,linkdirection,1);

        tddmask=repmat(tp,1,ceil(pxsch.AllocatedPeriod/length(tp)));
        tddmask=tddmask(1:pxsch.AllocatedPeriod);
        tddmask(pxsch.AllocatedSlots+1)=tddmask(pxsch.AllocatedSlots+1)-1;

        pxsch.AllocatedSlots=find(tddmask<0)-1;

    end
end


function waveconfig=getTestModelPDSCHParameters(tdef,waveconfig,sv)



    supportedversions=["15.1.0","15.2.0","15.7.0"];
    vcomp=strcmpi(sv,supportedversions);

    stdversion=find(vcomp);





    nrb=waveconfig.Carriers.NRB;
    scs=waveconfig.BWP.SubcarrierSpacing;



    pdsch=getPDSCHCommonParameters(tdef.FR,nrb,waveconfig.NCellID,tdef.Modulation(1));


    if stdversion>2
        waveconfig.PDCCH.DataSource='PN23';
        pdsch.DataSource='PN23';
    end

    if stdversion>1




        pdsch.AllocatedPRB=3:nrb-1;
        pdsch.Name=sprintf("Partial band PDSCH sequence with %s modulation scheme (target, RNTI = %d)",pdsch.Modulation,pdsch.RNTI);


        pdsch(2)=pdsch;
        pdsch(2).AllocatedPRB=0:2;
        pdsch(2).AllocatedSymbols=2:max(pdsch(2).AllocatedSymbols);
        pdsch(2).RNTI=2;
        pdsch(2).Name=sprintf("Partial band PDSCH sequence with %s modulation scheme (target, RNTI = %d)",pdsch(2).Modulation,pdsch(2).RNTI);
    end



    if tdef.BoostedPercent<100
        if tdef.BoostedPercent==1

            slotsperframe=10*fix(scs/15);

            pdsch(1).RNTI=2*(stdversion>1);
            pdsch(1).AllocatedSymbols=2*(stdversion>1):max(pdsch(1).AllocatedSymbols);
            pdsch(1).AllocatedPRB=0;
            pdsch(1).AllocatedSlots=3*(0:ceil(slotsperframe/3)-1);
            pdsch(1).AllocatedPeriod=slotsperframe;
            pdsch(1).Name="PDSCH sequence for lower PRB (3n slots)";

            pdsch(2)=pdsch(1);
            pdsch(2).AllocatedPRB=fix(nrb/2);
            pdsch(2).AllocatedSlots=1+3*(0:ceil((slotsperframe-1)/3)-1);
            pdsch(2).Name="PDSCH sequence for middle PRB (3n+1 slots)";

            pdsch(3)=pdsch(1);
            pdsch(3).AllocatedPRB=nrb-1;
            pdsch(3).AllocatedSlots=2+3*(0:ceil((slotsperframe-2)/3)-1);
            pdsch(3).Name="PDSCH sequence for upper PRB (3n+2 slots)";
        else



            if stdversion>2
                tdef.Modulation(2)="QPSK";
            end


            exprg1=stdversion>1;




            bwpalloc=pdsch(1).AllocatedPRB;
            bwpnrb=length(bwpalloc);
            P=getPRGSize(bwpnrb,1);


            bpercent=tdef.BoostedPercent/100;
            nprgmax=fix((bwpnrb+mod(bwpalloc(1),P)-P*exprg1)/P);
            nprg=min(fix(bpercent*bwpnrb/P),(nprgmax-mod(nprgmax,2))/2+1);


            lastprg=fix((bwpnrb+mod(bwpalloc(1),P))/P)-1;
            prg=[exprg1+(0:2:2*(nprg-2)),lastprg];
            prgprb=P*fix(bwpalloc(1)/P)+P*prg;
            boostedprb=reshape(prgprb+(0:P-1)',1,[]);

            pdsch(1).AllocatedPRB=boostedprb;
            pdsch(1).Power=tdef.BoostedPower;
            pdsch(1).RNTI=double(tdef.BoostedPower<0);
            pdsch(1).Name=sprintf("Partial band PDSCH sequence with %s modulation scheme (target, RNTI = %d)",pdsch(1).Modulation,pdsch(1).RNTI);


            if length(pdsch)==2&&pdsch(2).RNTI==2
                pdsch(2).Modulation='QPSK';
            end


            deboostedprb=setdiff(bwpalloc,boostedprb);
            pdsch(end+1)=pdsch(1);
            pdsch(end).AllocatedPRB=deboostedprb;
            pdsch(end).Power=10*log10((bwpnrb-10^(tdef.BoostedPower/10)*P*nprg)/(bwpnrb-P*nprg));
            pdsch(end).Modulation=tdef.Modulation(2);
            pdsch(end).RNTI=double(tdef.BoostedPower>=0);
            pdsch(end).Name=sprintf("Partial band PDSCH sequence with %s modulation scheme (non-target, RNTI = %d)",pdsch(end).Modulation,pdsch(end).RNTI);

        end
    end



    if strcmpi(tdef.DuplexMode,'TDD')


        [pattern,tp]=getTDDConfiguration(tdef.FR,scs);

        if tdef.BoostedPercent==1


            fp=repmat(0:length(pdsch)-1,1,ceil(10*fix(scs/15)/3));
            fp=fp(1:10*fix(scs/15));



            p1=length(tp);
            p2=length(fp);
            tpl=lcm(p1,p2);







            ipattern=repmat(length(pdsch)*tp,1,tpl/p1)+repmat(fp,1,tpl/p2);
            sequenceslotindices=arrayfun(@(x)find(x==ipattern)-1,0:5,'UniformOutput',0);

        else


            tpl=length(tp);
            sequenceslotindices=[repmat({0:pattern.nrofDownlinkSlots-1},1,length(pdsch)),...
            repmat({pattern.nrofDownlinkSlots+(0:ceil(pattern.nrofDownlinkSymbols/14)-1)},1,length(pdsch))];
        end


        pdschpart=pdsch;
        names=[pdsch.Name]+" (Full downlink slots)";
        [pdsch.Name]=deal(names{:});
        names=[pdschpart.Name]+" (Partial downlink slots)";
        [pdschpart.Name]=deal(names{:});

        allocsymbs=cellfun(@(x)min(x):pattern.nrofDownlinkSymbols-1,{pdschpart.AllocatedSymbols},'UniformOutput',false);
        [pdschpart.AllocatedSymbols]=deal(allocsymbs{:});
        pdsch=[pdsch,pdschpart];

        [pdsch.AllocatedPeriod]=deal(tpl);
        [pdsch.AllocatedSlots]=deal(sequenceslotindices{:});
    end


    waveconfig.PDSCH=pdsch;

end


function pdsch=getPDSCHCommonParameters(fr,nrb,~,mod,mcs)


    if nargin<5
        mcs=-1;
    end


    pdsch.Name="Full-band PDSCH sequence";
    pdsch.Enable=1;
    pdsch.BWP=1;
    pdsch.Power=0;
    pdsch.EnableCoding=mcs>=0;
    if pdsch.EnableCoding
        tcr=lookupPDSCHTCR(mcs,mod);
        datasource="PN9-ITU";
    else
        tcr=0.4785;
        datasource=0;
    end
    pdsch.DataSource=datasource;
    pdsch.TargetCodeRate=tcr;
    pdsch.Xoh_PDSCH=0;
    pdsch.Modulation=mod;
    pdsch.NLayers=1;
    pdsch.RVSequence=0;
    pdsch.VRBToPRBInterleaving=0;
    pdsch.VRBBundleSize=2;



    pdsch.AllocatedSymbols=0:13;
    pdsch.AllocatedSlots=0;
    pdsch.AllocatedPeriod=1;
    pdsch.AllocatedPRB=0:nrb-1;
    pdsch.RNTI=0;
    pdsch.NID=[];



    pdsch.RateMatch(1).CORESET=[];
    pdsch.RateMatch(1).Pattern.AllocatedPRB=0:2;
    pdsch.RateMatch(1).Pattern.AllocatedSymbols=0:1;
    pdsch.RateMatch(1).Pattern.AllocatedSlots=0;
    pdsch.RateMatch(1).Pattern.AllocatedPeriod=1;


    pdsch.PortSet=[];
    pdsch.PDSCHMappingType='A';
    pdsch.DMRSTypeAPosition=2;
    pdsch.DMRSLength=1;
    pdsch.DMRSAdditionalPosition=double(fr=="FR1");
    pdsch.DMRSConfigurationType=1;
    pdsch.NumCDMGroupsWithoutData=1;
    pdsch.NIDNSCID=[];
    pdsch.NSCID=0;
    pdsch.PowerDMRS=0;








    pdsch.EnablePTRS=(fr=="FR2");
    pdsch.PTRSTimeDensity=4;
    pdsch.PTRSFrequencyDensity=2;
    pdsch.PTRSREOffset="00";
    pdsch.PTRSPortSet=min(pdsch.PortSet);
    pdsch.PowerPTRS=0;

end


function p=getPRGSize(nrb,config)







    p=min(16,(1+(config==2))*2^find(nrb<=[36,72,144,275],1));

end



function tcr=lookupPDSCHTCR(mcs,mod)


    table1=[...
    0,2,120,0.2344
    1,2,157,0.3066
    2,2,193,0.3770
    3,2,251,0.4902
    4,2,308,0.6016
    5,2,379,0.7402
    6,2,449,0.8770
    7,2,526,1.0273
    8,2,602,1.1758
    9,2,679,1.3262
    10,4,340,1.3281
    11,4,378,1.4766
    12,4,434,1.6953
    13,4,490,1.9141
    14,4,553,2.1602
    15,4,616,2.4063
    16,4,658,2.5703
    17,6,438,2.5664
    18,6,466,2.7305
    19,6,517,3.0293
    20,6,567,3.3223
    21,6,616,3.6094
    22,6,666,3.9023
    23,6,719,4.2129
    24,6,772,4.5234
    25,6,822,4.8164
    26,6,873,5.1152
    27,6,910,5.3320
    28,6,948,5.5547];


    table2=[...
    0,2,120,0.2344;
    1,2,193,0.3770
    2,2,308,0.6016
    3,2,449,0.8770
    4,2,602,1.1758
    5,4,378,1.4766
    6,4,434,1.6953
    7,4,490,1.9141
    8,4,553,2.1602
    9,4,616,2.4063
    10,4,658,2.5703
    11,6,466,2.7305
    12,6,517,3.0293
    13,6,567,3.3223
    14,6,616,3.6094
    15,6,666,3.9023
    16,6,719,4.2129
    17,6,772,4.5234
    18,6,822,4.8164
    19,6,873,5.1152
    20,8,682.5,5.3320
    21,8,711,5.5547
    22,8,754,5.8906
    23,8,797,6.2266
    24,8,841,6.5703
    25,8,885,6.9141
    26,8,916.5,7.1602
    27,8,948,7.4063];


    table3=[...
    0,2,30,0.0586
    1,2,40,0.0781
    2,2,50,0.0977
    3,2,64,0.1250
    4,2,78,0.1523
    5,2,99,0.1934
    6,2,120,0.2344
    7,2,157,0.3066
    8,2,193,0.3770
    9,2,251,0.4902
    10,2,308,0.6016
    11,2,379,0.7402
    12,2,449,0.8770
    13,2,526,1.0273
    14,2,602,1.1758
    15,4,340,1.3281
    16,4,378,1.4766
    17,4,434,1.6953
    18,4,490,1.9141
    19,4,553,2.1602
    20,4,616,2.4063
    21,6,438,2.5664
    22,6,466,2.7305
    23,6,517,3.0293
    24,6,567,3.3223
    25,6,616,3.6094
    26,6,666,3.9023
    27,6,719,4.2129
    28,6,772,4.5234];%#ok<NASGU>


    bps=sum(strcmpi(mod,["QPSK","16QAM","64QAM","256QAM"]).*[2,4,6,8]);
    if bps==8
        actable=table2;
    else
        actable=table1;
    end
    tcr=actable(mcs+1,3)/1024;
end

function tdef=getULFRCDefinition(rc,bw,scs)






















    rc=char(rc);
    FR=rc(3:5);
    frNum=str2double(FR(end));
    secNum=str2double(rc(8));
    frcNum=str2double(rc(10:end));


    tdef.Name=rc;
    tdef.FR=string(FR);


    tdef.SubcarrierSpacing=getSCSUplinkFRC(frNum,secNum,frcNum);

    tdef.AllocatedNRB=getNRBUplinkFRC(frNum,secNum,frcNum);


    switch secNum
    case{1,3}
        tdef.Modulation="QPSK";
    case{2,4}
        tdef.Modulation="16QAM";
    otherwise
        tdef.Modulation="64QAM";
    end


    targetRatesPerSec=[308,658,193,658,567]/1024;
    tdef.TargetCodeRate=targetRatesPerSec(secNum);


    if(any(secNum==[3,4])&&frNum==1&&(frcNum>=15&&frcNum<=28))||...
        (any(secNum==[3,4])&&frNum==2&&(frcNum>=6&&frcNum<=10))
        tdef.NLayers=2;
    else
        tdef.NLayers=1;
    end


    tdef.TransformPrecoding=(secNum==3&&frNum==1&&any(frcNum==[29,30,31,32]))||...
    (secNum==3&&frNum==2&&any(frcNum==[11,12]));


    if frNum==2&&secNum>=3
        tdef.NAllocatedSymbols=10;
    else
        tdef.NAllocatedSymbols=14;
    end


    tdef.MappingType='A';
    tdef.DMRSTypeAPosition=2;


    if frNum==2&&secNum>=3
        tdef.MappingType='B';
    end


    if(frNum==1&&any(secNum==[3,4,5])&&any(frcNum==[1:7,15:21,29,30]))
        tdef.DMRSAdditionalPosition=0;
    elseif(frNum==2&&secNum>1)
        tdef.DMRSAdditionalPosition=0;
    else
        tdef.DMRSAdditionalPosition=1;
    end
    if frNum==2&&secNum==5&&any(frcNum==6:10)
        tdef.DMRSAdditionalPosition=1;
    end


    activescs=tdef.SubcarrierSpacing;
    if nargin>2&&~isempty(scs)
        activescs=scs;
    end
    [looknrb,lookbw,lookscs]=getValidNRB(tdef.FR,bw,activescs);
    minnrbidx=find(looknrb>=tdef.AllocatedNRB,1);
    if isempty(minnrbidx)
        minnrbidx=find(~isnan(looknrb),1,'last');
        newnrb=looknrb(minnrbidx);



        tdef.AllocatedNRB=newnrb;
    end
    tdef.ChannelBandwidth=lookbw(minnrbidx);
    tdef.ChannelNRB=looknrb(minnrbidx);
    tdef.SubcarrierSpacing=lookscs;


    duplexingmodes=["FDD","TDD"];
    tdef.DuplexMode=duplexingmodes(1+double(tdef.FR=="FR2"));
end


function scs=getSCSUplinkFRC(frNum,secNum,frcNum)




    commonFR1=[15,15,15,30,30,30,30];
    fr1SCS={[15,30,60,15,30,60,15,30,60],...
    [15,30,60,15,30,60],...
    [repmat(commonFR1,1,4),15,30,15,30],...
    repmat(commonFR1,1,4),...
    repmat(commonFR1,1,2)};

    commonFR2=[60,60,120,120,120];
    fr2SCS={[60,120,120,60,120],...
    [],...
    [repmat(commonFR2,1,2),60,120],...
    repmat(commonFR2,1,2),...
    repmat(commonFR2,1,2)};

    if nargin==2
        scs=fr1SCS{secNum};
        return;
    end


    if frNum==1
        scs=fr1SCS{secNum}(frcNum);
    else
        scs=fr2SCS{secNum}(frcNum);
    end

end

function nrb=getNRBUplinkFRC(frNum,secNum,frcNum)




    commonFR1=[25,52,106,24,51,106,273];
    fr1NRB={[25,11,11,106,51,24,15,6,6],...
    [25,11,11,106,51,24],...
    [repmat(commonFR1,1,4),25,24,25,24],...
    repmat(commonFR1,1,4),...
    repmat(commonFR1,1,2)};

    commonFR2=[66,132,32,66,132];
    fr2NRB={[66,32,66,33,16],...
    [],...
    [repmat(commonFR2,1,2),30,30],...
    repmat(commonFR2,1,2),...
    repmat(commonFR2,1,2)};

    if nargin==1
        if frNum==1
            nrb=fr1NRB;
        else
            nrb=fr2NRB;
        end
        return;
    end


    if frNum==1
        nrb=fr1NRB{secNum}(frcNum);
    else
        nrb=fr2NRB{secNum}(frcNum);
    end

end

function waveconfig=getFRCPUSCHParameters(tdef,ncellid)

    tdd=strcmpi(tdef.DuplexMode,'TDD');


    waveconfig.Name=tdef.Name;
    waveconfig.NCellID=ncellid;
    waveconfig.ChannelBandwidth=tdef.ChannelBandwidth;
    waveconfig.FrequencyRange=tdef.FR;
    waveconfig.NumSubframes=10+10*tdd;
    waveconfig.Windowing=0;
    waveconfig.DisplayGrids=0;



    carriers(1).SubcarrierSpacing=tdef.SubcarrierSpacing;
    carriers(1).NRB=tdef.ChannelNRB;
    carriers(1).RBStart=0;



    bwp(1).SubcarrierSpacing=carriers(1).SubcarrierSpacing;
    bwp(1).CyclicPrefix='Normal';
    bwp(1).NRB=carriers(1).NRB;
    bwp(1).RBOffset=0;


    pucch(1).Enable=0;


    pusch(1).Name=sprintf("PUSCH sequence for %s",tdef.Name);
    pusch(1).Enable=1;
    pusch(1).BWP=1;
    pusch(1).Power=0;
    pusch(1).EnableCoding=1;
    pusch(1).TargetCodeRate=tdef.TargetCodeRate;
    pusch(1).Xoh_PUSCH=0;
    pusch(1).TxScheme='codebook';
    pusch(1).Modulation=tdef.Modulation;
    pusch(1).NLayers=tdef.NLayers;
    pusch(1).NAntennaPorts=pusch(1).NLayers;
    pusch(1).RVSequence=0;
    pusch(1).IntraSlotFreqHopping='disabled';
    pusch(1).TransformPrecoding=tdef.TransformPrecoding;
    pusch(1).TPMI=0;
    pusch(1).GroupHopping='neither';
    pusch(1).RBOffset=0;
    pusch(1).InterSlotFreqHopping='disabled';
    pusch(1).NID=[];
    pusch(1).RNTI=1;
    pusch(1).DataSource="PN9-ITU";

    pusch(1).PUSCHMappingType=tdef.MappingType;
    pusch(1).AllocatedSymbols=0:tdef.NAllocatedSymbols-1;
    pusch(1).AllocatedSlots=0;
    pusch(1).AllocatedPeriod=1;
    allocprboffset=fix((tdef.ChannelNRB-tdef.AllocatedNRB)/2);
    pusch(1).AllocatedPRB=allocprboffset+(0:tdef.AllocatedNRB-1);
    pusch(1).PortSet=0:tdef.NLayers-1;
    pusch(1).DMRSTypeAPosition=tdef.DMRSTypeAPosition;
    pusch(1).DMRSLength=1;
    pusch(1).DMRSAdditionalPosition=tdef.DMRSAdditionalPosition;
    pusch(1).DMRSConfigurationType=1;
    pusch(1).NumCDMGroupsWithoutData=2;
    pusch(1).NIDNSCID=0;
    pusch(1).NSCID=0;
    pusch(1).NRSID=[];
    pusch(1).PowerDMRS=3;
    pusch(1).DisableULSCH=0;
    pusch(1).BetaOffsetACK=0;
    pusch(1).BetaOffsetCSI1=0;
    pusch(1).BetaOffsetCSI2=0;
    pusch(1).ScalingFactor=1;
    pusch(1).EnablePTRS=(tdef.FR=="FR2")&&(~tdef.TransformPrecoding);
    pusch(1).PTRSFrequencyDensity=2;
    pusch(1).PTRSTimeDensity=1;
    pusch(1).PTRSNumSamples=2;
    pusch(1).PTRSNumGroups=2;
    pusch(1).PTRSREOffset='00';
    pusch(1).PTRSPortSet=0:tdef.NLayers-1;
    pusch(1).PTRSNID=[];
    pusch(1).PowerPTRS=0;


    pusch=setFRCSlotAllocation(pusch,tdef,tdef.SubcarrierSpacing);


    waveconfig.Carriers=carriers;
    waveconfig.BWP=bwp;
    waveconfig.PUCCH=pucch;
    waveconfig.PUSCH=pusch;

end


function plotResourceGrid(~,waveconfig,cfgObj,gridset,isDownlink)

    if nargin<5
        isDownlink=1;
    end

    bwp=nr5g.internal.wavegen.linkSCS2BWP(waveconfig);


    if isDownlink
        carriers=cfgObj.SCSCarriers;

        chplevel.PDCCH=1.3;
        chplevel.PDSCH=0.8;
        chplevel.SS_Burst=0.6;


        ssburst=nr5g.internal.wavegen.mapSSBObj2Struct(cfgObj.SSBurst,carriers);

        for idx=1:length(carriers)
            isUsed=false;
            for idx2=1:length(cfgObj.BandwidthParts)
                if carriers{idx}.SubcarrierSpacing==cfgObj.BandwidthParts{idx2}.SubcarrierSpacing
                    isUsed=true;
                end
            end
            if~isUsed
                carriers(idx)=[];
            end
        end

        ssbreserved=nr5g.internal.wavegen.ssburstResources(ssburst,carriers);
    else
        carriers=waveconfig.Carriers;

        chplevel.PUCCH=1.3;
        chplevel.PUSCH=0.8;
        if isfield(waveconfig,'SRS')
            chplevel.SRS=1.5;
        end
    end

    for bp=1:length(gridset)



        bgrid=gridset(bp).ResourceGridPRB;
        if isDownlink
            cgrid=zeros(carriers{(bwp(bp).CarrierIdx)}.NSizeGrid,size(bgrid,2));
        else
            cgrid=zeros(carriers((bwp(bp).CarrierIdx)).NRB,size(bgrid,2));
        end
        bgrid(bgrid==0)=0.15;


        cgrid(bwp(bp).RBOffset+(1:size(bgrid,1)),:)=bgrid;

        if isDownlink

            thisRsv=ssbreserved{bwp(bp).CarrierIdx};
            if~isempty(thisRsv)
                nsymbolsperhalfframe=thisRsv.Period*14;
                symbols=nr5g.internal.wavegen.expandbyperiod(thisRsv.SymbolSet,nsymbolsperhalfframe,size(cgrid,2));
                cgrid(thisRsv.PRBSet+1,symbols+1)=chplevel.SS_Burst;
            end
        end


        cscaling=40;
        subplot(length(gridset),1,bp)
        ax=gca;
        image(ax,cscaling*cgrid);
        axis(ax,'xy');

        if isDownlink
            channelList='PDSCH and PDCCH';
        else
            channelList='PUSCH';
        end
        title(ax,sprintf('BWP %d in Carrier (SCS=%dkHz). %s location',bp,bwp(bp).SubcarrierSpacing,channelList));
        xlabel(ax,'Symbols');
        ylabel(ax,'Carrier RB');
        cmap=parula(64);
        colormap(ax,cmap);


        if bp==1

            fnames=strrep(fieldnames(chplevel),'_',' ');
            chpval=struct2cell(chplevel);
            clevels=cscaling*[chpval{:}];
            N=length(clevels);
            L=line(ax,ones(N),ones(N),'LineWidth',8);

            set(L,{'color'},mat2cell(cmap(min(1+clevels,length(cmap)),:),ones(1,N),3));

            legend(ax,fnames{:});
        end

    end

end


function cfgObj=getGenConfigObj(gen)

    cfgObj=gen.ConfigValue;
    if isstruct(cfgObj)
        if gen.LinkDirection=="uplink"
            cfgObj=mapStruct2ObjUplink(cfgObj);
        else
            cfgObj=mapStruct2ObjDownlink(cfgObj);
        end
    end
end

function cfgObj=mapStruct2ObjUplink(cfgS)


    cfgObj=nrULCarrierConfig;


    [cfgObj,cfgS]=mapStruct2ObjCCCommon(cfgObj,cfgS);


    cfgObj.PUSCH=mapPUSCH(cfgS);

end


function cfgObj=mapStruct2ObjDownlink(cfgS)


    cfgObj=nrDLCarrierConfig;


    [cfgObj,cfgS]=mapStruct2ObjCCCommon(cfgObj,cfgS);


    cfgObj.SSBurst=mapSSB(cfgS);
    [cset,ss,pdcch]=mapControl(cfgS);
    cfgObj.CORESET=cset;
    cfgObj.SearchSpaces=ss;
    cfgObj.PDCCH=pdcch;
    cfgObj.PDSCH=mapPDSCH(cfgS);
    cfgObj.CSIRS=mapCSIRS(cfgS);
end


function[cfgObj,cfgS]=mapStruct2ObjCCCommon(cfgObj,cfgS)


    cfgObj.FrequencyRange=cfgS.FrequencyRange;
    cfgObj.ChannelBandwidth=cfgS.ChannelBandwidth;
    cfgObj.NCellID=cfgS.NCellID;
    cfgObj.NumSubframes=cfgS.NumSubframes;
    if isprop(cfgObj,'WindowingPercent')&&isfield(cfgS,'Windowing')

        if cfgS.Windowing==0
            w=0;
        else
            w=[];
        end
        cfgObj.WindowingPercent=w;
    end

    if~isfield(cfgS,'Name')
        cfgS.Name='';
    else
        cfgObj.Label=cfgS.Name;
    end

    cfgObj.SCSCarriers=mapCarriers(cfgS);
    [cfgObj.BandwidthParts,cfgS]=mapBWP(cfgS);

end


function scsCfg=mapCarriers(cfgS)


    carriers=cfgS.Carriers;
    for idx=1:length(carriers)
        scsCfg{idx}=nrSCSCarrierConfig;

        scsCfg{idx}.SubcarrierSpacing=carriers(idx).SubcarrierSpacing;%#ok<*AGROW>
        scsCfg{idx}.NSizeGrid=carriers(idx).NRB;
        scsCfg{idx}.NStartGrid=carriers(idx).RBStart;
    end


    if isfield(cfgS,'SSBurst')

        if cfgS.SSBurst.Enable
            burstSCS=nr5g.internal.wavegen.blockPattern2SCS(cfgS.SSBurst.BlockPattern);
            scs=[carriers.SubcarrierSpacing];
            if~any(burstSCS==scs)

                [~,imax]=max(scs);

                fMin=scsCfg{imax}.NStartGrid*12*scsCfg{imax}.SubcarrierSpacing*1e3;
                fMax=fMin+scsCfg{imax}.NSizeGrid*12*scsCfg{imax}.SubcarrierSpacing*1e3;
                waveformCenter=fMin+(fMax-fMin)/2;

                idx=idx+1;
                scsCfg{idx}=nrSCSCarrierConfig;
                scsCfg{idx}.SubcarrierSpacing=burstSCS;
                scsCfg{idx}.NSizeGrid=20;

                ssbBottom=waveformCenter-(scsCfg{idx}.NSizeGrid/2)*12*burstSCS*1e3;
                start=ssbBottom/(burstSCS*12*1e3);
                if floor(start)~=start
                    scsCfg{idx}.NSizeGrid=scsCfg{idx}.NSizeGrid+1;
                    ssbBottom=waveformCenter-(scsCfg{idx}.NSizeGrid/2)*12*burstSCS*1e3;
                    start=ssbBottom/(burstSCS*12*1e3);
                end
                scsCfg{idx}.NStartGrid=start;
            end
        end
    end

end

function[bwp2,cfgS]=mapBWP(cfgS)

    bwp2={};

    bwp=cfgS.BWP;
    for idx=1:length(bwp)
        bwp2{idx}=nrWavegenBWPConfig;
        bwp2{idx}.BandwidthPartID=idx;
        bwp2{idx}.SubcarrierSpacing=bwp(idx).SubcarrierSpacing;
        bwp2{idx}.CyclicPrefix=bwp(idx).CyclicPrefix;
        bwp2{idx}.NSizeBWP=bwp(idx).NRB;

        carrierid=[cfgS.Carriers(:).SubcarrierSpacing]==bwp2{idx}.SubcarrierSpacing;
        bwp2{idx}.NStartBWP=bwp(idx).RBOffset+cfgS.Carriers(carrierid).RBStart;
        cfgS.BWP(idx).Carrier=find(carrierid,1);
    end
end

function ssb2=mapSSB(cfgS)

    ssb=cfgS.SSBurst;

    ssb2=nrWavegenSSBurstConfig;
    ssb2.Enable=ssb.Enable;
    ssb2.Power=ssb.Power;
    ssb2.BlockPattern=char(ssb.BlockPattern);
    ssb2.TransmittedBlocks=ssb.SSBTransmitted;
    ssb2.Period=ssb.SSBPeriodicity;
    ssb2.NCRBSSB=[];
    ssb2.DataSource='MIB';

    ssb2.SubcarrierSpacingCommon=30*(1+strcmpi(cfgS.FrequencyRange,'FR2'));

end

function[coreset2,ss2,pdcch2]=mapControl(cfgS)

    coreset2={};
    ss2={};
    pdcch2={};


    coresetused=[cfgS.PDCCH(:).CORESET];
    bwpused=[cfgS.PDCCH(:).BWP];


    coreset=cfgS.CORESET;
    for idx=1:length(coreset)

















        coreset2{idx}=nrCORESETConfig;
        coreset2{idx}.CORESETID=idx;
        coreset2{idx}.Label=['CORESET',num2str(idx)];















        bwpusingcoreset=bwpused(coresetused==idx);
        allblocks=[];maxsizes=[];maxnblocks=[];
        for b=bwpusingcoreset
            [coresetprb,nblocks,maxnblocks]=getCORESETPRB(cfgS.Carriers(cfgS.BWP(b).Carrier),cfgS.BWP(b),coreset(idx));%#ok<ASGLU>
            allblocks=[allblocks,nblocks];
            maxsizes=[maxsizes,maxnblocks];
        end

        bmap(1+allblocks(allblocks<min(maxnblocks)))=1;
        coreset2{idx}.FrequencyResources=bmap;


        coreset2{idx}.Duration=coreset(idx).Duration;
        if isfield(coreset(idx),'CCEREGMapping')
            coreset2{idx}.CCEREGMapping=coreset(idx).CCEREGMapping;
            coreset2{idx}.REGBundleSize=coreset(idx).REGBundleSize;
            coreset2{idx}.InterleaverSize=coreset(idx).InterleaverSize;
            coreset2{idx}.ShiftIndex=coreset(idx).ShiftIndex;
        end


        ss2{idx}=nrSearchSpaceConfig;
        ss2{idx}.SearchSpaceID=idx;
        ss2{idx}.Label=['SearchSpace',num2str(ss2{idx}.SearchSpaceID)];
        ss2{idx}.CORESETID=idx;

        ss2{idx}.SearchSpaceType='common';







        symbols=coreset(idx).AllocatedSymbols;
        ss2{idx}.StartSymbolWithinSlot=symbols(1);
        ss2{idx}.Duration=1;
        ss2{idx}.SlotPeriodAndOffset=[1,0];


        numREGs=6*numel(bmap)*coreset(idx).Duration;
        crstCCEs=fix(numREGs/6);
        ALs=[1,2,4,8,16];
        ind2del=ALs>crstCCEs;
        ss2{idx}.NumCandidates(ind2del)=0;

    end


    pdcch=cfgS.PDCCH;
    for idx=1:length(pdcch)
        pdcch2{idx}=nrWavegenPDCCHConfig;
        pdcch2{idx}.Enable=pdcch(idx).Enable;
        pdcch2{idx}.Label=['PDCCH',num2str(idx)];
        pdcch2{idx}.Power=pdcch(idx).Power;
        pdcch2{idx}.BandwidthPartID=pdcch(idx).BWP;
        pdcch2{idx}.Coding=pdcch(idx).EnableCoding;

        pdcch2{idx}.SearchSpaceID=pdcch(idx).CORESET;
        pdcch2{idx}.AggregationLevel=pdcch(idx).NumCCE;
        pdcch2{idx}.AllocatedCandidate=1+fix(pdcch(idx).StartCCE/pdcch(idx).NumCCE);


        coresetidx=pdcch(idx).CORESET;
        sallocation=coreset(coresetidx).AllocatedSlots;
        speriod=coreset(coresetidx).AllocatedPeriod;


        callocation=pdcch(idx).AllocatedSearchSpaces;
        cperiod=pdcch(idx).AllocatedPeriod;


        [eallocation,eperiod]=controlexpansion(sallocation,speriod,callocation,cperiod);

        pdcch2{idx}.SlotAllocation=eallocation;
        pdcch2{idx}.Period=eperiod;


        pdcch2{idx}.RNTI=pdcch(idx).RNTI;
        pdcch2{idx}.DMRSScramblingID=pdcch(idx).NID;
        pdcch2{idx}.DMRSPower=pdcch(idx).PowerDMRS;
        pdcch2{idx}.DataBlockSize=pdcch(idx).DataBlkSize;
        pdcch2{idx}.DataSource=pdcch(idx).DataSource;
    end

end

function pdsch2=mapPDSCH(cfgS)

    pdsch2={};


    pdsch=cfgS.PDSCH;
    for idx=1:length(pdsch)
        pdsch2{idx}=nrWavegenPDSCHConfig;
        pdsch2{idx}.Enable=pdsch(idx).Enable;
        pdsch2{idx}.Label=pdsch(idx).Name;
        pdsch2{idx}.Power=pdsch(idx).Power;
        pdsch2{idx}.BandwidthPartID=pdsch(idx).BWP;
        pdsch2{idx}.Coding=pdsch(idx).EnableCoding;
        pdsch2{idx}.DataSource=pdsch(idx).DataSource;
        pdsch2{idx}.TargetCodeRate=pdsch(idx).TargetCodeRate;
        pdsch2{idx}.TBScaling=1;
        pdsch2{idx}.XOverhead=pdsch(idx).Xoh_PDSCH;
        pdsch2{idx}.Modulation=pdsch(idx).Modulation;
        pdsch2{idx}.NumLayers=pdsch(idx).NLayers;
        pdsch2{idx}.RVSequence=pdsch(idx).RVSequence;
        pdsch2{idx}.VRBToPRBInterleaving=pdsch(idx).VRBToPRBInterleaving;
        pdsch2{idx}.VRBBundleSize=pdsch(idx).VRBBundleSize;
        pdsch2{idx}.SymbolAllocation=[pdsch(idx).AllocatedSymbols(1),(pdsch(idx).AllocatedSymbols(end)+1-pdsch(idx).AllocatedSymbols(1))];
        pdsch2{idx}.SlotAllocation=pdsch(idx).AllocatedSlots;
        pdsch2{idx}.Period=pdsch(idx).AllocatedPeriod;
        pdsch2{idx}.PRBSet=pdsch(idx).AllocatedPRB;
        pdsch2{idx}.RNTI=pdsch(idx).RNTI;
        pdsch2{idx}.NID=pdsch(idx).NID;
        pdsch2{idx}.MappingType=pdsch(idx).PDSCHMappingType;

        for idx2=1:length(pdsch(idx).RateMatch)
            pdsch2{idx}.ReservedCORESET=[pdsch2{idx}.ReservedCORESET,pdsch(idx).RateMatch(idx2).CORESET];
            pdsch2{idx}.ReservedPRB{idx2}=nrPDSCHReservedConfig;
            pdsch2{idx}.ReservedPRB{idx2}.PRBSet=pdsch(idx).RateMatch(idx2).Pattern.AllocatedPRB;
            pdsch2{idx}.ReservedPRB{idx2}.SymbolSet=pdsch(idx).RateMatch(idx2).Pattern.AllocatedSymbols;
            pdsch2{idx}.ReservedPRB{idx2}.Period=pdsch(idx).RateMatch(idx2).Pattern.AllocatedPeriod;
        end



        dmrs{idx}=nrPDSCHDMRSConfig;
        dmrs{idx}.DMRSPortSet=pdsch(idx).PortSet;
        dmrs{idx}.DMRSTypeAPosition=pdsch(idx).DMRSTypeAPosition;
        dmrs{idx}.DMRSLength=pdsch(idx).DMRSLength;
        dmrs{idx}.DMRSAdditionalPosition=pdsch(idx).DMRSAdditionalPosition;
        dmrs{idx}.DMRSConfigurationType=pdsch(idx).DMRSConfigurationType;
        dmrs{idx}.NumCDMGroupsWithoutData=pdsch(idx).NumCDMGroupsWithoutData;
        dmrs{idx}.NIDNSCID=pdsch(idx).NIDNSCID;
        dmrs{idx}.NSCID=pdsch(idx).NSCID;
        pdsch2{idx}.DMRSPower=pdsch(idx).PowerDMRS;
        pdsch2{idx}.DMRS=dmrs{idx};

        ptrs{idx}=nrPDSCHPTRSConfig;
        pdsch2{idx}.EnablePTRS=pdsch(idx).EnablePTRS;
        ptrs{idx}.TimeDensity=pdsch(idx).PTRSTimeDensity;
        ptrs{idx}.FrequencyDensity=pdsch(idx).PTRSFrequencyDensity;
        ptrs{idx}.REOffset=pdsch(idx).PTRSREOffset;
        ptrs{idx}.PTRSPortSet=pdsch(idx).PTRSPortSet;
        pdsch2{idx}.PTRSPower=pdsch(idx).PowerPTRS;
        pdsch2{idx}.PTRS=ptrs{idx};
    end
end

function[o,cond]=passign(s,o,f,p,ac)



    cond=isfield(s,f)&&~isempty(s.(f));
    if nargin==5
        cond=cond&&ac;
    end

    if cond
        if nargin==3
            o.(f)=s.(f);
        else
            o.(p)=s.(f);
        end
    end
end

function pusch2=mapPUSCH(cfgS)

    pusch2={};


    pusch=cfgS.PUSCH;
    for idx=1:length(pusch)
        pusch2{idx}=nrWavegenPUSCHConfig;

        pusch2{idx}.Enable=pusch(idx).Enable;
        pusch2{idx}.Label=pusch(idx).Name;
        pusch2{idx}.Power=pusch(idx).Power;
        pusch2{idx}.BandwidthPartID=pusch(idx).BWP;
        pusch2{idx}.Coding=pusch(idx).EnableCoding;
        pusch2{idx}.DataSource=pusch(idx).DataSource;
        pusch2{idx}.TargetCodeRate=pusch(idx).TargetCodeRate;
        pusch2{idx}.XOverhead=pusch(idx).Xoh_PUSCH;
        pusch2{idx}.Modulation=pusch(idx).Modulation;
        pusch2{idx}.NumLayers=pusch(idx).NLayers;
        pusch2{idx}.RVSequence=pusch(idx).RVSequence;
        pusch2{idx}.SymbolAllocation=[pusch(idx).AllocatedSymbols(1),(pusch(idx).AllocatedSymbols(end)+1-pusch(idx).AllocatedSymbols(1))];
        pusch2{idx}.SlotAllocation=pusch(idx).AllocatedSlots;
        pusch2{idx}.Period=pusch(idx).AllocatedPeriod;
        pusch2{idx}.PRBSet=pusch(idx).AllocatedPRB;
        pusch2{idx}.RNTI=pusch(idx).RNTI;
        pusch2{idx}.NID=pusch(idx).NID;
        pusch2{idx}.MappingType=pusch(idx).PUSCHMappingType;


        pusch2{idx}.TransformPrecoding=pusch(idx).TransformPrecoding;
        pusch2{idx}.TransmissionScheme=pusch(idx).TxScheme;
        pusch2{idx}.NumAntennaPorts=pusch(idx).NAntennaPorts;
        pusch2{idx}.TPMI=pusch(idx).TPMI;
        if strcmpi(pusch(idx).InterSlotFreqHopping,'enabled')
            pusch2{idx}.FrequencyHopping='interSlot';
        elseif strcmpi(pusch(idx).IntraSlotFreqHopping,'enabled')
            pusch2{idx}.FrequencyHopping='intraSlot';
        else
            pusch2{idx}.FrequencyHopping='neither';
        end
        if~strcmpi(pusch2{idx}.FrequencyHopping,'neither')
            if isempty(pusch(idx).RBOffset)
                pusch(idx).RBOffset=0;
            end
            secondHopPRB=mod(pusch(idx).AllocatedPRB(1)+pusch(idx).RBOffset,cfgS.BWP(idx).NRB);
            pusch(idx).RBOffset=secondHopPRB;
        end
        pusch2{idx}.SecondHopStartPRB=pusch(idx).RBOffset;


        pusch2{idx}.EnableULSCH=~pusch(idx).DisableULSCH;
        pusch2{idx}=passign(pusch(idx),pusch2{idx},'BetaOffsetACK','BetaOffsetACK',pusch(idx).BetaOffsetACK);
        pusch2{idx}=passign(pusch(idx),pusch2{idx},'BetaOffsetCSI1','BetaOffsetCSI1',pusch(idx).BetaOffsetCSI1);
        pusch2{idx}=passign(pusch(idx),pusch2{idx},'BetaOffsetCSI2','BetaOffsetCSI2',pusch(idx).BetaOffsetCSI2);
        pusch2{idx}.UCIScaling=pusch(idx).ScalingFactor;

        pusch2{idx}.EnableACK=0;
        pusch2{idx}.EnableCSI1=0;
        pusch2{idx}.EnableCSI2=0;
        pusch2{idx}.EnableCGUCI=0;



        dmrs=nrPUSCHDMRSConfig;
        dmrs=passign(pusch(idx),dmrs,'PortSet','DMRSPortSet');
        dmrs=passign(pusch(idx),dmrs,'DMRSConfigurationType','DMRSConfigurationType',~pusch(idx).TransformPrecoding);
        dmrs=passign(pusch(idx),dmrs,'DMRSTypeAPosition');
        dmrs=passign(pusch(idx),dmrs,'DMRSAdditionalPosition');
        dmrs=passign(pusch(idx),dmrs,'DMRSLength');
        dmrs=passign(pusch(idx),dmrs,'DMRSSymbolSet','CustomSymbolSet');
        dmrs=passign(pusch(idx),dmrs,'NIDNSCID');
        dmrs=passign(pusch(idx),dmrs,'NSCID','NSCID',~pusch(idx).TransformPrecoding);
        dmrs=passign(pusch(idx),dmrs,'NRSID','NRSID',pusch(idx).TransformPrecoding);
        if isfield(pusch(idx),'GroupHopping')&&pusch(idx).TransformPrecoding
            if strcmpi(pusch(idx).GroupHopping,'enable')
                dmrs.GroupHopping=1;
            elseif strcmpi(pusch(idx).GroupHopping,'disable')
                dmrs.SequenceHopping=1;
            end
        end
        if isfield(pusch(idx),'NumCDMGroupsWithoutData')&&~isempty(pusch(idx).NumCDMGroupsWithoutData)...
            &&~pusch(idx).TransformPrecoding&&pusch(idx).NumCDMGroupsWithoutData
            dmrs.NumCDMGroupsWithoutData=pusch(idx).NumCDMGroupsWithoutData;
        else
            dmrs.NumCDMGroupsWithoutData=1+pusch(idx).TransformPrecoding;
        end
        pusch2{idx}.DMRSPower=pusch(idx).PowerDMRS;
        pusch2{idx}.DMRS=dmrs;

        numDMRSPorts=numel(dmrs.DMRSPortSet);
        if numDMRSPorts

            pusch2{idx}.NumLayers=numDMRSPorts;
        end


        pusch2{idx}.EnablePTRS=pusch(idx).EnablePTRS;
        ptrs{idx}=nrPUSCHPTRSConfig;
        ptrs{idx}.TimeDensity=pusch(idx).PTRSTimeDensity;
        ptrs{idx}.FrequencyDensity=pusch(idx).PTRSFrequencyDensity;
        ptrs{idx}.REOffset=pusch(idx).PTRSREOffset;
        ptrs{idx}.PTRSPortSet=pusch(idx).PTRSPortSet;
        ptrs{idx}.NID=pusch(idx).PTRSNID;
        pusch2{idx}.PTRSPower=pusch(idx).PowerPTRS;
        pusch2{idx}.PTRS=ptrs{idx};
    end
end

function csirs2=mapCSIRS(cfgS)

    csirs2={};


    csirs=cfgS.CSIRS;
    for idx=1:length(csirs)
        csirs2{idx}=nrWavegenCSIRSConfig;
        csirs2{idx}.Enable=csirs(idx).Enable;
        csirs2{idx}.Label=['CSIRS',num2str(idx)];
        csirs2{idx}.Power=csirs(idx).Power;


        csirs2{idx}.BandwidthPartID=csirs(idx).BWP;


        csirs2{idx}.CSIRSType=csirs(idx).CSIRSType;
        csirs2{idx}.RowNumber=csirs(idx).RowNumber;
        csirs2{idx}.Density=csirs(idx).Density;
        csirs2{idx}.SubcarrierLocations=csirs(idx).SubcarrierLocations;
        csirs2{idx}.NumRB=csirs(idx).NumRB;
        csirs2{idx}.RBOffset=csirs(idx).RBOffset;
        csirs2{idx}.SymbolLocations=csirs(idx).SymbolLocations;
        csirs2{idx}.NID=csirs(idx).NID;


        allocperiod=csirs(idx).AllocatedPeriod;
        allocslots=csirs(idx).AllocatedSlots;
        if iscell(allocperiod)
            allocperiod=allocperiod{1};
        end
        if iscell(allocslots)
            allocslots=allocslots{1};
        end
        if isempty(allocperiod)
            csirs2{idx}.CSIRSPeriod='off';
        elseif allocperiod==1
            csirs2{idx}.CSIRSPeriod='on';
        else
            csirs2{idx}.CSIRSPeriod=[allocperiod(1),allocslots(1)];
        end
    end
end





function[coresetprb,nblocks,nblockmax]=getCORESETPRB(carrier,bwp,coreset)

    nstartbwp=carrier.RBStart+bwp.RBOffset;
    offsetprb=mod(6-nstartbwp,6);





    nblocks=unique(floor(coreset.AllocatedPRB/6));
    nblockmax=fix((bwp.NRB-offsetprb)/6);
    nblocks=nblocks((nblocks>=0)&(nblocks<nblockmax));
    coresetprb=expander(6*nblocks,6)+offsetprb;
end


function[eallocation,eperiod]=controlexpansion(sallocation,speriod,callocation,cperiod)


    eperiod=[];
    if~isempty(speriod)
        sallocation=sallocation(sallocation<speriod);
        if isempty(cperiod)
            srep=ceil(max(callocation)+1/length(sallocation));
        else
            srep=cperiod;
            eperiod=srep*speriod;
        end
    else
        srep=1;
        speriod=1;
    end


    if~isempty(cperiod)
        callocation=callocation(callocation<cperiod);
        crep=length(sallocation);
    else
        crep=1;
        cperiod=1;
    end


    sexp=reshape(sallocation(:)+speriod*(0:srep-1),1,[]);


    cexp=reshape(callocation(:)+cperiod*(0:crep-1),1,[]);


    cexp=cexp(cexp<length(sexp));
    eallocation=sexp(1+cexp);

end


function expanded=expander(d,e,s,o,excl)
    if nargin<5
        excl=0;
    end
    if nargin<4
        o=0;
    end
    if nargin<3
        s=1;
    end
    eseq=(o:s:e-1)';
    if excl
        eseq=setdiff((0:e-1)',eseq);
    end
    expanded=reshape(reshape(d,1,[])+eseq,1,[]);
end

