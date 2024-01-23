% 在 GPU 显存中分配 rows 行，cols 列的数组
function gArr = gpuArrayAlloc(rows,cols,dt)
    if strcmpi(dt,'logical')
        gArr = gpuArray.false(rows,cols);
    else
        gArr = gpuArray.zeros(rows,cols,dt);
    end
end


