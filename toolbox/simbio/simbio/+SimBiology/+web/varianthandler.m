function out=varianthandler(action,varargin)











    out={action};

    switch(action)
    case 'create'
        out=create(action,varargin{:});
    case 'addVariantToModelFromData'
        out=addVariantToModelFromData(action,varargin{:});
    case 'addVariantForSimData'
        out=addVariantForSimData(action,varargin{:});
    case 'addVariantForEstimatedParameters'
        out=addVariantForEstimatedParameters(action,varargin{:});
    end

end

function out=create(action,input)


    m=SimBiology.web.modelhandler('getModelFromSessionID',input.model);
    info=input.info;


    v=getvariant(m);
    names=get(v,{'Name'});
    name=findUniqueName(names,input.name);
    transaction=SimBiology.Transaction.create(m);
    v=addvariant(m,name);

    for i=1:length(info)
        obj=sbioselect(m,'SessionID',info(i).sessionID);
        if isa(obj,'SimBiology.RepeatDose')
            value=get(obj,info(i).property);
            if~isnumeric(value)
                obj=resolveparameter(obj,m,value);
            end
        end

        if isa(obj,'SimBiology.Species')||isa(obj,'SimBiology.Parameter')||isa(obj,'SimBiology.Compartment')
            v.addcontent({obj.type,obj.PartiallyQualifiedNameReally,'Value',info(i).value});
        end
    end

    transaction.commit;

    out.action=action;
    out.message='';

    if~strcmp(name,input.name)
        out.message=['A variant with the name: ',input.name,' already existed on the model. A variant called: ',name,' was added.'];
    end

end

function out=addVariantToModelFromData(action,input)


    m=SimBiology.web.modelhandler('getModelFromSessionID',input.sessionID);


    v=getvariant(m);
    names=get(v,{'Name'});
    name=findUniqueName(names,input.name);


    dataInfo=input.dataInfo;
    data=load(dataInfo.matfileName,dataInfo.matfileVarName);
    data=data.(dataInfo.matfileVarName);
    variant=data.(dataInfo.variableName);


    transaction=SimBiology.Transaction.create(m);
    vnew=addvariant(m,name);
    vnew.Content=variant.Content;
    transaction.commit;


    out.action=action;
    out.message='';
    if~strcmp(vnew.Name,input.name)
        out.message=['A variant with the name: ',input.name,' already existed on the model. A variant called: ',vnew.Name,' was added.'];
    end

end

function out=addVariantForSimData(action,input)


    m=SimBiology.web.modelhandler('getModelFromSessionID',input.sessionID);


    v=getvariant(m);
    names=get(v,{'Name'});
    name=findUniqueName(names,input.name);


    dataInfo=input.dataInfo;
    data=load(dataInfo.matfileName,dataInfo.matfileVarName);
    data=data.(dataInfo.matfileVarName);
    simdata=data.(dataInfo.variableName);


    stateInfo=simdata.DataInfo;
    endValues=simdata.Data(end,:);


    transaction=SimBiology.Transaction.create(m);
    vnew=addvariant(m,name);


    for i=1:length(stateInfo)
        name=stateInfo{i}.Name;


        if strcmpi(stateInfo{i}.Type,'Species')
            comp=sbioselect(m,'Type','Compartment','Name',stateInfo{i}.Compartment);
            species=sbioselect(comp,'Name',stateInfo{i}.Name);
            name=species.PartiallyQualifiedNameReally;
        end

        addcontent(vnew,{stateInfo{i}.Type,name,'Value',endValues(i)});
    end

    transaction.commit;


    out.action=action;
    out.message='';
    if~strcmp(vnew.Name,input.name)
        out.message=['A variant with the name: ',input.name,' already existed on the model. A variant called: ',vnew.Name,' was added.'];
    end

end

function out=addVariantForEstimatedParameters(action,input)


    m=SimBiology.web.modelhandler('getModelFromSessionID',input.sessionID);


    dataInfo=input.dataInfo;
    data=load(dataInfo.matfileName,dataInfo.matfileVarName);
    data=data.(dataInfo.matfileVarName);
    fitResults=data.(dataInfo.variableName);


    names=fitResults.EstimatedParameterNames;

    estimates=nan(numel(names),1);

    switch class(fitResults)
    case 'SimBiology.fit.NLMEResults'
        resultsTable=fitResults.PopulationParameterEstimates;
    case 'SimBiology.fit.OptimResults'
        resultsTable=vertcat(fitResults(:).ParameterEstimates);
    end


    out.action=action;
    out.message='';

    if input.perGroup

        groups=vertcat(fitResults.GroupName);
        for i=1:numel(groups)
            estim=fitResults(i).ParameterEstimates;


            name=sprintf('%s_Group_%s',input.name,groups(i));
            uniqueName=findUniqueName(get(m.getvariant,{'Name'}),name);
            addVariantHelper(m,uniqueName,names,estim.Estimate);

            if~strcmp(uniqueName,name)
                if~isempty(out.message)
                    msg=['A variant with the name: ',name,' already existed on the model. A variant called: ',uniqueName,' was added.'];
                    out.message=sprintf('%s\n%s',out.message,msg);
                else
                    out.message=['A variant with the name: ',name,' already existed on the model. A variant called: ',uniqueName,' was added.'];
                end
            end
        end
    else


        for i=1:numel(names)
            estim=resultsTable(strcmp(resultsTable.Name,names{i}),:);
            estimates(i)=mean(estim.Estimate);
        end


        uniqueName=findUniqueName(get(m.getvariant,{'Name'}),input.name);
        addVariantHelper(m,uniqueName,names,estimates);

        if~strcmp(uniqueName,input.name)
            out.message=['A variant with the name: ',input.name,' already existed on the model. A variant called: ',uniqueName,' was added.'];
        end
    end

end

function vnew=addVariantHelper(m,name,contentNames,estimates)


    transaction=SimBiology.Transaction.create(m);
    vnew=addvariant(m,name);


    for i=1:length(contentNames)

        stateObj=sbioselect(m,'where','Name','==',contentNames{i},'or','where','PartiallyQualifiedName','==',contentNames{i},'or','where','PartiallyQualifiedNameReally','==',contentNames{i});

        if~isempty(stateObj)
            name=stateObj.PartiallyQualifiedNameReally;
            addcontent(vnew,{stateObj.Type,name,'Value',estimates(i)});
        else


            addcontent(vnew,{'',contentNames{i},'Value',estimates(i)});
        end
    end

    transaction.commit;

end

function name=findUniqueName(allNames,nameIn)

    name=SimBiology.web.codegenerationutil('findUniqueName',allNames,nameIn);
end
