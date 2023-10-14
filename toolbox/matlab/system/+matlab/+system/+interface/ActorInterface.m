classdef ActorInterface < matlab.system.interface.ElementBase

    properties ( Access = public )
    end

    properties ( Access = private, Hidden = true )
        UserDefinedActions
    end

    methods
        function obj = ActorInterface( varargin )

            name = "default";
            obj = obj@matlab.system.interface.ElementBase( name );
            obj.UserDefinedActions = containers.Map;
        end

        function addAction( obj, actionType, action )
            arguments
                obj
                actionType
                action( 1, 1 )matlab.system.interface.ActorAction
            end


            if isKey( obj.UserDefinedActions, action.Name )
                error( 'The action name already exists.' );
            end

            switch actionType
                case 'UserDefinedAction'
                    obj.UserDefinedActions( action.Name ) = action;
            end
        end

        function actions = getActions( obj, actionType )
            switch actionType
                case 'UserDefinedAction'
                    actions = values( obj.UserDefinedActions );
            end
        end
    end

    methods ( Access = protected )
        function processInputArguments( obj, configs )
        end
    end
end

