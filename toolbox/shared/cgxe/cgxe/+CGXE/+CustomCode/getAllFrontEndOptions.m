




function[cFeOpts,cxxFeOpts]=getAllFrontEndOptions(modelLang,usrIncludes,usrDefines)

    if nargin<3
        usrDefines=[];
    end

    if nargin<2
        usrIncludes=[];
    end

    cppModel=strcmpi(modelLang,'C++');
    [compilerInfo,clearObj]=CGXE.CustomCode.adjustMexCompilers(cppModel,ispc);%#ok<ASGLU>

    cppExtraFlags={};

    if~isempty(compilerInfo.cppOverrides)
        cppExtraFlags={'overrideCompilerFlags',compilerInfo.cppOverrides};
    end

    try
        cxxFeOpts=CGXE.CustomCode.getFrontEndOptions('C++',usrIncludes,usrDefines,cppExtraFlags);
        hasCxxCompiler=true;
    catch
        hasCxxCompiler=false;
    end

    if compilerInfo.forceCxx&&hasCxxCompiler
        cFeOpts=deepCopy(cxxFeOpts);
    else
        cFeOpts=CGXE.CustomCode.getFrontEndOptions('C',usrIncludes,usrDefines);
        if~hasCxxCompiler


            cxxFeOpts=deepCopy(cFeOpts);
        end
    end

