function[varargout]=vehdyntire(varargin)




    block=varargin{1};
    maskMode=varargin{2};
    maskObj=Simulink.Mask.get(block);
    brakeType=get_param(block,'BrakeType');
    varargout{1}=[];
    simStatus=get_param(bdroot(block),'SimulationStatus');
    if strcmp(simStatus,'stopped')||strcmp(simStatus,'updating')
        simStopped=true;
    else
        simStopped=false;
    end











    switch maskMode

    case 0
        [~]=vehdynicon('vehdynlibtire',block,2);
        [~]=vehdynicon('vehdynlibtire',block,5);

        statFricVal=autoblksgetmaskparms(block,{'mu_static'},true);
        kinFricVal=autoblksgetmaskparms(block,{'mu_kinetic'},true);
        fricDims=max([size(statFricVal{:});size(kinFricVal{:});[1,1]]);
        massVal=autoblksgetmaskparms(block,{'MASS'},true);
        posVal=autoblksgetmaskparms(block,{'zo'},true);
        zdotVal=autoblksgetmaskparms(block,{'zdoto'},true);
        vertDims=max([size(massVal{:});size(posVal{:});size(zdotVal{:});[1,1]]);
        inertVal=autoblksgetmaskparms(block,{'IYY'},true);
        dampVal=autoblksgetmaskparms(block,{'br'},true);
        omegaoVal=autoblksgetmaskparms(block,{'omegao'},true);
        rotDims=max([size(inertVal{:});size(dampVal{:});size(omegaoVal{:});[1,1]]);
        if any(rotDims>1)
            set_param([block,'/Wheel Module/Clutch'],'LabelModeActiveChoice','1');
        else
            set_param([block,'/Wheel Module/Clutch'],'LabelModeActiveChoice','0');
        end


        GeneralBrakeParmChecks={...
        'mu_kinetic',fricDims,{'gt',0.;'lte',1.};...
        'mu_static',fricDims,{'gte','mu_kinetic';'lte',1.}};
        ParamList={...
        'IYY',rotDims,{'gt',0};...
        'UNLOADED_RADIUS',[1,1],{'gt',0};...
        'NOMPRES',[1,1],{'gte',0};...
        'FZMIN',[1,1],{'gte',0};...
        'FZMAX',[1,1],{'gt','FZMIN'};...
        'PRESMIN',[1,1],{'gte',0};...
        'PRESMAX',[1,1],{'gt','PRESMIN'};...
        'KPUMAX',[1,1],{};...
        'VXLOW',[1,1],{'gt',0};...
        'LONGVL',[1,1],{'gt',0};...
        'FZMIN',[1,1],{'gte',0};...
        'RIM_RADIUS',[1,1],{'gt',0};...
        'BOTTOM_OFFST',[1,1],{};...
        'BOTTOM_STIFF',[1,1],{'gte',0};...
        'br',rotDims,{'gte',0};...
        'FNOMIN',[1,1],{'gte',0};...
        'WIDTH',[1,1],{'gte',0};...
        'MASS',vertDims,{'gt',0};...
        'GRAVITY',[1,1],{};...
        'VERTICAL_STIFFNESS',[1,1],{'gte',0};...
        'VERTICAL_DAMPING',vertDims,{'gte',0};...
        'BOTTOM_STIFF',[1,1],{'gte',0};...
        'LONGITUDINAL_STIFFNESS',[1,1],{'gte',0};...
        'LATERAL_STIFFNESS',[1,1],{'gte',0};...
        'FxRelFreqLwrLim',[1,1],{'gt',0};...
        'FyRelFreqLwrLim',[1,1],{'gt',0};...
        'MyRelFreqLwrLim',[1,1],{'gt',0};...
        'zo',vertDims,{};...
        'zdoto',vertDims,{};...
        'omegao',rotDims,{};...
        };

        LookupTblList=[];
        BrakeParmChecks=[];
        BrakeTableChecks=[];

        switch brakeType
        case 'None'
            if simStopped
                set_param([block,'/Wheel Module/Brakes'],'LabelModeActiveChoice','None');
                SwitchInport(block,'BrkPrs','Ground','')
            end
        case 'Disc'
            BrakeParmChecks={...
            'disk_abore',fricDims,{'gt',0;'lte',10};...
            'num_pads',fricDims,{'gte',1;'int',0;'lte',20};
            'Rm',fricDims,{'gt',0;'lte',1e6}};
            if simStopped
                set_param([block,'/Wheel Module/Brakes'],'LabelModeActiveChoice','Disk');
                SwitchInport(block,'BrkPrs','Inport','')
            end
        case 'Drum'
            BrakeParmChecks={...
            'drum_theta1',fricDims,{'lt','drum_theta2';'gte',0};...
            'drum_theta2',fricDims,{'gt',0.;'lte',360};...
            'drum_r',fricDims,{'gt',0.;'lte',1e6};...
            'drum_a',fricDims,{'lte','drum_r';'gte',0.};...
            'drum_c',fricDims,{'gt',0.;'lte',1e6};...
            'drum_abore',fricDims,{'gt',0.;'lte',1e6}};
            if simStopped
                set_param([block,'/Wheel Module/Brakes'],'LabelModeActiveChoice','Drum');
                SwitchInport(block,'BrkPrs','Inport','')
            end
        case 'Mapped'
            MappedBrakeTblBpt={'brake_p_bpt',{'gte',0;'lte',1e6},'brake_n_bpt',{'gte',0;'lte',10000}};
            BrakeTableChecks={MappedBrakeTblBpt,'f_brake_t',{'gte',0;'lte',1e6}};
            if simStopped
                set_param([block,'/Wheel Module/Brakes'],'LabelModeActiveChoice','Mapped');
                SwitchInport(block,'BrkPrs','Inport','')
            end
        end

        InportNames={'BrkPrs'};
        FoundNames=get_param(find_system(block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport'),'Name');
        [~,PortI]=intersect(InportNames,FoundNames);
        PortI=sort(PortI);
        for i=1:length(PortI)
            set_param([block,'/',InportNames{PortI(i)}],'Port',num2str(i));
        end
        ParamList=[ParamList;GeneralBrakeParmChecks;BrakeParmChecks;];
        LookupTblList=[LookupTblList;BrakeTableChecks];

        if~isempty(LookupTblList)&&~isempty(ParamList)
            autoblkscheckparams(block,'Longitudinal Wheel',ParamList,LookupTblList);
        elseif~isempty(ParamList)
            autoblkscheckparams(block,'Longitudinal Wheel',ParamList);
        end


        if strcmp(brakeType,'Drum')
            DrumLockStatus=autoblksdrumbrake(block);
            if DrumLockStatus
                error(message('autoblks_shared:autoerrDrumBrake:invalidDrumBrakeDesign',block));
            end
        end
        if~simStopped
            tireDataSrc=get_param(block,'tireType');
            switch tireDataSrc


            case 'External file'
                extData=zeros(279,1);
                extData(4)=1;
                varargout{1}=extData;
            case 'Light passenger car 205/60R15'
                varargout{1}=struct2array(tireMF20560R15('Novi'))';
            case 'Mid-size passenger car 235/45R18'
                varargout{1}=struct2array(tireMF23545R18('Novi'))';
            case 'Performance car 225/40R19'
                varargout{1}=struct2array(tireMF22540R19('Novi'))';
            case 'SUV 265/50R20'
                varargout{1}=struct2array(tireMF26550R20('Novi'))';
            case 'Light truck 275/65R18'
                varargout{1}=struct2array(tireMF20560R15('Novi'))';
            case 'Commercial truck 295/75R22.5'
                varargout{1}=struct2array(tireMF29575R22p5('Novi'))';
            otherwise
                extData=zeros(279,1);
                extData(4)=1;
                varargout{1}=extData;
            end
        else
            extData=zeros(279,1);
            extData(4)=1;
            varargout{1}=extData;
        end

    case 1


        titleObj=message('vdynblks:vehdyntire:dialogTitle');
        OKObj=message('vdynblks:vehdyntire:dialogOK');
        cancelObj=message('vdynblks:vehdyntire:dialogCancel');
        promptObj=message('vdynblks:vehdyntire:dialogPrompt');
        choice=questdlg(promptObj.getString,titleObj.getString,OKObj.getString,cancelObj.getString,cancelObj.getString);

        if strcmp(choice,'OK')
            aDlgHdl=maskObj.getDialogHandle();
            if~isempty(aDlgHdl)
                aDlgHdl.apply;
            end
            WsVars=maskObj.getWorkspaceVariables;
            [~,IParamList]=intersect({WsVars.Name},'tireParamSet','stable');
            tireMaskInput=WsVars(IParamList);
            if isa(tireMaskInput.Value,'mpt.Parameter')||isa(tireMaskInput.Value,'Simulink.Parameter')
                tireMaskInput.Value=tireMaskInput.Value.Value;
            end

            tireMaskInput=tireMaskInput.Value;

            if isa(tireMaskInput,'tire.tire')

                if all([tireMaskInput.FITTYP]==62)
                    [tireStruct,tiresStruct]=createStruct(tireMaskInput);
                else
                    error(message('vdynblks:vehdyntire:wrongMFVer'))
                end

            elseif isstruct(tireMaskInput)

                if all([tireMaskInput.FITTYP]==62)
                    [tireStruct,tiresStruct]=createStruct(tireMaskInput);
                else
                    error(message('vdynblks:vehdyntire:wrongMFVer'))
                end


            elseif ischar(tireMaskInput)||iscellstr(tireMaskInput)
                if ischar(tireMaskInput)
                    tireMaskInput={tireMaskInput};
                end
                TireObj=tire.tire(tireMaskInput);

                if~(all([TireObj.FITTYP]==62)||all([TireObj.FITTYP]==61))
                    warning(message('vdynblks:vehdyntire:wrongMFVer'))
                end
                [tireStruct,tiresStruct]=createStruct(TireObj);
                setMaskVars(TireObj,block);
            else

                error(message('vdynblks:vehdyntire:unknownType'))
            end
        end
        varargout{1}=[];

    case 2
        switch brakeType
        case 'None'
            autoblksenableparameters(block,[],[],[],{'brakeParam','DiskBrakeParms','DrumBrakeParms','MappedBrakeParms'});

        case 'Disc'
            autoblksenableparameters(block,[],[],{'brakeParam','GenParams','DiskBrakeParms'},{'DrumBrakeParms','MappedBrakeParms'});

        case 'Drum'
            autoblksenableparameters(block,[],[],{'brakeParam','GenParams','DrumBrakeParms'},{'DiskBrakeParms','MappedBrakeParms'});

        case 'Mapped'
            autoblksenableparameters(block,[],[],{'brakeParam','GenParams','MappedBrakeParms'},{'DrumBrakeParms','DiskBrakeParms'});
        end
        varargout{1}=[];

    case 3
        h=figure('Visible','off');
        autoblksgetmaskparms(block,{'brake_p_bpt','brake_n_bpt','f_brake_t'},true);
        [X,Y]=ndgrid(brake_p_bpt,brake_n_bpt);
        surf(X,Y,f_brake_t);
        xlabel('Applied brake pressure [bar]');
        ylabel('Wheel speed [rpm]');
        zlabel('Brake torque [N*m]');
        title('Brake torque vs applied pressure and wheel speed');
        h.Visible='on';
        varargout{1}=[];


    case 4
        [fileName,pathName,~]=uigetfile({'*.tir';'*.mat';'*.*'},'File Selector');
        if fileName~=0
            set_param(block,'tireParamSet',fullfile(pathName,fileName));
        else
            return;
        end
        try

            return
        catch
            error(message('autoblks_shared:autoerrDrivecycle:invalidFile','File name'));
        end
        varargout{1}=[];

    case 5
        tireDataSrc=get_param(block,'tireType');
        if strcmp(tireDataSrc,'External file')
            autoblksenableparameters(block,[],{'FxRelFreqLwrLim';'FyRelFreqLwrLim';'MyRelFreqLwrLim'},{'tireParam';'tireParamTab'},{'paramOverwrite'});
        else
            paramOverButton=maskObj.getDialogControl('paramOverwrite');
            paramOverButton.Enabled='on';
            paramOverButton.Visible='on';
            autoblksenableparameters(block,[],{'FxRelFreqLwrLim';'FyRelFreqLwrLim';'MyRelFreqLwrLim';'BREFF';'DREFF';'FREFF';'Q_RE0';'Q_V1';'Q_V2';'Q_FZ1';'Q_FZ2';'Q_FZ3';'Q_FCX';'Q_FCY';'Q_FCY2';'PFZ1';'VERTICAL_STIFFNESS';'BOTTOM_OFFST';'BOTTOM_STIFF'},[],{'tireParam';'structParamPannel';'contParamPannel';'longParamPannel';'overParamPannel';'lateralParamPanel';'rollParamPanel';'alignParamPanel';'turnParamPanel'},true);
        end

        p=Simulink.Mask.get(block);
        tempParam=p.getParameter('FxRelFreqLwrLim');
        if~isempty(tempParam)

            tempParam.Visible='off';
        end
        tempParam=p.getParameter('FyRelFreqLwrLim');
        if~isempty(tempParam)

            tempParam.Visible='off';
        end
        tempParam=p.getParameter('MyRelFreqLwrLim');
        if~isempty(tempParam)

            tempParam.Visible='off';
        end
        varargout{1}=0;

    case 6
        tireDataSrc=get_param(block,'tireType');

        switch tireDataSrc
        case 'External file'
            tirStruct=[];
        case 'Light passenger car 205/60R15'
            tirStruct=tireMF20560R15('Novi');
        case 'Mid-size passenger car 235/45R18'
            tirStruct=tireMF23545R18('Novi');
        case 'Performance car 225/40R19'
            tirStruct=tireMF22540R19('Novi');
        case 'SUV 265/50R20'
            tirStruct=tireMF26550R20('Novi');
        case 'Light truck 275/65R18'
            tirStruct=tireMF27565R18('Novi');
        case 'Commercial truck 295/75R22.5'
            tirStruct=tireMF29575R22p5('Novi');
        otherwise
            varargout{1}=0;
        end
        updateMaskValues(block,tirStruct);

        varargout{1}=0;

    case 8
        varargout{1}=DrawCommands(block);

    otherwise
        varargout{1}=[];
    end
end


function IconInfo=DrawCommands(BlkHdl)

    AliasNames={'BrakePress MPa','BrkPrs';'DriveTorque','DrvTrq'};
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    switch get_param(BlkHdl,'BrakeType')
    case 'None'
        IconInfo.ImageName='wheel3dof.png';
    case 'Disc'
        IconInfo.ImageName='wheel3dofdisc.png';
    case 'Drum'
        IconInfo.ImageName='wheel3dofdrum.png';
    case 'Mapped'
        IconInfo.ImageName='wheel3dofmap.png';
    end
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,50,'white');
end


function LockStatus=autoblksdrumbrake(block)


    LockStatus=false;

    MaskObject=get_param(block,'MaskObject');
    MaskVarNames={MaskObject.getWorkspaceVariables.Name};
    MaskVarValues={MaskObject.getWorkspaceVariables.Value};

    [~,i]=intersect(MaskVarNames,'drum_a');
    a=MaskVarValues{i};

    [~,i]=intersect(MaskVarNames,'drum_r');
    r=MaskVarValues{i};

    [~,i]=intersect(MaskVarNames,'mu_kinetic');
    mu=MaskVarValues{i};

    [~,i]=intersect(MaskVarNames,'drum_theta1');
    theta1=MaskVarValues{i}*pi/180.;

    [~,i]=intersect(MaskVarNames,'drum_theta2');
    theta2=MaskVarValues{i}*pi/180.;

    sigma=cos(theta2)-cos(theta1);

    Denominator1=2.*mu.*(-2.*r.*sigma-a.*(cos(theta1).^2-cos(theta2).^2));

    Denominator2=a.*(2.*theta1-2.*theta2-sin(2.*theta1)+sin(2.*theta2));

    if any((Denominator1+Denominator2)>=0)
        LockStatus=true;
    end
end
function SwitchInport(Block,PortName,UsePort,Param)

    InportOption={'built-in/Constant',[PortName,'Constant'];...
    'built-in/Inport',PortName;...
    'simulink/Sinks/Terminator',[PortName,'Terminator'];...
    'simulink/Sinks/Out1',PortName;...
    'built-in/Ground',[PortName,'Ground']};
    switch UsePort
    case 'Constant'
        NewBlkHdl=autoblksreplaceblock(Block,InportOption,1);
        set_param(NewBlkHdl,'Value',Param);
    case 'Terminator'
        autoblksreplaceblock(Block,InportOption,3);
    case 'Outport'
        autoblksreplaceblock(Block,InportOption,4);
    case 'Inport'
        autoblksreplaceblock(Block,InportOption,2);
    case 'Ground'
        autoblksreplaceblock(Block,InportOption,5);
    end
end
function updateMaskValues(block,tirStruct)
    if~isempty(tirStruct)
        set_param(block,'PRESMAX',num2str(tirStruct.PRESMAX),...
        'PRESMIN',num2str(tirStruct.PRESMIN),...
        'FZMAX',num2str(tirStruct.FZMAX),...
        'FZMIN',num2str(tirStruct.FZMIN),...
        'VXLOW',num2str(tirStruct.VXLOW),...
        'KPUMAX',num2str(tirStruct.KPUMAX),...
        'KPUMIN',num2str(tirStruct.KPUMIN),...
        'ALPMAX',num2str(tirStruct.ALPMAX),...
        'ALPMIN',num2str(tirStruct.ALPMIN),...
        'CAMMIN',num2str(tirStruct.CAMMIN),...
        'CAMMAX',num2str(tirStruct.CAMMAX),...
        'LONGVL',num2str(tirStruct.LONGVL),...
        'UNLOADED_RADIUS',num2str(tirStruct.UNLOADED_RADIUS),...
        'RIM_RADIUS',num2str(tirStruct.RIM_RADIUS),...
        'NOMPRES',num2str(tirStruct.NOMPRES),...
        'VERTICAL_DAMPING',num2str(tirStruct.VERTICAL_DAMPING),...
        'FNOMIN',num2str(tirStruct.FNOMIN),...
        'MASS',num2str(tirStruct.MASS),...
        'IYY',num2str(tirStruct.IYY),...
        'WIDTH',num2str(tirStruct.WIDTH));
    end
end
