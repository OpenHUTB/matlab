function[data]=convertAsynchronousSaturation(i_data,v_data,Lls,param_option,connection_option)%#codegen








    coder.allowpcode('plain');



    if connection_option==ee.enum.Connection.delta||connection_option==ee.enum.Connection.delta1
        i_data=i_data/sqrt(3);
    else
        v_data=v_data/sqrt(3);
    end

    if param_option==ee.enum.unit.pu

        if abs(i_data(1))>=eps
            pm_error('physmod:ee:library:ZeroOrigin',getString(message('physmod:ee:library:comments:utils:machines:convertAsynchronousSaturation:error_PerunitNoloadStatorCurrentSaturationDataI')));
        end
        if abs(v_data(1))>=eps
            pm_error('physmod:ee:library:ZeroOrigin',getString(message('physmod:ee:library:comments:utils:machines:convertAsynchronousSaturation:error_PerunitTerminalVoltageSaturationDataV')));
        end


        if any(size(i_data)~=size(v_data))
            pm_error('physmod:simscape:compiler:patterns:checks:LengthEqualLength',getString(message('physmod:ee:library:comments:utils:machines:convertAsynchronousSaturation:error_PerunitNoloadStatorCurrentSaturationDataI')),getString(message('physmod:ee:library:comments:utils:machines:convertAsynchronousSaturation:error_PerunitTerminalVoltageSaturationDataV')));
        end


        vectorMinimumLength=5;
        if length(i_data)<vectorMinimumLength
            pm_error('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',getString(message('physmod:ee:library:comments:utils:machines:convertAsynchronousSaturation:error_PerunitNoloadStatorCurrentSaturationDataI')),num2str(vectorMinimumLength));
        end


        if~issorted(i_data,'strictascend')
            pm_error('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',getString(message('physmod:ee:library:comments:utils:machines:convertAsynchronousSaturation:error_PerunitNoloadStatorCurrentSaturationDataI')));
        end
        if~issorted(v_data,'strictascend')
            pm_error('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',getString(message('physmod:ee:library:comments:utils:machines:convertAsynchronousSaturation:error_PerunitTerminalVoltageSaturationDataV')));
        end



        saturationSegmentGradients=diff(v_data)./diff(i_data);

        if~issorted(saturationSegmentGradients,'strictdescend')
            pm_error('physmod:ee:library:InductionMachineVISaturationSegmentGradients',...
            getString(message('physmod:ee:library:comments:electromech:async:squirrel_cage:base:pu_saturation_i')),...
            getString(message('physmod:ee:library:comments:electromech:async:squirrel_cage:base:pu_saturation_v')));
        end



        Psi_data=v_data-Lls*i_data;
        saturationSegmentGradients=diff(Psi_data)./diff(i_data);
        negativeGradients=find(saturationSegmentGradients<=0);

        if~isempty(negativeGradients)
            pm_error('physmod:ee:library:InductionMachinePsiINegativeGradients',...
            num2str(negativeGradients),...
            getString(message('physmod:ee:library:comments:electromech:async:squirrel_cage:base:pu_Lls')),...
            getString(message('physmod:ee:library:comments:electromech:async:squirrel_cage:base:saturation_i')),...
            getString(message('physmod:ee:library:comments:electromech:async:squirrel_cage:base:saturation_v')));
        end
    else

        if abs(i_data(1))>=eps
            pm_error('physmod:ee:library:ZeroOrigin',getString(message('physmod:ee:library:comments:utils:machines:convertAsynchronousSaturation:error_NoloadStatorCurrentSaturationDataIrms')));
        end
        if abs(v_data(1))>=eps
            pm_error('physmod:ee:library:ZeroOrigin',getString(message('physmod:ee:library:comments:utils:machines:convertAsynchronousSaturation:error_TerminalVoltageSaturationDataVphasephaseRms')));
        end


        if any(size(i_data)~=size(v_data))
            pm_error('physmod:simscape:compiler:patterns:checks:LengthEqualLength',getString(message('physmod:ee:library:comments:utils:machines:convertAsynchronousSaturation:error_NoloadStatorCurrentSaturationDataIrms')),getString(message('physmod:ee:library:comments:utils:machines:convertAsynchronousSaturation:error_TerminalVoltageSaturationDataVphasephaseRms')));
        end


        vectorMinimumLength=5;
        if length(i_data)<vectorMinimumLength
            pm_error('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',getString(message('physmod:ee:library:comments:utils:machines:convertAsynchronousSaturation:error_NoloadStatorCurrentSaturationDataIrms')),num2str(vectorMinimumLength));
        end


        if~issorted(i_data,'strictascend')
            pm_error('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',getString(message('physmod:ee:library:comments:utils:machines:convertAsynchronousSaturation:error_NoloadStatorCurrentSaturationDataIrms')));
        end
        if~issorted(v_data,'strictascend')
            pm_error('physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec',getString(message('physmod:ee:library:comments:utils:machines:convertAsynchronousSaturation:error_TerminalVoltageSaturationDataVphasephaseRms')));
        end



        saturationSegmentGradients=diff(v_data)./diff(i_data);

        if~issorted(saturationSegmentGradients,'strictdescend')
            pm_error('physmod:ee:library:InductionMachineVISaturationSegmentGradients',...
            getString(message('physmod:ee:library:comments:electromech:async:squirrel_cage:base:saturation_i')),...
            getString(message('physmod:ee:library:comments:electromech:async:squirrel_cage:base:saturation_v')));
        end



        Psi_data=v_data-Lls*i_data;
        saturationSegmentGradients=diff(Psi_data)./diff(i_data);
        negativeGradients=find(saturationSegmentGradients<=0);

        if~isempty(negativeGradients)
            pm_error('physmod:ee:library:InductionMachinePsiINegativeGradients',...
            num2str(negativeGradients),...
            getString(message('physmod:ee:library:comments:electromech:async:squirrel_cage:base:Xls')),...
            getString(message('physmod:ee:library:comments:electromech:async:squirrel_cage:base:saturation_i')),...
            getString(message('physmod:ee:library:comments:electromech:async:squirrel_cage:base:saturation_v')));
        end
    end


    data=ee.internal.machines.createEmptyAsynchronousSaturation();
    data.original.i=i_data;
    data.original.v=v_data;



    L_m=data.original.v(2:end)./data.original.i(2:end)-Lls;


    data.original.L_unsaturated=L_m(1);
    data.original.saturated_gradient=diff(data.original.v(end-1:end))./diff(data.original.i(end-1:end));
    data.original.saturated_offset=data.original.v(end)-data.original.saturated_gradient*data.original.i(end);

    unsaturated_base_value=data.original.L_unsaturated;
    number_segment_sections=10;

    unsaturated_i=[min(data.original.i),max(data.original.v)./(data.original.L_unsaturated+Lls)];
    unsaturated_v=unsaturated_i.*(data.original.L_unsaturated+Lls);
    slope_unsaturated=diff(unsaturated_v)./diff(unsaturated_i);





    seg_2_i=data.original.i(2:end-1);
    seg_2_v=data.original.v(2:end-1);


    seg_2_v_interp=linspace(seg_2_v(1),seg_2_v(end),number_segment_sections);
    seg_2_i_interp=interp1(seg_2_v,seg_2_i,seg_2_v_interp,'makima');


    vGap=seg_2_v_interp(2)-seg_2_v_interp(1);
    vMaxN=2;
    seg_3_v=data.original.v(end):vGap:vMaxN*data.original.v(end);
    seg_3_i=(seg_3_v-data.original.saturated_offset)./data.original.saturated_gradient;


    data.derived.i=[data.original.i(1),seg_2_i_interp,seg_3_i];
    data.derived.v=[data.original.v(1),seg_2_v_interp,seg_3_v];

    k=1;
    while k<=3
        slope_vi_derived=diff(data.derived.v)./diff(data.derived.i);
        if~any(slope_vi_derived>slope_unsaturated)
            break
        end
        idx=find(slope_vi_derived>slope_unsaturated);
        data.derived.v(idx+1)=[];
        data.derived.i(idx+1)=[];
        k=k+1;
    end

    data.derived.L_unsaturated=data.original.L_unsaturated;
    data.derived.saturated_gradient=data.original.saturated_gradient;
    data.derived.saturated_offset=data.original.saturated_offset;


    psi_data=data.derived.v-Lls*data.derived.i;
    L_data=data.derived.v./data.derived.i-Lls;
    L_data(1)=L_data(2);
    L_data=L_data.*double(L_data>=0);
    K_s_data=L_data./unsaturated_base_value;

    data.psi=psi_data;
    data.L_m=L_data;
    data.K_s=K_s_data;

end

