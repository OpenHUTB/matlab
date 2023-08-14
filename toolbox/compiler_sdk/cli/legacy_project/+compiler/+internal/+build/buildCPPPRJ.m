function buildOutput=buildCPPPRJ(prjStruct)

    buildOutput=[];

    options=compiler.build.CppSharedLibraryOptions(prjStruct.fileset_exports.file);


    switch prjStruct.param_cpp_api
    case "option.cpp.all"


        s2=prjStruct;
        s2.param_cpp_api="option.cpp.legacy";
        buildOutput=compiler.internal.build.buildCPPPRJ(s2);

        options.Interface="matlab-data";
    case "option.cpp.legacy"
        options.Interface="mwarray";
        options.LibraryVersion=prjStruct.param_version;
    case "option.cpp.generic"
        options.Interface="matlab-data";
    end

    options.DebugBuild="off";
    options.LibraryName=prjStruct.param_appname;

    options=compiler.internal.build.LegacyProjectBuildUtilities.addCommonBuildOptions(options,prjStruct);
    options=compiler.internal.build.LegacyProjectBuildUtilities.addSampleFiles(options,prjStruct);
    options=compiler.internal.build.LegacyProjectBuildUtilities.addAdditionalFiles(options,prjStruct);
    options=compiler.internal.build.LegacyProjectBuildUtilities.addSupportPackages(options,prjStruct);

    if~isempty(buildOutput)
        firstBuildFiles=moveAndRenameGettingStarted(buildOutput,"MWArray.html");
    end

    buildOutputTwo=compiler.build.cppSharedLibrary(options);
    if isempty(buildOutput)
        buildOutput=buildOutputTwo;
    else


        mcrProductFile=fullfile(options.OutputDir,"requiredMCRProducts.txt");
        spfile=fullfile(options.OutputDir,...
        compiler.internal.utils.CLIConstants.SupportPackageMCCFileName);
        secondBuildFiles=moveAndRenameGettingStarted(buildOutputTwo,"DataArray.html");

        buildOutput=compiler.build.Results.constructor(...
        'Files',unique(vertcat(firstBuildFiles,secondBuildFiles)),...
        'Options',options,...
        'BuildType',compiler.internal.build.BuildTypes(buildOutput.BuildType),...
        'IncludedSupportPackages',spfile,...
        'RuntimeDefinition',mcrProductFile,...
        'BuildID',buildOutputTwo.BuildID);
    end
end

function fileList=moveAndRenameGettingStarted(buildOutput,interfaceString)


    fileList=buildOutput.Files;
    ind=-1;
    gsName="";
    for i=1:length(fileList)
        [parentFolder,name,ext]=fileparts(fileList{i});
        if strcmp(strcat(name,ext),"GettingStarted.html")
            gsName=fullfile(parentFolder,strcat("GettingStarted",interfaceString));
            movefile(fileList{i},gsName);
            ind=i;
            break;
        end
    end
    fileList{ind}=char(gsName);
end
