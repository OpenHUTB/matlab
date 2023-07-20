function toolRootFolder=getToolchainRootFolder(hCS)





    targetFolder=codertarget.target.getTargetFolder(hCS);
    fileName=codertarget.target.getThirdPartyToolsRegistrationFileName(targetFolder);
    h=codertarget.thirdpartytools.ThirdPartyToolInfo(fileName);
    names=h.getThirdPartyTools();
    tool=h.getThirdPartyTools();
    toolRootFolder=[];
    for i=1:numel(tool)
        if isequal(tool{i}{:}.Category,'toolchain')&&...
            isequal(names{i}{1}.ToolName,get_param(hCS,'Toolchain'))
            toolRootFolder=tool{i}{:}.RootFolder;
            break;
        end
    end
end