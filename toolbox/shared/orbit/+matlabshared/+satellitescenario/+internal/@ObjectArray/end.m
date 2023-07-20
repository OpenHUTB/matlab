function e=end(asset,k,n)





    s=size(asset.Handles);


    nds=numel(s);


    s=[s,ones(1,n-length(s)+1)];
    if n==1&&k==1
        e=prod(s);
    elseif n==nds||k<n
        e=s(k);
    else
        e=prod(s(k:end));
    end
end

