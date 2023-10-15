classdef ModuleUtils
    properties ( GetAccess = public, SetAccess = protected, Hidden = true )
        HasMATLABSILPILInterface( 1, 1 )logical = false
        HasSimulinkCoder( 1, 1 )logical = false
    end

    methods ( Access = protected )



        function this = ModuleUtils(  )
            this.HasMATLABSILPILInterface = exist( 'coder.connectivity.MATLABSILPILInterfaceStore', 'class' ) == 8;
            this.HasSimulinkCoder = ~isempty( which( 'Simulink.fileGenControl' ) ) &&  ...
                ~isempty( which( 'RTW.getBuildDir' ) );
        end
    end

    methods ( Static, Access = protected )



        function inst = instance(  )
            persistent obj;
            if isempty( obj )
                obj = codeinstrum.internal.codecov.ModuleUtils(  );
            end
            inst = obj;
        end
    end

    methods ( Static )




        function moduleName = buildModuleName( isMATLABCoder, projectOrModelName, covMode )
            arguments
                isMATLABCoder( 1, 1 )logical
                projectOrModelName( 1, 1 )string
                covMode( 1, 1 )string = ""
            end

            if isMATLABCoder
                narginchk( 2, 3 );
                projectOrModelName = char( projectOrModelName );
                if covMode.strlength(  ) < 1
                    if endsWith( projectOrModelName, "_sil" )
                        covMode = "SIL";
                    elseif endsWith( projectOrModelName, "_pil" )
                        covMode = "PIL";
                    else
                        assert( false );
                    end
                    projectOrModelName = projectOrModelName( 1:end  - 4 );
                end
                moduleName = [ projectOrModelName, ' (', char( covMode ), '_MATLAB)' ];
            else
                narginchk( 3, 3 );
                moduleName = [ char( projectOrModelName ), ' (', regexprep( char( covMode ), '^ModelRefTop', '' ), ')' ];
            end
        end




        function [ projectOrModelName, covMode, isSharedUtils, isMATLABCoder ] = parseModuleName( moduleName )
            arguments
                moduleName( 1, 1 )string
            end


            regExpr = '^(.*) \((.*)\)$';
            tokens = regexp( moduleName, regExpr, 'tokens' );


            if isempty( tokens )
                moduleName = codeinstrum.internal.codecov.ModuleUtils.buildModuleName( true, moduleName );
                tokens = regexp( moduleName, regExpr, 'tokens' );
            end

            assert( ~isempty( tokens ), 'Invalid format for module name ''%s''', moduleName );
            tokens = tokens{ 1 };

            projectOrModelName = tokens{ 1 };
            covMode = tokens{ 2 };
            isMATLABCoder = endsWith( covMode, '_MATLAB' );
            if isMATLABCoder
                covMode = strrep( covMode, '_MATLAB', '' );
            end

            isSharedUtils = startsWith( projectOrModelName, "[" );
            if isSharedUtils
                projectOrModelName = projectOrModelName( 2:end  - 1 );
            end
        end





        function [ trDataFile, resHitsFile, buildDir, isSharedUtils, isMATLABCoder ] = getCodeCovDataFiles( moduleName, buildDirInfo )
            arguments
                moduleName( 1, 1 )string
                buildDirInfo = [  ];
            end


            trDataFile = '';
            resHitsFile = '';
            buildDir = '';


            [ projectOrModelName, covMode, isSharedUtils, isMATLABCoder ] =  ...
                codeinstrum.internal.codecov.ModuleUtils.parseModuleName( moduleName );


            obj = codeinstrum.internal.codecov.ModuleUtils.instance(  );

            if isMATLABCoder
                if isempty( buildDirInfo )
                    if ~obj.HasMATLABSILPILInterface
                        return
                    end
                    interface = coder.connectivity.MATLABSILPILInterfaceStore.getInstance(  ).getSILPILInterface( projectOrModelName );
                    if isempty( interface )
                        return
                    end
                    buildDir = interface.getCodeDir(  );
                else
                    buildDir = buildDirInfo;
                end
            else
                if ~obj.HasSimulinkCoder
                    return
                end
                if isSharedUtils
                    fileGenCfg = Simulink.fileGenControl( 'getConfig' );
                    codeGenFolder = fileGenCfg.CodeGenFolder;
                    relBuildDir = projectOrModelName;
                    [ ~, projectOrModelName ] = fileparts( relBuildDir );
                else
                    if isempty( buildDirInfo )
                        buildDirInfo = RTW.getBuildDir( projectOrModelName );
                    end
                    codeGenFolder = buildDirInfo.CodeGenFolder;
                    if ( covMode == "ModelRefSIL" ) || ( covMode == "ModelRefPIL" )
                        relBuildDir = buildDirInfo.ModelRefRelativeBuildDir;
                    else
                        relBuildDir = buildDirInfo.RelativeBuildDir;
                    end
                end
                buildDir = fullfile( codeGenFolder, relBuildDir );
            end
            trDataFile = fullfile( buildDir, [ projectOrModelName, '_', covMode, '.db' ] );
            resHitsFile = fullfile( buildDir, [ projectOrModelName, '_', covMode, '_R.db' ] );
        end
    end
end

