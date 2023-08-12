function updateTestbenchChecksCatalog( this, mdlName, checkArray )



if ~this.TestbenchChecksCatalog.isKey( mdlName )
this.TestbenchChecksCatalog( mdlName ) = [  ];
end 

curr = this.TestbenchChecksCatalog( mdlName );
this.TestbenchChecksCatalog( mdlName ) = cat( 2, curr, checkArray );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpPQryPx.p.
% Please follow local copyright laws when handling this file.

