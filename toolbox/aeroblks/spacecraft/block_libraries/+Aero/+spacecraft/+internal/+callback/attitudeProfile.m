function varargout=attitudeProfile(blk,action)




    if~builtin("license","checkout","Aerospace_Blockset")||...
        ~builtin("license","checkout","Aerospace_Toolbox")
        error(message("spacecraft:cubesat:licenseFailAero"));
    end

    switch action
    case "init"

        handleTunables(blk);
        handlePointing(blk);
        timeNeeded=handleFrameChange(blk);
        [ports]=handlePorts(blk,timeNeeded);
        varargout={ports};
    case "pointing"

        handlePointing(blk);
    case "pointingSrc"

        handleVectorSrc(blk);
    case "tunable"

        handleTunables(blk);
        handlePointing(blk);
    case "tunableConditioning"

        handleTunableICRF2ITRFreduc(blk);
    end
end


function handlePointing(blk)
    enable0=get_param(blk,"MaskEnables");
    enable=enable0;
    viz0=get_param(blk,"MaskVisibilities");
    viz=viz0;
    val=get_param(blk,"MaskValues");
    pointingMode=val{2};
    tunablePointing=(val{4}=="on");

    if~tunablePointing
        enable{3}='on';
        switch pointingMode
        case "Point at nadir"
            viz{3}='off';
            enable{10}='off';
            enable{11}='off';
        case "Point at celestial body"
            viz{3}='on';
            enable{10}='off';
            enable{11}='off';
        case "Point at LatLonAlt"
            viz{3}='off';
            enable{10}='off';
            enable{11}='off';
        otherwise
            viz{3}='off';
            enable{10}='on';
            if(val{10}=="Dialog")
                enable{11}='on';
            else
                enable{11}='off';
            end
        end
    else
        if(pointingMode=="Custom")
            enable{3}='off';
            enable{10}='on';
            if val{10}=="Dialog"
                enable{11}='on';
            else
                enable{11}='off';
            end
        elseif(pointingMode=="Point at celestial body")
            enable{3}='on';
            enable{10}='off';
            enable{11}='off';
        else
            enable{3}='off';
            enable{10}='off';
            enable{11}='off';
        end
    end

    if~isequal(enable,enable0)
        set_param(blk,"MaskEnables",enable);
    end
    if~isequal(viz,viz0)
        set_param(blk,"MaskVisibilities",viz);
    end
end


function handleTunables(blk)
    viz=get_param(blk,"MaskVisibilities");
    viz0=viz{3};
    val=get_param(blk,"MaskValues");
    tunables=get_param(blk,"MaskTunableValues");
    tunable0=tunables{2};
    tunablePointing=(val{4}=="on");

    if tunablePointing
        tunables{2}='on';
        viz{3}='on';
        if~strcmp(tunable0,tunables{2})
            set_param(blk,"MaskTunableValues",tunables);
        end
        if~strcmp(viz0,viz{3})
            set_param(blk,"MaskVisibilities",viz);
        end
    else
        tunables{2}='off';
        if~strcmp(tunable0,tunables{2})
            set_param(blk,"MaskTunableValues",tunables);
        end
    end
end


function handleVectorSrc(blk)
    enable0=get_param(blk,"MaskEnables");
    enable=enable0;
    val=get_param(blk,"MaskValues");
    for idx=[5,7,10,12]
        if((enable{idx}=="on")&&...
            (val{idx}=="Dialog"))
            enable{idx+1}='on';
        else
            enable{idx+1}='off';
        end
    end
    if~isequal(enable,enable0)
        set_param(blk,"MaskEnables",enable);
    end
end


function timeNeeded=handleFrameChange(blk)
    val=get_param(blk,"MaskValues");

    vehFrame=val{1};
    tunablePointing=(val{4}=="on");
    pointingMode=val{2};
    constraintFrame=val{9};
    conditioningBlock=blk+"/ConditionAttInputs";
    calcBlock=blk+"/CalcC1";
    reducNeeded=false;
    timeNeeded=false;

    if~(tunablePointing)
        switch pointingMode
        case "Point at nadir"
            updateblock(calcBlock,"Nadir_pointing");

            updateblock(conditioningBlock,"Condition Pass through");
        case "Point at celestial body"
            timeNeeded=true;
            updateblock(calcBlock,"OtherCB_pointing");
            switch vehFrame
            case "ICRF"

                updateblock(conditioningBlock,"Condition Pass through");
            case "Fixed-frame"

                updateblock(conditioningBlock,"Condition ITRF to ICRF");
                reducNeeded=true;
            end
        case "Point at LatLonAlt"
            updateblock(calcBlock,"LatLonAlt_pointing");
            switch vehFrame
            case "ICRF"

                updateblock(conditioningBlock,"Condition ICRF to ITRF");
                reducNeeded=true;
            case "Fixed-frame"

                updateblock(conditioningBlock,"Condition Pass through");
            end
        case "Custom"
            updateblock(calcBlock,"Custom_pointing");

            updateblock(conditioningBlock,"Condition Pass through");
        end


    else


        updateblock(calcBlock,"Tunable_pointing");
        reducNeeded=true;
        switch vehFrame
        case "ICRF"
            updateblock(conditioningBlock,"Condition Pass through");
            set_param(calcBlock,"portFrameIsICRF","on");
        case "Fixed-frame"
            updateblock(conditioningBlock,"Condition Pass through");
            set_param(calcBlock,"portFrameIsICRF","off");
        end
    end


    cframeblock=blk+"/CalcCFrame";
    switch vehFrame
    case "ICRF"
        switch constraintFrame
        case "ICRF"

            updateblock(cframeblock,"invert_q");
        case "Fixed-frame"

            updateblock(cframeblock,"icrf2itrf");
            reducNeeded=true;
        case "LVLH"

            updateblock(cframeblock,"icrf2lvlh");
        case "NED"

            updateblock(cframeblock,"icrf2ned");
            reducNeeded=true;
        case "Body-frame"

            updateblock(cframeblock,"no_rotation");
        end
    case "Fixed-frame"
        switch constraintFrame
        case "ICRF"

            updateblock(cframeblock,"itrf2icrf");
            reducNeeded=true;
        case "Fixed-frame"

            updateblock(cframeblock,"invert_q");
        case "LVLH"

            timeNeeded=true;
            updateblock(cframeblock,"itrf2lvlh");
        case "NED"

            updateblock(cframeblock,"itrf2ned");
        case "Body-frame"

            updateblock(cframeblock,"no_rotation");
        end
    end


    reducblock=blk+"/Reduc";
    if(reducNeeded)
        timeNeeded=true;
        updateblock(reducblock,"iau2000reduc");
    else
        updateblock(reducblock,"no_reduc");
    end


    if(pointingMode=="Point at celestial body")
        set_param(calcBlock,"nTarget",get_param(blk,"celestialTarget"));
    end

end


function[ports]=handlePorts(blk,timeNeeded)


    val=get_param(blk,"MaskValues");
    pointingMode=val{2};
    vehFrame=val{1};
    primAlignSrc=val{5};
    secAlignSrc=val{7};
    constraintFrame=val{9};
    primConstraintSrc=val{10};
    secConstraintSrc=val{12};
    tunablePointing=(val{4}=="on");


    switch vehFrame
    case "ICRF"
        x_in='X_{ icrf} (m)';
        v_in='V_{ icrf} (m/s)';
        q_in='q_{ b2icrf}';
    case "Fixed-frame"
        x_in='X_{ ff} (m)';
        v_in='V_{ ff} (m/s)';
        q_in='q_{ b2ff}';
    end


    ports=struct("type",{'input','input','input','input','input',...
    'input','input','input','input','input','output'},...
    "port",{1,1,1,1,1,1,1,1,1,1,1},...
    "txt",{'','','','','','','','','','','q_{ tgt_{b}}'});



    portVals(1)=timeNeeded;
    portVals(2)=true;
    portVals(3)=(constraintFrame=="LVLH");
    portVals(4)=true;
    portVals(5:6)=((pointingMode=="Point at LatLonAlt")...
    ||tunablePointing);
    portVals(7)=(primAlignSrc=="Port");
    portVals(8)=(secAlignSrc=="Port");
    portVals(9)=(primConstraintSrc=="Port")&&...
    (pointingMode=="Custom");
    portVals(10)=(secConstraintSrc=="Port");
    numPorts=numel(portVals);

    portsActive=(1:numPorts)';
    portsActive(~sort(portVals,"descend"))=[];


    if~isempty(portsActive)
        portIdxVals=ones(numPorts,1)*max(portsActive);
    else
        portIdxVals=ones(numPorts,1);
    end
    portIdxVals(1:numel(portsActive))=portsActive;


    switch constraintFrame
    case "ICRF"
        constraintFrameStr='icrf';
    case "Fixed-frame"
        constraintFrameStr='ff';
    case "LVLH"
        constraintFrameStr='lvlh';
    case "NED"
        constraintFrameStr='ned';
    case "Body-frame"
        constraintFrameStr='b';
    end


    portsActive={'t_{ utc} (JD)',x_in,v_in,q_in,'\mu l (deg)','h (m)','A1_{b}','A2_{b}',...
    ['C1_{',constraintFrameStr,'}'],['C2_{',constraintFrameStr,'}']};


    portsActive(~portVals)=[];
    extraStrs={'','','','','','','','','',''};
    extraStrs(1:numel(portsActive))=portsActive;


    param=["t_utc","X_portFrame","V_portFrame","q_b2portFrame","latlon","alt","primaryAlignment",...
    "secondaryAlignment","primaryConstraint","secondaryConstraint"];
    dimension=["1","3","3","4","2","1","3","3","3","3"];
    units=["inherit","m","m/s","inherit","deg","m","inherit","inherit","inherit","inherit"];


    jdx=1;
    for idx=1:numPorts
        blockName=blk+"/"+param{idx};
        ports(idx).port=portIdxVals(idx);
        ports(idx).txt=extraStrs{idx};
        if portVals(idx)
            Aero.internal.maskutilities.addport(blockName,...
            Inport=jdx,...
            OutUnit=units(idx),...
            Dimensions=dimension(idx));
            jdx=jdx+1;
        else
            if(param(idx)=="latlon")||(param(idx)=="alt")...
                ||(param(idx)=="V_portFrame")||(param(idx)=="X_portFrame")...
                ||(param(idx)=="t_utc")
                Aero.internal.maskutilities.addstub(blockName,"Ground");
            else
                Aero.internal.maskutilities.addconst(blockName,param(idx));
            end
        end
    end

end

function handleTunableICRF2ITRFreduc(blk)



    tunablePointingICRF=blk+"/Tunable Condition to ICRF";
    tunablePointingITRF=blk+"/Tunable Condition to ITRF";

    switch get_param(blk,"portFrameIsICRF")
    case "on"
        updateblock(tunablePointingICRF,"Condition Pass through");
        updateblock(tunablePointingITRF,"Condition ICRF to ITRF");
    case "off"
        updateblock(tunablePointingITRF,"Condition Pass through");
        updateblock(tunablePointingICRF,"Condition ITRF to ICRF");
    end
end

function updateblock(blk,refBlock)

    if~contains(get_param(blk,"ReferenceBlock"),refBlock)
        pos=get_param(blk,"Position");
        delete_block(blk);
        add_block(("aerolibattitudesys/"+refBlock),blk,...
        "Position",pos);
    end
end
