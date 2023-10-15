classdef ( Sealed, Hidden )ScreenerInfo < handle & matlab.mixin.CustomDisplay & coder.internal.NamedDialogMixin

    properties ( SetAccess = private )
        Files( :, 1 )coder.File = coder.File.empty(  )
        Messages( :, 1 )coder.Message = coder.Message.empty(  )
        UnsupportedCalls( :, 1 )coder.CallSite = coder.CallSite.empty(  )
    end

    properties ( Hidden, Transient, SetAccess = private )

        ScreenerModel coderapp.internal.screener.ScreenerResultView{ mustBeScalarOrEmpty( ScreenerModel ) } =  ...
            coderapp.internal.screener.ScreenerResultView.empty

        MF0Model = [  ]

        UIHandle coderapp.internal.screener.ui.Screener{ mustBeScalarOrEmpty( UIHandle ) } =  ...
            coderapp.internal.screener.ui.Screener.empty
    end


    properties ( Access = private )

        FilePathToReportedPath containers.Map %#ok<MCHDT>


        ReportedPathToFilePath containers.Map %#ok<MCHDT>
    end

    methods
        function outputReport = textReport( this )
            if this.hasValidScreenerModel
                outputReport = coderapp.internal.screener.screenerTextReport( this.ScreenerModel );
            else
                error( message( "coderApp:screener:InvalidScreenerModelReport" ) );
            end
        end
    end

    methods ( Hidden, Access = { ?codergui.internal.ScreenerInfoBuilder } )




        function this = ScreenerInfo( aScreenerModel, aOptions )
            arguments
                aScreenerModel coderapp.internal.screener.ScreenerResultView{ mustBeScalarOrEmpty( aScreenerModel ) }
                aOptions.Model( 1, 1 )mf.zero.Model
                aOptions.PathMap containers.Map = containers.Map( 'KeyType', 'char', 'ValueType', 'char' )
                aOptions.UIHandle( 1, : )coderapp.internal.screener.ui.Screener = coderapp.internal.screener.ui.Screener.empty;
            end

            this.initializePathMaps( aOptions.PathMap );
            this.constructFromMF0Model( aScreenerModel, aOptions.Model );
            this.UIHandle = aOptions.UIHandle;
        end
    end

    methods ( Hidden, Access = public )


        function problems = getProblemsByImpact( this )
            problems = arrayfun( @( message )string( message.Type ), this.ScreenerModel.Messages.toArray(  ) )';
            if isempty( problems )
                problems = string.empty;
            end
        end
    end


    methods ( Hidden, Access = private )
        function initializePathMaps( this, pathMap )
            this.FilePathToReportedPath = pathMap;
            if ~isempty( this.FilePathToReportedPath ) > 0
                this.ReportedPathToFilePath = containers.Map( this.FilePathToReportedPath.values(  ), this.FilePathToReportedPath.keys(  ) );
            end
        end

        function p = getReportedPathFromFilePath( this, filepath )
            if this.FilePathToReportedPath.isKey( filepath )

                p = this.FilePathToReportedPath( filepath );
            else
                p = filepath;
            end
        end

        function p = getFilePathFromReportedPath( this, filepath )
            if this.ReportedPathToFilePath.isKey( filepath )

                p = this.ReportedPathToFilePath( filepath );
            else
                p = filepath;
            end
        end

        function file = lookupFileFromPath( this, path )
            remappedPath = this.getReportedPathFromFilePath( path );
            file = this.Files( string( { this.Files.Path } ) == remappedPath );
        end

        function file = lookupFileFromFunction( this, fcn )
            file = this.lookupFileFromPath( fcn.Path );
        end

        function file = lookupFileFromCallSite( this, callSite )
            file = this.lookupFileFromPath( callSite.Caller.Path );
        end
    end


    methods ( Hidden, Access = private )
        function constructFromMF0Model( this, screenerResultView, mf0Model )
            this.ScreenerModel = screenerResultView;
            this.MF0Model = mf0Model;
            this.accumulateFiles;
            this.accumulateMessages;
            this.accumulateUnsupportedCallSites;
        end

        function accumulateFiles( this )
            for fcn = this.ScreenerModel.Result.Functions.toArray
                if fcn.IsMathWorksAuthored && ~this.ScreenerModel.Result.Input.Options.TraverseMathWorksCode
                    continue ;
                end
                [ ~, ~, ext ] = fileparts( fcn.Path );
                remappedPath = this.getReportedPathFromFilePath( fcn.Path );
                if ~fcn.IsAnalyzed
                    this.Files( end  + 1 ) = coder.File( remappedPath, ext, fcn.IsMathWorksAuthored );
                else
                    text = this.ScreenerModel.Files{ fcn.Path }.Contents;
                    this.Files( end  + 1 ) = coder.CodeFile( text, remappedPath, ext, fcn.IsMathWorksAuthored );
                end
            end
        end

        function accumulateMessages( this )

            msgs = this.ScreenerModel.Messages.toArray;
            if isempty( msgs )
                this.Messages = coder.Message.empty;
                return ;
            end
            numMessages = numel( msgs );
            messages( numMessages ) = coder.Message;

            ids = [ msgs.MessageID ];
            idStrs = append( { ids.CatalogName }, ':', { ids.MessageKey } );
            files = this.getFiles( msgs );
            categoryStrs = cellstr( string( [ msgs.Type ] ) );

            locs = [ msgs.Location ];
            starts = [ locs.Start ];
            ends = [ locs.End ];

            uuids = string( { msgs.UUID } );
            fullMessages = this.ScreenerModel.FullMessages;
            warningString = string( coderapp.internal.screener.MessageSeverity.WARNING );
            texts = cell( 1, numMessages );
            sevStrs = cell( 1, numMessages );
            sevs = string( [ msgs.Severity ] );
            for idx = 1:numMessages
                texts{ idx } = fullMessages{ uuids( idx ) }.Text;
                sevStrs{ idx } = toSeverityString( sevs( idx ), warningString );
            end

            [ messages.Identifier ] = idStrs{ : };
            [ messages.Type ] = sevStrs{ : };
            [ messages.Text ] = texts{ : };
            [ messages.File ] = files{ : };
            [ messages.Category ] = categoryStrs{ : };
            [ messages.SubCategory ] = deal( [  ] );
            [ messages.StartIndex ] = starts.Offset;
            [ messages.EndIndex ] = ends.Offset;
            [ messages.StartLine ] = starts.Line;
            [ messages.EndLine ] = ends.Line;
            [ messages.StartColumn ] = starts.Column;
            [ messages.EndColumn ] = ends.Column;

            this.Messages = messages;
        end

        function files = getFiles( this, aMsgs )
            paths = cell( 1, numel( aMsgs ) );
            for idx = 1:numel( aMsgs )
                paths{ idx } = getPathFromMessage( aMsgs( idx ) );
            end
            if ~isempty( this.FilePathToReportedPath )
                for idx = 1:numel( aMsgs )
                    paths{ idx } = this.lookupFileFromPath( paths{ idx } );
                end
            end
            files = cell( 1, numel( aMsgs ) );
            for idx = 1:numel( aMsgs )
                files{ idx } = this.Files( string( { this.Files.Path } ) == paths{ idx } );
            end
        end

        function accumulateUnsupportedCallSites( this )
            calls = this.ScreenerModel.UnsupportedCallSites.toArray;
            if isempty( calls )
                this.UnsupportedCalls = coder.CallSite.empty;
                return ;
            end
            numCalls = numel( calls );
            locs = [ calls.Location ];
            starts = [ locs.Start ];
            ends = [ locs.End ];
            symbols = { calls.Symbol };
            files = cell( 1, numCalls );
            for idx = 1:numCalls
                files{ idx } = this.lookupFileFromCallSite( calls( idx ) );
            end
            unsupportedCalls( numCalls ) = coder.CallSite;
            [ unsupportedCalls.CalleeName ] = symbols{ : };
            [ unsupportedCalls.File ] = files{ : };
            [ unsupportedCalls.StartIndex ] = starts.Offset;
            [ unsupportedCalls.EndIndex ] = ends.Offset;
            [ unsupportedCalls.StartLine ] = starts.Line;
            [ unsupportedCalls.EndLine ] = ends.Line;
            [ unsupportedCalls.StartColumn ] = starts.Column;
            [ unsupportedCalls.EndColumn ] = ends.Column;
            this.UnsupportedCalls = unsupportedCalls;
        end
    end

    methods ( Hidden )
        function open( obj )



            obj.dialog( '' );
        end

        function dialog( obj, ~ )







            if obj.hasValidScreenerModel
                obj.openOrRefocusUI(  );
            else
                warning( message( 'coderApp:screener:InvalidScreenerModel' ) );
            end
        end
    end

    methods ( Access = protected, Sealed, Hidden )
        function text = getFooter( obj )






            inputName = inputname( 1 );
            if isscalar( obj ) && isvalid( obj ) && obj.hasValidScreenerModel && ~isempty( inputName )
                if feature( 'hotlinks' )
                    text = [ '    ', message( 'coderApp:screener:ScreenerInfoOpenLink', inputName ).getString, newline ];
                else
                    text = [ '  ', message( 'coderApp:screener:ScreenerInfoOpenMessage', inputName ).getString, newline ];
                end
            else
                text = '';
            end
        end
    end

    methods ( Hidden, Access = private )
        function openOrRefocusUI( obj )
            if obj.isBoundToExistingUI
                obj.UIHandle.show(  );
            else

                obj.UIHandle = coderapp.internal.screener.ui.Screener( obj.ScreenerModel );
            end
        end


        function bool = isBoundToExistingUI( obj )
            bool = ~isempty( obj.UIHandle ) && isvalid( obj.UIHandle ) && strcmp( obj.UIHandle.getScreenerResultUUID, obj.ScreenerModel.UUID );
        end

        function bool = hasValidScreenerModel( obj )




            bool = isscalar( obj.ScreenerModel ) &&  ...
                ( isa( obj.ScreenerModel, 'coderapp.internal.screener.ScreenerResultView' ) ||  ...
                isa( obj.ScreenerModel, 'com.mathworks.toolbox.coder.screener.ScreenerReportModel' ) );
        end
    end
end

function result = toSeverityString( aSeverity, aWarningString )
if aSeverity == aWarningString
    result = 'Warn';
else
    result = 'Error';
end
end

function result = getPathFromMessage( aMessage )
if isa( aMessage, 'coderapp.internal.screener.FunctionMessage' )
    result = aMessage.Function.Path;
else
    result = aMessage.CallSite.Caller.Path;
end
end
