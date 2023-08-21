function design=fullfact(levels)
    [m,n]=size(levels);
    if~isfloat(levels)
        levels=double(levels);
    end

    assert(min(m,n)==1,'levels must be a vector');
    assert(all(floor(levels)==levels)&&all(levels>=1),...
    'levels must have integer values');

    ssize=prod(levels);
    ncycles=ssize;
    cols=max(m,n);
    design=zeros(cols,ssize,class(levels));

    for k=1:cols
        settings=(1:levels(k));
        nreps=ssize./ncycles;
        ncycles=ncycles./levels(k);
        settings=settings(ones(1,nreps),:);
        settings=settings(:);
        settings=settings(:,ones(1,ncycles));
        design(k,:)=settings(:);
    end
end


