











function out=FddULFirstInterleaving(in,tti)

    if isempty(in)
        out=[];
        return
    end
    out=fdd('FddULFirstInterleaving',in,tti);


    if size(in,1)>size(in,2)
        out=transpose(out);
    end

end