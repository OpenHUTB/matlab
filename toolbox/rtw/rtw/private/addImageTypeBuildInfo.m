
function result=addImageTypeBuildInfo(modelName)

    mwimageIncPath=fullfile(matlabroot,'extern','include','images');
    coder.internal.callBuildInfo(modelName,1,'addIncludePaths',mwimageIncPath,'TLC');
    coder.internal.callBuildInfo(modelName,1,'addIncludeFiles','datatypes_util.hpp',mwimageIncPath,'TLC');
    coder.internal.callBuildInfo(modelName,1,'addIncludeFiles','ImageDefs.hpp',mwimageIncPath,'TLC');
    if strcmp(get_param(modelName,'IsERTTarget'),'off')||strcmp(get_param(modelName,'ImplementImageWithCVMat'),'off')
        coder.internal.callBuildInfo(modelName,1,'addIncludeFiles','ImageMetadata.hpp',mwimageIncPath,'TLC');
        coder.internal.callBuildInfo(modelName,1,'addIncludeFiles','Image.hpp',mwimageIncPath,'TLC');
        coder.internal.callBuildInfo(modelName,1,'addIncludeFiles','ImageUtils.hpp',mwimageIncPath,'TLC');
        mwimageSrcPath=fullfile(matlabroot,'toolbox','shared','images_datatypes','extern');
        coder.internal.callBuildInfo(modelName,1,'addSourceFiles','Image.cpp',mwimageSrcPath,'TLC');
    end

    result=0;
end
