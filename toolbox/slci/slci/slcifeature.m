function prev=slcifeature(name,varargin)






    if ispc
        slcifeatureLibName='slcifeat';
    else
        slcifeatureLibName='libmwslcifeat';
    end

    if~libisloaded(slcifeatureLibName)
        loadlibrary(slcifeatureLibName,'slcifeature.h')
    end

    if nargin==1
        prev=slsvTestingHook(name);
    else
        prev=slsvTestingHook(name,varargin{1});
    end

end
