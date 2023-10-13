classdef ( Sealed )RegisterCGIRInspectorResults < Advisor.BaseRegisterCGIRInspectorResults & matlab.mixin.Copyable

    methods ( Static = true )
        function singleObj = getInstance( allowCreate )
            arguments
                allowCreate( 1, 1 )logical = false
            end

            persistent localStaticObj;
            if ~isempty( localStaticObj ) && ~isvalid( localStaticObj )
                localStaticObj = [  ];
            end
            if allowCreate && isempty( localStaticObj )
                localStaticObj = coder.report.RegisterCGIRInspectorResults;
            end
            singleObj = localStaticObj;
        end

        function clearResults(  )
            instance = coder.report.RegisterCGIRInspectorResults.getInstance(  );
            if ~isempty( instance ) && isvalid( instance )
                clearResults@Advisor.BaseRegisterCGIRInspectorResults( instance );
            end
        end
    end

    methods ( Static, Hidden )
        function addTagsResultsWrapper( varargin )
            narginchk( 2, Inf );
            instance = coder.report.RegisterCGIRInspectorResults.getInstance( true );
            instance.addTagsResults( varargin{ 1 }{ 1 }, varargin{ 2:end  } );
        end
    end

    methods
        function parsedResults = getParsedResults( this, key )
            arguments
                this( 1, 1 )
                key( 1, : )char
            end

            parsedResults = this.parseCGIRResults( key );
            if isempty( parsedResults )
                parsedResults = {  };
            else
                parsedResults = parsedResults.tag;
            end
        end
    end

    methods ( Access = protected )
        function copy = copyElement( obj )
            copy = copyElement@matlab.mixin.Copyable( obj );
            if ~isempty( obj.resultMap )
                copy.resultMap = containers.Map( obj.resultMap.keys(  ), obj.resultMap.values(  ) );
            else
                copy.resultMap = containers.Map(  );
            end
        end
    end

    methods ( Static, Hidden )








        function [ script, fcnId, pos ] = parseSID( sid )


            colPos = strfind( sid, ':' );
            lastColPos = colPos( end  );
            script = sid( 1:( lastColPos - 1 ) );
            data = sid( ( lastColPos + 1 ):end  );
            fields = strsplit( data, ',' );

            if length( fields ) > 1
                fcnId = fields{ 2 };
                fcnId = str2double( fcnId( 2:end  ) );
            else
                fcnId =  - 1;
            end
            pos = fields{ 1 };
        end


        function [ scriptPath, scriptName, textStart, textEnd, fcnId ] = parseRecordSID( record )
            scriptPath = '';
            scriptName = '';
            textStart = 0;
            textEnd = 0;
            if ~isfield( record, 'sid' ) || isempty( record.sid )
                return
            end
            [ script, fcnId, pos ] = coder.report.RegisterCGIRInspectorResults.parseSID( record.sid );
            [ scriptPath, scriptName, extension ] = coder.report.RegisterCGIRInspectorResults.getScriptPathAndName( script );

            if strcmp( extension, '.m' )
                [ textStart, textEnd ] = coder.report.RegisterCGIRInspectorResults.getTextStartAndEnd( pos );
            end
        end
    end


    methods ( Static, Access = private )

        function [ scriptPath, scriptName, extension ] = getScriptPathAndName( script )
            [ scriptPath, scriptName, extension ] = fileparts( script );
        end


        function [ textStart, textEnd ] = getTextStartAndEnd( pos )
            splitPos = strsplit( pos, '-' );
            textStart = str2double( splitPos{ 1 } );
            textEnd = str2double( splitPos{ 2 } );
        end
    end
end

