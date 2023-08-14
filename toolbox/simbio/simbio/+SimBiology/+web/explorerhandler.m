function out=explorerhandler(action,varargin)











    out={action};

    switch(action)
    case 'getSliderInfo'
        out=getSliderInfo(varargin{:});
    case 'commit'
        commit(varargin{:});
    case 'commitDose'
        commitDose(varargin{:});
    case 'commitVariant'
        commitVariant(varargin{:});
    end

end

function out=getSliderInfo(input)

    model=SimBiology.web.modelhandler('getModelFromSessionID',input.model);
    names=input.names;
    types=input.types;
    if~iscell(names)
        names={names};
        types={types};
    end

    data=cell(1,length(names));
    for i=1:length(names)
        obj=getObject(model,names{i},types{i});
        if strcmp(obj.Type,'variant')
            data{i}=getVariantInfo(model,obj);
        else
            data{i}=getDoseInfo(obj);
        end
    end

    out.data=data;

end

function out=getVariantInfo(model,obj)


    objs=privateresolve(obj,model);
    content=obj.Content;


    template=struct('sessionID',-1,'name','','value','','type','');
    numContent=sum(isvalid(objs));
    out=repmat(template,1,numContent);
    count=1;

    for i=1:length(objs)
        next=objs(i);
        if isvalid(next)
            out(count).sessionID=next.SessionID;
            out(count).name=content{i}{2};
            out(count).value=content{i}{4};
            out(count).type='variant';
            count=count+1;
        end
    end

end

function out=getDoseInfo(obj)

    out.sessionID=obj.SessionID;
    out.name='';
    out.value=0;
    out.type='repeatdose';

end

function commit(input)

    model=SimBiology.web.modelhandler('getModelFromSessionID',input.model);
    transaction=SimBiology.Transaction.create(model);
    info=input.info;

    for i=1:length(info)
        obj=sbioselect(model,'Type',info(i).type,'SessionID',info(i).sessionID);
        switch(info(i).type)
        case{'species','parameter','compartment'}
            set(obj,getValueProperty(info(i).type),info(i).value);
        case 'repeatdose'
            commitDoseValue(model,obj,info(i));
        end
    end

    transaction.commit;

end

function commitDose(input)

    model=SimBiology.web.modelhandler('getModelFromSessionID',input.model);
    obj=sbioselect(model,'Type','repeatdose','SessionID',input.sessionID);
    transaction=SimBiology.Transaction.create(model);

    commitDoseValue(model,obj,input);
    transaction.commit;

end

function commitDoseValue(model,obj,input)

    value=get(obj,input.property);
    if isnumeric(value)
        set(obj,input.property,input.value);
    else

        param=resolveparameter(obj,model,value);
        if~isempty(param)
            set(param,'Value',input.value);
        end
    end

end

function commitVariant(input)

    model=SimBiology.web.modelhandler('getModelFromSessionID',input.model);
    obj=sbioselect(model,'Type',input.type,'SessionID',input.sessionID);
    prop=getValueProperty(input.type);
    set(obj,prop,input.value);

end

function out=getValueProperty(type)

    out=SimBiology.web.codegenerationutil('getValueProperty',type);

end

function obj=getObject(model,name,type)

    if strcmp(type,'variant')
        obj=sbioselect(model,'Type','variant','Name',name);
    else
        obj=sbioselect(model,'Type','repeatdose','Name',name);
    end
end
