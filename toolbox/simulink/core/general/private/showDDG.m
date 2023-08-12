function showDDG( hSrc )




tr = DAStudio.ToolRoot;
openDlgs = tr.getOpenDialogs( hSrc );
dialog = {  };
for i = 1:length( openDlgs )
if openDlgs( i ).isStandAlone
dialog = openDlgs( i );
dialog.show;
break ;
end 
end 

if isempty( dialog )
dialog = DAStudio.Dialog( hSrc, '', 'DLG_STANDALONE' );
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpm1axc0.p.
% Please follow local copyright laws when handling this file.

