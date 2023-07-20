function[tempFillVertices,tempHoleVertices]=cleanUpFillsAndHoles(g1)


    nanfill_indx=find(isnan(g1.PolyFilledVertices(:,1))==1);
    tempFillVertices=cell(1,numel(nanfill_indx));
    tempfill_idx=[0;nanfill_indx];
    for i=1:numel(nanfill_indx)
        tempFillVertices{i}=g1.PolyFilledVertices(1+tempfill_idx(i):tempfill_idx(i+1)-2,1:2);
    end
    if(g1.NumHoles>0)
        nanhole_indx=find(isnan(g1.PolyHoleVertices(:,1))==1);
        tempHoleVertices=cell(1,numel(nanhole_indx));
        temphole_idx=[0;nanhole_indx];
        for i=1:numel(nanhole_indx)
            tempHoleVertices{i}=flipud(g1.PolyHoleVertices(1+temphole_idx(i):temphole_idx(i+1)-2,1:2));
        end
    else
        tempHoleVertices={[]};
    end