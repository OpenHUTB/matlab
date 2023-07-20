function copyProps(fromObj,toObj)













    rCopyProps('',fromObj,toObj);

    function rCopyProps(prefix,oldObj,newObj)








        oldProps=eval(['Simulink.data.getPropList(oldObj',prefix...
        ,', ''SetAccess'', ''public'')']);
        allOldProps=eval(['Simulink.data.getPropList(oldObj',prefix...
        ,', ''GetAccess'', ''public'')']);
        if(isa(oldProps,'schema.prop'))
            oldProps=oldProps.get;
            allOldProps=allOldProps.get;
        end
        newProps=eval(['Simulink.data.getPropList(newObj',prefix...
        ,', ''SetAccess'', ''public'')']);
        allNewProps=eval(['Simulink.data.getPropList(newObj',prefix...
        ,', ''GetAccess'', ''public'')']);
        if(isa(newProps,'schema.prop'))
            newProps=newProps.get;
            allNewProps=allNewProps.get;
        end
        newPropNames={newProps.Name};
        oldPropNames={oldProps.Name};
        allNewPropNames={allNewProps.Name};
        allOldPropNames={allOldProps.Name};



        commonPropNames=intersect(newPropNames,oldPropNames,'stable');

        commonAllPropNames=intersect(allNewPropNames,allOldPropNames);


        for name=commonPropNames
            str=name{:};
            try
                eval(['newObj',prefix,'.',str,' = oldObj',prefix,'.',str,';']);
            end
        end



        unsettableNames=setdiff(commonAllPropNames,commonPropNames);
        for name=unsettableNames
            str=name{:};
            newPrefix=[prefix,'.',str];


            level=Simulink.data.getScalarObjectLevel(eval(['oldObj',newPrefix]));
            if(level>0)
                rCopyProps(newPrefix,oldObj,newObj);
            end
        end

    end
end
