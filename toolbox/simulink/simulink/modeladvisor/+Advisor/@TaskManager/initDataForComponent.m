



















function initDataForComponent(this,compId,varargin)
    p=inputParser();

    if isempty(varargin)


        p.addRequired('compId',@ischar);
        p.parse(compId);
        in=p.Results;
        in.maObj=this.getMAObjs(compId);
        in.legacy=false;
        in.isRoot=false;

    else
        p.addRequired('compId',@ischar);
        p.addRequired('maObj',@(x)isa(x,'Simulink.ModelAdvisor'));
        p.addParameter('isRoot',false,@islogical);
        p.addParameter('legacy',false,@islogical);
        p.parse(compId,varargin{:});
        in=p.Results;
    end


    if this.NodeIDMap.length==0

        r=in.maObj.TaskAdvisorRoot;

        for n=1:length(r.ChildrenObj)
            this.generateIDMap(r.ChildrenObj{n});
        end
    end
end