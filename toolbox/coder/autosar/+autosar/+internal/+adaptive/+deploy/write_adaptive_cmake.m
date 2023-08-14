function write_adaptive_cmake(writer,type,...
    appName,...
    SWCName,...
    buildType,...
    packages,...
    cppSources,...
    arxmlSources,...
    includedirs,...
    defines,...
    libpaths,...
    linklibs,...
    subdirs,...
    subTargets,...
    cmakeVars)

















    validateattributes(writer,{'autosar.internal.adaptive.deploy.Writer'},{'numel',1});
    validateattributes(appName,{'string'},{'numel',1});
    validateattributes(cppSources,{'string'},{'nonempty'});
    validatestring(buildType,{'Release','Debug'});

    write_header(writer,appName,buildType);

    write_cmake_vars(writer,cmakeVars);

    write_packages(writer,packages);

    write_cached_command(writer,"include_directories",includedirs,...
    "EXTRAINCLUDES");

    write_cached_command(writer,"add_definitions",defines,...
    "EXTRADEFINITIONS");

    write_cached_command(writer,"link_directories",libpaths,...
    "EXTRALIBRARYPATHS");

    write_aragen(writer,arxmlSources,appName,SWCName);

    write_subdirs(writer,subdirs,subTargets);

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

    write_target_link_libraries(writer,linklibs,appName);

end

function write_cached_command(writer,command,values,variable)


















    valid_values=get_valid_entries(values);
    if~isempty(valid_values)
        writer.writeln("list(APPEND %s ",variable);
        for ii=1:length(valid_values)
            writer.writeln("    %s",valid_values(ii));
        end
        writer.writeln(")\n");

    end
    writer.writeln("if(DEFINED %s)",variable);
    writer.writeln("    %s(${%s})",command,variable);
    writer.writeln("endif()");
    writer.writeln("");
end

function validentries=get_valid_entries(field)



    if isempty(field)
        validentries=[];
        return;
    end

    idx=field.strip.strlength>0;
    validentries=field(idx);
end

function write_header(writer,appName,buildType)
    writer.writeln("cmake_minimum_required(VERSION 3.1)");
    writer.writeln("project(%s C CXX)",appName);
    writer.writeln("set(CMAKE_CXX_STANDARD 11)");
    writer.writeln("set(CMAKE_BUILD_TYPE %s CACHE STRING ""CMake Build Type"")",buildType);
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
end

function write_packages(writer,packages)
    writer.writeln("find_package(Threads)");

    packages=get_valid_entries(packages);
    for ii=1:length(packages)
        writer.writeln("find_package(%s REQUIRED)",packages(ii));
    end
    writer.writeln("");
end

function write_aragen(writer,arxmlSources,appName,SWCName)
    arxmlSources=get_valid_entries(arxmlSources);
    if isempty(arxmlSources)
        return;
    end

    writer.writeln("set(ARXMLFILES");
    for arxmlSource=arxmlSources
        writer.writeln("    %s",arxmlSource);
    end
    writer.writeln("    ${ARA_ARXMLS_DIR}/stdtypes.arxml\n");
    writer.writeln(")");

    writer.writeln("file(GLOB_RECURSE SOURCES ${GENDIR} *.cpp)");

    writer.writeln("set(GENDIR ${PROJECT_BINARY_DIR}/generated/)");

    writer.writeln("add_aragen(");
    writer.writeln("    DESTINATION ${GENDIR}");
    writer.writeln("    TARGET %sGenerated",appName);
    writer.writeln("  SWC %s",SWCName);
    writer.writeln("  SYSMANIFEST %sSystemManifest",SWCName);
    writer.writeln("    OUTPUT");
    writer.writeln("      ${GENDIR}/proxy_%s.h",appName);
    writer.writeln("      ${GENDIR}/proxy_vsomeip_%s.h",appName);
    writer.writeln("      ${GENDIR}/service_desc_%s.cpp",appName);
    writer.writeln("      ${GENDIR}/service_desc_%s.h",appName);
    writer.writeln("      ${GENDIR}/vsomeip_service_mapping-%s.cpp",appName);
    writer.writeln("      ${GENDIR}/ara_com_main-%s.cpp",appName);
    writer.writeln("      ${GENDIR}/radar.cpp");
    writer.writeln("      ${GENDIR}/");
    writer.writeln("  ARXMLS");
    writer.writeln("        ${ARA_ARXMLS_DIR}/stdtypes.arxml");
    writer.writeln(")");
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

function write_target_link_libraries(writer,linklibs,appName)
    if~isempty(linklibs)
        writer.writeln("list(APPEND EXTRALIBS");
        for ii=1:length(linklibs)
            writer.writeln("    %s",linklibs(ii));
        end
        writer.writeln(")\n");
    end
    writer.writeln("");

    writer.writeln("target_link_libraries( %s ${EXTRALIBS} rt Threads::Threads)",appName);
end



