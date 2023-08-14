function maxPathLength=GetMaxPathLength(this)
    if(this.NumRows>=1)
        pathLengths=arrayfun(@(x)length(this.RowSources(x).path),...
        1:this.NumRows,...
        'UniformOutput',false);
        maxPathLength=max(cell2mat(pathLengths));
        if(maxPathLength<20)
            maxPathLength=20;
        end
    else
        maxPathLength=20;
    end


    this.MaxPathLength=maxPathLength;

end
