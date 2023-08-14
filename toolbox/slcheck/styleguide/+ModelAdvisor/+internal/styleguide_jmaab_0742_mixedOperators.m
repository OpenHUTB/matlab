


function result=styleguide_jmaab_0742_mixedOperators(str)
    result=true;
    if isempty(str)
        return;
    end

    if iscell(str)
        str=str{1};
    end

    if contains(str,'&&')&&contains(str,'||')


        indicesMixedOps=regexp(str,'(&&|\|\|)');



        for currIndex=1:(length(indicesMixedOps)-1)
            if~strcmp(str(indicesMixedOps(currIndex)),str(indicesMixedOps(currIndex+1)))

                subStr=str(indicesMixedOps(currIndex):indicesMixedOps(currIndex+1));
                if(~contains(subStr,'(')&&~contains(subStr,')'))
                    result=false;
                    return;
                end
            end
        end
    end