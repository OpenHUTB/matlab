function params = updateEDAScriptDefault( this, params )


cli = this.getCLI;
toolSelection = find( strcmpi( 'hdlsynthtool', params( 1:2:end  ) ) );

if ~isempty( toolSelection )
valueIndex = ( toolSelection - 1 ) * 2 + 1;

if ~strcmpi( params( valueIndex ), cli.get( 'hdlsynthtool' ) ) && ~strcmpi( params( valueIndex ), 'none' )






newToolSetting = params( valueIndex + 1 );
defaults = this.initEDAScript( newToolSetting );

postfixSetting = find( strcmpi( 'hdlsynthfilepostfix', params( 1:2:end  ) ) );
initSetting = find( strcmpi( 'hdlsynthinit', params( 1:2:end  ) ) );
cmdSetting = find( strcmpi( 'hdlsynthcmd', params( 1:2:end  ) ) );
termSetting = find( strcmpi( 'hdlsynthterm', params( 1:2:end  ) ) );

if ( isempty( cli.HDLSynthFilePostfix ) && isempty( cli.HDLSynthInit ) ...
 && isempty( cli.HDLSynthCmd ) && isempty( cli.HDLSynthTerm ) ...
 && isempty( postfixSetting ) && isempty( initSetting ) ...
 && isempty( cmdSetting ) && isempty( termSetting ) )


if isempty( postfixSetting )
params{ end  + 1 } = 'HDLSynthFilePostfix';
params{ end  + 1 } = defaults{ 2 };
end 

if isempty( initSetting )
params{ end  + 1 } = 'HDLSynthInit';
params{ end  + 1 } = defaults{ 4 };
end 

if isempty( cmdSetting )
params{ end  + 1 } = 'HDLSynthCmd';
params{ end  + 1 } = defaults{ 6 };
end 

if isempty( termSetting )
params{ end  + 1 } = 'HDLSynthTerm';
params{ end  + 1 } = defaults{ 8 };
end 
else 

if isempty( postfixSetting )
params{ end  + 1 } = 'HDLSynthFilePostfix';
if ( ~isempty( cli.HDLSynthFilePostfix ) )
params{ end  + 1 } = cli.HDLSynthFilePostfix;
else 
params{ end  + 1 } = defaults{ 2 };
end 
end 

if isempty( initSetting )
params{ end  + 1 } = 'HDLSynthInit';
params{ end  + 1 } = cli.HDLSynthInit;
end 

if isempty( cmdSetting )
params{ end  + 1 } = 'HDLSynthCmd';
params{ end  + 1 } = cli.HDLSynthCmd;
end 

if isempty( termSetting )
params{ end  + 1 } = 'HDLSynthTerm';
params{ end  + 1 } = cli.HDLSynthTerm;
end 
end 



params{ end  + 1 } = 'HDLSynthLibCmd';
params{ end  + 1 } = defaults{ 10 };
params{ end  + 1 } = 'HDLSynthLibSpec';
params{ end  + 1 } = defaults{ 12 };
end 
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpBy7x0M.p.
% Please follow local copyright laws when handling this file.

