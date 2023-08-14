function feedloc=calculateCircularArrayFeedLocation(obj)

    if isempty(obj.Element)
        feedloc=[];
        return;
    end
    unitelementloc=obj.Element.FeedLocation;
    if size(unitelementloc,1)>1
        cross=1;
    else
        cross=0;
    end
    if isfield(obj.privateArrayStruct,'Radius')&&all(~cellfun(@isempty,{obj.Radius,obj.AngleOffset}))
        R=obj.Radius;
        numRings=numel(R);
        Nt=obj.NumElements/numRings;
        feedloc=[];
        start_angle=obj.AngleOffset;
        stop_angle=359+obj.AngleOffset;
        for i=1:numRings
            delta_theta=(stop_angle-start_angle)/(Nt);
            theta=start_angle:delta_theta:stop_angle-delta_theta;
            x=kron(R(i),cosd(theta));
            y=kron(R(i),sind(theta));
            z=zeros(size(x));
            if cross==1
                for i=1:Nt %#ok<FXSET>
                    j=i*2;
                    Feedlocx(j-1:j,:)=obj.Element.FeedLocation(:,1)+x(i);
                    Feedlocy(j-1:j,:)=obj.Element.FeedLocation(:,1)+y(i);
                end
                z=zeros(size(Feedlocx));
                feedloc=[feedloc;Feedlocx,Feedlocy,z(:)];%#ok<AGROW>
            else
                feedloc=[feedloc;x(:),y(:),z(:)];%#ok<AGROW>

            end
        end
    else
        feedloc=[];
        return;
    end

    if cross==1
        feedloc(:,3)=repmat(unitelementloc(5:6)',Nt,1);
    else
        feedloc(:,3)=unitelementloc(3);
    end
    feedloc=assignFeedLocation(obj,feedloc);
end

