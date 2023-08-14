function cmakePackageList=getAdaptiveCMakePackages(modelName)








    cmakePackageList={};

    tcName=get_param(modelName,'Toolchain');

    switch tcName
    case 'AUTOSAR Adaptive | CMake'

        cmakePackageList{end+1}='Threads';

        buildConfig=get_param(modelName,'BuildConfiguration');
        if strcmp(buildConfig,'Specify')


            tcSpecify=get_param(modelName,'CustomToolchainOptions');

            packageIndex=find(strcmp(tcSpecify,'Required Packages'))+1;
            packages=tcSpecify{packageIndex};
            packages=strip(packages);
            if~isempty(packages)
                packagesCell=split(packages);
                for ii=1:numel(packagesCell)
                    cmakePackageList{end+1}=packagesCell{ii};%#ok<*AGROW>
                end
            end
        end
    case 'AUTOSAR Adaptive Linux Executable'

        cmakePackageList{end+1}='Threads';
    otherwise
    end
end


