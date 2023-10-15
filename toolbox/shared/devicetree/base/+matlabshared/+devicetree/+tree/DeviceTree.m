classdef DeviceTree < matlabshared.devicetree.util.Commentable









































    properties ( SetAccess = protected )
        Nodes matlabshared.devicetree.node.NodeBase
    end

    properties ( Hidden, SetAccess = protected )
        IncludeDirectories string
    end

    properties ( Hidden )

    end

    properties ( Access = protected, Constant )
        Header = "/dts-v1/;"
        OverlayHeader = "/plugin/;"

        DefaultCompilerPath = "dtc";


    end


    methods

        function obj = DeviceTree(  )
        end

        function hNode = addRootNode( obj )






            hNode = matlabshared.devicetree.node.Node( "/" );
            hNode.ParentNode = hNode;
            obj.Nodes( end  + 1 ) = hNode;
        end

        function hNode = addReferenceNode( obj, node )





            if isa( node, 'matlabshared.devicetree.node.ReferenceNode' )
                hNode = node;
            else
                hNode = matlabshared.devicetree.node.ReferenceNode( node );
            end

            obj.Nodes( end  + 1 ) = hNode;
        end

        function hNode = addIncludeStatement( obj, fileName, folderName )


            hNode = matlabshared.devicetree.node.IncludeNode( fileName );
            obj.Nodes( end  + 1 ) = hNode;
            if nargin > 2
                obj.IncludeDirectories( end  + 1 ) = folderName;
            end
        end

        function hNode = addNodeDeletion( obj, refName )






            matlabshared.devicetree.util.validateReferenceName( refName );
            hNode = matlabshared.devicetree.node.DeleteNode( refName );
            obj.Nodes( end  + 1 ) = hNode;
        end
    end

    methods ( Hidden )
        function hNode = addEmptyNode( obj )



            hNode = matlabshared.devicetree.node.EmptyNode(  );
            obj.Nodes( end  + 1 ) = hNode;
        end

        function appendDeviceTree( obj, hDeviceTrees )

            for hDT = hDeviceTrees


                obj.Nodes = [ obj.Nodes, hDT.Nodes ];
                obj.Comments = [ obj.Comments, hDT.Comments ];
                obj.IncludeDirectories = [ obj.IncludeDirectories, hDT.IncludeDirectories ];
            end
        end
    end


    methods ( Access = protected )



















































        function printHeader( obj, hDTPrinter, isOverlay, isIncludeFile )

            printHeader@matlabshared.devicetree.util.Commentable( obj, hDTPrinter, isOverlay, isIncludeFile );



            if ~isempty( obj.Comments )
                hDTPrinter.addEmptyLine;
            end






            if ~isIncludeFile
                hDTPrinter.addLine( obj.Header );
            end
            if isOverlay
                hDTPrinter.addLine( obj.OverlayHeader );
            end
            hDTPrinter.addEmptyLine;
        end

        function printBody( obj, hDTPrinter, isOverlay, ~ )







            if isOverlay

                hDTPrinter.addLine( "/ {" );
                hDTPrinter.indent;




                fragmentCount = 0;
                for hNode = obj.Nodes

                    fragmentLine = "fragment@" + num2str( fragmentCount ) + " {";
                    hDTPrinter.addLine( fragmentLine );
                    hDTPrinter.indent;


                    hNode.printObject( hDTPrinter, isOverlay );


                    hDTPrinter.unindent;
                    hDTPrinter.addLine( "};" );


                    hDTPrinter.addEmptyLine;


                    fragmentCount = fragmentCount + 1;
                end


                hDTPrinter.unindent;
                hDTPrinter.addLine( "};" );
            else


                for hNode = obj.Nodes
                    hNode.printObject( hDTPrinter );
                    hDTPrinter.addEmptyLine;
                end
            end
        end
    end


    methods ( Hidden )
        function addIncludeDirectory( obj, includeDirs )
            obj.IncludeDirectories = [ obj.IncludeDirectories, includeDirs ];
        end

        function compile( obj, outputFilePath, varargin )

            [ folderName, fileName ] = fileparts( outputFilePath );
            inputFilePath = fullfile( folderName, fileName + ".input.dts" );
            cleanupFile = onCleanup( @(  )delete( inputFilePath ) );

            obj.printSource( inputFilePath );
            obj.compileDeviceTree( inputFilePath, outputFilePath, "IncludeDirectories", obj.IncludeDirectories, varargin{ : } );
        end
    end

    methods ( Static, Hidden )
        function outputFilePath = compileDeviceTree( inputFilePath, outputFilePath, compileOptions )
            arguments
                inputFilePath string{ matlabshared.devicetree.tree.DeviceTree.validateInputFilePath }
                outputFilePath string = string.empty;
                compileOptions.IncludeDirectories string = string.empty;
                compileOptions.CompilerPath string = matlabshared.devicetree.tree.DeviceTree.DefaultCompilerPath;
                compileOptions.OutputType string{ matlabshared.devicetree.tree.DeviceTree.validateOutputType } = "dtb";
                compileOptions.RemoteShell matlabshared.internal.SystemInterface
                compileOptions.RemoteDirectory string = string.empty;
            end


            includeDirs = compileOptions.IncludeDirectories;
            compilerPath = compileOptions.CompilerPath;
            outputType = compileOptions.OutputType;





            remoteShell = [  ];
            isHostCompiler = true;
            if isfield( compileOptions, 'RemoteShell' )
                remoteShell = compileOptions.RemoteShell;
                isHostCompiler = false;
            end
            remoteDir = compileOptions.RemoteDirectory;


            import matlabshared.devicetree.tree.DeviceTree.*;



            outputFilePath = getOutputFilePath( outputFilePath, inputFilePath, outputType );


            validateCompilerInstallation( compilerPath, remoteShell );



            if ~isHostCompiler && isempty( remoteDir )


                [ status, result ] = runSystemCommand( 'mktemp -d', remoteShell );
                if status
                    error( 'Failed to create temp directory in remote shell due to error:\n%s', result );
                end
                remoteDir = strtrim( result );
                cleanupCommand = sprintf( 'rm -rf %s', remoteDir );
                cleanupDir = onCleanup( @(  )runSystemCommand( cleanupCommand, remoteShell ) );
            end
            [ compilerInputFile, compilerOutputFile, includeDirs ] =  ...
                collectCompilerFiles( inputFilePath, outputFilePath, includeDirs, remoteShell, remoteDir );


            for ii = 1:length( outputType )
                outputFile = compilerOutputFile( ii );
                compileCommand = getCompileCommand( compilerPath, compilerInputFile, outputFile, includeDirs, outputType( ii ) );

                [ status, result ] = runSystemCommand( compileCommand, remoteShell );
                if ( status ~= 0 )
                    error( 'Device tree compilation failed with message:\n%s', result );
                end

                if ~isHostCompiler

                    getFile( remoteShell, char( outputFile ), char( outputFilePath( ii ) ) );
                end
            end
        end
    end

    methods ( Static, Access = protected )
        function command = getCompileCommand( compilerPath, inputFilePath, outputFilePath, includeDirs, outputType )
            if nargin < 5
                outputType = "dtb";
            end
            if nargin < 4
                includeDirs = string.empty;
            end


            templateArgs = "-@ -I dts -O %s -o %s %s";
            compilerArgs = sprintf( templateArgs, outputType, outputFilePath, inputFilePath );

            if ~isempty( includeDirs )
                compilerArgs = compilerArgs + " -i " + join( includeDirs, ", " );
            end


            command = compilerPath + " " + compilerArgs;
        end

        function [ inputFile, outputFile, includeDirs ] = collectCompilerFiles( inputFilePath, outputFilePath, includeDirs, remoteShell, remoteDir )
            if nargin < 4
                remoteShell = [  ];
            end

            import matlabshared.devicetree.tree.DeviceTree.*;



            isHostCompiler = isempty( remoteShell );


            if ~isHostCompiler
                inputFile = copyFilesToRemoteLocation( remoteShell, inputFilePath, includeDirs, remoteDir );
                [ ~, fileName, ext ] = fileparts( outputFilePath );
                outputFile = remoteDir + "/" + fileName + ext;
                includeDirs = string.empty;
            else
                inputFile = inputFilePath;
                outputFile = outputFilePath;
            end
        end

        function remoteInputFile = copyFilesToRemoteLocation( remoteShell, inputFilePath, includeDirs, remoteDir )
            [ ~, fileName, ext ] = fileparts( inputFilePath );
            remoteInputFile = remoteDir + "/" + fileName + ext;


            putFile( remoteShell, char( inputFilePath ), char( remoteInputFile ) );


            for folderName = includeDirs
                filesToCopy = fullfile( folderName, "*.dts*" );
                if isempty( dir( filesToCopy ) )


                    continue ;
                end
                putFile( remoteShell, char( filesToCopy ), char( remoteDir ) );












            end
        end

        function validateCompilerInstallation( compilerPath, remoteShell )
            if nargin < 2
                remoteShell = [  ];
            end

            import matlabshared.devicetree.tree.DeviceTree.*;



            checkCompilerCommand = '"' + compilerPath + '" -v';
            [ status, result ] = runSystemCommand( checkCompilerCommand, remoteShell );
            isValidCompiler = ( status == 0 );

            if ~isValidCompiler
                error( 'Compiler cannot be found at path "%s" with message:\n%s', compilerPath, result );
            end
        end

        function validateInputFilePath( inputFilePath )
            [ ~, ~, ext ] = fileparts( inputFilePath );
            assert( ( ext == ".dts" ) || ( ext == ".dtso" ), 'Input file extension must be ".dts" or ".dtso".' );
        end

        function validateOutputType( outputType )
            mustBeMember( outputType, [ "dtb", "dts" ] );
            if ~( isequal( outputType, "dtb" ) ||  ...
                    isequal( outputType, "dts" ) ||  ...
                    isequal( outputType, [ "dtb", "dts" ] ) ||  ...
                    isequal( outputType, [ "dts", "dtb" ] ) )

                error( 'OutputType must be specified as "dtb", "dts", or ["dtb", "dts"].' );
            end
        end

        function outputFilePath = getOutputFilePath( outputFilePath, inputFilePath, outputType )
            if isempty( outputFilePath )






                [ ~, fileName ] = fileparts( inputFilePath );
                for outType = outputType
                    if outType == "dtb"
                        ext = ".dtb";
                    else
                        ext = ".output.dts";
                    end
                    outputFilePath( end  + 1 ) = fileName + ext;%#ok<AGROW>
                end
            else


                assert( length( outputFilePath ) == length( outputType ), 'OutputFilePath and OutputType must be the same number of values.' );
            end
        end

        function [ status, result ] = runSystemCommand( command, remoteShell )

            if nargin < 2
                remoteShell = [  ];
            end

            if isempty( remoteShell )

                [ status, result ] = system( command );
            else

                try
                    status = 0;
                    result = system( remoteShell, char( command ) );
                catch ME
                    status = 1;
                    result = ME.message;
                end
            end
        end
    end

end
