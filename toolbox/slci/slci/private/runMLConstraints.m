






function[result,failureMap]=runMLConstraints(constraints,failureMap)


    result=true;

    for j=1:numel(constraints)

        constraint=constraints{j};
        ckey=constraint.getID;

        if~isKey(failureMap,ckey)
            failureMap(ckey)=containers.Map;
        end

        [failure,~]=constraint.checkCompatibility();
        if~isempty(failure)

            result=false;


            incompMap=failureMap(ckey);
            for k=1:numel(failure)
                incomp=failure(k);
                fkey=incomp.getCode;
                if isKey(incompMap,fkey)
                    incompMap(fkey)=[incompMap(fkey),incomp];
                else
                    incompMap(fkey)=incomp;
                end
            end
            failureMap(ckey)=incompMap;
        end
    end
end
