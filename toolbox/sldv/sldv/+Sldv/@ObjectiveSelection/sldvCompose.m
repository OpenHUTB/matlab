





function stmt=sldvCompose(specId,varargin)
    for k=1:numel(varargin)


        if isempty(varargin{k})

            continue;
        end

        if isfield(varargin{k},'pathList')
            stmt=sldvCompose_Paths(varargin{1:end});
        else
            stmt=sldvCompose_Basic(varargin{1:end});
        end
        stmt.specId=specId;
        return;
    end
    stmt.set=[];
end

function stmt=sldvCompose_Basic(varargin)
    set=[];
    specIds=[];
    toStore=true;
    detectionSites=struct([]);

    for k=1:numel(varargin)
        if isempty(varargin{k})
            continue;
        end
        if isfield(varargin{k},'set')
            set=[set,varargin{k}.set];%#ok<*AGROW>
        else
            if isfield(varargin{k},'elem')
                set(end+1).elem=varargin{k}.elem;
            end
            if isfield(varargin{k},'compSpecIds')
                specIds=[specIds,varargin{k}.compSpecIds];
            end
            if isfield(varargin{k},'testObjective')
                testObjective=varargin{k}.testObjective;
            end
            if isfield(varargin{k},'conjunction')
                isConjunction=varargin{k}.conjunction;
            end
            if isfield(varargin{k},'toStore')
                toStore=varargin{k}.toStore;
            end
            if isfield(varargin{k},'detectionSites')
                detectionSites=varargin{k}.detectionSites;
            end
        end
    end

    stmt.set=set;
    stmt.compSpecIds=specIds;
    stmt.testObjective=testObjective;
    stmt.conjunction=isConjunction;
    stmt.toStore=toStore;
    stmt.detectionSites=detectionSites;
end

function stmt=sldvCompose_Paths(varargin)





    set=[];
    pathList=[];

    for k=1:numel(varargin)
        if isempty(varargin{k})
            continue;
        end

        if isfield(varargin{k},'set')
            set=[set,varargin{k}.set];
        else
            if~isempty(varargin{k}.elem)


                set(end+1).elem=varargin{k}.elem;
            end
        end

        if isfield(varargin{k},'pathList')




            pathList=[pathList,varargin{k}.pathList];
        end
    end

    stmt.set=set;
    stmt.pathList=pathList;
end
