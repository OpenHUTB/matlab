function instance=loadInstance(filename,overwrite)
    narginchk(1,2);
    if nargin<2
        overwrite=true;
    end

    unwrappedInstance=systemcomposer.internal.analysis.AnalysisService.loadInstanceModelAPI(filename,overwrite);
    instance=systemcomposer.analysis.ArchitectureInstance.getWrapperForImpl(...
    unwrappedInstance,'systemcomposer.analysis.ArchitectureInstance');

end