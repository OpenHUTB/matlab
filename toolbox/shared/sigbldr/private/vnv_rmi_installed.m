function out = vnv_rmi_installed







persistent rmi_installed;

if isempty( rmi_installed )
rmi_installed = exist( 'vnv_panel_mgr', 'file' ) == 6 | exist( 'vnv_panel_mgr', 'file' ) == 2;
end 
out = rmi_installed;

% Decoded using De-pcode utility v1.2 from file /tmp/tmpqoyA81.p.
% Please follow local copyright laws when handling this file.

