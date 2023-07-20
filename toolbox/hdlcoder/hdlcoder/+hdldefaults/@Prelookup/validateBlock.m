function v=validateBlock(~,hC)


    v=hdlvalidatestruct;
    blockname='Prelookup';
    slbh=hC.SimulinkHandle;

    slobj=get_param(slbh,'object');
    indexMethods=slobj.getPropAllowedValues('IndexSearchMethod');
    indexMethods(2)=[];
    switch slobj.BreakpointsSpecification


    case 'Explicit values'
        if~strcmpi(indexMethods{1},get_param(slbh,'IndexSearchMethod'))
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:searchmethod',blockname,indexMethods{1}));
        end
    case 'Even spacing'

    otherwise
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:brkpt_specification',...
        blockname,slobj.BreakpointsSpecification));
    end

    if strcmp(slobj.BreakpointsDataSource,'Input port')
        m=message('hdlcoder:validate:PrelookupInput');
        v(end+1)=hdlvalidatestruct(1,m);
    end

    if~strcmp(get_param(hC.SimulinkHandle,'ExtrapMethod'),'Clip')
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:cliptorange'));
    end

    genFraction=strcmpi(get_param(hC.SimulinkHandle,'OutputOnlyTheIndex'),'off');
    if genFraction&&~strcmp(get_param(hC.SimulinkHandle,'UseLastBreakpoint'),'on')
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:uselastbreakpoint'));
    end

    if~strcmp(get_param(hC.SimulinkHandle,'ActionForOutOfRangeInput'),'Error')
        v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:outofrange',blockname));
    end

    slbh=hC.SimulinkHandle;
    slobj=get_param(slbh,'object');
    bpTypeVals=slobj.getPropAllowedValues('BreakpointDataTypeStr');
    if~strcmp(get_param(slbh,'BreakpointDataTypeStr'),bpTypeVals{1})
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:tabledatatype',bpTypeVals{1}));
    end


    rndMode=get_param(slbh,'RndMeth');
    rndModeVals=slobj.getPropAllowedValues('RndMeth');
    if~(strcmp(rndMode,rndModeVals{3})||...
        strcmp(rndMode,rndModeVals{6})||...
        strcmp(rndMode,rndModeVals{7}))
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:rndmode',rndMode,blockname));
    end


    bp_data=hdlslResolve('BreakpointsData',slbh);
    stride=double(bp_data(2)-bp_data(1));
    if stride~=2^nextpow2(stride)
        v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:prelookupnotpoweroftwo'));
        if genFraction
            v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:prelookupfraction'));
        end
    end


