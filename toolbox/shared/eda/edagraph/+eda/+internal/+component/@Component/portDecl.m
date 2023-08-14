function hdlcode=portDecl(this,generic_decl)








    prop=properties(this);
    hdlcode='';
    portSpec='';
    inports={};
    outports={};
    ioports={};
    for ii=1:length(prop)
        propName=prop{ii};
        if(isa(this.(propName),'eda.internal.component.ClockPort')||...
            isa(this.(propName),'eda.internal.component.ResetPort')||...
            isa(this.(propName),'eda.internal.component.ClockEnablePort')||...
            isa(this.(propName),'eda.internal.component.Inport'))
            inports{end+1}=propName;%#ok<AGROW>
        elseif isa(this.(propName),'eda.internal.component.Outport')
            outports{end+1}=propName;%#ok<AGROW>
        elseif isa(this.(propName),'eda.internal.component.InOutport')
            ioports{end+1}=propName;%#ok<*AGROW>
        end
    end

    for ii=1:length(inports)
        propName=inports{ii};
        fitype=this.(propName).FiType;
        htype=hdltype(this,fitype);



        portName=this.(propName).UniqueName;
        if hdlgetparameter('isvhdl')
            hdlcode=[hdlcode,hdl.indent(3),sprintf('%-32s',portName),': IN  ',htype,';',hdl.newline];%#ok
        else
            hdlcode=[hdlcode,hdl.indent(3),sprintf(portName),',',hdl.newline];%#ok
            portSpec=[portSpec,hdl.indent(3),'input    ',findType(htype),' ',sprintf(portName),';',hdl.newline];%#ok
        end
    end

    for ii=1:length(outports)
        propName=outports{ii};
        fitype=this.(propName).FiType;
        htype=hdltype(this,fitype);



        portName=this.(propName).UniqueName;
        if hdlgetparameter('isvhdl')
            hdlcode=[hdlcode,hdl.indent(3),sprintf('%-32s',portName),': OUT ',htype,';',hdl.newline];%#ok
        else
            hdlcode=[hdlcode,hdl.indent(3),sprintf(portName),',',hdl.newline];%#ok
            portSpec=[portSpec,hdl.indent(3),'output   ',findType(htype),' ',sprintf(portName),';',hdl.newline];%#ok
        end
    end

    for ii=1:length(ioports)
        propName=ioports{ii};
        fitype=this.(propName).FiType;
        htype=hdltype(this,fitype);



        portName=this.(propName).UniqueName;
        if hdlgetparameter('isvhdl')
            hdlcode=[hdlcode,hdl.indent(3),sprintf('%-32s',portName),': INOUT ',htype,';',hdl.newline];%#ok
        else
            hdlcode=[hdlcode,hdl.indent(3),sprintf(portName),',',hdl.newline];%#ok
            portSpec=[portSpec,hdl.indent(3),'inout   ',findType(htype),' ',sprintf(portName),';',hdl.newline];%#ok
        end
    end

    hdlcode(end-1)='';
    hdlcode=[hdlcode,');\n'];

    if hdlgetparameter('isverilog')
        hdlcode=[hdlcode,generic_decl,portSpec];
    end
end

function dtype=findType(vtype)
    dtype='';
    lenvtype=length(vtype);
    if strcmp(vtype(1:3),'reg')&&lenvtype>4
        dtype=vtype(4:end);
    elseif strcmp(vtype(1:4),'wire')&&lenvtype>5
        dtype=vtype(5:end);
    end

end


