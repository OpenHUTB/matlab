function setdisp( obj )





if ~obj.cmdDisplay
return ;
end 

optionWidth = 25;
valueWidth = 20;


fprintf( [ '%', num2str( optionWidth ), 's : %s' ], 'OptionID', 'Value' );
spaceWidth = valueWidth - length( 'Value' );
fprintf( [ '%', num2str( spaceWidth ), 's : %s\n' ], ' ', 'Choice' );


workflowID = '';
optionList = obj.getOptionList;
for ii = 1:length( optionList )
hOption = optionList{ ii };
workflowID = obj.dispWorkflowID( workflowID, hOption, optionWidth );

fprintf( [ '%', num2str( optionWidth ), 's : %s' ], hOption.OptionID, hOption.Value );
spaceWidth = valueWidth - length( hOption.Value );
if spaceWidth > 0
fprintf( [ '%', num2str( spaceWidth ), 's : {' ], ' ' );
else 
fprintf( ' : {' );
end 

choiceList = obj.getOptionChoice( hOption.OptionID );
if ~isempty( choiceList )
for jj = 1:length( choiceList ) - 1
fprintf( '<a href="matlab:set(downstream.handle(''Model'',''%s''), ''%s'', ''%s'');">%s</a>, ', obj.hCodeGen.ModelName, hOption.OptionID, choiceList{ jj }, choiceList{ jj } );
end 
fprintf( '<a href="matlab:set(downstream.handle(''Model'',''%s''), ''%s'', ''%s'');">%s</a>', obj.hCodeGen.ModelName, hOption.OptionID, choiceList{ end  }, choiceList{ end  } );
end 
fprintf( '}\n' );
end 


obj.dispButton;

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpxmIeQ4.p.
% Please follow local copyright laws when handling this file.

