function[switchValues,diodeValues,IGBTValues,nlInductorValues]=utilPejovicReplacement(switchList,diodeList,IGBTList,nlInductorList,inputMap,simscapeModel,A)







    initConditions=simscape.op.create(simscapeModel,'start');

    rsNum=1;

    switchValues=repmat(struct,size(switchList,1),1);

    for i=1:size(switchList,1)

        elecSwitch=switchList{i,1};

        Rs=str2double(switchList{i,2});

        switchName=get_param(elecSwitch,'Name');
        switchFullName=split(elecSwitch,'/');
        switchFullName{1}=simscapeModel;
        elecSwitch=join(switchFullName,'/');
        elecSwitch=elecSwitch{1};


        hswitch=get_param(elecSwitch,'Handle');


        switchPosition=get_param(hswitch,'Position');
        hSPSBlock=backPropegateToConverterSwitch(hswitch);



        switchValues(i).inputNum=findCorrispondingSpsNum(hSPSBlock,inputMap,simscapeModel);


        Simulink.BlockDiagram.createSubsystem([hswitch,hSPSBlock]);
        switchSystem=get_param(hswitch,'Parent');
        hswitchSystem=get_param(switchSystem,'Handle');
        set_param(hswitchSystem,'Position',switchPosition);
        set_param(hswitchSystem,'Name',switchName);

        switchValues(i).handle=hswitchSystem;
        switchValues(i).threshold=utilUnitConversion(slResolve(get_param(hswitch,'Threshold'),hswitch),get_param(hswitch,'Threshold_unit'));
        switchValues(i).R_closed=utilUnitConversion(slResolve(get_param(hswitch,'R_closed'),hswitch),get_param(hswitch,'R_closed_unit'));
        switchValues(i).G_open=utilUnitConversion(slResolve(get_param(hswitch,'G_open'),hswitch),get_param(hswitch,'G_open_unit'));
        opWalker=initConditions;
        for depth=2:size(switchFullName,1)
            opWalker=get(opWalker,switchFullName{depth});
        end
        switchValues(i).initV=get(opWalker,'v').Value;
        switchValues(i).initI=get(opWalker,'i').Value;
        switchValues(i).Rs=Rs;
        rsNum=rsNum+1;

        orientation=get_param(hswitch,'Orientation');
        inputFlip=false;
        if strcmpi(orientation,'up')||strcmpi(orientation,'left')
            inputFlip=true;
        end


        utilLinearizeSwitch(hswitchSystem,switchValues(i),hswitch,hSPSBlock,i,inputFlip);

    end


    diodeValues=repmat(struct,size(diodeList,1),1);

    for i=1:size(diodeList,1)
        diode=diodeList{i,1};
        Rs=str2double(diodeList{i,2});

        diodeName=get_param(diode,'Name');
        diodeFullName=split(diode,'/');
        diodeFullName{1}=simscapeModel;
        diode=join(diodeFullName,'/');
        diode=diode{1};


        hdiode=get_param(diode,'Handle');

        diodePosition=get_param(hdiode,'Position');


        Simulink.BlockDiagram.createSubsystem(hdiode);
        diodeSystem=get_param(hdiode,'Parent');
        hdiodeSystem=get_param(diodeSystem,'Handle');
        set_param(hdiodeSystem,'Position',diodePosition);
        set_param(hdiodeSystem,'Name',diodeName);




        diodeValues(i).Vf=utilUnitConversion(slResolve(get_param(hdiode,'Vf'),hdiode),get_param(hdiode,'Vf_unit'));
        diodeValues(i).Ron=utilUnitConversion(slResolve(get_param(hdiode,'Ron'),hdiode),get_param(hdiode,'Ron_unit'));
        diodeValues(i).Goff=utilUnitConversion(slResolve(get_param(hdiode,'Goff'),hdiode),get_param(hdiode,'Goff_unit'));
        opWalker=initConditions;
        for depth=2:size(diodeFullName,1)
            opWalker=get(opWalker,diodeFullName{depth});
        end
        diodeValues(i).initV=get(opWalker,'v').Value;
        diodeValues(i).initI=get(opWalker,'i').Value;

        diodeValues(i).Rs=Rs;
        rsNum=rsNum+1;

        orientation=get_param(hdiode,'Orientation');
        inputFlip=false;
        if strcmpi(orientation,'up')||strcmpi(orientation,'left')
            inputFlip=true;
        end


        utilLinearizeDiode(hdiodeSystem,diodeValues(i),hdiode,i,inputFlip);

    end
    IGBTValues=repmat(struct,size(IGBTList,1),1);

    for i=1:size(IGBTList,1)
        IGBT=IGBTList{i,1};

        Rs=str2double(IGBTList{i,2});

        IGBTName=get_param(IGBT,'Name');
        IGBTFullName=split(IGBT,'/');
        IGBTFullName{1}=simscapeModel;
        IGBT=join(IGBTFullName,'/');
        IGBT=IGBT{1};


        hIGBT=get_param(IGBT,'Handle');
        IGBTPosition=get_param(hIGBT,'Position');

        hSPSBlock=backPropegateToConverterIGBT(hIGBT);


        IGBTValues(i).inputNum=findCorrispondingSpsNum(hSPSBlock,inputMap,simscapeModel);
        Simulink.BlockDiagram.createSubsystem([hIGBT,hSPSBlock]);
        IGBTSystem=get_param(hIGBT,'Parent');
        hIGBTSystem=get_param(IGBTSystem,'Handle');
        set_param(hIGBTSystem,'Position',IGBTPosition);
        set_param(hIGBTSystem,'Name',IGBTName);
        IGBTValues(i).handle=hIGBTSystem;
        IGBTValues(i).Vf=utilUnitConversion(slResolve(get_param(hIGBT,'Vf'),hIGBT),get_param(hIGBT,'Vf_unit'));
        IGBTValues(i).Ron=utilUnitConversion(slResolve(get_param(hIGBT,'Ron'),hIGBT),get_param(hIGBT,'Ron_unit'));
        IGBTValues(i).Goff=utilUnitConversion(slResolve(get_param(hIGBT,'Goff'),hIGBT),get_param(hIGBT,'Goff_unit'));
        IGBTValues(i).Vt=utilUnitConversion(slResolve(get_param(hIGBT,'Vth'),hIGBT),get_param(hIGBT,'Vth_unit'));
        opWalker=initConditions;
        for depth=2:size(IGBTFullName,1)
            opWalker=get(opWalker,IGBTFullName{depth});
        end
        opWalker=get(opWalker,'ideal_switch');
        IGBTValues(i).initV=get(opWalker,'v').Value;
        IGBTValues(i).initI=get(opWalker,'i').Value;
        IGBTValues(i).Rs=Rs;
        rsNum=rsNum+1;


        utilLinearizeIGBT(hIGBTSystem,IGBTValues(i),hIGBT,hSPSBlock,i);





    end








    nlInductorValues=repmat(struct,size(nlInductorList,1),1);

    for i=1:size(nlInductorList,1)
        nlInductor=nlInductorList{i,1};
        if strcmp(nlInductorList{i,2},'auto')
            Rs=utilCalculateRs(rsNum);
        else
            Rs=str2double(nlInductorList{i,2});
        end
        nlInductorName=get_param(nlInductor,'Name');
        nlInductorFullName=split(nlInductor,'/');
        nlInductorFullName{1}=simscapeModel;
        nlInductor=join(nlInductorFullName,'/');
        nlInductor=nlInductor{1};


        hnlInductor=get_param(nlInductor,'Handle');

        nlInductorPosition=get_param(hnlInductor,'Position');


        Simulink.BlockDiagram.createSubsystem(hnlInductor);
        nlInductorSystem=get_param(hnlInductor,'Parent');
        hnlInductorSystem=get_param(nlInductorSystem,'Handle');
        set_param(hnlInductorSystem,'Position',nlInductorPosition);
        set_param(hnlInductorSystem,'Name',nlInductorName);




        nlInductorValues(i).Nw=utilUnitConversion(slResolve(get_param(hnlInductor,'Nw'),hnlInductor),get_param(hnlInductor,'Nw_unit'));
        nlInductorValues(i).current_data=utilUnitConversion(slResolve(get_param(hnlInductor,'current_data'),hnlInductor),get_param(hnlInductor,'current_data_unit'));
        nlInductorValues(i).magnetic_flux_data=utilUnitConversion(slResolve(get_param(hnlInductor,'magnetic_flux_data'),hnlInductor),get_param(hnlInductor,'magnetic_flux_data_unit'));
        if(strcmp(get_param(nlInductor,'SystemSampleTime'),'-1'))
            nlInductorValues(i).Ts=slResolve(get_param(simscapeModel,'CompiledStepSize'),simscapeModel);
        else
            nlInductorValues(i).Ts=slResolve(get_param(hnlInductor,'SystemSampleTime'),hnlInductor);
        end

        opWalker=initConditions;
        for depth=2:size(nlInductorFullName,1)
            opWalker=get(opWalker,nlInductorFullName{depth});
        end
        nlInductorValues(i).initV=get(opWalker,'inductor/v').Value;
        nlInductorValues(i).initI=get(opWalker,'inductor/i').Value;

        nlInductorValues(i).Rs=Rs;
        rsNum=rsNum+1;

        orientation=get_param(hnlInductor,'Orientation');
        inputFlip=false;
        if strcmpi(orientation,'up')||strcmpi(orientation,'left')
            inputFlip=true;
        end


        utilLinearizeInductor(hnlInductorSystem,nlInductorValues(i),hnlInductor,i,inputFlip);
    end

end

function hSPSBlock=backPropegateToConverterIGBT(hIGBT)
    ports=get_param(hIGBT,'PortHandles');

    if get_param(get_param(ports.LConn(1),'Line'),'DstBlockHandle')==-1
        me=MException('linearize:InvalidPhysicalSystemIn',...
        message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:InvalidPhysicalSystemIn').getString);
        throwAsCaller(me);
    end

    dstBlock=get_param(get_param(get_param(ports.LConn(1),'Line'),'DstBlockHandle'),'ReferenceBlock');
    srcBlock=get_param(get_param(get_param(ports.LConn(1),'Line'),'SrcBlockHandle'),'ReferenceBlock');

    if strcmp(dstBlock,['nesl_utility/Simulink-PS',newline,'Converter'])
        hSPSBlock=get_param(get_param(ports.LConn(1),'Line'),'DstBlockHandle');
    elseif strcmp(srcBlock,['nesl_utility/Simulink-PS',newline,'Converter'])
        hSPSBlock=get_param(get_param(ports.LConn(1),'Line'),'SrcBlockHandle');
    else

        me=MException('linearize:InvalidPhysicalSystemIn',...
        message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:InvalidPhysicalSystemIn').getString);
        throwAsCaller(me);
    end
end

function hSPSBlock=backPropegateToConverterSwitch(hIGBT)
    ports=get_param(hIGBT,'PortHandles');
    if get_param(get_param(ports.RConn(1),'Line'),'DstBlockHandle')~=-1
        hdstBlock=get_param(get_param(ports.RConn(1),'Line'),'DstBlockHandle');
        hsrcBlock=get_param(get_param(ports.RConn(1),'Line'),'SrcBlockHandle');
    elseif get_param(get_param(ports.LConn(1),'Line'),'DstBlockHandle')~=-1
        hdstBlock=get_param(get_param(ports.LConn(1),'Line'),'DstBlockHandle');
        hsrcBlock=get_param(get_param(ports.LConn(1),'Line'),'SrcBlockHandle');

    else
        me=MException('linearize:InvalidPhysicalSystemIn',...
        message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:InvalidPhysicalSystemIn').getString);
        throwAsCaller(me);
    end


    dstBlockRef=get_param(hdstBlock,'ReferenceBlock');
    srcBlockRef=get_param(hsrcBlock,'ReferenceBlock');
    if strcmp(dstBlockRef,['nesl_utility/Simulink-PS',newline,'Converter'])
        hSPSBlock=hdstBlock;
    elseif strcmp(srcBlockRef,['nesl_utility/Simulink-PS',newline,'Converter'])

        hSPSBlock=hsrcBlock;
    else

        me=MException('linearize:InvalidPhysicalSystemIn',...
        message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:InvalidPhysicalSystemIn').getString);
        throwAsCaller(me);

    end
end

function inputNum=findCorrispondingSpsNum(hSPSBlock,spsBlks,simscapeModel)



    inputNum=-1;
    for jj=1:numel(spsBlks)
        spsName=spsBlks{jj};
        spsName=split(spsName,'/');
        spsName{1}=simscapeModel;
        newSpsName=join(spsName,'/');
        if strcmp(getfullname(hSPSBlock),newSpsName{1})
            inputNum=jj;
            continue
        end
    end
end




