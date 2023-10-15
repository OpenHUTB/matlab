function pu = addParameter( this, name, options )

arguments
    this{ musBeAValidArchitecture }
    name{ mustBeTextScalar } = ""
    options.Type{ mustBeTextScalar } = "double"
    options.Value{ mustBeTextScalar } = ""
    options.Units{ mustBeTextScalar } = ""
    options.Complexity{ mustBeMember( options.Complexity, { 'real', 'complex' } ) } = "real"
    options.Dimensions{ mustBeTextScalar } = "[1 1]"
    options.Minimum{ mustBeTextScalar } = ""
    options.Maximum{ mustBeTextScalar } = ""
    options.Description{ mustBeTextScalar } = ""
    options.Promote{ mustBeA( options.Promote, 'systemcomposer.arch.Parameter' ) } = systemcomposer.arch.Parameter.empty
    options.Path{ mustBeTextScalar } = ""
    options.Parameters{ mustBeText } = "all"
end

name = string( name );
options.Value = string( options.Value );
options.Minimum = string( options.Minimum );
options.Maximum = string( options.Maximum );
options.Units = string( options.Units );

pu = systemcomposer.arch.Parameter.empty;
pUsgImpl = systemcomposer.internal.parameter.ParameterUsage.empty;

if ~isempty( options.Promote ) && options.Promote.isValid

    fullPath = options.Promote.Context;
    paramName = options.Promote.Name;
    existingParams = this.getParameterNames;
    this.exposeParameter( 'Path', fullPath, 'Parameters', paramName );
    currentParams = this.getParameterNames;
    newParams = setdiff( currentParams, existingParams );
    for i = 1:numel( newParams )
        pu( i ) = systemcomposer.arch.Parameter.wrapper( this, newParams( i ) );
    end
elseif ~matches( options.Path, "" )

    existingParams = this.getParameterNames;
    this.exposeParameter( 'Path', options.Path, 'Parameters', options.Parameters );
    currentParams = this.getParameterNames;
    newParams = setdiff( currentParams, existingParams );
    for i = 1:numel( newParams )
        pu( i ) = systemcomposer.arch.Parameter.wrapper( this, newParams( i ) );
    end
else
    if isempty( name ) || matches( name, "" )
        error( 'SystemArchitecture:Parameter:EmptyParameterName', message( 'SystemArchitecture:Parameter:EmptyParameterName' ).getString );
    end


    if ~isempty( this.Parent )

        masked = get_param( this.SimulinkHandle, 'Mask' );
        if strcmp( masked, 'off' )
            set_param( this.SimulinkHandle, 'Mask', 'on' );
        end
        mask = get_param( this.SimulinkHandle, 'MaskObject' );
        mask.IconOpaque = 'transparent';
        maskPrm = mask.getParameter( name );
        if isempty( maskPrm )
            if options.Value.matches( "" )
                val = '[]';
            else
                val = options.Value;
            end
            maskPrm = Simulink.MaskParameter.createStandalone( 1 );
            maskPrm.Name = name;
            maskPrm.Value = val;
            maskPrm.DefaultValue = options.Value;
            maskPrm.DataType = options.Type;
            maskPrm.Dimensions = options.Dimensions;
            maskPrm.Complexity = options.Complexity;
            maskPrm.Min = options.Minimum;
            maskPrm.Max = options.Maximum;
            maskPrm.Description = options.Description;
            aUnit = Simulink.Mask.Unit;
            aUnit.BaseUnit = options.Units;
            maskPrm.Unit = aUnit;
            try

                mask.addParameter( maskPrm );
            catch e


                if ~isempty( mask.getParameter( name ) )
                    mask.removeParameter( name );
                end
                throw( e );
            end
            pUsgImpl = this.ElementImpl.getParameter( name );
        else
            error( 'SystemArchitecture:Parameter:NonUniqueParameterName', message( 'SystemArchitecture:Parameter:NonUniqueParameterName', name, this.Name ).getString );
        end
    else
        mWksp = get_param( this.Name, 'ModelWorkspace' );
        if ~isempty( mWksp )
            if ~mWksp.hasVariable( name )
                paramObj = Simulink.Parameter;
                if options.Value.matches( "" )
                    val = [  ];
                else
                    val = eval( options.Value );
                end
                if options.Minimum.matches( "" )
                    minVal = [  ];
                else
                    minVal = eval( options.Minimum );
                end
                if options.Maximum.matches( "" )
                    maxVal = [  ];
                else
                    maxVal = eval( options.Maximum );
                end
                paramObj.DataType = options.Type;
                paramObj.Value = val;
                paramObj.Unit = options.Units;
                paramObj.Min = minVal;
                paramObj.Max = maxVal;
                paramObj.Complexity = options.Complexity;
                paramObj.Dimensions = eval( options.Dimensions );
                paramObj.Description = options.Description;
                mWksp.assignin( name, paramObj );

                existing_args = get_param( this.Name, 'ParameterArgumentNames' );
                if isempty( existing_args )
                    existing_args = name;
                else
                    existing_args = sprintf( '%s, %s', existing_args, name );
                end
                set_param( this.Name, 'ParameterArgumentNames', existing_args );
                systemcomposer.internal.arch.internal.processBatchedPluginEvents( this.SimulinkModelHandle );
                pUsgImpl = this.ElementImpl.getParameter( name );
            else
                error( 'SystemArchitecture:Parameter:NonUniqueParameterName', message( 'SystemArchitecture:Parameter:NonUniqueParameterName', name, this.Name ).getString );
            end
        end
    end
    if ~isempty( pUsgImpl )
        pu = systemcomposer.arch.Parameter.wrapper( this, name );
    end
end
end

function b = musBeAValidArchitecture( this )
b = isa( this, 'systemcomposer.arch.Architecture' );
isAutosarModel = Simulink.internal.isArchitectureModel( this.SimulinkModelHandle, 'AUTOSARArchitecture' );
if b
    if ~isempty( this.Parent )
        if this.Parent.IsAdapterComponent
            msgId = 'SystemArchitecture:Parameter:CannotDefineOnAdapters';
            throwAsCaller( MException( msgId, DAStudio.message( msgId ) ) );
        elseif isAutosarModel && autosar.bsw.ServiceComponent.isBswServiceComponent( this.SimulinkHandle )
            msgId = 'SystemArchitecture:Parameter:CannotDefineAUTOSARServiceComponents';
            throwAsCaller( MException( msgId, DAStudio.message( msgId ) ) );
        end
    end
else
    msgId = 'SystemArchitecture:API:ArchitectureInvalidInput';
    throwAsCaller( MException( msgId, DAStudio.message( msgId ) ) );
end
end

