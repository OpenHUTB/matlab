function targetNames=getRegisteredTargetNames(varargin)




    targets=codertarget.target.getRegisteredTargets(varargin{:});
    numTargets=length(targets);
    targetNames=cell(1,numTargets);
    for i=1:length(targets)
        targetNames{i}=targets(i).Name;
    end
end