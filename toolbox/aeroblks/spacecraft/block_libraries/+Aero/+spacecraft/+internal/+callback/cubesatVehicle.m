function varargout=cubesatVehicle(blk,action,varargin)




    if~builtin('license','checkout','Aerospace_Blockset')||...
        ~builtin('license','checkout','Aerospace_Toolbox')
        error(message('spacecraft:cubesat:licenseFailAero'));
    end

    switch action
    case 'init'
        ics=computeICs(varargin);
        [ports,constraintAxes]=handleConstraints(blk);
        switch get_param(blk,'pointingMode')
        case 'Earth (Nadir) Pointing'
            pointing=1;
        case 'Sun Tracking'
            pointing=2;
        case 'Custom Pointing'
            pointing=3;
        otherwise
            pointing=4;
        end
        varargout=[ics,{ports},{constraintAxes},{pointing}];

    case 'circ'
        handleSpecialOrbit(blk);

    case 'method'
        handleMethod(blk);

    case 'pointing'
        handlePointing(blk);

    case 'pointingExt'
        handlePointingExt(blk);

    case 'mission'
        handleMissionAnalysis(blk);
    end
end


function handleSpecialOrbit(blk)
    enable=get_param(blk,'MaskEnables');
    enable(10:12)={'off'};
    enable(7:9)={'on'};
    if strcmp(get_param(blk,'method'),'Keplerian Orbital Elements')
        incl_temp=abs(str2double(get_param(blk,'incl')));
        if abs(str2double(get_param(blk,'ecc')))<1e-12
            if incl_temp<1e-12||abs(incl_temp-pi)<1e-12
                enable(10)={'on'};
                enable(7:9)={'off'};
            else
                enable(11)={'on'};
                enable(8:9)={'off'};
            end
        else
            if incl_temp<1e-12||abs(incl_temp-pi)<1e-12
                enable(12)={'on'};
                enable(7:8)={'off'};
            end
        end
    end
    set_param(blk,'MaskEnables',enable);
end


function handleMethod(blk)
    vis=get_param(blk,'MaskVisibilities');
    vis(3:18)={'off'};
    switch get_param(blk,'method')
    case 'Keplerian Orbital Elements'
        vis(3:12)={'on'};
        handleSpecialOrbit(blk);
    case 'ECI Position and Velocity'
        vis(3)={'on'};
        vis(13:14)={'on'};
    case 'ECEF Position and Velocity'
        vis(15:16)={'on'};
    case 'Geodetic LatLonAlt and Velocity in NED'
        vis(17:18)={'on'};
    end
    set_param(blk,'MaskVisibilities',vis);
end


function handlePointing(blk)
    enable=get_param(blk,'MaskEnables');
    vals=get_param(blk,'MaskValues');
    if strcmp(get_param(blk,'pointingMode'),'Standby (Off)')
        enable(22:30)={'off'};
    elseif any(strcmp(get_param(blk,'pointingMode'),{'Sun Tracking','Earth (Nadir) Pointing'}))
        enable(22:26)={'on'};
        enable(27:28)={'off'};
        enable(29:30)={'on'};
    else
        enable(22:26)={'on'};
        enable(27)={'on'};
        if strcmp(vals(27),'Dialog')
            enable(28)={'on'};
        else
            enable(28)={'off'};
        end
        enable(29:30)={'on'};
    end

    set_param(blk,'MaskEnables',enable);
end


function handlePointingExt(blk)
    enable=get_param(blk,'MaskEnables');
    vals=get_param(blk,'MaskValues');
    for idx=[22,24,27,29]
        if strcmp(enable(idx),'on')&&strcmp(vals(idx),'Dialog')
            enable(idx+1)={'on'};
        else
            enable(idx+1)={'off'};
        end
    end

    set_param(blk,'MaskEnables',enable);
end


function handleMissionAnalysis(blk)
    enable=get_param(blk,'MaskEnables');
    vals=get_param(blk,'MaskValues');
    if strcmp(vals(31),'Dialog')
        enable(32)={'on'};
    else
        enable(32)={'off'};
    end
    if strcmp(vals(34),'on')
        enable(35:36)={'on'};
    else
        enable(35:36)={'off'};
    end
    set_param(blk,'MaskEnables',enable);
end


function icOut=computeICs(dataIn)
    a=dataIn{4};ecc=dataIn{5};incl=dataIn{6};RAAN=dataIn{7};
    argp=dataIn{8};nu=dataIn{9};truelon=dataIn{10};arglat=dataIn{11};
    lonper=dataIn{12};r_ijk=dataIn{13};v_ijk=dataIn{14};r_ecef=dataIn{15};...
    v_ecef=dataIn{16};lla=dataIn{17};v_ned=dataIn{18};euler=dataIn{19};
    pqr=dataIn{20};


    epochDT=datetime(dataIn{3},'convertfrom','juliandate');
    sim_t0DT=datetime(dataIn{2},'convertfrom','juliandate');

    epochVec=Aero.internal.math.createDateVec(epochDT);
    sim_t0Vec=Aero.internal.math.createDateVec(sim_t0DT);


    mjul_simT0=mjuliandate(sim_t0DT);
    dAT=37;
    dUT1=deltaUT1(mjul_simT0);
    pm=polarMotion(mjul_simT0);
    dCIP=deltaCIP(mjul_simT0);
    lod=0;

    switch dataIn{1}
    case 'Keplerian Orbital Elements'

        small=1e-12;
        if(ecc<small)
            if incl<small||abs(incl-pi)<small
                [r_ijk,v_ijk]=keplerian2ijk(a,ecc,incl,0,0,...
                0,'truelon',truelon);
            else
                [r_ijk,v_ijk]=keplerian2ijk(a,ecc,incl,RAAN,0,...
                0,'arglat',arglat);
            end
        else
            if((incl<small)||(abs(incl-pi)<small))
                [r_ijk,v_ijk]=keplerian2ijk(a,ecc,incl,0,0,...
                nu,'lonper',lonper);
            else
                [r_ijk,v_ijk]=keplerian2ijk(a,ecc,incl,RAAN,argp,...
                nu);
            end
        end

        R_ijk2j2000=Aero.spacecraft.transform.internal.dcmMOD2J2000(epochVec,dAT)';
        r_j2000=R_ijk2j2000*r_ijk;
        v_j2000=R_ijk2j2000*v_ijk;

    case 'ECI Position and Velocity'

        R_ijk2j2000=Aero.spacecraft.transform.internal.dcmMOD2J2000(epochVec,dAT)';
        r_j2000=R_ijk2j2000*r_ijk(:);
        v_j2000=R_ijk2j2000*v_ijk(:);

    case 'ECEF Position and Velocity'

        [r_j2000,v_j2000]=ecef2eci(sim_t0Vec,r_ecef,v_ecef,'dAT',dAT,...
        'dUT1',dUT1,'pm',pm,'dCIP',dCIP,'lod',lod);

    case 'Geodetic LatLonAlt and Velocity in NED'

        v_ecef=dcmecef2ned(lla(1),lla(2))'*v_ned(:);

        r_ecef=lla2ecef(lla(:)');

        [r_j2000,v_j2000]=ecef2eci(sim_t0Vec,r_ecef,v_ecef,'dAT',dAT,...
        'dUT1',dUT1,'pm',pm,'dCIP',dCIP,'lod',lod);
    end

    icOut{1}=r_j2000(:)';
    icOut{2}=v_j2000(:)';
    icOut{3}=euler(:)';
    icOut{4}=pqr(:)';
end


function[ports,constraintAxes]=handleConstraints(blk)
    ports=struct('type',{'input','input','input','input','input','output','output','output','output'},...
    'port',{1,1,1,1,1,1,2,3,4},...
    'txt',{'A_{ECEF} (m/s^{2})','','','','','X_{ECEF} (m)','V_{ECEF} (m/s)','q_{ECI2Body}','q_{ECEF2Body}'});

    vals=get_param(blk,'MaskValues');
    extraVals(1)=strcmp(vals(22),'Input port')&&~strcmp(get_param(blk,'pointingMode'),'Standby (Off)');
    extraVals(2)=strcmp(vals(24),'Input port')&&~strcmp(get_param(blk,'pointingMode'),'Standby (Off)');
    extraVals(3)=strcmp(vals(27),'Input port')&&~any(strcmp(get_param(blk,'pointingMode'),{'Sun Tracking','Earth (Nadir) Pointing','Standby (Off)'}));
    extraVals(4)=strcmp(vals(29),'Input port')&&~strcmp(get_param(blk,'pointingMode'),'Standby (Off)');

    extra=[2,3,4,5]';
    extra(~sort(extraVals,'descend'))=[];
    if~isempty(extra)
        extraPorts=ones(4,1)*max(extra);
    else
        extraPorts=ones(4,1)*1;
    end
    extraPorts(1:numel(extra))=extra;

    switch vals{26}
    case 'NED Axes'
        extra={'1^{st} Alignment_{Body}','2^{nd} Alignment_{Body}','1^{st} Constraint_{NED}','2^{nd} Constraint_{NED}'};
        constraintAxes=1;
    case 'ECI Axes'
        extra={'1^{st} Alignment_{Body}','2^{nd} Alignment_{Body}','1^{st} Constraint_{ECI}','2^{nd} Constraint_{ECI}'};
        constraintAxes=2;
    case 'ECEF Axes'
        extra={'1^{st} Alignment_{Body}','2^{nd} Alignment_{Body}','1^{st} Constraint_{ECEF}','2^{nd} Constraint_{ECEF}'};
        constraintAxes=3;
    case 'Body-Fixed Axes'
        extra={'1^{st} Alignment_{Body}','2^{nd} Alignment_{Body}','1^{st} Constraint_{Body}','2^{nd} Constraint_{Body}'};
        constraintAxes=4;
    end

    extra(~extraVals)=[];
    extraStrs={'','','',''};
    extraStrs(1:numel(extra))=extra;

    param={'firstAlign','secondAlign','firstRef','secondRef'};

    jdx=2;
    for idx=1:4
        blockName=blk+"/"+param{idx};
        ports(idx+1).port=extraPorts(idx);
        ports(idx+1).txt=extraStrs{idx};
        if extraVals(idx)
            Aero.internal.maskutilities.addport(blockName,Inport=jdx,DataType="double");
            jdx=jdx+1;
        else
            Aero.internal.maskutilities.addconst(blockName,param{idx});
        end
    end
end
