function out = vnv_enabled



persistent enabled;

if isempty( enabled )
enabled =  ...
( exist( 'vnv_assert_mgr', 'file' ) == 6 | exist( 'vnv_assert_mgr', 'file' ) == 2 );
end 
out = enabled;
% Decoded using De-pcode utility v1.2 from file /tmp/tmpWDviE0.p.
% Please follow local copyright laws when handling this file.

