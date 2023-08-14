function[eigenfrequenciesOut,zshaft,WXOut,WYOut,WTOut,WPOut,...
    Y_realOut,MmodalOut,DmodalOut,GmodalOut,KmodalOut,FmodalOut,...
    V_supportsOut,W_supportsOut,M_supportsKOut,F_supportsKOut,M_supportsDOut,F_supportsDOut,...
    speeds_solve,...
    D_slope,G_slope,K_slope,F_slope,...
    V_supp_slope,W_supp_slope,M_suppK_slope,F_suppK_slope,M_suppD_slope,F_suppD_slope,errorFlag]=...
calculateEigenmodes_anisotropicBearings_private...
    (ModeInputMethod,numModes_Limit,userMode_w,userMode_z,userMode_shapeX,userMode_shapeY,...
    Omega_Nom,Itors,rhoA,EI,L,noDisk,mDisk,zDisk,IdDisk,IpDisk,...
    mode_speed_dependency,bearing_speed,...
    num_supports,z_support,...
    boundaryC,KtransC_all_speeds,KrotC,DtransC_all_speeds,DrotC,...
    boundaryI1,KtransI1_all_speeds,KrotI1,DtransI1_all_speeds,DrotI1,...
    boundaryI2,KtransI2_all_speeds,KrotI2,DtransI2_all_speeds,DrotI2,...
    boundaryR,KtransR_all_speeds,KrotR,DtransR_all_speeds,DrotR,...
    dz,wMax,...
    zForce,ForceMag,ForcePhase)



























































    Rel_dw=1e-3;

    complex_error=0;
    sorting_error=0;


    eigenfrequenciesOut=[];
    WXOut=[];
    WYOut=[];
    WTOut=[];
    WPOut=[];
    Y_realOut=[];
    MmodalOut=[];
    GmodalOut=[];
    DmodalOut=[];
    KmodalOut=[];
    FmodalOut=[];
    V_supportsOut=[];
    W_supportsOut=[];
    M_supportsKOut=[];
    F_supportsKOut=[];
    M_supportsDOut=[];
    F_supportsDOut=[];
    zshaft=[];%#ok<NASGU>

    D_slope=[];
    G_slope=[];
    K_slope=[];
    F_slope=[];
    V_supp_slope=[];
    W_supp_slope=[];
    M_suppK_slope=[];
    F_suppK_slope=[];
    M_suppD_slope=[];
    F_suppD_slope=[];

    try

        if ModeInputMethod==2
            user_shape_error=check_user_mode_dimensions(...
            bearing_speed,L,userMode_w,userMode_z,userMode_shapeX,userMode_shapeY);
        else
            user_shape_error=0;
        end

        if ModeInputMethod==1
            dz_Global=dz;
            zshaft_in=[];
        else
            dz_Global=[];
            zshaft_in=userMode_z;
        end



        [zshaft,support_type,support_node,Ktrans_mat,...
        MGlobal,GGlobal,KGlobal,KSupports_sDep,Dsupports_sDep,FGlobal,...
        V_supportsGlobal,W_supportsGlobal,...
        M_supports_ideal_stiffnessGlobal,F_supports_ideal_stiffnessGlobal,...
        M_supportsK_sDepGlobal,F_supportsK_sDepGlobal,M_supportsD_sDepGlobal,F_supportsD_sDepGlobal]=get_lumped_matrix...
        (ModeInputMethod,dz_Global,zshaft_in,L,z_support,num_supports,...
        Itors,EI,rhoA,...
        bearing_speed,...
        boundaryC,KtransC_all_speeds,KrotC,DtransC_all_speeds,DrotC,...
        boundaryI1,KtransI1_all_speeds,KrotI1,DtransI1_all_speeds,DrotI1,...
        boundaryI2,KtransI2_all_speeds,KrotI2,DtransI2_all_speeds,DrotI2,...
        boundaryR,KtransR_all_speeds,KrotR,DtransR_all_speeds,DrotR,...
        ForceMag,zForce,ForcePhase,...
        noDisk,zDisk,mDisk,IdDisk,IpDisk);



        [speeds_solve,num_speeds]=set_speed_dependency(...
        mode_speed_dependency,num_supports,bearing_speed,Omega_Nom,...
        boundaryC,boundaryI1,boundaryI2,boundaryR);

        for s=1:num_speeds


            DGlobal_s=Dsupports_sDep(:,:,s);
            KTotal_s=KGlobal+KSupports_sDep(:,:,s);

            M_supportsKGlobal=M_supports_ideal_stiffnessGlobal+M_supportsK_sDepGlobal(:,:,s);
            F_supportsKGlobal=F_supports_ideal_stiffnessGlobal+F_supportsK_sDepGlobal(:,:,s);
            M_supportsDGlobal=M_supportsD_sDepGlobal(:,:,s);
            F_supportsDGlobal=F_supportsD_sDepGlobal(:,:,s);


            if ModeInputMethod==1

                [Y_real,eigenfrequencies]=compute_eigenmodes(numModes_Limit,...
                support_type,support_node,MGlobal,KTotal_s,DGlobal_s,GGlobal,FGlobal);

            else

                eigenfrequencies=userMode_w(s,:);

                Ux_s=userMode_shapeX(:,:,s);
                Uy_s=userMode_shapeY(:,:,s);


                Ux_s=interp1(zshaft_in,Ux_s,zshaft);
                Uy_s=interp1(zshaft_in,Uy_s,zshaft);



                Y_real=get_lumped_matrix_UserModes(zshaft,Ux_s,Uy_s,support_node,support_type);



            end









            [Mmodal,Dmodal,Gmodal,Kmodal,Fmodal,Y_real,eigenfrequencies,sorting_error,complex_error]=...
            getModeProperties_Lumped(MGlobal,KTotal_s,DGlobal_s,GGlobal,FGlobal,...
            eigenfrequencies,Y_real,support_type,support_node,...
            WXOut,WYOut,Rel_dw,zshaft,Ktrans_mat(:,:,s));





            [V_supports,W_supports,M_supportsK,F_supportsK,M_supportsD,F_supportsD]=support_responses(...
            V_supportsGlobal,W_supportsGlobal,...
            M_supportsKGlobal,F_supportsKGlobal,M_supportsDGlobal,F_supportsDGlobal,Y_real,...
            ModeInputMethod,support_type,zshaft,z_support,L,EI);



            [eigenfrequenciesOut,WXOut,WYOut,WTOut,WPOut,...
            Y_realOut,MmodalOut,DmodalOut,GmodalOut,KmodalOut,FmodalOut,...
            V_supportsOut,W_supportsOut,M_supportsKOut,F_supportsKOut,M_supportsDOut,F_supportsDOut]=...
formatOutputsAtAllSpeeds...
            (eigenfrequenciesOut,WXOut,WYOut,WTOut,WPOut,...
            Y_realOut,MmodalOut,DmodalOut,GmodalOut,KmodalOut,FmodalOut,...
            V_supportsOut,W_supportsOut,M_supportsKOut,F_supportsKOut,M_supportsDOut,F_supportsDOut,...
            s,num_speeds,wMax,zshaft,num_supports,...
            Mmodal,Dmodal,Gmodal,Kmodal,Fmodal,Y_real,eigenfrequencies,...
            V_supports,W_supports,M_supportsK,F_supportsK,M_supportsD,F_supportsD,...
            ModeInputMethod);


        end


        if num_speeds>1

            [D_slope,G_slope,K_slope,F_slope,...
            V_supp_slope,W_supp_slope,M_suppK_slope,F_suppK_slope,M_suppD_slope,F_suppD_slope]=...
            get_modal_derivatives_wrt_shaft_speed(...
            speeds_solve,...
            DmodalOut,GmodalOut,KmodalOut,FmodalOut,...
            V_supportsOut,W_supportsOut,M_supportsKOut,F_supportsKOut,M_supportsDOut,F_supportsDOut);
        end

        errorFlag=get_errorFlag(user_shape_error,complex_error,sorting_error,0);

    catch ME %#ok<NASGU>

        severe_error=1;
        eigenfrequenciesOut=[];
        WXOut=[];
        WYOut=[];
        WTOut=[];
        WPOut=[];
        Y_realOut=[];
        V_supportsOut=[];
        W_supportsOut=[];
        M_supportsKOut=[];
        F_supportsKOut=[];
        M_supportsDOut=[];
        F_supportsDOut=[];
        zshaft=1;
        speeds_solve=[];

        errorFlag=get_errorFlag(user_shape_error,complex_error,sorting_error,severe_error);

    end

end


function errorFlag=get_errorFlag(user_shape_error,complex_error,sorting_error,severe_error)
    if user_shape_error
        errorFlag=2;
    elseif complex_error
        errorFlag=3;
    elseif sorting_error
        errorFlag=4;
    elseif severe_error
        errorFlag=1;
    else
        errorFlag=0;
    end
end


function errorFlag=check_user_mode_dimensions(bearing_speed,L,userMode_w,userMode_z,userMode_shapeX,userMode_shapeY)

    errorFlag=0;

    try
        if numel(bearing_speed)~=size(userMode_w,1)
            errorFlag=2;
        end

        if isvector(userMode_w)
            if all(size(userMode_shapeX)==[numel(userMode_z),length(userMode_w)])&&...
                all(size(userMode_shapeY)==[numel(userMode_z),length(userMode_w)])

            else
                errorFlag=2;
            end
        else
            if all(size(userMode_shapeY)==[numel(userMode_z),size(userMode_w')])&&...
                all(size(userMode_shapeX)==[numel(userMode_z),size(userMode_w')])

            else
                errorFlag=2;
            end
        end

        if userMode_z(end)~=sum(L)
            errorFlag=2;
        end


    catch ME %#ok<NASGU>
        errorFlag=2;
    end

end


function[speeds_solve,num_speeds]=set_speed_dependency(...
    mode_speed_dependency,numSupports,bearing_speed,Omega_Nom,...
    boundaryC,boundaryI1,boundaryI2,boundaryR)


    if mode_speed_dependency==1&&...
        (boundaryC==5||boundaryR==5||...
        (boundaryI1==5&&numSupports>2)||...
        (boundaryI2==5&&numSupports>3))
        speeds_solve=bearing_speed;
    else
        speeds_solve=Omega_Nom;
    end
    num_speeds=length(speeds_solve);

end



function[Y_out,Yview_out]=separate_Ux_Uy(Y,Yview,Eigenfrequencies,dw,Ktrans_mat)












    Y_out=Y;
    Yview_out=Yview;


    Vx=Yview(1:4:end,:);
    Vy=Yview(2:4:end,:);






    Kxx=Ktrans_mat(:,1);
    Kxy=Ktrans_mat(:,2);
    Kyx=Ktrans_mat(:,3);
    Kyy=Ktrans_mat(:,4);
    if all(Kxx==Kyy)&&all(Kxy==Kyx)





        numEigenmodes=size(Y,2);

        for i=2:numEigenmodes
            lambda2=Eigenfrequencies(i);
            for j=1:i-1
                lambda1=Eigenfrequencies(j);

                if abs(lambda1-lambda2)<dw





                    [~,ind_max]=max(abs(Vx(:,i)));
                    magX1=Vx(ind_max,j);
                    magY1=Vy(ind_max,j);
                    magX2=Vx(ind_max,i);
                    magY2=Vy(ind_max,i);


                    Y_out(:,j)=Y(:,j)-Y(:,i).*magY1./magY2;
                    Yview_out(:,j)=Yview(:,j)-Yview(:,i).*magY1./magY2;


                    Y_out(:,i)=Y(:,i)-Y(:,j).*magX2./magX1;
                    Yview_out(:,i)=Yview(:,i)-Yview(:,j).*magX2./magX1;

                end

            end
        end
    end
end


function[Yn,Yview_n]=normalizeModes(Y,Yview)



    end_disp_dofs=size(Yview,1);
    indX=1:4:end_disp_dofs;
    indY=2:4:end_disp_dofs;
    ind_mode_translation=union(indX,indY);


    Y_translation=Yview(ind_mode_translation,:);
    [~,ind_peak]=max(abs(Y_translation));
    mode_peak=Y_translation(sub2ind(size(Y_translation),ind_peak,1:size(Y_translation,2)));

    numRows=size(Y,1);
    norm_mat=repmat(mode_peak,numRows,1);
    Yn=Y./norm_mat;

    numRows_view=size(Yview,1);
    norm_mat_view=repmat(mode_peak,numRows_view,1);
    Yview_n=Yview./norm_mat_view;

end


function[Yn,Yview_n]=matchModeShapeComplexAnglevsSpeed(Y,Yview,WXOut,WYOut)






    Yn=Y;
    Yview_n=Yview;

    if~isempty(WXOut)




        WX_previous=WXOut(:,:,end);
        WY_previous=WYOut(:,:,end);

        [~,ind_peakX_prev]=max(abs(WX_previous));
        [~,ind_peakY_prev]=max(abs(WY_previous));

        peakX_previous=WX_previous(sub2ind(size(WX_previous),ind_peakX_prev,1:size(WX_previous,2)));
        peakY_previous=WY_previous(sub2ind(size(WY_previous),ind_peakY_prev,1:size(WY_previous,2)));
        useX_as_ref=abs(peakX_previous)>abs(peakY_previous);

        linearInd_peakX_prev=sub2ind(size(WX_previous),ind_peakX_prev,1:size(WX_previous,2));
        linearInd_peakY_prev=sub2ind(size(WY_previous),ind_peakY_prev,1:size(WY_previous,2));



        sign_previous=sign(WX_previous(linearInd_peakX_prev)).*useX_as_ref+...
        sign(WY_previous(linearInd_peakY_prev)).*(1-useX_as_ref);


        end_disp_dofs=size(Yview,1);
        indX=1:4:end_disp_dofs;
        indY=2:4:end_disp_dofs;
        WX=Yview(indX,1:end);
        WY=Yview(indY,1:end);



        sign_current=sign(WX(linearInd_peakX_prev)).*useX_as_ref+...
        sign(WY(linearInd_peakY_prev)).*(1-useX_as_ref);


        multiplication_factor_needed=-1+2*(sign_previous==sign_current);




        Yview_n=Yview_n.*repmat(multiplication_factor_needed,size(Yview_n,1),1);
        Yn=Yn.*repmat(multiplication_factor_needed,size(Yn,1),1);


    end

end



function[zshaft,support_type,support_node,Ktrans_mat,...
    MGlobal,GGlobal,KGlobal,KSupports,Dsupports,FGlobal,...
    V_supports,W_supports,...
    M_supports_ideal_stiffness,F_supports_ideal_stiffness,...
    M_supportsKmat,F_supportsKmat,M_supportsDmat,F_supportsDmat]=get_lumped_matrix...
    (ModeInputMethod,dz,zshaft_input,L,z_support,num_supports,...
    Itors,EI,rhoA,...
    Omega,...
    boundaryC,KtransC,KrotC,DtransC,DrotC,...
    boundaryI1,KtransI1,KrotI1,DtransI1,DrotI1,...
    boundaryI2,KtransI2,KrotI2,DtransI2,DrotI2,...
    boundaryR,KtransR,KrotR,DtransR,DrotR,...
    ForceMag,zForce,ForcePhase,...
    noDisk,zDisk,mDisk,IdDisk,IpDisk)


    modelTransverse=1;

    if ModeInputMethod==1
        n_input=round(sum(L)/dz);
    else
        n_input=[];
    end

    Ktors=Itors;
    mu_visc=0.*z_support;
    damping_ratio=0;


    [~,zshaft,~,...
    ~,~,~,~,...
    MGlobal,~,GGlobal,KGlobal,KSupports,Dsupports,FGlobal,...
    ~,~,...
    support_type,support_node,Ktrans_mat,~,~,...
    V_supports,W_supports,...
    M_supports_ideal_stiffness,F_supports_ideal_stiffness,...
    M_supportsKmat,F_supportsKmat,M_supportsDmat,F_supportsDmat,...
    errorFlag]=...
    sdl_internal.sdl_flexible_shaft_get_element_properties(modelTransverse,...
    n_input,zshaft_input,L,z_support,num_supports,...
    Itors,Ktors,mu_visc,damping_ratio,...
    EI,rhoA,...
    Omega,...
    boundaryC,KtransC,KrotC,DtransC,DrotC,...
    boundaryI1,KtransI1,KrotI1,DtransI1,DrotI1,...
    boundaryI2,KtransI2,KrotI2,DtransI2,DrotI2,...
    boundaryR,KtransR,KrotR,DtransR,DrotR,...
    ForceMag,zForce,ForcePhase,...
    noDisk,zDisk,mDisk,IdDisk,IpDisk);%#ok<ASGLU>

end



function[Vright,Eigenfrequencies]=compute_eigenmodes(numModes_Limit,support_type,support_node,M,K,D,G,F)

    [M,K,~,~,~]=delete_fixed_dofs(support_type,support_node,M,K,D,G,F);








    [Vright,Diag]=eigs(sparse(K),sparse(M),numModes_Limit,'smallestabs');
    Eigenvalues=diag(Diag);




    Vright=real(Vright);
    Eigenfrequencies=real(Eigenvalues).^.5;

end



function[modal_Mass,modal_Damping,modal_Gyroscopics,modal_Stiffness,modal_forcing,...
    Yview,Eigenfrequencies,sorting_error,complex_error]=...
    getModeProperties_Lumped(M,K,D,G,F,...
    Eigenfrequencies,Vright,support_type,support_node,...
    WXOut,WYOut,dw,zshaft,Ktrans_mat)


    Y=Vright;

    if size(M,1)>size(Vright,1)
        [M,K,D,G,F,deleted_dofs]=delete_fixed_dofs(support_type,support_node,M,K,D,G,F);

        Yview=add_fixed_dofs(deleted_dofs,Y);
    else
        Yview=Y;
    end









    [Y,Yview]=separate_Ux_Uy(Y,Yview,Eigenfrequencies,dw,Ktrans_mat);


    [Y,Yview]=normalizeModes(Y,Yview);



    [Y,Yview,Eigenfrequencies,sorting_error]=sortModes(Y,Yview,Eigenfrequencies,WXOut,WYOut,zshaft);




    [Y,Yview]=matchModeShapeComplexAnglevsSpeed(Y,Yview,WXOut,WYOut);







    Z=Y';
    modal_Mass_Temp=Z*M*Y;


    if(rank(modal_Mass_Temp)~=size(modal_Mass_Temp,1))
        complex_error=1;
        modal_Mass=[];
        modal_Damping=[];
        modal_Gyroscopics=[];
        modal_Stiffness=[];
        modal_forcing=[];
    else
        complex_error=0;
        norm_M=inv(modal_Mass_Temp);
        modal_Mass=norm_M*Z*M*Y;%#ok<*MINV>
        modal_Damping=norm_M*Z*D*Y;
        modal_Gyroscopics=norm_M*Z*G*Y;
        modal_Stiffness=norm_M*Z*K*Y;
        modal_forcing=norm_M*Z*F;
    end

end



function[V_supports,W_supports,M_supportsK,F_supportsK,M_supportsD,F_supportsD]=support_responses(...
    V_supportsGlobal,W_supportsGlobal,...
    M_supportsKGlobal,F_supportsKGlobal,M_supportsDGlobal,F_supportsDGlobal,Y,...
    ModeInputMethod,support_type,zshaft,z_support,LSegments,EISegments)




    V_supports=V_supportsGlobal*Y;


    W_supports=W_supportsGlobal*Y;





    M_supportsK=M_supportsKGlobal*Y;
    F_supportsK=F_supportsKGlobal*Y;

    M_supportsD=M_supportsDGlobal*Y;
    F_supportsD=F_supportsDGlobal*Y;


    if ModeInputMethod==2
        numModes=size(Y,2);
        num_supports=numel(support_type);
        for i=1:num_supports
            if support_type(i)==1||support_type(i)==2

                for j=1:numModes

                    F_override=user_modes_ideal_support_force(Y(:,j),zshaft,z_support(i),LSegments,EISegments);
                    F_supportsK(2*i+[-1,0],j)=F_override;
                end
            end
        end
    end


end


function F_supports=user_modes_ideal_support_force(Y,zshaft,z_support,LSegments,EISegments)



    F_supports=zeros(1,2);

    L=sum(LSegments);


    Ux=Y(1:4:end);
    Uy=Y(2:4:end);

    Upx=gradient(Ux,zshaft);
    Upx(1)=interp1(zshaft(2:end-1),Upx(2:end-1),0,'linear','extrap');
    Upx(end)=interp1(zshaft(2:end-1),Upx(2:end-1),L,'linear','extrap');

    Uppx=gradient(Upx,zshaft);
    Uppx(1)=interp1(zshaft(3:end-2),Uppx(3:end-2),0,'linear','extrap');
    Uppx(end)=interp1(zshaft(3:end-2),Uppx(3:end-2),L,'linear','extrap');

    Upppx=gradient(Uppx,zshaft);
    Upppx(1)=interp1(zshaft(4:end-3),Upppx(4:end-3),0,'linear','extrap');
    Upppx(end)=interp1(zshaft(4:end-3),Upppx(4:end-3),L,'linear','extrap');

    Upy=gradient(Uy,zshaft);
    Upy(1)=interp1(zshaft(2:end-1),Upy(2:end-1),0,'linear','extrap');
    Upy(end)=interp1(zshaft(2:end-1),Upy(2:end-1),L,'linear','extrap');

    Uppy=gradient(Upy,zshaft);
    Uppy(1)=interp1(zshaft(3:end-2),Uppy(3:end-2),0,'linear','extrap');
    Uppy(end)=interp1(zshaft(3:end-2),Uppy(3:end-2),L,'linear','extrap');

    Upppy=gradient(Uppy,zshaft);
    Upppy(1)=interp1(zshaft(4:end-3),Upppy(4:end-3),0,'linear','extrap');
    Upppy(end)=interp1(zshaft(4:end-3),Upppy(4:end-3),L,'linear','extrap');



    z_property_change=cumsum(LSegments(1:end-1));
    [~,ind_property_changes,~]=intersect(zshaft,z_property_change);
    if isempty(ind_property_changes)
        EI_along_z=EISegments.*ones(length(zshaft),1);
    else
        EI_along_z=zeros(length(zshaft),1);


        EI_along_z(1:ind_property_changes(1)-1)=EISegments(1);


        EI_along_z(ind_property_changes(end):length(zshaft))=EISegments(end);


        for i=1:length(ind_property_changes)-1
            EI_along_z(ind_property_changes(i):ind_property_changes(i+1)-1)=EISegments(i);
        end
    end



    if z_support==0
        F_support_x=-interp1(zshaft,EI_along_z.*Upppx,z_support);
        F_support_y=-interp1(zshaft,EI_along_z.*Upppy,z_support);
    elseif z_support==zshaft(end)
        F_support_x=interp1(zshaft,EI_along_z.*Upppx,z_support);
        F_support_y=interp1(zshaft,EI_along_z.*Upppy,z_support);
    else
        ind_support=find(zshaft>=z_support,1);



        ind_use=[ind_support-3,ind_support+3];

        EI_use=EI_along_z(ind_use);

        F_support_x_left=EI_use(1)*Upppx(ind_use(1));
        F_support_x_right=-EI_use(2)*Upppx(ind_use(2));
        F_support_y_left=EI_use(1)*Upppy(ind_use(1));
        F_support_y_right=-EI_use(2)*Upppy(ind_use(2));

        F_support_x=F_support_x_left+F_support_x_right;
        F_support_y=F_support_y_left+F_support_y_right;
    end

    F_supports(1)=F_support_x;
    F_supports(2)=F_support_y;

end


function H=get_lumped_matrix_UserModes(zshaft,Ux,Uy,node_supports,support_type)

    num_nodes=length(zshaft);
    num_modes=size(Ux,2);




    [~,Utheta]=gradient(-Uy,1,zshaft);
    [~,Uphi]=gradient(Ux,1,zshaft);

    U1=cat(3,Ux,Uy,Utheta,Uphi);
    U2=permute(U1,[3,1,2]);




    H=reshape(U2,4*num_nodes,num_modes);


    clamped_nodes=node_supports(support_type==1);
    for i=1:length(clamped_nodes)
        zero_rotation_dofs=4.*clamped_nodes(i)-[1,0];
        H(zero_rotation_dofs,:)=0;
    end

end



function[MGlobal,KGlobal,DGlobal,GGlobal,FGlobal,delete_dofs]=delete_fixed_dofs(support_type,node_supports,MGlobal,KGlobal,DGlobal,GGlobal,FGlobal)


    clamped_nodes=node_supports(support_type==1);
    pinned_nodes=node_supports(support_type==2);

    delete_dofs=[];
    for i=1:length(clamped_nodes)
        delete_dofs=[delete_dofs,4*clamped_nodes(i)-[3,2,1,0]];%#ok<AGROW>
    end
    for i=1:length(pinned_nodes)
        delete_dofs=[delete_dofs,4*pinned_nodes(i)-[3,2]];%#ok<AGROW>
    end
    delete_dofs=sort(delete_dofs);


    MGlobal(delete_dofs,:)=[];
    KGlobal(delete_dofs,:)=[];
    DGlobal(delete_dofs,:)=[];
    GGlobal(delete_dofs,:)=[];

    MGlobal(:,delete_dofs)=[];
    KGlobal(:,delete_dofs)=[];
    DGlobal(:,delete_dofs)=[];
    GGlobal(:,delete_dofs)=[];

    FGlobal(delete_dofs,:)=[];
end


function Y=add_fixed_dofs(deleted_dofs,Y)




    numModes=size(Y,2);
    for i=1:length(deleted_dofs)
        numDofs=size(Y,1);

        if deleted_dofs(i)==1
            Y=[zeros(1,numModes)
            Y(1:end,:)];
        elseif deleted_dofs(i)==numDofs
            Y=[Y(1:end,:)
            zeros(1,numModes)];
        else
            Y=[Y(1:deleted_dofs(i)-1,:)
            zeros(1,numModes)
            Y(deleted_dofs(i):end,:)];
        end
    end
end


function[Y,Yview,Eigenfrequencies,match_error]=sortModes(Y,Yview,Eigenfrequencies,WXOut,WYOut,zshaft)






    match_error=0;

    if~isempty(WXOut)


        WX_previous=WXOut(:,:,end);
        WY_previous=WYOut(:,:,end);


        dz=gradient(zshaft)';

        end_disp_dofs=size(Yview,1);
        indX=1:4:end_disp_dofs;
        indY=2:4:end_disp_dofs;
        WX=Yview(indX,1:end);
        WY=Yview(indY,1:end);

        numModes=length(Eigenfrequencies);

        MAC=zeros(numModes,numModes);


        for ind_current_speed=1:numModes
            WXj=real(WX(:,ind_current_speed));
            WYj=real(WY(:,ind_current_speed));

            for ind_prev_speed=1:numModes
                WXi=real(WX_previous(:,ind_prev_speed));
                WYi=real(WY_previous(:,ind_prev_speed));

                CoupledModeMassX=sum(WXi.*WXj.*dz);
                CoupledModeMassY=sum(WYi.*WYj.*dz);



                MAC(ind_prev_speed,ind_current_speed)=abs((CoupledModeMassX)+(CoupledModeMassY));
            end
        end

        [ind_match,match_error]=match_MAC_preferences(MAC);

        if~match_error

            for i=1:numModes
                if ind_match(i)<i


                    Y(:,[i,ind_match(i)])=Y(:,[ind_match(i),i]);
                    Yview(:,[i,ind_match(i)])=Yview(:,[ind_match(i),i]);
                    Eigenfrequencies([i,ind_match(i)])=Eigenfrequencies([ind_match(i),i]);

                end
            end
        end


    end
end



function[ind_match,match_error]=match_MAC_preferences(MAC)














    [~,ind_preferences]=sort(MAC,1,'descend');




    numModes=size(MAC,2);
    ind_match=zeros(1,numModes);
    for m=1:numModes
        ind_match_try=ind_preferences(1,m);
        tryNum=1;
        while any(ind_match==ind_match_try)
            tryNum=tryNum+1;


            ind_match_try=ind_preferences(tryNum,m);
        end
        ind_match(m)=ind_match_try;
    end



    successful_match=all(ind_match(ind_match)==1:numModes);
    match_error=~successful_match;

    if~successful_match





        initial_free_mode=(ind_match(ind_match)~=1:numModes)';
        num_free_modes=sum(initial_free_mode);


        aSingle=ones(1,num_free_modes);
        bSingle=ones(1,num_free_modes);
        ind_match_algo=zeros(1,num_free_modes);

        aPref=MAC(initial_free_mode,initial_free_mode);
        bPref=aPref';



        triedMat=zeros(num_free_modes,num_free_modes);


        ind_match(initial_free_mode)=0;

        while any(aSingle)&&~all(triedMat,'all')

            ind_free_a=find(aSingle);
            num_free_a=length(ind_free_a);
            x=randi(num_free_a,1);
            chosenA=ind_free_a(x);


            notProposed=triedMat(:,chosenA)==0;
            [~,ind_AsFavoriteB]=max(aPref(:,chosenA).*notProposed);


            if bSingle(ind_AsFavoriteB)
                bSingle(ind_AsFavoriteB)=0;
                aSingle(chosenA)=0;
                ind_match_algo(chosenA)=ind_AsFavoriteB;
            else


                otherM=find(ind_match_algo==ind_AsFavoriteB);


                if bPref(ind_AsFavoriteB,otherM)<bPref(ind_AsFavoriteB,chosenA)
                    aSingle(chosenA)=0;
                    aSingle(otherM)=1;
                    ind_match_algo(otherM)=0;
                    ind_match_algo(chosenA)=ind_AsFavoriteB;
                end

            end

            triedMat(ind_AsFavoriteB,chosenA)=1;
        end

        inds_free=find(ind_match==0);
        ind_match(initial_free_mode)=inds_free(ind_match_algo);

        successful_match=all(ind_match(ind_match)==1:numModes);
        match_error=~successful_match;

    end

end


function[D_slope,G_slope,K_slope,F_slope,...
    V_supp_slope,W_supp_slope,M_suppK_slope,F_suppK_slope,M_suppD_slope,F_suppD_slope]=...
    get_modal_derivatives_wrt_shaft_speed(...
    bearing_speed,...
    Dout,Gout,Kout,Fout,...
    V_supportsOut,W_supportsOut,M_supportsKOut,F_supportsKOut,M_supportsDOut,F_supportsDOut)

    num_slope_bkpts=length(bearing_speed)-1;
    s_diff=reshape(diff(bearing_speed),[1,1,num_slope_bkpts]);

    s_diff_sizeM=repmat(s_diff,size(Kout,1),size(Kout,2),1);
    s_diff_sizeF=repmat(s_diff,size(Fout,1),size(Fout,2),1);
    s_diff_sizeV=repmat(s_diff,size(V_supportsOut,1),size(V_supportsOut,2),1);

    D_slope=diff(Dout,1,3)./(s_diff_sizeM);
    G_slope=diff(Gout,1,3)./(s_diff_sizeM);
    K_slope=diff(Kout,1,3)./(s_diff_sizeM);
    F_slope=diff(Fout,1,3)./(s_diff_sizeF);

    V_supp_slope=diff(V_supportsOut,1,3)./(s_diff_sizeV);
    W_supp_slope=diff(W_supportsOut,1,3)./(s_diff_sizeV);
    M_suppK_slope=diff(M_supportsKOut,1,3)./(s_diff_sizeV);
    F_suppK_slope=diff(F_supportsKOut,1,3)./(s_diff_sizeV);
    M_suppD_slope=diff(M_supportsDOut,1,3)./(s_diff_sizeV);
    F_suppD_slope=diff(F_supportsDOut,1,3)./(s_diff_sizeV);




    D_slope=cat(3,D_slope,zeros(size(Kout,1),size(Kout,2),1));
    G_slope=cat(3,G_slope,zeros(size(Kout,1),size(Kout,2),1));
    K_slope=cat(3,K_slope,zeros(size(Kout,1),size(Kout,2),1));
    F_slope=cat(3,F_slope,zeros(size(Fout,1),size(Fout,2),1));

    V_supp_slope=cat(3,V_supp_slope,zeros(size(V_supportsOut,1),size(V_supportsOut,2),1));
    W_supp_slope=cat(3,W_supp_slope,zeros(size(V_supportsOut,1),size(V_supportsOut,2),1));
    M_suppK_slope=cat(3,M_suppK_slope,zeros(size(V_supportsOut,1),size(V_supportsOut,2),1));
    F_suppK_slope=cat(3,F_suppK_slope,zeros(size(V_supportsOut,1),size(V_supportsOut,2),1));
    M_suppD_slope=cat(3,M_suppD_slope,zeros(size(V_supportsOut,1),size(V_supportsOut,2),1));
    F_suppD_slope=cat(3,F_suppD_slope,zeros(size(V_supportsOut,1),size(V_supportsOut,2),1));

end


function[eigenfrequenciesOut,WXOut,WYOut,WTOut,WPOut,...
    Y_realOut,MmodalOut,DmodalOut,GmodalOut,KmodalOut,FmodalOut,...
    V_supportsOut,W_supportsOut,M_supportsKOut,F_supportsKOut,M_supportsDOut,F_supportsDOut]=...
formatOutputsAtAllSpeeds...
    (eigenfrequenciesOut,WXOut,WYOut,WTOut,WPOut,...
    Y_realOut,MmodalOut,DmodalOut,GmodalOut,KmodalOut,FmodalOut,...
    V_supportsOut,W_supportsOut,M_supportsKOut,F_supportsKOut,M_supportsDOut,F_supportsDOut,...
    s,num_speeds,wMax,zshaft,numSupports,...
    Mmodal,Dmodal,Gmodal,Kmodal,Fmodal,Y_real,eigenfrequencies,...
    V_supports,W_supports,M_supportsK,F_supportsK,M_supportsD,F_supportsD,...
    ModeInputMethod)






    numModes=length(eigenfrequencies);

    num_eigenvectors=size(Y_real,2);



    numNodes=size(Y_real,1)/4;



    eigenfrequenciesOut(s,1:numModes)=eigenfrequencies;





    WX=Y_real(1:4:4*numNodes,1:numModes);
    WY=Y_real(2:4:4*numNodes,1:numModes);
    WT=Y_real(3:4:4*numNodes,1:numModes);
    WP=Y_real(4:4:4*numNodes,1:numModes);

    WXOut(1:length(zshaft),1:numModes,s)=WX;
    WYOut(1:length(zshaft),1:numModes,s)=WY;
    WTOut(1:length(zshaft),1:numModes,s)=WT;
    WPOut(1:length(zshaft),1:numModes,s)=WP;




    Y_realOut(1:4*numNodes,1:num_eigenvectors,s)=Y_real;






    MmodalOut(1:numModes,1:numModes)=Mmodal;
    DmodalOut(1:numModes,1:numModes,s)=Dmodal;
    GmodalOut(1:numModes,1:numModes,s)=Gmodal;
    KmodalOut(1:numModes,1:numModes,s)=Kmodal;
    FmodalOut(1:numModes,1:4,s)=Fmodal;

    V_supportsOut(1:2*numSupports,1:numModes,s)=V_supports;
    W_supportsOut(1:2*numSupports,1:numModes,s)=W_supports;
    M_supportsKOut(1:2*numSupports,1:numModes,s)=M_supportsK;
    F_supportsKOut(1:2*numSupports,1:numModes,s)=F_supportsK;
    M_supportsDOut(1:2*numSupports,1:numModes,s)=M_supportsD;
    F_supportsDOut(1:2*numSupports,1:numModes,s)=F_supportsD;

    if s==num_speeds&&ModeInputMethod==1


        [~,mode_index,~]=find(abs(eigenfrequenciesOut)>wMax);
        max_mode_keep=min(mode_index)-1;

        if~isempty(max_mode_keep)
            eigenfrequenciesOut=eigenfrequenciesOut(:,1:max_mode_keep);
            WXOut=WXOut(:,1:max_mode_keep,:);
            WYOut=WYOut(:,1:max_mode_keep,:);
            WTOut=WTOut(:,1:max_mode_keep,:);
            WPOut=WPOut(:,1:max_mode_keep,:);

            indices_keep=1:max_mode_keep;
            Y_realOut=Y_realOut(:,indices_keep,:);
            MmodalOut=MmodalOut(indices_keep,indices_keep);
            KmodalOut=KmodalOut(indices_keep,indices_keep,:);
            DmodalOut=DmodalOut(indices_keep,indices_keep,:);
            GmodalOut=GmodalOut(indices_keep,indices_keep,:);
            FmodalOut=FmodalOut(indices_keep,1:4,:);

            V_supportsOut=V_supportsOut(:,indices_keep,:);
            W_supportsOut=W_supportsOut(:,indices_keep,:);
            M_supportsKOut=M_supportsKOut(:,indices_keep,:);
            F_supportsKOut=F_supportsKOut(:,indices_keep,:);
            M_supportsDOut=M_supportsDOut(:,indices_keep,:);
            F_supportsDOut=F_supportsDOut(:,indices_keep,:);
        end
    end


end

