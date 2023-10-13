classdef WDFNotification < classdiagram.app.core.notifications.notifications.AbstractNotification


    properties ( SetAccess = private )
        Modality;
        HelpMapPath;
    end

    methods

        function obj = WDFNotification( diagnostics, optional )
            arguments
                diagnostics{ mustBeMessageOrExceptionOrMessageId( diagnostics ) };
                optional.messageFills( 1, : ){  ...
                    mustFillMessage( diagnostics, optional.messageFills ) };

                optional.Severity( 1, 1 )classdiagram.app.core.notifications.Severity ...
                    = classdiagram.app.core.notifications.Severity.Info;

                optional.Target( 1, 1 ){ mustBeTargetStruct( optional.Target ) };
                optional.Modality( 1, 1 )classdiagram.app.core.notifications.Modality ...
                    = classdiagram.app.core.notifications.Modality.MODELESS;
                optional.Transient( 1, 1 )logical = true;
                optional.OutputMode( 1, 2 )matlab.lang.OnOffSwitchState ...
                    { mustNotBeBothFalse( optional.OutputMode ) };
                optional.HelpMapPath( 1, 1 )string;
                optional.HelpTopicId( 1, 1 )string;
            end

            optional.diagnostics = diagnostics;
            obj = obj@classdiagram.app.core.notifications.notifications.AbstractNotification( optional );
            obj.Severity = optional.Severity;
            obj.Modality = optional.Modality;
            obj.Transient = optional.Transient;
            if isfield( optional, "Target" )
                obj.Target = optional.Target;
            else
                obj.Target = struct( "Diagram", classdiagram.app.core.notifications.Target.Diagram );
            end
            if isfield( optional, "OutputMode" )
                obj.UIMode = optional.OutputMode( 1 );
                obj.CommandLineMode = optional.OutputMode( 2 );
            end
            if isfield( optional, 'HelpMapPath' ) && isfield( optional, 'HelpTopicId' )
                obj.HelpMapPath = optional.HelpMapPath;
            end
        end

        function createDiagnostic( obj, optional )
            if isa( optional.diagnostics, "MException" ) || isa( optional.diagnostics, "message" )
                obj.Message = optional.diagnostics;
            else
                if isfield( optional, "messageFills" ) && ~isempty( optional.messageFills )
                    fills = optional.messageFills;
                    obj.Message = classdiagram.app.core.notifications.notifications.makeMessage(  ...
                        optional.diagnostics, fills );
                else
                    obj.Message = classdiagram.app.core.notifications.notifications.makeMessage(  ...
                        optional.diagnostics );
                end
                try
                    obj.Message.getString;
                catch me
                    throwAsCaller( me );
                end
            end
        end

        function [ map_path, topic_id ] = getCSH( obj )
            map_path = obj.HelpMapPath;
            topic_id = obj.HelpTopicId;
        end
    end
end


function mustBeMessageOrExceptionOrMessageId( args )
if isa( args, "MException" ) || isa( args, "message" )
    return ;
elseif isa( args, "string" ) || isa( args, 'char' )
    try

        msg = message( args );
        return ;
    catch me
        throwAsCaller( me );
        return ;
    end
end
eidType = 'diagram_editor_registry:General:MustBeMessageExceptionOrMessageId';
msgType = message( eidType );
throwAsCaller( MException( eidType, msgType ) );
end

function mustFillMessage( msg, args )
if isa( msg, "message" ) || isa( msg, "MException" )
    return ;
elseif ~iscell( args ) && ~isa( args, "string" ) && ~isa( args, 'char' )
    eidType = 'diagram_editor_registry:General:MustFillMessageCorrectly';
    msgType = message( eidType );
    throwAsCaller( MException( eidType, msgType ) );
end
try
    if iscell( args )
        msgObj = classdiagram.app.core.notifications.notifications.makeMessage( msg, args{ : } );
    else
        msgObj = classdiagram.app.core.notifications.notifications.makeMessage( msg, args );
    end
    msgObj.getString;
catch me
    throwAsCaller( me );
end
end

function mustNotBeBothFalse( modes )
if ~( modes( 1 ) || modes( 2 ) )
    eidType = 'diagram_editor_registry:General:MustSetOutputMode';
    msgType = message( eidType );
    throwAsCaller( MException( eidType, msgType ) );
end
end

function mustBeTargetStruct( args )
if isempty( args )
    return ;
end
if isfield( args, 'uuid' ) && isempty( args.uuid ) ...
        && isfield( args, 'widgetId' ) && isempty( args.widgetId ) ...
        && isfield( args, 'Diagram' ) && isempty( args.Diagram )
    eidType = 'diagram_editor_registry:General:MustSetNotificationTarget';
    msgType = message( eidType );
    throwAsCaller( MException( eidType, msgType ) );
end
end


