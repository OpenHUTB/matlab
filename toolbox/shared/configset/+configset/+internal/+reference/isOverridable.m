function [ out, varargout ] = isOverridable( ref, parameter, fromDialog )

arguments
    ref
    parameter
    fromDialog( 1, 1 )logical = false
end

condition = configset.internal.reference.getOverrideConditions( ref, parameter );
out = all( [ condition{ : } ] );
[ modelref, enabled, dependency, exception, externalUse, unlocked ] = condition{ : };


if nargout > 1
    if out
        varargout{ 1 } = [  ];
    elseif ~unlocked

        varargout{ 1 } = MSLException( [  ], message( 'configset:diagnostics:ParameterOverrideRestrictedLocked' ) );
    elseif externalUse == false

        varargout{ 1 } = MSLException( [  ],  ...
            message( 'configset:diagnostics:ParameterOverrideRestrictedInternal', parameter ) );
    else
        data = configset.internal.reference.getParameterInfo( ref, parameter );
        if fromDialog
            description = data.Description;
        else
            description = parameter;
        end
        if exception == false
            varargout{ 1 } = MSLException( [  ],  ...
                message( 'configset:diagnostics:ParameterOverrideRestricted', description ) );
        elseif modelref == false
            varargout{ 1 } = MSLException( [  ],  ...
                message( 'configset:diagnostics:ParameterOverrideRestrictedModelReference', description ) );
        elseif enabled == false
            varargout{ 1 } = MSLException( [  ],  ...
                message( 'configset:diagnostics:ParameterOverrideRestrictedDisabled',  ...
                description, ref.getRefConfigSetName ) );
        elseif dependency == false
            dependsOnText = configset.internal.reference.getDependsOnText( ref, data, fromDialog );
            varargout{ 1 } = MSLException( [  ],  ...
                message( 'configset:diagnostics:ParameterOverrideRestrictedDependency',  ...
                description, dependsOnText ) );
        end
    end
end

