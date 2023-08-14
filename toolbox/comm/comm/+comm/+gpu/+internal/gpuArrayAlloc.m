function gArr=gpuArrayAlloc(rows,cols,dt)









    if strcmpi(dt,'logical')
        gArr=gpuArray.false(rows,cols);
    else
        gArr=gpuArray.zeros(rows,cols,dt);
    end
end


