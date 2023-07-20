function sfAdj=getAdjMatFrmTransition(sfjunctionMap,sfTransitions)














    dCount=0;

    for c1=1:numel(sfTransitions)
        if isempty(sfTransitions(c1).Source)
            dCount=dCount+1;
        end
    end

    sfAdj=zeros(sfjunctionMap.Count+dCount,sfjunctionMap.Count+dCount);
    count=1;
    for c1=1:numel(sfTransitions)
        source=sfTransitions(c1).Source;
        destination=sfTransitions(c1).Destination;


        if~isempty(source)&&~isempty(destination)



            if~sfjunctionMap.isKey(destination.Id)||...
                ~sfjunctionMap.isKey(source.Id)
                continue;
            end

            sfAdj(sfjunctionMap(source.Id),sfjunctionMap(destination.Id))=1;



        elseif isempty(source)&&~isempty(destination)



            if~sfjunctionMap.isKey(destination.Id)
                continue;
            end
            sfAdj(sfjunctionMap.Count+count,sfjunctionMap(destination.Id))=1;
            count=count+1;

        end
    end
end
