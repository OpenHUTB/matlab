classdef DeploymentTarget





    enumeration
        COMComponent,
        CppSharedLibrary,
        CSharedLibrary,
        DotNETAssembly,
        ExcelAddin,
        ExcelClientForProductionServer,
        JavaPackage,
        ProductionServerArchive,
        PythonPackage,
        StandaloneApplication,
WebAppArchive
    end

    methods(Static)

        function target=getDeploymentTargetFromProjectConfiguration(data)
            if isa(data,"compiler.project.COMLibraryConfigurationOptions")
                target=compiler.internal.DeploymentTarget.COMComponent;
            elseif isa(data,"compiler.project.CLibraryConfigurationOptions")
                target=compiler.internal.DeploymentTarget.CSharedLibrary;
            elseif isa(data,"compiler.project.CppLibraryConfigurationOptions")
                target=compiler.internal.DeploymentTarget.CppSharedLibrary;
            elseif isa(data,"compiler.project.DotNETLibraryConfigurationOptions")
                target=compiler.internal.DeploymentTarget.DotNETAssembly;
            elseif isa(data,"compiler.project.JavaLibraryConfigurationOptions")
                target=compiler.internal.DeploymentTarget.JavaPackage;
            elseif isa(data,"compiler.project.PSAConfigurationOptions")
                target=compiler.internal.DeploymentTarget.ProductionServerArchive;
            elseif isa(data,"compiler.project.PythonLibraryConfigurationOptions")
                target=compiler.internal.DeploymentTarget.PythonPackage;
            elseif isa(data,"compiler.project.StandaloneAppConfigurationOptions")
                target=compiler.internal.DeploymentTarget.StandaloneApplication;
            elseif isa(data,"compiler.project.WebAppConfigurationOptions")
                target=compiler.internal.DeploymentTarget.WebAppArchive;
            else
                target=[];
            end


        end


        function target=getDeploymentTargetFromLegacy(prjFile)

            prjStruct=compiler.internal.readPRJStruct(prjFile);
            switch prjStruct.param_target_type

            case "subtarget.web.app"
                target=compiler.internal.DeploymentTarget.WebAppArchive;
            case "subtarget.standalone"
                target=compiler.internal.DeploymentTarget.StandaloneApplication;
            case "subtarget.ex.addin"
                if~ispc
                    error(message('Compiler:build:compatibility:unsupportedPlatform',prjFile))
                end
                target=compiler.internal.DeploymentTarget.ExcelAddin;
            otherwise




                if~license('test','matlab_builder_for_java')
                    error(message('Compiler:build:compatibility:sdkNotAvailable',prjFile))
                end

                switch prjStruct.param_target_type
                case "subtarget.mads"
                    target=compiler.internal.DeploymentTarget.ProductionServerArchive;
                case "subtarget.mps.excel"
                    if~ispc
                        error(message('Compiler:build:compatibility:unsupportedPlatform',prjFile))
                    end
                    target=compiler.internal.DeploymentTarget.ExcelClientForProductionServer;
                case "subtarget.library.c"
                    target=compiler.internal.DeploymentTarget.CSharedLibrary;
                case "subtarget.library.cpp"
                    target=compiler.internal.DeploymentTarget.CppSharedLibrary;
                case "subtarget.java.package"
                    target=compiler.internal.DeploymentTarget.JavaPackage;
                case "subtarget.python.module"
                    target=compiler.internal.DeploymentTarget.PythonPackage;
                case "subtarget.net.component"
                    if~ispc
                        error(message('Compiler:build:compatibility:unsupportedPlatform',prjFile))
                    end
                    target=compiler.internal.DeploymentTarget.DotNETAssembly;
                case "subtarget.com.component"
                    if~ispc
                        error(message('Compiler:build:compatibility:unsupportedPlatform',prjFile))
                    end
                    target=compiler.internal.DeploymentTarget.COMComponent;
                case "subtarget.hadoop"
                    error(message('Compiler:build:compatibility:hadoopNotSupported'))
                otherwise


                    error(message('Compiler:build:compatibility:notCompatibilityPRJ',prjFile))
                end

            end
        end
    end
end

