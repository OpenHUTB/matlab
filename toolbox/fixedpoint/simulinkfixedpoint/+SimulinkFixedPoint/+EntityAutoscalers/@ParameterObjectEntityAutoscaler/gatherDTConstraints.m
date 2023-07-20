function[hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(~,dataObjectWrapper)






    DTConstraintsSet={};

    pkg=dataObjectWrapper.Object.CSCPackageName;
    csc=dataObjectWrapper.Object.CoderInfo.CustomStorageClass;
    cscDefn=processcsc('GetCSCDefn',pkg,csc);


    hasDTConstraints=isempty(cscDefn)||isMacro(cscDefn,dataObjectWrapper.Object);

    if hasDTConstraints
        constraint=SimulinkFixedPoint.AutoscalerConstraints.CodeGenMacroConstraint;
        constraint.setSourceInfo(dataObjectWrapper.Object,'');


        DTConstraintsSet{1}={[],constraint};
    end





