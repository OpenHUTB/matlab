function out=object2Data(objectId,varargin)

    chartId=sf('get',objectId,'state.chart');
    [chartName,~]=sfprivate('chart2name',chartId);

    methodName=varargin{1};

    switch methodName
    case 'getChartName'


        out=chartName;
    case 'getChartId'
        out=chartId;
    case 'blkName'
        if strcmp(slmle.internal.checkMLFBType(objectId),'EMChart')
            out=chartName;
        else
            fncName=sf('get',objectId,'.name');
            out=[chartName,'/',fncName];
        end
    case 'getScript'
        out=sf('get',objectId,'.eml.script');

    case 'setScript'
        text=varargin{2};

        sf('TurnOffEMLUIUpdates',1);
        sf('set',objectId,'.eml.script',text);
        sf('TurnOffEMLUIUpdates',0);
        out=text;
    case 'handle'
        out=getSFHandle(objectId);
    case 'inputs'
        out=getInputArgs(objectId);
    otherwise
        out=[];

    end
end


function out=getSFHandle(objectId)
    if strcmp(slmle.internal.checkMLFBType(objectId),'EMChart')
        out=idToHandle(sfroot,sf('get',objectId,'.chart'));
    else
        out=idToHandle(sfroot,objectId);
    end
end

function result=getInputArgs(objectId)
    h=getSFHandle(objectId);

    if isempty(h)
        result=[];
        return;
    end

    data=h.find('-isa','Stateflow.Data');
    inArgs=cell(length(data),1);
    for i=1:length(data)
        if any(strcmp(data(i).Scope,{'Input','Parameter'}))
            args.name=data(i).Name;
            args.type=data(i).Scope;
            inArgs{i}=args;
        end
    end
    result=inArgs(~cellfun('isempty',inArgs));
end