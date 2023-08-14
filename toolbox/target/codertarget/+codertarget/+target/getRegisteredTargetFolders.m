function folders=getRegisteredTargetFolders(varargin)




    targets=codertarget.target.getRegisteredTargets(varargin{:});
    numTargets=length(targets);
    folders=cell(1,numTargets);
    for i=1:length(targets)
        folders{i}=targets(i).TargetFolder;
    end
end