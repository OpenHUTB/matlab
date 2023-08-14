function addNeighborhoodCreator(ncc)




    try
        nc=streamingmatrix.NeighborhoodCreator(ncc);
        nc.doit;
    catch ex
        internal.mtree.utils.errorWithContext(ex,...
        'Neighborhood creation error: ',...
        '+streamingmatrix');
    end

end
