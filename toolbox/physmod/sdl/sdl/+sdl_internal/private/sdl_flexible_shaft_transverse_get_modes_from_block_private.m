function[WXchoose,WYchoose,zout,eigenfrequencies,shaft_speed]=sdl_flexible_shaft_transverse_get_modes_from_block_private(blockHandle,zChoose,OmegaNomIn)


















    noDisk=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'noDisk',"1");
    if noDisk==1
        mDisk=0;
        zDisk=0;
        IdDisk=0;
        IpDisk=0;
    else
        mDisk=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'mDiskIn',"kg");
        zDisk=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'zDisk',"m");
        if noDisk==3
            IdDisk=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'IdDiskIn',"kg*m^2");
            IpDisk=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'IpDiskIn',"kg*m^2");
        else
            IdDisk=zeros(1,length(zDisk));
            IpDisk=zeros(1,length(zDisk));
        end
    end


    dz=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'dz',"m");
    wMax=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'wMax',"rad/s");






    num_supports=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'num_supports',"1");
    z_support=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'z_support',"m");

    boundaryB1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'boundaryB1',"1");
    if boundaryB1==4
        KtransB1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'KtransB1_row',"N/m");
        DtransB1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'DtransB1_row',"N*s/m");
    elseif boundaryB1==5
        KtransB1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'KtransB1_w_mat',"N/m");
        DtransB1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'DtransB1_w_mat',"N*s/m");
    else
        KtransB1=[0,0,0,0];
        DtransB1=[0,0,0,0];
    end
    if boundaryB1==4||boundaryB1==5
        KrotB1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'KrotB1_row',"N*m/rad");
    else
        KrotB1=[0,0];
    end
    if boundaryB1~=1
        DrotB1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'DrotB1_row',"N*m*s/rad");
    else
        DrotB1=[0,0];
    end

    boundaryI1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'boundaryI1',"1");
    if num_supports>2&&boundaryI1==4
        KtransI1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'KtransI1_row',"N/m");
        DtransI1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'DtransI1_row',"N*s/m");
    elseif num_supports>2&&boundaryI1==5
        KtransI1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'KtransI1_w_mat',"N/m");
        DtransI1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'DtransI1_w_mat',"N*s/m");
    else
        KtransI1=[0,0,0,0];
        DtransI1=[0,0,0,0];
    end
    if num_supports>2&&boundaryI1==4||boundaryI1==5
        KrotI1_row=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'KrotI1_row',"N*m/rad");
        KrotI1=KrotI1_row;
    else
        KrotI1=[0,0];
    end
    if boundaryI1~=1
        DrotI1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'DrotI1_row',"N*m*s/rad");
    else
        DrotI1=[0,0];
    end


    boundaryI2=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'boundaryI2',"1");
    if num_supports>3&&boundaryI2==4
        KtransI2=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'KtransI2_row',"N/m");
        DtransI2=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'DtransI2_row',"N*s/m");
    elseif num_supports>3&&boundaryI2==5
        KtransI2=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'KtransI2_w_mat',"N/m");
        DtransI2=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'DtransI2_w_mat',"N*s/m");
    else
        KtransI2=[0,0,0,0];
        DtransI2=[0,0,0,0];
    end
    if num_supports>3&&boundaryI2==4||boundaryI2==5
        KrotI2_row=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'KrotI2_row',"N*m/rad");
        KrotI2=KrotI2_row;
    else
        KrotI2=[0,0];
    end
    if boundaryI2~=1
        DrotI2=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'DrotI2_row',"N*m*s/rad");
    else
        DrotI2=[0,0];
    end

    boundaryF1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'boundaryF1',"1");
    if boundaryF1==4
        KtransF1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'KtransF1_row',"N/m");
        DtransF1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'DtransF1_row',"N*s/m");
    elseif boundaryF1==5
        KtransF1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'KtransF1_w_mat',"N/m");
        DtransF1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'DtransF1_w_mat',"N*s/m");
    else
        KtransF1=[0,0,0,0];
        DtransF1=[0,0,0,0];
    end
    if boundaryF1==4||boundaryF1==5
        KrotF1_row=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'KrotF1_row',"N*m/rad");
        KrotF1=KrotF1_row;
    else
        KrotF1=[0,0];
    end
    if boundaryF1~=1
        DrotF1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'DrotF1_row',"N*m*s/rad");
    else
        DrotF1=[0,0];
    end


    if isempty(OmegaNomIn)
        OmegaNom=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'OmegaNom',"rad/s");
    else
        OmegaNom=OmegaNomIn;
    end

    zForce=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'offsetMassLocation',"m");



    ForceMag=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'offsetMR',"m*kg");
    ForcePhase=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'offsetMR_initialAngleIN',"rad");


    mode_speed_dependency=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'mode_speed_dependency',"1");
    bearing_speed=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'bearing_speed',"rad/s");

    parameterization=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'parameterization',"1");

    if parameterization==1

        EI=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'eiIN',"m^4*Pa");
        rhoA=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'rhoAIN',"kg/m");
        L=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'length',"m");
        Itors=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'shaft_inertia',"kg*m^2");

    elseif parameterization==3

        EI=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'eiINs',"m^4*Pa");
        rhoA=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'rhoAINs',"kg/m");
        L=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'lengths',"m");
        Itors=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'shaft_inertias',"kg*m^2");

    else

        if parameterization==2
            L=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'length',"m");
        else
            L=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'lengths',"m");
        end

        E=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'elastic_modulus',"Pa");
        rho=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'density',"kg/m^3");

        if parameterization==2
            st=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'shaft_construction',"1");
            if st==2
                di=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'diameter_inner',"m");
            else
                di=0;
            end
            do=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'diameter_outer',"m");
        else
            st=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'shaft_construction',"1");
            if st==2
                di=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'diameter_inners',"m");
            else
                di=0;
            end
            do=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'diameter_outers',"m");
        end

        I=pi/4.*((do./2).^4-(di./2).^4);
        EI=E.*I;

        A=pi.*((do./2).^2-(di./2).^2);
        rhoA=rho.*A;
        Itors=rhoA.*L.*(do.^2+di.^2)/8;
    end

    speed_dependent_modes=boundaryB1==5||boundaryF1==5||...
    (num_supports>=3&&boundaryI1==5)||...
    (num_supports>=4&&boundaryI2==5);

    ModeInputMethod=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'ModeInputMethod',"1");
    if ModeInputMethod==sdl.enum.modeInputMethod.UserDefined
        if speed_dependent_modes
            userMode_w=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'userMode_w_mat',"rad/s");
            userMode_z=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'userMode_z',"m");
            userMode_shapeX=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'userMode_shapeX_mat',"1");
            userMode_shapeY=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'userMode_shapeY_mat',"1");
        else
            userMode_w=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'userMode_w',"rad/s");
            userMode_z=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'userMode_z',"m");
            userMode_shapeX=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'userMode_shapeX',"1");
            userMode_shapeY=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'userMode_shapeY',"1");
        end
    else
        userMode_w=[];
        userMode_z=[];
        userMode_shapeX=[];
        userMode_shapeY=[];
    end

    numModes_Limit=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'numModesIn',"1");

    [eigenfrequencies,zshaft,WX,WY,~,~,...
    ~,~,~,~,~,~,...
    ~,~,~,~,~,~,...
    shaft_speed,...
    ~,~,~,...
    ~,~,~,~,~,~,~]=...
    sdl_internal.calculateEigenmodes_anisotropicBearings...
    (ModeInputMethod,numModes_Limit,userMode_w,userMode_z,userMode_shapeX,userMode_shapeY,...
    OmegaNom,Itors,rhoA,EI,L,noDisk,mDisk,zDisk,IdDisk,IpDisk,...
    mode_speed_dependency,bearing_speed,...
    num_supports,z_support,...
    boundaryB1,KtransB1,KrotB1,DtransB1,DrotB1,...
    boundaryI1,KtransI1,KrotI1,DtransI1,DrotI1,...
    boundaryI2,KtransI2,KrotI2,DtransI2,DrotI2,...
    boundaryF1,KtransF1,KrotF1,DtransF1,DrotF1,...
    dz,wMax,...
    zForce,ForceMag,ForcePhase);

    if isempty(zChoose)
        zout=zshaft;
    else
        zout=zChoose;
    end

    numModes=length(eigenfrequencies);
    if numModes==0
        warning('No mode shapes were found. Rerun simulation to check settings.');
        WXchoose=0.*zout;
        WYchoose=0.*zout;
    elseif isempty(zChoose)

        WXchoose=WX;
        WYchoose=WY;
    else

        WXchoose=interp1(zshaft',WX,zChoose');
        WYchoose=interp1(zshaft',WY,zChoose');
    end

end