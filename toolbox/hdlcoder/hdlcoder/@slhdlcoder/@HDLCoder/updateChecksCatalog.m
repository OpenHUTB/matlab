function updateChecksCatalog( this, mdlName, checkArray )



if ~this.ChecksCatalog.isKey( mdlName )
this.ChecksCatalog( mdlName ) = [  ];
end 

curr = this.ChecksCatalog( mdlName );
this.ChecksCatalog( mdlName ) = cat( 2, curr, checkArray );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpHkmpqC.p.
% Please follow local copyright laws when handling this file.

