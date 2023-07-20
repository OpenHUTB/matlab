function plan=peakMarkerUpdatePlan(p,changedDatasets)




























    markerDataset=getPeakMarkerDataset(p);







    map=cell(1,getNumDatasets(p));
    allAdded=[];
    allUnused=[];
    Nmarkers=numel(markerDataset);
    nextMarkerIdx=1+Nmarkers;
    peakLocs=p.pPeakLocationList;
    for i=1:numel(changedDatasets)
        ds_i=changedDatasets(i);




        marker_indices_needed=peakLocs{ds_i};
        Nneeded=size(marker_indices_needed,1);


        midx=find(markerDataset==ds_i);
        Npresent=numel(midx);

        if Nneeded<Npresent
            add_i=[];
            map_i=midx(1:Nneeded);
            unused_i=midx(Nneeded+1:Npresent);
        elseif Nneeded>Npresent
            D=Nneeded-Npresent;
            add_i=(nextMarkerIdx:nextMarkerIdx+D-1)';
            map_i=[midx;add_i(:)];
            unused_i=[];
            nextMarkerIdx=nextMarkerIdx+D;
        else
            add_i=[];
            unused_i=[];
            map_i=midx;
        end

        allAdded=[allAdded;add_i];%#ok<AGROW>
        allUnused=[allUnused;unused_i];%#ok<AGROW>
        map{ds_i}=map_i;
    end




    Nunused=numel(allUnused);
    Nadded=numel(allAdded);
    if Nunused>0&&Nadded>0


        Nreused=min(Nunused,Nadded);
        for i=1:Nreused
            reuse_i=allUnused(i);
            add_i=allAdded(Nadded+1-i);


            used_i=false;
            for j=1:numel(changedDatasets)
                ds_j=changedDatasets(j);
                map_j=map{ds_j};
                sel=map_j==add_i;
                if any(sel)
                    map_j(sel)=reuse_i;
                    map{ds_j}=map_j;
                    used_i=true;
                    break
                end
            end
            assert(used_i);
        end
        allUnused=allUnused(Nreused+1:Nunused);
        allAdded=allAdded(1:Nadded-Nreused);

        Nadded=numel(allAdded);
    end



    map_addneg=map;
    if Nadded>0
        new_indices=Nmarkers+1:Nmarkers+Nadded;
        for i=1:numel(changedDatasets)
            ds_i=changedDatasets(i);
            map_i=map_addneg{ds_i};
            [~,ia]=intersect(map_i,new_indices);
            if~isempty(ia)
                map_i(ia)=-map_i(ia);
                map_addneg{ds_i}=map_i;
            end
        end
    end



    plan.map=map;
    plan.map_addneg=map_addneg;
    plan.remove=allUnused;
    plan.add=Nadded;
