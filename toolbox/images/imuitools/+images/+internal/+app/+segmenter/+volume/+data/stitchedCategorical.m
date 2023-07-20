function data=stitchedCategorical(data,values,names)


















    assert(ismatrix(data)||ndims(data)==3,'This function only supports 2D and 3D inputs');


    sz=size(data,1:3);

    if sz(3)>=10
        dim=3;
    elseif sz(2)>=10
        dim=2;
    elseif sz(1)>=10
        dim=1;
    else

        data=categorical(data,values,names);
        return;
    end

    chunks=cell([10,1]);
    chunkingVector=linspace(0,sz(dim),11);



    emptyCat=categorical(1:255,values+1,names);

    switch dim
    case 1

        for idx=1:10

            chunks{idx}=emptyCat(data(ceil(chunkingVector(idx))+1:ceil(chunkingVector(idx+1)),:,:)+1);

        end

    case 2

        for idx=1:10

            chunks{idx}=emptyCat(data(:,ceil(chunkingVector(idx))+1:ceil(chunkingVector(idx+1)),:)+1);

        end

    case 3

        for idx=1:10

            chunks{idx}=emptyCat(data(:,:,ceil(chunkingVector(idx))+1:ceil(chunkingVector(idx+1)))+1);

        end

    end

    data=cat(dim,chunks{1},chunks{2},chunks{3},chunks{4},chunks{5},chunks{6},chunks{7},chunks{8},chunks{9},chunks{10});

end