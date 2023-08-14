function propDiffs=compareValues(value1,value2)





    propDiffs={};
    if~strcmp(class(value1),class(value2))
        propDiffs{1}='<class>';
    else
        if(Simulink.data.getScalarObjectLevel(value1)==0||...
            Simulink.data.getScalarObjectLevel(value2)==0||...
            isenum(value1))

            if~isequal(value1,value2)
                propDiffs{1}='<value>';
            end
        else

            featureLevel=slfeature('SLDataDictionaryAllowInconsistentDuplicates');

            switch featureLevel
            case 0
                callClassMethod=false;
            case 1
                callClassMethod=isa(value1,'Simulink.Data');
            case 2
                callClassMethod=(isa(value1,'Simulink.Data')||...
                isa(value1,'Simulink.UserData'));
            case 3
                callClassMethod=l_hasMethod(value1,'getPropsWithInconsistentValues');
            otherwise
                assert(false);
            end

            if callClassMethod
                propDiffs=getPropsWithInconsistentValues(value1,value2);
            else
                propDiffs=Simulink.data.getPropsWithInconsistentValues(value1,value2);
            end
        end
    end
end

function hasMethod=l_hasMethod(obj,methodName)
    hasMethod=false;


    cls=metaclass(obj);
    if~isempty(cls)


        hiddenMethods=findobj(cls.MethodList,...
        'Access','public',...
        'Abstract',false,...
        'Name',methodName);
        hasMethod=~isempty(hiddenMethods);
    end

end
