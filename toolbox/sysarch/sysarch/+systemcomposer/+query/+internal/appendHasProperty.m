function updatedQueryStr=appendHasProperty(intialQuery,propName,propVal)


    constraint=systemcomposer.query.Constraint.createFromString(intialQuery);
    updatedQuery=constraint&systemcomposer.query.Property(propName)==['''',propVal,''''];

    updatedQueryStr=updatedQuery.stringify;

end

