function[data]=convertSynchronousSaturation(ifd_data,Vag_data,varargin)%#codegen








    coder.allowpcode('plain');


    if abs(ifd_data(1))>=eps
        pm_error('physmod:ee:library:ZeroOrigin',getString(message('physmod:ee:library:comments:utils:machines:convertSynchronousSaturation:error_PerunitFieldCurrentSaturationDataIfd')));
    end
    if abs(Vag_data(1))>=eps
        pm_error('physmod:ee:library:ZeroOrigin',getString(message('physmod:ee:library:comments:utils:machines:convertSynchronousSaturation:error_PerunitAirgapVoltageSaturationDataVag')));
    end


    if any(size(ifd_data)~=size(Vag_data))
        pm_error('physmod:simscape:compiler:patterns:checks:LengthEqualLength',getString(message('physmod:ee:library:comments:utils:machines:convertSynchronousSaturation:error_PerunitFieldCurrentSaturationDataIfd')),getString(message('physmod:ee:library:comments:utils:machines:convertSynchronousSaturation:error_PerunitAirgapVoltageSaturationDataVag')));
    end


    vectorMinimumLength=5;
    if length(ifd_data)<vectorMinimumLength
        pm_error('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',getString(message('physmod:ee:library:comments:utils:machines:convertSynchronousSaturation:error_PerunitFieldCurrentSaturationDataIfd')),num2str(vectorMinimumLength));
    end


    if~issorted(ifd_data)
        pm_error('physmod:simscape:compiler:patterns:checks:AscendingVec',getString(message('physmod:ee:library:comments:utils:machines:convertSynchronousSaturation:error_PerunitFieldCurrentSaturationDataIfd')));
    end
    if~issorted(Vag_data)
        pm_error('physmod:simscape:compiler:patterns:checks:AscendingVec',getString(message('physmod:ee:library:comments:utils:machines:convertSynchronousSaturation:error_PerunitAirgapVoltageSaturationDataVag')));
    end


    data=ee.internal.machines.createEmptySynchronousSaturation();
    data.original.ifd=ifd_data;
    data.original.Vag=Vag_data;



    L_a=data.original.Vag(2:end)./data.original.ifd(2:end);


    data.original.L_unsaturated=L_a(1);
    data.original.saturated_gradient=diff(data.original.Vag(end-1:end))./diff(data.original.ifd(end-1:end));
    data.original.saturated_offset=data.original.Vag(end)-data.original.saturated_gradient*data.original.ifd(end);

    switch nargin
    case 3
        unsaturated_base_value=varargin{1};
        number_segment_sections=10;
    case 4
        unsaturated_base_value=varargin{1};
        number_segment_sections=varargin{2};
    otherwise
        unsaturated_base_value=data.original.L_unsaturated;
        number_segment_sections=10;
    end

    unsaturated_i=[min(data.original.ifd),max(data.original.Vag)./(data.original.L_unsaturated)];
    unsaturated_v=unsaturated_i.*data.original.L_unsaturated;
    slope_unsaturated=diff(unsaturated_v)./diff(unsaturated_i);





    seg_2_ifd=data.original.ifd(2:end-1);
    seg_2_Vag=data.original.Vag(2:end-1);


    seg_2_Vag_interp=linspace(seg_2_Vag(1),seg_2_Vag(end),number_segment_sections);
    seg_2_ifd_interp=interp1(seg_2_Vag,seg_2_ifd,seg_2_Vag_interp,'makima');


    VagGap=seg_2_Vag_interp(2)-seg_2_Vag_interp(1);
    vagMaxN=2;
    seg_3_Vag=data.original.Vag(end):VagGap:vagMaxN*data.original.Vag(end);
    seg_3_ifd=(seg_3_Vag-data.original.saturated_offset)./data.original.saturated_gradient;


    data.derived.ifd=[data.original.ifd(1),seg_2_ifd_interp,seg_3_ifd];
    data.derived.Vag=[data.original.Vag(1),seg_2_Vag_interp,seg_3_Vag];

    k=1;
    while k<=3
        slope_vi_derived=diff(data.derived.Vag)./diff(data.derived.ifd);
        if~any(slope_vi_derived>slope_unsaturated)
            break
        end
        idx=find(slope_vi_derived>slope_unsaturated);
        data.derived.Vag(idx+1)=[];
        data.derived.ifd(idx+1)=[];
        k=k+1;
    end

    data.derived.L_unsaturated=data.original.L_unsaturated;
    data.derived.saturated_gradient=data.original.saturated_gradient;
    data.derived.saturated_offset=data.original.saturated_offset;


    psi_data=[data.derived.Vag];
    L_data=data.derived.Vag./data.derived.ifd;
    L_data(1)=L_data(2);
    L_data=L_data.*double(L_data>=0);
    K_s_data=L_data./unsaturated_base_value;

    data.psi=psi_data;
    data.L_a=L_data;
    data.K_s=K_s_data;

end

