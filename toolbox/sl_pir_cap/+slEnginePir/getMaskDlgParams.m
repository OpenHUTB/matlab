function dialogParams=getMaskDlgParams(slBlock)






    op=get_param(slBlock,'dialogparameters');

    if isempty(op)
        dialogParams=[];
        return;
    end

    f=fieldnames(op);


    i=strcmp('TemplateBlock',f);f(i)=[];
    i=strcmp('MemberBlocks',f);f(i)=[];
    i=strcmp('ParameterArgumentNames',f);f(i)=[];
    i=strcmp('ParameterArgumentValues',f);f(i)=[];
    i=strcmp('AvailSigsDefaultProps',f);f(i)=[];


    i=strcmp('UpdateSigLoggingInfo',f);f(i)=[];



    idx_list=[];
    for i=1:length(f)
        cond1=~isempty(nonzeros(strcmp('read-only',op.(f{i}).Attributes)));
        cond2=~isempty(nonzeros(strcmp('write-only',op.(f{i}).Attributes)));
        if cond1||cond2
            idx_list=[idx_list,i];
        end
    end
    f(idx_list)=[];




    idx_list=[];
    for i=1:length(f)
        cond1=isempty(nonzeros(strcmp('always-link-instance',op.(f{i}).Attributes)));
        cond2=isempty(nonzeros(strcmp('link-instance',op.(f{i}).Attributes)));
        hmask=hasmask(slBlock);
        if(cond1&&~hmask)||(cond2&&hmask)
            idx_list=[idx_list,i];
        end
    end


    f(idx_list)=[];


    f{end+1,1}='Priority';
    f{end+1,1}='Description';
    f{end+1,1}='Tag';
    f{end+1,1}='AttributesFormatString';



    for i=1:length(f)
        v{i,1}=get_param(slBlock,f{i});
    end


    pv=[f,v];

    dialogParams=pv;

end
