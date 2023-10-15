














































classdef Binder < handle
    properties ( Access = private )
        App
        SimulationHelper
        Bindings
    end

    properties ( Constant, Access = private )
        SimInputVariables = "SimInputVariables";
        StatusMessage = "StatusMessage";

        SupportedBindingKeys = [  ...
            simulink.compiler.internal.AppConfigType.setsNames(  ) ...
            , simulink.compiler.app.Binder.SimInputVariables ...
            , simulink.compiler.app.Binder.StatusMessage ...
            ];
    end

    methods ( Access = { ?simulink.compiler.app.SimulationHelper, ?matlab.mock.classes.BinderMock } )
        function obj = Binder( simulationHelper )










            arguments
                simulationHelper( 1, 1 )simulink.compiler.app.SimulationHelper
            end

            obj.App = simulationHelper.App;
            obj.SimulationHelper = simulationHelper;
            obj.Bindings = containers.Map(  );
        end
    end

    methods
        function bindToModelParameter( obj, component, modelParam, options )




























            arguments
                obj
                component( 1, 1 ){ isComponentOrFcnHandle }
                modelParam
                options.ConvertToString( 1, 1 )matlab.lang.OnOffSwitchState =  ...
                    matlab.lang.OnOffSwitchState.on
            end

            binding.modelParam = modelParam;
            binding.handle = component;
            binding.convertToString = options.ConvertToString;

            obj.addBinding( binding,  ...
                simulink.compiler.internal.AppConfigType.ModelParameter.Sets );
        end

        function bindToVariable( obj, component, variable, options )





























            arguments
                obj
                component( 1, 1 ){ isComponentOrFcnHandle }
                variable
                options.ConvertToString( 1, 1 )matlab.lang.OnOffSwitchState =  ...
                    matlab.lang.OnOffSwitchState.off
                options.Workspace( 1, 1 )string = "global-workspace"
            end

            binding.variable = variable;
            binding.handle = component;
            binding.convertToString = options.ConvertToString;
            binding.workspace = options.Workspace;

            obj.addBinding( binding, obj.SimInputVariables );
        end

        function bindToInitialStateSets( obj, component )





















            arguments
                obj
                component( 1, 1 ){ isComponentOrFcnHandle }
            end

            binding.handle = component;
            obj.addBinding( binding,  ...
                simulink.compiler.internal.AppConfigType.InitialState.Sets );
        end

        function bindToExternalInputSets( obj, component )





















            arguments
                obj
                component( 1, 1 ){ isComponentOrFcnHandle }
            end

            binding.handle = component;
            obj.addBinding( binding,  ...
                simulink.compiler.internal.AppConfigType.ExternalInput.Sets );
        end

        function bindToWorkspaceVariableSets( obj, component )





















            arguments
                obj
                component( 1, 1 ){ isComponentOrFcnHandle }
            end

            binding.handle = component;
            obj.addBinding( binding,  ...
                simulink.compiler.internal.AppConfigType.ReferenceWorkspaceVariable.Sets );
        end

        function bindToAppStatusUpdates( obj, component )

















            arguments
                obj
                component( 1, 1 ){ isComponentOrFcnHandle }
            end

            binding.handle = component;

            obj.addBinding( binding, obj.StatusMessage );
        end
    end

    methods ( Hidden )
        function simIn = applyBindings( obj, simIn )

            bindings = obj.Bindings;


            simIn = obj.applyModelParamBindings( simIn, bindings );


            simIn = obj.applyBindingsToBindable( simIn, bindings,  ...
                simulink.compiler.internal.AppConfigType.InitialState );


            simIn = obj.applyBindingsToBindable( simIn, bindings,  ...
                simulink.compiler.internal.AppConfigType.ExternalInput );


            simIn = obj.applyBindingsToBindable( simIn, bindings,  ...
                simulink.compiler.internal.AppConfigType.ReferenceWorkspaceVariable );


            simIn = obj.applySimInVarBindings( simIn, bindings );
        end

        function component = getBoundComponent( obj, bindable )
            arguments
                obj
                bindable( 1, : ){ isCharStringOrEnum }
            end

            component = [  ];

            key = obj.inferBindingKey( bindable );

            if isempty( key ) || ~obj.Bindings.isKey( key )
                return
            end

            bindings = obj.Bindings( key );

            if isempty( bindings )
                return
            end

            assert( length( bindings ) == 1,  ...
                "getBoundComponent() does not support multiple bindings." );

            handle = bindings( 1 ).data.handle;

            if ~isa( handle, "function_handle" )
                component = handle;
            end
        end

        function bindings = getBindings( obj )









































            bindings = obj.Bindings;
        end
    end

    methods ( Access = private )
        function addBinding( obj, binding, bindingKey )
            arguments
                obj
                binding
                bindingKey( 1, : ){ mustBeScalarText }
            end

            supportedKey = find( strcmp( obj.SupportedBindingKeys, bindingKey ) );

            if ~supportedKey
                error( "Invalid binding key provided. Supported keys are:\r\n" +  ...
                    join( obj.SupportedBindingKeys ), "\r\n" );
            end

            if ~obj.Bindings.isKey( bindingKey )
                obj.Bindings( bindingKey ) = struct( "data", binding );
            else
                bindings = obj.Bindings( bindingKey );
                bindings( end  + 1 ).data = binding;
                obj.Bindings( bindingKey ) = bindings;
            end
        end

        function binding = getBinding( component )
            binding = struct(  );

            bindings = obj.Bindings;

            for bdg = bindings
                if isequal( bdg.handle, component )
                    binding = bdg;
                    return
                end
            end
        end

        function simIn = applyModelParamBindings( obj, simIn, bindings )
            if ~bindings.isKey( "ModelParameterSets" )
                return
            end

            modelParamBindings = bindings( "ModelParameterSets" );

            for binding = modelParamBindings
                bindingData = binding.data;
                paramValue = obj.boundValue( bindingData );
                if obj.numericEquivalentIsInfinite( paramValue )
                    continue
                end
                simIn = simIn.setModelParameter( bindingData.modelParam, paramValue );
            end
        end

        function simIn = applySimInVarBindings( obj, simIn, bindings )
            if ~bindings.isKey( "SimInputVariables" )
                return
            end

            simInVarBindings = bindings( "SimInputVariables" );

            for binding = simInVarBindings
                bindingData = binding.data;
                workspace = bindingData.workspace;

                varValue = obj.boundValue( bindingData );
                if obj.numericEquivalentIsInfinite( varValue )
                    continue
                end

                simIn = simIn.setVariable( bindingData.variable,  ...
                    varValue, 'Workspace', workspace );
            end
        end

        function checkPassed = numericEquivalentIsInfinite( ~, value )
            import matlab.internal.datatypes.isScalarText;

            if isScalarText( value )
                value = str2double( value );
            end
            checkPassed = ~isfinite( value );
        end

        function simIn = applyBindingsToBindable( obj, simIn, bindings, bindable )
            bindableSets = bindable.Sets;

            bindingsExist = bindings.isKey( bindableSets );
            bindableExists = ~isempty( obj.SimulationHelper.Workspace.( bindableSets ) );

            if bindingsExist && bindableExists
                [ ~, setName ] = obj.SimulationHelper.UserInterface.getSelectedSet( bindable );
                simIn.( bindable.SimInputName ) =  ...
                    obj.SimulationHelper.Workspace.( bindableSets ).( setName );
            end
        end

        function value = boundValue( ~, binding )
            handle = binding.handle;

            if isa( handle, 'function_handle' )
                value = handle(  );
            else
                value = handle.Value;
            end

            if isfield( binding, 'convertToString' ) &&  ...
                    strcmp( binding.convertToString, 'on' )
                value = num2str( value );
            end
        end

        function bindingKey = inferBindingKey( obj, bindable )
            import simulink.compiler.internal.util.transformBindableToConfigType;

            origBindable = bindable;
            bindable = transformBindableToConfigType( bindable );

            if isempty( bindable )
                bindingKeys = obj.Bindings.keys(  );
                bitMap = strcmp( bindingKeys, origBindable );
                bindingKey = [  ];

                if any( bitMap )
                    bindingKey = origBindable;
                end

                return
            end

            bindingKey = bindable.Sets;

            if isempty( bindingKey )
                bindingKey = bindable.Name;
            end
        end
    end
end

function valid = isComponentOrFcnHandle( toValidate )
valid =  ...
    isa( toValidate, "function_handle" ) ||  ...
    isa( toValidate, "matlab.ui.control.internal.model.AbstractComponent" );

if ~valid
    error( message( "simulinkcompiler:genapp:NotComponentOrFcnHandle" ) );
end
end

function valid = mustBeScalarText( toValidate )
import matlab.internal.datatypes.isScalarText;
valid = isScalarText( toValidate );

if ~valid

    error( "Invalid argument. Argument must be a char array or string." );
end
end

function valid = isCharStringOrEnum( toValidate )
import matlab.internal.datatypes.isScalarText;

valid = isScalarText( toValidate ) ||  ...
    isa( toValidate, "simulink.compiler.internal.AppConfigType" );

if ~valid
    error( message( "simulinkcompiler:genapp:MustBeCharStringOrEnum", toValidate ) );
end
end


