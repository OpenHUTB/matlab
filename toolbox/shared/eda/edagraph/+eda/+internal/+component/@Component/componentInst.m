function hdlcode=componentInst(this)








    if hdlgetparameter('isvhdl')
        hdlcode=vhdlCompInst(this);
    else
        hdlcode=verilogCompInst(this);
    end

end


function hdlcode=vhdlCompInst(this)

    hdlcode=this.hdlcodeinit;

    hdlcode.arch_body_component_instances=['u_',unifyInstName(this),': ',this.UniqueName,' \n'];
    if~isempty(this.findprop('generic'))
        fieldNames=fieldnames(this.generic);
        hdlcode.arch_body_component_instances=[hdlcode.arch_body_component_instances,'GENERIC MAP ('];
        for i=1:length(fieldNames)
            if isfield(this.generic.(fieldNames{i}),'instance_Value')
                Value=this.generic.(fieldNames{i}).instance_Value;
            else
                Value=this.generic.(fieldNames{i}).default_Value;
            end
            if isfield(Value,'Name')
                hdlcode.arch_body_component_instances=[hdlcode.arch_body_component_instances,fieldNames{i},' => ',Value.Name,',\n'];%#ok<AGROW>
            else
                hdlcode.arch_body_component_instances=[hdlcode.arch_body_component_instances,fieldNames{i},' => ',Value,',\n'];%#ok<AGROW>

            end
        end
        hdlcode.arch_body_component_instances(end-2)='';
        hdlcode.arch_body_component_instances=[hdlcode.arch_body_component_instances,')\n'];
    end

    hdlcode.arch_body_component_instances=[hdlcode.arch_body_component_instances,'PORT MAP(\n'];


    prop=properties(this);
    hdlConstants=[];

    for i=1:length(prop)
        propName=prop{i};
        if isa(this.(propName),'eda.internal.component.Port')
            if~isempty(this.(propName).signal)
                if isa(this.(propName).signal,'eda.internal.component.Signal')
                    hdlcode.arch_body_component_instances=[hdlcode.arch_body_component_instances,...
                    hdl.indent(4),sprintf('%-20s',this.(propName).UniqueName),' => ',this.(propName).signal.UniqueName,',\n'];
                elseif isa(this.(propName).signal,'eda.internal.component.Port')
                    signalName=this.findSignalName(propName,'componentInst');
                    hdlcode.arch_body_component_instances=[hdlcode.arch_body_component_instances,...
                    hdl.indent(4),sprintf('%-20s',this.(propName).UniqueName),' => ',signalName,',\n'];








                else
                    if strcmpi(this.(propName).signal,'HIGH')||strcmpi(this.(propName).signal,'1')
                        if strcmpi(this.(propName).FiType,'boolean')
                            value='''1''';
                        else
                            type=this.(propName).FiType;
                            if~isempty(this.findprop('generic'))
                                if isfield(this.generic,type)
                                    dataLength=num2str((this.getGenericInstanceValue(this.generic.(type)))-1);
                                    type=this.generic.(type).Type;
                                elseif~isempty(strfind(type,'int'))||~isempty(strfind(type,'fix'))||~isempty(strfind(type,'std'))
                                    dataLength=findDataLength(type);
                                end
                            elseif~isempty(strfind(type,'int'))||~isempty(strfind(type,'fix'))||~isempty(strfind(type,'std'))
                                dataLength=findDataLength(type);
                            end;
                            [baseMLType,baseHDLType]=findBaseType(type);
                            [Name,handle]=hdlnewsignal([propName,'_CONST'],'block',-1,0,0,[baseHDLType,'(',dataLength,' DOWNTO 0)'],baseMLType);
                            hdlConstants=[hdlConstants,makehdlconstantdecl(handle,'(others => ''1'')')];%#ok<*AGROW>
                            value=Name;
                        end
                    elseif strcmpi(this.(propName).signal,'LOW')||strcmpi(this.(propName).signal,'0')
                        if strcmpi(this.(propName).FiType,'boolean')
                            value='''0''';
                        else
                            type=this.(propName).FiType;
                            if~isempty(this.findprop('generic'))
                                if isfield(this.generic,type)
                                    dataLength=num2str((this.getGenericInstanceValue(this.generic.(type)))-1);
                                    type=this.generic.(type).Type;
                                elseif~isempty(strfind(type,'int'))||~isempty(strfind(type,'fix'))||~isempty(strfind(type,'std'))
                                    dataLength=findDataLength(type);
                                end
                            elseif~isempty(strfind(type,'int'))||~isempty(strfind(type,'fix'))||~isempty(strfind(type,'std'))
                                dataLength=findDataLength(type);
                            end
                            [baseMLType,baseHDLType]=findBaseType(type);
                            [Name,handle]=hdlnewsignal([propName,'_CONST'],'block',-1,0,0,[baseHDLType,'(',dataLength,' DOWNTO 0)'],baseMLType);
                            hdlConstants=[hdlConstants,makehdlconstantdecl(handle,'(others => ''0'')')];
                            value=Name;
                        end
                    elseif strcmpi(this.(propName).signal,'OPEN')
                        value='OPEN';
                    else
                        error(message('EDALink:Component:componentInst:NotValidSignalValue'));
                    end
                    hdlcode.arch_body_component_instances=[hdlcode.arch_body_component_instances,...
                    hdl.indent(4),sprintf('%-20s',this.(propName).UniqueName),' => ',value,',\n'];
                end
            end
        end
    end
    hdlcode.arch_constants=hdlConstants;
    hdlcode.arch_body_component_instances(end-2)='';
    hdlcode.arch_body_component_instances=[hdlcode.arch_body_component_instances,');\n\n'];

    this.HDL.arch_body_component_instances=hdlcode.arch_body_component_instances;

end


function hdlcode=verilogCompInst(this)

    hdlcode=this.hdlcodeinit;

    hdlcode.arch_body_component_instances=[this.UniqueName,' '];


    if~isempty(this.findprop('generic'))
        fieldNames=fieldnames(this.generic);
        hdlcode.arch_body_component_instances=[hdlcode.arch_body_component_instances,'#('];
        for i=1:length(fieldNames)
            if isfield(this.generic.(fieldNames{i}),'instance_Value')
                Value=this.generic.(fieldNames{i}).instance_Value;
            else
                Value=this.generic.(fieldNames{i}).default_Value;
            end
            hdlcode.arch_body_component_instances=[hdlcode.arch_body_component_instances,'.',fieldNames{i},'(',Value,'),'];%#ok<AGROW>
        end
        hdlcode.arch_body_component_instances(end)='';
        hdlcode.arch_body_component_instances=[hdlcode.arch_body_component_instances,') '];
    end

    hdlcode.arch_body_component_instances=[hdlcode.arch_body_component_instances,'u_',unifyInstName(this),' '];
    hdlcode.arch_body_component_instances=[hdlcode.arch_body_component_instances,'(\n'];


    prop=properties(this);

    for i=1:length(prop)
        propName=prop{i};
        if isa(this.(propName),'eda.internal.component.Port')
            if~isempty(this.(propName).signal)
                if isa(this.(propName).signal,'eda.internal.component.Signal')
                    hdlcode.arch_body_component_instances=[hdlcode.arch_body_component_instances,...
                    hdl.indent(4),'.',sprintf('%-20s',this.(propName).UniqueName),' (',this.(propName).signal.UniqueName,'),\n'];
                elseif isa(this.(propName).signal,'eda.internal.component.Port')
                    signalName=this.findSignalName(propName,'componentInst');
                    hdlcode.arch_body_component_instances=[hdlcode.arch_body_component_instances,...
                    hdl.indent(4),'.',sprintf('%-20s',this.(propName).UniqueName),' (',signalName,'),\n'];








                else
                    if strcmpi(this.(propName).signal,'HIGH')
                        value='1''b1';
                    elseif strcmpi(this.(propName).signal,'LOW')
                        value='1''b0';
                    elseif strcmpi(this.(propName).signal,'OPEN')
                        value='';
                    else
                        error(message('EDALink:Component:componentInst:NotValidSignalValue'));
                    end
                    hdlcode.arch_body_component_instances=[hdlcode.arch_body_component_instances,...
                    hdl.indent(4),'.',sprintf('%-20s',this.(propName).UniqueName),' (',value,'),\n'];
                end
            end
        end
    end

    hdlcode.arch_body_component_instances(end-2)='';
    hdlcode.arch_body_component_instances=[hdlcode.arch_body_component_instances,');\n\n'];

    this.HDL.arch_body_component_instances=hdlcode.arch_body_component_instances;

end



function UniqueName=unifyInstName(this)
    if isempty(this.InstName)
        Name=this.Name;
    else
        Name=this.InstName;
    end
    legalName=hdllegalnamersvd(Name);
    if hdlentitynameexists([legalName])

        UniqueName=hdluniqueentityname(legalName);
    else
        UniqueName=legalName;
    end
    hdladdtoentitylist('',UniqueName,'','');

end

function dataLength=findDataLength(dataType)
    str=strrep(dataType,'uint','');
    str=strrep(str,'int','');
    str=strrep(str,'ufix','');
    str=strrep(str,'sfix','');
    str=strrep(str,'std','');
    dataLength=num2str(eval(str)-1);
end

function[baseMLType,baseHDLType]=findBaseType(dataType)
    baseMLType='';
    baseHDLType='';
    if~isempty(strfind(dataType,'integer'))
        baseMLType='ufix';
        baseHDLType='std_logic_vector';
    elseif~isempty(strfind(dataType,'int'))||~isempty(strfind(dataType,'sfix'))
        baseMLType='sfix';
        baseHDLType='signed';
    elseif~isempty(strfind(dataType,'uint'))||~isempty(strfind(dataType,'ufix'))
        baseMLType='ufix';
        baseHDLType='unsigned';
    elseif~isempty(strfind(dataType,'std'))
        baseMLType='ufix';
        baseHDLType='std_logic_vector';
    end
end

