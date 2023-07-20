function SynchronousMachineVfd(block)







    if strcmp(get_param(block,'DisplayVfd'),'on')

        NominalParameters=getSPSmaskvalues(block,{'NominalParameters'});
        Stator=getSPSmaskvalues(block,{'Stator'});
        Field=getSPSmaskvalues(block,{'Field'});
        Mechanical=getSPSmaskvalues(block,{'Mechanical'});
        InitialConditions=getSPSmaskvalues(block,{'InitialConditions'});
        SetSaturation=isequal('on',get_param(block,'SetSaturation'));
        MechanicalLoad=get_param(block,'MechanicalLoad');
        PolePairs=getSPSmaskvalues(block,{'PolePairs'});
        RotorType=get_param(block,'RotorType');

        switch RotorType
        case 'Salient-pole'
            Dampers=[getSPSmaskvalues(block,{'Dampers1'}),0,inf];
        case 'Round'
            Dampers=getSPSmaskvalues(block,{'Dampers2'});
        end

        if SetSaturation
            Saturation=getSPSmaskvalues(block,{'Saturation'});
        else
            Saturation=[];
        end


        [NominalParameters,Stator,Field,Dampers,Mechanical,InitialConditions,Saturation,LC]=SynchronousMachineSItoPU(block,NominalParameters,Stator,Field,Dampers,Mechanical,InitialConditions,SetSaturation,Saturation,PolePairs);


        DisplayVfd=1;
        Units='SI fundamental parameters';
        excAxis=1;
        IterativeModel=0;
        LoadFlowFrequency=60;

        SynchronousMachineParam(MechanicalLoad,NominalParameters,Stator,Field,Dampers,Mechanical,PolePairs,InitialConditions,SetSaturation,Saturation,DisplayVfd,Units,excAxis,RotorType,IterativeModel,LoadFlowFrequency,LC)


        set_param(block,'DisplayVfd','off');

    end