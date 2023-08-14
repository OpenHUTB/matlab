function constraints=trimFieldsOf1DArrayofConstraints(constraints)




    len=length(constraints);
    for i=1:len
        val=constraints(i);
        val.Name=strtrim(val.Name);
        val.Condition=strtrim(val.Condition);
        constraints(i)=val;
    end
end
