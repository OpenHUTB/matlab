function schema




    pkg=findpackage('MECH');

    parentpkg=findpackage('Simulink');
    parentcls=findclass(parentpkg,'CustomCC');
    cls=schema.class(pkg,'SimMechanicsCC',parentcls);





    p=schema.prop(cls,'WarnOnRedundantConstraints','bool');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'WarnOnSingularInitialAssembly','bool');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'ShowCutJoints','bool');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'VisOnUpdateDiagram','bool');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'VisDuringSimulation','bool');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'EnableVisSimulationTime','bool');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'VisSampleTime','string');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'DisableBodyVisControl','bool');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'ShowCG','bool');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'ShowCS','bool');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'ShowOnlyPortCS','bool');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'HighlightModel','bool');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'FramesToBeSkipped','string');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'AnimationDelay','string');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'RecordAVI','bool');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'CompressAVI','bool');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'AviFileName','string');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'AutoFitVis','string');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'EnableSelection','bool');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'LastVizWinPosition','string');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'CamPosition','string');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'CamTarget','string');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'CamUpVector','string');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'CamHeight','string');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'CamViewAngle','string');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'VisBackgroundColor','string');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'DefaultBodyColor','string');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'MDLBodyVisualizationType','string');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=schema.prop(cls,'OVRRIDBodyVisualizationType','string');
    p.AccessFlags.Serialize='off';
    p.Visible='off';



    p=schema.prop(cls,'VisConfigFile','string');
    p.AccessFlags.Serialize='off';
    p.Visible='off';




    m=schema.method(cls,'getName');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(cls,'getMdlRefComplianceTable');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','Sl_MdlRefTarget_EnumType'};
    s.OutputTypes={'MATLAB array'};






    m=schema.method(cls,'update');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle',...
'string'...
    };
    s.OutputTypes={...
    };

    m=schema.method(cls,'configParamsCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string','mxArray'};
    s.OutputTypes={};




