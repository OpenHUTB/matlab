function mapping=createMapping(this)




    mapping=slreq.datamodel.MappingOptions(this.model);

    mapRequirement=slreq.datamodel.MappedType(this.model);





    mapRequirement.thisType='SpecObject';
    mapRequirement.thatType='RequirementItem';

    mapping.types.add(mapRequirement);
end

