function [ out, varargout ] = isRestorable( ref, parameter, fromDialog )




R36
ref
parameter
fromDialog( 1, 1 )logical = false
end 


condition = configset.internal.reference.getOverrideConditions( ref, parameter );
dependency = condition{ 3 };
externalUse = condition{ 5 };
unlocked = condition{ 6 };
out = dependency && externalUse && unlocked;


if nargin > 1
if out
varargout{ 1 } = [  ];
elseif ~unlocked

varargout{ 1 } = MSLException( [  ],  ...
message( 'configset:diagnostics:ParameterRestoreRestrictedLocked' ) );
elseif ~externalUse

varargout{ 1 } = MSLException( [  ],  ...
message( 'configset:diagnostics:ParameterRestoreRestrictedInternal', parameter ) );
else 
data = configset.internal.reference.getParameterInfo( ref, parameter );
if fromDialog
description = data.Description;
else 
description = parameter;
end 
dependsOnText = configset.internal.reference.getDependsOnText( ref, data, fromDialog );
varargout{ 1 } = MSLException( [  ],  ...
message( 'configset:diagnostics:ParameterRestoreRestrictedDependency',  ...
description, dependsOnText ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpWEVwDR.p.
% Please follow local copyright laws when handling this file.

