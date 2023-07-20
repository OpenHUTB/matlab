function[varargout]=autoblkswheel(varargin)




    block=varargin{1};
    maskMode=varargin{2};
    maskRollingType=get_param(block,'rollingType');
    maskFxType=get_param(block,'FxType');
    brakeType=get_param(block,'BrakeType');
    vertType=get_param(block,'vertType');
    varargout{1}=[];
    simStopped=autoblkschecksimstopped(block);


    if maskMode==0


        blkPath=block;
        gndType=get_param(block,'extMu');
        extGnd=get_param(block,'extGnd');
        extPress=get_param(block,'extPress');

        ParamList={...
        'omegao',[1,1],{};...
        'Iyy',[1,1],{'gt',0};...
        'Re',[1,1],{'gt',0};...
        'Lrel',[1,1],{'gt',0};...
        'gamma',[1,1],{};...
        'UNLOADED_RADIUS',[1,1],{'gt',0};...
        'press',[1,1],{'gte',0};...
        'FZMIN',[1,1],{'gte',0};...
        'FZMAX',[1,1],{'gt','FZMIN'};...
        'PRESMIN',[1,1],{'gte',0};...
        'PRESMAX',[1,1],{'gt','PRESMIN'};...
        'kappamax',[1,1],{'gt',0};...
        'VXLOW',[1,1],{'gt',0};...
        'LONGVL',[1,1],{'gt',0};...
        };

        LookupTblList=[];
        FxParmChecks=[];
        MyParmChecks=[];
        MyTableChecks=[];
        FzParmChecks=[];
        FzTableChecks=[];
        FxTableChecks=[];
        BrakeParmChecks=[];
        BrakeTableChecks=[];
        switch maskFxType
        case 'Magic Formula constant value'
            FxParmChecks={...
            'Dx',[1,1],{};...
            'Cx',[1,1],{};...
            'Bx',[1,1],{};...
            'Ex',[1,1],{};...
            'lam_x',[1,1],{'gte',0};...
            };
            if simStopped
                strprts=strsplit([maskFxType,' Fx'],' ');
                set_param([blkPath,'/Longitudinal Parameters'],'LabelModeActiveChoice',[strprts{:}]);
                set_param([blkPath,'/FxType'],'Value','0');
            end
        case 'Magic Formula pure longitudinal slip'
            FxParmChecks={...
            'PCX1',[1,1],{};...
            'PDX1',[1,1],{};...
            'PDX2',[1,1],{};...
            'PDX3',[1,1],{};...
            'PEX1',[1,1],{};...
            'PEX2',[1,1],{};...
            'PEX3',[1,1],{};...
            'PEX4',[1,1],{};...
            'PKX1',[1,1],{};...
            'PKX2',[1,1],{};...
            'PKX3',[1,1],{};...
            'PHX1',[1,1],{};...
            'PHX2',[1,1],{};...
            'PVX1',[1,1],{};...
            'PVX2',[1,1],{};...
            'PPX1',[1,1],{};...
            'PPX2',[1,1],{};...
            'PPX3',[1,1],{};...
            'PPX4',[1,1],{};...
            'lam_Fzo',[1,1],{};...
            'lam_muV',[1,1],{};...
            'lam_Kxkappa',[1,1],{};...
            'lam_Cx',[1,1],{};...
            'lam_Ex',[1,1],{};...
            'lam_Hx',[1,1],{};...
            'lam_Vx',[1,1],{};...
            'lam_x',[1,1],{'gte',0};...
            };
            if simStopped
                strprts=strsplit([maskFxType,' Fx'],' ');
                set_param([blkPath,'/Longitudinal Parameters'],'LabelModeActiveChoice',[strprts{:}]);
                set_param([blkPath,'/FxType'],'Value','2');
            end

        case 'Mapped force'
            MappedFxTblBpt={'kappaFx',{},'FzFx',{}};
            FxTableChecks={MappedFxTblBpt,'FxMap',{}};
            FxParmChecks={...
            'lam_x',[1,1],{'gte',0};...
            };
            if simStopped
                strprts=strsplit(maskFxType,' ');
                set_param([blkPath,'/Longitudinal Parameters'],'LabelModeActiveChoice',[strprts{1},strprts{2}]);
                set_param([blkPath,'/FxType'],'Value','3');
            end
        end
        switch maskRollingType
        case 'None'
            if simStopped
                set_param([blkPath,'/Rolling Parameters'],'LabelModeActiveChoice',maskRollingType);
                set_param([blkPath,'/rollType'],'Value','0');
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
                set_param([blkPath,'/Rolling Parameters'],'LabelModeActiveChoice','Simple');
                set_param([blkPath,'/rollType'],'Value','1');
                set_param(block,'extTamb','off');
            end
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
                strprts=strsplit('Magic Formula',' ');
                set_param([blkPath,'/Rolling Parameters'],'LabelModeActiveChoice',[strprts{1},strprts{2}]);
                set_param([blkPath,'/rollType'],'Value','2');
                set_param(block,'extTamb','off');
            end
        case 'Mapped torque'
            MappedMyTblBpt={'VxMy',{},'FzMy',{}};
            MyTableChecks={MappedMyTblBpt,'MyMap',{}};
            if simStopped
                strprts=strsplit('Mapped torque',' ');
                set_param([blkPath,'/Rolling Parameters'],'LabelModeActiveChoice',[strprts{1},strprts{2}]);
                set_param([blkPath,'/rollType'],'Value','3');
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
                set_param([blkPath,'/Rolling Parameters'],'LabelModeActiveChoice','ISO');
                set_param([blkPath,'/rollType'],'Value','4');
            end
        end
        switch vertType
        case 'None'
            FzParmChecks={...
            'Gndz',[1,1],{}};
            if simStopped
                set_param([blkPath,'/Vertical DOF'],'LabelModeActiveChoice',vertType);
                set_param([blkPath,'/vertType'],'Value','0');
            end
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
                set_param([blkPath,'/Vertical DOF'],'LabelModeActiveChoice','Magic');
                set_param([blkPath,'/vertType'],'Value','1');
            end
        case 'Mapped stiffness and damping'
            FzParmChecks={...
            'Gndz',[1,1],{}
            'm',[1,1],{'gt',0};...
            'zo',[1,1],{};...
            'zdoto',[1,1],{};...
            'g',[1,1],{'gte',0}};
            FzTableChecks={{'pFz',{'gte',0},'zFz',{}},'Fzz',{};...
            {'pFz',{'gte',0},'zdotFz',{}},'Fzzdot',{}};
            if simStopped
                set_param([blkPath,'/Vertical DOF'],'LabelModeActiveChoice','Mapped');
                set_param([blkPath,'/vertType'],'Value','2');
            end
        end

        switch brakeType
        case 'None'
            if simStopped
                set_param([blkPath,'/Wheel Module/Brakes'],'LabelModeActiveChoice','None');
            end
        case 'Disc'
            BrakeParmChecks={...
            'disk_abore',[1,1],{'gt',0;'lte',10};...
            'num_pads',[1,1],{'gte',1;'int',0;'lte',20};
            'Rm',[1,1],{'gt',0;'lte',1e6}};
            if simStopped
                set_param([blkPath,'/Wheel Module/Brakes'],'LabelModeActiveChoice','Disk');
            end
        case 'Drum'
            BrakeParmChecks={...
            'drum_theta1',[1,1],{'lt','drum_theta2';'gte',0};...
            'drum_theta2',[1,1],{'gt',0.;'lte',360};...
            'drum_r',[1,1],{'gt',0.;'lte',1e6};...
            'drum_a',[1,1],{'lte','drum_r';'gte',0.};...
            'drum_c',[1,1],{'gt',0.;'lte',1e6};...
            'drum_abore',[1,1],{'gt',0.;'lte',1e6}};
            if simStopped
                set_param([blkPath,'/Wheel Module/Brakes'],'LabelModeActiveChoice','Drum');
            end
        case 'Mapped'
            MappedBrakeTblBpt={'brake_p_bpt',{'gte',0;'lte',1e6},'brake_n_bpt',{'gte',0;'lte',10000}};
            BrakeTableChecks={MappedBrakeTblBpt,'f_brake_t',{'gte',0;'lte',1e6}};
            if simStopped
                set_param([blkPath,'/Wheel Module/Brakes'],'LabelModeActiveChoice','Mapped');
            end
        end

        GeneralBrakeParmChecks={...
        'mu_kinetic',[1,1],{'gt',0.;'lte',1.};...
        'mu_static',[1,1],{'gte','mu_kinetic';'lte',1.}};


        if strcmp(brakeType,'Drum')
            DrumLockStatus=autoblksdrumbrake(block);
            if DrumLockStatus
                error(message('autoblks_shared:autoerrDrumBrake:invalidDrumBrakeDesign',block));
            end
        end
        if simStopped
            if strcmp(brakeType,'None')
                SwitchInport(block,'BrkPrs','Constant','0');
            else
                SwitchInport(block,'BrkPrs','Inport','BrkPrs');
            end
            if strcmp(gndType,'off')
                SwitchInport(block,'lam_mux','Constant','lam_x');
            else
                SwitchInport(block,'lam_mux','Inport','lam_x');
            end
            if strcmp(extGnd,'off')
                SwitchInport(block,'Gnd','Constant','Gndz');

            else
                SwitchInport(block,'Gnd','Inport','Gndz');

            end
            if strcmp(vertType,'None')
                SwitchInport(block,'z','Terminator','z');
                SwitchInport(block,'zdot','Terminator','zdot');
            else
                SwitchInport(block,'z','Outport','z');
                SwitchInport(block,'zdot','Outport','zdot');
            end

            extTamb=get_param(block,'extTamb');
            if strcmp(extTamb,'off')
                SwitchInport(block,'Tamb','Constant','Tamb');
                if strcmp(maskRollingType,'ISO 28580')
                    set_param([block,'/TambConstant'],'Value','Tamb');
                else
                    set_param([block,'/TambConstant'],'Value','0');
                end
            else
                SwitchInport(block,'Tamb','Inport','Tamb');

            end
        end
        maskParamInds=setmaskparam(block,maskFxType,maskRollingType,vertType,brakeType);
        if strcmp(extPress,'off')
            if maskParamInds(1)
                SwitchInport(block,'TirePrs','Constant','press');
            else
                SwitchInport(block,'TirePrs','Constant','0');
            end
        else
            SwitchInport(block,'TirePrs','Inport','press');
        end
        ParamList=[ParamList;GeneralBrakeParmChecks;BrakeParmChecks;FxParmChecks;MyParmChecks;FzParmChecks];
        LookupTblList=[LookupTblList;BrakeTableChecks;FxTableChecks;MyTableChecks;FzTableChecks];
        if~isempty(LookupTblList)&&~isempty(ParamList)
            autoblkscheckparams(block,'Longitudinal Wheel',ParamList,LookupTblList);
        elseif~isempty(ParamList)
            autoblkscheckparams(block,'Longitudinal Wheel',ParamList);
        end


        InportNames={'BrkPrs','AxlTrq','Vx','Fz','lam_mux','Gnd','TirePrs','Tamb'};
        FoundNames=get_param(find_system(block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport'),'Name');
        [~,PortI]=intersect(InportNames,FoundNames);
        PortI=sort(PortI);
        for i=1:length(PortI)
            set_param([block,'/',InportNames{PortI(i)}],'Port',num2str(i));
        end
        varargout{1}=[];
    end

    if maskMode==5
        [~]=setmaskparam(block,maskFxType,maskRollingType,vertType,brakeType);
        varargout{1}=[];
    end

    if maskMode==2
        [~]=setmaskparam(block,maskFxType,maskRollingType,vertType,brakeType);
        varargout{1}=[];
    end

    if maskMode==1
        [~]=setmaskparam(block,maskFxType,maskRollingType,vertType,brakeType);
        varargout{1}=[];
    end

    if maskMode==3
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
    end

    if maskMode==6
        h=figure('Visible','off');
        autoblksgetmaskparms(block,{'kappaFx','FzFx','FxMap'},true);
        [X,Y]=ndgrid(kappaFx,FzFx);
        surf(X,Y,FxMap);
        xlabel(getString(message('autoblks_shared:autoblkLongitudinalWheelPlot:Fx_plot_x')));
        ylabel(getString(message('autoblks_shared:autoblkLongitudinalWheelPlot:Fx_plot_y')));
        zlabel(getString(message('autoblks_shared:autoblkLongitudinalWheelPlot:Fx_plot_z')));
        title(getString(message('autoblks_shared:autoblkLongitudinalWheelPlot:Fx_plot_title')));
        h.Visible='on';
        varargout{1}=[];
    end

    if maskMode==7
        h=figure('Visible','off');
        autoblksgetmaskparms(block,{'VxMy','FzMy','MyMap'},true);
        [X,Y]=ndgrid(VxMy,FzMy);
        surf(X,Y,MyMap);xlabel(getString(message('autoblks_shared:autoblkLongitudinalWheelPlot:My_plot_x')));
        ylabel(getString(message('autoblks_shared:autoblkLongitudinalWheelPlot:My_plot_y')));
        zlabel(getString(message('autoblks_shared:autoblkLongitudinalWheelPlot:My_plot_z')));
        title(getString(message('autoblks_shared:autoblkLongitudinalWheelPlot:My_plot_title')));
        h.Visible='on';
        varargout{1}=[];
    end
    if maskMode==9
        [~]=setmaskparam(block,maskFxType,maskRollingType,vertType,brakeType);
        varargout{1}=[];
    end
    if maskMode==10
        [~]=setmaskparam(block,maskFxType,maskRollingType,vertType,brakeType);
        varargout{1}=[];
    end
    if maskMode==11
        [~]=setmaskparam(block,maskFxType,maskRollingType,vertType,brakeType);
        varargout{1}=[];
    end
    if maskMode==12
        [~]=setmaskparam(block,maskFxType,maskRollingType,vertType,brakeType);
        varargout{1}=[];
    end
    if maskMode==13
        [~]=setmaskparam(block,maskFxType,maskRollingType,vertType,brakeType);
        varargout{1}=[];
    end
    if maskMode==8
        varargout{1}=DrawCommands(block);
    end

end


function IconInfo=DrawCommands(BlkHdl)

    AliasNames={'BrakePress MPa','BrkPrs';'DriveTorque','DrvTrq'};
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    switch get_param(BlkHdl,'BrakeType')
    case 'None'
        IconInfo.ImageName='wheel_no_brake.png';
    case 'Disc'
        IconInfo.ImageName='wheel_disc_brake.png';
    case 'Drum'
        IconInfo.ImageName='wheel_drum_brake.png';
    case 'Mapped'
        IconInfo.ImageName='wheel_mapped.png';
    end
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,50,'white');
end


function LockStatus=autoblksdrumbrake(block)


    LockStatus=true;

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

    Denominator1=2*mu*(-2*r*sigma-a*(cos(theta1)^2-cos(theta2)^2));

    Denominator2=a*(2*theta1-2*theta2-sin(2*theta1)+sin(2*theta2));

    if(Denominator1+Denominator2)<0,LockStatus=false;end

end

function maskParamInds=setmaskparam(block,maskFxType,maskRollingType,vertType,brakeType)
    paramVec={'press','extPress','NOMPRES','PRESMIN','PRESMAX','gamma','FNOMIN','UNLOADED_RADIUS','LONGVL','lam_Fzo','g','m','zo','zdoto','extGnd','Gndz','Cr','Kt','Fpl','TMIN','TMAX','Tmeas','Tamb','extTamb','lam_x'};
    groupVec={'vertParam','vertMagicParam','vertMappedParam','MagicPeakFxParams','MagicPureFxoParams','MappedFxParam','rollingParam','SimpMyParams','MagicMyParams','MappedMyParams','ISOMyParams','brakeParam','GenParams','DiskBrakeParms','DrumBrakeParms','MappedBrakeParms'};

    rollParamVec=boolean(zeros(length(paramVec),1));
    FxParamVec=rollParamVec;
    KzParamVec=rollParamVec;

    rollGroupVec=boolean(zeros(length(groupVec),1));
    FxGroupVec=rollGroupVec;
    KzGroupVec=rollGroupVec;
    brakeGroupVec=rollGroupVec;
    switch maskRollingType
    case 'None'
    case 'Pressure and velocity'
        rollParamVec([1,2,4,5,8])=true;
        rollGroupVec([7,8])=true;
    case 'Magic Formula'
        rollParamVec(1:8)=true;
        rollGroupVec([7,9])=true;
    case 'Mapped torque'
        rollParamVec(8)=true;
        rollGroupVec([7,10])=true;
    case 'ISO 28580'
        rollParamVec(8)=true;
        rollParamVec(17:end)=true;
        rollGroupVec([7,11])=true;
    end
    switch maskFxType
    case 'Magic Formula constant value'
        FxGroupVec(4)=true;
    case 'Magic Formula pure longitudinal slip'
        FxParamVec(1:10)=true;
        FxParamVec(8)=false;
        FxGroupVec(5)=true;
    case 'Mapped force'
        FxGroupVec(6)=true;
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
    switch brakeType
    case 'None'
    case 'Disc'
        brakeGroupVec([12,13,14])=true;
    case 'Drum'
        brakeGroupVec([12,13,15])=true;
    case 'Mapped'
        brakeGroupVec([12,13,16])=true;
    end
    TambType=get_param(block,'extTamb');
    if strcmp(TambType,'on')
        FxParamVec(23)=false;
        rollParamVec(23)=false;
        KzParamVec(23)=false;
    end
    pressType=get_param(block,'extPress');
    if strcmp(pressType,'on')
        rollParamVec(1)=false;
        FxParamVec(1)=false;
        KzParamVec(1)=false;
    end
    gndType=get_param(block,'extGnd');
    if strcmp(gndType,'on')
        rollParamVec(16)=false;
        FxParamVec(16)=false;
        KzParamVec(16)=false;
    end
    gndType=get_param(block,'extMu');
    if strcmp(gndType,'on')
        FxParamVec(25)=false;
    else
        FxParamVec(25)=true;
    end
    maskParamInds=rollParamVec|FxParamVec|KzParamVec;
    maskGroupInds=rollGroupVec|FxGroupVec|KzGroupVec|brakeGroupVec;
    autoblksenableparameters(block,[],[],groupVec(maskGroupInds),groupVec(~maskGroupInds));
    autoblksenableparameters(block,paramVec(maskParamInds),paramVec(~maskParamInds),[],[],true);
    if~maskParamInds(2)
        set_param(block,'extPress','off')
    end
    if~maskParamInds(24)
        set_param(block,'extTamb','off')
    end
end
function SwitchInport(Block,PortName,UsePort,Param)

    InportOption={'built-in/Constant',[PortName,'Constant'];...
    'built-in/Inport',PortName;...
    'simulink/Sinks/Terminator',[PortName,'Terminator'];...
    'simulink/Sinks/Out1',PortName};
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
    end
end