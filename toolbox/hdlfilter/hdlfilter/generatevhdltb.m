function generatevhdltb(filterobj,varargin)
    if~(builtin('license','checkout','Filter_Design_HDL_Coder'))
        error(message('hdlfilter:generatevhdltb:nolicenseavailable'));
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
            error(message('hdlfilter:generatevhdltb:unsupportedarch',class(filterobj)));
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
            error(message('hdlfilter:generatevhdltb:unsupportedarithmetic',arithtype));
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
            error(message('hdlfilter:generatevhdltb:unsupportedarithmetic',arithtype));
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
            error(message('hdlfilter:generatevhdltb:unsupportedarithmetic',arithtype));
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
            error(message('hdlfilter:generatevhdltb:unsupportedarithmetic',arithtype));
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
            error(message('hdlfilter:generatevhdltb:unsupportedarithmetic',arithtype));
        end


    otherwise
        error(message('hdlfilter:generatevhdltb:unsupportedarch',class(filterobj)));
    end

    if isempty(hdlgetparameter('target_language'))
        warning(message('hdlfilter:generatevhdltb:usingdefaults'));
        hdldefaultfilterparameters('vhdl');
    end

    hdlvhdlmode();

    bdt=hdlgetparameter('base_data_type');
    hdlsetparameter('tb_target_language','vhdl');

    if isempty(hdlgetparameter('tb_stimulus'))&&isempty(hdlgetparameter('tb_user_stimulus'))
        warning(message('hdlfilter:generatevhdltb:usingdefaultstimulus'));
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
                error(message('hdlfilter:generatevhdltb:directoryfailure',hdlGetCodegendir));
            case 'matlab:mkdir:oserror',
                error(message('hdlfilter:generatevhdltb:createdirectoryfailure',hdlGetCodegendir));
            otherwise

                error(message('hdlfilter:generatevhdltb:codegendirerror',mess));
            end
        end
    else
        error(message('hdlfilter:generatevhdltb:unsupportedarch',class(filterobj)));
    end

    fprintf('### Starting generation of VHDL Test Bench\n');

    latency=1+hdlfilterlatency(filterobj);




    inexactcompare=0;

    if hdlgetparameter('bit_true_to_filter')==0||...
        (isfir(filterobj)&&~strcmpi(filterstruct,'firt')...
        &&~strcmpi(hdlgetparameter('filter_fir_final_adder'),'linear'))||...
        ~strcmpi(hdlgetparameter('filter_multipliers'),'multiplier')
        inexactcompare=1;
        warning(message('hdlfilter:generatevhdltb:inexactresults'));

        if isempty(hdlgetparameter('error_margin'))
            comparethreshold=15;
            warning(message('hdlfilter:generatevhdltb:defaulterrormargin'));
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
    if hdlgetparameter('filter_input_type_std_logic')==1||...
        strcmpi(hdlgetparameter('filter_target_language'),'verilog')
        [inputvtype,inputsltype]=hdlgetporttypesfromsizes(inputsize,inputbp,inputsigned);
        input_is_std_logic=1;
    else
        [inputvtype,inputsltype]=hdlgettypesfromsizes(inputsize,inputbp,inputsigned);
        input_is_std_logic=0;
    end
    if arithisdouble
        input_is_std_logic=false;
    end

    [outputsize,outputbp]=getoutputwordfraclength(filterobj);
    outputsigned=true;
    if hdlgetparameter('filter_output_type_std_logic')==1||...
        strcmpi(hdlgetparameter('filter_target_language'),'verilog')
        [outputvtype,outputsltype]=hdlgetporttypesfromsizes(outputsize,outputbp,outputsigned);
        output_is_std_logic=1;
    else
        [outputvtype,outputsltype]=hdlgettypesfromsizes(outputsize,outputbp,outputsigned);
        output_is_std_logic=0;
    end
    if arithisdouble
        output_is_std_logic=false;
    end


    oldcastbeforesum=overridecastbeforesum(filterobj);





    fprintf('### Generating input stimulus\n');

    inputdata=generatetbstimulus(filterobj,varargin{:});
    len=length(inputdata);

    if len<latency
        error(message('hdlfilter:generatevhdltb:notenoughinput',len,latency));
    end

    if arithisdouble&&~all(isfinite(inputdata))
        error(message('hdlfilter:generatevhdltb:nonefinitenumber'));
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
        error(message('hdlfilter:generatevhdltb:nonefinitenumber'));
    end

    overridecastbeforesum(filterobj,oldcastbeforesum);

    tbfilename=fullfile(hdlGetCodegendir,...
    [hdlgetparameter('tb_name'),hdlgetparameter('filename_suffix')]);

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
        hdlgetparameter('rcs_cvs_tag'),[]);
    else
        header_comment=hdlentitycomment(hdlgetparameter('tb_name'),...
        hdlgetparameter('rcs_cvs_tag'),...
        info(filterobj));
    end



    entity_name=hdlentitytop;
    if isempty(entity_name)
        if isempty(hdlgetparameter('filter_name'))
            error(message('hdlfilter:generatevhdltb:nofilter'));
        else
            entity_name=hdlgetparameter('filter_name');
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
    [~,entity_input]=hdlnewsignal(innamename,'filter',-1,inputcplxty,0,inputvtype,inputsltype);
    inname=hdlsignalname(entity_input);
    if inputcplxty
        inname_im=hdlsignalname(hdlsignalimag(entity_input));
    end
    if isinterpolator(filterobj)||isdecimator(filterobj)
        if hdlgetparameter('clockinputs')==2
            [clk1,clk1idx]=hdlnewsignal([clkname,'1'],'filter',-1,0,0,bdt,'boolean');
            [clken1,notused]=hdlnewsignal([clkenname,'1'],'filter',-1,0,0,bdt,'boolean');
            [reset1,notused]=hdlnewsignal([resetname,'1'],'filter',-1,0,0,bdt,'boolean');
        end
    end






    hdllastinputsignal;
    [~,entity_output]=hdlnewsignal(outnamename,'filter',-1,outputcplxty,0,outputvtype,outputsltype);
    outname=hdlsignalname(entity_output);
    if outputcplxty
        outname_im=hdlsignalname(hdlsignalimag(entity_output));
    end



    if isinterpolator(filterobj)||isdecimator(filterobj)
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
        sprintf('              %-32s',portnames{n}),...
        ' => ',portnames{n},',\n'];
    end
    portmap=portmap(1:end-3);

    vhdl_entity_comment=header_comment;
    [vhdl_entity_library,vhdl_entity_package,vhdl_entity_decl,...
    vhdl_entity_end]=vhdlentityinit(hdlgetparameter('tb_name'));

    vhdl_entity_ports='';

    vhdl_arch_comment='----------------------------------------------------------------\n';
    vhdl_arch_decl=['ARCHITECTURE test OF ',hdlgetparameter('tb_name'),' IS\n'];
    vhdl_arch_end=['END test;\n'];

    vhdl_arch_component_decl='';
    vhdl_arch_component_config='';
    vhdl_arch_functions='';
    vhdl_arch_typedefs='  -- Type Definitions\n';
    vhdl_arch_constants='  -- Constants\n';
    vhdl_arch_signals='  -- Signals\n';
    vhdl_arch_begin='\n\nBEGIN\n';
    vhdl_arch_body_component_instances='';
    vhdl_arch_body_blocks='  -- Block Statements\n';
    vhdl_arch_body_output_assignments='';

    vhdl_arch_component_decl=[vhdl_arch_component_decl,...
    '  COMPONENT ',entity_name,'\n',...
    hdl_entity_ports,...
    '    END COMPONENT;\n\n'];
    vhdl_arch_component_config=['  FOR ALL : ',entity_name,'\n',...
    '    USE ENTITY work.',entity_name,'(rtl);\n\n'];

    vhdl_arch_functions=[vhdl_arch_functions,...
    '  FUNCTION to_hex( x : IN std_logic_vector) RETURN string IS\n',...
    '    VARIABLE result  : STRING(1 TO 256); -- 1024 bits max\n',...
    '    VARIABLE i       : INTEGER;\n',...
    '    VARIABLE imod    : INTEGER;\n',...
    '    VARIABLE j       : INTEGER;\n',...
    '    VARIABLE newx    : std_logic_vector(1023 DOWNTO 0);\n',...
    '    BEGIN\n',...
    '      newx := (OTHERS => ''0'');\n',...
    '      newx(x''RANGE) := x;\n',...
    '      i := x''LENGTH-1;\n',...
    '      imod := x''LENGTH MOD 4;\n',...
    '      IF    imod = 1 THEN i := i+3;\n',...
    '      ELSIF imod = 2 THEN i := i+2;\n',...
    '      ELSIF imod = 3 THEN i := i+1;\n',...
    '      END IF;\n',...
    '      j := 1;\n',...
    '      WHILE i >= 3 LOOP\n',...
    '        IF    newx(i DOWNTO (i-3)) = "0000" THEN result(j) := ''0'';\n',...
    '        ELSIF newx(i DOWNTO (i-3)) = "0001" THEN result(j) := ''1'';\n',...
    '        ELSIF newx(i DOWNTO (i-3)) = "0010" THEN result(j) := ''2'';\n',...
    '        ELSIF newx(i DOWNTO (i-3)) = "0011" THEN result(j) := ''3'';\n',...
    '        ELSIF newx(i DOWNTO (i-3)) = "0100" THEN result(j) := ''4'';\n',...
    '        ELSIF newx(i DOWNTO (i-3)) = "0101" THEN result(j) := ''5'';\n',...
    '        ELSIF newx(i DOWNTO (i-3)) = "0110" THEN result(j) := ''6'';\n',...
    '        ELSIF newx(i DOWNTO (i-3)) = "0111" THEN result(j) := ''7'';\n',...
    '        ELSIF newx(i DOWNTO (i-3)) = "1000" THEN result(j) := ''8'';\n',...
    '        ELSIF newx(i DOWNTO (i-3)) = "1001" THEN result(j) := ''9'';\n',...
    '        ELSIF newx(i DOWNTO (i-3)) = "1010" THEN result(j) := ''A'';\n',...
    '        ELSIF newx(i DOWNTO (i-3)) = "1011" THEN result(j) := ''B'';\n',...
    '        ELSIF newx(i DOWNTO (i-3)) = "1100" THEN result(j) := ''C'';\n',...
    '        ELSIF newx(i DOWNTO (i-3)) = "1101" THEN result(j) := ''D'';\n',...
    '        ELSIF newx(i DOWNTO (i-3)) = "1110" THEN result(j) := ''E'';\n',...
    '        ELSIF newx(i DOWNTO (i-3)) = "1111" THEN result(j) := ''F'';\n',...
    '        ELSE result(j) := ''X'';\n',...
    '        END IF;\n',...
    '\n',...
    '        i := i-4;\n',...
    '        j := j+1;\n',...
    '      END LOOP;\n',...
    '      RETURN result(1 TO j-1);\n',...
    '    END;\n',...
    '\n',...
    '  FUNCTION to_hex( x : IN bit_vector ) RETURN string IS\n',...
    '    BEGIN\n',...
    '      RETURN to_hex( to_stdlogicvector(x) );\n',...
    '    END;\n'];

    if input_is_std_logic==0||output_is_std_logic==0
        vhdl_arch_functions=[vhdl_arch_functions,...
        '\n',...
        '  FUNCTION to_hex( x : IN signed ) RETURN string IS\n',...
        '    BEGIN\n',...
        '      RETURN to_hex( std_logic_vector(x) );\n',...
        '    END;\n',...
        '\n',...
        '  FUNCTION to_hex( x : IN unsigned ) RETURN string IS\n',...
        '    BEGIN\n',...
        '      RETURN to_hex( std_logic_vector(x) );\n',...
        '    END;\n'];
    end

    if strcmpi(outputvtype,'real')
        vhdl_arch_functions=[vhdl_arch_functions,...
        '  FUNCTION to_hex( x : IN real ) RETURN string IS\n',...
        '    BEGIN\n',...
        '      RETURN real''image(x);\n',...
        '    END;\n\n'];
    else
        vhdl_arch_functions=[vhdl_arch_functions,'\n'];
    end

    thigh=hdlgetparameter('force_clock_high_time');
    tlow=hdlgetparameter('force_clock_low_time');
    tcycle=tlow+thigh;
    thold=hdlgetparameter('force_hold_time');

    if latency==1&&(2*thold>=tcycle)
        error(message('hdlfilter:generatevhdltb:combtimingerror',thold,tcycle));
    elseif thold>=tcycle
        error(message('hdlfilter:generatevhdltb:timingerror',thold,tcycle));
    end

    vhdl_arch_body_component_instances=[vhdl_arch_body_component_instances,...
    '  ',hdlgetparameter('Instance_prefix'),entity_name,': ',entity_name,'\n',...
    '    PORT MAP (\n',...
    portmap,...
    '      );\n\n'];

    vhdl_arch_signals=[vhdl_arch_signals,...
    '  CONSTANT ',sprintf('%-32s',[clk,'_high']),...
    ' : time := ',num2str(thigh),' ns;\n',...
    '  CONSTANT ',sprintf('%-32s',[clk,'_low']),...
    ' : time := ',num2str(tlow),' ns;\n',...
    '  CONSTANT ',sprintf('%-32s',[clk,'_period']),...
    ' : time := ',num2str(tcycle),' ns;\n',...
    '  CONSTANT ',sprintf('%-32s',[clk,'_hold']),...
    ' : time := ',num2str(thold),' ns;\n'];

    vhdl_arch_signals=[vhdl_arch_signals,'\n',...
    '  SIGNAL ',sprintf('%-32s',clk),' : std_logic;\n',...
    '  SIGNAL ',sprintf('%-32s',clken),' : std_logic;\n',...
    '  SIGNAL ',sprintf('%-32s',reset),' : std_logic;\n\n',...
    '  SIGNAL ',sprintf('%-32s',inname),' : ',inputvtype,';\n',...
    '  SIGNAL ',sprintf('%-32s',outname),' : ',outputvtype,';\n',...
    ];
    if inputcplxty
        vhdl_arch_signals=[vhdl_arch_signals,'\n',...
        '  SIGNAL ',sprintf('%-32s',inname_im),' : ',inputvtype,';\n',...
        ];
    end
    if outputcplxty
        vhdl_arch_signals=[vhdl_arch_signals,'\n',...
        '  SIGNAL ',sprintf('%-32s',outname_im),' : ',outputvtype,';\n',...
        ];
    end

    if strcmpi(filterstruct,'firsrc')
        vhdl_arch_signals=[vhdl_arch_signals,...
        '  SIGNAL ',sprintf('%-32s',ceinname),' : std_logic;\n'];
    end
    if isinterpolator(filterobj)||isdecimator(filterobj)||strcmpi(filterstruct,'firsrc')
        if hdlgetparameter('clockinputs')==1
            vhdl_arch_signals=[vhdl_arch_signals,...
            '  SIGNAL ',sprintf('%-32s',ceoutname),' : std_logic;\n\n'];
        else
            vhdl_arch_signals=[vhdl_arch_signals,...
            '  SIGNAL ',sprintf('%-32s',clk1),' : std_logic;\n'];
            vhdl_arch_signals=[vhdl_arch_signals,...
            '  SIGNAL ',sprintf('%-32s',clken1),' : std_logic;\n'];
            vhdl_arch_signals=[vhdl_arch_signals,...
            '  SIGNAL ',sprintf('%-32s',reset1),' : std_logic;\n'];
            vhdl_arch_signals=[vhdl_arch_signals,...
            '  SIGNAL ',sprintf('%-32s',tempcountname),' : integer;\n\n'];
        end
    else
        vhdl_arch_signals=[vhdl_arch_signals,...
        '\n'];
    end

    if hdlgetparameter('force_clockenable')==1
        clkenvalue=hdlgetparameter('force_clockenable_value');
        vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
        '  ',clken,' <= ''',sprintf('%d',clkenvalue),''';\n\n'];
    end

    if hdlgetparameter('force_clock')==1
        vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
        '  ',clk,'_gen: PROCESS\n',...
        '  BEGIN\n',...
        '    ',clk,' <= ''1'';\n',...
        '    WAIT FOR ',clk,'_high;\n',...
        '    ',clk,' <= ''0'';\n',...
        '    WAIT FOR ',clk,'_low;\n',...
        '  END PROCESS ',clk,'_gen;\n\n'];

        nreset=2;
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
                vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
                '  ',clk1,' <= TRANSPORT ',clk,' after ',num2str(clkdelay),' ns;\n',...
                '  ',clken1,' <= ',clken,';\n',...
                '  ',reset1,' <= ',reset,';\n\n'];
            else
                if hdlgetparameter('force_reset_value')==1
                    resetvalue='''1''';
                    resetvalue_n='''0''';
                else
                    resetvalue='''0''';
                    resetvalue_n='''1''';
                end

                [reset2,reset2idx]=hdlnewsignal([reset,'2'],'filter',-1,0,0,bdt,'boolean');
                vhdl_arch_signals=[vhdl_arch_signals,makehdlsignaldecl(reset2idx)];
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
                vhdl_arch_signals=[vhdl_arch_signals,makehdlsignaldecl(ring_phase)];

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
                    vhdl_arch_signals=[vhdl_arch_signals,makehdlsignaldecl(clk1signals)];
                end
                vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
                clk1body,...
                '  ',clk1,' <= ''1'' after ',num2str(clkdelay),' ns when ',clk1temp,' = ''1'' else ''0'' after ',num2str(clkdelay),' ns;\n',...
                '  ',clken1,' <= ',clken,';\n'];

                if hdlgetparameter('async_reset')==1
                    vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
                    '  ',reset1,' <= ',reset,';\n'];
                end
                vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
                '  ',reset2,' <= ',resetvalue,', ',resetvalue_n,' after 1 ns;\n\n'];

            end
        end
    end

    if hdlgetparameter('force_reset')==1
        rassertval=sprintf('''%d''',hdlgetparameter('force_reset_value'));
        rdeassertval=sprintf('''%d''',1-hdlgetparameter('force_reset_value'));
        tend=(2*tcycle+thold);

        vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
        '  ',reset,'_gen: PROCESS\n',...
        '  BEGIN\n',...
        '    ',reset,' <= ',rassertval,';\n',...
        '    WAIT FOR ',clk,'_period*2 + ',clk,'_hold;\n',...
        '    ',reset,' <= ',rdeassertval,';\n',...
        '    WAIT;\n',...
        '  END PROCESS ',reset,'_gen;\n\n'];


        if(hdlgetparameter('async_reset')==0&&hdlgetparameter('clockinputs')==2)
            vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
            '  ',reset,'1_gen: PROCESS\n',...
            '  BEGIN\n',...
            '    ',reset1,' <= ',rassertval,';\n',...
            '    WAIT UNTIL ',clk1,char(39),'event AND ',clk1,' =  ''1'';\n',...
            '    WAIT FOR ',clk,'_hold;\n',...
            '    ',reset1,' <= ',rdeassertval,';\n',...
            '    WAIT;\n',...
            '  END PROCESS ',reset,'1_gen;\n\n'];
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

    vhdl_arch_typedefs=[vhdl_arch_typedefs,...
    '  TYPE ',inname,'_table IS ARRAY (0 TO ',num2str(inveclen),') OF ',inputvtype,';\n',...
    '  TYPE ',outname,'_table IS ARRAY (0 TO ',num2str(outveclen),') OF ',outputvtype,';\n'];

    inconstants=['  CONSTANT ',inname,'_force : ',inname,'_table :=\n    (\n'];
    outconstants=['  CONSTANT ',outname,'_expected : ',outname,'_table :=\n    (\n'];
    if inputcplxty
        inconstants_im=['  CONSTANT ',inname,'_force : ',inname,'_table :=\n    (\n'];
    end
    if outputcplxty
        outconstants_im=['  CONSTANT ',outname,'_expected : ',outname,'_table :=\n    (\n'];
    end
    if latency==1
        hold_sign='-';
    else
        hold_sign='+';
    end

    vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
    '  ',inname,'_gen: PROCESS\n'];

    if isinterpolator(filterobj)||isdecimator(filterobj)
        vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
        '    VARIABLE m : INTEGER := 0;\n'];
    end
    if strcmpi(filterstruct,'firsrc')
        vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
        '    VARIABLE m_in : INTEGER := 0;\n',...
        '    VARIABLE m_out : INTEGER := 0;\n'];
    end
    vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
    '  BEGIN\n',...
    '    ',inname,' <= ',inname,'_force(0);\n'];
    if inputcplxty
        vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
        '    ',inname_im,' <= ',inname_im,'_force(0);\n'];
    end

    if isinterpolator(filterobj)&&...
        hdlgetparameter('filter_registered_input')&&...
        ~(isa(filterobj,'dsp.internal.mfilt.cicinterp')&&...
        hdlgetparameter('clockinputs')==2)&&~isserialized(filterobj)
        vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
        '    WAIT FOR ',clk,'_period*4;\n'];
    else
        vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
        '    WAIT FOR ',clk,'_period*3 ',hold_sign,' ',clk,'_hold;\n'];
    end


    for n=1:latency-2
        if isinterpolator(filterobj)
            if hdlgetparameter('clockinputs')==1
                if isfirinterp_da(filterobj)||(isserializablefir(filterobj)&&isserialized(filterobj))

                    ffact=hdlgetparameter('foldingfactor');
                    if ffact>1
                        vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
                        '    IF ',ceoutname,'= ''1'' THEN\n',...
                        '      ',inname,' <= ',inname,'_force(m + 1);\n',...
                        '      m := m + 1;\n',...
                        '    END IF;\n',...
                        '    WAIT FOR ',clk,'_period*',num2str(ffact),';\n'];
                    else
                        vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
                        '    IF ',ceoutname,'= ''1'' THEN\n',...
                        '      ',inname,' <= ',inname,'_force(m + 1);\n',...
                        '      m := m + 1;\n',...
                        '    END IF;\n',...
                        '    WAIT FOR ',clk,'_period;\n'];
                    end
                else
                    vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
                    '    IF ',ceoutname,'= ''1'' THEN\n',...
                    '      ',inname,' <= ',inname,'_force(m + 1);\n',...
                    '      m := m + 1;\n',...
                    '    END IF;\n',...
                    '    WAIT FOR ',clk,'_period;\n'];
                end
            else
                if(isserializablefir(filterobj)&&isserialized(filterobj))

                    ffact=hdlgetparameter('foldingfactor');
                    vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
                    '    IF ',clk1,'= ''1'' THEN\n',...
                    '      ',inname,' <= ',inname,'_force(m + 1);\n'];
                    if inputcplxty
                        vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
                        '      ',inname_im,' <= ',inname_im,'_force(m + 1);\n'];
                    end

                    vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
                    '      m := m + 1;\n',...
                    '    END IF;\n',...
                    '    WAIT FOR ',clk,'_period*',num2str(ffact),';\n'];
                else
                    vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
                    '    IF ',clk1,'= ''1'' THEN\n',...
                    '      ',inname,' <= ',inname,'_force(m + 1);\n'];
                    if inputcplxty
                        vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
                        '      ',inname_im,' <= ',inname_im,'_force(m + 1);\n'];
                    end
                    vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
                    '      m := m + 1;\n',...
                    '    END IF;\n',...
                    '    WAIT FOR ',clk,'_period;\n'];
                end
            end

        else
            if isserializablefir(filterobj)||isfirdecim_da(filterobj)

                ffact=hdlgetparameter('foldingfactor');
                if ffact>1
                    vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
                    '    ',inname,' <= ',inname,'_force(',num2str(n),');\n'];
                    if inputcplxty
                        vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
                        '    ',inname_im,' <= ',inname_im,'_force(',num2str(n),');\n'];
                    end
                    vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
                    '    WAIT FOR ',clk,'_period*',num2str(ffact),';\n'];
                else
                    vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
                    '    ',inname,' <= ',inname,'_force(',num2str(n),');\n'];
                    if inputcplxty
                        vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
                        '    ',inname_im,' <= ',inname_im,'_force(',num2str(n),');\n'];
                    end
                    vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
                    '    WAIT FOR ',clk,'_period;\n'];
                end

            else
                vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
                '    ',inname,' <= ',inname,'_force(',num2str(n),');\n'];
                if inputcplxty
                    vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
                    '    ',inname_im,' <= ',inname_im,'_force(',num2str(n),');\n'];
                end
                vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
                '    WAIT FOR ',clk,'_period;\n'];
            end
        end

    end


    if isdecimator(filterobj)

        if strcmpi(outputvtype,'real')
            if~outputcplxty
                testcondition=['abs( ',outname,' - ',outname,'_expected(m) ) < 1.0e-9'];
            else
                testcondition=['abs( ',outname,' - ',outname,'_expected(m) ) < 1.0e-9 AND abs( ',outname_im,' - ',outname_im,'_expected(m) ) < 1.0e-9'];
            end
        elseif inexactcompare

            if outputsigned==1&&output_is_std_logic==0
                if~outputcplxty
                    testcondition=['abs(',outname,' - ',outname,'_expected(m) ) <= ',...
                    num2str(comparethreshold)];
                else
                    testcondition=['abs(',outname,' - ',outname,'_expected(m) ) <= ',...
                    num2str(comparethreshold),' AND ',...
                    'abs(',outname_im,' - ',outname_im,'_expected(m) ) <= ',...
                    num2str(comparethreshold)];
                end

            elseif outputsigned==1&&output_is_std_logic==1
                if~outputcplxty
                    testcondition=['abs(signed( ',outname,' ) - signed( ',outname,'_expected(m) )) <= ',...
                    num2str(comparethreshold)];
                else
                    testcondition=['abs(signed( ',outname,' ) - signed( ',outname,'_expected(m) )) <= ',...
                    num2str(comparethreshold),' AND ',...
                    'abs(signed( ',outname_im,' ) - signed( ',outname_im,'_expected(m) )) <= ',...
                    num2str(comparethreshold)];
                end

            else
                if~outputcplxty
                    testcondition=['abs(signed( ''0'' & ',outname,' ) - signed( ''0'' & ',outname,'_expected(m) )) <= ',...
                    num2str(comparethreshold)];
                else
                    testcondition=['abs(signed( ''0'' & ',outname,' ) - signed( ''0'' & ',outname,'_expected(m) )) <= ',...
                    num2str(comparethreshold),' AND  ',...
                    'abs(signed( ''0'' & ',outname_im,' ) - signed( ''0'' & ',outname_im,'_expected(m) )) <= ',...
                    num2str(comparethreshold)];
                end

            end
        else
            if~outputcplxty
                testcondition=[outname,' = ',outname,'_expected(m)'];
            else
                testcondition=[outname,' = ',outname,'_expected(m) AND ',outname_im,' = ',outname_im,'_expected(m)'];
            end
        end

        severitylevel='ERROR';

        if latency==1
            wait_after_assert=['      WAIT FOR 2*',clk,'_hold;\n'];
            wait_after_force=['      WAIT FOR ',clk,'_period - 2*',clk,'_hold;\n'];
            n_adj=1;
        else
            wait_after_assert='';

            if isfirdecim_da(filterobj)||isserializablefir(filterobj)
                ffact=hdlgetparameter('foldingfactor');
                if ffact>1
                    wait_after_force=['      WAIT FOR ',clk,'_period*',num2str(ffact),';\n'];
                else
                    wait_after_force=['      WAIT FOR ',clk,'_period;\n'];
                end
            else
                wait_after_force=['      WAIT FOR ',clk,'_period;\n'];
            end
            n_adj=latency-1;
        end
        if~outputcplxty
            assert_section=['      ASSERT ',testcondition,'\n',...
            '        REPORT "Error in filter test: Expected " \n',...
            '               & to_hex(',outname,'_expected(m))\n',...
            '               & " Actual "\n',...
            '               & to_hex(',outname,')\n',...
            '        SEVERITY ',severitylevel,';\n'];

        else
            assert_section=['      ASSERT ',testcondition,'\n',...
            '        REPORT "Error in filter test: Expected (real): " \n',...
            '               & to_hex(',outname,'_expected(m))\n',...
            '               & " vs Actual (real): "\n',...
            '               & to_hex(',outname,') & " and Expected (imag): "\n',...
            '               & to_hex(',outname_im,'_expected(m))\n',...
            '               & " vs Actual (imag): "\n',...
            '               & to_hex(',outname_im,')\n',...
            '        SEVERITY ',severitylevel,';\n'];

        end
        if~inputcplxty
            force_input_section=['    IF n + ',num2str(n_adj),' <= ',num2str(len-1),' THEN\n',...
            '        ',inname,' <= ',inname,'_force(n + ',num2str(n_adj),');\n',...
            '      END IF;\n'];
        else
            force_input_section=['    IF n + ',num2str(n_adj),' <= ',num2str(len-1),' THEN\n',...
            '        ',inname,' <= ',inname,'_force(n + ',num2str(n_adj),');\n',...
            '        ',inname_im,' <= ',inname_im,'_force(n + ',num2str(n_adj),');\n',...
            '      END IF;\n'];
        end
        if hdlgetparameter('clockinputs')==1
            vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
            '    FOR n IN 0 TO ',num2str(len-1+latency),' LOOP\n',...
            '      IF ',ceoutname,' = ''1'' ',...
            'AND m < ',num2str(lenout),' THEN\n',...
            '  ',assert_section,...
            '        m := m + 1;\n',...
            '      END IF;\n',...
            '  ',wait_after_assert,...
            force_input_section,...
            wait_after_force,...
            '    END LOOP;\n',...
            '    IF m /= ',num2str(lenout),' THEN\n',...
            '      ASSERT FALSE REPORT ',...
            '"Error in filter test: Wrong number of outputs were checked" SEVERITY FAILURE;\n',...
            '    ELSE\n',...
            '      ASSERT FALSE REPORT "**** Test Complete with NO FAILURES. ****" SEVERITY FAILURE;\n',...
            '    END IF;\n',...
            ];
        else
            vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
            '    FOR n IN 0 TO ',num2str(len-1+latency),' LOOP\n',...
            '      IF n mod ',num2str(factor),' = 0 AND m < ',num2str(lenout),' THEN\n',...
            '  ',assert_section,...
            '        m := m + 1;\n',...
            '      END IF;\n',...
            '  ',wait_after_assert,...
            force_input_section,...
            wait_after_force,...
            '    END LOOP;\n',...
            '    IF m /= ',num2str(lenout),' THEN\n',...
            '      ASSERT FALSE REPORT ',...
            '"Error in filter test: Wrong number of outputs were checked" SEVERITY FAILURE;\n',...
            '    ELSE\n',...
            '      ASSERT FALSE REPORT "**** Test Complete with NO FAILURES. ****" SEVERITY FAILURE;\n',...
            '    END IF;\n',...
            ];
        end
    elseif isinterpolator(filterobj)
        if strcmpi(outputvtype,'real')
            testcondition=['abs( ',outname,' - ',outname,'_expected(n) ) < 1.0e-9'];
        elseif inexactcompare

            if outputsigned==1&&output_is_std_logic==0
                testcondition=['abs(',outname,' - ',outname,'_expected(n) ) <= ',...
                num2str(comparethreshold)];
            elseif outputsigned==1&&output_is_std_logic==1
                testcondition=['abs(signed( ',outname,' ) - signed( ',outname,'_expected(n) )) <= ',...
                num2str(comparethreshold)];
            else
                testcondition=['abs(signed( ''0'' & ',outname,' ) - signed( ''0'' & ',outname,'_expected(n) )) <= ',...
                num2str(comparethreshold)];
            end
        else
            if~outputcplxty
                testcondition=[outname,' = ',outname,'_expected(n)'];
            else
                testcondition=[outname,' = ',outname,'_expected(n) AND ',outname_im,' = ',outname_im,'_expected(n)'];
            end
        end

        severitylevel='ERROR';

        if latency==1
            wait_after_assert=['      WAIT FOR 2*',clk,'_hold;\n'];
            wait_after_force=['      WAIT FOR ',clk,'_period - 2*',clk,'_hold;\n'];
            n_adj=1;
        else
            wait_after_assert='';

            if isfirinterp_da(filterobj)||(isserializablefir(filterobj)&&isserialized(filterobj))
                ffact=hdlgetparameter('foldingfactor');
                if ffact>1
                    wait_after_force=['      WAIT FOR ',clk,'_period*',num2str(ffact),';\n'];
                else
                    wait_after_force=['      WAIT FOR ',clk,'_period;\n'];
                end
            else
                wait_after_force=['      WAIT FOR ',clk,'_period;\n'];
            end
            n_adj=latency-1;
        end
        if~outputcplxty
            assert_section=['      ASSERT ',testcondition,'\n',...
            '        REPORT "Error in filter test: Expected " \n',...
            '               & to_hex(',outname,'_expected(n))\n',...
            '               & " Actual "\n',...
            '               & to_hex(',outname,')\n',...
            '        SEVERITY ',severitylevel,';\n'];
        else
            assert_section=['      ASSERT ',testcondition,'\n',...
            '        REPORT "Error in filter test: Expected (real): " \n',...
            '               & to_hex(',outname,'_expected(n))\n',...
            '               & " vs. Actual(real): "\n',...
            '               & to_hex(',outname,')\n',...
            '               & " and Expected (imag): " \n',...
            '               & to_hex(',outname_im,'_expected(n))\n',...
            '               & " vs. Actual(imag): "\n',...
            '               & to_hex(',outname_im,')\n',...
            '        SEVERITY ',severitylevel,';\n'];
        end

        if hdlgetparameter('clockinputs')==1
            force_input_section=['      IF ',ceoutname,'= ''1'' AND m + 1 <= ',num2str(len-1),' THEN\n',...
            '          ',inname,' <= ',inname,'_force(m + 1);\n',...
            '           m := m + 1;\n',...
            '        END IF;\n'];
        else
            force_input_section=['      IF ',clk1,' = ''1'' AND m + 1 <= ',num2str(len-1),' THEN\n',...
            '          ',inname,' <= ',inname,'_force(m + 1);\n'];
            if inputcplxty
                force_input_section=[force_input_section,...
                '          ',inname_im,' <= ',inname_im,'_force(m + 1);\n'];
            end
            force_input_section=[force_input_section,...
            '           m := m + 1;\n',...
            '        END IF;\n'];
        end

        vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
        '    FOR n IN 0 TO ',num2str(len*factor-1),' LOOP\n',...
        '  ',assert_section,...
        '  ',wait_after_assert,...
        force_input_section,...
        wait_after_force,...
        '    END LOOP;\n',...
        '    IF m /= ',num2str(len-1),' THEN\n',...
        '      ASSERT FALSE REPORT ',...
        '"Error in filter test: Wrong number of outputs were checked" SEVERITY FAILURE;\n',...
        '    ELSE\n',...
        '      ASSERT FALSE REPORT "**** Test Complete with NO FAILURES. ****" SEVERITY FAILURE;\n',...
        '    END IF;\n',...
        ];

    else

        if strcmpi(outputvtype,'real')
            testcondition=['abs( ',outname,' - ',outname,'_expected(n) ) < 1.0e-9'];
        elseif inexactcompare

            if outputsigned==1&&output_is_std_logic==0
                testcondition=['abs(',outname,' - ',outname,'_expected(n) ) <= ',...
                num2str(comparethreshold)];
            elseif outputsigned==1&&output_is_std_logic==1
                testcondition=['abs(signed( ',outname,' ) - signed( ',outname,'_expected(n) )) <= ',...
                num2str(comparethreshold)];
            else
                testcondition=['abs(signed( ''0'' & ',outname,' ) - signed( ''0'' & ',outname,'_expected(n) )) <= ',...
                num2str(comparethreshold)];
            end
        else
            testcondition=[outname,' = ',outname,'_expected(n)'];
        end

        severitylevel='ERROR';

        if latency==1
            wait_after_assert=['      WAIT FOR 2*',clk,'_hold;\n'];
            wait_after_force=['      WAIT FOR ',clk,'_period - 2*',clk,'_hold;\n'];
            n_adj=1;
        else
            wait_after_assert='';
            if isserializablefir(filterobj)
                ffact=hdlgetparameter('foldingfactor');
                if ffact>1
                    wait_after_force=['      WAIT FOR ',clk,'_period*',num2str(ffact),';\n'];
                else
                    wait_after_force=['      WAIT FOR ',clk,'_period;\n'];
                end
            else
                wait_after_force=['      WAIT FOR ',clk,'_period;\n'];
            end
            n_adj=latency-1;
        end

        assert_section=['      ASSERT ',testcondition,'\n',...
        '        REPORT "Error in filter test: Expected " \n',...
        '               & to_hex(',outname,'_expected(n))\n',...
        '               & " Actual "\n',...
        '               & to_hex(',outname,')\n',...
        '        SEVERITY ',severitylevel,';\n'];

        force_input_section=['      IF n + ',num2str(n_adj),' <= ',num2str(len-1),' THEN\n',...
        '        ',inname,' <= ',inname,'_force(n + ',num2str(n_adj),');\n',...
        '      END IF;\n'];

        vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
        '    FOR n IN 0 TO ',num2str(len-1),' LOOP\n',...
        assert_section,...
        wait_after_assert,...
        force_input_section,...
        wait_after_force,...
        '    END LOOP;\n',...
        '    ASSERT FALSE REPORT "**** Test Complete with NO FAILURES. ****" SEVERITY FAILURE;\n',...
        ];

    end

    vhdl_arch_body_blocks=[vhdl_arch_body_blocks,...
    '  END PROCESS ',inname,'_gen;\n\n'];





    if hdlgetparameter('vhdl_package_required')==1
        vhdl_entity_library=[vhdl_entity_library,'USE work.',hdlgetparameter('vhdl_package_name'),'.ALL;\n\n'];
    else
        vhdl_entity_library=[vhdl_entity_library,'\n'];
    end

    tbfid=fopen(tbfilename,'w');

    if tbfid==-1
        error(message('hdlfilter:generatevhdltb:fileerror',tbfilename));
    end

    vhdl_entity=[vhdl_entity_comment,...
    vhdl_entity_library,...
    vhdl_entity_package,...
    vhdl_entity_decl,...
    vhdl_entity_ports,...
    vhdl_entity_end];

    fprintf(tbfid,vhdl_entity);

    vhdl_arch1=[vhdl_arch_comment,...
    vhdl_arch_decl,...
    vhdl_arch_component_decl,...
    vhdl_arch_component_config,...
    vhdl_arch_functions,...
    vhdl_arch_typedefs,...
    vhdl_arch_constants,...
    inconstants];
    fprintf(tbfid,vhdl_arch1);

    fprintf('### Please wait ...');

    for n=1:len-1

        if mod(n,1000)==0
            fprintf('.');
        end

        inconst=hdlconstantvalue(real(indata(n)),inputsize,inputbp,inputsigned,'hex');
        if inputsize==0
            inconstants=['     ',inconst,',\n'];
        elseif inconst(1)=='('
            inconstants=['     ',inconst,',\n'];
        elseif input_is_std_logic==0
            inconstants=['     ',inconst,',\n'];
        elseif inputsigned
            inconstants=['     ',inconst(8:end-1),',\n'];
        else
            inconstants=['     ',inconst(10:end-1),',\n'];
        end

        fprintf(tbfid,inconstants);

    end


    inconst=hdlconstantvalue(real(indata(len)),inputsize,inputbp,inputsigned,'hex');

    if inputsize==0
        inconstants=['     ',inconst,',\n'];
    elseif inconst(1)=='('
        inconstants=['     ',inconst,',\n'];
    elseif input_is_std_logic==0
        inconstants=['     ',inconst,',\n'];
    elseif inputsigned
        inconstants=['     ',inconst(8:end-1),',\n'];
    else
        inconstants=['     ',inconst(10:end-1),',\n'];
    end

    if len==1
        inconst=hdlconstantvalue(0,inputsize,inputbp,inputsigned,'hex');
        if inputsize==0
            inconstants=[inconstants,'     ',inconst,');\n\n'];
        elseif inconst(1)=='('
            inconstants=[inconstants,'     ',inconst,');\n\n'];
        elseif input_is_std_logic==0
            inconstants=[inconstants,'     ',inconst,');\n\n'];
        elseif inputsigned
            inconstants=[inconstants,'     ',inconst(8:end-1),');\n\n'];
        else
            inconstants=[inconstants,'     ',inconst(10:end-1),');\n\n'];
        end
    else
        inconstants=[inconstants(1:end-3),');\n\n'];
    end
    fprintf(tbfid,inconstants);

    if inputcplxty
        inconstants=['  CONSTANT ',inname_im,'_force : ',inname,'_table :=\n    (\n'];
        fprintf(tbfid,inconstants);

        for n=1:len-1

            if mod(n,1000)==0
                fprintf('.');
            end
            inconst=hdlconstantvalue(imag(indata(n)),inputsize,inputbp,inputsigned,'hex');
            if inputsize==0
                inconstants=['     ',inconst,',\n'];
            elseif inconst(1)=='('
                inconstants=['     ',inconst,',\n'];
            elseif input_is_std_logic==0
                inconstants=['     ',inconst,',\n'];
            elseif inputsigned
                inconstants=['     ',inconst(8:end-1),',\n'];
            else
                inconstants=['     ',inconst(10:end-1),',\n'];
            end
            fprintf(tbfid,inconstants);

        end


        inconst=hdlconstantvalue(imag(indata(len)),inputsize,inputbp,inputsigned,'hex');

        if inputsize==0
            inconstants=['     ',inconst,',\n'];
        elseif inconst(1)=='('
            inconstants=['     ',inconst,',\n'];
        elseif input_is_std_logic==0
            inconstants=['     ',inconst,',\n'];
        elseif inputsigned
            inconstants=['     ',inconst(8:end-1),',\n'];
        else
            inconstants=['     ',inconst(10:end-1),',\n'];
        end

        if len==1
            inconst=hdlconstantvalue(0,inputsize,inputbp,inputsigned,'hex');
            if inputsize==0
                inconstants=[inconstants,'     ',inconst,');\n\n'];
            elseif inconst(1)=='('
                inconstants=[inconstants,'     ',inconst,');\n\n'];
            elseif input_is_std_logic==0
                inconstants=[inconstants,'     ',inconst,');\n\n'];
            elseif inputsigned
                inconstants=[inconstants,'     ',inconst(8:end-1),');\n\n'];
            else
                inconstants=[inconstants,'     ',inconst(10:end-1),');\n\n'];
            end
        else
            inconstants=[inconstants(1:end-3),');\n\n'];
        end
        fprintf(tbfid,inconstants);
    end

    if outputcplxty
        lrange=2;
    else
        lrange=1;
    end

    for m=1:lrange
        if m==2
            outconstants=['  CONSTANT ',outname_im,'_expected : ',outname,'_table :=\n    (\n'];
            lastoutdataval=imag(outdata(lenout));
        else
            lastoutdataval=real(outdata(lenout));
        end
        fprintf(tbfid,outconstants);
        for n=1:lenout-1

            if mod(n,1000)==0
                fprintf('.');
            end
            if m==2
                outconstants=['  CONSTANT ',outname_im,'_expected : ',outname,'_table :=\n    (\n'];
                outdataval=imag(outdata(n));
            else
                outdataval=real(outdata(n));
            end
            outconst=hdlconstantvalue(outdataval,outputsize,outputbp,outputsigned,'hex');

            if outputsize==0
                outconstants=['     ',outconst,',\n'];
            elseif outconst(1)=='('
                outconstants=['     ',outconst,',\n'];
            elseif output_is_std_logic==0
                outconstants=['     ',outconst,',\n'];
            elseif outputsigned
                outconstants=['     ',outconst(8:end-1),',\n'];
            else
                outconstants=['     ',outconst(10:end-1),',\n'];
            end
            fprintf(tbfid,outconstants);
        end

        outconst=hdlconstantvalue(lastoutdataval,outputsize,outputbp,outputsigned,'hex');

        if outputsize==0
            outconstants=['     ',outconst,',\n'];
        elseif outconst(1)=='('
            outconstants=['     ',outconst,',\n'];
        elseif output_is_std_logic==0
            outconstants=['     ',outconst,',\n'];
        elseif outputsigned
            outconstants=['     ',outconst(8:end-1),',\n'];
        else
            outconstants=['     ',outconst(10:end-1),',\n'];
        end

        if lenout==1
            outconst=hdlconstantvalue(0,outputsize,outputbp,outputsigned,'hex');
            if outputsize==0
                outconstants=[outconstants,'     ',outconst,');\n\n'];
            elseif outconst(1)=='('
                outconstants=[outconstants,'     ',outconst,');\n\n'];
            elseif output_is_std_logic==0
                outconstants=[outconstants,'     ',outconst,');\n\n'];
            elseif outputsigned
                outconstants=[outconstants,'     ',outconst(8:end-1),');\n\n'];
            else
                outconstants=[outconstants,'     ',outconst(10:end-1),');\n\n'];
            end
        else
            outconstants=[outconstants(1:end-3),');\n\n'];
        end
        fprintf('\n');

        fprintf(tbfid,outconstants);
    end
    vhdl_arch2=[vhdl_arch_signals,...
    vhdl_arch_begin,...
    vhdl_arch_body_component_instances,...
    vhdl_arch_body_blocks,...
    vhdl_arch_body_output_assignments,...
    vhdl_arch_end];
    fprintf(tbfid,vhdl_arch2);

    fclose(tbfid);

    fprintf('### Done generating VHDL test bench.\n');



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








