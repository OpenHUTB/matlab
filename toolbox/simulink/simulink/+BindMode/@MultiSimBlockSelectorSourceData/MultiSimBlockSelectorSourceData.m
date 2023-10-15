classdef MultiSimBlockSelectorSourceData < BindMode.BindModeSourceData









    properties ( SetAccess = protected, GetAccess = public )
        modelName
        clientName = BindMode.ClientNameEnum.MULTISIMBLOCKSELECTOR
        isGraphical = false
        modelLevelBinding = true
        sourceElementPath
        hierarchicalPathArray = {  }
        sourceElementHandle
        allowMultipleConnections = false
        requiresDropDownMenu = false
    end

    properties
        helpNotificationTimerDuration = 0
    end

    properties ( Access = private )
        DataModel
        BlockElement
    end

    methods
        function obj = MultiSimBlockSelectorSourceData( modelName, dataModel, blockElement )
            obj.modelName = modelName;
            obj.DataModel = dataModel;
            obj.BlockElement = blockElement;
        end

        function bindableData = getBindableData( ~, selectionHandles, ~ )
            arguments
                ~
                selectionHandles double
                ~
            end

            bindableData.updateDiagramButtonRequired = false;
            bindableData.bindableRows = {  };

            for selectionIdx = 1:numel( selectionHandles )
                selectionType = get_param( selectionHandles( selectionIdx ), "Type" );
                if ( ~strcmp( selectionType, "block" ) )
                    continue ;
                end

                params = get_param( selectionHandles( selectionIdx ), "DialogParameters" );
                paramNames = fieldnames( params );
                for paramIdx = 1:numel( paramNames )
                    if strcmp( params.( paramNames{ paramIdx } ).Type, "string" )
                        bindableParamMetaData = BindMode.SLParamMetaData( paramNames{ paramIdx }, getfullname( selectionHandles( selectionIdx ) ) );
                        paramPrompt = strip( params.( paramNames{ paramIdx } ).Prompt, 'right', ':' );
                        bindableName = paramPrompt;
                        bindableParam = BindMode.BindableRow( false, BindMode.BindableTypeEnum.SLPARAMETER, bindableName, bindableParamMetaData );
                        bindableData.bindableRows = [ bindableData.bindableRows, { bindableParam } ];
                    end
                end
            end
        end

        function result = onRadioSelectionChange( obj, ~, ~, ~, bindableMetaData, ~ )
            result = true;
            blockPath = bindableMetaData.blockPathStr;
            blockPath = replace( blockPath, newline, ' ' );

            txn = obj.DataModel.beginTransaction(  );
            obj.BlockElement.BlockPath = blockPath;
            obj.BlockElement.Name = bindableMetaData.name;
            txn.commit(  );
            simulink.multisim.internal.utils.BlockParameter.handlePropertyChange( obj.DataModel, obj.BlockElement );
            modelObj = get_param( obj.modelName, "Object" );
            BindMode.BindMode.disableBindMode( modelObj );
        end
    end
end
