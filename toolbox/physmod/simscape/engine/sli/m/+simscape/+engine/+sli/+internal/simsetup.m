function[stats,slTopoData,blockMap]=simsetup(solver,sp,daes,inputs,outputs,conns)





    if isempty(daes)
        stats=struct('srcPath',{},...
        'dstPath',{},...
        'filterOrder',{},...
        'timeConstant',{});
        slTopoData=[];
        blockMap=containers.Map;
        return;
    end

    [in,out,connections]=simscape.engine.sli.internal.convertioformat(daes,inputs,outputs,conns,@lGetIoNames);




    [stats,slTopoData,blockMap]=nesl_setupsimulation(sp,solver,daes,in,out,connections,false);

    if~isempty(slTopoData)
        if~isempty(slTopoData.Blocks)&&~iscell(slTopoData.Blocks)
            slTopoData.Blocks={slTopoData.Blocks};
        end
        if~isempty(slTopoData.Lines)&&~iscell(slTopoData.Lines)
            slTopoData.Lines={slTopoData.Lines};
        end
    end

end

function names=lGetIoNames(dae,iotype)
    names=cellfun(@(a)a.Info.Name,dae.(iotype)(:),'UniformOutput',false);
end
