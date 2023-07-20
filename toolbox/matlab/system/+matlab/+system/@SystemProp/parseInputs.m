function inactiveProps=parseInputs(obj,args,valueonlyprops)






    if isempty(args)
        inactiveProps=string.empty();
        return
    end


    if~isempty(valueonlyprops)


        pvIndex=length(args)+1;

        for ii=1:length(args)
            argN=args{ii};
            if ischar(argN)||isStringScalar(argN)
                if isprop(obj,argN)
                    pvIndex=ii;
                    break
                else
                    listProps=properties(obj);
                    indexProp=find(strcmpi(listProps,argN)>0,1);
                    if~isempty(indexProp)
                        matlab.system.internal.error('MATLAB:system:invalidCapitalization',...
                        class(obj),strcat('''',char(argN),''''),...
                        strcat('''',listProps{indexProp,1},''''));
                        break
                    end
                end
            end
        end

        if pvIndex>length(valueonlyprops)+1
            matlab.system.internal.error('MATLAB:system:invalidValueOnlyProps',...
            class(obj),length(valueonlyprops),pvIndex-1);
        end


        valueOnlyPairs=cell(1,2*(pvIndex-1));
        for ii=1:pvIndex-1
            offset=2*(ii-1)+1;
            valueOnlyPairs{offset}=valueonlyprops{ii};
            valueOnlyPairs{offset+1}=args{ii};
        end
        inactiveProps=pvParse(obj,valueOnlyPairs{:},args{pvIndex:end});
    else
        inactiveProps=pvParse(obj,args{:});
    end
end
