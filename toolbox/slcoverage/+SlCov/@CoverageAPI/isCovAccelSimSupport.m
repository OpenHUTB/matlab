function res=isCovAccelSimSupport(topModelH)



    res=slfeature('SlCovAccelCompileSupport')&&...
    strcmpi(get_param(topModelH,'CovAccelSimSupport'),'on');
end
