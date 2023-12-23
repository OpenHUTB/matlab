function[isSupported]=compilerForCodegenSupports(modelName,api)

    isSupported=false;
    stf=get_param(modelName,'SystemTargetFile');

    if(isequal(stf,'raccel.tlc'))
        compConfig=mex.getCompilerConfigurations('C','Selected');
        shortName=compConfig.ShortName;
    else

        [isRtwgenCall,~,lResolvedMexCompilerKey]=...
        coder.internal.CompInfoCacheForRtwgen.getRtwgenCompInfoCache;

        assert(isRtwgenCall,"Must be called underneath rtwgen");
        compStruct=coder.make.internal.getMexCompInfoFromKey(lResolvedMexCompilerKey);

        assert(isfield(compStruct,'comp')&&(~isempty(compStruct.comp)),"Compiler Configuration not found");
        shortName=compStruct.comp.ShortName;
    end

    switch api
    case 'openmp'
        isSupported=contains(shortName,{'msvc','gcc','mingw','clang'},'IgnoreCase',true);

    case 'pthread'
        isSupported=contains(shortName,{'gcc','mingw','clang'},'IgnoreCase',true);
    end


