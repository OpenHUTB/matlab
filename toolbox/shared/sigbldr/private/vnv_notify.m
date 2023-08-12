function vnv_notify( method, blockH, varargin )




if is_a_link( blockH ) || ~vnv_rmi_installed
return ;
end 

try 
vnv_assert_mgr( method, blockH, varargin{ : } );
catch vnvNotifyAssertMgrError %#ok<NASGU>

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpEKTFBI.p.
% Please follow local copyright laws when handling this file.

