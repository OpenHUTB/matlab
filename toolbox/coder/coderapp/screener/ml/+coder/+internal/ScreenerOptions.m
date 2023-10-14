classdef ScreenerOptions









    properties



        AnalyzeMathWorksCode( 1, 1 )logical = false





        Target( 1, : )coderapp.internal.screener.Target{ mustBeScalarOrEmpty( Target ) } = coderapp.internal.screener.Target.empty;





        MessageFilters( 1, : )coderapp.internal.screener.ScreenerMessageMatcher = getDefaultScreenerMessageFilter(  );






        UseMetadata( 1, 1 )logical = false;






        UseEMLWhich( 1, 1 )logical = false;
    end

    properties ( Dependent )
        Language
        Environment
        FixedPointConversion
    end

    methods
        function obj = ScreenerOptions( aArgs )





            arguments
                aArgs.?coder.internal.ScreenerOptions
            end
            if isempty( intersect( string( fieldnames( aArgs ) ), [ "Target", "Language", "Environment", "FixedPointConversion" ] ) )
                obj.Target = coderapp.internal.screener.Target;
            end
            validateNameValuePairsInCtor( aArgs );
            for prop = string( fieldnames( aArgs ) )'
                obj.( prop ) = aArgs.( prop );
            end
        end

        function result = get.Language( obj )
            result = obj.getTargetPropertyAsString( "Language" );
        end

        function result = get.Environment( obj )
            result = obj.getTargetPropertyAsString( "Environment" );
        end

        function result = get.FixedPointConversion( obj )
            if isempty( obj.Target )
                result = logical.empty;
            else
                result = obj.Target.FIConversion == coderapp.internal.screener.FIConversion.FI;
            end
        end

        function obj = set.Language( obj, aValue )
            arguments
                obj( 1, 1 )coder.internal.ScreenerOptions
                aValue( 1, 1 )string{ mustBeLanguageString( aValue ) }
            end
            if ~isempty( obj.Target )
                if aValue == "HDL" && obj.Target.Environment == coderapp.internal.screener.Environment.MEX
                    error( message( 'coderApp:screener:ScreenerOptionsMEXHDLConflict' ) );
                end

                if aValue == "GPU" && obj.Target.FIConversion == coderapp.internal.screener.FIConversion.FI
                    error( message( 'coderApp:screener:ScreenerOptionsGPUFIConflict' ) );
                end
            end
            if isempty( obj.Target )
                obj.Target = coderapp.internal.screener.Target;
                if aValue == "HDL"
                    obj.Target.Environment = coderapp.internal.screener.Environment.LIB;
                end
                if aValue == "GPU"
                    obj.Target.FIConversion = coderapp.internal.screener.FIConversion.NOFI;
                end
            end
            obj.Target.Language = coderapp.internal.screener.Language( aValue );
        end

        function obj = set.Environment( obj, aValue )
            arguments
                obj( 1, 1 )coder.internal.ScreenerOptions
                aValue( 1, 1 )string{ mustBeEnvironmentString( aValue ) }
            end
            if ~isempty( obj.Target )
                if aValue == "MEX" && obj.Target.Language == coderapp.internal.screener.Language.HDL
                    error( message( 'coderApp:screener:ScreenerOptionsMEXHDLConflict' ) );
                end
            end
            if isempty( obj.Target )
                obj.Target = coderapp.internal.screener.Target;
            end
            obj.Target.Environment = coderapp.internal.screener.Environment( aValue );
        end

        function obj = set.FixedPointConversion( obj, aValue )
            arguments
                obj( 1, 1 )coder.internal.ScreenerOptions
                aValue( 1, 1 )logical
            end
            if ~isempty( obj.Target )
                if aValue && obj.Target.Language == coderapp.internal.screener.Language.GPU
                    error( message( 'coderApp:screener:ScreenerOptionsGPUFIConflict' ) );
                end
            end
            if aValue
                fiConversion = coderapp.internal.screener.FIConversion.FI;
            else
                fiConversion = coderapp.internal.screener.FIConversion.NOFI;
            end
            if isempty( obj.Target )
                obj.Target = coderapp.internal.screener.Target;
            end
            obj.Target.FIConversion = fiConversion;
        end
    end

    methods ( Access = private )
        function result = getTargetPropertyAsString( obj, aProp )
            if isempty( obj.Target )
                result = string.empty;
            else
                result = string( obj.Target.( aProp ) );
            end
        end
    end
end

function validateNameValuePairsInCtor( aArgs )
validateConflictingNameValuePairs( aArgs, 'Target', 'Language' );
validateConflictingNameValuePairs( aArgs, 'Target', 'Environment' );
validateConflictingNameValuePairs( aArgs, 'Target', 'FixedPointConversion' );
validateMEXHDLConflict( aArgs );
validateGPUFIConflict( aArgs );
end

function validateConflictingNameValuePairs( aArgs, aName1, aName2 )
if isfield( aArgs, aName1 ) && isfield( aArgs, aName2 )
    error( message( 'coderApp:screener:ScreenerOptionsConflictingArguments', aName1, aName2 ) );
end
end

function validateMEXHDLConflict( aArgs )
if isfield( aArgs, 'Environment' ) && isfield( aArgs, 'Language' )
    if aArgs.Environment == "MEX" && aArgs.Language == "HDL"
        error( message( 'coderApp:screener:ScreenerOptionsMEXHDLConflict' ) );
    end
end
end

function validateGPUFIConflict( aArgs )
if isfield( aArgs, 'Language' ) && isfield( aArgs, 'FixedPointConversion' )
    if aArgs.Language == "GPU" && aArgs.FixedPointConversion
        error( message( 'coderApp:screener:ScreenerOptionsGPUFIConflict' ) );
    end
end
end

function mustBeLanguageString( aValue )
mustBeMember( aValue, languageStringValues(  ) );
end

function mustBeEnvironmentString( aValue )
mustBeMember( aValue, environmentStringValues(  ) );
end

function result = languageStringValues
result = string( enumeration( 'coderapp.internal.screener.Language' ) )';
end

function result = environmentStringValues
result = string( enumeration( 'coderapp.internal.screener.Environment' ) )';
end

function matcher = getDefaultScreenerMessageFilter
import coderapp.internal.screener.ScreenerMessageMatcher;
import coderapp.internal.screener.ScreenerMessageType;
import coderapp.internal.screener.MessageSeverity;

matcher = ScreenerMessageMatcher;
matcher.Type = ScreenerMessageType.NON_CODEGEN_MESSAGE;
matcher.Severity = MessageSeverity.WARNING;
end


