function result=isSharedRMIAvailable
    persistent isAvailable
    if isempty(isAvailable)
        isAvailable=isfolder(fullfile(matlabroot,'toolbox','shared','reqmgt'))...
        &&contains(path,fullfile('shared','reqmgt'));
    end
    result=isAvailable;
end
