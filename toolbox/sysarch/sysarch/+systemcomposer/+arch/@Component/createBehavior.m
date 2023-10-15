function this = createBehavior( this, behaviorOptions )

arguments
    this{ mustBeA( this, 'systemcomposer.arch.Component' ) }
    behaviorOptions.Type{ mustBeA( behaviorOptions.Type, 'systemcomposer.ArchitectureType' ) } = systemcomposer.ArchitectureType.empty( 0, 1 );
    behaviorOptions.IsReusable{ mustBeNumericOrLogical } = false
    behaviorOptions.FileName{ mustBeTextScalar } = ""
    behaviorOptions.Template{ mustBeTextScalar } = ""
    behaviorOptions.Reference{ mustBeTextScalar } = ""
end

behaviorOptions.FileName = string( behaviorOptions.FileName );
behaviorOptions.Template = string( behaviorOptions.Template );
behaviorOptions.Reference = string( behaviorOptions.Reference );

doPreConversionChecks( this, behaviorOptions );



if isequal( behaviorOptions.Type, systemcomposer.ArchitectureType.SimulinkModel ) && ~behaviorOptions.IsReusable
    error( 'systemcomposer:API:AddComponentModelLinkInvalidFlag', message(  ...
        'SystemArchitecture:API:AddComponentModelLinkInvalidFlag' ).getString );
end


if behaviorOptions.IsReusable && ( behaviorOptions.FileName.matches( "" ) && behaviorOptions.Reference.matches( "" ) )
    error( 'systemcomposer:API:AddComponentMissingModelInformation', message(  ...
        'SystemArchitecture:API:AddComponentMissingModelInformation' ).getString );
end

if ~behaviorOptions.FileName.matches( "" ) && ~behaviorOptions.Reference.matches( "" )
    error( 'systemcomposer:API:AddComponentConflictingModelInformation', message(  ...
        'SystemArchitecture:API:AddComponentConflictingModelInformation' ).getString );
end



if Simulink.internal.isArchitectureModel( this.SimulinkModelHandle, 'SoftwareArchitecture' ) &&  ...
        ~isequal( behaviorOptions.Type, systemcomposer.ArchitectureType.SimulinkModel )
    error( 'systemcomposer:API:AddComponentInvalidTypeForArchitecture', message(  ...
        'SystemArchitecture:API:AddComponentInvalidTypeForArchitecture', behaviorOptions.Type.char, 'SoftwareArchitecture' ).getString );
end

t = this.MFModel.beginTransaction;
switch ( behaviorOptions.Type )
    case systemcomposer.ArchitectureType.SimulinkModel
        if ~( behaviorOptions.FileName.matches( "" ) )
            this.createSimulinkBehavior( behaviorOptions.FileName, 'Template', behaviorOptions.Template );
        end
    case systemcomposer.ArchitectureType.SimulinkSubsystem
        if slfeature( 'ZCInlineSubsystem' ) && ~behaviorOptions.IsReusable
            this.createSimulinkBehavior( behaviorOptions.FileName, 'Type', 'Subsystem' );
        elseif behaviorOptions.IsReusable && ~behaviorOptions.FileName.matches( "" )
            this.createSimulinkBehavior( behaviorOptions.FileName, 'Type', 'SubsystemReference' );
        end
    case systemcomposer.ArchitectureType.Stateflow
        this.createStateflowChartBehavior;
end

if behaviorOptions.IsReusable && ~behaviorOptions.Reference.matches( "" )
    this.linkToModel( behaviorOptions.Reference );
end
t.commit;

end

function doPreConversionChecks( ~, behaviorOptions )

if isempty( behaviorOptions.Type )
    error( 'systemcomposer:API:CreateBehaviorMissingType', message(  ...
        'SystemArchitecture:API:CreateBehaviorMissingType' ).getString );
else
    switch ( behaviorOptions.Type )
        case systemcomposer.ArchitectureType.SimulinkModel

        case systemcomposer.ArchitectureType.SimulinkSubsystem
            if ~slfeature( 'ZCInlineSubsystem' ) && ~behaviorOptions.IsReusable
                error( 'systemcomposer:API:AddComponentCannotCreateInlinedSimulink', message(  ...
                    'SystemArchitecture:API:AddComponentCannotCreateInlinedSimulink' ).getString );
            end
            if ~slfeature( 'ZCSubsystemReference' ) && ( behaviorOptions.IsReusable || ~behaviorOptions.Reference.matches( "" ) )
                error( 'systemcomposer:API:AddComponentCannotCreateSSRef', message(  ...
                    'SystemArchitecture:API:AddComponentCannotCreateSSRef' ).getString );
            end
        case systemcomposer.ArchitectureType.Stateflow
            if behaviorOptions.IsReusable || ~behaviorOptions.Reference.matches( "" )
                error( 'systemcomposer:API:AddComponentStateflowCannotBeReusable', message(  ...
                    'SystemArchitecture:API:AddComponentStateflowCannotBeReusable' ).getString );
            end
    end

end


end

