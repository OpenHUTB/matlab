function planes=validatePlanes(planes,bbox,mustBeInBoundingBox)










    inverseNormalLength=1./vecnorm(planes(:,1:3),2,2);
    planes=planes.*inverseNormalLength;

    if any(isnan(planes),'all')
        error(message('images:volume:invalidPlane'));
    end

    if mustBeInBoundingBox

        for i=1:size(planes,1)
            if~intersectsPlane(bbox,planes(i,:))
                error(message('images:volume:planeMustIntersect'));
            end
        end
    end

end

function TF=intersectsPlane(bbox,plane)

    minVal=0;
    maxVal=0;

    for idx=1:3
        if plane(idx)>0
            minVal=minVal+plane(idx)*bbox(1,idx);
            maxVal=maxVal+plane(idx)*bbox(2,idx);
        else
            minVal=minVal+plane(idx)*bbox(2,idx);
            maxVal=maxVal+plane(idx)*bbox(1,idx);
        end
    end

    TF=minVal<=-plane(4)&&maxVal>=-plane(4);

end