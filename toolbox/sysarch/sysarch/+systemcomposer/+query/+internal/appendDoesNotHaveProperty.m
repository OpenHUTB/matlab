function updatedQueryStr=appendDoesNotHaveProperty(intialQuery,propName)

    constraint=systemcomposer.query.Constraint.createFromString(intialQuery);
    updatedQuery=constraint&~systemcomposer.query.HasProperty(propName);

    updatedQueryStr=updatedQuery.stringify;

end

