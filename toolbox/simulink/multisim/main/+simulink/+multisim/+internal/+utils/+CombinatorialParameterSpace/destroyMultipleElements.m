function destroyMultipleElements( dataModel, ~, modelHandle, elementIDs )

arguments
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
