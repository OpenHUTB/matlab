function privgeneratetb(filterobj,tbtype,varargin)

    if~(builtin('license','checkout','Filter_Design_HDL_Coder'))
        error(message('hdlfilter:privgeneratetb:nolicenseavailable'));
    end
    position=strmatch('targetlang',varargin(1:2:end));
    if~isempty(position),
        tbtype=varargin{2*position};
        varargin(2*position)=[];
        varargin(2*position-1)=[];
    end


    user_props=varargin(1:2:end);
    for n=1:length(user_props)
        if isempty(strmatch(lower(user_props(n)),lower(hdlgettbproperties)))
            error(message('hdlfilter:privgeneratetb:notTestBenchProperty',user_props{n}));
        end
    end

    supported_tbtypes={'VHDL','Verilog','GenerateCosimBlock'};
    tbtypes_for_errstring={'VHDL','Verilog'};
    expected_one_of='Illegal value ''%s'' for %s, expected one of %s.';
    errstr='';
    for n=1:length(tbtypes_for_errstring)-1
        errstr=[errstr,'''',tbtypes_for_errstring{n},''', '];
    end
    errstr=[errstr,'or ''',tbtypes_for_errstring{end},''''];

    if~iscell(tbtype)
        tbtype={tbtype};
    end

    tbtype=reshape(tbtype,1,length(tbtype));


    if length(tbtype)>1
        for v=tbtype
            pos=strmatch(lower(v),'generatecosimblocks');
            if~isempty(pos)

                error(message('hdlfilter:privgeneratetb:wrongtbtypeused'));
            end
        end

    end
    pos=strmatch(lower(tbtype),'generatecosimblock');
    if hdlgetparameter('generatecosimblock')||...
        (length(tbtype)==1&&~isempty(pos))
        hF=createhdlfilter(filterobj);
        makecosimblks(hF,filterobj,varargin{:});
    end


    temp_tbtype={};
    count=1;

    for v=tbtype
        position=strmatch(lower(v),lower(supported_tbtypes));
        if isempty(position)||length(position)>1
            error(message('hdlfilter:privgeneratetb:illegalparametervalue',v{1},'Test Bench Type',errstr));
        else
            temp_tbtype{count}=supported_tbtypes{position};
            count=count+1;
        end
    end


    if isa(filterobj,'dfilt.basefilter')
        hF=createhdlfilter(filterobj);
    else
        indices=strcmpi(varargin,'inputdatatype');
        pos=1:length(indices);
        pos=pos(indices);
        if isempty(pos)
            error(message('hdlfilter:privgeneratehdl:inputdatatypenotspecified'));
        else

        end
        inputnumerictype=varargin{pos+1};

        hF=createhdlfilter(filterobj,inputnumerictype);
    end
    for tbn=1:length(temp_tbtype)


        oldlang=hdlgetparameter('target_language');
        hprop=PersistentHDLPropSet;



        if isa(hF,'hdlfilter.abstractmultistage')
            cas_proplist=getCascadedProperties(hF);
            for n=1:length(cas_proplist)
                propval=get(hprop.CLI,cas_proplist{n});
                if iscell(propval)
                    for stn=1:length(hF.Stage)
                        hF.Stage(stn).setHDLParameter(cas_proplist{n},propval{stn})
                    end
                else

                    for stn=1:length(hF.Stage)
                        hF.Stage(stn).setHDLParameter(cas_proplist{n},propval)
                    end
                end
            end
            updateHdlfilterINI(hF);
        end

        hF.HDLParameters=hprop;
        hprop.CLI.TargetLanguage=temp_tbtype{tbn};

        updateINI(hprop);

        hF.generatetbcode(filterobj,varargin{:});

        hprop.CLI.TargetLanguage=oldlang;
        updateINI(hprop);

    end








