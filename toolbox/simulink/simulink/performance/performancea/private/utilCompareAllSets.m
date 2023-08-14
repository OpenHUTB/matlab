function[setIds,simRange]=utilCompareAllSets(slopes,offsets)













    times=slopes+offsets;
    [~,setId]=min(times);
    simRange=nan(numel(slopes),2);
    setIds=nan(numel(slopes),1);

    ideal_mode_counter=1;

    simRange(1,1)=1;
    setIds(1)=setId;

    for j=1:numel(slopes)
        intersections=nan(size(slopes));
        for i=1:numel(slopes)
            if i==setId
                continue
            end
            intersections(i)=(offsets(setIds(j))-offsets(i))/...
            (slopes(i)-slopes(setIds(j)));
        end

        intersections(intersections<=simRange(j,1))=nan;
        [firstIntersect,firstId]=min(intersections);
        if~isnan(firstIntersect)
            simRange(j,2)=firstIntersect;
            simRange(j+1,1)=firstIntersect;
            setIds(j+1)=firstId;
            ideal_mode_counter=ideal_mode_counter+1;
        else
            simRange(j,2)=inf;
            break
        end
    end

    simRange=simRange(1:ideal_mode_counter,:);
    setIds=setIds(1:ideal_mode_counter);


    simRange(:,1)=ceil(simRange(:,1));
    simRange(:,2)=floor(simRange(:,2));

    invalidRows=simRange(:,2)<simRange(:,1);
    setIds(invalidRows)=[];
    simRange(invalidRows,:)=[];

end
