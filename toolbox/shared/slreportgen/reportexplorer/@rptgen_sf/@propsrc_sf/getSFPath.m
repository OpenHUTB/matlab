function sfPath=getSFPath(ps,obj,d)





    if nargin<3
        d=get(rptgen.appdata_rg,'CurrentDocument');
    end

    sfPath={ps.getObjectName(obj)};

    obj=locGetParent(obj);
    while~isempty(obj)&&~isa(obj,'Stateflow.Root')&&~isa(obj,'Simulink.Root')
        sfPath=[{d.makeLink(ps.getObjectID(obj),...
        ps.getObjectName(obj),...
        'link'),'/'},sfPath];
        obj=locGetParent(obj);
    end

    sfPath=d.createDocumentFragment(sfPath{:});


    function par=locGetParent(obj)


        if isa(obj,'Stateflow.Machine')

            par=[];
        else
            par=up(obj);





            if isa(par,'Simulink.BlockDiagram')||isa(par,'Simulink.SubSystem')
                par=obj.Machine;
            end
        end
