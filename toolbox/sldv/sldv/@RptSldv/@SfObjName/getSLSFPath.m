function sfPath=getSLSFPath(c,obj,d)%#ok<INUSL>







    ps=rptgen_sf.propsrc_sf;
    psSL=rptgen_sl.propsrc_sl;
    appDSF=rptgen_sf.appdata_sf;

    if nargin<2
        d=get(rptgen.appdata_rg,'CurrentDocument');
    end


    if isa(obj,'Stateflow.Chart')
        obj=appDSF.CurrentChartBlock;
        sfPath={psSL.getObjectName(obj)};
    else
        sfPath={ps.getObjectName(obj)};
    end

    [obj,ps]=locGetParent(obj,ps,psSL,appDSF);
    while~isempty(obj)
        sfPath=[{d.makeLink(ps.getObjectID(obj),...
        ps.getObjectName(obj),...
        'link'),'/'},sfPath];%#ok<AGROW>
        [obj,ps]=locGetParent(obj,ps,psSL,appDSF);
    end

    sfPath=d.createDocumentFragment(sfPath{:});


    function[par,ps]=locGetParent(obj,ps,psSL,appDSF)

        if isa(obj,'Simulink.SubSystem')
            par=up(obj);
            par=par.getFullName;
            ps=psSL;
        elseif isa(obj,'Stateflow.Object')
            par=up(obj);
            if isa(par,'Stateflow.Chart')
                par=appDSF.CurrentChartBlock;
                par=par.getFullName;
                ps=psSL;
            end
            if isa(par,'Simulink.SubSystem')


                ps=psSL;
                par=get(par,'Parent');
            elseif isa(par,'Simulink.Object')
                par=par.getFullName;
                ps=psSL;
            end
        elseif ischar(obj)
            par=get_param(obj,'Parent');
        elseif isa(obj,'Simulink.BlockDiagram')||isa(obj,'Stateflow.Root')||isa(obj,'Simulink.Root')
            par=[];
        else
            obj=up(obj);
            if~isa(obj,'Stateflow.Object')
                ps=psSL;
            end
        end
