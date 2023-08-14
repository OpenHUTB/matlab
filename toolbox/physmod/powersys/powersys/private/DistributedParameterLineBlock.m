function[sps,YuNonlinear,Multimeter]=DistributedParameterLineBlock(nl,sps,YuNonlinear,Multimeter)



    idx=nl.filter_type('Distributed Parameters Line');

    for i=1:length(idx)
        block=nl.elements(idx(i));
        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);
        sps.DistributedParameterLine{i}.BlockName=BlockName;
        sps.DistributedParameterLine{i}.WB=0;
        sps.DistributedParameterLine{i}.WBG=[];
        sps.DistributedParameterLine{i}.Decoupling=0;
        [nphase,freq,Rmat,Lmat,Cmat,long]=getSPSmaskvalues(block,{'Phases','Frequency','Resistance','Inductance','Capacitance','Length'});
        if nphase==3||nphase==1
            switch get_param(block,'Decoupling')
            case 'on'
                sps.DistributedParameterLine{i}.Decoupling=1;
            end
        end
        BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');
        measure=get_param(block,'Measurements');
        blocinit(block,{nphase,freq,Rmat,Lmat,Cmat,long});





        nodes=nl.block_nodes(block);

        [Zm,Rm,Smode,Ti]=blmodlin(nphase,freq,Rmat,Lmat,Cmat,BlockNom);
        if sps.PowerguiInfo.Discrete

            Vmax=max(Smode);
            Ts_min=long/Vmax;
            if sps.PowerguiInfo.Ts>Ts_min


                error(message('physmod:powersys:library:DPLTsVsPropagationTime',BlockName,num2str(Ts_min)));
            end
        end
        Zimp=zeros(nphase,nphase);
        for iphase=1:nphase
            Zimp(iphase,iphase)=Zm(iphase)+0.25*Rm(iphase)*long;
        end
        Yphase=Ti*inv(Zimp)*(Ti');

        x=size(sps.source,1)+1;
        distlinex=[nphase,x,length(sps.outstr)+1,long,Zm,Rm,Smode,reshape(Ti,1,nphase^2)];
        sps.distline(size(sps.distline,1)+1,1:length(distlinex))=distlinex;

        for jj=1:nphase
            sps.rlc(end+1,1:6)=[nodes(jj),0,0,1/sum(Yphase(jj,:)),0,0];
            sps.rlcnames{end+1}=['r_',num2str(jj),'_in: ',BlockNom];
            sps.source(end+1,1:7)=[0,nodes(jj),1,0,0,freq,19];
            YuNonlinear(end+1,1:2)=[nodes(jj),0];

            sps.srcstr{end+1}=['I_in_phase_',num2str(jj),': ',BlockNom];
            sps.outstr{end+1}=['U_in_phase_',num2str(jj),': ',BlockNom];
            sps.DistributedParameterLine{i}.Vs(jj)=length(sps.outstr);
            sps.DistributedParameterLine{i}.Is(jj)=length(sps.srcstr);
            sps.sourcenames(end+1,1)=block;

            switch measure
            case{'Phase-to-ground voltages','All voltages and currents'}
                Multimeter.Yu(end+1,1:2)=sps.rlc(end,1:2);
                Multimeter.V{end+1}=['Us_ph',num2str(jj),'_gnd: ',BlockNom];
            end
        end

        for jj=1:nphase
            for k=jj+1:nphase
                sps.rlc(end+1,1:6)=[nodes(jj),nodes(k),0,-1/Yphase(jj,k),0,0];
                sps.rlcnames{end+1}=['r_',num2str(jj),'_',num2str(k),'_in: ',BlockNom];
            end
        end

        for jj=1:nphase
            for k=jj+1:nphase
                sps.rlc(end+1,1:6)=[nodes(nphase+jj),nodes(nphase+k),0,-1/Yphase(jj,k),0,0];
                sps.rlcnames{end+1}=['r_',num2str(jj),'_',num2str(k),'_out: ',BlockNom];
            end
        end

        for jj=1:nphase
            sps.rlc(end+1,1:6)=[nodes(nphase+jj),0,0,1/sum(Yphase(jj,:)),0,0];
            sps.rlcnames{end+1}=['r_',num2str(jj),'_out: ',BlockNom];
            sps.source(end+1,1:7)=[0,nodes(nphase+jj),1,0,0,freq,19];
            YuNonlinear(end+1,1:2)=[nodes(nphase+jj),0];

            sps.srcstr{end+1}=['I_out_phase_',num2str(jj),': ',BlockNom];
            sps.outstr{end+1}=['U_out_phase_',num2str(jj),': ',BlockNom];
            sps.DistributedParameterLine{i}.Vr(jj)=length(sps.outstr);
            sps.DistributedParameterLine{i}.Ir(jj)=length(sps.srcstr);
            sps.sourcenames(end+1,1)=block;

            switch measure
            case{'Phase-to-ground voltages','All voltages and currents'}
                Multimeter.Yu(end+1,1:2)=sps.rlc(end,1:2);
                Multimeter.V{end+1}=['Ur_ph',num2str(jj),'_gnd: ',BlockNom];
            end
        end
        xc=size(sps.modelnames{19},2);
        sps.modelnames{19}(xc+1)=block;


        if sps.PowerguiInfo.Continuous||sps.PowerguiInfo.Discrete
            sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/From'],'GotoTag');
            sps.NonlinearDevices.Demux(end+1)=2*nphase;
            sps.U.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
            sps.U.Mux(end+1)=2*nphase;
        end

        if isfield(sps,'LoadFlow')
            if nphase==3

                if size(Rmat,1)==3
                    a=exp(1i*2*pi/3);T=1/3*[1,1,1;1,a,a^2;1,a^2,a];
                    w=2*pi*freq;
                    zser=Rmat+1i*Lmat*w;
                    Zseq=T*zser*inv(T);
                    Cseq=T*Cmat*inv(T);
                    R1=real(Zseq(2,2));
                    L1=imag(Zseq(2,2))/w;
                    C1=Cseq(2,2);
                end

                sps.LoadFlow.Lines.handle{end+1}=block;
                if size(Rmat,1)==1
                    sps.LoadFlow.Lines.r{end+1}=Rmat(1);
                elseif size(Rmat,1)==3
                    sps.LoadFlow.Lines.r{end+1}=R1;
                else
                    sps.LoadFlow.Lines.r{end+1}=NaN;
                end
                if size(Lmat,1)==1
                    sps.LoadFlow.Lines.l{end+1}=Lmat(1);
                elseif size(Lmat,1)==3
                    sps.LoadFlow.Lines.l{end+1}=L1;
                else
                    sps.LoadFlow.Lines.l{end+1}=NaN;
                end
                if size(Cmat,1)==1
                    sps.LoadFlow.Lines.c{end+1}=Cmat(1);
                elseif size(Cmat,1)==3
                    sps.LoadFlow.Lines.c{end+1}=C1;
                else
                    sps.LoadFlow.Lines.c{end+1}=NaN;
                end
                sps.LoadFlow.Lines.long{end+1}=long;
                sps.LoadFlow.Lines.freq{end+1}=freq;
                sps.LoadFlow.Lines.leftnodes{end+1}=nodes(1:3);
                sps.LoadFlow.Lines.rightnodes{end+1}=nodes(4:6);
                sps.LoadFlow.Lines.LeftbusNumber{end+1}=[];
                sps.LoadFlow.Lines.RightbusNumber{end+1}=[];
                sps.LoadFlow.Lines.isPI{end+1}=0;
            end
        end
        if isfield(sps,'UnbalancedLoadFlow')
            sps.UnbalancedLoadFlow.Lines.handle{end+1}=block;
            sps.UnbalancedLoadFlow.Lines.r{end+1}=Rmat;
            sps.UnbalancedLoadFlow.Lines.l{end+1}=Lmat;
            sps.UnbalancedLoadFlow.Lines.c{end+1}=Cmat;
            sps.UnbalancedLoadFlow.Lines.long{end+1}=long;
            sps.UnbalancedLoadFlow.Lines.freq{end+1}=freq;
            sps.UnbalancedLoadFlow.Lines.leftnodes{end+1}=nodes(1:nphase);
            sps.UnbalancedLoadFlow.Lines.rightnodes{end+1}=nodes(nphase+1:2*nphase);
            sps.UnbalancedLoadFlow.Lines.LeftbusNumber{end+1}=[];
            sps.UnbalancedLoadFlow.Lines.RightbusNumber{end+1}=[];
            sps.UnbalancedLoadFlow.Lines.isPI{end+1}=0;
            sps.UnbalancedLoadFlow.Lines.BlockType{end+1}='Dist';
        end
    end