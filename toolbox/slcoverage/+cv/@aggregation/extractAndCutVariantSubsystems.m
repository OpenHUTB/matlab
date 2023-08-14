



function[cutCvd,extractCvd]=extractAndCutVariantSubsystems(inCvdata)
    try
        cutCvd=[];
        extractCvd=[];

        toCutMap=struct('cvds',{},'path',{});
        for idx=1:numel(inCvdata)
            ccvd=inCvdata(idx);
            vs=ccvd.getRootVariantStates();
            if isempty(vs)
                continue;
            end

            for vidx=1:numel(vs)
                path=vs(vidx).path;
                state=vs(vidx).state;
                fidx=find({toCutMap.path}==string(path));
                if~isempty(fidx)&&state==1
                    toCutMap(fidx).cvds=[toCutMap(fidx).cvds,ccvd];
                else
                    toCutMap(end+1)=struct('cvds',ccvd,'path',vs(vidx).path);
                end

            end
        end
        if isempty(toCutMap)
            return;
        end

        for didx=1:numel(toCutMap)
            cvds=toCutMap(didx).cvds;

            if numel(cvds)==numel(inCvdata)
                continue;
            end
            subsysPath=toCutMap(didx).path;
            for cidx=1:numel(cvds)
                scvd=cvds(cidx);
                ucvd=scvd.extract(subsysPath);
                if~isempty(ucvd)
                    extractCvd=[extractCvd,ucvd];
                end
                tscvd=scvd.cutSubsystem(subsysPath);
                if~isempty(tscvd)
                    cutCvd=[cutCvd,tscvd];
                end
            end
        end
    catch MEx
        rethrow(MEx);
    end
end
