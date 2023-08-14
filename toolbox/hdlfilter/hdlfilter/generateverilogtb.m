function generateverilogtb(filterobj,varargin)











    if~(builtin('license','checkout','Filter_Design_HDL_Coder'))
        error(message('hdlfilter:generateverilogtb:nolicenseavailable'));
    end

    switch lower(class(filterobj))

    case{'mfilt.cicdecim','dsp.internal.mfilt.cicinterp'}
        arithisdouble=0;

        filterobj.ResetBeforeFiltering='on';

        switch lower(class(filterobj))
        case 'mfilt.cicdecim'
            filterstruct='cicdecim';
            factor=filterobj.DecimationFactor;
        case 'dsp.internal.mfilt.cicinterp'
            filterstruct='cicinterp';
            factor=filterobj.InterpolationFactor;
        otherwise
            error(message('hdlfilter:generateverilogtb:unsupportedarch',class(filterobj)));
        end

    case 'dsp.internal.mfilt.firinterp'
        filterstruct='firinterp';
        factor=filterobj.InterpolationFactor;
        arithtype=get(filterobj,'Arithmetic');
        switch arithtype
        case 'double'
            arithisdouble=1;
        case 'fixed'
            arithisdouble=0;
        otherwise
            error(message('hdlfilter:generateverilogtb:unsupportedarithmetic',arithtype));
        end

    case 'mfilt.firtdecim'
        filterstruct='firtdecim';
        factor=filterobj.DecimationFactor;
        arithtype=get(filterobj,'Arithmetic');
        switch arithtype
        case 'double'
            arithisdouble=1;
        case 'fixed'
            arithisdouble=0;
        otherwise
            error(message('hdlfilter:generateverilogtb:unsupportedarithmetic',arithtype));
        end

    case 'mfilt.firdecim'
        filterstruct='firdecim';
        factor=filterobj.DecimationFactor;
        arithtype=get(filterobj,'Arithmetic');
        switch arithtype
        case 'double'
            arithisdouble=1;
        case 'fixed'
            arithisdouble=0;
        otherwise
            error(message('hdlfilter:generateverilogtb:unsupportedarithmetic',arithtype));
        end

    case 'dsp.internal.mfilt.holdinterp'
        filterstruct='holdinterp';
        factor=filterobj.InterpolationFactor;
        arithtype=get(filterobj,'Arithmetic');
        switch arithtype
        case 'double'
            arithisdouble=1;
        case 'fixed'
            arithisdouble=0;
        otherwise
            error(message('hdlfilter:generateverilogtb:unsupportedarithmetic',arithtype));
        end

    case 'dsp.internal.mfilt.linearinterp'
        filterstruct='linearinterp';
        factor=filterobj.InterpolationFactor;
        arithtype=get(filterobj,'Arithmetic');
        switch arithtype
        case 'double'
            arithisdouble=1;
        case 'fixed'
            arithisdouble=0;
        otherwise
            error(message('hdlfilter:generateverilogtb:unsupportedarithmetic',arithtype));
        end

    otherwise
        error(message('hdlfilter:generateverilogtb:unsupportedarch',class(filterobj)));
    end

    if isempty(hdlgetparameter('target_language'))
        warning(message('hdlfilter:generateverilogtb:usingdefaults'));
        hdldefaultfilterparameters('verilog');
    end

    hdlverilogmode();

    bdt=hdlgetparameter('base_data_type');
    hdlsetparameter('tb_target_language','verilog');

    if isempty(hdlgetparameter('tb_stimulus'))&&isempty(hdlgetparameter('tb_user_stimulus'))
        warning(message('hdlfilter:generateverilogtb:usingdefaultstimulus'));
        hprop=PersistentHDLPropSet;
        set(hprop.CLI,'TestBenchStimulus',defaulttbstimulus(filterobj));
        updateINI(hprop);
    end

    [cando,errstr]=ishdlable(filterobj);
    if cando
        [s,mess,messid]=mkdir(hdlGetCodegendir);
        if s==0
            switch lower(messid)
            case 'matlab:mkdir:directoryexists',
                error(message('hdlfilter:generateverilogtb:directoryfailure',hdlGetCodegendir));
            case 'matlab:mkdir:oserror',
                error(message('hdlfilter:generateverilogtb:createdirectoryfailure',hdlGetCodegendir));
            otherwise

                error(message('hdlfilter:generateverilogtb:codegendirerror',mess));
            end
        end
    else
        error(message('hdlfilter:generateverilogtb:unsupportedarch',class(filterobj)));
    end

    fprintf('### Starting generation of Verilog Test Bench\n');

    latency=1+hdlfilterlatency(filterobj);




    inexactcompare=0;

    if hdlgetparameter('bit_true_to_filter')==0||...
        (isfir(filterobj)&&~strcmpi(filterstruct,'firt')...
        &&~strcmpi(hdlgetparameter('filter_fir_final_adder'),'linear'))||...
        ~strcmpi(hdlgetparameter('filter_multipliers'),'multiplier')
        inexactcompare=1;
        warning(message('hdlfilter:generateverilogtb:inexactresults'));

        if isempty(hdlgetparameter('error_margin'))
            comparethreshold=15;
            warning(message('hdlfilter:generateverilogtb:defaulterrormargin'));
        else
            if hdlgetparameter('error_margin')<=0
                comparethreshold=0;
            else
                comparethreshold=floor(2.^hdlgetparameter('error_margin')-1);
            end
        end
    end

    [inputsize,inputbp]=getinputwordfraclength(filterobj);
    inputsigned=true;

    [inputvtype,inputsltype]=hdlgetporttypesfromsizes(inputsize,inputbp,inputsigned);

    [outputsize,outputbp]=getoutputwordfraclength(filterobj);
    outputsigned=true;

    [outputvtype,outputsltype]=hdlgetporttypesfromsizes(outputsize,outputbp,outputsigned);

    oldcastbeforesum=overridecastbeforesum(filterobj);





    fprintf('### Generating input stimulus\n');

    inputdata=generatetbstimulus(filterobj,varargin{:});
    len=length(inputdata);

    if len<latency
        error(message('hdlfilter:generateverilogtb:notenoughinput',len,latency));
    end

    if arithisdouble&&~all(isfinite(inputdata))
        error(message('hdlfilter:generateverilogtb:nonefinitenumber'));
    end

    fprintf('### Done generating input stimulus; length %d samples.\n',len);

    if arithisdouble
        indata=inputdata;
    else


        indata=fi(inputdata,inputsigned,inputsize,inputbp,...
        'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
    end


    if isa(filterobj,'mfilt.firtdecim')||isa(filterobj,'mfilt.farrowsrc')
        outdata=filter(filterobj,indata);
    else
        filterobj_copy=copy(filterobj);
        outdata=filter(filterobj_copy,indata);
    end

    lenout=length(outdata);

    if arithisdouble&&~all(isfinite(outdata))
        error(message('hdlfilter:generateverilogtb:nonefinitenumber'));
    end

    overridecastbeforesum(filterobj,oldcastbeforesum);

    tbfilename=fullfile(hdlGetCodegendir,[hdlgetparameter('tb_name'),hdlgetparameter('filename_suffix')]);

    [pathstr,fname,exten]=fileparts(tbfilename);
    fullfilename=[fname,exten];

    nameforuser=fullfile(pathstr,fullfilename);
    if~isempty(pathstr)
        whatstruct=what(pathstr);
        whatstruct=whatstruct(end);
        if~isempty(whatstruct)
            nameforuser=fullfile(whatstruct.path,fullfilename);
        end
    end

    fprintf('%s\n',['### Generating: <a href="matlab:edit(''',nameforuser,''')">',nameforuser,'</a>']);
    if isa(filterobj,'mfilt.cascade')&&isa(filterobj.Stage(1),'mfilt.firdecim')...
        &&isa(filterobj.Stage(end),'mfilt.farrowsrc')
        header_comment=hdlentitycomment(hdlgetparameter('tb_name'),...
        hdlgetparameter('rcs_cvs_tag'),...
        [],'//');
    else
        header_comment=hdlentitycomment(hdlgetparameter('tb_name'),...
        hdlgetparameter('rcs_cvs_tag'),...
        info(filterobj),'//');
    end




    module_name=hdlentitytop;
    if isempty(module_name)
        if isempty(hdlgetparameter('filter_name'))
            error(message('hdlfilter:generateverilogtb:nofilter'));
        else
            module_name=hdlgetparameter('filter_name');
        end
    end

    hdlentitysignalsinit;



    clkname=hdlgetparameter('clockname');
    if isempty(clkname)
        clkname='clk';
    end

    clkenname=hdlgetparameter('clockenablename');
    if isempty(clkenname)
        clkenname='clk_enable';
    end

    resetname=hdlgetparameter('resetname');
    if isempty(resetname)
        resetname='reset';
    end

    innamename=hdlgetparameter('filter_input_name');
    if isempty(innamename)
        innamename='filter_in';
    end

    outnamename=hdlgetparameter('filter_output_name');
    if isempty(outnamename)
        outnamename='filter_out';
    end

    ceoutname=hdlgetparameter('clockenableoutputname');
    if isempty(ceoutname)
        ceoutname='ce_out';
    end

    if strcmpi(filterstruct,'firsrc')
        ceinname='ce_in';
    end
    tempcountname='temp_count';
    inputcplxty=hdlgetparameter('filter_complex_inputs');
    if isa(filterobj,'mfilt.cascade')
        outputcplxty=0;
    else
        if isa(filterobj,'mfilt.cicdecim')||isa(filterobj,'dsp.internal.mfilt.cicinterp')
            outputcplxty=hdlgetparameter('filter_complex_inputs');
        else
            outputcplxty=hdlgetparameter('filter_complex_inputs')||~isreal(filterobj.Numerator);
        end
    end

    [clk,notused]=hdlnewsignal(clkname,'filter',-1,0,0,bdt,'boolean');
    [clken,notused]=hdlnewsignal(clkenname,'filter',-1,0,0,bdt,'boolean');
    [reset,notused]=hdlnewsignal(resetname,'filter',-1,0,0,bdt,'boolean');
    [inname,entity_input]=hdlnewsignal(innamename,'filter',-1,inputcplxty,0,inputvtype,inputsltype);
    inname=hdlsignalname(entity_input);
    if inputcplxty
        inname_im=hdlsignalname(hdlsignalimag(entity_input));
    end
    if isinterpolator(filterobj)||isdecimator(filterobj)
        if hdlgetparameter('clockinputs')==2
            [clk1,notused]=hdlnewsignal([clkname,'1'],'filter',-1,0,0,bdt,'boolean');
            [clken1,notused]=hdlnewsignal([clkenname,'1'],'filter',-1,0,0,bdt,'boolean');
            [reset1,notused]=hdlnewsignal([resetname,'1'],'filter',-1,0,0,bdt,'boolean');
        end
    end


    hdllastinputsignal;
    [outname,entity_output]=hdlnewsignal(outnamename,'filter',-1,outputcplxty,0,outputvtype,outputsltype);
    outname=hdlsignalname(entity_output);
    if outputcplxty
        outname_im=hdlsignalname(hdlsignalimag(entity_output));
    end

    if isinterpolator(filterobj)||isdecimator(filterobj)||strcmpi(filterstruct,'firsrc')
        if hdlgetparameter('clockinputs')==1
            [ceoutname,entity_ceoutput]=hdlnewsignal(ceoutname,'filter',-1,0,0,bdt,'boolean');
        end
    end
    hdllastoutputsignal;

    [hdl_entity_ports,hdl_entity_portdecls]=hdlentityports;
    portnames=hdlentityportnames;
    if~strcmpi(filterstruct,'farrow')


        hdlentitysignalsinit;
    end

    portmap='';
    for n=1:length(portnames)
        portmap=[portmap,...
        '    .',portnames{n},'(',portnames{n},')',...
        ',\n'];
    end
    portmap=portmap(1:end-3);

    verilog_module_comment=header_comment;
    verilog_timescale='`timescale 1 ns / 1 ns\n\n';
    verilog_module_decl=['module ',hdlgetparameter('tb_name'),';\n\n'];
    verilog_module_end='endmodule\n';

    verilog_functions='';
    verilog_constants='  // Constants\n';
    verilog_parameters='  // Parameters\n';
    verilog_signals='  // Nets\n';
    verilog_component_instances='  // Component Instances\n';
    verilog_blocks='  // Block Statements\n';

    thigh=hdlgetparameter('force_clock_high_time');
    tlow=hdlgetparameter('force_clock_low_time');
    tcycle=tlow+thigh;
    thold=hdlgetparameter('force_hold_time');

    if latency==1&&(2*thold>=tcycle)
        error(message('hdlfilter:generateverilogtb:combtimingerror',thold,tcycle));
    elseif thold>=tcycle
        error(message('hdlfilter:generateverilogtb:timingerror',thold,tcycle));
    end

    if strcmp(inputvtype(1:4),'wire')
        inputvtype_const=['reg ',inputvtype(5:end)];
    else
        inputvtype_const=inputvtype;
    end
    if strcmp(outputvtype(1:4),'wire')
        outputvtype_const=['reg ',outputvtype(5:end)];
    else
        outputvtype_const=outputvtype;
    end

    if outputsize==0
        verilog_functions='  // Function definitions\n';
        verilog_functions=[verilog_functions,...
        '  function real abs_real;\n',...
        '  input real arg;\n',...
        '  begin\n',...
        '    abs_real = arg > 0 ? arg : -arg;\n',...
        '  end\n',...
        '  endfunction //function abs_real\n\n',...
        ];
    elseif inexactcompare
        verilog_functions='  // Function definitions\n';
        verilog_functions=[verilog_functions,...
        '  function signed [',num2str(outputsize-1),':0] abs;\n',...
        '  input signed [',num2str(outputsize-1),':0] arg;\n',...
        '  begin\n',...
        '    abs = arg > 0 ? arg : -arg;\n',...
        '  end\n',...
        '  endfunction //function abs\n\n',...
        ];
    end

    verilog_component_instances=[verilog_component_instances,...
    '  ',module_name,' ',hdlgetparameter('Instance_prefix'),module_name,'\n',...
    '    (\n',...
    portmap,...
    '\n    );\n\n'];

    verilog_parameters=[verilog_parameters,...
    '  parameter ',sprintf('%-10s',[clk,'_high']),...
    ' = ',num2str(thigh),';\n',...
    '  parameter ',sprintf('%-10s',[clk,'_low']),...
    ' = ',num2str(tlow),';\n',...
    '  parameter ',sprintf('%-10s',[clk,'_period']),...
    ' = ',num2str(tcycle),';\n',...
    '  parameter ',sprintf('%-10s',[clk,'_hold']),...
    ' = ',num2str(thold),';\n\n',...
    ];

    verilog_signals=[verilog_signals,'\n',...
    '  reg ',clk,';\n',...
    '  reg ',clken,';\n',...
    '  reg ',reset,';\n',...
    '  ',inputvtype_const,' ',inname,';\n',...
    '  ',outputvtype,' ',outname,';\n\n',...
    '  integer n;  //loop variable\n\n',...
    ];
    if inputcplxty
        verilog_signals=[verilog_signals,...
        '  ',inputvtype_const,' ',inname_im,';\n'];
    end
    if outputcplxty
        verilog_signals=[verilog_signals,...
        '  ',outputvtype,' ',outname_im,';\n\n',...
        ];
    end

    if strcmpi(filterstruct,'firsrc')
        verilog_signals=[verilog_signals,...
        '  wire ',ceinname,';\n'];
    end
    if isinterpolator(filterobj)||isdecimator(filterobj)||strcmpi(filterstruct,'firsrc')
        if hdlgetparameter('clockinputs')==1
            verilog_signals=[verilog_signals,...
            '  wire ',ceoutname,';\n\n'];
        else
            verilog_signals=[verilog_signals,...
            '  wire ',clk1,';\n'];
            verilog_signals=[verilog_signals,...
            '  wire ',clken1,';\n'];
            if hdlgetparameter('async_reset')==0
                verilog_signals=[verilog_signals,...
                '  reg ',reset1,';\n'];
            else
                verilog_signals=[verilog_signals,...
                '  wire ',reset1,';\n'];
            end
            verilog_signals=[verilog_signals,...
            '  integer ',tempcountname,';\n\n'];
        end
    else
        verilog_signals=[verilog_signals,...
        '\n'];
    end

    if hdlgetparameter('force_clockenable')==1
        clkenvalue=hdlgetparameter('force_clockenable_value');
        enable_statement=['    ',clken,' <= 1''b',sprintf('%d',clkenvalue),';\n'];
    end

    nreset=2;
    if hdlgetparameter('force_clock')==1
        verilog_blocks=[verilog_blocks,...
        '  always  // clk generation\n',...
        '    begin : ',clk,'_gen\n',...
        '    ',clk,' <= 1''b1;\n',...
        '    # ',clk,'_high;\n',...
        '    ',clk,' <= 1''b0;\n',...
        '    # ',clk,'_low;\n',...
        '    end  //',clk,'_gen;\n\n'];
        if hdlgetparameter('clockinputs')==2

            if hdlgetparameter('filter_registered_input')==1
                initval=1;
            else
                initval=0;
            end

            if isdecimator(filterobj)
                clkdelay=tcycle-1;
            else
                clkdelay=1;
                initval=0;
            end

            if factor==1
                if isdecimator(filterobj)
                    clkdelay=tlow-1;
                    phase=0;
                else
                    clkdelay=1;
                    initval=0;
                    phase=1;
                end
                verilog_blocks=[verilog_blocks,...
                '  assign #',num2str(clkdelay),' ',clk1,' =(',clk,' == ',int2str(phase),')? 1''b1 : 1''b0;\n',...
                '  assign ',clken1,' = ',clken,';\n',...
                '  assign ',reset1,' = ',reset,';\n\n'];
            else
                if hdlgetparameter('force_reset_value')==1
                    activeedge='posedge';
                    resetvalue='1';
                    resetvalue_n='0';
                else
                    activeedge='negedge';
                    resetvalue='0';
                    resetvalue_n='1';
                end

                [reset2,reset2idx]=hdlnewsignal([reset,'2'],'filter',-1,0,0,bdt,'boolean');
                hdlregsignal(reset2idx);
                verilog_signals=[verilog_signals,makehdlsignaldecl(reset2idx)];

                if hdlgetparameter('clockinputs')==2
                    if isserializablefir(filterobj)&&isserialized(filterobj)
                        count_to=factor*hdlgetparameter('foldingfactor');
                    else
                        count_to=factor;
                    end
                    if isfirdecim_da(filterobj)
                        count_to=factor*hdlgetparameter('foldingfactor');
                    end
                else
                    count_to=factor;
                end

                [phasevtype,phasesltype]=hdlgettypesfromsizes(count_to,0,0);

                [~,ring_phase]=hdlnewsignal('ring_count','filter',-1,0,0,...
                phasevtype,phasesltype);
                hdlregsignal(ring_phase);
                verilog_signals=[verilog_signals,makehdlsignaldecl(ring_phase)];


                resetbak=hdlgetparameter('resetname');
                hdlsetparameter('resetname',reset2);
                clkbak=hdlgetparameter('clockname');
                hdlsetparameter('clockname',clk);
                clkenbak=hdlgetparameter('clockenablename');
                hdlsetparameter('clockenablename',clken);
                oldresettype=hdlgetparameter('async_reset');
                hdlsetparameter('async_reset',1);
                if(isfirdecim_da(filterobj)&&hdlgetparameter('clockinputs')==2&&hdlgetparameter('filter_daradix')~=2^inputsize)||...
                    (isinterpolator(filterobj)&&(isserializablefir(filterobj)&&isserialized(filterobj))&&hdlgetparameter('clockinputs')==2)


                    [clk1body,clk1signals]=hdlringcounter(ring_phase,count_to,[clk1,'_gen'],1,mod(nreset+initval+1,count_to));
                else
                    if~(isa(filterobj,'mfilt.firdecim')&&isserialized(filterobj))
                        [clk1body,clk1signals]=hdlringcounter(ring_phase,count_to,[clk1,'_gen'],1,mod(nreset+initval,count_to));
                    else
                        if(isa(filterobj,'mfilt.firdecim')&&isserialized(filterobj))

                            if hdlgetparameter('filter_registered_input')==1
                                outputcycles=(hdlgetparameter('foldingfactor')+2)+1;
                            else
                                outputcycles=(hdlgetparameter('foldingfactor')+1)+1;
                            end

                            rphase=mod(3+outputcycles-1,count_to);


                            numinputs=ceil((outputcycles)/hdlgetparameter('foldingfactor'))+2;
                            latency=numinputs;
                        end

                        [clk1body,clk1signals]=hdlringcounter(ring_phase,count_to,[clk1,'_gen'],1,rphase);

                    end
                end
                clk1temp=hdlsignalname(clk1signals);

                hdlsetparameter('resetname',resetbak);
                hdlsetparameter('clockname',clkbak);
                hdlsetparameter('clockenablename',clkenbak);
                hdlsetparameter('async_reset',oldresettype);

                if~isempty(clk1signals)
                    verilog_signals=[verilog_signals,makehdlsignaldecl(clk1signals)];
                end
                verilog_blocks=[verilog_blocks,...
                clk1body,...
                '  assign #',num2str(clkdelay),' ',clk1,' = (',clk1temp,' == 1)? 1 : 0;\n',...
                '  assign ',clken1,' = ',clken,';\n'];


                if hdlgetparameter('async_reset')==1
                    verilog_blocks=[verilog_blocks,...
                    '  assign ',reset1,' = ',reset,';\n\n'];
                else
                    verilog_blocks=[verilog_blocks,'\n'];
                end
                verilog_blocks=[verilog_blocks,...
                '  initial //',reset2,'_gen\n',...
                '    begin\n',...
                '    ',reset2,' <= ',resetvalue,';\n',...
                '    # 1;\n',...
                '    ',reset2,' <= ',resetvalue_n,';\n',...
                '  end //',reset2,'_gen\n\n'];
            end
        end
    end

    if hdlgetparameter('force_reset')==1
        rassertval=['1''b',num2str(hdlgetparameter('force_reset_value'))];
        rdeassertval=['1''b',num2str(1-hdlgetparameter('force_reset_value'))];
        tend=(2*tcycle+hdlgetparameter('force_hold_time'));

        verilog_blocks=[verilog_blocks,...
        '  initial  // reset block\n',...
        '    begin : ',reset,'_gen\n',...
        enable_statement,...
        '    ',reset,' <= ',rassertval,';\n',...
        '    # (',clk,'_period*2 + ',clk,'_hold);\n',...
        '    ',reset,' <= ',rdeassertval,';\n',...
        '  end  //',reset,'_gen;\n\n'];

        if(hdlgetparameter('async_reset')==0&&hdlgetparameter('clockinputs')==2)
            verilog_blocks=[verilog_blocks,...
            '  initial  // reset1 block\n',...
            '    begin : ',reset1,'_gen\n',...
            '    ',reset1,' <= ',rassertval,';\n',...
            '    wait (',clk1,');\n',...
            '    # ',clk,'_hold;\n',...
            '    ',reset1,' <= ',rdeassertval,';\n',...
            '  end  //',reset1,'_gen;\n\n'];
        end
    end






    if len==1
        inveclen=len;
    else
        inveclen=len-1;
    end

    if lenout==1
        outveclen=lenout;
    else
        outveclen=lenout-1;
    end

    verilog_initial='  initial\n    begin\n';
    verilog_initial_end='    end\n\n';

    inconstants_decl=['  ',inputvtype_const,' ',inname,'_force [0:',num2str(len-1),'];\n'];
    outconstants_decl=['  ',outputvtype_const,' ',outname,'_expected [0:',num2str(lenout-1),'];\n\n'];

    if inputcplxty
        inconstants_im_decl=['  ',inputvtype_const,' ',inname_im,'_force [0:',num2str(len-1),'];\n'];
    end
    if outputcplxty
        outconstants_im_decl=['  ',outputvtype_const,' ',outname_im,'_expected [0:',num2str(lenout-1),'];\n\n'];
    end

    inconstants='';
    outconstants='';

    verilog_constants=[verilog_constants,inconstants,outconstants];

    if latency==1
        hold_sign='-';
    else
        hold_sign='+';
    end

    if isinterpolator(filterobj)||isdecimator(filterobj)
        verilog_signals=[verilog_signals,...
        '  integer m;\n'];
    end
    if strcmpi(filterstruct,'firsrc')
        verilog_signals=[verilog_signals,...
        '  integer m_in = 0;\n',...
        '  integer m_out = 0;\n'];
    end
    verilog_blocks=[verilog_blocks,...
    '  initial  //The main block \n',...
    '    begin\n'];

    if isinterpolator(filterobj)||isdecimator(filterobj)
        verilog_blocks=[verilog_blocks,...
        '    m <= 0;\n'];
    end

    verilog_blocks=[verilog_blocks,...
    '    # ',clk,'_period;\n',...
    '    ',inname,' <= ',inname,'_force[0];\n'];
    if inputcplxty
        verilog_blocks=[verilog_blocks,...
        '    ',inname_im,' <= ',inname_im,'_force[0];\n'];
    end
    if isinterpolator(filterobj)&&...
        hdlgetparameter('filter_registered_input')&&...
        ~(isa(filterobj,'dsp.internal.mfilt.cicinterp')&&...
        hdlgetparameter('clockinputs')==2)
        verilog_blocks=[verilog_blocks,...
        '    # (',clk,'_period*3);\n'];
    else
        verilog_blocks=[verilog_blocks,...
        '    # (',clk,'_period*2 ',hold_sign,' ',clk,'_hold);\n'];
    end



    for n=1:latency-2
        if isinterpolator(filterobj)
            if hdlgetparameter('clockinputs')==1
                if isfirinterp_da(filterobj)||(isserializablefir(filterobj)&&isserialized(filterobj))

                    ffact=hdlgetparameter('foldingfactor');
                    if ffact>1
                        verilog_blocks=[verilog_blocks,...
                        '    if (',ceoutname,' == 1) \n',...
                        '      begin\n',...
                        '      ',inname,' <= ',inname,'_force[m + 1];\n',...
                        '      m <= m + 1;\n',...
                        '      end\n',...
                        '    # (',clk,'_period*',num2str(ffact),');\n'];
                    else
                        verilog_blocks=[verilog_blocks,...
                        '    if (',ceoutname,' == 1) \n',...
                        '      begin\n',...
                        '      ',inname,' <= ',inname,'_force[m + 1];\n',...
                        '      m <= m + 1;\n',...
                        '      end\n',...
                        '    # ',clk,'_period;\n'];
                    end
                else
                    verilog_blocks=[verilog_blocks,...
                    '    if (',ceoutname,' == 1) \n',...
                    '      begin\n',...
                    '      ',inname,' <= ',inname,'_force[m + 1];\n',...
                    '      m <= m + 1;\n',...
                    '      end\n',...
                    '    # ',clk,'_period;\n'];
                end

            else
                if(isserializablefir(filterobj)&&isserialized(filterobj))

                    ffact=hdlgetparameter('foldingfactor');
                    verilog_blocks=[verilog_blocks,...
                    '    if (',clk1,' == 1)\n',...
                    '      begin\n',...
                    '      ',inname,' <= ',inname,'_force[m + 1];\n'];
                    if inputcplxty
                        verilog_blocks=[verilog_blocks,...
                        '      ',inname_im,' <= ',inname_im,'_force[m + 1];\n'];
                    end
                    verilog_blocks=[verilog_blocks,...
                    '      m <= m + 1;\n',...
                    '      end\n',...
                    '    # (',clk,'_period*',num2str(ffact),');\n'];
                else
                    verilog_blocks=[verilog_blocks,...
                    '    if (',clk1,' == 1)\n',...
                    '      begin\n',...
                    '      ',inname,' <= ',inname,'_force[m + 1];\n'];
                    if inputcplxty
                        verilog_blocks=[verilog_blocks,...
                        '      ',inname_im,' <= ',inname_im,'_force[m + 1];\n'];
                    end
                    verilog_blocks=[verilog_blocks,...
                    '      m <= m + 1;\n',...
                    '      end\n',...
                    '    # ',clk,'_period;\n'];
                end
            end

        else
            if isserializablefir(filterobj)||isfirdecim_da(filterobj)

                ffact=hdlgetparameter('foldingfactor');
                if ffact>1
                    if inputcplxty
                        verilog_blocks=[verilog_blocks,...
                        '    ',inname,' <= ',inname,'_force[',num2str(n),'];\n',...
                        '    ',inname_im,' <= ',inname_im,'_force[',num2str(n),'];\n',...
                        '    # (',clk,'_period*',num2str(ffact),');\n'];
                    else
                        verilog_blocks=[verilog_blocks,...
                        '    ',inname,' <= ',inname,'_force[',num2str(n),'];\n',...
                        '    # (',clk,'_period*',num2str(ffact),');\n'];
                    end
                else
                    if inputcplxty
                        verilog_blocks=[verilog_blocks,...
                        '    ',inname,' <= ',inname,'_force[',num2str(n),'];\n',...
                        '    ',inname_im,' <= ',inname_im,'_force[',num2str(n),'];\n',...
                        '    # ',clk,'_period;\n'];
                    else
                        verilog_blocks=[verilog_blocks,...
                        '    ',inname,' <= ',inname,'_force[',num2str(n),'];\n',...
                        '    # ',clk,'_period;\n'];
                    end
                end
            else
                if inputcplxty
                    verilog_blocks=[verilog_blocks,...
                    '    ',inname,' <= ',inname,'_force[',num2str(n),'];\n',...
                    '    ',inname_im,' <= ',inname_im,'_force[',num2str(n),'];\n',...
                    '    # ',clk,'_period;\n'];
                else
                    verilog_blocks=[verilog_blocks,...
                    '    ',inname,' <= ',inname,'_force[',num2str(n),'];\n',...
                    '    # ',clk,'_period;\n'];
                end
            end
        end
    end

    if isdecimator(filterobj)
        if outputsize==0
            if~outputcplxty
                testcondition=['abs_real($bitstoreal(',outname,') - $bitstoreal(',outname,'_expected[m])) >= 1.0e-9'];
            else
                testcondition=['abs_real($bitstoreal(',outname,') - $bitstoreal(',outname,'_expected[m])) >= 1.0e-9',...
                ' || abs_real($bitstoreal(',outname_im,') - $bitstoreal(',outname_im,'_expected[m])) >= 1.0e-9'];
            end
        elseif inexactcompare


            if outputsigned==1
                if~outputcplxty
                    testcondition=['abs(',outname,' - ',outname,'_expected[m]) > ',...
                    num2str(comparethreshold)];
                else
                    testcondition=['abs(',outname,' - ',outname,'_expected[m]) > ',...
                    num2str(comparethreshold),...
                    ' || abs(',outname_im,' - ',outname_im,'_expected[m]) > ',...
                    num2str(comparethreshold)];

                end
            else
                if~outputcplxty
                    testcondition=['abs($signed(',outname,') - $signed(',outname,'_expected[m])) > ',...
                    num2str(comparethreshold)];
                else
                    testcondition=['abs($signed(',outname,') - $signed(',outname,'_expected[m])) > ',...
                    num2str(comparethreshold),...
                    ' || abs($signed(',outname_im,') - $signed(',outname_im,'_expected[m])) > ',...
                    num2str(comparethreshold)];
                end
            end
        else
            if~outputcplxty
                testcondition=[outname,' !== ',outname,'_expected[m]'];
            else
                testcondition=[outname,' !== ',outname,'_expected[m]',...
                ' || ',outname_im,' !== ',outname_im,'_expected[m]'];
            end
        end

        severitylevel='ERROR';

        if latency==1
            wait_after_assert=['      # (2*',clk,'_hold);\n'];
            wait_after_force=['      # (',clk,'_period - 2*',clk,'_hold);\n'];
            n_adj=1;
        else
            wait_after_assert='';

            if isfirdecim_da(filterobj)||isserializablefir(filterobj)
                ffact=hdlgetparameter('foldingfactor');
                if ffact>1
                    wait_after_force=['      # (',clk,'_period*',num2str(ffact),');\n'];
                else
                    wait_after_force=['      # (',clk,'_period);\n'];
                end
            else
                wait_after_force=['      # (',clk,'_period);\n'];
            end

            n_adj=latency-1;
        end

        if outputsize==0
            display=['          $display("',severitylevel,' in filter test at time %%t : Expected ''%%f'' Actual ''%%f''", ',...
            '$time, $bitstoreal(',outname,'_expected[m]), $bitstoreal(',outname,'));\n'];
        else
            if outputcplxty
                display=['          $display("',severitylevel,' in filter test at time %%t : Expected (real) ''%%h'' vs Actual (real) ''%%h'' and Expected (imag) ''%%h'' vs Actual (imag) ''%%h''", ',...
                '$time, ',outname,'_expected[m], ',outname,...
                ' ,',outname_im,'_expected[m], ',outname_im,');\n'];
            else
                display=['          $display("',severitylevel,' in filter test at time %%t : Expected ''%%h'' Actual ''%%h''", ',...
                '$time, ',outname,'_expected[m], ',outname,');\n'];
            end
        end

        if hdlgetparameter('clockinputs')==1
            verilog_blocks=[verilog_blocks,...
            '    for (n = 0; n<= ',num2str(len-1+latency),'; n = n + 1)\n',...
            '      begin\n',...
            '      if (',ceoutname,' == 1 & m < ',num2str(lenout),')\n',...
            '        begin\n',...
            '        if (',testcondition,')\n',...
            display,...
            '        m <= m + 1; \n',...
            '        end\n',...
            wait_after_assert,...
            '      if (n + ',num2str(n_adj),' <= ',num2str(len-1),')\n',...
            '        ',inname,' <= ',inname,'_force[n + ',num2str(n_adj),'];\n',...
            wait_after_force,...
            '      end\n',...
            '    if (m != ',num2str(lenout),')\n',...
            '      begin\n',...
            '        $display("',severitylevel,' in filter test: Wrong number of outputs were checked");\n',...
            '      end\n',...
            '    else\n',...
            '      begin\n',...
            '        $display( "**** Test Complete with NO FAILURES. ****" );\n',...
            '      end\n',...
            '    $stop;\n\n',...
            ];
        else
            if~inputcplxty
                force_after_waitassert=['      if (n + ',num2str(n_adj),' <= ',num2str(len-1),')\n',...
                '        ',inname,' <= ',inname,'_force[n + ',num2str(n_adj),'];\n'];
            else
                force_after_waitassert=['      if (n + ',num2str(n_adj),' <= ',num2str(len-1),')\n',...
                '        ',inname,' <= ',inname,'_force[n + ',num2str(n_adj),'];\n',...
                '        ',inname_im,' <= ',inname_im,'_force[n + ',num2str(n_adj),'];\n'];
            end

            verilog_blocks=[verilog_blocks,...
            '    for (n = 0; n<= ',num2str(len-1+latency),'; n = n + 1)\n',...
            '      begin\n',...
            '      if (n %% ',num2str(factor),' == 0 & m < ',num2str(lenout),')\n',...
            '        begin\n',...
            '        if (',testcondition,')\n',...
            display,...
            '        m <= m + 1; \n',...
            '        end\n',...
            wait_after_assert,...
            force_after_waitassert,...
            wait_after_force,...
            '      end\n',...
            '    if (m != ',num2str(lenout),')\n',...
            '      begin\n',...
            '        $display("',severitylevel,' in filter test: Wrong number of outputs were checked");\n',...
            '      end\n',...
            '    else\n',...
            '      begin\n',...
            '        $display( "**** Test Complete with NO FAILURES. ****" );\n',...
            '      end\n',...
            '    $stop;\n\n',...
            ];
        end
    elseif isinterpolator(filterobj)
        if outputsize==0
            testcondition=['abs_real($bitstoreal(',outname,') - $bitstoreal(',outname,'_expected[n])) >= 1.0e-9'];
        elseif inexactcompare


            if outputsigned==1
                testcondition=['abs(',outname,' - ',outname,'_expected[n]) > ',...
                num2str(comparethreshold)];
            else
                testcondition=['abs($signed(',outname,') - $signed(',outname,'_expected[n])) > ',...
                num2str(comparethreshold)];
            end
        else
            if~outputcplxty
                testcondition=[outname,' !== ',outname,'_expected[n]'];
            else
                testcondition=[outname,' !== ',outname,'_expected[n] || ',outname_im,' !== ',outname_im,'_expected[n]'];
            end

        end

        severitylevel='ERROR';

        if latency==1
            wait_after_assert=['      # (2*',clk,'_hold);\n'];
            wait_after_force=['      # (',clk,'_period - 2*',clk,'_hold);\n'];
            n_adj=1;
        else
            wait_after_assert='';

            if isfirinterp_da(filterobj)||(isserializablefir(filterobj)&&isserialized(filterobj))
                ffact=hdlgetparameter('foldingfactor');
                if ffact>1
                    wait_after_force=['      # (',clk,'_period*',num2str(ffact),');\n'];
                else
                    wait_after_force=['      # (',clk,'_period);\n'];
                end
            else
                wait_after_force=['      # (',clk,'_period);\n'];
            end
            n_adj=latency-1;
        end

        if outputsize==0
            display=['        $display("',severitylevel,' in filter test at time %%t : Expected ''%%f'' Actual ''%%f''", ',...
            '$time, $bitstoreal(',outname,'_expected[n]), $bitstoreal(',outname,'));\n'];
        else
            if outputcplxty
                display=['          $display("',severitylevel,' in filter test at time %%t : Expected (real) ''%%h'' vs Actual (real) ''%%h'' and Expected (imag) ''%%h'' vs Actual (imag) ''%%h''", ',...
                '$time, ',outname,'_expected[m], ',outname,...
                ' ,',outname_im,'_expected[m], ',outname_im,');\n'];
            else
                display=['          $display("',severitylevel,' in filter test at time %%t : Expected ''%%h'' Actual ''%%h''", ',...
                '$time, ',outname,'_expected[m], ',outname,');\n'];
            end


        end

        if hdlgetparameter('clockinputs')==1
            verilog_blocks=[verilog_blocks,...
            '    for (n = 0; n<= ',num2str(len*factor-1),'; n = n + 1)\n',...
            '      begin\n',...
            '      if (',testcondition,')\n',...
            display,...
            wait_after_assert,...
            '      if (',ceoutname,'== 1 & m + 1 <=',num2str(len-1),')\n',...
            '        begin\n',...
            '        ',inname,' <= ',inname,'_force[m + 1];\n',...
            '        m <= m + 1;\n',...
            '        end\n',...
            wait_after_force,...
            '      end\n',...
            '    if (m != ',num2str(len-1),')\n',...
            '      begin\n',...
            '        $display("',severitylevel,' in filter test: Wrong number of outputs were checked");\n',...
            '      end\n',...
            '    else\n',...
            '      begin\n',...
            '        $display( "**** Test Complete with NO FAILURES. ****" );\n',...
            '      end\n',...
            '    $stop;\n\n',...
            ];
        else
            if~inputcplxty
                force_after_waitassert=['        ',inname,' <= ',inname,'_force[m + 1];\n'];
            else
                force_after_waitassert=['        ',inname,' <= ',inname,'_force[m + 1];\n',...
                '        ',inname_im,' <= ',inname_im,'_force[m + 1];\n'];
            end
            verilog_blocks=[verilog_blocks,...
            '    for (n = 0; n<= ',num2str(len*factor-1),'; n = n + 1)\n',...
            '      begin\n',...
            '      if (',testcondition,')\n',...
            display,...
            wait_after_assert,...
            '      if (',clk1,'== 1 & m + 1 <=',num2str(len-1),')\n',...
            '        begin\n',...
            force_after_waitassert,...
            '        m <= m + 1;\n',...
            '        end\n',...
            wait_after_force,...
            '      end\n',...
            '    if (m != ',num2str(len-1),')\n',...
            '      begin\n',...
            '        $display("',severitylevel,' in filter test: Wrong number of outputs were checked");\n',...
            '      end\n',...
            '    else\n',...
            '      begin\n',...
            '        $display( "**** Test Complete with NO FAILURES. ****" );\n',...
            '      end\n',...
            '    $stop;\n\n',...
            ];
        end
    else

        if outputsize==0
            testcondition=['abs_real($bitstoreal(',outname,') - $bitstoreal(',outname,'_expected[n])) >= 1.0e-9'];
        elseif inexactcompare


            if outputsigned==1
                testcondition=['abs(',outname,' - ',outname,'_expected[n]) > ',...
                num2str(comparethreshold)];
            else
                testcondition=['abs($signed(',outname,') - $signed(',outname,'_expected[n])) > ',...
                num2str(comparethreshold)];
            end
        else
            testcondition=[outname,' !== ',outname,'_expected[n]'];
        end

        severitylevel='ERROR';

        if latency==1
            wait_after_assert=['      # (2*',clk,'_hold);\n'];
            wait_after_force=['      # (',clk,'_period - 2*',clk,'_hold);\n'];
            n_adj=1;
        else
            wait_after_assert='';
            if isserializablefir(filterobj)
                ffact=hdlgetparameter('foldingfactor');
                if ffact>1
                    wait_after_force=['      # (',clk,'_period*',num2str(ffact),');\n'];
                else
                    wait_after_force=['      # (',clk,'_period);\n'];
                end
            else
                wait_after_force=['      # (',clk,'_period);\n'];
            end
            n_adj=latency-1;

        end

        if outputsize==0
            display=['        $display("',severitylevel,' in filter test at time %%t : Expected ''%%f'' Actual ''%%f''", ',...
            '$time, $bitstoreal(',outname,'_expected[n]), $bitstoreal(',outname,'));\n'];
        else
            display=['        $display("',severitylevel,' in filter test at time %%t : Expected ''%%h'' Actual ''%%h''", ',...
            '$time, ',outname,'_expected[n], ',outname,');\n'];
        end

        verilog_blocks=[verilog_blocks,...
        '    for (n = 0; n<= ',num2str(len-1),'; n = n + 1)\n',...
        '      begin\n',...
        '      if (',testcondition,')\n',...
        display,...
        wait_after_assert,...
        '      if (n + ',num2str(n_adj),' <= ',num2str(len-1),')\n',...
        '        ',inname,' <= ',inname,'_force[n + ',num2str(n_adj),'];\n',...
        wait_after_force,...
        '      end\n',...
        '    $display( "**** Test Complete with NO FAILURES. ****" );\n',...
        '    $stop;\n\n',...
        ];
    end

    verilog_blocks=[verilog_blocks,...
    '  end //',inname,'_gen;\n\n'];






    tbfid=fopen(tbfilename,'w');

    if tbfid==-1
        error(message('hdlfilter:generateverilogtb:fileerror',tbfilename));
    end

    verilog_module=[verilog_module_comment,verilog_timescale,verilog_module_decl];

    fprintf(tbfid,verilog_module);

    verilog_body1=[verilog_parameters,...
    verilog_signals,...
    inconstants_decl,...
    outconstants_decl];
    if inputcplxty
        verilog_body1=[verilog_body1,...
        inconstants_im_decl];
    end
    if outputcplxty
        verilog_body1=[verilog_body1,...
        outconstants_im_decl];
    end
    verilog_body1=[verilog_body1,...
    verilog_functions,...
    verilog_component_instances,...
    verilog_initial];
    fprintf(tbfid,verilog_body1);

    fprintf('### Please wait ...');

    for n=1:len

        if mod(n,1000)==0
            fprintf('.');
        end

        inconst=hdlconstantvalue(real(indata(n)),inputsize,inputbp,inputsigned,'hex');

        inconstants=['    ',inname,'_force [',num2str(n-1),'] <= '];
        if inputsize==0
            inconstants=[inconstants,'$realtobits(',inconst,');\n'];
        else
            inconstants=[inconstants,inconst,';\n'];
        end

        fprintf(tbfid,inconstants);
    end


    if inputcplxty
        for n=1:len

            if mod(n,1000)==0
                fprintf('.');
            end

            inconst=hdlconstantvalue(imag(indata(n)),inputsize,inputbp,inputsigned,'hex');

            inconstants=['    ',inname_im,'_force [',num2str(n-1),'] <= '];
            if inputsize==0
                inconstants=[inconstants,'$realtobits(',inconst,');\n'];
            else
                inconstants=[inconstants,inconst,';\n'];
            end

            fprintf(tbfid,inconstants);
        end

    end
    if outputcplxty
        lrange=2;
    else
        lrange=1;
    end

    for m=1:lrange
        for n=1:lenout
            if m==2
                outdataval=imag(outdata(n));
                outcomplexname=outname_im;
            else
                outdataval=real(outdata(n));
                outcomplexname=outname;
            end
            if mod(n,1000)==0
                fprintf('.');
            end

            outconst=hdlconstantvalue(outdataval,outputsize,outputbp,outputsigned,'hex');

            outconstants=['    ',outcomplexname,'_expected [',num2str(n-1),'] <= '];
            if outputsize==0
                outconstants=[outconstants,'$realtobits(',outconst,');\n'];
            else
                outconstants=[outconstants,outconst,';\n'];
            end

            fprintf(tbfid,outconstants);
        end
    end
    fprintf('\n');

    verilog_body=[verilog_initial_end,...
    verilog_blocks,...
    verilog_module_end];
    fprintf(tbfid,verilog_body);
    fclose(tbfid);

    fprintf('### Done generating Verilog test bench.\n');



    function oldcastbeforesum=overridecastbeforesum(filterobj,value)

        if nargin==1
            value=logical(hdlgetparameter('cast_before_sum'));
        end

        oldcastbeforesum=false;
        if any(strcmpi('castbeforesum',fieldnames(get(filterobj))))
            oldcastbeforesum=get(filterobj,'CastBeforeSum');
            if(get(filterobj,'CastBeforeSum')~=value)
                try
                    set(filterobj,'CastBeforeSum',value);
                catch
                end
            end
        end



        function result=isinterpolator(filterobj)

            if isa(filterobj,'dsp.internal.mfilt.cicinterp')||isa(filterobj,'dsp.internal.mfilt.firinterp')...
                ||isa(filterobj,'dsp.internal.mfilt.holdinterp')||isa(filterobj,'dsp.internal.mfilt.linearinterp')
                result=true;
            elseif isa(filterobj,'mfilt.cascade')
                rcf=getratechangefactors(filterobj);
                result=any(rcf(:,1)~=1)&&all(rcf(:,2)==1);
            else
                result=false;
            end



            function result=isdecimator(filterobj)


                if isa(filterobj,'mfilt.cicdecim')||...
                    isa(filterobj,'mfilt.firtdecim')||...
                    isa(filterobj,'mfilt.firdecim')
                    result=true;
                elseif isa(filterobj,'mfilt.cascade')
                    rcf=getratechangefactors(filterobj);
                    result=any(rcf(:,2)~=1)&&all(rcf(:,1)==1);
                else
                    result=false;
                end



                function[wordlen,fraclen]=getinputwordfraclength(filterobj)

                    if isa(filterobj,'dfilt.cascade')
                        if strcmpi(filterobj.Stage(1).Arithmetic,'fixed')
                            wordlen=get(filterobj.Stage(1),'InputWordLength');
                            fraclen=get(filterobj.Stage(1),'InputFracLength');
                        else
                            wordlen=0;
                            fraclen=0;
                        end
                    else
                        if strcmpi(filterobj.Arithmetic,'fixed')
                            wordlen=get(filterobj,'InputWordLength');
                            fraclen=get(filterobj,'InputFracLength');
                        else
                            wordlen=0;
                            fraclen=0;
                        end
                    end



                    function[wordlen,fraclen]=getoutputwordfraclength(filterobj)

                        if isa(filterobj,'dfilt.cascade')
                            if strcmpi(filterobj.Stage(end).Arithmetic,'fixed')
                                wordlen=get(filterobj.Stage(end),'OutputWordLength');
                                fraclen=get(filterobj.Stage(end),'OutputFracLength');
                            else
                                wordlen=0;
                                fraclen=0;
                            end
                        else
                            if strcmpi(filterobj.Arithmetic,'fixed')
                                wordlen=get(filterobj,'OutputWordLength');
                                fraclen=get(filterobj,'OutputFracLength');
                            else
                                wordlen=0;
                                fraclen=0;
                            end
                        end


                        function result=isserializablefir(filterobj)

                            if isa(filterobj,'dfilt.dffir')||...
                                isa(filterobj,'dfilt.dfsymfir')||...
                                isa(filterobj,'dfilt.dfasymfir')||...
                                isa(filterobj,'mfilt.firdecim')||...
                                isa(filterobj,'dsp.internal.mfilt.firinterp')
                                result=true;
                            else
                                result=false;
                            end



                            function serial=isserialized(filterobj)

                                ssi=hdlgetparameter('filter_serialsegment_inputs');
                                reuseacc=hdlgetparameter('filter_reuseaccum');
                                if isscalar(ssi)
                                    if ssi==-1&&~reuseacc
                                        serial=false;
                                    else
                                        serial=true;
                                    end
                                else
                                    if isequal(ones(1,length(ssi)),ssi)
                                        serial=false;
                                    else
                                        serial=true;
                                    end
                                end

                                function da=isfirdecim_da(filterobj)

                                    if~(isa(filterobj,'mfilt.firdecim'))
                                        da=false;
                                        return
                                    end
                                    lpi=hdlgetparameter('filter_dalutpartition');
                                    if isscalar(lpi)
                                        if lpi==-1
                                            da=false;
                                        else
                                            da=true;
                                        end
                                    else
                                        da=true;
                                    end

                                    function da=isfirinterp_da(filterobj)

                                        if~(isa(filterobj,'dsp.internal.mfilt.firinterp'))
                                            da=false;
                                            return
                                        end
                                        lpi=hdlgetparameter('filter_dalutpartition');
                                        if isscalar(lpi)
                                            if lpi==-1
                                                da=false;
                                            else
                                                da=true;
                                            end
                                        else
                                            da=true;
                                        end








