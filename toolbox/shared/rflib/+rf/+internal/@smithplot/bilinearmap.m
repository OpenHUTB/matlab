function mappoints=bilinearmap(points)



    mappoints=(points-1)./(1+points);

    if isnan(mappoints(end))
        mappoints(isnan(mappoints))=complex(-1,0);
    end

end