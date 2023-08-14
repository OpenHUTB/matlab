



function blockName=utilUnwrapBlockNameIfInModelRef(blockName)
    indices=strfind(blockName,'|');
    if~isempty(indices)
        try
            indices=[0,indices,length(blockName)+1];
            for k=1:length(indices)-1
                currentPath=blockName(indices(k)+1:indices(k+1)-1);

                nindices=strfind(currentPath,'/');
                currentMdl=currentPath(1:nindices(1)-1);

                load_system(currentMdl);
            end

            blockName=blockName(indices(end-1)+1:end);
        catch
        end
    end
end