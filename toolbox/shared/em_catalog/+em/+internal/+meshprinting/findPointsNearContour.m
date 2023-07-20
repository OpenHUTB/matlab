function out_close=findPointsNearContour(Pcontour,Pinner,Epsilon)
    out_close=[];
    for m=1:size(Pinner,1)
        temp=Pcontour-repmat(Pinner(m,:),size(Pcontour,1),1);
        temp=sqrt(dot(temp,temp,2));
        if any(temp<Epsilon)
            out_close=[out_close,m];%#ok<AGROW>
        end
    end
end