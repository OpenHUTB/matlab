function ret=getDatastoreForSignal(sigID,repo)


    ret=repo.safeTransaction(@locGetDatastoreForSignal,sigID,repo);
end


function ret=locGetDatastoreForSignal(sigID,repo)

    opts.sigID=sigID;
    opts.chunk=0;
    exporter=Simulink.sdi.internal.export.WorkspaceExporter.getDefault();
    ds=exportRun(...
    exporter,...
    repo,...
    opts,...
    false,...
    false,...
    '',...
    [],...
    []);
    assert(numElements(ds)==1);
    ret=getElement(ds,1);




    if isa(ret,'Simulink.SimulationData.Dataset')
        ret=ret{1};
        ret.Values=matlab.io.datastore.sdidatastore(sigID);
    else

        leafIDs=locGetLeafIDs(ret.Values,repo,sigID,int32.empty);
        ret.Values=locReplaceTimeseriesWithDatastore(ret.Values,leafIDs,repo);
    end
end


function leafIDs=locGetLeafIDs(vals,repo,sigID,leafIDs)
    bIsScalar=isscalar(vals);
    if isa(vals,'timeseries')
        if bIsScalar

            leafIDs(end+1)=sigID;
        else

            childIDs=repo.getSignalChildren(sigID);
            leafIDs=[leafIDs,childIDs'];
        end
    else
        assert(isstruct(vals));
        if bIsScalar

            childIDs=repo.getSignalChildren(sigID);
            fnames=fieldnames(vals);
            assert(length(childIDs)==length(fnames));
            for idx=1:length(childIDs)
                leafIDs=locGetLeafIDs(...
                vals.(fnames{idx}),...
                repo,...
                childIDs(idx),...
                leafIDs);
            end
        else

            childIDs=repo.getSignalChildren(sigID);
            assert(numel(childIDs)==numel(vals));
            for idx=1:numel(childIDs)
                leafIDs=locGetLeafIDs(...
                vals(idx),...
                repo,...
                childIDs(idx),...
                leafIDs);
            end
        end
    end
end


function[vals,leafIDs]=locReplaceTimeseriesWithDatastore(vals,leafIDs,repo)
    if isa(vals,'timeseries')

        orig_vals=vals;
        for idx=1:numel(orig_vals)
            if idx==1
                vals=matlab.io.datastore.sdidatastore(leafIDs(1),repo);
            else
                vals(idx)=matlab.io.datastore.sdidatastore(leafIDs(1),repo);
            end
            leafIDs(1)=[];
        end
        if~isscalar(vals)
            vals=reshape(vals,size(orig_vals));
        end
    else

        fnames=fieldnames(vals);
        for idx1=1:numel(vals)
            for idx2=1:length(fnames)
                [vals(idx1).(fnames{idx2}),leafIDs]=locReplaceTimeseriesWithDatastore(...
                vals(idx1).(fnames{idx2}),...
                leafIDs,...
                repo);
            end
        end
    end
end
