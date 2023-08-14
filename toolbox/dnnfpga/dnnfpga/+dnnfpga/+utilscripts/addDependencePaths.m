function oldPath=addDependencePaths()
    [dep,~]=dnnfpga.utilscripts.resolveDependences('.',{});
    oldPath=addpath(dep{:});
end