function updateLintParams( this, modelName )%#ok




linttool = this.getParameter( 'hdllinttool' );
LintTools = { 'None', 'SpyGlass', 'LEDA', 'AscentLint', 'HDLDesigner', 'Custom' };
linttool = LintTools{ linttool };
defaults = slhdlcoder.HDLCoder.initLintScript( linttool );

if isempty( this.getParameter( 'hdllintinit' ) )
this.setParameter( 'hdllintinit', defaults{ 4 } );
end 
if isempty( this.getParameter( 'hdllintterm' ) )
this.setParameter( 'hdllintterm', defaults{ 6 } );
end 
if isempty( this.getParameter( 'hdllintcmd' ) )
this.setParameter( 'hdllintcmd', defaults{ 2 } );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpZ4tq2Y.p.
% Please follow local copyright laws when handling this file.

