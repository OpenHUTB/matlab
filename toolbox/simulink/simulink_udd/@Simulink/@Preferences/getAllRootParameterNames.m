function paramnames=getAllRootParameterNames(obj)














    paramnames=obj.getRootParameterNames;

    c=obj.getChildren();
    allnames=cell(size(c));
    for i=1:numel(c)
        if~ismember('getRootParameterNames',methods(c(i)))

            fprintf(['Warning: Simulink.Preferences child %d (%s) has no '...
            ,'getRootParameterNames method\n'],i,class(c(i)));
            continue;
        end
        temp=c(i).getRootParameterNames;
        allnames{i}=temp(:);
    end

    paramnames=vertcat(paramnames(:),allnames{:});

