function setPseudoElabSettings( this, hN, hPreElabC, hPostElabC )





if ~ishandle( hPostElabC ) || ~ishandle( hPreElabC )
return ;
end 

if ~hPostElabC.isNetworkInstance
return ;
end 


if ~strcmp( hPreElabC.ClassName, 'black_box_comp' ) || ~hPreElabC.elaborationHelper
return ;
end 

hPreElabC.setAllowOptimizationLowering( allowElabModelGen( this, hN, hPreElabC ) );
hPreElabC.setForceOptimizationLowering( forceElabModelGen( this, hN, hPreElabC ) );



if hideElabNetworkinGM( this, hN, hPreElabC )
hPostElabC.getModelGenForNICTag(  );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpkF44Xf.p.
% Please follow local copyright laws when handling this file.

