function generatecosimtb(this,filterobj,simulator)







    local_checkInstallLoadLibs(filterobj,simulator)

    modelname='untitled';
    h=new_system(modelname,'FromTemplate','factory_default_model');
    open_system(h);
    systemName=getfullname(h);

    bdroot(systemName);
    realizemdl(filterobj,...
    'InputProcessing','elementsaschannels','Rateoption','allowmultirate');

    simlength=(this.InportSrc.datalength);


    whitespace=70;
    baseX=50;
    baseY=300;
    sizeX=125;
    sizeY=50;



    [ratechange,rtsettings,factor_varname,factor_value]=getCosimModelProps(this.HDLFilterComp);


    local_setCosimModelProps(systemName,simlength,factor_varname,factor_value);


    local_setModelWorkSpace(this,systemName,simlength,ratechange,factor_varname,factor_value);


    stimPosition=[baseX,baseY,baseX+sizeX,baseY+sizeY];

    local_createStimulusBlock(systemName,stimPosition,factor_varname);


    resetblkBaseX=baseX+sizeX+whitespace;
    resetBlkBaseY=baseY;

    sizeResetX=ceil(sizeX/4);
    sizeResetY=sizeY;

    resetPosition=[resetblkBaseX,resetBlkBaseY,...
    resetblkBaseX+sizeResetX,...
    resetBlkBaseY+sizeResetY];

    local_createResetLatencyBlock(systemName,resetPosition);


    cosimblkBaseX=resetblkBaseX+sizeResetX+whitespace;
    cosimblkBaseY=resetBlkBaseY;
    sizeCosimX=sizeX;
    sizeCosimY=sizeY;

    cosimPosition=[cosimblkBaseX,cosimblkBaseY,...
    cosimblkBaseX+sizeCosimX,...
    cosimblkBaseY+sizeCosimY];

    tclcmd=local_createCosimBlock(this,systemName,simulator,cosimPosition,factor_varname,factor_value);






    filterblkBaseX=cosimblkBaseX;
    filterblkBaseY=cosimblkBaseY-sizeY-whitespace;

    sizeFilterX=sizeX;
    sizeFilterY=sizeY;

    filterPosition=[filterblkBaseX,filterblkBaseY,...
    filterblkBaseX+sizeFilterX,...
    filterblkBaseY+sizeFilterY];

    local_createFilterBlock(systemName,filterPosition);



    rtsizeX=sizeX/2;
    rtsizeY=sizeY/2;
    rtblkBaseX=filterblkBaseX+sizeX/2-rtsizeX/2;
    rtblkBaseY=filterblkBaseY-98;

    rtPosition=[rtblkBaseX,rtblkBaseY,...
    rtblkBaseX+rtsizeX,rtblkBaseY+rtsizeY];

    local_createRateTransitionBlock(systemName,rtPosition,ratechange,rtsettings)



    latencyblkBaseX=filterblkBaseX+sizeX+whitespace/2;
    latencyblkBaseY=filterblkBaseY;

    sizeLatencyX=sizeX/4;
    sizeLatencyY=sizeY;

    latencyPosition=[latencyblkBaseX,latencyblkBaseY,...
    latencyblkBaseX+sizeLatencyX,...
    latencyblkBaseY+sizeLatencyY];

    local_createHDLLatencyBlock(systemName,latencyPosition);


    if strcmpi(factor_varname,'decimationfactor')


        udenabledBaseX=latencyblkBaseX;
        udenabledBaseY=cosimblkBaseY;
        sizeUdenbX=sizeX/4;
        sizeUdenbY=sizeY;

        udenbPosition=[udenabledBaseX,udenabledBaseY,...
        udenabledBaseX+sizeUdenbX,...
        udenabledBaseY+sizeUdenbY];

        local_createUDEnabledBlock(systemName,udenbPosition);

        dsBaseX=udenabledBaseX+sizeX/4+whitespace/2;
        dsBaseY=udenabledBaseY;
        sizedsX=sizeX/4;
        sizedsY=sizeY;

        dsposition=[dsBaseX,dsBaseY,...
        dsBaseX+sizedsX,...
        dsBaseY+sizedsY];

        local_createDownSampleBlock(systemName,dsposition,factor_value);
    end



    sumblkBaseX=latencyblkBaseX+sizeX/4+whitespace/2;
    sumblkBaseY=cosimblkBaseY-sizeY;

    sizeSumX=30;
    sizeSumY=25;

    errPosition.Sum=[sumblkBaseX,sumblkBaseY,...
    sumblkBaseX+sizeSumX,sumblkBaseY+sizeSumY];


    absblkBaseX=sumblkBaseX+sizeSumX+whitespace/2;
    absblkBaseY=sumblkBaseY;
    sizeAbsX=sizeSumX;
    sizeAbsY=sizeSumY;

    errPosition.Abs=[absblkBaseX,absblkBaseY,...
    absblkBaseX+sizeAbsX,absblkBaseY+sizeAbsY];

    errmginblkBaseX=absblkBaseX+sizeSumX+whitespace/2;
    errmginblkBaseY=absblkBaseY;

    sizeErrMgnX=5*sizeSumX;
    sizeErrMgnY=sizeSumY;

    errPosition.ErrorMargin=[errmginblkBaseX,errmginblkBaseY,...
    (errmginblkBaseX+sizeErrMgnX),errmginblkBaseY+sizeErrMgnY];

    local_createErrorCheckingBlocks(this,systemName,errPosition);


    sizescopeX=50;
    sizescopeY=90;

    scopeblkBaseX=errmginblkBaseX+sizeErrMgnX+whitespace;
    scopeblkBaseY=filterblkBaseY-sizescopeY;

    scopePosition=[scopeblkBaseX,scopeblkBaseY,...
    scopeblkBaseX+sizescopeX,scopeblkBaseY+sizescopeY];

    local_createScopeBlock(systemName,scopePosition);


    local_wireAllBlocks(systemName,ratechange,factor_varname);



    noteBaseX=latencyblkBaseX;
    noteBaseY=cosimblkBaseY+sizeY/2+whitespace/3;

    sizeNoteX=100;
    sizeNoteY=50;
    notePosition=[noteBaseX,noteBaseY,noteBaseX+sizeNoteX,noteBaseY+sizeNoteY];

    local_createAnnotation(systemName,notePosition,simulator,tclcmd);

    set_param(systemName,'Location','[10, 10, 1050, 475]');



    function local_setCosimModelProps(systemName,simlength,factor_varname,factor_value)

        if strcmpi(factor_varname,'interpolationfactor')
            stoptime=[num2str(simlength),'*Ts*',factor_varname];
        elseif strcmpi(factor_varname,'decimationfactor')
            stoptime=[num2str(simlength+factor_value),'*Ts'];


        else
            stoptime=[num2str(simlength),'*Ts'];
        end
        set_param(systemName,...
        'Solver','fixedstepdiscrete',...
        'StartTime','0.0',...
        'StopTime',stoptime,...
        'SampleTimeColors','on',...
        'ShowLineDimensions','on',...
        'ShowLineWidths','on',...
        'ShowPortDataTypes','on',...
        'SolverMode','SingleTasking');


        function local_createStimulusBlock(systemName,position,factor_varname)
            blk_path=[systemName,'/','Test Stimulus'];

            blklibname='built-in/FromWorkspace';
            add_block(blklibname,...
            blk_path,...
            'Position',position);


            set_param(blk_path,'Interpolate','off');
            set_param(blk_path,'OutputAfterFinalValue','Setting to zero');
            srcCmd='inputdata';
            set_param(blk_path,'VariableName',srcCmd);
            if strcmpi(factor_varname,'interpolationfactor')
                set_param(blk_path,'SampleTime',['Ts*',factor_varname]);
            else
                set_param(blk_path,'SampleTime','Ts');
            end


            function local_setModelWorkSpace(this,systemName,simlength,ratechange,factor_varname,factor_value)


                hws=get_param(systemName,'modelworkspace');
                hws.DataSource='Model File';

                clkperiod=hdlgetparameter('force_clock_low_time')+hdlgetparameter('force_clock_high_time');
                Ts=clkperiod*hdlgetparameter('foldingfactor');

                hws.assignin('Ts',Ts);


                inputdata.time=(0:Ts:simlength*Ts-Ts)';
                inputdata.signals.values=this.InportSrc.data;

                if strcmpi(factor_varname,'decimationfactor')
                    resettime=factor_value*clkperiod+hdlgetparameter('force_hold_time');
                elseif strcmpi(factor_varname,'interpolationfactor')
                    resettime=factor_value*clkperiod+hdlgetparameter('force_hold_time');
                else
                    resettime=hdlgetparameter('resetlength')*clkperiod+hdlgetparameter('force_hold_time');
                end
                clkenabletime=resettime+hdlgetparameter('testbenchclockenabledelay')*clkperiod;
                resetlat=floor(clkenabletime/clkperiod);


                if ratechange
                    tbenbdelay=hdlgetparameter('testbenchclockenabledelay');
                    if tbenbdelay~=1
                        warning(message('hdlfilter:filterhdlcoder:HDLTestbench:generatecosimtb:TbClkenbDelayNotSuppForCosimModel',num2str(tbenbdelay)));
                    end
                    rstleng=hdlgetparameter('resetlength');
                    if rstleng~=2
                        warning(message('hdlfilter:filterhdlcoder:HDLTestbench:generatecosimtb:RstLengthNotSuppForCosimModel',num2str(rstleng)));
                    end
                    hws.assignin(factor_varname,factor_value)
                    if strcmpi(factor_varname,'decimationfactor')



                        if hdlgetparameter('filter_registered_input')&&hdlgetparameter('filter_registered_output')
                            lat=20+Ts*factor_value+10;


                        else


                            lat=20+(Ts*factor_value-10)+10;
                        end
                        lat=lat+hdlgetparameter('filter_excess_latency')*10;

                        lat=ceil(lat/(Ts*factor_value));
                        lat=lat-1;


                        resetlat=factor_value;


                    else
                        [~,lat]=latency(this.HDLFilterComp);



                        resetlat=2;

                        inputdata.time=(0:factor_value*Ts:simlength*Ts*factor_value-factor_value*Ts)';
                        inputdata.signals.values=this.InportSrc.data;
                    end
                else
                    lat=latency(this.hdlfilterComp);
                end
                hws.assignin('latency',lat);

                hws.assignin('inputdata',inputdata);


                hws.assignin('resetdelay',resetlat);





                hws.assignin('ErrMarginBits',hdlgetparameter('error_margin'));


                function local_createResetLatencyBlock(systemName,position)

                    resetLatBlk=[systemName,'/','Reset Delay'];
                    blklibname='simulink/Discrete/Integer Delay';

                    add_block(blklibname,...
                    resetLatBlk,...
                    'Position',position);

                    set_param(resetLatBlk,'NumDelays','resetdelay');

                    function tclcmd=local_createCosimBlock(this,systemName,simulator,position,factor_varname,factor_value)

                        switch simulator
                        case 'modelsim'
                            blklibname='modelsimlib/HDL Cosimulation';
                        case 'incisive'
                            blklibname='lfilinklib/HDL Cosimulation';
                        end

                        cosimblkname=[systemName,'/','HDL Cosimulation'];

                        add_block(blklibname,...
                        cosimblkname,...
                        'Position',position);


                        tclcmd=local_setupCosimBlk(this,simulator,cosimblkname,factor_varname,factor_value);

                        set_param(cosimblkname,...
                        'Position',position);

                        function local_createFilterBlock(systemName,position)


                            filterblk=[systemName,'/','Filter'];
                            while isempty(find_system(systemName,'SearchDepth',1,'BlockType','SubSystem'))
date
                            end
                            set_param(filterblk,'Position',position);


                            function local_createHDLLatencyBlock(systemName,position)




                                latencyBlk=[systemName,'/','HDL Latency'];
                                blklibname='simulink/Discrete/Integer Delay';

                                add_block(blklibname,...
                                latencyBlk,...
                                'Position',position);

                                set_param(latencyBlk,'NumDelays','latency');


                                function local_createErrorCheckingBlocks(this,systemName,position)

                                    blk_path=[systemName,'/','Error'];
                                    blklibname='built-in/Sum';

                                    add_block(blklibname,...
                                    blk_path,...
                                    'Position',position.Sum);


                                    set_param(blk_path,'IconShape','round');
                                    set_param(blk_path,'listofsigns','||+|-');

                                    set_param(blk_path,'OutDataTypeStr','Inherit: Same as accumulator');
                                    set_param(blk_path,'NamePlacement','alternate');


                                    blk_path=[systemName,'/','Abs'];
                                    blklibname='built-in/Abs';

                                    add_block(blklibname,...
                                    blk_path,...
                                    'Position',position.Abs);


                                    blk_path=[systemName,'/','Error Margin'];
                                    blklibname=['simulink/Logic and Bit',char(10),'Operations/Compare',char(10),'To Constant'];

                                    add_block(blklibname,...
                                    blk_path,...
                                    'Position',position.ErrorMargin);


                                    outputall=hdlgetallfromsltype(this.OutportSnk(1).PortSLType);

                                    if strcmpi(outputall.vtype,'real')
                                        compareConst=this.doubleErrorMargin;
                                    else
                                        if this.fixedPointErrorMargin~=0
                                            compareConst=['(2^ErrMarginBits-1)*(2^',num2str(-outputall.bp),')'];
                                        else
                                            compareConst=0;
                                        end
                                    end

                                    set_param(blk_path,'const',num2str(compareConst));
                                    set_param(blk_path,'relop','<');

                                    function local_createScopeBlock(systemName,position)

                                        blk_path=[systemName,'/','Scope'];
                                        blklibname='built-in/Scope';

                                        add_block(blklibname,...
                                        blk_path,...
                                        'Position',position);

                                        set_param(blk_path,'NumInputPorts','5');
                                        axistitles.axes1='Input Stimulus';
                                        axistitles.axes2='Output from behavioral model';
                                        axistitles.axes3='Output from HDL Cosimulation';
                                        axistitles.axes4='Error';
                                        axistitles.axes5='Error within margin';
                                        set_param(blk_path,'AxesTitles',axistitles);


                                        scopeblkHndl=get_param(blk_path,'Handle');
                                        set_param(blk_path,'Open','on');

                                        ScopeConfig=get_param(scopeblkHndl,'ScopeConfiguration');
                                        ScopeConfig.Position=[50,0,700,650];

                                        drawnow;
                                        set_param(blk_path,'Open','off');

                                        function local_createRateTransitionBlock(systemName,position,ratechange,rtsettings)

                                            if ratechange
                                                blk_path=[systemName,'/','Rate Transition'];
                                                blklibname='built-in/RateTransition';
                                                add_block(blklibname,...
                                                blk_path,...
                                                'Position',position);

                                                set_param(blk_path,rtsettings{:});
                                            end

                                            function local_wireAllBlocks(systemName,ratechange,factor_varname)


                                                add_line(systemName,'Test Stimulus/1','Reset Delay/1','autorouting','on');

                                                add_line(systemName,'Reset Delay/1','HDL Cosimulation/1','autorouting','on');
                                                add_line(systemName,'Reset Delay/1','Filter/1','autorouting','on');

                                                add_line(systemName,'Filter/1','HDL Latency/1','autorouting','on');

                                                if~ratechange
                                                    add_line(systemName,'Test Stimulus/1','Scope/1','autorouting','on');
                                                else
                                                    add_line(systemName,'Test Stimulus/1','Rate Transition/1','autorouting','on');
                                                    add_line(systemName,'Rate Transition/1','Scope/1','autorouting','on');
                                                end

                                                add_line(systemName,'HDL Latency/1','Error/1','autorouting','on');

                                                hLine=add_line(systemName,'HDL Latency/1','Scope/2');
                                                pts=get_param(hLine,'Points');
                                                set_param(hLine,'Points',[pts(1,:);...
                                                pts(1,1),pts(end,2);
                                                pts(end,:)]);
                                                if strcmpi(factor_varname,'decimationfactor')
                                                    add_line(systemName,'HDL Cosimulation/1','Output Delay/1','autorouting','on');
                                                    add_line(systemName,'HDL Cosimulation/2','Output Delay/2','autorouting','on');
                                                    add_line(systemName,'Output Delay/1','DownSample/1','autorouting','on');
                                                    add_line(systemName,'DownSample/1','Error/2','autorouting','on');
                                                    hLine=add_line(systemName,'DownSample/1','Scope/3');
                                                else
                                                    add_line(systemName,'HDL Cosimulation/1','Error/2','autorouting','on');
                                                    hLine=add_line(systemName,'HDL Cosimulation/1','Scope/3');
                                                end

                                                pts=get_param(hLine,'Points');
                                                set_param(hLine,'Points',[pts(1,:);...
                                                pts(end-1,1)-10,pts(1,2);
                                                pts(end-1,1)-10,pts(end-1,2);
                                                pts(end,:)]);
                                                add_line(systemName,'Error/1','Abs/1','autorouting','on');

                                                add_line(systemName,'Error/1','Scope/4','autorouting','on');

                                                add_line(systemName,'Abs/1','Error Margin/1','autorouting','on');

                                                add_line(systemName,'Error Margin/1','Scope/5','autorouting','on');



                                                function local_createUDEnabledBlock(systemName,position)

                                                    blk_path=[systemName,'/','Output Delay'];
                                                    blklibname=['simulink/Additional Math',char(10),...
                                                    '& Discrete/Additional',char(10),...
                                                    'Discrete/Unit Delay',char(10),...
                                                    'Enabled'];
                                                    add_block(blklibname,...
                                                    blk_path,...
                                                    'Position',position);


                                                    function local_createDownSampleBlock(systemName,position,factor_value)

                                                        blk_path=[systemName,'/','DownSample'];
                                                        blklibname='dspsigops/Downsample';
                                                        add_block(blklibname,...
                                                        blk_path,...
                                                        'Position',position);
                                                        set_param(blk_path,'N',num2str(factor_value));
                                                        set_param(blk_path,'InputProcessing','Elements as channels (sample based)');
                                                        set_param(blk_path,'RateOptions','Allow multirate processing');


                                                        function local_createAnnotation(systemName,position,simulator,tclcmd)

                                                            blk_path=[systemName,'/','  Start HDL Simulator  '];
                                                            blklibname='built-in/Note';

                                                            add_block(blklibname,...
                                                            blk_path,...
                                                            'Position',position);


                                                            tclcmdstr='    {';
                                                            for n=1:length(tclcmd)
                                                                if n==length(tclcmd)
                                                                    tclcmdstr=[tclcmdstr,'    ''',tclcmd{n},'''}'];
                                                                else
                                                                    tclcmdstr=[tclcmdstr,'    ''',tclcmd{n},''', ...',char(10)];
                                                                end
                                                            end
                                                            switch simulator
                                                            case 'modelsim'
                                                                hdlsimulatorstartfcn=['vsim(''tclstart'' , ...',char(10),tclcmdstr,')'];
                                                            case 'incisive'
                                                                hdlsimulatorstartfcn=['nclaunch(''tclstart'' , ...',char(10),tclcmdstr,')'];
                                                            end


                                                            set_param(blk_path,'clickFcn',hdlsimulatorstartfcn);
                                                            set_param(blk_path,'fontweight','bold');
                                                            set_param(blk_path,'backgroundcolor','cyan');
                                                            set_param(blk_path,'dropShadow','on')
                                                            set_param(blk_path,'FontSize',18);

                                                            function tclcmd=local_setupCosimBlk(this,simulator,cosimblkname,factor_varname,factor_value)




                                                                clkname=hdlgetparameter('clockname');
                                                                clk_enable=hdlgetparameter('clockenablename');
                                                                reset=hdlgetparameter('resetname');

                                                                nname=hdlgetparameter('filter_name');
                                                                entityfilename=[nname,...
                                                                hdlgetparameter('filename_suffix')];
                                                                pathstr=fileparts(fullfile(hdlGetCodegendir,entityfilename));
                                                                entitynameforuser=fullfile(pathstr,entityfilename);







                                                                tmpdir=fileparts(entitynameforuser);

                                                                top=CosimBlkAttributes(this);
                                                                lang=hdlgetparameter('target_language');

                                                                PortPaths='';
                                                                PortModes='';
                                                                PortTimes='';
                                                                PortSigns='';
                                                                PortFracLengths='';

                                                                simcmd={};
                                                                portnames={};
                                                                for m=1:length(this.InPortSrc)
                                                                    port=this.InPortSrc(m);
                                                                    portName=port.HDLPortName;
                                                                    for ii=1:length(portName)
                                                                        name=portName{ii};
                                                                        if~iscell(name)
                                                                            name={name};
                                                                        end
                                                                        for jj=1:length(name)
                                                                            PortPaths=[PortPaths,'/',top,'/',name{jj},';'];
                                                                            simcmd=[simcmd,['sim:/',top,'/',name{jj}]];
                                                                            portnames=[portnames,name{jj}];
                                                                            PortModes=[PortModes,'1 '];
                                                                            PortTimes=[PortTimes,'-1 '];
                                                                            PortSigns=[PortSigns,'-1 '];
                                                                            PortFracLengths=[PortFracLengths,'0,'];
                                                                        end
                                                                    end
                                                                end



                                                                if strcmpi(factor_varname,'decimationfactor')
                                                                    temport=this.OutPortSnk;
                                                                    ceoutname=hdlgetparameter('clockenableoutputname');
                                                                    temport.HDLPortName={ceoutname};
                                                                    temport.loggingPortName=ceoutname;

                                                                    temport.PortSLType='boolean';
                                                                    temport.PortVType=hdlgetparameter('base_data_type');

                                                                    this.OutPortSnk=[this.OutPortSnk,temport];
                                                                end

                                                                for m=1:length(this.OutPortSnk)
                                                                    port=this.OutPortSnk(m);
                                                                    [~,bp,sign]=hdlgetsizesfromtype(port.PortSLType);
                                                                    portName=port.HDLPortName;
                                                                    for ii=1:length(portName)
                                                                        name=portName{ii};
                                                                        if~iscell(name)
                                                                            name={name};
                                                                        end
                                                                        for jj=1:length(name)
                                                                            PortPaths=[PortPaths,'/',top,'/',name{jj},';'];
                                                                            simcmd=[simcmd,['sim:/',top,'/',name{jj},' ']];
                                                                            portnames=[portnames,name{jj}];
                                                                            PortFracLengths=[PortFracLengths,sprintf('%d,',bp)];
                                                                            PortModes=[PortModes,'2 '];
                                                                            PortTimes=[PortTimes,'Ts '];
                                                                            PortSigns=[PortSigns,sprintf('%d ',sign)];
                                                                        end
                                                                    end
                                                                end


                                                                PortPaths=PortPaths(1:end-1);

                                                                PortModes=['[',PortModes,']'];
                                                                PortTimes=['[',PortTimes,']'];
                                                                PortSigns=['[',PortSigns,']'];
                                                                PortFracLengths=['[',PortFracLengths(1:end-1),']'];
                                                                clkperiod=hdlgetparameter('force_clock_low_time')+hdlgetparameter('force_clock_high_time');

                                                                if strcmpi(factor_varname,'decimationfactor')
                                                                    resettime=factor_value*clkperiod+hdlgetparameter('force_hold_time');
                                                                elseif strcmpi(factor_varname,'interpolationfactor')
                                                                    resettime=factor_value*clkperiod+hdlgetparameter('force_hold_time');
                                                                else
                                                                    resettime=hdlgetparameter('resetlength')*clkperiod+hdlgetparameter('force_hold_time');
                                                                end
                                                                clkenabletime=resettime+hdlgetparameter('testbenchclockenabledelay')*clkperiod;
                                                                hdlnames=hdlentityfilenames;

                                                                switch simulator
                                                                case 'modelsim'
                                                                    if hdlgetparameter('reset_asserted_level')
                                                                        resetwave=[' 1 0 ns, 0 ',num2str(resettime),' ns;'];
                                                                        resetpostwave=' 1';
                                                                    else
                                                                        resetwave=[' 0 0 ns, 1 ',num2str(resettime),' ns;'];
                                                                        resetpostwave=' 0';
                                                                    end
                                                                    if strcmpi(factor_varname,'decimationfactor')||...
                                                                        strcmpi(factor_varname,'interpolationfactor')
                                                                        clk_enablecmd=' 1';
                                                                    else
                                                                        clk_enablecmd=[' 0 0 ns, 1 ',num2str(clkenabletime)];
                                                                    end
                                                                    tclprecmds=['force /',top,'/',clk_enable,clk_enablecmd,' ns;',char(10),...
                                                                    'force /',top,'/',reset,resetwave,char(10),...
                                                                    'puts -----------------------------------------',char(10),...
                                                                    'puts "Running Simulink Cosimulation block.";',char(10),...
                                                                    'puts [clock format [clock seconds]]'];
                                                                    tclpostcmds=['force /',top,'/',reset,resetpostwave,char(10),...
                                                                    'puts [clock format [clock seconds]]'];

                                                                    unixprojdir=strrep(tmpdir,'\','/');
                                                                    unixprojdir=strrep(unixprojdir,' ','\ ');

                                                                    if strcmpi(lang,'vhdl')
                                                                        compilecmdprefix='vcom ';
                                                                    else
                                                                        compilecmdprefix='vlog ';
                                                                    end
                                                                    compilecmd={};
                                                                    for n=1:length(hdlnames)
                                                                        compilecmd=[compilecmd,[compilecmdprefix,hdlnames{n}]];
                                                                    end
                                                                    tclcmd={['cd ',unixprojdir],...
                                                                    'vlib work',...
                                                                    compilecmd{:},...
                                                                    ['vsimulink work.',top]};
                                                                    wavecmd={};
                                                                    for n=1:length(simcmd);
                                                                        wavecmd=[wavecmd,['after 100 add wave -height 200 -radix decimal -format analog-step -scale 0.002 -offset 32000 ',simcmd{n}]];
                                                                    end
                                                                    wavecmd=[wavecmd,...
                                                                    'catch { wm geometry $vsimPriv(WaveWindows) 521x600+10+10 }',...
                                                                    'catch { wave zoomfull }'];
                                                                    tclcmd=[tclcmd,wavecmd];

                                                                case 'incisive'
                                                                    if strcmpi(lang,'vhdl')
                                                                        if hdlgetparameter('reset_asserted_level')
                                                                            resetwave=[' {B"1"} -after 0fs {B"0"} -after ',num2str(resettime),'fs;'];
                                                                            resetpostwave=' {B"1"};';
                                                                        else
                                                                            resetwave=[' {B"0"} -after 0fs {B"1"} -after ',num2str(resettime),'fs;'];
                                                                            resetpostwave=' {B"0"};';
                                                                        end
                                                                        if strcmpi(factor_varname,'decimationfactor')||...
                                                                            strcmpi(factor_varname,'interpolationfactor')
                                                                            clk_enablecmd=' {B"1"} -after 0fs;';
                                                                        else
                                                                            clk_enablecmd=[' {B"0"} -after 0fs {B"1"} -after ',num2str(clkenabletime),'fs;'];
                                                                        end
                                                                        tclprecmds=['force ',clk_enable,clk_enablecmd,char(10),...
                                                                        'force ',reset,resetwave,char(10)];
                                                                        tclpostcmds=['force ',reset,resetpostwave];
                                                                    else
                                                                        if hdlgetparameter('reset_asserted_level')
                                                                            resetwave=' 1 -after 0fs 0 -after 22fs;';
                                                                            resetpostwave=' 1;';
                                                                        else
                                                                            resetwave=' 0 -after 0fs 1 -after 22fs;';
                                                                            resetpostwave=' 0;';
                                                                        end
                                                                        tclprecmds=['force ',clk_enable,' 1  -after 0fs;',char(10),...
                                                                        'force ',reset,resetwave,char(10)];
                                                                        tclpostcmds=['force ',reset,resetpostwave];
                                                                    end

                                                                    tclprecmds=[tclprecmds,...
                                                                    'puts -----------------------------------------',char(10),...
                                                                    'puts "Running Simulink Cosimulation block.";'];

                                                                    if strcmpi(lang,'vhdl')
                                                                        compilecmdprefix='exec ncvhdl -64bit -v93 ';
                                                                    else
                                                                        compilecmdprefix='exec ncvlog -64bit ';
                                                                    end
                                                                    compilecmd={};
                                                                    for n=1:length(hdlnames)
                                                                        compilecmd=[compilecmd,[compilecmdprefix,hdlnames{n}]];
                                                                    end
                                                                    tclcmd={['cd ',tmpdir],...
                                                                    compilecmd{:},...
                                                                    ['exec ncelab -64bit -access +wc ',top]};
                                                                    hdlsimulinkcmd={['hdlsimulink -gui ',top],...
                                                                    ' -input "{@simvision  {set w \[waveform new\]}}"'};
                                                                    wavecmd=[];
                                                                    waveformat=[];
                                                                    waveaxis=[];
                                                                    waveprobe=[];
                                                                    for n=1:length(portnames)
                                                                        wavecmd=[wavecmd,[' -input "{@simvision {waveform add -using \$w -signals signed(:',portnames{n},')}}"']];
                                                                        waveformat=[waveformat,[' -input "{@simvision {waveform format -using \$w signed(:',portnames{n},') -trace analogSampleAndHold}}"']];
                                                                        waveaxis=[waveaxis,[' -input "{@simvision {waveform axis range -min -15000 -max 15000 -using \$w signed(:',portnames{n},')}}"']];
                                                                        waveprobe=[waveprobe,portnames{n},' '];
                                                                    end
                                                                    hdlsimulinkend=[' -input "{@database -open waves -into waves.shm -default}"',...
                                                                    [' -input "{@probe -create -shm ',waveprobe,'}"']];
                                                                    hdlsimulinkcmd=[hdlsimulinkcmd{:},wavecmd,waveformat,waveaxis,hdlsimulinkend];
                                                                    tclcmd=[tclcmd,hdlsimulinkcmd];

                                                                otherwise
                                                                    error(message('hdlfilter:filterhdlcoder:HDLTestbench:generatecosimtb:unsupportedsimulator',simulator));
                                                                end





                                                                wid1='HDLLink:BlockInit:NumberofParamsConflict';
                                                                warning('off',wid1);

                                                                set_param(cosimblkname,...
                                                                'PortPaths',PortPaths,...
                                                                'PortModes',PortModes,...
                                                                'PortTimes',PortTimes,...
                                                                'PortSigns',PortSigns,...
                                                                'PortFracLengths',PortFracLengths);

                                                                set_param(cosimblkname,'ClockTimes',['[',num2str(clkperiod),']'],...
                                                                'ClockPaths',[top,'/',clkname],...
                                                                'ClockModes','[2 ]');
                                                                set_param(cosimblkname,'CommSharedMemory','on');

                                                                set_param(cosimblkname,'CommShowInfo','off');
                                                                set_param(cosimblkname,'TclPreSimCommand',tclprecmds);
                                                                set_param(cosimblkname,'TclPostSimCommand',tclpostcmds);
                                                                [~,lastid]=lastwarn;
                                                                if strcmpi(lastid,wid1)
                                                                    lastwarn('');
                                                                end
                                                                warning('on',wid1);

                                                                function local_checkInstallLoadLibs(filterobj,simulator)



                                                                    if~(license('test','SIMULINK'))||isempty(ver('simulink'))
                                                                        error(message('hdlfilter:filterhdlcoder:HDLTestbench:generatecosimtb:simulinklicenseNA'));
                                                                    end

                                                                    switch simulator
                                                                    case 'modelsim'
                                                                        modelsimdir=fullfile(matlabroot,'toolbox','edalink','extensions','modelsim','modelsim');
                                                                        if~(license('test','EDA_Simulator_Link')&&exist(modelsimdir,'dir'))
                                                                            error(message('hdlfilter:filterhdlcoder:HDLTestbench:generatecosimtb:modelsimnotinstalled'));

                                                                        end
                                                                    case 'incisive'
                                                                        incisivedir=fullfile(matlabroot,'toolbox','edalink','extensions','incisive','incisive');
                                                                        if~(license('test','EDA_Simulator_Link')&&exist(incisivedir,'dir'))
                                                                            error(message('hdlfilter:filterhdlcoder:HDLTestbench:generatecosimtb:incisivenotinstalled'));

                                                                        end
                                                                    end

                                                                    if~(license('test','Signal_Blocks'))||isempty(ver('dsp'))
                                                                        error(message('hdlfilter:filterhdlcoder:HDLTestbench:generatecosimtb:dsplicenseNA'));
                                                                    end

                                                                    if isFixed(filterobj)
                                                                        if~(license('test','Fixed_Point_Toolbox'))||isempty(ver('fixedpoint'))
                                                                            error(message('hdlfilter:filterhdlcoder:HDLTestbench:generatecosimtb:simulinkfixedpointlicenseNA'));
                                                                        end
                                                                    end
                                                                    disp('### Loading Simulink ...');


                                                                    load_system('simulink');
                                                                    load_system('dspsrcs4');

                                                                    load_system('dspsigops');

                                                                    switch simulator
                                                                    case 'modelsim'
                                                                        load_system('modelsimlib');
                                                                    case 'incisive'
                                                                        load_system('lfilinklib');
                                                                    end

                                                                    function success=isFixed(filterobj)

                                                                        if isa(filterobj,'dfilt.multistage')
                                                                            success=strcmpi(filterobj.Stage(1).Arithmetic,'fixed');
                                                                        else
                                                                            success=strcmpi(filterobj.Arithmetic,'fixed');
                                                                        end













