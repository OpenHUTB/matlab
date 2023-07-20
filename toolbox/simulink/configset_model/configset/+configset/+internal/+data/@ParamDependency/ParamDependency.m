classdef ParamDependency<handle

    properties
        Parent={}

        StatusDepList={}
        ValueDepList={}
        CustomDepList={}
    end

    methods
        function obj=ParamDependency(nodes)
            depList={};
            for i=1:length(nodes)
                node=nodes{i};
                depList=[depList,obj.create(node)];%#ok
            end

            statusDepList={};
            for i=1:length(depList)
                dep=depList{i};
                if isa(dep,'configset.internal.dependency.StatusDependency')||...
                    isa(dep,'configset.internal.dependency.LicenseDependency')
                    statusDepList{end+1}=dep;%#ok
                elseif isa(dep,'configset.internal.dependency.ValueDependency')
                    obj.ValueDepList{end+1}=dep;
                elseif isa(dep,'configset.internal.dependency.CustomDependency')
                    obj.CustomDepList{end+1}=dep;
                end
            end


            n=length(statusDepList);
            st=zeros(1,n);
            for i=1:n
                st(i)=statusDepList{i}.StatusLimit;
            end
            [~,idx]=sort(st,'descend');
            obj.StatusDepList=statusDepList(idx);
        end

        status=getStatus(obj,cs,name,varargin);
        info=getInfo(obj);
    end

    methods(Access=private)
        depList=create(obj,node);
    end
end
