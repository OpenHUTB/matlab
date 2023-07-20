


function struct_data=constructStructData(obj,data)
    assert(iscell(data));
    assert(length(data)==7);
    codeLang=obj.getCodeLanguage();

    struct_data=struct(getField(1,codeLang),[],...
    getField(2,codeLang),[],...
    getField(3,codeLang),[],...
    getField(4,codeLang),[],...
    getField(5,codeLang),[],...
    getField(6,codeLang),[],...
    getField(7,codeLang),[]);
    fNames=fieldnames(struct_data);
    for i=1:7
        struct_data.(fNames{i})=data{i};
    end
end


function out=getField(index,codeLang)
    str='Slci:slcireview:ManualReview';
    if strcmp(codeLang,'hdl')
        str=[str,'HDL'];
    end
    str=[str,'TableFieldName',num2str(index)];
    out=message(str).getString;
    out=strrep(out,' ','_');
    out=strrep(out,newline,'_');
end