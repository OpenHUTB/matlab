function setup(obj)






    for i=1:length(obj.ParamList)
        p=obj.ParamList{i};
        assert(obj.ParamMap.isKey(p.Name),...
        ['Parameter: ',p.Name,' is not in map']);
        assert(obj.ParamMap.isKey(p.FullName),...
        ['Parameter: ',p.Name,' is not in map']);
    end


    for i=1:length(obj.ParamList)
        p=obj.ParamList{i};
        name=p.Name;
        loc_setChildren(obj,p,name);
        for j=1:length(p.WidgetList)
            loc_setChildren(obj,p.WidgetList{j},name);
        end
    end


    for i=1:length(obj.ParamList)
        p=obj.ParamList{i};
        fullParent=loc_complete(obj,p,'Parent',{p.Name});
        fullChildren=loc_complete(obj,p,'Children',{p.Name});
        if isempty(p.Parent)
            p.FullParent={};
        else
            p.FullParent=setdiff(fullParent,{p.Name},'stable')';
        end
        if isempty(p.Children)
            p.FullChildren={};
        else
            p.FullChildren=setdiff(fullChildren,{p.Name},'stable')';
        end
    end


    for i=1:length(obj.ParamList)
        p=obj.ParamList{i};
        for j=1:length(p.WidgetList)
            w=p.WidgetList{j};
            w.FullParent=union(p.FullParent,w.Parent);
        end
    end


    fcn=@configset.internal.util.toShortName;
    for i=1:length(obj.ParamList)
        p=obj.ParamList{i};
        p.Parent=cellfun(fcn,p.Parent,'UniformOutput',false);
        p.FullParent=cellfun(fcn,p.FullParent,'UniformOutput',false);
        p.Children=cellfun(fcn,p.Children,'UniformOutput',false);
        p.FullChildren=cellfun(fcn,p.FullChildren,'UniformOutput',false);
    end


    for p=obj.ParamList
        dependency=p{1}.Dependency;
        if~isempty(dependency)
            for i=1:length(dependency.StatusDepList)
                dep=dependency.StatusDepList{i};
                if isa(dep,'configset.internal.dependency.StatusDependency')
                    for j=1:length(dep.ParentList)
                        parent=dep.ParentList{j};
                        name=parent.Name;
                        valueSet=parent.ValueSet;
                        if~isempty(name)&&~isempty(valueSet)
                            parentObj=obj.ParamMap(name);
                            if iscell(parentObj)
                                parentObj=parentObj{1};
                            end
                            if~isempty(parentObj)&&strcmp(parentObj.Type,'int')
                                for k=1:length(valueSet)
                                    val=valueSet{k};
                                    dependency.StatusDepList{i}.ParentList{j}.ValueSet{k}=str2double(val);
                                end
                            end
                        end
                    end
                end
            end
        end
    end




    for i=1:length(obj.ParamList)
        p=obj.ParamList{i};
        for j=1:length(p.WidgetList)
            w=p.WidgetList{j};
            if isempty(w.CSH)
                w.CSH=p.CSH;
            end
        end
    end



    for i=1:length(obj.ParamList)
        p=obj.ParamList{i};
        obj.param.(p.Name)=obj.ParamMap(p.Name);
    end


    nameList={};
    idList=[];
    for i=1:length(obj.ParamList)
        p=obj.ParamList{i};


        n=find([cellfun(@(x)ismember(x,p.FullChildren)&&...
        ~ismember(x,p.FullParent),nameList),true],1);

        nameList=[nameList(1:n-1),{p.Name},nameList(n:end)];
        idList=[idList(1:n-1),i,idList(n:end)];
    end
    for i=1:length(idList)
        obj.ParamList{idList(i)}.Order=i;
    end


    function loc_setChildren(obj,p,name)


        if~isempty(p.Parent)
            for j=1:length(p.Parent)
                parent=obj.getParamAllFeatures(p.Parent{j});
                if iscell(parent)
                    for k=1:length(parent)
                        parent{k}.Children=union(parent{k}.Children,name);
                        parent{k}.Children=union({},parent{k}.Children);
                    end
                else
                    parent.Children=union(parent.Children,name);
                    parent.Children=union({},parent.Children);
                end
            end
        end



        function out=loc_complete(obj,param,relation,complete)

            rel=param.(relation);

            for i=1:length(rel)
                r=rel{i};
                p=obj.getParamAllFeatures(r);
                if iscell(p)
                    for j=1:length(p)
                        q=p{j};
                        if~ismember(q.Name,complete)

                            complete{end+1}=q.Name;%#ok
                            complete=loc_complete(obj,q,relation,complete);
                        else
                            complete=[setdiff(complete,{q.Name},'stable'),q.Name];
                        end
                    end
                else
                    if~ismember(p.Name,complete)

                        complete{end+1}=p.Name;%#ok
                        complete=loc_complete(obj,p,relation,complete);
                    else
                        complete=[setdiff(complete,{p.Name},'stable'),p.Name];
                    end
                end
            end

            out=complete;


