function sfPath=getSLSFPath(ps,obj,d,psSL)







    if nargin<4
        psSL=rptgen_sl.propsrc_sl;
        if nargin<3
            d=get(rptgen.appdata_rg,'CurrentDocument');
        end
    end

    sfPath={ps.getObjectName(obj)};

    [obj,ps]=locGetParent(obj,ps,psSL);
    while~isempty(obj)
        sfPath=[{d.makeLink(ps.getObjectID(obj),...
        ps.getObjectName(obj),...
        'link'),'/'},sfPath];
        [obj,ps]=locGetParent(obj,ps,psSL);
    end

    sfPath=d.createDocumentFragment(sfPath{:});


    function[par,ps]=locGetParent(obj,ps,psSL)

        if isa(obj,'Stateflow.Object')
            par=up(obj);
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
