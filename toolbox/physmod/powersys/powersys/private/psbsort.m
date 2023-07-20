function sps=psbsort(BLOCKLIST,system,options)









    if~exist('options','var')
        options='empty';
    end

    UpdateMultimeter=strcmp(options,'Multimeter');
    LoadFlowAnalysis=strcmp(options,'GetLoadFlowData');
    UnbalancedLoadFlowAnalysis=strcmp(options,'GetUnbalancedLoadFlowData');



    if LoadFlowAnalysis
        LFtypes={'asm','sm','rlcload','pqload','vsrc','xfo'};
        for i=1:length(LFtypes)
            sps.LoadFlow.(LFtypes{i})=struct('blockType','','busType','','P',[],'Q',[],'Qmin',[],'Qmax',[],'nodes',[],'handle',[]);
        end

        sps.LoadFlow.Lines=struct('r',[],'l',[],'c',[],'Zmatrix',[],'Ymatrix',[],'long',[],'freq',[],'leftnodes',[],'rightnodes',[],'LeftbusNumber',[],'RightbusNumber',[],'handle',[],'isPI',[],'Vbase',[]);
        sps.LoadFlow.bus=[];
        sps.LoadFlow.bus=[];
        sps.LoadFlow.VoltageRatio=[];
        sps.LoadFlow.error=[];
    end

    if UnbalancedLoadFlowAnalysis
        LFtypes={'asm','sm','rlcload','pqload','vsrc','xfo'};
        for i=1:length(LFtypes)
            sps.UnbalancedLoadFlow.(LFtypes{i})=struct('blockType','','busType','','P',[],'Q',[],'Qmin',[],'Qmax',[],'nodes',[],'handle',[],'connection',[]);
        end

        sps.UnbalancedLoadFlow.Lines=struct('r',[],'l',[],'c',[],'Zmatrix',[],'Ymatrix',[],'long',[],'freq',[],'leftnodes',[],'rightnodes',[],'LeftbusNumber',[],'RightbusNumber',[],'handle',[],'isPI',[],'Vbase',[],'BlockType',[]);
        sps.UnbalancedLoadFlow.Transfos=struct('Units',[],'handle',[],'Type',[],'conW1',[],'conW2',[],'conW3',[],'Pnom',[],'W1',[],'W2',[],'W3',[],'RmLm',[],'W1busNumber',[],'W2busNumber',[],'W3busNumber',[],'W1nodes',[],'W2nodes',[],'W3nodes',[],'Fnom',[],'L0',[]);
        sps.UnbalancedLoadFlow.bus=[];
        sps.UnbalancedLoadFlow.VoltageRatio=[];
        sps.UnbalancedLoadFlow.error=[];
    end




    YuSwitches=[];
    YuNonlinear=[];
    YuMeasurement=[];


    Multimeter.Yu=[];
    Multimeter.Yi=cell(0,2);
    Multimeter.YL={};
    Multimeter.V={};
    Multimeter.I={};
    Multimeter.L={};
    Multimeter.F={};
    Multimeter.Q1Q4=[];
    Multimeter.D1D4=[];
    Multimeter.D5D6=[];
    Multimeter.Others=[];


    YiExcTransfos.Yi=cell(0,2);
    YiExcTransfos.outstr={};
    YiExcTransfos.Tags=cell(0);


    VfVoltageSource.source=[];
    VfVoltageSource.srcstr={};
    VfVoltageSource.sourcenames=[];


    sps.circuit=system;
    sps.NoErrorOnMaxIteration=1;
    sps.basicnonlinearmodels=21+1+1;
    sps.blksrcnames={};
    sps.distline=[];
    sps.DCMachines={};
    sps.DiscreteSimulation=0;

    sps.DistributedParameterLine=[];
    sps.IdealSwitch=0;
    sps.Breaker=0;
    sps.Diode=0;
    sps.Thyristors=0;
    sps.GTO=0;
    sps.MOSFET=0;
    sps.IGBT=0;

    sps.ForceLonToZero.status=0;
    sps.ForceLonToZero.blocks=cell(0);
    sps.GotoSources=cell(0);
    sps.LinearTransformers=[];
    sps.machines=[];
    sps.LoadFlowParameters=[];
    sps.mesurexmeter=[];
    sps.mesureFluxes=[];
    sps.measurenames=[];
    sps.modelnames=cell(sps.basicnonlinearmodels+4,1);
    sps.multimeters=[];
    sps.nbmodels=zeros(1,sps.basicnonlinearmodels+4);
    sps.NbMachines=0;

    sps.NumberOfSfunctionSwitches=0;

    sps.ObsoleteNodes=[];
    sps.Outputs=cell(0,2);
    sps.outstr={};
    sps.rlc=[];
    sps.rlcnames={};
    sps.SaturableTransfo={};
    sps.source=zeros(0,7);
    sps.sourcenames=[];
    sps.SourceBlocks.indice=[];
    sps.srcstr={};
    sps.syslength=length(system)+2;
    sps.switches=zeros(0,5);
    sps.SwitchNames={};
    sps.SwitchVf=[];
    sps.Rswitch=[];
    sps.SPIDresistors=[];
    sps.yout=[];
    sps.ytype=[];
    sps.SilentMode=0;
    sps.CreateNetList=0;
    sps.OscillatoryModes='';
    sps.Zblocks=cell(0,4);
    sps.VoltNodes=zeros(0,2);


    sps.MeasurementBlock.name=[];
    sps.MeasurementBlock.indice=[];
    sps.SourceBlock.name=[];
    sps.SourceBlock.indice=[];
    sps.NonlinearBlock.name=[];
    sps.NonlinearBlock.inputname=[];
    sps.NonlinearBlock.Uindice=[];
    sps.NonlinearBlock.Yindice=[];


    sps.BlockInitialState.state={};
    sps.BlockInitialState.value={};
    sps.BlockInitialState.block={};
    sps.BlockInitialState.type={};


    sps.y3LevelCurrents=[];
    sps.y3LevelDevice=[];


    sps.modelnames{sps.basicnonlinearmodels+1}=[];


    sps.modelnames{sps.basicnonlinearmodels+2}=[];


    sps.nbmodels(sps.basicnonlinearmodels+4)=0;


    sps.Flux.Tags=cell(0);
    sps.Flux.Mux=[];
    sps.Y.Tags=cell(0);
    sps.Y.Demux=[];
    sps.Y.TotalNumberOfSignals=0;
    sps.Y.Q1Q4=[];
    sps.Y.D1D4=[];
    sps.Y.Others=[];
    sps.U.Tags=cell(0);
    sps.U.Mux=[];
    sps.Status.Tags=cell(0);
    sps.Status.Demux=[];
    sps.Gates.Tags=cell(0);
    sps.Gates.Mux=[];
    sps.VF.Tags=cell(0);
    sps.VF.Mux=[];
    sps.ITAIL.Tags=cell(0);
    sps.ITAIL.Mux=[];
    sps.SwitchType=[];
    sps.VoltageMeasurement.Tags=cell(0);
    sps.VoltageMeasurement.Demux=[];
    sps.CurrentMeasurement.Tags=cell(0);
    sps.CurrentMeasurement.Demux=[];
    sps.SwitchDevices.Tags=cell(0);
    sps.SwitchDevices.Demux=[];
    sps.SwitchDevices.qty=0;
    sps.SwitchDevices.total=0;
    sps.NonlinearDevices.Tags=cell(0);
    sps.NonlinearDevices.Demux=[];
    sps.NonlinearDevices.Switches=0;
    sps.SwitchGateInitialValue=[];
    sps.InputsNonZero=[];
    sps.DSS=[];



    RefBlock='';
    if~isempty(BLOCKLIST)
        if~isempty(BLOCKLIST.elements)
            RefBlock=getfullname(BLOCKLIST.elements(1));
        end
    end

    sps.PowerguiInfo=getPowerguiInfo(system,RefBlock);

    sps.DSS.model.reordersrc.indices=[];
    sps.DSS.model.reordersrc.width=[];
    sps.DSS.model.reorderout.indices=[];
    sps.DSS.model.reorderout.width=[];
    sps.DSS.model.inTags=[];
    sps.DSS.model.inMux=[];
    sps.DSS.model.outTags=[];
    sps.DSS.model.outDemux=[];
    sps.DSS.block=[];
    sps.DSS.custom.parent=[];
    sps.DSS.custom.type=[];
    sps.DSS.custom.number=[];
    sps.DSS.custom.states=[];
    sps.DSS.custom.solver=[];



    if LoadFlowAnalysis
        sps.LoadFlow.freq=sps.PowerguiInfo.LoadFlowFrequency;
        sps.LoadFlow.Pbase=sps.PowerguiInfo.Pbase;
        sps.LoadFlow.ErrMax=sps.PowerguiInfo.ErrMax;
        sps.LoadFlow.Iterations=sps.PowerguiInfo.Iterations;
    end

    if UnbalancedLoadFlowAnalysis
        sps.UnbalancedLoadFlow.freq=sps.PowerguiInfo.LoadFlowFrequency;
        sps.UnbalancedLoadFlow.Pbase=sps.PowerguiInfo.Pbase;
        sps.UnbalancedLoadFlow.ErrMax=sps.PowerguiInfo.ErrMax;
        sps.UnbalancedLoadFlow.Iterations=sps.PowerguiInfo.Iterations;
    end



    if sps.PowerguiInfo.Discrete
        if~isnumeric(sps.PowerguiInfo.Ts)
            if~UpdateMultimeter

                Erreur.message=['Undefined Sample Time in ',sps.PowerguiInfo.BlockName];
                Erreur.identifier='SpecializedPowerSystems:PowerguiBlock:SampleTimeError';
                psberror(Erreur);
            end
        end
        if sps.PowerguiInfo.Ts<0
            Erreur.message='Sample time defined in the powergui block cannot be set to a negative value.';
            Erreur.identifier='SpecializedPowerSystems:PowerguiBlock:SampleTimeError';
            psberror(Erreur);
        end
        if sps.PowerguiInfo.Ts==0
            Erreur.message='Sample time defined in the powergui block must be greater than zero and have a finite value.';
            Erreur.identifier='SpecializedPowerSystems:PowerguiBlock:SampleTimeError';
            psberror(Erreur);
        end
        if sps.PowerguiInfo.Ts==Inf||isnan(sps.PowerguiInfo.Ts)
            Erreur.message='Sample time defined in the powergui block must have a finite value';
            Erreur.identifier='SpecializedPowerSystems:PowerguiBlock:SampleTimeError';
            psberror(Erreur);
        end
    end



    if sps.PowerguiInfo.Discrete||sps.PowerguiInfo.Continuous
        Phasor_blocks={...
        '3-Phase Programmable Voltage Source (Phasor Type)';...
        'Sequence Analyzer (Phasor Type)';...
        'Active & Reactive Power (Phasor Type)';...
        '3-Phase Active & Reactive Power (Phasor Type)';...
        'Static Var Compensator (Phasor Type)'};
        for k=1:length(Phasor_blocks)
            F_block=find_system(system,'LookUnderMasks','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FollowLinks','on','MaskType',Phasor_blocks{k});
            if~isempty(F_block)
                message=['The ''',strrep(F_block{1},newline,' '),''' Phasor block is not allowed with the Continuous or Discrete simulation method.'];
                Erreur.message=message;
                Erreur.identifier='SpecializedPowerSystems:PowerguiBlock:InvalidPhasorBlocks';
                psberror(Erreur);
            end
        end
    end

    if isempty(BLOCKLIST)
        return
    end


    if~isempty(BLOCKLIST.nodes)
        NewNode=max([BLOCKLIST.nodes{:}])+1;
    else
        NewNode=NaN;
    end




    [sps,Multimeter]=SeriesRLCBranchBlock(BLOCKLIST,sps,Multimeter);
    [sps,Multimeter]=ThreePhaseSeriesRLCBranchBlock(BLOCKLIST,sps,Multimeter);
    [sps,Multimeter]=ParallelRLCBranchBlock(BLOCKLIST,sps,Multimeter);
    [sps,Multimeter]=ThreePhaseParallelRLCBranchBlock(BLOCKLIST,sps,Multimeter);
    [sps,Multimeter]=SeriesRLCLoadBlock(BLOCKLIST,sps,Multimeter);
    [sps,Multimeter,NewNode]=ThreePhaseSeriesRLCLoadBlock(BLOCKLIST,sps,Multimeter,NewNode);
    [sps,Multimeter]=ParallelRLCLoadBlock(BLOCKLIST,sps,Multimeter);
    [sps,Multimeter,NewNode]=ThreePhaseParallelRLCLoadBlock(BLOCKLIST,sps,Multimeter,NewNode);
    [sps,Multimeter,NewNode]=PISectionLineBlock(BLOCKLIST,sps,Multimeter,NewNode);



    [sps,YuNonlinear,Multimeter,YiExcTransfos,NewNode]=LinearTransformerBlock(BLOCKLIST,sps,YuNonlinear,Multimeter,YiExcTransfos,NewNode);


    Multimeter=GroundingTransformerblock(BLOCKLIST,sps,Multimeter);

    [sps,Multimeter,NewNode]=MutualInductanceBlock(BLOCKLIST,sps,Multimeter,NewNode);
    [sps,Multimeter,NewNode]=ThreePhaseMutualInductanceBlock(BLOCKLIST,sps,Multimeter,NewNode);



    [sps,Multimeter,NewNode]=InductanceMatrixTransformerblock(BLOCKLIST,sps,2,Multimeter,NewNode);



    [sps,Multimeter,NewNode]=InductanceMatrixTransformerblock(BLOCKLIST,sps,3,Multimeter,NewNode);
    [sps,Multimeter,NewNode]=ThreePhasePiSectionLineBlock(BLOCKLIST,sps,Multimeter,NewNode);
    [sps,Multimeter,NewNode]=ThreePhaseHarmonicFilterBlock(BLOCKLIST,sps,Multimeter,NewNode);



    ThreePhaseTransformer12Terminals(BLOCKLIST);





    [BlockCount,sps,YuSwitches,~,NewNode]=SwitchesBlock(1,'Ideal Switch',1,BLOCKLIST,sps,YuSwitches,VfVoltageSource,NewNode,(LoadFlowAnalysis||UnbalancedLoadFlowAnalysis));
    sps.IdealSwitch=BlockCount;


    Bridges=UniversalBridgeBlock('Ideal Switch',BLOCKLIST);
    for i=1:length(Bridges)
        [BlockCount,sps,Multimeter,YuSwitches,VfVoltageSource,NewNode]=TwoLevelBridge(BLOCKLIST,Bridges(i),'Ideal Switch',sps,Multimeter,YuSwitches,VfVoltageSource,NewNode);
        sps.IdealSwitch=sps.IdealSwitch+BlockCount;
    end


    Bridges=ThreeLevelBridgeBlock('Ideal Switch',BLOCKLIST);
    for i=1:length(Bridges)
        [BlockCount,sps,Multimeter,YuSwitches,VfVoltageSource,NewNode]=ThreeLevelSwitchBridge(BLOCKLIST,Bridges(i),sps,Multimeter,YuSwitches,VfVoltageSource,NewNode);
        sps.IdealSwitch=sps.IdealSwitch+BlockCount;
    end


    ThreePhaseBreakerBlock(BLOCKLIST,sps);


    ThreePhaseFaultBlock(BLOCKLIST,sps);


    [BlockCount,sps,YuSwitches,Multimeter,NewNode]=BreakerBlock(BLOCKLIST,sps,YuSwitches,Multimeter,NewNode,(LoadFlowAnalysis||UnbalancedLoadFlowAnalysis));
    sps.Breaker=BlockCount;


    [BlockCount,sps,YuSwitches,VfVoltageSource,NewNode]=SwitchesBlock(1,'Diode',3,BLOCKLIST,sps,YuSwitches,VfVoltageSource,NewNode,(LoadFlowAnalysis||UnbalancedLoadFlowAnalysis));
    sps.Diode=BlockCount;


    Bridges=UniversalBridgeBlock('Diode',BLOCKLIST);
    for i=1:length(Bridges)
        Lon=getSPSmaskvalues(Bridges(i),{'Lon'});
        errorScalar(Lon,'Lon',getfullname(Bridges(i)));
        if Lon>0&&sps.PowerguiInfo.Discrete
            sps.ForceLonToZero.status=1;
            sps.ForceLonToZero.blocks{end+1}=strrep(getfullname(Bridges(i)),newline,' ');
            Lon=0;
        end
        if Lon==0
            [BlockCount,sps,Multimeter,YuSwitches,VfVoltageSource,NewNode]=TwoLevelBridge(BLOCKLIST,Bridges(i),'Diode-Logic',sps,Multimeter,YuSwitches,VfVoltageSource,NewNode);
            sps.Diode=sps.Diode+BlockCount;
        end
    end


    [BlockCount,sps,YuSwitches,VfVoltageSource,NewNode]=SwitchesBlock(1,'Thyristor',4,BLOCKLIST,sps,YuSwitches,VfVoltageSource,NewNode,(LoadFlowAnalysis||UnbalancedLoadFlowAnalysis));
    sps.Thyristors=BlockCount;


    Bridges=UniversalBridgeBlock('Thyristor',BLOCKLIST);
    for i=1:length(Bridges)
        Lon=getSPSmaskvalues(Bridges(i),{'Lon'});
        errorScalar(Lon,'Lon',getfullname(Bridges(i)));
        if Lon>0&&sps.PowerguiInfo.Discrete
            sps.ForceLonToZero.status=1;
            sps.ForceLonToZero.blocks{end+1}=strrep(getfullname(Bridges(i)),newline,' ');
            Lon=0;
        end
        if Lon==0
            [BlockCount,sps,Multimeter,YuSwitches,VfVoltageSource,NewNode]=TwoLevelBridge(BLOCKLIST,Bridges(i),'Thyristor-Logic',sps,Multimeter,YuSwitches,VfVoltageSource,NewNode);
            sps.Thyristors=sps.Thyristors+BlockCount;
        end
    end


    [BlockCount,sps,YuSwitches,VfVoltageSource,NewNode]=SwitchesBlock(1,'Detailed Thyristor',4,BLOCKLIST,sps,YuSwitches,VfVoltageSource,NewNode,(LoadFlowAnalysis||UnbalancedLoadFlowAnalysis));
    sps.Thyristors=sps.Thyristors+BlockCount;


    sps.SwitchDevices.total=sps.SwitchDevices.qty;


    [BlockCount,sps,YuSwitches,VfVoltageSource,NewNode]=SwitchesBlock(1,'Gto',5,BLOCKLIST,sps,YuSwitches,VfVoltageSource,NewNode,(LoadFlowAnalysis||UnbalancedLoadFlowAnalysis));
    sps.GTO=BlockCount;


    [BlockCount,sps,YuSwitches,VfVoltageSource,NewNode]=SwitchesBlock(1,'IGBT',6,BLOCKLIST,sps,YuSwitches,VfVoltageSource,NewNode,(LoadFlowAnalysis||UnbalancedLoadFlowAnalysis));
    sps.IGBT=BlockCount;


    [BlockCount,sps,YuSwitches,VfVoltageSource,NewNode]=SwitchesBlock(1,'IGBT/Diode',7,BLOCKLIST,sps,YuSwitches,VfVoltageSource,NewNode,(LoadFlowAnalysis||UnbalancedLoadFlowAnalysis));
    sps.IGBTdiode=BlockCount;



    [BlockCount,sps,YuSwitches,VfVoltageSource,NewNode]=FullBridgeMMCBlock(BLOCKLIST,sps,YuSwitches,VfVoltageSource,NewNode,'FullMMC');
    sps.IGBTdiode=sps.IGBTdiode+BlockCount;



    [BlockCount,sps,YuSwitches,VfVoltageSource,NewNode]=FullBridgeMMCBlock(BLOCKLIST,sps,YuSwitches,VfVoltageSource,NewNode,'HalfMMC');
    sps.IGBTdiode=sps.IGBTdiode+BlockCount;



    [BlockCount,sps,YuSwitches,VfVoltageSource,YuNonlinear,NewNode]=FullBridgeMMCBlockExternalDClinks(BLOCKLIST,sps,YuSwitches,VfVoltageSource,YuNonlinear,NewNode);
    sps.IGBTdiode=sps.IGBTdiode+BlockCount;



    sps.MOSFET=0;


    MOSFETBlock(BLOCKLIST);


    Bridges=UniversalBridgeBlock('GTO',BLOCKLIST);
    for i=1:length(Bridges)
        [BlockCount,sps,Multimeter,YuSwitches,VfVoltageSource,NewNode]=TwoLevelBridge(BLOCKLIST,Bridges(i),'GTO',sps,Multimeter,YuSwitches,VfVoltageSource,NewNode);
        sps.GTO=sps.GTO+BlockCount;
    end


    Bridges=UniversalBridgeBlock('IGBT',BLOCKLIST);
    for i=1:length(Bridges)
        [BlockCount,sps,Multimeter,YuSwitches,VfVoltageSource,NewNode]=TwoLevelBridge(BLOCKLIST,Bridges(i),'IGBT',sps,Multimeter,YuSwitches,VfVoltageSource,NewNode);
        sps.IGBT=sps.IGBT+BlockCount;
    end


    Bridges=UniversalBridgeBlock('MOSFET',BLOCKLIST);
    for i=1:length(Bridges)
        [BlockCount,sps,Multimeter,YuSwitches,VfVoltageSource,NewNode]=TwoLevelBridge(BLOCKLIST,Bridges(i),'MOSFET',sps,Multimeter,YuSwitches,VfVoltageSource,NewNode);
        sps.MOSFET=sps.MOSFET+BlockCount;
    end


    sps.ThreeLevelDevices=0;
    Bridges=ThreeLevelBridgeBlock('GTO IGBT MOSFET',BLOCKLIST);
    for i=1:length(Bridges)
        [BlockCount,sps,Multimeter,YuSwitches,VfVoltageSource,NewNode]=ThreeLevelBridge(BLOCKLIST,Bridges(i),sps,Multimeter,YuSwitches,VfVoltageSource,NewNode);
        sps.ThreeLevelDevices=sps.ThreeLevelDevices+BlockCount;
    end


    sps.Rswitch=sps.Rswitch';

    sps.NumberOfSfunctionSwitches=(sps.IdealSwitch+sps.Breaker+sps.Diode+sps.Thyristors+sps.GTO+sps.IGBT+sps.IGBTdiode+sps.MOSFET+sps.ThreeLevelDevices);

    if sps.PowerguiInfo.SPID

        sps.NumberOfSfunctionSwitches=0;
        sps.switches=zeros(0,5);
    end





    [BlockCount,sps,YuNonlinear]=SwitchesBlock(2,'Diode',3,BLOCKLIST,sps,YuNonlinear,VfVoltageSource,NewNode,(LoadFlowAnalysis||UnbalancedLoadFlowAnalysis));
    sps.Diode=sps.Diode+BlockCount;


    Bridges=UniversalBridgeBlock('Diode',BLOCKLIST);
    for i=1:length(Bridges)
        Lon=getSPSmaskvalues(Bridges(i),{'Lon'});
        errorScalar(Lon,'Lon',getfullname(Bridges(i)));
        if Lon>0&&~sps.PowerguiInfo.Discrete
            [BlockCount,sps,Multimeter,YuNonlinear,VfVoltageSource,NewNode]=TwoLevelBridge(BLOCKLIST,Bridges(i),'Diode-RL',sps,Multimeter,YuNonlinear,VfVoltageSource,NewNode);
            sps.Diode=sps.Diode+BlockCount;
        end
    end


    [BlockCount,sps,YuNonlinear]=SwitchesBlock(2,'Thyristor',4,BLOCKLIST,sps,YuNonlinear,VfVoltageSource,NewNode,(LoadFlowAnalysis||UnbalancedLoadFlowAnalysis));
    sps.Thyristors=sps.Thyristors+BlockCount;


    Bridges=UniversalBridgeBlock('Thyristor',BLOCKLIST);
    for i=1:length(Bridges)
        Lon=getSPSmaskvalues(Bridges(i),{'Lon'});
        errorScalar(Lon,'Lon',getfullname(Bridges(i)));
        if Lon>0&&~sps.PowerguiInfo.Discrete
            [BlockCount,sps,Multimeter,YuNonlinear,VfVoltageSource,NewNode]=TwoLevelBridge(BLOCKLIST,Bridges(i),'Thyristor-RL',sps,Multimeter,YuNonlinear,VfVoltageSource,NewNode);
            sps.Thyristors=sps.Thyristors+BlockCount;
        end
    end


    [BlockCount,sps,YuNonlinear]=SwitchesBlock(2,'Detailed Thyristor',4,BLOCKLIST,sps,YuNonlinear,VfVoltageSource,NewNode,(LoadFlowAnalysis||UnbalancedLoadFlowAnalysis));
    sps.Thyristors=sps.Thyristors+BlockCount;


    [BlockCount,sps,YuNonlinear]=SwitchesBlock(2,'Gto',5,BLOCKLIST,sps,YuNonlinear,VfVoltageSource,NewNode,(LoadFlowAnalysis||UnbalancedLoadFlowAnalysis));
    sps.GTO=sps.GTO+BlockCount;


    [BlockCount,sps,YuNonlinear]=SwitchesBlock(2,'IGBT',6,BLOCKLIST,sps,YuNonlinear,VfVoltageSource,NewNode,(LoadFlowAnalysis||UnbalancedLoadFlowAnalysis));
    sps.IGBT=sps.IGBT+BlockCount;


    ns=size(sps.switches,1);
    sps.switches(:,6)=(1:ns)';
    sps.switches(:,7)=(1:ns)';

    if isequal(options,'getSwitchStatus')
        return
    end



    [sps,YuNonlinear]=SimplifiedSynchronousMachineBlock(BLOCKLIST,sps,YuNonlinear);
    [sps,YuNonlinear]=SynchronousMachineBlock(BLOCKLIST,sps,YuNonlinear);
    [sps,YuNonlinear]=AsynchronousMachineBlock(BLOCKLIST,sps,YuNonlinear);
    [sps,YuNonlinear]=SinglePhaseAsynchronousMachineBlock(BLOCKLIST,sps,YuNonlinear);
    [sps,YuNonlinear]=PMSynchronousMachineBlock(BLOCKLIST,sps,YuNonlinear);
    [sps,YuNonlinear]=SwitchedReluctanceMotorBlock(BLOCKLIST,sps,YuNonlinear);
    [sps,YuNonlinear]=StepperMotorBlock(BLOCKLIST,sps,YuNonlinear);

    [sps,YuNonlinear,Multimeter]=SurgeArresterBlock(BLOCKLIST,sps,YuNonlinear,Multimeter);

    [sps,YuNonlinear,Multimeter,NewNode]=SaturableTransformerBlock(BLOCKLIST,sps,YuNonlinear,Multimeter,NewNode);
    [sps,YuNonlinear,Multimeter,YiExcTransfos,NewNode]=NWindingsTransformerBlock(BLOCKLIST,sps,YuNonlinear,Multimeter,YiExcTransfos,NewNode);

    [sps,YuNonlinear,Multimeter,YiExcTransfos,NewNode]=ThreePhaseTransformerBlock('Three-Phase Transformer (Two Windings)',BLOCKLIST,sps,YuNonlinear,Multimeter,YiExcTransfos,NewNode);
    [sps,YuNonlinear,Multimeter,YiExcTransfos,NewNode]=ThreePhaseTransformerBlock('Three-Phase Transformer (Three Windings)',BLOCKLIST,sps,YuNonlinear,Multimeter,YiExcTransfos,NewNode);
    [sps,YuNonlinear,Multimeter,YiExcTransfos,NewNode]=ThreePhaseTransformerBlock('Zigzag Phase-Shifting Transformer',BLOCKLIST,sps,YuNonlinear,Multimeter,YiExcTransfos,NewNode);

    [sps,YuNonlinear,Multimeter]=DistributedParameterLineBlock(BLOCKLIST,sps,YuNonlinear,Multimeter);
    [sps,YuNonlinear,Multimeter]=WideBandLineBlock(BLOCKLIST,sps,YuNonlinear,Multimeter);

    DecouplingLineBlock(BLOCKLIST,sps);

    [sps,YuNonlinear]=ThreePhaseDynamicLoadBlock(BLOCKLIST,sps,YuNonlinear);


    sps=DCMachineBlock(BLOCKLIST,sps);

    NumberOfNonlinearElements=length(sps.sourcenames(:));
    if NumberOfNonlinearElements
        sps.NonlinearBlock.name=getfullname(sps.sourcenames(:));
        sps.NonlinearBlock.inputname={sps.srcstr{:}};
        sps.NonlinearBlock.Uindice=1:NumberOfNonlinearElements;
        sps.NonlinearBlock.Yindice=1:NumberOfNonlinearElements;
    end

    if~isempty(sps.LoadFlowParameters)
        sps.machines(1).status=1;
        sps.LoadFlowParameters(1).LoadFlowFrequency=sps.PowerguiInfo.LoadFlowFrequency;
        sps.LoadFlowParameters(1).InitialConditions='Auto';
        sps.LoadFlowParameters(1).DisplayWarnings='on';
    end





    [sps,YuNonlinear,Multimeter,YiSwitchingFunction,NewNode]=SwitchingFunctionBridgeBlock(BLOCKLIST,sps,YuNonlinear,Multimeter,NewNode);

    if~isempty(YiSwitchingFunction.expression)

        sps.NonlinearBlock.Yindice=1:(NumberOfNonlinearElements+YiSwitchingFunction.nb);
    end



    [sps,YuImpedance]=ImpedanceMeasurementBlock(BLOCKLIST,sps);



    FirstSourceBlock=size(sps.source,1)+1;
    [sps,Multimeter]=DCVoltageSourceBlock(BLOCKLIST,sps,Multimeter);
    [sps,Multimeter]=ACVoltageSourceBlock(BLOCKLIST,sps,Multimeter);
    [sps,Multimeter]=ACCurrentSourceBlock(BLOCKLIST,sps,Multimeter);
    [sps,Multimeter]=ControlledVoltageSourceBlock(BLOCKLIST,sps,Multimeter);
    [sps,Multimeter]=ControlledCurrentSourceBlock(BLOCKLIST,sps,Multimeter);
    [sps]=NonlinearElementOutput(BLOCKLIST,sps);

    [sps,YuNonlinear,YiNonlinearResistor,NewNode]=NonlinearResistorBlock(BLOCKLIST,sps,YuNonlinear,NewNode);
    [sps,YuNonlinear,Multimeter,NewNode]=NonlinearInductorBlock(BLOCKLIST,sps,YuNonlinear,Multimeter,NewNode);

    [sps,NewNode]=ThreePhaseSourceBlock(BLOCKLIST,sps,NewNode);%#ok
    [sps]=ThreePhaseProgSourceBlock(BLOCKLIST,sps);

    LastSourceBlock=size(sps.source,1);
    if LastSourceBlock>=FirstSourceBlock
        sps.SourceBlock.name=getfullname(sps.sourcenames(FirstSourceBlock:LastSourceBlock));
        sps.SourceBlock.indice=FirstSourceBlock:LastSourceBlock;
    end



    sps.srcstr=[sps.srcstr,VfVoltageSource.srcstr];
    sps.sourcenames=[sps.sourcenames;VfVoltageSource.sourcenames];

    for i=1:size(VfVoltageSource.source,1)
        sps.source(end+1,1:7)=VfVoltageSource.source(i,:);
        sps.NonlinearBlock.Uindice(end+1)=size(sps.source,1);
    end


    if~LoadFlowAnalysis&&~UnbalancedLoadFlowAnalysis
        if sps.PowerguiInfo.Phasor
            if~any(sps.source(:,6)==sps.PowerguiInfo.PhasorFrequency)
                message=['There is no voltage source, current source, or machine block ',...
                'with a frequency matching the Phasor simulation frequency.'];
                Erreur.message=message;
                Erreur.identifier='SpecializedPowerSystems:PowerguiBlock:PhasorSimulationFrequency';
                psberror(Erreur);
            end
        end
    end


    if~LoadFlowAnalysis&&~UnbalancedLoadFlowAnalysis


        ListOfAvailableFrequencies=unique(sps.source(:,6));
        if~isempty(ListOfAvailableFrequencies)



            if~any(sps.PowerguiInfo.LoadFlowFrequency==ListOfAvailableFrequencies)


                if find(ListOfAvailableFrequencies==60)

                    sps.PowerguiInfo.LoadFlowFrequency=60;
                elseif find(ListOfAvailableFrequencies==50)

                    sps.PowerguiInfo.LoadFlowFrequency=50;
                else

                    sps.PowerguiInfo.LoadFlowFrequency=min(ListOfAvailableFrequencies);
                end


                set_param(sps.PowerguiInfo.BlockName,'frequencyindice',mat2str(sps.PowerguiInfo.LoadFlowFrequency));
            end
        else


            sps.PowerguiInfo.LoadFlowFrequency=60;
        end
    end



    if UpdateMultimeter
        sps.mesurexmeter=[Multimeter.V';Multimeter.I';Multimeter.F';Multimeter.L'];
        sps.nbmodels(sps.basicnonlinearmodels+2)=length([YiExcTransfos.Yi{:,1}])+length(Multimeter.V)+length(Multimeter.I);
        return
    end





    [sps,YuMeasurement,MesuresTensions]=VoltageMeasurementBlock(BLOCKLIST,sps,YuMeasurement);

    [sps,YuMeasurement,MesuresTensions]=NonlinearElementInput(0,BLOCKLIST,sps,YuMeasurement,MesuresTensions,[],[]);


    [sps,YuMeasurement,Ycurr,MesuresTensions,MesuresCourants,YiMeasurement_1]=ThreePhaseVIMeasurementBlock(BLOCKLIST,sps,YuMeasurement,MesuresTensions);




    [sps,Ycurr,MesuresCourants,YiMeasurement_2]=CurrentMeasurementBlock(BLOCKLIST,sps,Ycurr,MesuresCourants);

    [sps,YuMeasurement,MesuresTensions,Ycurr,MesuresCourants]=NonlinearElementInput(1,BLOCKLIST,sps,YuMeasurement,MesuresTensions,Ycurr,MesuresCourants);

    sps=NonlinearElementMake(sps);

    for i=1:length(YiNonlinearResistor.DSSelement)
        Ycurr(end+1,1:2)=YiNonlinearResistor.Ycurr(i,1:2);
        sps.outstr{end+1}=YiNonlinearResistor.outstr{i};
        NewOutputValue=length(sps.outstr);
        sps.DSS.block(YiNonlinearResistor.DSSelement(i)).outputs=NewOutputValue;
        sps.measurenames(end+1,1)=YiNonlinearResistor.MeasureNames(i);
        MesuresCourants{end+1,1}=YiNonlinearResistor.MeasureNames(i);
        sps.CurrentMeasurement.Tags{end+1}=YiNonlinearResistor.Tags{i};
        sps.CurrentMeasurement.Demux(end+1)=YiNonlinearResistor.Demux(i);
    end

    sps.measurenames=[MesuresTensions;MesuresCourants];




    YiMeasurement=[YiMeasurement_1;YiMeasurement_2];




    ns=size(sps.rlc,1);
    sps.rlc(:,7)=(1:ns)';


    Multimeterblock(BLOCKLIST);



    if YiSwitchingFunction.nb>0
        NbCurrentOutputs=length(sps.outstr);
        NbNewOutputs=length(YiSwitchingFunction.expression);
        sps.NonlinearBlock.Yindice(end+1:end+NbNewOutputs)=NbCurrentOutputs+1:NbCurrentOutputs+NbNewOutputs;
    end

    sps.outstr=[sps.outstr,YiSwitchingFunction.expression];
    Ycurr=[Ycurr;YiSwitchingFunction.nodes];


    if LoadFlowAnalysis
        [sps]=ThreePhaseLoadFlowBar(BLOCKLIST,sps,'get');
    end


    if UnbalancedLoadFlowAnalysis
        [sps]=LoadFlowBar(BLOCKLIST,sps,'get');
    end


    [sps,YuMeasurement,YuSwitches,YuNonlinear,YuImpedance,Multimeter,Ycurr]=LoadFlowBar(BLOCKLIST,sps,'short-circuit',YuMeasurement,YuSwitches,YuNonlinear,YuImpedance,Multimeter,LoadFlowAnalysis,UnbalancedLoadFlowAnalysis,Ycurr);











    rlc=sps.rlc;
    source=sps.source;
    ycurrX=Ycurr;

    s=size(sps.source,1);
    yc=size(Ycurr,1);


    if yc>0
        for i=1:s
            if source(i,3)==0

                noeudfusionne=source(i,2);
                noeudremplace=source(i,1);

                if noeudfusionne==0
                    noeudfusionne=source(i,1);
                    noeudremplace=source(i,2);
                end

                if~isempty(rlc)
                    k=(rlc(:,1:2)==noeudfusionne);
                    rlc(k)=noeudremplace;
                end
                if~isempty(source)
                    k=(source(:,1:2)==noeudfusionne);
                    source(k)=noeudremplace;
                end
                if~isempty(ycurrX)
                    k=(ycurrX(:,1:2)==noeudfusionne);
                    ycurrX(k)=noeudremplace;
                end
            end
        end
    end


    for i=1:yc


        rlctemp=rlc;
        if isempty(rlctemp)
            rlctemp=zeros(1,7);
        end
        sourcetemp=source;
        if isempty(sourcetemp)
            sourcetemp=zeros(1,5);
        end
        ycurrtemp=ycurrX;


        for jj=1:yc

            if jj~=i
                noeudfusionne=ycurrtemp(jj,2);
                noeudremplace=ycurrtemp(jj,1);

                if noeudfusionne==0
                    noeudfusionne=ycurrtemp(jj,1);
                    noeudremplace=ycurrtemp(jj,2);
                end

                k=(rlctemp(:,1:2)==noeudfusionne);
                rlctemp(k)=noeudremplace;
                k=(sourcetemp(:,1:2)==noeudfusionne);
                sourcetemp(k)=noeudremplace;
                k=(ycurrtemp(:,1:2)==noeudfusionne);
                ycurrtemp(k)=noeudremplace;
            end
        end






        if ycurrtemp(i,1)~=0
            noeudsomme=ycurrtemp(i,1);

            TmpPolarite=1;
        else
            noeudsomme=ycurrtemp(i,2);

            TmpPolarite=-1;
        end




        krlc=find(rlctemp(:,2)==noeudsomme);
        typequiprecede=[0;rlctemp(:,3)];

        YiMeasurement{i,1}=[];

        for jj=1:length(krlc)
            n=krlc(jj);

            type=rlctemp(n,3);
            switch type
            case{0,1}

                if typequiprecede(n)~=2&&typequiprecede(n)~=3&&typequiprecede(n)~=4


                    YiMeasurement{i,1}=[YiMeasurement{i,1},n];

                end
            case{2,3,4}


                YiMeasurement{i,1}=[YiMeasurement{i,1},n];

            end
        end


        krlc=find(rlctemp(:,1)==noeudsomme);
        for jj=1:length(krlc)
            n=krlc(jj);

            type=rlctemp(n,3);
            switch type
            case{0,1}

                if typequiprecede(n)~=2&&typequiprecede(n)~=3&&typequiprecede(n)~=4


                    YiMeasurement{i,1}=[YiMeasurement{i,1},-n];

                end
            case{2,3,4}


                YiMeasurement{i,1}=[YiMeasurement{i,1},-n];

            end
        end




        YiMeasurement{i,2}=[];

        ksrc=find(sourcetemp(:,2)==noeudsomme);
        for jj=1:length(ksrc)
            n=ksrc(jj);
            type=sourcetemp(n,3);
            SaturationXfo=sourcetemp(n,7)==18;
            if type==1&&~SaturationXfo
                YiMeasurement{i,2}=[YiMeasurement{i,2},n];
            end
        end


        ksrc=find(sourcetemp(:,1)==noeudsomme);
        for jj=1:length(ksrc)
            n=ksrc(jj);
            type=sourcetemp(n,3);
            SaturationXfo=sourcetemp(n,7)==18;
            if type==1&&~SaturationXfo
                YiMeasurement{i,2}=[YiMeasurement{i,2},-n];
            end
        end



        YiMeasurement{i,1}=[YiMeasurement{i,1}]*TmpPolarite;
        YiMeasurement{i,2}=[YiMeasurement{i,2}]*TmpPolarite;

    end



    for i=1:yc
        noeudfusionne=Ycurr(i,2);
        noeudremplace=Ycurr(i,1);

        if noeudfusionne==0
            noeudfusionne=Ycurr(i,1);
            noeudremplace=Ycurr(i,2);
        end



        if size(sps.ObsoleteNodes,2)==2
            x=find(sps.ObsoleteNodes(:,2)==noeudfusionne);
        else
            x=[];
        end

        if~isempty(x)
            sps.ObsoleteNodes(x,2)=noeudremplace;
        end


        sps.ObsoleteNodes(end+1,1:2)=[noeudfusionne,noeudremplace];


        k=(Ycurr==noeudfusionne);
        Ycurr(k)=noeudremplace;
        if~isempty(sps.rlc)
            k=(sps.rlc(:,1:2)==noeudfusionne);
            sps.rlc(k)=noeudremplace;
        end
        if~isempty(sps.source)
            k=(sps.source(:,1:2)==noeudfusionne);
            sps.source(k)=noeudremplace;
        end
        if~isempty(sps.switches)
            k=(sps.switches(:,1:2)==noeudfusionne);
            sps.switches(k)=noeudremplace;
        end
        if~isempty(YuMeasurement)
            k=(YuMeasurement(:,1:2)==noeudfusionne);
            YuMeasurement(k)=noeudremplace;
        end
        if~isempty(YuSwitches)
            k=(YuSwitches(:,1:2)==noeudfusionne);
            YuSwitches(k)=noeudremplace;
        end
        if~isempty(YuNonlinear)
            k=(YuNonlinear(:,1:2)==noeudfusionne);
            YuNonlinear(k)=noeudremplace;
        end
        if~isempty(YuImpedance)
            k=(YuImpedance(:,1:2)==noeudfusionne);
            YuImpedance(k)=noeudremplace;
        end
        if~isempty(Multimeter.Yu)
            k=(Multimeter.Yu(:,1:2)==noeudfusionne);
            Multimeter.Yu(k)=noeudremplace;
        end


        if LoadFlowAnalysis
            for j=1:length(sps.LoadFlow.bus)
                if sps.LoadFlow.bus(j).Busnode==noeudfusionne
                    sps.LoadFlow.bus(j).Busnode=noeudremplace;
                end
            end
            LFblocks={'asm','sm','pqload','rlcload','vsrc','xfo'};
            for x=1:length(LFblocks)
                for j=1:length(sps.LoadFlow.(LFblocks{x}).nodes)
                    k=sps.LoadFlow.(LFblocks{x}).nodes{j}==noeudfusionne;
                    sps.LoadFlow.(LFblocks{x}).nodes{j}(k)=noeudremplace;
                end
            end

            for j=1:length(sps.LoadFlow.Lines.leftnodes)
                k=sps.LoadFlow.Lines.leftnodes{j}==noeudfusionne;
                sps.LoadFlow.Lines.leftnodes{j}(k)=noeudremplace;
                k=sps.LoadFlow.Lines.rightnodes{j}==noeudfusionne;
                sps.LoadFlow.Lines.rightnodes{j}(k)=noeudremplace;
            end
        end


        if UnbalancedLoadFlowAnalysis
            for j=1:length(sps.UnbalancedLoadFlow.bus)
                if sps.UnbalancedLoadFlow.bus(j).Busnode==noeudfusionne
                    sps.UnbalancedLoadFlow.bus(j).Busnode=noeudremplace;
                end
            end
            LFblocks={'asm','sm','pqload','rlcload','vsrc'};
            for x=1:length(LFblocks)
                for j=1:length(sps.UnbalancedLoadFlow.(LFblocks{x}).nodes)
                    k=sps.UnbalancedLoadFlow.(LFblocks{x}).nodes{j}==noeudfusionne;
                    sps.UnbalancedLoadFlow.(LFblocks{x}).nodes{j}(k)=noeudremplace;
                end
            end

            for j=1:length(sps.UnbalancedLoadFlow.Lines.leftnodes)
                k=sps.UnbalancedLoadFlow.Lines.leftnodes{j}==noeudfusionne;
                sps.UnbalancedLoadFlow.Lines.leftnodes{j}(k)=noeudremplace;
                k=sps.UnbalancedLoadFlow.Lines.rightnodes{j}==noeudfusionne;
                sps.UnbalancedLoadFlow.Lines.rightnodes{j}(k)=noeudremplace;
            end

            for j=1:length(sps.UnbalancedLoadFlow.Transfos.W1nodes)
                k=sps.UnbalancedLoadFlow.Transfos.W1nodes{j}==noeudfusionne;
                sps.UnbalancedLoadFlow.Transfos.W1nodes{j}(k)=noeudremplace;
                k=sps.UnbalancedLoadFlow.Transfos.W2nodes{j}==noeudfusionne;
                sps.UnbalancedLoadFlow.Transfos.W2nodes{j}(k)=noeudremplace;
                k=sps.UnbalancedLoadFlow.Transfos.W3nodes{j}==noeudfusionne;
                sps.UnbalancedLoadFlow.Transfos.W3nodes{j}(k)=noeudremplace;
            end
        end

    end

    sps.CurrentMeasurement.Nodes=Ycurr(:,1)';
    sps.CurrentMeasurement.BlockHandles=MesuresCourants;

    sps.rlc(sps.rlc(:,3)==444,3)=0;



    if LoadFlowAnalysis
        [sps]=ThreePhaseLoadFlowBar(BLOCKLIST,sps,'connect',sps.LoadFlow.Pbase,0);
    end



    if UnbalancedLoadFlowAnalysis
        [sps]=LoadFlowBar(BLOCKLIST,sps,'connect');
    end



    if LoadFlowAnalysis

        if~isempty(sps.LoadFlow.bus)
            sps.source=[sps.source;cell2mat({sps.LoadFlow.bus.sources}')];

            BusSrcHandles=reshape([[sps.LoadFlow.bus.handle];[sps.LoadFlow.bus.handle];[sps.LoadFlow.bus.handle]],3*length(sps.LoadFlow.bus),1);
            sps.sourcenames=[sps.sourcenames;BusSrcHandles];

            for i=1:length(sps.LoadFlow.bus)
                for j=1:3
                    sps.srcstr{end+1}=[sps.LoadFlow.bus(i).ID,'_phase:',num2str(j)];
                end
            end

        end
    end


    if UnbalancedLoadFlowAnalysis
        if~isempty(sps.UnbalancedLoadFlow.bus)
            sps.source=[sps.source;cell2mat({sps.UnbalancedLoadFlow.bus.sources}')];
            for i=1:length(sps.UnbalancedLoadFlow.bus)
                sps.srcstr{end+1}=sps.UnbalancedLoadFlow.bus(i).ID;
                sps.sourcenames(end+1,1)=sps.UnbalancedLoadFlow.bus(i).handle;
            end

        end
    end


    CheckForVoltageSourceLoop(sps)



    if sps.PowerguiInfo.SPID

    else

        for i=1:size(YuSwitches,1)
            sps.ytype(i,1)=0;
            sps.Outputs{i,1}=YuSwitches(i,:);
        end
        sps.Y.Tags=sps.SwitchDevices.Tags;
        sps.Y.Demux=sps.SwitchDevices.Demux;
    end


    for i=1:size(YuNonlinear,1)
        sps.ytype(end+1,1)=0;
        sps.Outputs{end+1,1}=YuNonlinear(i,:);


    end
    sps.Y.Tags={sps.Y.Tags{:},sps.NonlinearDevices.Tags{:}};%#ok
    sps.Y.Demux=[sps.Y.Demux,sps.NonlinearDevices.Demux];


    for i=1:size(YuImpedance,1)
        sps.ytype(end+1,1)=0;
        sps.Outputs{end+1,1}=YuImpedance(i,:);
    end

    sps.MeasurementBlock.name=getfullname([sps.measurenames{:}]);


    for i=1:size(YuMeasurement,1)
        sps.ytype(end+1,1)=0;
        sps.Outputs{end+1,1}=YuMeasurement(i,1:2);
        sps.VoltNodes(end+1,1:2)=YuMeasurement(i,1:2);
        sps.Y.Tags{end+1}=sps.VoltageMeasurement.Tags{i};
        sps.Y.Demux(end+1)=sps.VoltageMeasurement.Demux(i);
        sps.MeasurementBlock.indice(end+1)=size(sps.Outputs,1);
    end


    TotalCurrentMeasurements=size(YiMeasurement,1);
    VirtualCurrentMeasurement=size(YiSwitchingFunction.nodes,1);
    for i=1:TotalCurrentMeasurements
        sps.ytype(end+1,1)=1;
        sps.Outputs{end+1,1}=YiMeasurement{i,1};
        sps.Outputs{end,2}=YiMeasurement{i,2};


        if i<=TotalCurrentMeasurements-VirtualCurrentMeasurement

            sps.MeasurementBlock.indice(end+1)=size(sps.Outputs,1);
        end
    end


    sps.Y.Tags=[sps.Y.Tags(1:end),sps.CurrentMeasurement.Tags(1:end),YiSwitchingFunction.CurrentMeasurement.Tags(1:end)];
    sps.Y.Demux=[sps.Y.Demux,sps.CurrentMeasurement.Demux,YiSwitchingFunction.CurrentMeasurement.Demux];



    for i=1:size(YiExcTransfos.Yi,1)
        if length(YiExcTransfos.Yi{i,1})==2


            Iexc_IL0=YiExcTransfos.Yi{i,1};
            sps.ytype(end+1,1)=1;
            sps.Outputs{end+1,1}=Iexc_IL0(1);
            sps.Outputs{end,2}=[];
            sps.outstr{end+1}=YiExcTransfos.outstr{i};
            sps.ytype(end+1,1)=1;
            sps.Outputs{end+1,1}=Iexc_IL0(2);
            sps.Outputs{end,2}=[];
            sps.outstr{end+1}=['Delta0 ',YiExcTransfos.outstr{i}(7:end)];

            sps.Y.Tags{end+1}=YiExcTransfos.Tags{i};
            sps.Y.Demux(end+1)=2;
        else
            sps.ytype(end+1,1)=1;
            sps.Outputs{end+1,1}=YiExcTransfos.Yi{i,1};
            sps.Outputs{end,2}=[];
            sps.outstr{end+1}=YiExcTransfos.outstr{i};
            sps.Y.Tags{end+1}=YiExcTransfos.Tags{i};
            sps.Y.Demux(end+1)=1;
        end
    end



    sps.multimeters=find_system(system,'LookUnderMasks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on','MaskType','Multimeter');

    if~isempty(sps.multimeters)


        sps.mesurexmeter=[Multimeter.V';Multimeter.I';Multimeter.F';Multimeter.L'];


        NumberOfV=size(Multimeter.Yu,1);
        for i=1:NumberOfV
            sps.ytype(end+1,1)=0;
            sps.Outputs{end+1,1}=Multimeter.Yu(i,1:2);
            sps.outstr{end+1}=Multimeter.V{i};
        end


        NumberOfI=size(Multimeter.Yi,1);
        for i=1:NumberOfI
            sps.ytype(end+1,1)=1;
            if isnan(Multimeter.Yi{i,1})






                ii=Multimeter.Yi{i,2};
                if ii>0
                    sps.Outputs{end+1,1}=-YiMeasurement{ii,1};
                    sps.Outputs{end,2}=YiMeasurement{ii,2};
                else

                    sps.Outputs{end+1,1}=[YiMeasurement{abs(ii),1},YiMeasurement{abs(ii)-1,1}];
                    sps.Outputs{end,2}=[YiMeasurement{abs(ii),2},YiMeasurement{abs(ii)-1,2}];
                end
            else
                sps.Outputs{end+1,1}=Multimeter.Yi{i,1};
                sps.Outputs{end,2}=Multimeter.Yi{i,2};
            end
            sps.outstr{end+1}=Multimeter.I{i};
        end





        sps.nbmodels(sps.basicnonlinearmodels+2)=length([YiExcTransfos.Yi{:,1}])+length(Multimeter.V)+length(Multimeter.I);




        NumberOfMeasurements=length(Multimeter.V)+length(Multimeter.I)+sum(sps.Flux.Mux);

        if NumberOfMeasurements
            if~isempty(Multimeter.Q1Q4)

                sps.Y.Q1Q4=Multimeter.Q1Q4+NumberOfV;
                sps.Y.D1D4=Multimeter.D1D4+NumberOfV;
                Multimeter.D5D6=Multimeter.D5D6+NumberOfV;
                FirstIndiceInQ1Q4=sps.Y.Q1Q4(1);
                LastIndiceInD5D6=Multimeter.D5D6(end);


                sps.Y.Others=[1:NumberOfV,NumberOfV+1:FirstIndiceInQ1Q4-1,Multimeter.D5D6,LastIndiceInD5D6+1:NumberOfMeasurements];

                sps.Y.Tags{end+1}='ThreeLevelBridgeCurrents';
                sps.Y.TotalNumberOfSignals=NumberOfMeasurements;


            else
                sps.Y.Tags{end+1}='gotomultimeterPSB';
            end
            sps.Y.Demux(end+1)=NumberOfMeasurements;
        end
    end

    sps.blksrcnames=sps.blksrcnames';
    if length(sps.measurenames)==1
        sps.measurenames=getfullname(sps.measurenames{1});
    else
        sps.measurenames=getfullname(sps.measurenames);
    end
    if~iscell(sps.measurenames)
        sps.measurenames={sps.measurenames};
    end



    if LoadFlowAnalysis

        if~isempty(sps.LoadFlow.bus)
            V=cell2mat({sps.LoadFlow.bus.YuMeasurement}');

            for i=1:size(V,1)
                sps.ytype(end+1,1)=0;
                sps.Outputs{end+1,1}=V(i,1:2);
                sps.outstr{end+1}='LF bus';
            end
        end

    end



    if UnbalancedLoadFlowAnalysis

        if~isempty(sps.UnbalancedLoadFlow.bus)
            V=cell2mat({sps.UnbalancedLoadFlow.bus.YuMeasurement}');

            for i=1:size(V,1)
                sps.ytype(end+1,1)=0;
                sps.Outputs{end+1,1}=V(i,1:2);
                sps.outstr{end+1}='LF bus';
            end
        end

    end




    if LoadFlowAnalysis
        nBus=length(sps.LoadFlow.bus);
        if nBus>0


            sps.LoadFlow.VoltageRatio=repmat([sps.LoadFlow.bus.vbase]',1,nBus)./repmat([sps.LoadFlow.bus.vbase],nBus,1);


            for i=1:length(sps.LoadFlow.xfo.busNumber)
                bus_i=sps.LoadFlow.xfo.busNumber{i};
                handle_i=sps.LoadFlow.xfo.handle{i};
                Vnom_i=sps.LoadFlow.xfo.vnom{i};

                m=find(cell2mat(sps.LoadFlow.xfo.handle)==handle_i);
                n=m~=i;
                m=m(n);
                for j=1:length(m)
                    bus_n=sps.LoadFlow.xfo.busNumber{m(j)};
                    Vnom_n=sps.LoadFlow.xfo.vnom{m(j)};

                    a=Vnom_n/Vnom_i;
                    sps.LoadFlow.VoltageRatio(bus_i,bus_n)=sps.LoadFlow.VoltageRatio(bus_i,bus_n)*a;
                end
            end
        else
            sps.LoadFlow.VoltageRatio=[];
        end
    end

    sps.yout=sps.outstr';
    sps.outstr=char(sps.yout);
    sps.rlcnames=sps.rlcnames';
    sps.srcstr=sps.srcstr';




    if sps.PowerguiInfo.SPID

    else
        sps.U.Tags=[sps.ITAIL.Tags(1:end),sps.U.Tags(1:end)];
        sps.U.Mux=[sps.ITAIL.Mux,sps.U.Mux];
    end



    sps.U.Tags=[sps.U.Tags(1:end),sps.VF.Tags(1:end)];
    sps.U.Mux=[sps.U.Mux,sps.VF.Mux];




    disp('')

    if LoadFlowAnalysis||UnbalancedLoadFlowAnalysis

        sps.PowerguiInfo.SPID=0;
    end







    function Bridges=UniversalBridgeBlock(SwitchType,BLOCKLIST)

        idx=BLOCKLIST.filter_type('Universal Bridge');
        if~isempty(idx)
            Blocks=BLOCKLIST.elements(idx);
            BridgeTypes=get_param(Blocks,'device');
            switch SwitchType
            case 'Ideal Switch'
                i=strmatch('Ideal Switches',BridgeTypes);
                Bridges=Blocks(i);
            case 'Diode'
                i=strmatch('Diodes',BridgeTypes);
                Bridges=Blocks(i);
            case 'Thyristor'
                i=strmatch('Thyristors',BridgeTypes);
                Bridges=Blocks(i);
            case 'GTO'
                i=strmatch('GTO / Diodes',BridgeTypes);
                Bridges=Blocks(i);
            case 'IGBT'
                i=strmatch('IGBT / Diodes',BridgeTypes);
                Bridges=Blocks(i);
            case 'MOSFET'
                i=strmatch('MOSFET / Diodes',BridgeTypes);
                Bridges=Blocks(i);
            case 'Switching-function based VSC'
                i=strmatch('Switching-function based VSC',BridgeTypes);
                Bridges=Blocks(i);
            case 'Average-model based VSC'
                i=strmatch('Average-model based VSC',BridgeTypes);
                Bridges=Blocks(i);
            end
        else
            Bridges=[];
        end




        function Bridges=ThreeLevelBridgeBlock(SwitchType,BLOCKLIST)

            idx=BLOCKLIST.filter_type('Three-Level Bridge');
            if~isempty(idx)
                Blocks=BLOCKLIST.elements(idx);
                BridgeTypes=get_param(Blocks,'Device');
                switch SwitchType
                case 'Ideal Switch'
                    i=strmatch('Ideal Switches',BridgeTypes);
                    Bridges=Blocks(i);
                case 'GTO IGBT MOSFET'
                    i=strmatch('Ideal Switches',BridgeTypes);
                    Blocks(i)=[];
                    Bridges=Blocks;
                end
            else
                Bridges=[];
            end

            function CheckForVoltageSourceLoop(sps)


                if isempty(sps.source)
                    return
                end


                S=[sps.source(:,1:3),sps.sourcenames];


                S(S(:,3)==1,:)=[];

                x=1;
                while~isempty(x)

                    for i=1:size(S,1)
                        Lx=S(i,1);
                        Rx=S(i,2);
                        A=S(:,1:2);
                        Y=find(A==Lx);
                        Z=find(A==Rx);
                        if length(Y)==1||length(Z)==1


                            S(i,3)=1;
                        end
                    end

                    x=find(S(:,3)==1);
                    S(x,:)=[];
                end


                if~isempty(S)
                    VoltageSourceNames=getfullname(S(:,4));
                    if iscell(VoltageSourceNames)
                        message=['The following voltage source blocks are in parallel, or are connected in a loop(s) of voltage sources:',newline,newline];
                        for i=1:size(S,1)
                            message=[message,VoltageSourceNames{i},char(10)];%#ok
                        end
                    else
                        message=['The following voltage source block is short-circuited:',newline,newline];
                        message=[message,VoltageSourceNames,newline];
                    end
                    Erreur.message=message;
                    Erreur.identifier='SpecializedPowerSystems:getABCD:BlockConnectionIssue';
                    psberror(Erreur);
                end
