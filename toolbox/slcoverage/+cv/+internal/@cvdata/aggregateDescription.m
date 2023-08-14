function aggregateDescription(this,srcCvd1,srcCvd2)




    cvdArray=[srcCvd1,srcCvd2];

    aggDescription=cvdArray(1).description;
    aggTag=cvdArray(1).tag;
    for i=2:length(cvdArray)
        aggDescription=joinProp(aggDescription,cvdArray(i).description);
        aggTag=joinProp(aggTag,cvdArray(i).tag);
    end
    this.description=aggDescription;
    this.tag=aggTag;

    cv.internal.cvdata.aggregateUniqueIds(this,cvdArray,[]);
end


function res=joinProp(prop1,prop2)
    res=prop1;

    if contains(prop1,prop2)
        prop2='';
    elseif contains(prop2,prop1)
        prop1='';
    end

    if~isempty(prop1)&&~isempty(prop2)
        res=[prop1,newline,prop2];
    elseif~isempty(prop1)
        res=prop1;
    elseif~isempty(prop2)
        res=prop2;
    end
end

