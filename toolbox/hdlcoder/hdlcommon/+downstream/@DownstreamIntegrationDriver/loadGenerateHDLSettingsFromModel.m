function loadGenerateHDLSettingsFromModel( obj, modelName, loadTBSettings )



if nargin < 3
loadTBSettings = true;
end 

if ( obj.isMLHDLC || obj.queryFlowOnly == downstream.queryflowmodesenum.VIVADOSYSGEN )
return ;
end 



obj.loadingFromModel = true;




if strcmpi( hdlget_param( modelName, 'GenerateHDLCode' ), 'on' )
obj.GenerateRTLCode = true;
else 
obj.GenerateRTLCode = false;
end 
































genTB = strcmpi( hdlget_param( modelName, 'GenerateTB' ), 'on' );
genCosimTB = obj.isCosimEnabledOnModel;
genSVDPITB = obj.isSVDPIEnabledOnModel;




if ( genTB || genCosimTB || genSVDPITB ) && loadTBSettings
obj.GenerateTestbench = true;
end 




if ( strcmpi( hdlget_param( modelName, 'GenerateValidationModel' ), 'on' ) )
obj.GenerateValidationModel = true;
else 
obj.GenerateValidationModel = false;
end 

obj.loadingFromModel = false;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp22mwM8.p.
% Please follow local copyright laws when handling this file.

