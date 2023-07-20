function slrealtime_Application(fileName)







    [~,modelName]=fileparts(fileName);
    targets=slrealtime.Targets;
    list=targets.getTargetNames;
    [indx,tf]=listdlg('ListString',list,...
    'SelectionMode','single',...
    'Name',getString(message('slrealtime:mldatx:slrealtimeAppTest')),...
    'PromptString',getString(message('slrealtime:mldatx:runAppOnTarget')),...
    'InitialValue',find(strcmp(targets.getDefaultTargetName(),list)),...
    'ListSize',[350,300]);

    if tf
        targetName=list{indx};
        tg=slrealtime(targetName);
        tg.connect;
        tg.load(modelName);
        tg.start;
    end
