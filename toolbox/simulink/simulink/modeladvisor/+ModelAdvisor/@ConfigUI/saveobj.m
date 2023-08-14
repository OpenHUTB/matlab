function B=saveobj(obj)











    B.class=class(obj);
    fnames=fieldnames(obj);
    for i=1:length(fnames)
        B.(fnames{i})=obj.(fnames{i});
    end
    B.MAObj={};

    for i=1:length(B.InputParameters)
        if strcmp(B.InputParameters{i}.Type,'PushButton')
            B.InputParameters{i}.Entries={};
        end
    end
    if~isempty(B.ParentObj)&&isprop(B.ParentObj,'Index')
        B.ParentObj=B.ParentObj.Index;
    end
    for i=1:length(B.ChildrenObj)
        if isprop(B.ChildrenObj{i},'Index')
            B.ChildrenObj{i}=B.ChildrenObj{i}.Index;
        end
    end
