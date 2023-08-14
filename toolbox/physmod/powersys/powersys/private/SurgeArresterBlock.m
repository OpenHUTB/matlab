function[sps,YuNonlinear,Multimeter]=SurgeArresterBlock(nl,sps,YuNonlinear,Multimeter)






    idx=nl.filter_type('Surge Arrester');
    sps.NbMachines=sps.NbMachines+length(idx);
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    for i=1:numel(blocks)
        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');
        measure=get_param(block,'Measurements');


        IM=getSPSmaskvalues(block,{'UseDiscreteRobustSolver'});
        LocallyWantDSS=0;
        if sps.PowerguiInfo.Discrete&&strcmp(get_param(block,'BreakLoop'),'off')&&IM==1;
            LocallyWantDSS=1;
        end

        if sps.PowerguiInfo.WantDSS||LocallyWantDSS
            sps.DSS.block(end+1).type='Surge Arrester';
            sps.DSS.block(end).Blockname=BlockName;
        end

        NotAllowedForPhasorSimulation(sps.PowerguiInfo.Phasor||sps.PowerguiInfo.DiscretePhasor,BlockName,'Surge Arrester');

        nodes=nl.block_nodes(block);
        sps.source(end+1,1:7)=[nodes(1),nodes(2),1,0,0,0,17];

        YuNonlinear(end+1,1:2)=[nodes(1),nodes(2)];

        sps.srcstr{end+1}=['I_',BlockNom];
        sps.outstr{end+1}=['U_',BlockNom];
        x=size(sps.source,1);


        sps.InputsNonZero(end+1)=x;

        if sps.PowerguiInfo.WantDSS||LocallyWantDSS

            sps.DSS.block(end).size=[0,1,1];

            sps.DSS.block(end).xInit=[];
            sps.DSS.block(end).yinit=0;
            sps.DSS.block(end).iterate=1;

            [Vref,Iref,ncol,kalfa1,kalfa2,kalfa3]=getSPSmaskvalues(block,{'ProtectionVoltage','ReferenceCurrent','Columns','Segment1','Segment2','Segment3'});

            VI=VI_MOV(Vref,Iref,ncol,kalfa1(1),kalfa2(1),kalfa3(1),kalfa1(2),kalfa2(2),kalfa3(2));

            sps.DSS.block(end).VI=VI;
            sps.DSS.block(end).method=1;
            sps.DSS.block(end).inputs=x;
            sps.DSS.block(end).outputs=length(sps.outstr);
            sps.DSS.model.inTags{end+1}='';
            sps.DSS.model.inMux(end+1)=1;
        end


        if strcmp('Branch voltage',measure)||strcmp('Branch voltage and current',measure)
            Multimeter.Yu(end+1,1:2)=[nodes(1),nodes(2)];
            Multimeter.V{end+1}=['Ub: ',BlockNom];
        end
        if strcmp('Branch current',measure)||strcmp('Branch voltage and current',measure)
            Multimeter.I{end+1}=['Ib: ',BlockNom];
            Multimeter.Yi{end+1,2}=x;
        end
        xc=size(sps.modelnames{17},2);
        sps.modelnames{17}(xc+1)=block;
        sps.sourcenames(end+1,1)=block;
        sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/From'],'GotoTag');
        sps.NonlinearDevices.Demux(end+1)=1;
        sps.U.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
        sps.U.Mux(end+1)=1;
    end

    sps.nbmodels(17)=size(sps.modelnames{17},2);


    function[VI_nonlin]=VI_MOV(Vref,Iref,ncol,k1,k2,k3,alpha1,alpha2,alpha3)




        Imax=Iref*4*ncol;




        I12=ncol*Iref*(k1/k2)^(alpha1*alpha2/(alpha1-alpha2));
        I23=ncol*Iref*(k2/k3)^(alpha2*alpha3/(alpha2-alpha3));

        Nseg=5;


        deltaI1=I12/Nseg;
        deltaI2=(I23-I12)/Nseg;
        deltaI3=(Imax-I23)/Nseg;

        I=[0:deltaI1:I12,(I12+deltaI2):deltaI2:I23,(I23+deltaI3):deltaI3:Imax]';
        N=length(I);
        V=zeros(N,1);
        for k=1:N
            Ik=I(k);
            if Ik<=I12
                V(k)=Vref*k1*(Ik/(ncol*Iref))^(1/alpha1);
            elseif Ik>I12&&Ik<I23
                V(k)=Vref*k2*(Ik/(ncol*Iref))^(1/alpha2);
            else
                V(k)=Vref*k3*(Ik/(ncol*Iref))^(1/alpha3);
            end
        end



        V_first=0.8*Vref;
        I_first=Iref*ncol*(V_first/Vref)^alpha1/k1^alpha1;

        V=V(2:end);
        I=I(2:end);

        if V_first<V(1)
            V=[V_first;V];
            I=[I_first;I];
        end


        V_nl=[-V(end:-1:1);V(1:end)];
        I_nl=[-I(end:-1:1);I(1:end)];
















        VI_nonlin=[V_nl,I_nl];