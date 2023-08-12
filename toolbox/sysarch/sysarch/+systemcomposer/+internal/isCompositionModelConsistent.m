function tf = isCompositionModelConsistent( modelNameOrHandle, showDiagnostics )






if nargin < 2
showDiagnostics = false;
end 

bdH = get_param( modelNameOrHandle, 'handle' );
tf = Simulink.SystemArchitecture.internal.ApplicationManager.isCompositionModelConsistent( bdH, showDiagnostics );

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp60hJ4r.p.
% Please follow local copyright laws when handling this file.

