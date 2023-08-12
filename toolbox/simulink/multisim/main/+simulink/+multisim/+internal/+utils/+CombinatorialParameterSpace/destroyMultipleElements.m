function destroyMultipleElements( dataModel, ~, modelHandle, elementIDs )




R36
dataModel( 1, 1 )mf.zero.Model
~
modelHandle( 1, 1 )double
elementIDs( 1, : )string
end 

txn = dataModel.beginTransaction(  );
for elementID = elementIDs
element = dataModel.findElement( elementID );
elementClassName = element.StaticMetaClass.name;
simulink.multisim.internal.utils.( elementClassName ).destroyElement( dataModel, element, modelHandle );
end 
txn.commit(  );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpQVEu7i.p.
% Please follow local copyright laws when handling this file.

