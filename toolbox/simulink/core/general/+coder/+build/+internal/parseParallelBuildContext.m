function context=parseParallelBuildContext(varargin)





    persistent p;
    if isempty(p)
        p=inputParser;
        p.addOptional('BuildSpec','',@coder.build.internal.isBuildSpec);
        p.addParameter('ParallelBuildContext',[]);
        p.KeepUnmatched=true;
    end
    p.parse(varargin{:});

    context=p.Results.ParallelBuildContext;

end
