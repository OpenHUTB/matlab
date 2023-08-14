function propDiffs=getPropsWithInconsistentValues(obj1,obj2,excludeProperties)











    if(slfeature('SLDataDictionaryAllowInconsistentDuplicates')==0)
        narginchk(2,2);
    end

    if nargin==3
        if isstring(excludeProperties)
            excludeProperties=cellstr(excludeProperties);
        end

        assert(iscellstr(excludeProperties),...
        'Third argument must be a cell array of strings');
    else
        excludeProperties={};
    end

    propDiffs={};


    propList=fieldnames(obj1);
    for i=1:length(propList)
        propName=propList{i};
        if~ismember(propName,excludeProperties)

            subpropDiffs=slprivate('compareValues',obj1.(propName),obj2.(propName));
            for j=1:length(subpropDiffs)
                subprop=subpropDiffs{j};
                propDiff=propName;
                if~strncmp(subprop,'<',1)
                    propDiff=[propDiff,'.',subprop];
                end
                propDiffs{end+1}=propDiff;
            end
        end
    end

end
