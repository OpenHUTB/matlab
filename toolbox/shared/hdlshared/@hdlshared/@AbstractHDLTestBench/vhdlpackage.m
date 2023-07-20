function vhdlpackage(this,hdltbcode,tbpkgfid,tbdatafid)









    data_resolution='1.0e-9';
    for m=1:length(this.OutportSnk)
        portvtype=this.OutportSnk(m).PortVType;
        if strfind(portvtype,'vector_of_real')
            hdltbcode.package_functions=[hdltbcode.package_functions,...
            '  FUNCTION isEqual( x : IN vector_of_real;\n',...
            '                    y : IN vector_of_real) RETURN boolean;\n'];
            hdltbcode.package_body=[hdltbcode.package_body,...
            '  FUNCTION isEqual( x : IN vector_of_real;\n',...
            '                    y : IN vector_of_real) RETURN boolean IS\n',...
            '    VARIABLE i      :INTEGER;\n',...
            '    VARIABLE result : boolean;\n',...
            '  BEGIN\n',...
            '    result := TRUE;\n',...
            '    FOR i in 0 to x''length - 1 LOOP\n',...
            '      IF abs(x(i) - y(i)) >',data_resolution,' THEN\n',...
            '        result := FALSE;\n',...
            '      END IF;\n',...
            '    END LOOP;\n',...
            '    RETURN result;\n',...
            '  END;\n',...
            '\n\n'];
            break;
        end
    end





    to_hex_datatypes={'std_logic','std_logic_vector','signed','unsigned','real'};
    to_hex_port_vector_sizes=zeros(1,length(to_hex_datatypes));
    to_hex_new_idx=length(to_hex_datatypes)+1;

    for m=1:length(this.InPortSrc)
        openparenpos=strfind(this.InPortSrc(m).PortVType,'(');
        if~isempty(openparenpos)
            basevtype=this.InPortSrc(m).PortVType(1:openparenpos-1);
        else
            basevtype=this.InPortSrc(m).PortVType;
        end

        [wordlen,bp,signed]=hdlwordsize(this.InPortSrc(m).PortSLType);%#ok
        if wordlen==0
            hexsize=this.InPortSrc(m).VectorPortSize*16;
        else
            hexsize=this.InPortSrc(m).VectorPortSize*ceil(wordlen/4+1);
        end

        foundIdx=find(strcmp(basevtype,to_hex_datatypes));
        if isempty(foundIdx)
            to_hex_datatypes{end+1}=basevtype;%#ok
            to_hex_port_vector_sizes(length(to_hex_datatypes))=hexsize;
        else
            to_hex_port_vector_sizes(foundIdx)=max(hexsize,to_hex_port_vector_sizes(foundIdx));
        end
    end

    for m=1:length(this.OutPortSnk)
        openparenpos=strfind(this.OutPortSnk(m).PortVType,'(');
        if~isempty(openparenpos)
            basevtype=this.OutPortSnk(m).PortVType(1:openparenpos-1);
        else
            basevtype=this.OutPortSnk(m).PortVType;
        end

        [wordlen,bp,signed]=hdlwordsize(this.OutPortSnk(m).PortSLType);%#ok
        if wordlen==0
            hexsize=this.OutPortSnk(m).VectorPortSize*16+this.OutPortSnk(m).VectorPortSize-1;
        else
            hexsize=this.OutPortSnk(m).VectorPortSize*ceil(wordlen/4+1);
        end

        foundIdx=find(strcmp(basevtype,to_hex_datatypes));
        if isempty(foundIdx)
            to_hex_datatypes{end+1}=basevtype;%#ok
            to_hex_port_vector_sizes(length(to_hex_datatypes))=hexsize;
        else
            to_hex_port_vector_sizes(foundIdx)=max(hexsize,to_hex_port_vector_sizes(foundIdx));
        end
    end

    if length(to_hex_datatypes)>=to_hex_new_idx
        for ii=to_hex_new_idx:length(to_hex_datatypes)
            basevtype=to_hex_datatypes{ii};
            hexsize=to_hex_port_vector_sizes(ii);

            hdltbcode.package_functions=[hdltbcode.package_functions,...
            '  FUNCTION to_hex( x : IN ',basevtype,') RETURN string;\n'];
            hdltbcode.package_body=[hdltbcode.package_body,...
            '  FUNCTION to_hex( x : IN ',basevtype,') RETURN string IS\n',...
            '    VARIABLE result  : STRING(1 TO ',int2str(hexsize),');\n',...
            '    VARIABLE i       : INTEGER;\n',...
            '    VARIABLE j       : INTEGER;\n',...
            '    VARIABLE k       : INTEGER;\n',...
            '    VARIABLE m       : INTEGER;\n',...
            '    VARIABLE newx    : STRING(1 to 32);\n',...
            '  BEGIN\n',...
            '    i := x''LENGTH-1;\n',...
            '    m := to_hex(x(0))''LENGTH;\n',...
            '    newx(1 to m) := to_hex(x(0));\n',...
            '    k := m;\n',...
            '    result(1 to m) := newx(1 to m);\n',...
            '    for j in 1 to i loop\n',...
            '      m := to_hex(x(j))''LENGTH;\n',...
            '      result(k+1) := '' '';\n',...
            '      k := k+1;\n',...
            '      newx(1 to m) := to_hex(x(j));\n',...
            '      result(k+1 to k+m) := newx(1 to m);\n',...
            '      k := k+m;\n',...
            '    end loop;\n',...
            '    RETURN result(1 TO k);\n',...
            '  END;\n\n'];

        end
    end


    dataType.VType={};
    dataType.datalength=[];
    dataType.isConst=0;
    dataType.HDLNewType={};
    dataTypeIdx=0;
    performIO=this.isTextIOSupported;

    for m=1:length(this.InportSrc)
        type=findType(dataType,this.InportSrc(m));
        if isempty(type)
            dataTypeIdx=dataTypeIdx+1;
            dataType(dataTypeIdx).VType=this.InportSrc(m).PortVType;%#ok
            dataType(dataTypeIdx).datalength=this.InportSrc(m).datalength;%#ok
            dataType(dataTypeIdx).isConst=this.InportSrc(m).dataIsConstant;%#ok
            if(this.InportSrc(m).dataIsConstant==0&&~performIO)
                newType=[this.InportSrc(m).loggingPortName,'_type'];
                dataType(dataTypeIdx).HDLNewType=newType;%#ok
                this.InportSrc(m).HDLNewType=newType;
                hdltbcode.package_typedefs=[hdltbcode.package_typedefs,...
                '  TYPE ',newType,' IS ARRAY (0 TO ',int2str(this.InportSrc(m).datalength-1),') OF ',this.InportSrc(m).PortVType,';\n'];
            else
                dataType(dataTypeIdx).HDLNewType=this.InportSrc(m).PortVType;%#ok
                this.InportSrc(m).HDLNewType=this.InportSrc(m).PortVType;
            end
        else
            this.InportSrc(m).HDLNewType=type;
        end
    end
    for m=1:length(this.OutportSnk)
        type=findType(dataType,this.OutportSnk(m));
        if isempty(type)
            dataTypeIdx=dataTypeIdx+1;
            newDataType.VType=this.OutportSnk(m).PortVType;
            newDataType.datalength=this.OutportSnk(m).datalength;
            newDataType.isConst=this.OutportSnk(m).dataIsConstant;
            if(this.OutportSnk(m).dataIsConstant==0&&~performIO)
                newDataType.HDLNewType=[this.OutportSnk(m).loggingPortName,'_type'];
                this.OutportSnk(m).HDLNewType=newDataType.HDLNewType;
                hdltbcode.package_typedefs=[hdltbcode.package_typedefs,...
                '  TYPE ',newDataType.HDLNewType,' IS ARRAY (0 TO ',int2str(this.OutportSnk(m).datalength-1),') OF ',this.OutportSnk(m).PortVType,';\n'];
            else
                newDataType.HDLNewType=this.OutportSnk(m).PortVType;
                this.OutportSnk(m).HDLNewType=this.OutportSnk(m).PortVType;
            end
            dataType(dataTypeIdx)=newDataType;%#ok
        else
            this.OutportSnk(m).HDLNewType=type;
        end
    end



    procedureNames=containers.Map;
    for m=1:length(this.InportSrc)
        if performIO

            [procDecl,procBody]=hdlprocedure(this,this.InportSrc(m),'1 ns');
        else
            [procDecl,procBody]=hdlprocedure(this,this.InportSrc(m),[]);
        end

        hdltbcode.package_procedure=[hdltbcode.package_procedure,procDecl];
        hdltbcode.package_body=[hdltbcode.package_body,procBody];
        this.InportSrc(m).procedureName=...
        this.uniquifyName([this.InportSrc(m).loggingPortName,'_procedure'],...
        procedureNames);
    end
    for m=1:length(this.OutportSnk)
        if performIO

            [prodecureDecl,procBody]=hdlprocedure(this,this.OutportSnk(m),'1 ns');
        else
            [prodecureDecl,procBody]=hdlprocedure(this,this.OutportSnk(m),[]);
        end

        hdltbcode.package_procedure=[hdltbcode.package_procedure,prodecureDecl];
        hdltbcode.package_body=[hdltbcode.package_body,procBody];
        this.OutportSnk(m).procedureName=...
        this.uniquifyName([this.OutportSnk(m).loggingPortName,'_procedure'],...
        procedureNames);
    end


    hdltbcode_package=[hdltbcode.package_comment,...
    hdltbcode.package_library,...
    hdltbcode.package_decl,...
    hdltbcode.package_typedefs,...
    hdltbcode.package_functions,...
    hdltbcode.package_procedure,...
    hdltbcode.package_end,...
    hdltbcode.package_body,...
    hdltbcode.package_end];

    fprintf(tbpkgfid,hdltbcode_package);



    this.vhdlwriteRefData(tbdatafid);


    function type=findType(dataType,PortInfo)
        type=[];
        for m=1:length(dataType)
            if strcmpi(dataType(m).VType,PortInfo.PortVType)
                if dataType(m).datalength==PortInfo.datalength&&...
                    dataType(m).isConst==PortInfo.dataIsConstant
                    type=dataType(m).HDLNewType;
                    break;
                end
            end
        end


        function[procedureDecl,procedureBody]=hdlprocedure(this,Src,delay)
            if Src.datalength>2
                counter_size=ceil(log2(Src.datalength));
                dataType=[' unsigned(',int2str(counter_size-1),' DOWNTO 0)'];
                addrCond=['        IF (addr = TO_UNSIGNED(',int2str(Src.datalength-1),...
                ', ',int2str(counter_size),' )) THEN\n'];
                if isempty(delay)
                    addrAddOne=['          addr     <= addr + TO_UNSIGNED(1,',int2str(counter_size),'); \n'];
                else
                    addrAddOne=['          addr     <= addr + TO_UNSIGNED(1,',int2str(counter_size),') after ',delay,'; \n'];
                end

                addrRstValue=['      addr     <= TO_UNSIGNED(0,',int2str(counter_size),');\n'];

                doneCond=['    ELSIF (addr = TO_UNSIGNED(',int2str(Src.datalength-1),', ',int2str(counter_size),' )) THEN\n'];
            else
                dataType=(' std_logic');
                addrCond=('        IF (addr = ''1'') THEN\n');
                if isempty(delay)
                    addrAddOne=('           addr     <= ''1''; \n');
                else
                    addrAddOne=['           addr     <= ''1'' after ',delay,'; \n'];
                end

                addrRstValue=('      addr     <= ''0'';\n');
                doneCond=('    ELSIF (addr = ''1'') THEN\n');
            end
            rassertval=sprintf('''%d''',this.ForceResetValue);

            procedureIF=['  PROCEDURE ',Src.loggingPortName,'_procedure \n',...
            '    (SIGNAL clk      : IN    std_logic;\n',...
            '     SIGNAL reset    : IN    std_logic;\n',...
            '     SIGNAL rdenb    : IN    std_logic;\n',...
            '     SIGNAL addr     : INOUT',dataType,';\n',...
            '     SIGNAL done     : OUT   std_logic'];

            if hdlgetparameter('clockedge')==0
                clock_str='    ELSIF clk''event and clk = ''1'' THEN\n';
            else
                clock_str='    ELSIF clk''event and clk = ''0'' THEN\n';
            end

            counter=[...
            '    IF reset = ',rassertval,' THEN\n',...
            addrRstValue,...
            clock_str,...
            '      IF rdenb = ''1'' THEN\n',...
            addrCond,...
            '          addr     <= addr; \n',...
            '        ELSE\n',...
            addrAddOne,...
            '        END IF;\n',...
            '      ELSE \n',...
            '        addr <= addr;\n',...
            '      END IF;\n',...
            '    END IF;\n\n'];

            done_signal=[...
            '    IF reset = ',rassertval,' THEN\n',...
            '      done <= ''0''; \n',...
            doneCond,...
            '      done <= ''1''; \n',...
            '    ELSE\n',...
            '      done <= ''0''; \n',...
            '    END IF;\n'];
            procedureDecl=[procedureIF,...
            ');\n\n'];

            procedureBody=[procedureIF,') IS\n',...
            '  BEGIN\n',...
            '-- Counter to generate Addr.\n',...
            counter,...
            '-- Done Signal generation.\n',...
            done_signal,...
            '  END ',Src.loggingPortName,'_procedure;\n\n'];


