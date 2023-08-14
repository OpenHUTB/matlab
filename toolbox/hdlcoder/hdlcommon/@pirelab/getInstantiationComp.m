function hBlackBoxComp=getInstantiationComp(varargin)





    p=inputParser;

    p.addParameter('Network','');
    p.addParameter('Name','');
    p.addParameter('SLHandle',-1);
    p.addParameter('InportNames',{});
    p.addParameter('OutportNames',{});
    p.addParameter('InportSignals',[]);
    p.addParameter('OutportSignals',[]);
    p.addParameter('AddClockPort','on');
    p.addParameter('AddClockEnablePort','on');
    p.addParameter('AddResetPort','on');
    p.addParameter('ClockInputPort','');
    p.addParameter('ClockEnableInputPort','');
    p.addParameter('ResetInputPort','');
    p.addParameter('InlineConfigurations','on');
    p.addParameter('GenericList','');
    p.addParameter('EntityName','');
    p.addParameter('VHDLArchitectureName',[]);

    p.parse(varargin{:});
    args=p.Results;

    hN=args.Network;
    compName=args.Name;
    hInSignals=args.InportSignals;
    hOutSignals=args.OutportSignals;
    inportNames=args.InportNames;
    outportNames=args.OutportNames;
    slHandle=args.SLHandle;


    hBlackBoxComp=hN.addComponent('black_box_comp','instantiation',0,0);

    for ii=1:length(inportNames)
        hBlackBoxComp.addInputPort(inportNames{ii});
        hInSignals(ii).addReceiver(hBlackBoxComp,ii-1);
    end

    for ii=1:length(outportNames)
        hBlackBoxComp.addOutputPort(outportNames{ii});
        hOutSignals(ii).addDriver(hBlackBoxComp,ii-1);
    end


    params={};


    hBlackBoxImpl=hdldefaults.SubsystemBlackBoxHDLInstantiation;

    implParams={...
    'AddClockPort',args.AddClockPort,...
    'AddClockEnablePort',args.AddClockEnablePort,...
    'AddResetPort',args.AddResetPort,...
    'InlineConfigurations',args.InlineConfigurations,...
    'GenericList',args.GenericList,...
    'EntityName',args.EntityName
    };



    if~isempty(args.ClockInputPort)
        implParams{end+1}='ClockInputPort';
        implParams{end+1}=args.ClockInputPort;
    end

    if~isempty(args.ClockEnableInputPort)
        implParams{end+1}='ClockEnableInputPort';
        implParams{end+1}=args.ClockEnableInputPort;
    end

    if~isempty(args.ResetInputPort)
        implParams{end+1}='ResetInputPort';
        implParams{end+1}=args.ResetInputPort;
    end

    if~isempty(args.VHDLArchitectureName)
        implParams{end+1}='VHDLArchitectureName';
        implParams{end+1}=args.VHDLArchitectureName;
    end

    hBlackBoxImpl.setImplParams(implParams);
    hBlackBoxImpl.setGenericsInfo(hBlackBoxComp);


    firstArgs={hBlackBoxImpl,hBlackBoxComp};
    userData.CodeGenFunction='emit';
    userData.CodeGenParams=[firstArgs,params];
    userData.generateSLBlockFunction='generateSLBlock';
    userData.generateSLBlockParams=firstArgs;
    hBlackBoxComp.ImplementationData=userData;


    hBlackBoxComp.SimulinkHandle=slHandle;
    hBlackBoxComp.Name=compName;
