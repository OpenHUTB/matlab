function [ ResultDescription, ResultDetails ] = verifyCosim( system )



mdlAdvObj = Simulink.ModelAdvisor.getModelAdvisor( system );
mdlAdvObj.setCheckErrorSeverity( 1 );


hModel = bdroot( system );
hdriver = hdlmodeldriver( hModel );


hDI = hdriver.DownstreamIntegrationDriver;


if hDI.SkipVerifyCosim
[ ResultDescription, ResultDetails ] = publishSkippedMessage( mdlAdvObj, 'HDL Cosimulation.' );
return ;
end 

ResultDescription = {  };
ResultDetails = {  };
Passed = ModelAdvisor.Text( DAStudio.message( 'HDLShared:hdldialog:MSGPassed' ), { 'Pass' } );
Failed = ModelAdvisor.Text( DAStudio.message( 'HDLShared:hdldialog:MSGFailed' ), { 'Fail' } );

try 
[ Result, logTxt ] = hDI.runVerifyCosim( system );
catch ME
[ ResultDescription, ResultDetails ] = publishFailedMessage( mdlAdvObj, ME.message );
return ;
end 


if Result
statusText = Passed.emitHTML;
statusStr = { 'Pass' };
else 
statusText = Failed.emitHTML;
statusStr = { 'Fail' };
end 
text = ModelAdvisor.Text( [ statusText, 'HDL Cosimulation.' ] );
ResultDescription{ end  + 1 } = text;
ResultDetails{ end  + 1 } = '';

[ ResultDescription, ResultDetails ] = utilDisplayResult( logTxt,  ...
ResultDescription, ResultDetails, true );


mdlAdvObj.setCheckResultStatus( Result );
end 







% Decoded using De-pcode utility v1.2 from file /tmp/tmpxR7zho.p.
% Please follow local copyright laws when handling this file.

