function write_adaptive_modern_cmake(writer,type,...
    appName,...
    buildType,...
    packages,...
    cppSources,...
    arxmlSources,...
    includedirs,...
    defines,...
    libpaths,...
    linklibs,...
    buildInfoLibs,...
    subdirs,...
    subTargets,...
    cmakeVars)


















    validateattributes(writer,{'autosar.internal.adaptive.deploy.Writer'},{'numel',1});
    validateattributes(appName,{'string'},{'numel',1});
    validateattributes(cppSources,{'string'},{'nonempty'});
    validatestring(buildType,{'Release','Debug'});

    switch(type)
    case coder.make.enum.BuildOutput.EXECUTABLE
        addProject=true;
    otherwise
        addProject=false;
    end

    write_header(writer,appName,buildType,addProject);

    write_cmake_vars(writer,cmakeVars);

    write_sources(writer,cppSources);

    switch(type)
    case coder.make.enum.BuildOutput.EXECUTABLE
        writer.writeln("add_executable(%s ${SOURCES})",appName);
    case coder.make.enum.BuildOutput.SHARED_LIBRARY
        writer.writeln("add_library(%s SHARED ${SOURCES})",appName);
    case coder.make.enum.BuildOutput.STATIC_LIBRARY
        writer.writeln("add_library(%s STATIC ${SOURCES})",appName);
    otherwise
        MSLDiagnostic('autosarstandard:validation:BuildTypeNotSupported',string(type),appName).reportAsWarning;
    end
    writer.writeln("");

    write_arxml(writer,arxmlSources,appName);

    write_cxx_target_compile_features(writer,appName);

    write_cached_command(writer,"target_include_directories",appName,"PUBLIC",...
    includedirs,"EXTRAINCLUDES");

    write_cached_command(writer,"target_compile_definitions",appName,"PUBLIC",...
    defines,"EXTRADEFINITIONS");

    write_subdirs(writer,subdirs,subTargets);

    write_packages(writer,packages);

    write_target_link_libraries(writer,libpaths,buildInfoLibs,linklibs,appName);

end

function write_cached_command(writer,command,targetName,visibility,values,variable)




















    valid_values=get_valid_entries(values);
    if~isempty(valid_values)
        writer.writeln("list(APPEND %s ",variable);
        for ii=1:length(valid_values)
            writer.writeln("    %s",valid_values(ii));
        end
        writer.writeln(")\n");

    end
    writer.writeln("if(DEFINED %s)",variable);
    writer.writeln("    %s(%s %s ${%s})",command,targetName,visibility,variable);
    writer.writeln("endif()");
    writer.writeln("");
end

function validentries=get_valid_entries(field)



    if isempty(field)
        validentries=[];
        return;
    end

    validentries=field.strip;
end

function write_header(writer,appName,buildType,addProject)
    writer.writeln("cmake_minimum_required(VERSION 3.1...3.17)");
    writer.writeln("");
    writer.writeln("if(${CMAKE_VERSION} VERSION_LESS 3.12)");
    writer.writeln("    cmake_policy(VERSION ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION})");
    writer.writeln("endif()");
    writer.writeln("");


    if(addProject)
        writer.writeln("project(%s VERSION 1.0 DESCRIPTION ""%s autosar adaptive application."" LANGUAGES C CXX)",appName,appName);
    end

    writer.writeln("");
    writer.writeln("set(CMAKE_BUILD_TYPE %s CACHE STRING ""CMake Build Type"")",buildType);
    writer.writeln("");
end

function write_cxx_target_compile_features(writer,appName)
    writer.writeln("set_target_properties(%s PROPERTIES CXX_STANDARD 11 CXX_STANDARD_REQUIRED YES CXX_EXTENSIONS NO )",appName);
    writer.writeln("");
    writer.writeln("if(${CMAKE_VERSION} VERSION_GREATER_EQUAL 3.8)");
    writer.writeln("    target_compile_features(%s PUBLIC cxx_std_11)",appName);
    writer.writeln("endif()");


    if(slfeature('MWModernCMakeUsage')==3)
        writer.writeln("set_target_properties(%s PROPERTIES POSITION_INDEPENDENT_CODE ON)",appName);
    end
    writer.writeln("");
end

function write_cmake_vars(writer,cmakeVars)
    vars=fieldnames(cmakeVars);
    for ii=1:length(vars)
        cmakeVar=vars{ii};
        switch(cmakeVars.(cmakeVar))
        case{"START_DIR","MATLAB_ROOT"}
            writer.writeln("set(%s ""%s"" CACHE PATH ""User Customizable Variable"")",cmakeVar,cmakeVars.(cmakeVar));
        otherwise
            writer.writeln("set(%s ""%s"" CACHE STRING ""User Customizable Variable"")",cmakeVar,cmakeVars.(cmakeVar));
        end
    end

    writer.writeln("set(CMAKE_THREAD_PREFER_PTHREAD TRUE CACHE BOOL ""Cmake prefer pthread"")");
    writer.writeln("set(THREADS_PREFER_PTHREAD_FLAG TRUE CACHE STRING ""Threads prefer pthread"")");
    writer.writeln("");
end

function write_packages(writer,packages)
    writer.writeln("find_package(Threads)");

    packages=get_valid_entries(packages);
    for ii=1:length(packages)
        writer.writeln("find_package(%s REQUIRED)",packages(ii));
    end
    writer.writeln("");
end

function write_arxml(writer,arxmlSources,appName)

    arxmlSources=get_valid_entries(arxmlSources);
    if isempty(arxmlSources)
        return;
    end
    writer.writeln("file(GLOB_RECURSE ARXMLFILES ""%s/*.arxml"")",arxmlSources);
    writer.writeln("set(%s_ARXMLFILES ""${ARXML_FILES}"" CACHE STRING ""Arxml files generated for the model %s."" FORCE)",...
    appName,appName);
    writer.writeln("");
end

function write_subdirs(writer,subdirs,subTargets)
    if~isempty(subdirs)
        targetsNum=numel(subTargets);
        for ii=1:numel(subdirs)



            if(ii<=targetsNum)
                writer.writeln("if (NOT TARGET %s)",subTargets(ii));
            end
            writer.writeln("add_subdirectory(%s %s)",subdirs(ii),subdirs(ii));
            if(ii<=targetsNum)
                writer.writeln("endif()");
            end
        end
        writer.writeln("");
    end
end

function write_sources(writer,cppSources)
    writer.writeln("set(SOURCES");

    for source=cppSources
        writer.writeln("    %s",source);
    end
    writer.writeln(")\n");
end

function write_target_link_libraries(writer,libpaths,buildInfoLibs,linklibs,appName)

    libpaths=get_valid_entries(libpaths);
    libpathVar="EXTRALIBRARYPATHS";
    if~isempty(libpaths)
        writer.writeln("list(APPEND %s",libpathVar);

        for ii=1:length(libpaths)
            writer.writeln("    %s",libpaths(ii));
        end
        writer.writeln(")\n");
    end

    linklibs=get_valid_entries(linklibs);
    buildInfoLibs=get_valid_entries(buildInfoLibs);


    if~isempty(buildInfoLibs)
        linklibs=setdiff(linklibs,buildInfoLibs);
    end

    allLibsPathString="";
    if~isempty(linklibs)
        for ii=1:length(linklibs)
            writer.writeln("find_library(%s_LIB %s PATHS ${%s})",linklibs(ii),...
            linklibs(ii),libpathVar);
            allLibsPathString=sprintf("%s ${%s_LIB}",allLibsPathString,linklibs(ii));
        end
    end
    writer.writeln("");


    if~isempty(buildInfoLibs)
        for ii=1:length(buildInfoLibs)
            allLibsPathString=sprintf("%s %s",allLibsPathString,buildInfoLibs(ii));
        end
    end

    writer.writeln("target_link_libraries(%s PUBLIC ${CMAKE_DL_LIBS} rt Threads::Threads %s)",appName,allLibsPathString);
end




