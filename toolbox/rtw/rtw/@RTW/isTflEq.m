function result=isTflEq(name1,name2)













    if nargin==2
        name1=convertStringsToChars(name1);
        name2=convertStringsToChars(name2);
        delimiter=coder.internal.getCrlLibraryDelimiter;

        if~contains(name1,delimiter)&&~contains(name2,delimiter)

            tfl1=RTW.resolveTflName(name1);
            tfl2=RTW.resolveTflName(name2);
            result=strcmp(tfl1,tfl2);
        else
            lhsNames=coder.internal.getCrlLibraries(name1);
            rhsNames=coder.internal.getCrlLibraries(name2);
            ln=length(lhsNames);
            rn=length(rhsNames);
            if ln~=rn
                result=false;
            else
                result=true;
                for i=1:ln
                    tfl1=RTW.resolveTflName(lhsNames{i});
                    tfl2=RTW.resolveTflName(rhsNames{i});
                    if~strcmp(tfl1,tfl2)
                        result=false;
                        return;
                    end
                end
            end
        end

    else
        DAStudio.error('RTW:targetRegistry:invalidNumOfArgs');
    end
