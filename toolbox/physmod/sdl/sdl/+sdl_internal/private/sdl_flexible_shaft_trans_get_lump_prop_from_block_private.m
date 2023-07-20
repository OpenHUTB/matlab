function[ne_final,L_el_Transverse_vec,zStation_vec,...
    Itors_Global,Dtors_Global,Ktors_Global,...
    MGlobal,MGlobalAlpha,GGlobal,KGlobal,KSupports,Dsupports,FGlobal]=...
    sdl_flexible_shaft_trans_get_lump_prop_from_block_private(blockHandle)





    ne_input=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'n_segments',"1");
    z_support=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'z_support',"m");

    num_supports=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'num_supports',"1");

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
    if num_supports>2
        if boundaryI1==4||boundaryI1==5
            KrotI1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'KrotI1_row',"N*m/rad");
        else
            KrotI1=[0,0];
        end
        if boundaryI1~=1
            DrotI1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'DrotI1_row',"N*m*s/rad");
        else
            DrotI1=[0,0];
        end
        if boundaryI1==4
            KtransI1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'KtransI1_row',"N/m");
            DtransI1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'DtransI1_row',"N*s/m");
        elseif boundaryI1==5
            KtransI1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'KtransI1_w_mat',"N/m");
            DtransI1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'DtransI1_w_mat',"N*s/m");
        else
            KtransI1=[0,0,0,0];
            DtransI1=[0,0,0,0];
        end
    else
        KtransI1=[0,0,0,0];
        DtransI1=[0,0,0,0];
        KrotI1=[0,0];
        DrotI1=[0,0];
    end

    boundaryI2=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'boundaryI2',"1");
    if num_supports>3
        if boundaryI2==4||boundaryI2==5
            KrotI2=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'KrotI2_row',"N*m/rad");
        else
            KrotI2=[0,0];
        end
        if boundaryI2~=1
            DrotI2=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'DrotI2_row',"N*m*s/rad");
        else
            DrotI2=[0,0];
        end
        if boundaryI2==4
            KtransI2=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'KtransI2_row',"N/m");
            DtransI2=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'DtransI2_row',"N*s/m");
        elseif boundaryI2==5
            KtransI2=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'KtransI2_w_mat',"N/m");
            DtransI2=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'DtransI2_w_mat',"N*s/m");
        else
            KtransI2=[0,0,0,0];
            DtransI2=[0,0,0,0];
        end
    else
        KtransI2=[0,0,0,0];
        DtransI2=[0,0,0,0];
        KrotI2=[0,0];
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
        KrotF1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'KrotF1_row',"N*m/rad");
    else
        KrotF1=[0,0];
    end
    if boundaryF1~=1
        DrotF1=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'DrotF1_row',"N*m*s/rad");
    else
        DrotF1=[0,0];
    end


    if boundaryB1==5||boundaryF1==5||...
        (num_supports>=3&&boundaryI1==5)||(num_supports>=4&&boundaryI2==5)
        bearing_speeds_tab=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'bearing_speed',"rad/s");
    else
        bearing_speeds_tab=[];
    end

    offsetMR=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'offsetMR',"kg*m");
    offsetLocation=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'offsetMassLocation',"m");
    offsetInitialAngle=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'offsetMR_initialAngleIN',"rad");

    noDisk=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'noDisk',"1");
    zDisk=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'zDisk',"m");
    if noDisk==sdl.enum.shaftDisks.none
        mDiskIN=0;
        IdDiskIN=0;
        IpDiskIN=0;
    else
        mDiskIN=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'mDiskIn',"kg");
        numDisk=length(mDiskIN);
        if noDisk==sdl.enum.shaftDisks.point
            IdDiskIN=zeros(1,numDisk);
            IpDiskIN=zeros(1,numDisk);
        else
            IdDiskIN=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'IdDiskIn',"kg*m^2");
            IpDiskIN=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'IpDiskIn',"kg*m^2");
        end
    end

    modelTransverse=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'modelTransverse',"1");
    parameterization=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'parameterization',"1");

    if(parameterization==1||parameterization==2)
        shaft_length=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'length',"m");
    else
        shaft_length=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'lengths',"m");
    end

    if parameterization==1
        Itors=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'shaft_inertia',"kg*m^2");
        Ktors=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'shaft_stiffness',"N*m/rad");
    elseif parameterization==3
        Itors=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'shaft_inertias',"kg*m^2");
        Ktors=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'shaft_stiffnesses',"N*m/rad");
    else

        st=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'shaft_construction',"1");
        if st==2
            if parameterization==2
                di=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'diameter_inner',"m");
            else
                di=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'diameter_inners',"m");
            end
        else
            di=0;
        end

        if parameterization==2
            do=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'diameter_outer',"m");
        else
            do=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'diameter_outers',"m");
        end

        rho=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'density',"kg/m^3");
        shear_modulus=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'shear_modulus',"Pa");

        A=pi.*((do./2).^2-(di./2).^2);
        mass=rho*A.*shaft_length;
        polar_moment_inertia=pi/32.*(do.^4-di.^4);

        Itors=mass.*(do.^2+di.^2)/8;
        Ktors=shear_modulus.*polar_moment_inertia./shaft_length;

    end

    if modelTransverse
        if parameterization==1
            rhoA=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'rhoaIN',"kg/m");
            EI=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'eiIN',"N*m^2");
        elseif parameterization==3
            rhoA=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'rhoaINs',"kg/m");
            EI=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'eiINs',"N*m^2");
        else
            rhoA=rho.*A;

            E=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'elastic_modulus',"N/m^2");
            EI=E.*polar_moment_inertia/2;
        end

        if(parameterization==1||parameterization==3)
            mu_visc=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'mu_visc',"N*m*s/rad");
        else
            if modelTransverse
                mu_visc=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'mu_visc',"N*m*s/rad");
            else
                mu_visc=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'mu_visc_BF',"N*m*s/rad");
            end
        end
        damping_ratio=sdl_internal.sdl_flexible_shaft_transverse_get_dialog_box_value(blockHandle,'damping_ratio',"1");



        [ne_final,zStation_vec,L_el_Transverse_vec,...
        Itors_Global,Dtors_Global,Ktors_Global,~,...
        MGlobal,MGlobalAlpha,GGlobal,KGlobal,KSupports,Dsupports,FGlobal,...
        ~,~,...
        ~,~,~,~,~,...
        ~,~,...
        ~,~,...
        ~,~,~,~,...
        errorFlag]=...
        sdl_internal.sdl_flexible_shaft_get_element_properties(modelTransverse,...
        ne_input,[],shaft_length,z_support,num_supports,...
        Itors,Ktors,mu_visc,damping_ratio,...
        EI,rhoA,...
        bearing_speeds_tab,...
        boundaryB1,KtransB1,KrotB1,DtransB1,DrotB1,...
        boundaryI1,KtransI1,KrotI1,DtransI1,DrotI1,...
        boundaryI2,KtransI2,KrotI2,DtransI2,DrotI2,...
        boundaryF1,KtransF1,KrotF1,DtransF1,DrotF1,...
        offsetMR,offsetLocation,offsetInitialAngle,...
        noDisk,zDisk,mDiskIN,IdDiskIN,IpDiskIN);

    end