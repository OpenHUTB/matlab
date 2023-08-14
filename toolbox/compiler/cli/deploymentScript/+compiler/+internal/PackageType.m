classdef PackageType





    enumeration
ExcelClientForProductionServer
MCRInstaller
NoInstaller
    end

    methods(Static)

        function target=getPackageTypeFromLegacy(prjFile)

            prjStruct=compiler.internal.readPRJStruct(prjFile);
            switch prjStruct.param_target_type

            case "subtarget.web.app"
                target=compiler.internal.PackageType.NoInstaller;
            case "subtarget.standalone"
                target=compiler.internal.PackageType.MCRInstaller;
            case "subtarget.ex.addin"
                if~ispc
                    error(message('Compiler:build:compatibility:unsupportedPlatform',prjFile))
                end
                target=compiler.internal.PackageType.MCRInstaller;
            otherwise




                if~license('test','matlab_builder_for_java')
                    error(message('Compiler:build:compatibility:sdkNotAvailable',prjFile))
                end

                switch prjStruct.param_target_type
                case "subtarget.mads"
                    target=compiler.internal.PackageType.NoInstaller;
                case "subtarget.mps.excel"
                    if~ispc
                        error(message('Compiler:build:compatibility:unsupportedPlatform',prjFile))
                    end
                    target=compiler.internal.PackageType.ExcelClientForProductionServer;
                case{"subtarget.library.c","subtarget.library.cpp","subtarget.java.package","subtarget.python.module"}
                    target=compiler.internal.PackageType.MCRInstaller;
                case{"subtarget.net.component","subtarget.com.component"}
                    if~ispc
                        error(message('Compiler:build:compatibility:unsupportedPlatform',prjFile))
                    end
                    target=compiler.internal.PackageType.MCRInstaller;
                case "subtarget.hadoop"
                    error(message('Compiler:build:compatibility:hadoopNotSupported'))
                otherwise


                    error(message('Compiler:build:compatibility:notCompatibilityPRJ',prjFile))
                end

            end
        end
    end
end