function hdl=componentBody(signal,comp)






    oldLang=hdlgetparameter('target_language');
    hdlsetparameter('target_language',comp.Partition.Lang);

    h=eda.internal.diagram.Node;
    hdl=h.hdlcodeinit;

















    if~isempty(signal.Src)&&length(signal.Src)>1
        disp(['### MESSAGE: "',signal.UniqueName,'"',' is driven by too many signals in ',comp.UniqueName,'!!']);
    end

    dstIsPort=false;
    if~isempty(signal.Src)&&isa(signal.Src.Port,'eda.internal.component.Port')
        srcIsPort=true;
    else
        srcIsPort=false;
    end

    if isempty(signal.Src)&&~isempty(signal.Dst)&&~dstIsPort
        if hdlgetparameter('verbo')
            disp(['### MESSAGE: "',signal.UniqueName,'"',' signal does not have a source in ',comp.UniqueName,'!!']);
        end
    elseif~isempty(signal.Src)&&isempty(signal.Dst)&&~srcIsPort
        if hdlgetparameter('verbo')
            disp(['### MESSAGE: "',signal.UniqueName,'"',' signal does not have a destination in ',comp.UniqueName,'!!']);
        end
    elseif isempty(signal.Src)&&isempty(signal.Dst)&&~srcIsPort&&~dstIsPort
        if hdlgetparameter('verbo')
            disp(['### MESSAGE:"',signal.UniqueName,'"',' signal in ',comp.UniqueName,' is declared but not used.!!']);
        end
    elseif~isfield(signal.Src,'txfn')
        if isa(signal.Src.Port(:),'eda.internal.component.Outport')
            for j=1:length(signal.Dst)
                if isa(signal.Dst(j).Port,'eda.internal.component.Outport')
                    if signal.Dst(j).Node==comp
                        if isempty(signal.Src.Port(:).signal)
                            src=hdlsignalfindname(signal.Src.Port(:).UniqueName);
                        else
                            src=hdlsignalfindname(signal.Src.Port(:).signal.UniqueName);
                        end
                        if isempty(signal.Dst(j).Port.signal)||~comp.flatten
                            dst=hdlsignalfindname(signal.Dst(j).Port.UniqueName);
                        else
                            dst=hdlsignalfindname(signal.Dst(j).Port.signal.UniqueName);
                        end

                        hdl.arch_body_blocks=[hdl.arch_body_blocks,hdlassignment(src,dst)];
                    else

                    end
                elseif isa(signal.Dst(j).Port,'eda.internal.component.Inport')


                elseif isa(signal.Dst(j).Port,'eda.internal.component.Signal')
                    if~isfield(signal.Dst(j).Port.Src,'txfn')
                        if isempty(signal.Src.Port(:).signal)
                            src=hdlsignalfindname(signal.Src.Port(:).UniqueName);
                        else
                            src=hdlsignalfindname(signal.Src.Port(:).signal.UniqueName);
                        end
                        dst=hdlsignalfindname(signal.Dst(j).Port.UniqueName);
                        hdl.arch_body_blocks=[hdl.arch_body_blocks,hdlassignment(src,dst)];
                    else

                    end
                end
            end
        elseif isa(signal.Src.Port(:),'eda.internal.component.Inport')||...
            isa(signal.Src.Port(:),'eda.internal.component.ResetPort')||...
            isa(signal.Src.Port(:),'eda.internal.component.ClockPort')||...
            isa(signal.Src.Port(:),'eda.internal.component.ClockEnablePort')
            if comp.flatten
                src=hdlsignalfindname(signal.Src.Port(:).signal.UniqueName);
            else
                src=hdlsignalfindname(signal.Src.Port(:).UniqueName);
            end

            for j=1:length(signal.Dst)
                if isa(signal.Dst(j).Port(:),'eda.internal.component.Outport')
                    if comp.flatten
                        dst=hdlsignalfindname(signal.Dst(j).Port(j).signal.UniqueName);
                    else
                        dst=hdlsignalfindname(signal.Dst(j).Port(j).UniqueName);
                    end
                elseif isa(signal.Dst(j).Port(:),'eda.internal.component.Inport')||...
                    isa(signal.Dst(j).Port(:),'eda.internal.component.ResetPort')||...
                    isa(signal.Dst(j).Port(:),'eda.internal.component.ClockPort')||...
                    isa(signal.Dst(j).Port(:),'eda.internal.component.ClockEnablePort')

                    dst=hdlsignalfindname(signal.UniqueName);
                    hdl.arch_body_blocks=[hdl.arch_body_blocks,hdlassignment(src,dst)];
                    break;
                else
                    dst=hdlsignalfindname(signal.UniqueName);
                end





                hdl.arch_body_blocks=[hdl.arch_body_blocks,hdlassignment(src,dst)];



            end
        elseif isa(signal.Src.Port(:),'eda.internal.component.Signal')
            if comp.flatten
                src=hdlsignalfindname(signal.Src.Port.signal.UniqueName);
            else
                src=hdlsignalfindname(signal.Src.Port.UniqueName);
            end
            for j=1:length(signal.Dst)
                if isa(signal.Dst(j).Port(:),'eda.internal.component.Outport')
                    if comp.flatten
                        dst=hdlsignalfindname(signal.Dst(j).Port(j).signal.UniqueName);
                        hdl.arch_body_blocks=[hdl.arch_body_blocks,hdlassignment(src,dst)];
                    else
                        dst=hdlsignalfindname(signal.Dst(j).Port(j).UniqueName);
                        hdl.arch_body_blocks=[hdl.arch_body_blocks,hdlassignment(src,dst)];
                    end
                elseif isa(signal.Dst(j).Port(:),'eda.internal.component.Inport')||...
                    isa(signal.Dst(j).Port(:),'eda.internal.component.ResetPort')||...
                    isa(signal.Dst(j).Port(:),'eda.internal.component.ClockPort')||...
                    isa(signal.Dst(j).Port(:),'eda.internal.component.ClockEnablePort')

                    dst=hdlsignalfindname(signal.UniqueName);
                    hdl.arch_body_blocks=[hdl.arch_body_blocks,hdlassignment(src,dst)];
                    break;
                else
                    dst=hdlsignalfindname(signal.UniqueName);
                    hdl.arch_body_blocks=[hdl.arch_body_blocks,hdlassignment(src,dst)];
                end
            end
        end
    else
        if hdlgetparameter('isvhdl')
            hdlCode=generateVHDL(signal,comp);
        else
            hdlCode=generateVLOG(signal,comp);
        end
        hdl.arch_body_blocks=[hdl.arch_body_blocks,hdlCode];
    end

    hdlsetparameter('target_language',oldLang);
end



function hdlCode=generateVHDL(signal,comp)
    hdlCode='';
    for i=1:length(signal.Dst)
        if isa(signal.Dst(i).Port,'eda.internal.component.Outport')
            if comp.flatten
                hdlCode=[signal.Dst(i).Port.signal.UniqueName,' <= '];
            else
                hdlCode=[signal.Dst(i).Port.UniqueName,' <= '];
            end
        else
            hdlCode=[signal.UniqueName,' <= '];
        end
    end
    operator=signal.Src.txfn;
    switch operator
    case 'bitand'
        len=length(signal.Src.Port);
        for loop=1:len-1
            hdlCode=[hdlCode,signal.Src.Port{loop}.UniqueName,' AND '];
        end
        hdlCode=[hdlCode,signal.Src.Port{len}.UniqueName,';\n'];
    case 'bitor'
        len=length(signal.Src.Port);
        for loop=1:len-1
            hdlCode=[hdlCode,signal.Src.Port{loop}.UniqueName,' OR '];
        end
        hdlCode=[hdlCode,signal.Src.Port{len}.UniqueName,';\n'];
    case 'bitreplicate'
        if comp.flatten
            src=signal.Src.Port{1}.signal.UniqueName;
        else
            src=signal.Src.Port{1}.UniqueName;
        end
        if strcmpi(signal.FiType,'boolean')
            hdlCode=[hdlCode,src,';\n'];
        else
            hdlCode=[hdlCode,'(others => ',src,');\n'];
        end

    case 'bitsliceget'
        if length(signal.Src.fnParam)==1
            hdlCode=[hdlCode,signal.Src.Port{1}.UniqueName,'(',signal.Src.fnParam{1},');\n'];
        elseif eval(signal.Src.fnParam{1})==eval(signal.Src.fnParam{2})
            hdlCode=[hdlCode,signal.Src.Port{1}.UniqueName,'(',num2str(eval(signal.Src.fnParam{1})-1),');\n'];
        else
            hdlCode=[hdlCode,signal.Src.Port{1}.UniqueName,'(',signal.Src.fnParam{1},...
            ' DOWNTO ',signal.Src.fnParam{2},');\n'];
        end
    case 'bitconcat'
        len=length(signal.Src.Port);
        for loop=1:len-1
            hdlCode=[hdlCode,signal.Src.Port{loop}.UniqueName,' & '];%#ok<*AGROW>
        end
        hdlCode=[hdlCode,signal.Src.Port{len}.UniqueName,';\n'];
    case 'not'
        hdlCode=[hdlCode,' NOT ',signal.Src.Port{1}.UniqueName,';\n'];
    case 'zeros'
        hdlCode=[hdlCode,'(others => ''0'');\n'];
    case 'fi'
        value=signal.Src.fnParam{1};

        sign='1';size='16';bp='12';

        if length(signal.Src.fnParam)==4
            sign=signal.Src.fnParam{2};
            size=signal.Src.fnParam{3};
            bp=signal.Src.fnParam{4};
        elseif length(signal.Src.fnParam)==3
            sign=signal.Src.fnParam{2};
            size=signal.Src.fnParam{3};
        elseif length(signal.Src.fnParam)==2
            sign=signal.Src.fnParam{2};
        end
        fValue=eval(['fi(',value,',',sign,',',size,',',bp,')']);
        if eval(size)==1
            hdlCode=[hdlCode,'''',fValue.bin,''';\n'];
        elseif eval(value)==0
            hdlCode=[hdlCode,'(others => ''0'');\n'];
        else
            hdlCode=[hdlCode,'"',fValue.bin,'";\n'];
        end
    case 'padonezero'
        hdlCode=[hdlCode,'''0'';\n'];
    otherwise
        error(message('EDALink:Signal:componentBody:FuncionNotSupported',signal.Src.txfn));
    end
end
function hdlCode=generateVLOG(signal,comp)
    hdlCode='';
    for i=1:length(signal.Dst)
        if isa(signal.Dst(i).Port,'eda.internal.component.Outport')
            if comp.flatten
                hdlCode=['assign ',signal.Dst(i).Port.signal.UniqueName,' = '];
            else
                hdlCode=['assign ',signal.Dst(i).Port.UniqueName,' = '];
            end
        else
            hdlCode=['assign ',signal.UniqueName,' = '];
        end
    end
    operator=signal.Src.txfn;
    switch operator
    case 'bitand'
        len=length(signal.Src.Port);
        for loop=1:len-1
            hdlCode=[hdlCode,signal.Src.Port{loop}.UniqueName,' & '];
        end
        hdlCode=[hdlCode,signal.Src.Port{len}.UniqueName,';\n'];
    case 'bitor'
        len=length(signal.Src.Port);
        for loop=1:len-1
            hdlCode=[hdlCode,signal.Src.Port{loop}.UniqueName,' | '];
        end
        hdlCode=[hdlCode,signal.Src.Port{len}.UniqueName,';\n'];
    case 'bitreplicate'
        if comp.flatten
            src=signal.Src.Port{1}.signal.UniqueName;
        else
            src=signal.Src.Port{1}.UniqueName;
        end
        if strcmpi(signal.FiType,'boolean')
            hdlCode=[hdlCode,src,';\n'];
        else
            error(message('EDALink:Signal:componentBody:BitreplicateNotImplemented'));
        end

    case 'bitsliceget'
        if length(signal.Src.fnParam)==1
            hdlCode=[hdlCode,signal.Src.Port{1}.UniqueName,'[',signal.Src.fnParam{1},'];\n'];
        elseif eval(signal.Src.fnParam{1})==eval(signal.Src.fnParam{2})
            hdlCode=[hdlCode,signal.Src.Port{1}.UniqueName,'[',num2str(eval(signal.Src.fnParam{1})-1),'];\n'];
        else
            hdlCode=[hdlCode,signal.Src.Port{1}.UniqueName,'[',signal.Src.fnParam{1},...
            ' : ',signal.Src.fnParam{2},'];\n'];
        end
    case 'bitconcat'
        hdlCode=[hdlCode,'{'];
        for loop=1:length(signal.Src.Port)
            hdlCode=[hdlCode,signal.Src.Port{loop}.UniqueName,','];%#ok<*AGROW>
        end
        hdlCode(end)='}';
        hdlCode=[hdlCode,';\n'];
    case 'not'
        hdlCode=[hdlCode,' ~ ',signal.Src.Port{1}.UniqueName,';\n'];
    case 'zeros'
        hdlCode=[hdlCode,'0;'];
    case 'fi'
        value=signal.Src.fnParam{1};

        sign='1';size='16';bp='12';

        if length(signal.Src.fnParam)==4
            sign=signal.Src.fnParam{2};
            size=signal.Src.fnParam{3};
            bp=signal.Src.fnParam{4};
        elseif length(signal.Src.fnParam)==3
            sign=signal.Src.fnParam{2};
            size=signal.Src.fnParam{3};
        elseif length(signal.Src.fnParam)==2
            sign=signal.Src.fnParam{2};
        end
        fValue=eval(['fi(',value,',',sign,',',size,',',bp,')']);
        assign=sprintf('%s''b%s;\n',size,fValue.bin);
        hdlCode=[hdlCode,assign];
    case 'padonezero'
        hdlCode=[hdlCode,'0;\n'];
    otherwise
        error(message('EDALink:Signal:componentBody:FuncionNotSupported',signal.Src.txfn));
    end
end


function hdlcode=hdlassignment(src,dst)
    hdlcode='';


    srcFiType=hdlsignalsltype(src);


    dstFiType=hdlsignalsltype(dst);
    if~isempty(strfind(srcFiType,'std'))||~isempty(strfind(dstFiType,'std'))
        if hdlgetparameter('isvhdl')
            if~isempty(strfind(srcFiType,'std'))
                srcSize=stdSize(srcFiType);
                if~isempty(strfind(dstFiType,'std'))
                    dstSize=stdSize(dstFiType);
                    if dstSize==srcSize
                        hdlcode=[hdlsignalname(dst),' <= ',hdlsignalname(src),';\n'];
                    else


                    end
                elseif~isempty(strfind(dstFiType,'sfix'))
                    hdlcode=[hdlsignalname(dst),' <= signed(',hdlsignalname(src),');\n'];
                elseif~isempty(strfind(dstFiType,'ufix'))
                    hdlcode=[hdlsignalname(dst),' <= unsigned(',hdlsignalname(src),');\n'];
                end
            else
                dstSize=stdSize(dstFiType);
                srcSize=hdlsignalsizes(src);
                if srcSize(1)==dstSize
                    hdlcode=[hdlsignalname(dst),' <= std_logic_vector(',hdlsignalname(src),');\n'];
                else


                end
            end
        else
            hdlcode=['assign ',hdlsignalname(dst),' = ',hdlsignalname(src),';\n'];
        end
    else
        hdlcode=hdldatatypeassignment(src,dst,'floor',0);
        hdlcode=regexprep(hdlcode,'(^)\s+','');

    end
end


function size=stdSize(fitype)
    if strfind(fitype,'ssdl')
        size=str2double(fitype(5:end));
    else
        size=str2double(fitype(4:end));
    end
end


