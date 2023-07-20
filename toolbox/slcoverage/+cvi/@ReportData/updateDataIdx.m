function updateDataIdx(data)



    try
        if SlCov.ContextGuard.canSkipUpdateDataIdx(data)
            return;
        end

        rootId=data.rootId;
        modelcovId=cv('get',rootId,'.modelcov');
        roots=cv('RootsIn',modelcovId);
        indexedForRoot=cv('get',modelcovId,'.indexedForRoot');
        needIndexingForRoot=numel(roots)>1&&...
        indexedForRoot~=rootId;
        needIndexingForRootVariants=cvi.RootVariant.setRootVariantFromCvdata(data);
        if needIndexingForRoot||needIndexingForRootVariants


            if isempty(cv('get',rootId,'.testobjectives'))
                cto=[];
                if data.id==0
                    tests=cv('TestsIn',rootId);

                    for idx=1:numel(tests)
                        cto=cv('get',tests(idx),'.testobjectives');
                        if any(cto)
                            break;
                        end
                    end
                else
                    cto=cv('get',data.id,'.testobjectives');
                end
                cv('set',rootId,'.testobjectives',cto);
            end
            cv('rootUpdateDataIdx',rootId,data.id,needIndexingForRootVariants);

        end
        applyFilter(data);
        data.processAgregatedInfo();
    catch MEx
        rethrow(MEx);
    end
end

