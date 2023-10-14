classdef ( Abstract )ClassBasedPRJDataAdapter < compiler.internal.deployScriptDataAdapter.AbstractBuildPRJDataAdapter

    properties
        InstallerAdapter
    end

    methods
        function obj = ClassBasedPRJDataAdapter( prjData )
            arguments
                prjData( 1, 1 )compiler.internal.deployScriptData.LegacyProjectData
            end
            obj = obj@compiler.internal.deployScriptDataAdapter.AbstractBuildPRJDataAdapter( prjData );
            obj.InstallerAdapter = compiler.internal.deployScriptDataAdapter.InstallerPRJDataAdapter( prjData );
        end
    end

    methods ( Access = protected )
        function optValue = getSharedClassBasedLibraryOptionValue( obj, option )
            arguments
                obj
                option( 1, 1 )compiler.internal.option.DeploymentOption
            end

            switch option
                case compiler.internal.option.DeploymentOption.ClassMap
                    classmap = compiler.internal.build.LegacyProjectBuildUtilities.generateClassmapFromPRJ( obj.dataWrapper.getData(  ) );

                    classSettingStrings = "";
                    classNames = classmap.keys;
                    classFunctions = classmap.values;
                    for i = 1:classmap.Count

                        functions = classFunctions{ i };
                        functionsString = "{";
                        for j = 1:numel( functions )
                            if j > 1
                                functionsString = strcat( functionsString, ',' );
                            end
                            functionsString = strcat( functionsString, "'", functions{ j }, "'" );
                        end
                        functionsString = strcat( functionsString, '}' );

                        classSettingStrings =  ...
                            strjoin( [ classSettingStrings,  ...
                            strcat( "classmap('", classNames{ i }, "') = ", functionsString, ';' ) ],  ...
                            newline );
                    end

                    optValue = strjoin( [ 'classmap = containers.Map;', classSettingStrings ], newline );

                case compiler.internal.option.DeploymentOption.DebugBuild
                    optValue = obj.DEFAULT;
                case compiler.internal.option.DeploymentOption.FunctionFiles
                    optValue = obj.dataWrapper.getData(  ).fileset_exports.file;
                otherwise
                    if any( compiler.internal.option.DeploymentOption.allBuildTargetOptions == option )
                        optValue = obj.getBasicBuildOptionValue( option );
                    else

                        optValue = obj.InstallerAdapter.getOptionValue( option );
                    end
            end
        end
    end
end


