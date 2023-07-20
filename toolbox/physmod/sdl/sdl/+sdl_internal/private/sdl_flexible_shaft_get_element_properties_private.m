function[ne_final,zStation_vec,L_fe_vec,...
    Itors_Global,Dtors_Global,Ktors_Global,k_tor_fe_vec,...
    MGlobal,MGlobalAlpha,GGlobal,KGlobal,KSupports,Dsupports,FGlobal,...
    unbalanceMR_vec,unbalance_offset_vec,...
    support_type,support_node,Ktrans_mat,free_DOFs,T_shaft_w_to_Global,...
    V_supports,W_supports,...
    M_supports_ideal_stiffness,F_supports_ideal_stiffness,...
    M_supportsKmat,F_supportsKmat,M_supportsDmat,F_supportsDmat,...
    errorFlag]=...
    sdl_flexible_shaft_get_element_properties_private(modelTransverse,...
    n_input,z_input,shaft_length,z_support,num_supports,...
    Itors,Ktors,mu_visc,damping_ratio,...
    EI,rhoA,...
    bearing_speed,...
    boundaryC,KtransC,KrotC,DtransC,DrotC,...
    boundaryI1,KtransI1,KrotI1,DtransI1,DrotI1,...
    boundaryI2,KtransI2,KrotI2,DtransI2,DrotI2,...
    boundaryR,KtransR,KrotR,DtransR,DrotR,...
    unbalanceMR,zUnbalance,unbalanceInitialAngle,...
    noDisk,zDisk,mDiskIN,IdDiskIN,IpDiskIN)










































    zStation_vec=[];
    L_fe_vec=[];

    Itors_Global=[];
    Dtors_Global=[];
    Ktors_Global=[];
    k_tor_fe_vec=[];

    MGlobal=[];
    MGlobalAlpha=[];
    GGlobal=[];
    KGlobal=[];
    KSupports=[];
    Dsupports=[];
    FGlobal=[];
    unbalanceMR_vec=[];
    unbalance_offset_vec=[];

    support_type=[];
    support_node=[];
    Ktrans_mat=[];
    free_DOFs=[];
    T_shaft_w_to_Global=[];

    V_supports=[];
    W_supports=[];
    M_supports_ideal_stiffness=[];
    F_supports_ideal_stiffness=[];
    M_supportsKmat=[];
    F_supportsKmat=[];
    M_supportsDmat=[];
    F_supportsDmat=[];

    errorFlag=0;


    try

















        [zStation_vec,z_geo_change]=initial_station_locations(n_input,z_input,shaft_length,Itors);






        zStation_vec=...
        add_fixed_stations(z_support,zStation_vec,zUnbalance,zDisk,noDisk,modelTransverse);



        zStation_vec=even_out_segment_lengths(zStation_vec,z_support,z_geo_change,zUnbalance,zDisk,modelTransverse);

        ne_final=length(zStation_vec)-1;
        L_fe_vec=diff(zStation_vec);






        mu_visc_tor_station_vec=torsion_viscous_damping(mu_visc,zStation_vec,z_support);







        [I_tor_segments,I_tor_station_vec,k_tor_fe_vec,d_tor_internal_fe_vec]=torsion_properties(Itors,Ktors,damping_ratio,z_geo_change,zStation_vec);


        [Itors_Global,Dtors_Global,Ktors_Global]=torsion_global_matrices(I_tor_station_vec,k_tor_fe_vec,d_tor_internal_fe_vec,mu_visc_tor_station_vec,ne_final);


        if modelTransverse








            [numSpeeds,support_type,Ktrans_mat,Krot_mat,Dtrans_mat,Drot_mat]=format_bearing_matrices...
            (boundaryC,KtransC,KrotC,DtransC,DrotC,...
            boundaryI1,KtransI1,KrotI1,DtransI1,DrotI1,...
            boundaryI2,KtransI2,KrotI2,DtransI2,DrotI2,...
            boundaryR,KtransR,KrotR,DtransR,DrotR,...
            num_supports);


            [mass_fe_vec,Imass_fe_vec,EI_fe_vec]=bending_properties(EI,rhoA,I_tor_segments,L_fe_vec,z_geo_change,zStation_vec);





            [MGlobal,MGlobalAlpha,GGlobal,KGlobal,KSupports,Dsupports,FGlobal,unbalanceMR_vec,unbalance_offset_vec]=...
            bending_global_matrices(ne_final,mass_fe_vec,Imass_fe_vec,EI_fe_vec,L_fe_vec,zStation_vec,...
            zDisk,noDisk,mDiskIN,IdDiskIN,IpDiskIN,...
            zUnbalance,unbalanceMR,unbalanceInitialAngle,...
            z_support,support_type,Ktrans_mat,Krot_mat,Dtrans_mat,Drot_mat);






            [~,support_node,~]=intersect(zStation_vec,z_support);

            numNodes=ne_final+1;
            numDOFs=4*numNodes;


            free_DOFs=ones(1,numDOFs);
            for i=1:num_supports
                free_DOFs(4*support_node(i)+[-3:0])=0;
            end
            free_DOFs=(1:numDOFs).*free_DOFs;
            free_DOFs(free_DOFs==0)=[];





            T1=eye(numNodes);
            T2=reshape(T1,1,numel(T1));
            T3=repmat(T2,4,1);
            T_shaft_w_to_Global=reshape(T3,numel(T3)/numNodes,numNodes);

            M_supportsKmat=zeros(2*num_supports,numDOFs,numSpeeds);
            F_supportsKmat=zeros(2*num_supports,numDOFs,numSpeeds);
            M_supportsDmat=zeros(2*num_supports,numDOFs,numSpeeds);
            F_supportsDmat=zeros(2*num_supports,numDOFs,numSpeeds);


            [V_supports,W_supports,M_supports_ideal_stiffness,F_supports_ideal_stiffness]=support_responses...
            (zStation_vec,support_node',support_type,num_supports,...
            [],[],L_fe_vec,EI_fe_vec,'Ideal');

            for s=1:numSpeeds



                [~,~,M_supportsK_s,F_supportsK_s]=support_responses...
                (zStation_vec,support_node',support_type,num_supports,...
                Ktrans_mat(:,:,s),Krot_mat(:,:,s),L_fe_vec,EI_fe_vec,'Matrix');




                [~,~,M_supportsD_s,F_supportsD_s]=support_responses...
                (zStation_vec,support_node',support_type,num_supports,...
                Dtrans_mat(:,:,s),Drot_mat(:,:,s),L_fe_vec,EI_fe_vec,'Matrix');

                M_supportsKmat(:,:,s)=M_supportsK_s;
                F_supportsKmat(:,:,s)=F_supportsK_s;
                M_supportsDmat(:,:,s)=M_supportsD_s;
                F_supportsDmat(:,:,s)=F_supportsD_s;
            end

        end



    catch ME %#ok<NASGU>

        ne_final=0;
        errorFlag=1;

    end

end




function[zStation_vec,z_geo_change]=initial_station_locations(ne_input,z_input,shaft_lengths,Itors)


    if shaft_lengths==0

        num_geo_segments=length(Itors);
        num_elements_per_geo_seg=ceil(ne_input/num_geo_segments);
        num_elements=num_elements_per_geo_seg*num_geo_segments;
        num_stations=num_elements+1;
        dz_between_stations=1/num_elements;
        zStation_vec=(0:num_stations-1).*dz_between_stations;
        z_geo_change=(0:num_elements_per_geo_seg:num_elements).*dz_between_stations;


    else

        if~isempty(ne_input)
            zStation_vec=linspace(0,sum(shaft_lengths),ne_input+1);
        else
            zStation_vec=z_input;
        end


        z_geo_change=[0,cumsum(shaft_lengths)];
        zStation_vec=union(zStation_vec,z_geo_change);
    end
end


function[numSpeeds,support_type_input,Ktrans_input,Krot_input,Dtrans_input,Drot_input]=format_bearing_matrices...
    (boundaryC,KtransC,KrotC,DtransC,DrotC,...
    boundaryI1,KtransI1,KrotI1,DtransI1,DrotI1,...
    boundaryI2,KtransI2,KrotI2,DtransI2,DrotI2,...
    boundaryR,KtransR,KrotR,DtransR,DrotR,...
    num_supports)






    numSpeeds_KtransC=size(KtransC,1);
    numSpeeds_KtransR=size(KtransR,1);
    numSpeeds_KtransI1=size(KtransI1,1);
    numSpeeds_KtransI2=size(KtransI2,1);

    numSpeeds=max([numSpeeds_KtransC,numSpeeds_KtransR,numSpeeds_KtransI1,numSpeeds_KtransI2]);



    if numSpeeds_KtransC<numSpeeds
        KtransC=repmat(KtransC,numSpeeds,1);
        DtransC=repmat(DtransC,numSpeeds,1);
    end
    if numSpeeds_KtransR<numSpeeds
        KtransR=repmat(KtransR,numSpeeds,1);
        DtransR=repmat(DtransR,numSpeeds,1);
    end
    if numSpeeds_KtransI1<numSpeeds
        KtransI1=repmat(KtransI1,numSpeeds,1);
        DtransI1=repmat(DtransI1,numSpeeds,1);
    end
    if numSpeeds_KtransI2<numSpeeds
        KtransI2=repmat(KtransI2,numSpeeds,1);
        DtransI2=repmat(DtransI2,numSpeeds,1);
    end


    KtransC=permute(KtransC,[3,2,1]);
    KtransR=permute(KtransR,[3,2,1]);
    KtransI1=permute(KtransI1,[3,2,1]);
    KtransI2=permute(KtransI2,[3,2,1]);

    DtransC=permute(DtransC,[3,2,1]);
    DtransR=permute(DtransR,[3,2,1]);
    DtransI1=permute(DtransI1,[3,2,1]);
    DtransI2=permute(DtransI2,[3,2,1]);

    if num_supports==2
        support_type_input=[boundaryC,boundaryR];

        Krot_input=[KrotC;KrotR];
        Ktrans_input=[KtransC;KtransR];

        Drot_input=[DrotC;DrotR];
        Dtrans_input=[DtransC;DtransR];

    elseif num_supports==3
        support_type_input=[boundaryC,boundaryI1,boundaryR];

        Krot_input=[KrotC;KrotI1;KrotR];
        Ktrans_input=[KtransC;KtransI1;KtransR];

        Drot_input=[DrotC;DrotI1;DrotR];
        Dtrans_input=[DtransC;DtransI1;DtransR];

    else
        support_type_input=[boundaryC,boundaryI1,boundaryI2,boundaryR];

        Krot_input=[KrotC;KrotI1;KrotI2;KrotR];
        Ktrans_input=[KtransC;KtransI1;KtransI2;KtransR];

        Drot_input=[DrotC;DrotI1;DrotI2;DrotR];
        Dtrans_input=[DtransC;DtransI1;DtransI2;DtransR];

    end




    Krot_input=repmat(Krot_input,1,1,numSpeeds);
    Drot_input=repmat(Drot_input,1,1,numSpeeds);

end


function zStation_vec=...
    add_fixed_stations(z_support,zStation_vec,zUnbalance,zDisk,noDisk,modelTransverse)



    zStation_vec=union(zStation_vec,z_support);

    if modelTransverse
        zStation_vec=union(zStation_vec,zUnbalance);
        if noDisk~=1
            zStation_vec=union(zStation_vec,zDisk);
        end
    end

end


function zStation_vec=even_out_segment_lengths(zStation_vec,z_support,z_geo_change,zUnbalance,zDisk,modelTransverse)







    num_stations=length(zStation_vec);
    [~,support_index,~]=intersect(zStation_vec,z_support);
    [~,geo_change_index,~]=intersect(zStation_vec,z_geo_change);

    fixed_station_index=union(support_index,geo_change_index);

    if modelTransverse
        [~,unbalance_index,~]=intersect(zStation_vec,zUnbalance);
        [~,disk_index,~]=intersect(zStation_vec,zDisk);
        fixed_station_index=union(union(fixed_station_index,unbalance_index),disk_index);
    end


    if fixed_station_index(1)~=1
        fixed_station_index=[1;fixed_station_index];
    end
    if fixed_station_index(end)~=num_stations
        fixed_station_index=[fixed_station_index;num_stations];
    end



    for i=1:length(fixed_station_index)-1


        num_free_stations=fixed_station_index(i+1)-fixed_station_index(i)-1;


        zNew=linspace(zStation_vec(fixed_station_index(i)),zStation_vec(fixed_station_index(i+1)),num_free_stations+2);

        zStation_vec(fixed_station_index(i):fixed_station_index(i+1))=zNew;
    end
end


function[I_tor_fe,I_tor_vec,K_tor_vec,d_tor_internal_vec]=torsion_properties(Itors,Ktors,damping_ratio,z_start_geo_segs,zStation_vec)


    num_geo_seg=length(Itors);
    num_stations=length(zStation_vec);

    num_fe=num_stations-1;
    I_tor_fe=zeros(1,num_fe);


    I_tor_vec=zeros(1,num_fe+1);
    K_tor_vec=zeros(1,num_fe+1);


    for i_geo=1:num_geo_seg
        z_start_geo=z_start_geo_segs(i_geo);
        z_end_geo=z_start_geo_segs(min(i_geo+1,num_stations));

        length_geo_seg=z_end_geo-z_start_geo;
        ind_fe_in_this_geo_seg=zStation_vec(1:end-1)>=z_start_geo&zStation_vec(1:end-1)<z_end_geo;
        ind_stations_in_this_geo_seg=zStation_vec>=z_start_geo&zStation_vec<=z_end_geo;
        ind_springs_in_this_geo_seg=zStation_vec>z_start_geo&zStation_vec<=z_end_geo;

        z_stations_in_geo_seg=zStation_vec(ind_stations_in_this_geo_seg);
        fe_lengths_in_geo_seg=diff(z_stations_in_geo_seg);


        el_frac_of_geo_seg=fe_lengths_in_geo_seg./length_geo_seg;

        I_tor_segments_in_this_geo_seg=Itors(i_geo).*el_frac_of_geo_seg;
        K_tor_segments_in_this_geo_seg=Ktors(i_geo)./el_frac_of_geo_seg;


        I_tor_fe(ind_fe_in_this_geo_seg==1)=I_tor_segments_in_this_geo_seg;



        I_tor_half=I_tor_segments_in_this_geo_seg/2;

        I_tor_vec(ind_stations_in_this_geo_seg)=...
        I_tor_vec(ind_stations_in_this_geo_seg)+[I_tor_half,0]+[0,I_tor_half];

        K_tor_vec(ind_springs_in_this_geo_seg)=K_tor_segments_in_this_geo_seg;
    end


    d_tor_internal_vec=[0,2*damping_ratio.*sqrt(K_tor_vec(2:end).*I_tor_fe/2)];

end


function mu_visc_tor_vec=torsion_viscous_damping(mu_visc,zStation_vec,z_support)



    num_stations=length(zStation_vec);

    [~,ind_supports,~]=intersect(zStation_vec,z_support);

    mu_visc_tor_vec=zeros(1,num_stations);
    mu_visc_tor_vec(ind_supports)=mu_visc;

end



function[mass_vec,Imass_vec,EI_vec]=bending_properties(EI,rhoA,I_tor_segments,L_fe_vec,z_start_geo_segs,zStation_vec)



    num_geo_seg=length(rhoA);


    num_segments=length(zStation_vec)-1;
    mass_vec=zeros(1,num_segments);
    EI_vec=zeros(1,num_segments);

    for i_geo=1:num_geo_seg
        z_start=z_start_geo_segs(i_geo);

        if i_geo<num_geo_seg
            z_end=z_start_geo_segs(i_geo+1);
        else
            z_end=zStation_vec(end);
        end


        z_stations_in_geo_seg=zStation_vec(zStation_vec>=z_start&zStation_vec<=z_end);

        lengths_in_geo_seg=diff(z_stations_in_geo_seg);

        mass_segments_in_this_geo_seg=rhoA(i_geo).*lengths_in_geo_seg;
        EI_segments_in_this_geo_seg=EI(i_geo);






        ind_segments_in_geo_seg=zStation_vec>=z_start&zStation_vec<z_end;
        mass_vec(ind_segments_in_geo_seg)=mass_segments_in_this_geo_seg;
        EI_vec(ind_segments_in_geo_seg)=EI_segments_in_this_geo_seg;
    end













    Imass_vec=I_tor_segments./4+mass_vec.*L_fe_vec.^2./24;

end



function[IGlobal,DGlobal,KGlobal]=torsion_global_matrices(I_tor_vec,k_tor_vec,d_tor_internal_vec,mu_visc_tor_vec,ne_final)



    IGlobal=diag(I_tor_vec);

    KGlobal_diag=diag([k_tor_vec(2:end),0])+diag([0,k_tor_vec(2:end)]);

    KGlobal_subDiag=[zeros(1,ne_final+1);
    -diag(k_tor_vec(2:end)),zeros(ne_final,1)];
    KGlobal_aboveDiag=[zeros(ne_final,1),-diag(k_tor_vec(2:end));
    zeros(1,ne_final+1)];

    KGlobal=KGlobal_diag+KGlobal_subDiag+KGlobal_aboveDiag;


    DGlobal_diag=diag([d_tor_internal_vec(2:end),0])+diag([0,d_tor_internal_vec(2:end)]);

    DGlobal_subDiag=[zeros(1,ne_final+1);
    -diag(d_tor_internal_vec(2:end)),zeros(ne_final,1)];
    DGlobal_aboveDiag=[zeros(ne_final,1),-diag(d_tor_internal_vec(2:end));
    zeros(1,ne_final+1)];
    DGlobal_support=diag(mu_visc_tor_vec);

    DGlobal=DGlobal_diag+DGlobal_subDiag+DGlobal_aboveDiag+DGlobal_support;
end


function[MGlobal,MGlobalAlpha,GGlobal,KGlobal,KSupports,DSupports,FGlobal,unbalanceMR_vec,unbalance_offset_vec]=...
    bending_global_matrices(ne,mass_vec,Imass_vec,EI_vec,L_fe_vec,zStation_vec,...
    zDisk,noDisk,mDiskIN,IdDiskIN,IpDiskIN,...
    zUnbalance,unbalanceMR,unbalanceInitialAngle,...
    z_support,support_type,Ktrans_mat,Krot_mat,Dtrans_mat,Drot_mat)










    numNodes=ne+1;
    numDOFs=4*numNodes;
    MGlobal=zeros(numDOFs,numDOFs);
    KGlobal=zeros(numDOFs,numDOFs);
    GGlobal=zeros(numDOFs,numDOFs);



    FGlobal=zeros(numDOFs,4);
    unbalanceMR_vec=zeros(numNodes,1);
    unbalance_offset_vec=zeros(numNodes,1);


    num_speeds=size(Ktrans_mat,3);
    KSupports=zeros(numDOFs,numDOFs,num_speeds);
    DSupports=zeros(numDOFs,numDOFs,num_speeds);


    for i=1:ne
        ind_nodeXC=4*i-3;






        ind_nodePhiR=4*i+4;

        mass_half=0.5*mass_vec(i);
        Imass_half=Imass_vec(i);

        MGlobal(ind_nodeXC:ind_nodePhiR,ind_nodeXC:ind_nodePhiR)=MGlobal(ind_nodeXC:ind_nodePhiR,ind_nodeXC:ind_nodePhiR)+...
        [mass_half,0,0,0,0,0,0,0
        0,mass_half,0,0,0,0,0,0
        0,0,Imass_half,0,0,0,0,0
        0,0,0,Imass_half,0,0,0,0
        0,0,0,0,mass_half,0,0,0
        0,0,0,0,0,mass_half,0,0
        0,0,0,0,0,0,Imass_half,0
        0,0,0,0,0,0,0,Imass_half];

        L_el=L_fe_vec(i);
        EI_el=EI_vec(i);

        KGlobal(ind_nodeXC:ind_nodePhiR,ind_nodeXC:ind_nodePhiR)=KGlobal(ind_nodeXC:ind_nodePhiR,ind_nodeXC:ind_nodePhiR)+...
        2*EI_el/L_el^3.*...
        [6,0,0,3*L_el,-6,0,0,3*L_el
        0,6,-3*L_el,0,0,-6,-3*L_el,0
        0,-3*L_el,2*L_el^2,0,0,3*L_el,L_el^2,0
        3*L_el,0,0,2*L_el^2,-3*L_el,0,0,L_el^2
        -6,0,0,-3*L_el,6,0,0,-3*L_el
        0,-6,3*L_el,0,0,6,3*L_el,0
        0,-3*L_el,L_el^2,0,0,3*L_el,2*L_el^2,0
        3*L_el,0,0,L_el^2,-3*L_el,0,0,2*L_el^2];

    end


    if noDisk==2||noDisk==3

        [~,disk_index,~]=intersect(zStation_vec,zDisk);
        numDisks=length(disk_index);

        for i=1:numDisks

            mDisk=mDiskIN(i);
            JdDisk=IdDiskIN(i);
            JpDisk=IpDiskIN(i);

            ind_nodeX=4*disk_index(i)-3;
            ind_nodePhi=4*disk_index(i);

            MGlobal(ind_nodeX:ind_nodePhi,ind_nodeX:ind_nodePhi)=...
            MGlobal(ind_nodeX:ind_nodePhi,ind_nodeX:ind_nodePhi)+...
            [mDisk,0,0,0
            0,mDisk,0,0
            0,0,JdDisk,0
            0,0,0,JdDisk];

            GGlobal(ind_nodeX:ind_nodePhi,ind_nodeX:ind_nodePhi)=...
            GGlobal(ind_nodeX:ind_nodePhi,ind_nodeX:ind_nodePhi)+...
            [0,0,0,0
            0,0,0,0
            0,0,0,JpDisk
            0,0,-JpDisk,0];

        end
    end


    [~,unbalance_index,~]=intersect(zStation_vec,zUnbalance);
    numUnbalances=length(unbalance_index);

    for i=1:numUnbalances

        ind_nodeX=4*unbalance_index(i)-3;
        ind_nodeY=4*unbalance_index(i)-2;

        phase=unbalanceInitialAngle(i);
        unbalance_mag=unbalanceMR(i);













        FGlobal(ind_nodeX:ind_nodeY,1:4)=...
        FGlobal(ind_nodeX:ind_nodeY,1:4)+...
        unbalance_mag.*...
        [cos(phase),-sin(phase),sin(phase),cos(phase)
        sin(phase),cos(phase),-cos(phase),sin(phase)];


        unbalanceMR_vec(unbalance_index(i))=unbalance_mag;
        unbalance_offset_vec(unbalance_index(i))=phase;

    end


    [~,support_index,~]=intersect(zStation_vec,z_support);
    numSupports=length(z_support);

    for i=1:numSupports

        ind_nodeX=4*support_index(i)-3;
        ind_nodeY=4*support_index(i)-2;
        ind_nodeTheta=4*support_index(i)-1;
        ind_nodePhi=4*support_index(i);

        KSupports(ind_nodeX,ind_nodeX,:)=Ktrans_mat(i,1,:);
        KSupports(ind_nodeX,ind_nodeY,:)=Ktrans_mat(i,2,:);
        KSupports(ind_nodeY,ind_nodeX,:)=Ktrans_mat(i,3,:);
        KSupports(ind_nodeY,ind_nodeY,:)=Ktrans_mat(i,4,:);
        KSupports(ind_nodeTheta,ind_nodeTheta,:)=Krot_mat(i,1,:);
        KSupports(ind_nodePhi,ind_nodePhi,:)=Krot_mat(i,2,:);

        DSupports(ind_nodeX,ind_nodeX,:)=Dtrans_mat(i,1,:);
        DSupports(ind_nodeX,ind_nodeY,:)=Dtrans_mat(i,2,:);
        DSupports(ind_nodeY,ind_nodeX,:)=Dtrans_mat(i,3,:);
        DSupports(ind_nodeY,ind_nodeY,:)=Dtrans_mat(i,4,:);
        DSupports(ind_nodeTheta,ind_nodeTheta,:)=Drot_mat(i,1,:);
        DSupports(ind_nodePhi,ind_nodePhi,:)=Drot_mat(i,2,:);

    end





    MGlobalAlpha=MGlobal;

    for i=1:numSupports

        ind_nodeX=4*support_index(i)-3;
        ind_nodeY=4*support_index(i)-2;

        ind_nodePhi=4*support_index(i);

        if support_type(i)==1

            MGlobal(ind_nodeX:ind_nodePhi,ind_nodeX:ind_nodePhi)=eye(4);
            MGlobalAlpha(ind_nodeX:ind_nodePhi,ind_nodeX:ind_nodePhi)=zeros(4);
            GGlobal(ind_nodeX:ind_nodePhi,:)=zeros(4,numDOFs);
            KGlobal(ind_nodeX:ind_nodePhi,:)=zeros(4,numDOFs);
            FGlobal(ind_nodeX:ind_nodePhi,1:4)=zeros(4,4);
            unbalanceMR_vec(support_index(i))=0;
        elseif support_type(i)==2

            MGlobal(ind_nodeX:ind_nodeY,ind_nodeX:ind_nodeY)=eye(2);
            MGlobalAlpha(ind_nodeX:ind_nodeY,ind_nodeX:ind_nodeY)=zeros(2);
            GGlobal(ind_nodeX:ind_nodeY,:)=zeros(2,numDOFs);
            KGlobal(ind_nodeX:ind_nodeY,:)=zeros(2,numDOFs);
            FGlobal(ind_nodeX:ind_nodeY,1:4)=zeros(2,4);
            unbalanceMR_vec(support_index(i))=0;
        end

    end

end



function[V_supports,W_supports,M_supports,F_supports]=support_responses(zStation_vec,support_node,support_type,num_supports,...
    Ctrans_mat_s,Crot_mat_s,L_els,EIs,type)






    x_support_index=4*support_node-3;
    y_support_index=4*support_node-2;
    thetaX_support_index=4*support_node-1;
    thetaY_support_index=4*support_node;


    num_nodes=length(zStation_vec);



    D=zeros(2*num_supports,4*num_nodes);
    support_VxVy_ind_in_y=union(x_support_index,y_support_index);
    D(sub2ind(size(D),1:2*num_supports,support_VxVy_ind_in_y))=1;
    V_supports=D;



    E=zeros(2*num_supports,4*num_nodes);
    support_WxWy_ind_in_y=union(thetaX_support_index,thetaY_support_index);
    E(sub2ind(size(E),1:2*num_supports,support_WxWy_ind_in_y))=1;
    W_supports=E;


    F_supports=zeros(2*num_supports,4*num_nodes);
    M_supports=zeros(2*num_supports,4*num_nodes);

    if strcmp(type,'Matrix')



        G=zeros(4*num_supports,4*num_nodes);
        support_xythetaXthetaY_in_y=union(union(x_support_index,y_support_index),union(thetaX_support_index,thetaY_support_index));
        G(sub2ind(size(G),1:4*num_supports,support_xythetaXthetaY_in_y))=1;
        X_supports=G;







        J=zeros(2*num_supports,4*num_supports);
        H=zeros(2*num_supports,4*num_supports);
        for i=1:num_supports
            J(2*i-1:2*i,4*i-3:4*i-2)=[Ctrans_mat_s(i,1),Ctrans_mat_s(i,2)
            Ctrans_mat_s(i,3),Ctrans_mat_s(i,4)];
            H(2*i-1:2*i,4*i-1:4*i)=[Crot_mat_s(i,1),0
            0,Crot_mat_s(i,2)];
        end
        F_supports=J*X_supports;
        M_supports=H*X_supports;

    else


        for i=1:num_supports

            if support_type(i)==1||support_type(i)==2


                if support_node(i)~=1




                    X_support_i=zeros(8,4*num_nodes);
                    segment_dofs=4*(support_node(i)-1)-3:4*(support_node(i)-1)+4;
                    X_support_i(sub2ind(size(X_support_i),1:8,segment_dofs))=1;


                    L_el=L_els(support_node(i)-1);
                    EI=EIs(support_node(i)-1);

                    s1pp_L=-6/L_el^2+12/L_el^2;
                    s2pp_L=-4/L_el+6/L_el;
                    s3pp_L=6/L_el^2-12/L_el^2;
                    s4pp_L=6/L_el-2/L_el;

                    s1ppp_L=12/L_el^3;
                    s2ppp_L=6/L_el^2;
                    s3ppp_L=-12/L_el^3;
                    s4ppp_L=6/L_el^2;

                    force_R=EI*[s1ppp_L,0,0,s2ppp_L,s3ppp_L,0,0,s4ppp_L
                    0,s1ppp_L,-s2ppp_L,0,0,s3ppp_L,-s4ppp_L,0];
                    moment_R=[EI*[0,s1pp_L,-s2pp_L,0,0,s3pp_L,-s4pp_L,0]
                    -EI*[s1pp_L,0,0,s2pp_L,s3pp_L,0,0,s4pp_L]];


                    Force_R=force_R*X_support_i;
                    Moment_R=(moment_R*X_support_i).*(support_type(i)~=2);


                    F_supports(2*i-1:2*i,:)=F_supports(2*i-1:2*i,:)+Force_R;
                    M_supports(2*i-1:2*i,:)=M_supports(2*i-1:2*i,:)+Moment_R;
                end


                if support_node(i)~=num_nodes




                    X_support_i=zeros(8,4*num_nodes);
                    segment_dofs=4*support_node(i)-3:4*support_node(i)+4;
                    X_support_i(sub2ind(size(X_support_i),1:8,segment_dofs))=1;


                    L_el=L_els(support_node(i));
                    EI=EIs(support_node(i));

                    s1pp_0=-6/L_el^2;
                    s2pp_0=-4/L_el;
                    s3pp_0=6/L_el^2;
                    s4pp_0=-2/L_el;

                    s1ppp_0=12/L_el^3;
                    s2ppp_0=6/L_el^2;
                    s3ppp_0=-12/L_el^3;
                    s4ppp_0=6/L_el^2;

                    force_C=-EI*[s1ppp_0,0,0,s2ppp_0,s3ppp_0,0,0,s4ppp_0
                    0,s1ppp_0,-s2ppp_0,0,0,s3ppp_0,-s4ppp_0,0];
                    moment_C=[-EI*[0,s1pp_0,-s2pp_0,0,0,s3pp_0,-s4pp_0,0]
                    EI*[s1pp_0,0,0,s2pp_0,s3pp_0,0,0,s4pp_0]];



                    Force_C=force_C*X_support_i;
                    Moment_C=(moment_C*X_support_i).*(support_type(i)~=2);


                    F_supports(2*i-1:2*i,:)=F_supports(2*i-1:2*i,:)+Force_C;
                    M_supports(2*i-1:2*i,:)=M_supports(2*i-1:2*i,:)+Moment_C;

                end
            end
        end
    end
end
