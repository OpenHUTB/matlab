



function PersistentInference(funcTable,typeInference,...
    sizeInference,mtreeInference)
    fids=cell2mat(keys(funcTable));

    for k=1:numel(fids)
        fid=fids(k);
        ast=funcTable(fid);

        assert(isa(ast,'slci.ast.SFAstMatlabFunctionDef'));
        pArgs=ast.getPersistentArgs();
        for j=1:numel(pArgs)
            if isKey(mtreeInference,fid)
                typeInference.inferType(pArgs{j},mtreeInference(fid));
                sizeInference.inferSize(pArgs{j},mtreeInference(fid));
            end
        end
    end
end