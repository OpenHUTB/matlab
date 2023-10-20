function flag = isJavaUI(  )




import matlab.internal.lang.capability.Capability

flag =  ...
Capability.isSupported( Capability.LocalClient ) &&  ...
~matlab.internal.feature( 'webui' ) &&  ...
usejava( 'desktop' ) &&  ...
settings(  ).matlab.sourcecontrol.EnableJavaSourceControlAdaptersInRemoteClient.ActiveValue;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpBDhCc4.p.
% Please follow local copyright laws when handling this file.

