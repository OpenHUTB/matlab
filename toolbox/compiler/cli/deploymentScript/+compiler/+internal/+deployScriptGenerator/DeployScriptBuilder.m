classdef DeployScriptBuilder
    properties
        buildTarget
        packageTarget = compiler.internal.PackageType.NoInstaller;
    end

    properties ( Access = private )
        data
    end

    methods
        function obj = DeployScriptBuilder( dataSource )
            arguments
                dataSource( 1, : )
            end
            obj.data = compiler.internal.deployScriptData.wrapData( dataSource );
        end

        function obj = set.buildTarget( obj, buildTarget )
            arguments
                obj
                buildTarget( 1, 1 )compiler.internal.DeploymentTarget
            end
            obj.buildTarget = buildTarget;
        end

        function obj = set.packageTarget( obj, packageTarget )
            arguments
                obj
                packageTarget( 1, 1 )compiler.internal.PackageType
            end
            obj.packageTarget = packageTarget;
        end

        function script = generateDeploymentScript( obj )
            if ( isempty( obj.buildTarget ) || isempty( obj.packageTarget ) )
                error( message( "Compiler:deploymentscript:builderPropMissing" ) );
            end

            dataAdapter = compiler.internal.deployScriptDataAdapter.getAdapter( obj.buildTarget, obj.data );
            buildGenerator = compiler.internal.deployScriptGenerator.getGenerator( obj.buildTarget, dataAdapter );
            packageGenerator = compiler.internal.deployScriptGenerator.getGenerator( obj.packageTarget, dataAdapter );

            script = strip( strjoin( [ buildGenerator.generateScript(  ),  ...
                "",  ...
                packageGenerator.generateScript(  ) ], newline ) );
        end
    end
end


