function rosNodeCMakeListGeneration(buildInfo,bldParams)




    newBuildInfo=RTW.BuildInfo;
    newBuildInfo.ComponentName=buildInfo.ComponentName;

    rosIncludeDir='/opt/ros/$ENV{ROS_DISTRO}/include/';
    rosLibDir='/opt/ros/$ENV{ROS_DISTRO}/lib/';
    cudaIncludeDir='${CUDA_INCLUDE_DIRS}';
    catkinIncludeDir='${catkin_INCLUDE_DIRS}';


    cudaEnabled=contains(lower(bldParams.configInfo.Toolchain),'cuda')||contains(lower(bldParams.configInfo.Toolchain),'nvcc');


    workingOnHost=~startsWith(bldParams.configInfo.HardwareImplementation.TargetHWDeviceType,'ARM');


    cmakelistAddIncludes();


    cmakelistAddLibraryAndDependencies();


    newBuildInfo.addCompileFlags('-std=c++11');


    codebuild(newBuildInfo,'BuildMethod','cmake','BuildVariant','STANDALONE_EXECUTABLE');


    cmakelistPostProcessing();



    function cmakelistAddLibraryAndDependencies()


        codingTarget='so';
        if strcmpi(bldParams.project.CodingTarget,'rtw:lib')
            codingTarget='a';
        end
        tmpLibFile=newBuildInfo.addFiles('syslib',sprintf('lib%s',...
        newBuildInfo.ComponentName));


        if workingOnHost
            tmpLibFile.FileName=sprintf('%s/lib%s.%s',bldParams.project.BldDirectory,...
            newBuildInfo.ComponentName,codingTarget);
        else


            tmpLibFile.FileName=sprintf('<path-to-lib>/lib%s.%s',...
            newBuildInfo.ComponentName,codingTarget);
        end


        newBuildInfo.addSysLibs('roscpp.so',rosLibDir);
        newBuildInfo.addSysLibs('boost_system.so');
    end


    function cmakelistAddIncludes()


        newBuildInfo.addIncludePaths({catkinIncludeDir,rosIncludeDir,cudaIncludeDir},'BuildDir');


        if cudaEnabled
            mainFileName='main.cu';
        else
            mainFileName='main.cpp';
        end


        if workingOnHost
            newBuildInfo.addIncludePaths({bldParams.project.ExamplesDirectory,...
            bldParams.project.BldDirectory},'BuildDir');
            newBuildInfo.addSourceFiles(mainFileName,bldParams.project.ExamplesDirectory);
        else


            newBuildInfo.addIncludePaths({'${START_DIR}',...
            sprintf('<path-to-codgen-includes>/%s/',newBuildInfo.ComponentName)},'BuildDir');
            newBuildInfo.addSourceFiles(mainFileName,'${START_DIR}');
        end
    end


    function cmakelistPostProcessing()

        if workingOnHost



            catkinCommentPrefix='#';
        else
            catkinCommentPrefix='';
        end

        cmakelistFile=sprintf('%s/CMakeLists.txt',bldParams.project.OutDirectory);
        finalCmakelistFile=sprintf('%s/CMakeLists.txt',bldParams.project.ExamplesDirectory);
        if isfile(cmakelistFile)

            fid=fopen(cmakelistFile,'r');
            cmakelistContents=textscan(fid,'%s','Delimiter','\n','HeaderLines',0);
            cmakelistContents=cmakelistContents{1};
            fclose(fid);



            fid=fopen(cmakelistFile,'w');
            for i=1:size(cmakelistContents,1)
                line=cmakelistContents{i};

                if cudaEnabled&&startsWith(line,'add_executable')
                    line=sprintf('cuda_%s',line);
                elseif startsWith(line,'target_link_libraries')
                    if contains(line,' PRIVATE ')
                        line=replace(line,' PRIVATE ',' ');
                    elseif contains(line,' PUBLIC ')
                        line=replace(line,' PUBLIC ',' ');
                    end
                elseif startsWith(line,'project')

                    line=sprintf('%s\n\n%s\n%s\n%s\n\n%s\n%s\n\n%s\n%s\n%s\n\n%s\n%s\n%s\n',line,...
                    '# Find catkin',...
                    sprintf('%sfind_package(catkin REQUIRED COMPONENTS roscpp)',catkinCommentPrefix),...
                    sprintf('%scatkin_package()',catkinCommentPrefix));

                    if cudaEnabled
                        line=sprintf('%s\n\n%s\n%s\n\n%s\n%s\n%s\n\n%s\n%s\n%s\n',line,...
                        '# Find CUDA Installation and Set CUDA Environment Variables',...
                        'find_package(CUDA REQUIRED)',...
                        '# Change from gcc to nvcc Compiler',...
                        'set(CMAKE_C_COMPILER ${CUDA_NVCC_EXECUTABLE})',...
                        'set(CMAKE_CXX_COMPILER ${CUDA_NVCC_EXECUTABLE})',...
                        '# Eliminate GCC Specific Compiler Flags',...
                        'set(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS "")',...
                        'set(CMAKE_EXECUTABLE_RUNTIME_CXX_FLAG "")');
                    end
                elseif workingOnHost&&startsWith(line,'get_filename_component')

                    line=sprintf('set(START_DIR %s)',bldParams.project.OutDirectory);
                end

                fwrite(fid,sprintf('%s\n',line));

            end
            fclose(fid);


            movefile(cmakelistFile,finalCmakelistFile);
        end
    end

end