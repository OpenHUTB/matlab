function write_cmake(writer,appName,swcName,buildType,cppSources,arxmlSources,includedirs,linklibs)











    validateattributes(writer,{'autosar.internal.adaptive.deploy.Writer'},{'numel',1});
    validateattributes(appName,{'string'},{'numel',1});
    validateattributes(cppSources,{'string'},{'nonempty'});

    writer.writeln("cmake_minimum_required(VERSION 3.0)");

    writer.writeln("set(CMAKE_CXX_STANDARD 11)");
    if strlength(buildType)>0
        writer.writeln("set(CMAKE_BUILD_TYPE %s)",buildType);
    end

    writer.writeln("");

    writer.writeln("find_package(ara-logging REQUIRED)\n");
    writer.writeln("find_package(ARAExec REQUIRED)\n");
    writer.writeln("find_package(AdaptivePlatform REQUIRED)\n");
    writer.writeln("find_package(ara-gen REQUIRED)\n");
    writer.writeln("find_package(ara-com REQUIRED)\n");
    writer.writeln("find_package(ara-arxmls REQUIRED)\n\n");

    writer.writeln("\n");

    writer.writeln("include_directories(");
    for ii=1:length(includedirs)
        writer.writeln("    %s",includedirs(ii));
    end
    writer.writeln("    ${ARA_ARXML_INCLUDES}\n");
    writer.writeln("    ${ARA_COM_INCLUDS}\n");
    writer.writeln("    ${ARAEXEC_INCLUDES}\n");
    writer.writeln("    ${ARA_LOGGING_INCLUDES}\n");
    writer.writeln("    ${ADAPTIVEPLATFORM_INCLUDES}\n");
    writer.writeln("    ${GENDIR}/includes\n");
    writer.writeln(")\n");

    writer.writeln("set(ARXMLFILES");
    for arxmlSource=arxmlSources
        writer.writeln("    %s",arxmlSource);
    end
    writer.writeln("    ${ARA_ARXMLS_DIR}/stdtypes.arxml\n");
    writer.writeln(")\n");

    writer.writeln("file(GLOB_RECURSE SOURCES ${GENDIR} *.cpp)\n");

    writer.writeln("set(GENDIR ${PROJECT_BINARY_DIR}/generated/)\n");

    writer.writeln("add_aragen(\n");
    writer.writeln("    DESTINATION ${GENDIR}\n");
    writer.writeln("    TARGET %sGenerated\n",appName);
    writer.writeln("  SWC %s\n",swcName);
    writer.writeln("  SYSMANIFEST %sSystemManifest\n",swcName);
    writer.writeln("    OUTPUT\n");
    writer.writeln("      ${GENDIR}/proxy_%s.h\n",appName);
    writer.writeln("      ${GENDIR}/proxy_vsomeip_%s.h\n",appName);
    writer.writeln("      ${GENDIR}/service_desc_%s.cpp\n",appName);
    writer.writeln("      ${GENDIR}/service_desc_%s.h\n",appName);
    writer.writeln("      ${GENDIR}/vsomeip_service_mapping-%s.cpp\n",appName);
    writer.writeln("      ${GENDIR}/ara_com_main-%s.cpp\n",appName);
    writer.writeln("      ${GENDIR}/radar.cpp\n");
    writer.writeln("      ${GENDIR}/\n");
    writer.writeln("  ARXMLS\n");
    writer.writeln("        ${ARA_ARXMLS_DIR}/stdtypes.arxml\n");

    writer.writeln("add_executable(%s ${SOURCES})",appName);
    writer.writeln("target_link_libraries(%s -lrt -pthread ${CMAKE_THREAD_LIBS_INIT} ${ARA_LIBRARIES} ${ARA_LOGGING_LIBRARIES} ${ARAEXEC_LIBRARIES} ${ADAPTIVEPLATFORM_LIBRARIES})\n",...
    appName);
    for ii=1:length(linklibs)
        writer.write(" %s",linklibs(ii));
    end
    writer.writeln(")");
    writer.writeln("install(TARGETS %s DESTINATION bin)\n",appName);
    writer.writeln("\n");

end

