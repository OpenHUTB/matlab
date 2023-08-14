function s=emcGetMexCompiler(lang)




    narginchk(0,1);
    fn=memoize(@mex.getCompilerConfigurations);

    if nargin==0
        clearCache(fn);
        s=[];
    else
        s=fn(lang,'Selected');
    end
