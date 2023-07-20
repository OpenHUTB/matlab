function root=findMapTileCacheFolderRoot











    try
        root=matlabshared.supportpkg.getSupportPackageRoot();
        if isempty(root)
            root=prefdir;
        end
    catch
        root=prefdir;
    end
end