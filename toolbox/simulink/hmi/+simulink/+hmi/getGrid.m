

function grid=getGrid(horizontalGrid,verticalGrid)
    if horizontalGrid&&verticalGrid
        grid='All';
    elseif horizontalGrid==0&&verticalGrid==0
        grid='None';
    elseif horizontalGrid==1
        grid='Horizontal';
    else
        grid='Vertical';
    end
end