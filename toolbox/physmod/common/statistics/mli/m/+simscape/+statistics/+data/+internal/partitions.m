function out=partitions(rawData)
    import simscape.statistics.data.internal.Statistic


    [partitions,data.Summary]=lExtractPartitions(rawData);
    data.Table=[];
    if isempty(partitions)
        data=repmat(simscape.statistics.data.internal.Statistic('NumPartitions'),0,0);
        return
    end


    name={partitions.Name};
    solver={partitions.Value};
    solverLongDescription={partitions(1).Description};


    varNames=cellfun(@(c)lMapId(c),{partitions(1).Children.ID},'UniformOutput',false);


    varShortDescription=cellfun(@(c)lTransformDescription(c),{partitions(1).Children.Name},'UniformOutput',false);


    varLongDescriptions={partitions(1).Children.Description};


    nPartitions=numel(partitions);
    vals=cell(nPartitions,numel(varNames));
    for idx=1:numel(partitions)
        vals(idx,:)=lStatistics(partitions(idx).Children);
    end


    varNames=[{'SolverType'},varNames];
    varShortDescription=[{'Solver Type'},varShortDescription];
    varLongDescription=[solverLongDescription,varLongDescriptions];
    vals=[solver',vals];


    t=cell2table(vals,'VariableNames',varNames);
    t.Properties.VariableDescriptions=strcat(varShortDescription,{': '},varLongDescription);



    out=Statistic(...
    'Data',t,...
    'Name',rawData.Name,...
    'Description',rawData.Description);
end

function stats=lStatistics(partition)


    stats={partition.Value};
    sources={partition.Sources};
    for idx=1:numel(stats)
        if~isempty(sources{idx})
            stats{idx}=struct('Value',stats(idx),...
            'Sources',lSourcesTable(sources{idx}));
        end
    end
end

function[partitions,summary]=lExtractPartitions(p)

    partitions=[];
    if~isempty(p)
        summary.TotalPartitions=p.Value;
        summary.TotalMemoryEstimate=p.Children(1).Value;
        partitions=p.Children(2:end);
    end
end

function id=lMapId(id)

    idsMap=struct(...
    'SolverType',{'SolverType'},...
    'EquationType',{'EquationType'},...
    'NumVariablesInPartition',{'NumVariables'},...
    'NumEquationsInPartition',{'NumEquations'},...
    'NumModesInPartition',{'NumModes'},...
    'NumCachedMatricesInPartition','NumCachedMatrices',...
    'MemEstimateInPartition',{'MemoryEstimate'});
    id=idsMap.(id);
end

function description=lTransformDescription(description)

    description=strrep(description,'Number of ','');
    description=[upper(description(1)),description(2:end)];
end

function t=lSourcesTable(s)
    pm_assert(~isempty(s));
    if strcmp(s(1).Callback,'ds.mli.internal.openFileSource')
        t=lSourceFileTable(s);
    else
        t=simscape.statistics.data.internal.block_sources(s);
    end
end

function t=lSourceFileTable(s)
    r=struct('BlockPath',{s.Path},...
    'Description',{s.Description},...
    'SourceCode',num2cell(lFileInfo({s.Object})));
    t=struct2table(r);
end

function files=lFileInfo(objectStrings)
    out=cellfun(@(n){strsplit(n,'|')},objectStrings);
    names=cell(size(objectStrings));
    rows=names;
    columns=names;
    for idx=1:numel(out)
        d=out{idx};
        names{idx}=d{1};
        rows{idx}=str2double(d{2});
        columns{idx}=str2double(d{3});
    end
    files=struct('File',names,'Line',rows,'Column',columns);
end

function t=lSourceBlockTable(s)
    r.VariablePath=s.Path;
    r.Description=s.Description;
    r.SID=s.Object;
    t=struct2table(r);
end

