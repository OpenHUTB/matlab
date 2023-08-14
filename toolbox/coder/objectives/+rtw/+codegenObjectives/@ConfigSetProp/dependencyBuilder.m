function dependencyBuilder(obj)



    dependency=dependencyList(obj);
    paramHash=obj.ParamHash;

    for i=1:length(dependency);
        dependency{i}.id=i;

        found1=0;
        found2=0;

        param1=dependency{i}.nameLeft;
        param2=dependency{i}.nameRight{1};

        resultId=paramHash.get(param1);
        if resultId>0
            found1=1;
            dependency{i}.idLeft=resultId;
        end

        resultId=paramHash.get(param2);
        if resultId>0
            found2=1;
            dependency{i}.idRight{1}=resultId;
        end

        if~found1||~found2
            dependency{i}.idLeft=-1;
            dependency{i}.idRight=[];
            dependency{i}.nOfRtP=0;
            dependency{i}.valid=0;
        else
            dependency{i}.valid=1;
        end

        dependency{i}.nOfRtP=1;
    end

    obj.Dependencies=dependency;
