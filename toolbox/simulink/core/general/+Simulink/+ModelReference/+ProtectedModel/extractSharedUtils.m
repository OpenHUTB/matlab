function extractSharedUtils(fullName,rootTargetDir,currentTarget,relName,year,topMdl,rootDir,buildDirs,varargin)



    isPackagedModel=false;
    xrelType=Simulink.ModelReference.ProtectedModel.CrossReleaseWorkflowType.None;
    if~isempty(varargin)
        isPackagedModel=varargin{1};
        if numel(varargin)>1
            xrelType=varargin{2};
        end
    end

    if isPackagedModel
        rtwprivate('ec_set_replacement_flag',topMdl);
        dstDir=fullfile(rootTargetDir,'_sharedutils_packaged');
    else
        import Simulink.ModelReference.ProtectedModel.*;
        import Simulink.ModelReference.common.*;
        sharedUtilsRelName=constructTargetRelationshipName(relName,currentTarget);
        dstDir=fullfile(rootTargetDir,'_sharedutils_protected');
        writeRelationship(fullName,dstDir,sharedUtilsRelName,year);
        slVersionObj=simulink_version(slInternal('getProtectedModelVersion',fullName));
        if xrelType==Simulink.ModelReference.ProtectedModel.CrossReleaseWorkflowType.ERT
            coder.internal.xrel.protectedSharedUtilsERTPostUnpackHook(fullName,dstDir,topMdl,slVersionObj)
        elseif xrelType==Simulink.ModelReference.ProtectedModel.CrossReleaseWorkflowType.NonERT||...
            xrelType==Simulink.ModelReference.ProtectedModel.CrossReleaseWorkflowType.SharedCodeUpdate
            coder.internal.xrel.protectedSharedUtilsNonERTPostUnpackHook(fullName,dstDir,topMdl,slVersionObj);
        end
    end


    if isempty(currentTarget)
        topSharedUtilsDir=fullfile(rootDir,buildDirs.SharedUtilsSimDir);
    else
        topSharedUtilsDir=fullfile(rootDir,buildDirs.SharedUtilsTgtDir);
    end


    [~,childModel]=fileparts(fullName);
    sl('merge_shared_utils',topMdl,dstDir,topSharedUtilsDir,...
    childModel,rootDir,true);

    if xrelType==Simulink.ModelReference.ProtectedModel.CrossReleaseWorkflowType.SharedCodeUpdate
        coder.internal.xrel.protectedSharedUtilsSharedCodeUpdatePostMergeHook(topSharedUtilsDir)
    end

    sl('removeDir',dstDir);
end


