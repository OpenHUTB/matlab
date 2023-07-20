function[varargout]=vehdyntirefiala(varargin)


    block=varargin{1};
    maskMode=varargin{2};

    maskRollingType=get_param(block,'rollingType');
    brakeType=get_param(block,'BrakeType');
    vertType=get_param(block,'vertType');
    varargout{1}=[];
    simStopped=autoblkschecksimstopped(block);








    switch maskMode

    case 0


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
        longstiffVal=autoblksgetmaskparms(block,{'Ckappa'},true);
        latstiffVal=autoblksgetmaskparms(block,{'Calpha'},true);
        camstiffVal=autoblksgetmaskparms(block,{'Cgamma'},true);
        muminVal=autoblksgetmaskparms(block,{'muMin'},true);
        mumaxVal=autoblksgetmaskparms(block,{'muMax'},true);
        LrelxVal=autoblksgetmaskparms(block,{'Lrelx'},true);
        LrelyVal=autoblksgetmaskparms(block,{'Lrely'},true);
        stiffDims=max([size(latstiffVal{:});size(longstiffVal{:});size(camstiffVal{:});size(muminVal{:});size(mumaxVal{:});size(LrelxVal{:});size(LrelyVal{:});[1,1]]);
        GeneralBrakeParmChecks={...
        'mu_kinetic',fricDims,{'gt',0.;'lte',1.};...
        'mu_static',fricDims,{'gte','mu_kinetic';'lte',1.}};
        ParamList={...
        'Ckappa',stiffDims,{'gt',0};...
        'Calpha',stiffDims,{'gt',0};...
        'Cgamma',stiffDims,{};...
        'muMin',stiffDims,{'gt',0};...
        'muMax',stiffDims,{'gt','muMin'};...
        'Lrelx',stiffDims,{'gt',0};...
        'Lrely',stiffDims,{'gt',0};...
        'MASS',vertDims,{'gt',0};...
        'zo',vertDims,{};...
        'zdoto',vertDims,{};...
        'VERTICAL_STIFFNESS',vertDims,{'gt',0};...
        'VERTICAL_DAMPING',vertDims,{'gt',0};...
        'GRAVITY',[1,1],{};...
        'UNLOADED_RADIUS',[1,1],{'gt',0};...
        'br',rotDims,{'gte',0};...
        'IYY',rotDims,{'gt',0};...
        'FZMIN',[1,1],{'gte',0};...
        'FZMAX',[1,1],{'gt','FZMIN'};...
        'WIDTH',[1,1],{'gt',0};...
        'PRESMIN',[1,1],{'gte',0};...
        'PRESMAX',[1,1],{'gt','PRESMIN'};...
        'KPUMAX',[1,1],{};...
        'KPUMIN',[1,1],{};...
        'ALPMAX',[1,1],{};...
        'ALPMIN',[1,1],{};...
        'CAMMAX',[1,1],{};...
        'CAMMIN',[1,1],{};...
        'omegao',rotDims,{};...
        };

        LookupTblList=[];
        MyParmChecks=[];
        MyTableChecks=[];
        BrakeParmChecks=[];
        BrakeTableChecks=[];
        switch maskRollingType
        case 'None'
            if simStopped
                set_param([block,'/Fiala/Rolling'],'LabelModeActiveChoice','None');
                set_param(block,'extTamb','off');
            end
        case 'Pressure and velocity'
            MyParmChecks={...
            'br',[1,1],{'gte',0};...
            'aMy',[1,1],{'gte',0};...
            'bMy',[1,1],{'gte',0};...
            'cMy',[1,1],{'gte',0};...
            'alphaMy',[1,1],{};...
            'betaMy',[1,1],{};...
            };
            if simStopped
                set_param([block,'/Fiala/Rolling'],'LabelModeActiveChoice','Simple');
            end

            set_param(block,'extTamb','off');
        case 'Magic Formula'
            MyParmChecks={...
            'QSY1',[1,1],{};...
            'QSY2',[1,1],{};...
            'QSY3',[1,1],{};...
            'QSY4',[1,1],{};...
            'QSY7',[1,1],{};...
            'QSY8',[1,1],{};...
            'lam_My',[1,1],{'gte',0};...
            'FNOMIN',[1,1],{'gt',0};...
            'NOMPRES',[1,1],{'gt',0};...
            };
            if simStopped
                set_param([block,'/Fiala/Rolling'],'LabelModeActiveChoice','MagicFormula');
            end
            set_param(block,'extTamb','off');
        case 'Mapped torque'
            MappedMyTblBpt={'VxMy',{},'FzMy',{}};
            MyTableChecks={MappedMyTblBpt,'MyMap',{}};
            if simStopped
                set_param([block,'/Fiala/Rolling'],'LabelModeActiveChoice','Mapped');
                set_param(block,'extTamb','off');
            end
        case 'ISO 28580'
            MyParmChecks={...
            'Fpl',[1,1],{};...
            'Cr',[1,1],{'gt',0};...
            'Kt',[1,1],{};...
            'Tmeas',[1,1],{'gte',0};...
            'Tamb',[1,1],{'gte',0};...
            'TMIN',[1,1],{'gte',0};...
            'TMAX',[1,1],{'gt','TMIN'};...
            };
            if simStopped
                set_param([block,'/Fiala/Rolling'],'LabelModeActiveChoice','ISO');
            end
        end
        switch vertType
        case 'None'
            FzParmChecks={...
            'zo',[1,1],{};
            };
            if simStopped
                set_param([block,'/Vertical DOF'],'LabelModeActiveChoice',vertType);
            end
            FzTableChecks=[];
        case 'Magic Formula'
            FzParmChecks={...
            'Gndz',[1,1],{}
            'm',[1,1],{'gt',0};...
            'zo',[1,1],{};...
            'zdoto',[1,1],{};...
            'g',[1,1],{'gte',0};...
            'VERTICAL_STIFFNESS',[1,1],{'gte',0};...
            'VERTICAL_DAMPING',[1,1],{'gte',0};...
            'Q_RE0',[1,1],{'gt',0};...
            'Q_V1',[1,1],{};...
            'Q_V2',[1,1],{};...
            'Q_FZ1',[1,1],{};...
            'Q_FZ2',[1,1],{};...
            'Q_FCX',[1,1],{};...
            'Q_FCY',[1,1],{};...
            'Q_CAM',[1,1],{};...
            'PFZ1',[1,1],{};...
            'Q_FCY2',[1,1],{};...
            'Q_CAM1',[1,1],{};...
            'Q_CAM2',[1,1],{};...
            'Q_CAM3',[1,1],{};...
            'Q_FYS1',[1,1],{};...
            'Q_FYS2',[1,1],{};...
            'Q_FYS3',[1,1],{};...
            'BOTTOM_OFFST',[1,1],{'gte',0};...
            'BOTTOM_STIFF',[1,1],{'gte',0};...
            };
            if simStopped
                set_param([block,'/Vertical DOF'],'LabelModeActiveChoice','Magic');
            end
        case 'Mapped stiffness and damping'
            FzParmChecks={...
            'MASS',[1,1],{'gt',0};...
            'zo',[1,1],{};...
            'zdoto',[1,1],{};...
            'GRAVITY',[1,1],{}};
            FzTableChecks={{'pFz',{'gte',0},'zFz',{}},'Fzz',{};...
            {'pFz',{'gte',0},'zdotFz',{}},'Fzzdot',{}};
            if simStopped
                set_param([block,'/Vertical DOF'],'LabelModeActiveChoice','Mapped');
            end
        end
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
        extTamb=get_param(block,'extTamb');
        if simStopped
            if strcmp(extTamb,'off')
                SwitchInport(block,'Tamb','Constant','0');
            else
                SwitchInport(block,'Tamb','Inport','Tamb');
            end
        end
        ParamList=[ParamList;GeneralBrakeParmChecks;MyParmChecks;BrakeParmChecks;FzParmChecks];
        LookupTblList=[LookupTblList;MyTableChecks;BrakeTableChecks;FzTableChecks];

        if~isempty(LookupTblList)&&~isempty(ParamList)
            autoblkscheckparams(block,'Longitudinal Wheel',ParamList,LookupTblList);
        elseif~isempty(ParamList)
            autoblkscheckparams(block,'Longitudinal Wheel',ParamList);
        end
        if strcmp(extTamb,'off')&&strcmp(maskRollingType,'ISO 28580')
            set_param([block,'/TambConstant'],'Value','Tamb')
        end

        if strcmp(brakeType,'Drum')
            DrumLockStatus=autoblksdrumbrake(block);
            if DrumLockStatus
                error(message('autoblks_shared:autoerrDrumBrake:invalidDrumBrakeDesign',block));
            end
        end

        InportNames={'BrkPrs','AxlTrq','Vx','Vy','Camber','YawRate','Prs','Gnd','Fext','Tamb','ScaleFctr'};
        FoundNames=get_param(find_system(block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport'),'Name');
        [~,PortI]=intersect(InportNames,FoundNames);
        PortI=sort(PortI);
        for i=1:length(PortI)
            set_param([block,'/',InportNames{PortI(i)}],'Port',num2str(i));
        end
        varargout{1}=[];


    case 1
        switch maskRollingType
        case 'None'
            autoblksenableparameters(block,[],{'extTamb','TMIN','TMAX'},[],{'rollingParam','SimpMyParams','MagicMyParams','MappedMyParams','ISOMyParams'});

        case 'Pressure and velocity'
            autoblksenableparameters(block,[],{'extTamb','TMIN','TMAX'},{'rollingParam','SimpMyParams'},{'MagicMyParams','MappedMyParams','ISOMyParams'});

        case 'Magic Formula'
            autoblksenableparameters(block,[],{'extTamb','TMIN','TMAX'},{'rollingParam','MagicMyParams'},{'SimpMyParams','MappedMyParams','ISOMyParams'});

        case 'Mapped torque'
            autoblksenableparameters(block,[],{'extTamb','TMIN','TMAX'},{'rollingParam','MappedMyParams'},{'MagicMyParams','SimpMyParams','ISOMyParams'});
        case 'ISO 28580'
            autoblksenableparameters(block,{'extTamb','TMIN','TMAX'},[],{'rollingParam','ISOMyParams'},{'MagicMyParams','SimpMyParams','MappedMyParams'});

        end
        setmaskparam(block,maskRollingType,vertType);

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
        xlabel(getString(message('autoblks_shared:autoblkLongitudinalWheelPlot:brk_plot_x')));
        ylabel(getString(message('autoblks_shared:autoblkLongitudinalWheelPlot:brk_plot_y')));
        zlabel(getString(message('autoblks_shared:autoblkLongitudinalWheelPlot:brk_plot_z')));
        title(getString(message('autoblks_shared:autoblkLongitudinalWheelPlot:brk_plot_title')));
        h.Visible='on';
        varargout{1}=[];

    case 4
        h=figure('Visible','off');
        autoblksgetmaskparms(block,{'VxMy','FzMy','MyMap'},true);
        [X,Y]=ndgrid(VxMy,FzMy);
        surf(X,Y,MyMap);xlabel(getString(message('autoblks_shared:autoblkLongitudinalWheelPlot:My_plot_x')));
        ylabel(getString(message('autoblks_shared:autoblkLongitudinalWheelPlot:My_plot_y')));
        zlabel(getString(message('autoblks_shared:autoblkLongitudinalWheelPlot:My_plot_z')));
        title(getString(message('autoblks_shared:autoblkLongitudinalWheelPlot:My_plot_title')));
        h.Visible='on';
        varargout{1}=[];

    case 5
        switch vertType
        case 'None'
            autoblksenableparameters(block,[],{'GRAVITY','MASS','zo','zdoto'},[],{'vertMagicParam','vertMappedParam','vertLinearParam'});

        case 'Magic Formula'
            autoblksenableparameters(block,{'GRAVITY','MASS','zo','zdoto'},[],{'vertMagicParam'},{'vertMappedParam','vertLinearParam'});

        case 'Mapped stiffness and damping'
            autoblksenableparameters(block,{'GRAVITY','MASS','zo','zdoto'},[],{'vertMappedParam'},{'vertMagicParam','vertLinearParam'});

        end
        setmaskparam(block,maskRollingType,vertType);
        varargout{1}=[];


    case 8
        varargout{1}=DrawCommands(block);

    otherwise
        varargout{1}=[];
    end
    if maskMode==12
        pressType=get_param(block,'extPress');
        if strcmp(pressType,'on')
            autoblksenableparameters(block,[],{'press'},[],[],true);
        else
            autoblksenableparameters(block,{'press'},[],[],[],true);
        end
        varargout{1}=[];
    end
    if maskMode==13
        TambType=get_param(block,'extTamb');
        if strcmp(TambType,'on')
            autoblksenableparameters(block,[],{'Tamb'},[],[],true);
        else
            autoblksenableparameters(block,{'Tamb'},[],[],[],true);
        end
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


function setmaskparam(block,maskRollingType,vertType)
    paramVec={'press','extPress','NOMPRES','PRESSMIN','PRESSMAX','gamma','FNOMIN','UNLOADED_RADIUS','LONGVL','lam_Fzo','g','m','zo','zdoto','extGnd','Gndz','Fpl','TMIN','TMAX','Tmeas','Tamb','extTamb'};
    groupVec={'vertParam','vertMagicParam','vertMappedParam','vertLinearParam'};
    rollParamVec=boolean(zeros(length(paramVec),1));
    KzParamVec=rollParamVec;

    rollGroupVec=boolean(zeros(length(groupVec),1));
    KzGroupVec=rollGroupVec;

    switch maskRollingType
    case 'None'

    case 'Pressure and velocity'
        rollParamVec([4,5,8])=true;

    case 'Magic Formula'
        rollParamVec(3:8)=true;
        rollGroupVec(1)=true;

    case 'Mapped torque'
        rollParamVec(8)=true;
    case 'ISO 28580'
        rollParamVec(8)=true;
        rollParamVec(17:end)=true;
    end

    switch vertType
    case 'None'

    case 'Magic Formula'
        KzParamVec([1,2,10:16])=true;
        KzGroupVec([1,2])=true;
    case 'Mapped stiffness and damping'
        KzParamVec([1,2,11:16])=true;
        KzGroupVec([1,3])=true;
    end
    maskParamInds=rollParamVec|KzParamVec;
    maskGroupInds=rollGroupVec|KzGroupVec;
    autoblksenableparameters(block,[],[],groupVec(maskGroupInds),groupVec(~maskGroupInds));
    autoblksenableparameters(block,paramVec(maskParamInds),paramVec(~maskParamInds),[],[]);
    [~]=vehdyntirefiala(block,13);

end