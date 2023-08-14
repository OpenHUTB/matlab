function dialogParams=getMaskDlgParams(this,slBlock)






    op=get_param(slBlock,'dialogparameters');






    objs=get_param(slBlock,'object');
    if iscell(objs)
        objs=cell2mat(objs);
    end
    isBusElemPort=any(isprop(objs,'IsBusElementPort')==1)&&...
    any(strcmp(get_param(slBlock,'IsBusElementPort'),'on')==1);


    if isempty(op)||isBusElemPort
        dialogParams=[];
        return;
    end

    f=fieldnames(op);


    i=strmatch('TemplateBlock',f);f(i)=[];
    i=strmatch('MemberBlocks',f);f(i)=[];
    i=strmatch('ParameterArgumentNames',f);f(i)=[];
    i=strmatch('ParameterArgumentValues',f);f(i)=[];
    i=strmatch('AvailSigsDefaultProps',f);f(i)=[];


    i=strmatch('SignalObject',f);f(i)=[];
    i=strmatch('StorageClass',f);f(i)=[];


    i=strmatch('Variant',f);f(i)=[];


    i=strmatch('UpdateSigLoggingInfo',f);f(i)=[];

    i=strmatch('BusVirtuality',f);f(i)=[];

    i=strmatch('DataMode',f);f(i)=[];

    i=strmatch('MessageQueueUseDefaultAttributes',f);f(i)=[];
    i=strmatch('MessageQueueCapacity',f);f(i)=[];
    i=strmatch('MessageQueueType',f);f(i)=[];
    i=strmatch('MessageQueueOverwriting',f);f(i)=[];


    idx_list=[];
    for i=1:length(f)
        cond1=~isempty(strmatch('read-only',op.(f{i}).Attributes,'exact'));
        cond2=~isempty(strmatch('write-only',op.(f{i}).Attributes,'exact'));
        if cond1||cond2
            idx_list=[idx_list,i];
        end
    end


    f(idx_list)=[];


    for i=1:length(f),
        v{i,1}=get_param(slBlock,f{i});
    end


    pv=[f,v];

    dialogParams=pv;

end


