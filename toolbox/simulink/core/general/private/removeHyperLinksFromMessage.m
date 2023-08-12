function out = removeHyperLinksFromMessage( message )





[ pattern, replace_pattern ] = slsvInternal( 'slsvGetRemoveHotLinksRegexpPattern' );

out = regexprep( message, pattern, replace_pattern );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpdahQNb.p.
% Please follow local copyright laws when handling this file.

