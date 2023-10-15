classdef RulesFile < handle











    properties ( Access = 'public' )
        mFileName;
    end

    properties ( Access = 'private' )
        mReader;
        mWriter;
        mTempFile;
    end

    methods ( Access = 'public' )
        function obj = RulesFile( filename )
            obj.mFileName = filename;
        end

        function delete( obj )
            if ~isempty( obj.mWriter )
                obj.discardWriter;
            end
        end



        function openReader( obj )
            obj.mReader = Simulink.loadsave.SLXPackageReader( obj.mFileName );
        end


        function closeReader( obj )
            if ~isempty( obj.mReader )
                obj.mReader.close
                obj.mReader = [  ];
            end
        end






        function ruleset = getRules( obj, ver )
            ver = saveas_version( ver );
            if isempty( obj.mReader )
                if obj.fileExists
                    obj.openReader;
                else
                    ruleset = [  ];
                    return ;
                end
            end
            partname = slexportprevious.RulesFile.getRulesPartName( ver );
            if obj.mReader.hasPart( partname )
                rules = obj.mReader.readPartToString( partname, 'UTF-8' );
                if ~isempty( rules )
                    rules = textscan( rules, '%s', 'delimiter', newline );
                    rules = rules{ 1 };
                else
                    rules = {  };
                end
            else
                rules = {  };
            end
            ruleset = slexportprevious.RuleSet( rules );
        end

        function deleteFile( obj )
            if obj.fileExists
                fileattrib( obj.mFileName, '+w' );
                delete( obj.mFileName );
            end
        end

        function changed = generate( obj, location, verbose )
            arguments
                obj;
                location;
                verbose( 1, 1 )logical = false;
            end

            restore_folder = [  ];
            funcname = slexportprevious.internal.CallbackDispatcher.getPostprocessFunctionNames( location );
            if verbose
                fprintf( 'Found %d functions to execute:\n', numel( funcname ) );
                fprintf( '   %s\n', funcname{ : } );
            end

            if verbose
                fprintf( 'Generating %s\n', obj.mFileName );
            end

            obj.openWriter;

            versions = saveas_version.getVersionStrings;

            changed = false;
            for i = 1:numel( versions )
                data = slexportprevious.RuleSet;
                for k = 1:numel( funcname )
                    if verbose
                        fprintf( '  Executing: %s\n', funcname{ k } );
                    end
                    funcdata = feval( funcname{ k }, saveas_version( versions{ i } ) );
                    if ~isa( funcdata, 'slexportprevious.RuleSet' )
                        edit( funcname{ k } );
                        error( 'slexportprevious:Generate:ReturnTypeError',  ...
                            [ funcname{ k }, ' did not return slexportprevious.RuleSet' ] );
                    end
                    funcdata.validateRules( false );
                    data.appendSet( funcdata );
                end
                changed = obj.writeRuleSet( data, saveas_version( versions{ i } ), verbose ) || changed;
            end

            delete( restore_folder );

            if changed
                if verbose
                    fprintf( 'Writing %s\n', obj.mFileName );
                end
                obj.commitWriter;
            else
                if verbose
                    fprintf( 'No changes made to %s\n', obj.mFileName );
                end
                obj.discardWriter;
            end

        end
    end

    methods ( Access = 'private' )




        function openWriter( obj )
            srcfile = '';
            if obj.fileExists
                srcfile = obj.mFileName;
                obj.openReader;
            end
            obj.mTempFile = [ tempname, '.rules' ];
            obj.mWriter = Simulink.loadsave.SLXPackageWriter( obj.mTempFile, srcfile );
        end


        function discardWriter( obj )
            if ~isempty( obj.mWriter )
                obj.mWriter.close;
                obj.mWriter = [  ];
                if ~isempty( obj.mTempFile ) && exist( obj.mTempFile, 'file' )
                    delete( obj.mTempFile );
                end
                obj.mTempFile = [  ];
            end
        end


        function commitWriter( obj )
            obj.mWriter.close;
            obj.mWriter = [  ];
            obj.mReader = [  ];
            assert( exist( obj.mTempFile, 'file' ) ~= 0 );
            movefile( obj.mTempFile, obj.mFileName, 'f' );
        end




        function changed = writeRuleSet( obj, ruleset, ver, verbose )

            assert( ~isempty( obj.mWriter ) );

            changed = false;
            reader = obj.mReader;


            allrules = sprintf( '%s\n', ruleset.mRules{ : } );

            partname = slexportprevious.RulesFile.getRulesPartName( ver );
            rewrite = true;
            if ~isempty( reader )
                if reader.hasPart( partname )
                    existingrules = reader.readPartToString( partname, 'UTF-8' );
                    if strcmp( allrules, existingrules )
                        if verbose
                            fprintf( 'New and old content identical: %s\n', partname );
                        end
                        rewrite = false;
                    elseif verbose
                        slexportprevious.RulesFile.displayDiff( existingrules, allrules );
                    end
                end
            end
            if rewrite
                if verbose
                    fprintf( 'Updating: %s\n', partname );
                end


                try
                    Simulink.loadsave.ExportRuleProcessor.validateRule( allrules )
                catch


                    for i = 1:numel( ruleset.mRules )
                        Simulink.loadsave.ExportRuleProcessor.validateRule( ruleset.mRules{ i } );
                    end
                    assert( false, 'Unreachable if rule validation is working properly' );
                end

                [ ~, id ] = fileparts( partname );
                part = Simulink.loadsave.SLXPartDefinition( partname, '', 'text/plain',  ...
                    'http://www.mathworks.com/simulink/exportRules',  ...
                    [ 'rules_', id ] );
                obj.mWriter.writePartFromString( part, allrules, 'UTF-8' );
                changed = true;
            end

        end

        function e = fileExists( obj )


            e = ~isempty( dir( obj.mFileName ) );
        end

    end

    methods ( Access = 'public', Static )

        function partname = getRulesPartName( ver )
            assert( isa( ver, 'saveas_version' ) );
            partname = [ '/rules_', ver.label( 8:end  ), '.txt' ];
        end

        function displayDiff( oldtxt, newtxt )
            t = tempname;
            oldfile = [ t, '_old.txt' ];
            f = fopen( oldfile, 'w' );
            fprintf( f, '%s\n', oldtxt );
            fclose( f );
            delete_oldfile = onCleanup( @(  )delete( oldfile ) );
            newfile = [ t, '_new.txt' ];
            f = fopen( newfile, 'w' );
            fprintf( f, '%s\n', newtxt );
            fclose( f );
            delete_newfile = onCleanup( @(  )delete( newfile ) );
            system( [ 'diff ', oldfile, ' ', newfile ] );
        end

        function obj = forFolder( folder )
            obj = slexportprevious.RulesFile(  ...
                fullfile( folder, 'slexportprevious.rules' ) );
        end

    end

end

