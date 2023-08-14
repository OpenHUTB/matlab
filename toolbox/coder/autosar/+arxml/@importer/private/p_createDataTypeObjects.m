function p_createDataTypeObjects(this,modelName,changeLogger)








    ddName=get_param(modelName,'DataDictionary');
    if isempty(ddName)
        workSpace='base';
    else
        workSpace=Simulink.dd.open(ddName);
    end


    m3iTypeSeq=autosar.mm.Model.findObjectByMetaClass(this.arModel,Simulink.metamodel.foundation.ValueType.MetaClass,true,true);


    slTypeBuilder=autosar.mm.mm2sl.TypeBuilder(this.arModel,true,workSpace,changeLogger,{},{});
    m3iMappedComp=autosar.api.Utils.m3iMappedComponent(modelName);
    slTypeBuilder.setM3iComp(m3iMappedComp);
    for typeIdx=1:m3iTypeSeq.size()
        slTypeBuilder.buildType(m3iTypeSeq.at(typeIdx));
    end
    slTypeBuilder.createAll(workSpace);
