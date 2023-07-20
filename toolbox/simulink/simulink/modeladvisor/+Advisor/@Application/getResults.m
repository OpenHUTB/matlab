
















function sysResults=getResults(this,varargin)













    p=inputParser();
    p.addParameter('ids',{});
    p.parse(varargin{:});
    in=p.Results;

    if isempty(in.ids)
        compIds=this.CompId2MAObjIdxMap.keys;
    else
        compIds=in.ids;

        if ischar(compIds)
            compIds={compIds};
        end
    end

    sysResults=ModelAdvisor.SystemResult.empty();

    for n=1:length(compIds)
        sysResults(n)=this.TaskManager.getComponentResult(compIds{n});
    end
end


