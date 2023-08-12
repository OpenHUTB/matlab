function result = promptclosebd( ModelName, testmode )













if nargin < 2
testmode = false;
end 

Prompt = DAStudio.message( 'Simulink:utility:PromptCloseBlockDiagram', ModelName );
Title = DAStudio.message( 'Simulink:utility:FileChangedOnDiskTitle' );

ButtonStrings = { DAStudio.message( 'Simulink:utility:IgnoreButton' ); ...
DAStudio.message( 'Simulink:utility:IgnoreAll' ); ...
DAStudio.message( 'Simulink:utility:CloseButton' ); ...
DAStudio.message( 'Simulink:utility:CloseAll' ); ...
DAStudio.message( 'Simulink:utility:CancelButton' ) };


Tags = { 'BD_KEEP_ONE', 'BD_KEEP_ALL', 'BD_CLOSE_ONE', 'BD_CLOSE_ALL', 'BD_CANCEL' };

d = DAStudio.DialogProvider;
if testmode
q = ButtonStrings{ 5 };
else 
q = d.questdlg( Prompt, Title, ButtonStrings, ButtonStrings{ 1 } );
if isempty( q )
q = ButtonStrings{ 5 };
end 
end 
result = Tags{ strcmp( q, ButtonStrings ) };

% Decoded using De-pcode utility v1.2 from file /tmp/tmpBvzHPT.p.
% Please follow local copyright laws when handling this file.

