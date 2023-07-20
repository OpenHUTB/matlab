function[varargout]=vehdynstdtire(varargin)




    block=varargin{1};
    maskMode=varargin{2};
    maskObj=Simulink.Mask.get(block);
    varargout{1}=[];
    simStatus=get_param(bdroot(block),'SimulationStatus');
    if strcmp(simStatus,'stopped')||strcmp(simStatus,'updating')
        simStopped=true;
    else
        simStopped=false;
    end












    switch maskMode

    case 0

        [~]=vehdynicon('vehdynlibstdtire',gcb,5);
        [~]=vehdynicon('vehdynlibstdtire',gcb,9);


        massVal=autoblksgetmaskparms(gcb,{'MASS'},true);
        wheelDims=size(massVal);
        ParamList={...
        'IYY',wheelDims,{'gt',0};...
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
        'br',wheelDims,{'gte',0};...
        'FNOMIN',[1,1],{'gte',0};...
        'WIDTH',[1,1],{'gte',0};...
        'MASS',[1,1],{'gt',0};...
        'GRAVITY',[1,1],{};...
        'VERTICAL_STIFFNESS',[1,1],{'gte',0};...
        'VERTICAL_DAMPING',wheelDims,{'gte',0};...
        'BOTTOM_STIFF',[1,1],{'gte',0};...
        'LONGITUDINAL_STIFFNESS',[1,1],{'gte',0};...
        'LATERAL_STIFFNESS',[1,1],{'gte',0};...
        'FxRelFreqLwrLim',[1,1],{'gt',0};...
        'FyRelFreqLwrLim',[1,1],{'gt',0};...
        'MyRelFreqLwrLim',[1,1],{'gt',0};...
        'TirePrs',[1,1],{'gte',0};...
        'zo',wheelDims,{};...
        'zdoto',wheelDims,{};...
        'omegao',wheelDims,{};...
        };

        LookupTblList=[];


        if~isempty(LookupTblList)&&~isempty(ParamList)
            autoblkscheckparams(block,'CPI/STI Tire Block',ParamList,LookupTblList);
        elseif~isempty(ParamList)
            autoblkscheckparams(block,'CPI/STI Tire Block',ParamList);
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

            if isa(tireMaskInput,'Tire')

                if all([tireMaskInput.FITTYP]==62)
                    [tireStruct,tiresStruct]=createStruct(tireMaskInput);
                else
                    error(message('vdynblks:vehdyntire:wrongMFVer'));
                end

                if strcmp(tireMaskInput.TYRESIDE,'Left')
                    set_param(block,'tyreside',"'Left'");
                else
                    set_param(block,'tyreside',"'Right'");
                end


            elseif isstruct(tireMaskInput)

                if all([tireMaskInput.FITTYP]==62)
                    [tireStruct,tiresStruct]=createStruct(tireMaskInput);
                else
                    error(message('vdynblks:vehdyntire:wrongMFVer'));
                end

                if strcmp(tireMaskInput.TYRESIDE,'Left')
                    set_param(block,'tyreside',"'Left'");
                else
                    set_param(block,'tyreside',"'Right'");
                end


            elseif ischar(tireMaskInput)||iscellstr(tireMaskInput)
                if ischar(tireMaskInput)
                    tireMaskInput={tireMaskInput};
                end
                TireObj=tire.tire(tireMaskInput);

                if~(all([TireObj.FITTYP]==62)||all([TireObj.FITTYP]==61))
                    warning(message('vdynblks:vehdyntire:wrongMFVer'));
                end
                [tireStruct,tiresStruct]=createStruct(TireObj);
                setMaskVars(TireObj,block)

                if strcmp(TireObj.TYRESIDE,'Left')
                    set_param(block,'tyreside',"'Left'");
                else
                    set_param(block,'tyreside',"'Right'");
                end
            else

                error(message('vdynblks:vehdyntire:unknownType'));
            end
        end
        varargout{1}=[];


    case 2
        varargout{1}=[];


    case 3
        varargout{1}=[];


    case 4
        [fileName,pathName,~]=uigetfile({'*.tir';'*.mat';'*.*'},'File Selector');
        if fileName~=0
            set_param(block,'tireParamSet',fullfile(pathName,fileName));
        else
            return;
        end
        try

            return;
        catch
            error(message('autoblks_shared:autoerrDrivecycle:invalidFile','File name'));
        end
        varargout{1}=[];


    case 5
        if simStopped
            tireDataSrc=get_param(block,'tireType');
            if strcmp(tireDataSrc,'External file')
                autoblksenableparameters(block,[],{'FxRelFreqLwrLim';'FyRelFreqLwrLim';'MyRelFreqLwrLim'},{'tireParam';'tireParamTab'},{'paramOverwrite'});
            else
                paramOverButton=maskObj.getDialogControl('paramOverwrite');
                paramOverButton.Enabled='on';
                paramOverButton.Visible='on';
                autoblksenableparameters(block,[],{'FxRelFreqLwrLim';'FyRelFreqLwrLim';'MyRelFreqLwrLim';'BREFF';'DREFF';'FREFF';'Q_RE0';'Q_V1';'Q_V2';'Q_FZ1';'Q_FZ2';'Q_FZ3';'Q_FCX';'Q_FCY';'Q_FCY2';'PFZ1';'VERTICAL_STIFFNESS';'BOTTOM_OFFST';'BOTTOM_STIFF'},[],{'tireParam';'structParamPannel';'contParamPannel';'longParamPannel';'overParamPannel';'lateralParamPanel';'rollParamPanel';'alignParamPanel';'turnParamPanel'},true);
            end
            autoblksenableparameters(block,[],{'FxRelFreqLwrLim';'FyRelFreqLwrLim';'MyRelFreqLwrLim'},[],[]);
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
            tirStruct=tireMF20560R15('Novi');
        case 'Commercial truck 295/75R22.5'
            tirStruct=tireMF29575R22p5('Novi');
        otherwise
            varargout{1}=0;
        end
        updateMaskValues(block,tirStruct);

        varargout{1}=0;


    case 8
        varargout{1}=DrawCommands(block);


    case 9
        if simStopped
            setpressureparam(block);
        end
        varargout{1}=[];

    case 10
        checkbox=get_param(block,'extTirePrs');
        if strcmp(checkbox,'on')
            autoblksenableparameters(block,[],{'TirePrs'},[],[],1);
        else
            autoblksenableparameters(block,{'TirePrs'},[],[],[],1);
        end

    case 11
        autoblksenableparameters(block,[],{'zo','zdoto','MASS','GRAVITY','IYY','br','omegao'},[],{'inertParamPannel'},0);
    case 12
        autoblksenableparameters(block,[],{'zo','zdoto','VERTICAL_DAMPING','MASS','GRAVITY','IYY','br','omegao'},[],{'inertParamPannel'},0);

    otherwise
        varargout{1}=[];

    end
end



function setpressureparam(block)
    checkbox=get_param(block,'extTirePrs');
    if strcmp(checkbox,'on')
        autoblksenableparameters(block,[],{'TirePrs'},[],[],1);
        SwitchInport(block,'Prs','Inport','TirePrs');
    else
        autoblksenableparameters(block,{'TirePrs'},[],[],[],1);
        SwitchInport(block,'Prs','Constant','TirePrs');
    end
end


function IconInfo=DrawCommands(BlkHdl)

    IconInfo=autoblksgetportlabels(BlkHdl);

    switch get_param(BlkHdl,'TireIO')
    case 'CPI'
        IconInfo.ImageName='cpi_tire_block.png';
    case 'STI'
        IconInfo.ImageName='sti_tire_block.png';
    end
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,50,'white');
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
