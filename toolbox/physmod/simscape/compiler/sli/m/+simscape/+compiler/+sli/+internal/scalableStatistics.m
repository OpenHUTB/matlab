function[report,data]=scalableStatistics(model)





    simscape.internal.systemBundleStatistics('clear');


    statsSetting=simscape.internal.systemBundleStatistics('enabled',true);
    cacheSetting=simscape.internal.cacheMethod(simscape.internal.CacheMethodType.None);
    try
        set_param(bdroot(model),'SimulationCommand','update');
    catch ME
        simscape.internal.systemBundleStatistics('enabled',statsSetting);
        simscape.internal.cacheMethod(cacheSetting);
        rethrow(ME);
    end
    simscape.internal.systemBundleStatistics('enabled',statsSetting);
    simscape.internal.cacheMethod(cacheSetting);

    data=simscape.internal.systemBundleStatistics('report');
    report=make_report(data);
end

function report=make_report(data)
    report={};
    for i=1:numel(data)
        report{i}=process_bundle(data{i});
    end
    if numel(report)==1
        report=report{1};
    end
end

function t=process_bundle(data)
    t=table();
    for i=1:size(data.subsystems,1)
        t=[t;process_subsys(data.subsystems(i))];
    end
end

function t=process_subsys(data)
    mf=process_data(data.mf,'physmod:simscape:compiler:core:util:SystemBundleStatistics_');
    ir=process_data(data.ir,'physmod:common:exec:core:xform:FunctionStatistics_');
    ird=ir_detail(data.ir_detail,'physmod:common:exec:core:xform:FunctionStatistics_');
    t=[mf,ir,ird];
    subsysName=data.name;
    if isempty(subsysName)
        subsysName='topSystem';
    end
    t.Properties.RowNames={subsysName};
end

function t=process_data(data,prefix)
    msgFcn=@(x)message(x).getString;
    varNames=cellfun(msgFcn,strcat(prefix,fields(data)),...
    'UniformOutput',false);
    t=struct2table(data);
    t.Properties.VariableNames=varNames;
end

function t=ir_detail(data,prefix)
    f=fields(data);
    s=struct.empty;
    for i=1:numel(f)
        s=[s;data.(f{i})];
    end
    t=struct2table(s);
    msgFcn=@(x)message(x).getString;
    t.Properties.VariableNames=cellfun(msgFcn,strcat(prefix,fields(s)),...
    'UniformOutput',false);
    t.Properties.RowNames=f;
    t=table({t},'VariableNames',{'IR Details'});
end
