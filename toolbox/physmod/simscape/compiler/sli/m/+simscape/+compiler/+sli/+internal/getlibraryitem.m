function s=getlibraryitem(blk)






    m=physmod.schema.internal.blockComponentSchema(blk).info().Members;

    ids={m.Parameters.ID,m.Variables.ID};


    assert(isequal(ids,unique(ids,'stable')));

    descriptions={m.Parameters.Label,m.Variables.Label};

    s=cell2struct(descriptions(:),ids(:));

end
