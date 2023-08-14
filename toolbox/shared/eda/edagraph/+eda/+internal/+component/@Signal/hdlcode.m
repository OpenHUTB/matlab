function hdl=hdlcode(this,comp)






    oldLang=hdlgetparameter('target_language');
    hdlsetparameter('target_language',comp.Partition.Lang);

    h=eda.internal.diagram.Node;
    hdl=h.hdlcodeinit;

    if~isempty(this.Src.Node)
        for loop=1:length(this.Src.Node)
            if isa(this.Src.Port(loop),'eda.internal.component.Outport')
                if length(this.Dst)>1
                    for j=1:length(this.Dst)
                        if isa(this.Dst(j).Port,'eda.internal.component.Outport')
                            if comp==this.Dst(j).Node
                                if isempty(this.Src.Port(loop).signal)
                                    src=hdlsignalfindname(this.Src.Port(loop).UniqueName);
                                else
                                    src=hdlsignalfindname(this.Src.Port(loop).signal.UniqueName);
                                end
                                if isempty(this.Dst(j).Port.signal)||~comp.flatten
                                    dst=hdlsignalfindname(this.Dst(j).Port.UniqueName);
                                else
                                    dst=hdlsignalfindname(this.Dst(j).Port.signal.UniqueName);
                                end

                                if comp.flatten
                                    hdl.arch_body_blocks=[hdl.arch_body_blocks,hdldatatypeassignment(src,dst,'floor',0)];
                                else
                                    hdl.arch_body_blocks=[hdl.arch_body_blocks,hdlfinalassignment(src,dst)];
                                end
                            else

                            end
                        elseif isa(this.Dst(j).Port,'eda.internal.component.Signal')
                        end
                    end
                end
            elseif isa(this.Src.Port(loop),'eda.internal.component.Inport')||...
                isa(this.Src.Port(loop),'eda.internal.component.ResetPort')||...
                isa(this.Src.Port(loop),'eda.internal.component.ClockPort')||...
                isa(this.Src.Port(loop),'eda.internal.component.ClockEnablePort')
                if comp.flatten
                    src=this.Src.Port(loop).signal.UniqueName;
                else
                    src=this.Src.Port(loop).UniqueName;
                end

                if isa(this.Dst.Port(loop),'eda.internal.component.Outport')
                    if comp.flatten
                        src=this.Src.Port(loop).signal.UniqueName;
                    else
                        dst=this.Dst.Port(loop).UniqueName;
                    end
                else
                    dst=this.UniqueName;
                end

                if strcmpi(this.FiType,'boolean')||strcmpi(this.FiType,'ufix1')
                    hdl.arch_body_blocks=[hdl.arch_body_blocks,dst,' <= ',src,';\n'];
                else
                    hdl.arch_body_blocks=[hdl.arch_body_blocks,dst,' <= (others => ',src,');\n'];
                end
            elseif isa(this.Src.Port{loop},'eda.internal.component.Signal')
                if isfield(this.Src,'txfn')
                    hdlCode=generateHDL(this,comp);
                    hdl.arch_body_blocks=[hdl.arch_body_blocks,hdlCode];
                    break;
                else
                    if comp.flatten
                        src=this.Src.Port.signal.UniqueName;
                    else
                        src=this.Src.Port.UniqueName;
                    end

                    dst=this.UniqueName;

                    if strcmpi(this.FiType,'boolean')
                        hdl.arch_body_blocks=[hdl.arch_body_blocks,dst,' <= ',src,';\n'];
                    else
                        hdl.arch_body_blocks=[hdl.arch_body_blocks,dst,' <= (others => ',src,');\n'];
                    end
                end
            end



        end
    else
        hdlCode=generateHDL(this,comp);
        hdl.arch_body_blocks=[hdl.arch_body_blocks,hdlCode];
    end

    hdlsetparameter('target_language',oldLang);
end



function hdlCode=generateHDL(this,comp)
    for i=1:length(this.Dst)
        if isa(this.Dst(i).Port,'eda.internal.component.Outport')
            if comp.flatten
                hdlCode=[this.Dst(i).Port.signal.UniqueName,' <= '];
            else
                hdlCode=[this.Dst(i).Port.UniqueName,' <= '];
            end
        else
            hdlCode=[this.UniqueName,' <= '];
        end
    end
    operator=this.Src.txfn;
    switch operator
    case 'bitand'
        len=length(this.Src.Port);
        for loop=1:len-1
            hdlCode=[hdlCode,this.Src.Port{loop}.UniqueName,' AND '];%#ok<AGROW>
        end
        hdlCode=[hdlCode,this.Src.Port{len}.UniqueName,';\n'];
    case 'bitor'
        len=length(this.Src.Port);
        for loop=1:len-1
            hdlCode=[hdlCode,this.Src.Port{loop}.UniqueName,' OR '];%#ok<AGROW>
        end
        hdlCode=[hdlCode,this.Src.Port{len}.UniqueName,';\n'];
    case 'bitsliceget'
        if length(this.Src.fnParam)==1
            hdlCode=[hdlCode,this.Src.Port{1}.UniqueName,'(',this.Src.fnParam{1},');\n'];
        else
            hdlCode=[hdlCode,this.Src.Port{1}.UniqueName,'(',this.Src.fnParam{1},...
            ' DOWNTO ',this.Src.fnParam{2},');\n'];
        end
    case 'bitconcat'
        len=length(this.Src.Port);
        for loop=1:len-1
            hdlCode=[hdlCode,this.Src.Port{loop}.UniqueName,' & '];%#ok<*AGROW>
        end
        hdlCode=[hdlCode,this.Src.Port{len}.UniqueName,';\n'];
    case 'not'
        hdlCode=[hdlCode,' NOT ',this.Src.Port{1}.UniqueName,';\n'];
    case 'fi'
        value=this.Src.fnParam{1};

        sign='1';size='16';bp='12';

        if length(this.Src.fnParam)==4
            sign=this.Src.fnParam{2};
            size=this.Src.fnParam{3};
            bp=this.Src.fnParam{4};
        elseif length(this.Src.fnParam)==3
            sign=this.Src.fnParam{2};
            size=this.Src.fnParam{3};
        elseif length(this.Src.fnParam)==2
            sign=this.Src.fnParam{2};
        end
        fValue=eval(['fi(',value,',',sign,',',size,',',bp,')']);
        if eval(size)==1
            hdlCode=[hdlCode,'''',fValue.bin,''';\n'];
        elseif eval(value)==0
            hdlCode=[hdlCode,'(others => ''0'');\n'];
        else
            hdlCode=[hdlCode,'"',fValue.bin,'";\n'];
        end

    otherwise
        error(message('EDALink:Signal:hdlcode:FuncionNotSupported',signal.Src.txfn));
    end
end
