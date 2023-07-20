function[sps,YuNonlinear,Multimeter]=WideBandLineBlock(nl,sps,YuNonlinear,Multimeter)




    idx=nl.filter_type('Distributed Parameters Line Frequency Dependent');
    offset=length(sps.DistributedParameterLine);

    for i=1:length(idx)

        if sps.PowerguiInfo.Discrete==0

            if~strcmp(get_param(sps.circuit,'SimulationStatus'),'stopped')
                Erreur.message='Your model contains blocks that require a discrete solver. The powergui Simulation mode must be set to Discrete.';
                Erreur.identifier='SpecializedPowerSystems:Powergui:IncompatibleBlocks';
                psberror(Erreur);
            end
            return
        end

        block=nl.elements(idx(i));
        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');
        sps.DistributedParameterLine{i+offset}.BlockName=BlockName;
        sps.DistributedParameterLine{i+offset}.WB=1;
        sps.DistributedParameterLine{i+offset}.Decoupling=0;
        measure=get_param(block,'Measurements');

        WBfile=get_param(block,'WBfile');
        DATA=power_cableparam(WBfile,'NoError');
        if isempty(DATA)
            DATA=power_lineparam(WBfile,'NoError');
        end
        if isempty(DATA)
            Erreur.message='The specified MAT file does not contain valid geometry parameters';
            Erreur.identifier='SpecializedPowerSystems:FrequencyDependentLineBlock:InvalidGeometryParameters';
            error(Erreur.message,Erreur.identifier);
            return
        end

        sps.DistributedParameterLine{i+offset}.WBfile=WBfile;
        DATA.WB.Ts=sps.PowerguiInfo.Ts;
        DATA.WB=TimeDomainWB(DATA.WB);

        N=size(DATA.R,1);
        blocinit(block,{N,DATA.frequency,DATA.R,DATA.L,DATA.C,DATA.length});





        nodes=nl.block_nodes(block);

        [Zm,Rm,Smode,Ti]=blmodlin(N,DATA.frequency,DATA.R,DATA.L,DATA.C,BlockNom);

        Vmax=max(Smode);
        Ts_min=DATA.length/Vmax;
        if sps.PowerguiInfo.Ts>Ts_min


            error(message('physmod:powersys:library:DPLTsVsPropagationTime',BlockName,num2str(Ts_min)));
        end
        freq=0;

        G=reshape(DATA.WB.GYc,[N,N]);
        sps.DistributedParameterLine{i+offset}.WBG=G;

        x=size(sps.source,1)+1;
        distlinex=[N,x,length(sps.outstr)+1,DATA.length,Zm,Rm,Smode,reshape(Ti,1,N^2)];
        sps.distline(size(sps.distline,1)+1,1:length(distlinex))=distlinex;

        for jj=1:N
            sps.rlc(end+1,1:6)=[nodes(jj),0,0,1/sum(G(jj,:)),0,0];
            sps.rlcnames{end+1}=['r_',num2str(jj),'_in: ',BlockNom];
            sps.source(end+1,1:7)=[0,nodes(jj),1,0,0,freq,19];
            YuNonlinear(end+1,1:2)=[nodes(jj),0];

            sps.srcstr{end+1}=['I_in_phase_',num2str(jj),': ',BlockNom];
            sps.outstr{end+1}=['U_in_phase_',num2str(jj),': ',BlockNom];
            sps.DistributedParameterLine{i+offset}.Vs(jj)=length(sps.outstr);
            sps.DistributedParameterLine{i+offset}.Is(jj)=length(sps.srcstr);
            sps.sourcenames(end+1,1)=block;

            switch measure
            case{'Phase-to-ground voltages','All voltages and currents'}
                Multimeter.Yu(end+1,1:2)=sps.rlc(end,1:2);
                Multimeter.V{end+1}=['Us_ph',num2str(jj),'_gnd: ',BlockNom];
            end
        end

        for jj=1:N
            for k=jj+1:N
                sps.rlc(end+1,1:6)=[nodes(jj),nodes(k),0,-1/G(jj,k),0,0];
                sps.rlcnames{end+1}=['r_',num2str(jj),'_',num2str(k),'_in: ',BlockNom];
            end
        end

        for jj=1:N
            sps.rlc(end+1,1:6)=[nodes(N+jj),0,0,1/sum(G(jj,:)),0,0];
            sps.rlcnames{end+1}=['r_',num2str(jj),'_out: ',BlockNom];
            sps.source(end+1,1:7)=[0,nodes(N+jj),1,0,0,freq,19];
            YuNonlinear(end+1,1:2)=[nodes(N+jj),0];

            sps.srcstr{end+1}=['I_out_phase_',num2str(jj),': ',BlockNom];
            sps.outstr{end+1}=['U_out_phase_',num2str(jj),': ',BlockNom];
            sps.DistributedParameterLine{i+offset}.Vr(jj)=length(sps.outstr);
            sps.DistributedParameterLine{i+offset}.Ir(jj)=length(sps.srcstr);
            sps.sourcenames(end+1,1)=block;

            switch measure
            case{'Phase-to-ground voltages','All voltages and currents'}
                Multimeter.Yu(end+1,1:2)=sps.rlc(end,1:2);
                Multimeter.V{end+1}=['Ur_ph',num2str(jj),'_gnd: ',BlockNom];
            end
        end

        for jj=1:N
            for k=jj+1:N
                sps.rlc(end+1,1:6)=[nodes(N+jj),nodes(N+k),0,-1/G(jj,k),0,0];
                sps.rlcnames{end+1}=['r_',num2str(jj),'_',num2str(k),'_out: ',BlockNom];
            end
        end
        xc=size(sps.modelnames{19},2);
        sps.modelnames{19}(xc+1)=block;
        sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/From'],'GotoTag');
        sps.NonlinearDevices.Demux(end+1)=2*N;
        sps.U.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
        sps.U.Mux(end+1)=2*N;

        if isfield(sps,'LoadFlow')
            if N==3

                if size(DATA.R,1)==3
                    a=exp(1i*2*pi/3);T=1/3*[1,1,1;1,a,a^2;1,a^2,a];
                    w=2*pi*DATA.frequency;
                    zser=DATA.R+1i*DATA.L*w;
                    Zseq=T*zser*inv(T);
                    Cseq=T*DATA.C*inv(T);
                    R1=real(Zseq(2,2));
                    L1=imag(Zseq(2,2))/w;
                    C1=Cseq(2,2);
                end

                sps.LoadFlow.Lines.handle{end+1}=block;
                if size(DATA.R,1)==1
                    sps.LoadFlow.Lines.r{end+1}=DATA.R(1);
                elseif size(DATA.R,1)==3
                    sps.LoadFlow.Lines.r{end+1}=R1;
                else
                    sps.LoadFlow.Lines.r{end+1}=NaN;
                end
                if size(DATA.L,1)==1
                    sps.LoadFlow.Lines.l{end+1}=DATA.L(1);
                elseif size(DATA.R,1)==3
                    sps.LoadFlow.Lines.l{end+1}=L1;
                else
                    sps.LoadFlow.Lines.l{end+1}=NaN;
                end
                if size(DATA.C,1)==1
                    sps.LoadFlow.Lines.c{end+1}=DATA.C(1);
                elseif size(DATA.C,1)==3
                    sps.LoadFlow.Lines.c{end+1}=C1;
                else
                    sps.LoadFlow.Lines.c{end+1}=NaN;
                end
                sps.LoadFlow.Lines.long{end+1}=DATA.length;
                sps.LoadFlow.Lines.freq{end+1}=DATA.frequency;
                sps.LoadFlow.Lines.leftnodes{end+1}=nodes(1:3);
                sps.LoadFlow.Lines.rightnodes{end+1}=nodes(4:6);
                sps.LoadFlow.Lines.LeftbusNumber{end+1}=[];
                sps.LoadFlow.Lines.RightbusNumber{end+1}=[];
                sps.LoadFlow.Lines.isPI{end+1}=0;
            end
        end
        if isfield(sps,'UnbalancedLoadFlow')
            sps.UnbalancedLoadFlow.Lines.handle{end+1}=block;
            sps.UnbalancedLoadFlow.Lines.r{end+1}=DATA.R;
            sps.UnbalancedLoadFlow.Lines.l{end+1}=DATA.L;
            sps.UnbalancedLoadFlow.Lines.c{end+1}=DATA.C;
            sps.UnbalancedLoadFlow.Lines.long{end+1}=DATA.length;
            sps.UnbalancedLoadFlow.Lines.freq{end+1}=DATA.frequency;
            sps.UnbalancedLoadFlow.Lines.leftnodes{end+1}=nodes(1:N);
            sps.UnbalancedLoadFlow.Lines.rightnodes{end+1}=nodes(N+1:2*N);
            sps.UnbalancedLoadFlow.Lines.LeftbusNumber{end+1}=[];
            sps.UnbalancedLoadFlow.Lines.RightbusNumber{end+1}=[];
            sps.UnbalancedLoadFlow.Lines.isPI{end+1}=0;
            sps.UnbalancedLoadFlow.Lines.BlockType{end+1}='Dist';
        end
    end