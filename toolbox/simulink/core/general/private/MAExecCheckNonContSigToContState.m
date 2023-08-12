function result = MAExecCheckNonContSigToContState( system )









result = [  ];%#ok<NASGU>
passString = [ '<p /><font color="#008000">', DAStudio.message( 'Simulink:tools:MAPassedMsg' ), '</font>' ];
model = bdroot( system );
hScope = get_param( system, 'Handle' );
hModel = get_param( model, 'Handle' );
mdladvObj = Simulink.ModelAdvisor.getModelAdvisor( system );
mdladvObj.setCheckResultStatus( false );

if ( hScope == hModel )
try 
troublespots = feval( model, 'get', 'discDerivSig' );
trouble = false( size( troublespots ) );
for i = 1:length( trouble )
if isempty( mdladvObj.filterResultWithExclusion( troublespots( i ).block ) )
continue ;
end 
trouble( i ) = true;
end 
troublespots = troublespots( trouble );

catch e %#ok<NASGU>
result = { DAStudio.message( 'Simulink:tools:MAMsgCouldNotCompileModel', model ) };
mdladvObj.setCheckResultStatus( false );
return 
end 

if ( ~isempty( troublespots ) )
nl = newline;
result = DAStudio.message( 'Simulink:tools:MAMsgNonContSigDerivPort' );

result = [ result, nl, '<table border="1" cellpadding="2">', DAStudio.message( 'Simulink:tools:MAMsgContSrcLocationHeader' ) ];
for i = 1:length( troublespots )
mangledname = modeladvisorprivate( 'HTMLjsencode', troublespots( i ).block, 'encode' );
mangledname = [ mangledname{ : } ];
dispname = regexprep( troublespots( i ).block, nl, ' ' );
result = [ result, DAStudio.message( 'Simulink:tools:MAMsgContSrcLocation', mangledname, dispname, troublespots( i ).port, troublespots( i ).idx, troublespots( i ).width ) ];%#ok<AGROW>
end 

result = [ result, '</table>', nl, DAStudio.message( 'Simulink:tools:MAMsgNonContSigDerivPortSuggest' ) ];
mdladvObj.setCheckResultStatus( false );
else 
result = passString;
mdladvObj.setCheckResultStatus( true );
end 
else 
result = passString;
mdladvObj.setCheckResultStatus( true );
end 
result = { result };


% Decoded using De-pcode utility v1.2 from file /tmp/tmpSQkAi_.p.
% Please follow local copyright laws when handling this file.

