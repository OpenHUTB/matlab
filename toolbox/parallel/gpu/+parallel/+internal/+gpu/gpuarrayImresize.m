function[B,map]=gpuarrayImresize(varargin)










    args=matlab.images.internal.stringToChar(varargin);

    params=matlab.images.internal.resize.resizeParseInputs(args{:});

    matlab.images.internal.resize.checkForMissingOutputArgument(params,nargout);

    A=matlab.images.internal.resize.preprocessImage(params);


    order=matlab.images.internal.resize.dimensionOrder(params.scale);


    weights=cell(1,params.num_dims);
    indices=cell(1,params.num_dims);
    allDimNearestNeighbor=true;
    for k=1:params.num_dims
        [weights{k},indices{k}]=matlab.images.internal.resize.contributions(...
        size(A,k),...
        params.output_size(k),params.scale(k),params.kernel,...
        params.kernel_width,params.antialiasing);

        if~isa(weights{k},'gpuArray')
            weights{k}=gpuArray(weights{k});
        end

        if~matlab.images.internal.resize.isPureNearestNeighborComputation(weights{k})
            allDimNearestNeighbor=false;
        end
    end

    if allDimNearestNeighbor
        B=matlab.images.internal.resize.resizeAllDimUsingNearestNeighbor(A,indices);
    else
        B=A;
        for k=1:numel(order)
            dim=gpuArray(order(k));
            B=resizeAlongDimGPU(B,dim,weights{dim},indices{dim});
        end
    end

    [B,map]=matlab.images.internal.resize.postprocessImage(B,params);

end


function out=resizeAlongDimGPU(in,dim,weights,indices)







    if matlab.images.internal.resize.isPureNearestNeighborComputation(weights)
        out=matlab.images.internal.resize.resizeAlongDimUsingNearestNeighbor(in,...
        dim,indices);
        return
    end

    out_length=size(weights,1);

    size_in=size(in);
    size_in((end+1):dim)=1;

    if(ndims(in)>3)




        pseudo_size_in=[size_in(1:2),prod(size_in(3:end))];
        in=reshape(in,pseudo_size_in);
    end



    out=matlab.images.internal.resize.imresizegpuArray(in,weights',indices',dim);

    if((length(size_in)>3)&&(size_in(end)>1))

        size_out=size_in;
        size_out(dim)=out_length;
        out=reshape(out,size_out);
    end

end

