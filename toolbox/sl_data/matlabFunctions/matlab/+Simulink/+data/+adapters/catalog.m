function varargout=catalog()




    classList=sl.data.adapter.AdapterManagerV2.getMCOSAdapterClasses;
    adptCount=numel(classList);
    structView=struct('ClassName',zeros(adptCount),...
    'DisplayName',zeros(adptCount),...
    'Extensions',zeros(adptCount),...
    'FullPath',zeros(adptCount));
    for i=1:adptCount
        structView(i).ClassName=string(classList{i});
        adpt=eval(classList{i});
        structView(i).DisplayName=string(adpt.getAdapterName);
        exts=adpt.getSupportedExtensions;
        if~isa(exts,'string')
            exts=string(exts);
        end
        structView(i).Extensions=upper(join(exts,","));
        structView(i).FullPath=string(which(classList{i}));
    end
    tableView=struct2table(structView);
    tableView.Properties.VariableNames=...
    {DAStudio.message('sl_data_adapter:messages:ClassName'),...
    DAStudio.message('sl_data_adapter:messages:DisplayName'),...
    DAStudio.message('sl_data_adapter:messages:Extensions'),...
    DAStudio.message('sl_data_adapter:messages:FullPath')};
    if nargout==0
        disp(tableView);
    else
        varargout{1}=tableView;
    end
end