function sps=NonlinearElementMake(sps)

    CustomBlocks=unique(sps.DSS.custom.parent);

    if~isempty(CustomBlocks)
        if sps.PowerguiInfo.Continuous||sps.PowerguiInfo.Phasor||sps.PowerguiInfo.DiscretePhasor
            if~strcmp(get_param(sps.circuit,'SimulationStatus'),'stopped')
                Erreur.message='Your model contains blocks that require a discrete solver. The powergui Simulation mode must be set to Discrete.';
                Erreur.identifier='SpecializedPowerSystems:Powergui:IncompatibleBlocks';
                psberror(Erreur);
            end
        end
    end
    for i=1:length(CustomBlocks)

        sps.DSS.block(end+1).type='custom';
        sps.DSS.block(end).Blockname=getfullname(CustomBlocks(i));

        BlockName=sps.DSS.block(end).Blockname;
        blocs=find(sps.DSS.custom.parent==CustomBlocks(i));

        Nbin=sum(sps.DSS.custom.type(blocs)==1);
        Nbout=sum(sps.DSS.custom.type(blocs)==2);

        try

            states=eval(get_param([BlockName,'/NEDModel'],'nx'));
            switch get_param([BlockName,'/NEDModel'],'method')
            case 'Backward Euler'
                solver=1;
            case 'Trapezoidal'
                solver=2;
            end


        catch
            states=0;
            solver=1;
        end




        sps.DSS.block(end).size=[states,Nbout,Nbin];
        sps.DSS.block(end).xInit=[];
        sps.DSS.block(end).yinit=[];
        sps.DSS.block(end).iterate=0;
        sps.DSS.block(end).VI=[];
        sps.DSS.block(end).method=solver;

        IO=sps.DSS.custom.number(1:2,blocs);

        xin=IO(1:2,sps.DSS.custom.type(blocs)==1);
        yout=IO(1:2,sps.DSS.custom.type(blocs)==2);

        [~,j]=sort(xin(1,:));
        X=xin(2,j);

        [~,j]=sort(yout(1,:));
        Y=yout(2,j);

        sps.DSS.block(end).inputs=X;
        sps.DSS.block(end).outputs=Y;

        sps.DSS.model.inTags{end+1}=get_param([BlockName,'/Dmatrix/Goto'],'GotoTag');
        sps.DSS.model.inMux(end+1)=Nbin*Nbout;



    end