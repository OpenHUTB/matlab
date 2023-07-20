function msh=meshCAD(filePath,varargin)
























































    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if(~exist(filePath,'file'))
        pm_error('sm:sli:callbacks:FileNotFound',filePath);
    end

    p=inputParser;
    addParameter(p,'MeshVolume',0,@islogical);
    addParameter(p,'Hmax',0,@isValidHmax);
    addParameter(p,'Hmin',0,@isValidHmin);
    addParameter(p,'GeometricOrder','quadratic',@isValidGeomOrder);
    addParameter(p,'Hgrad',0,@isValidHgrad);
    addParameter(p,'FacesToTrack',[],@isValidFaceId);
    addParameter(p,'QueryPoints',[],@isValidQueryPoint);
    addParameter(p,'QueryType','node',@isValidQueryType);
    addParameter(p,'HardPoints',[],@isValidQueryPoint);
    addParameter(p,'ComputeNormals',0,@islogical);

    parse(p,varargin{:});
    MeshVolume=p.Results.MeshVolume;
    Hmax=p.Results.Hmax;
    Hmin=p.Results.Hmin;
    Hgrad=p.Results.Hgrad;
    FacesToTrack=p.Results.FacesToTrack;
    QueryPoints=p.Results.QueryPoints;
    QueryType=p.Results.QueryType;
    enumQueryType=queryTypeToQueryEnum(QueryType);
    if(isempty(QueryPoints))
        enumQueryType=0;
    end
    HardPoints=p.Results.HardPoints;
    ComputeNormals=p.Results.ComputeNormals;
    if Hmax~=0&&Hmin~=0&&Hmin>Hmax
        pm_error('sm:sli:callbacks:InvalidHmaxHmin');
    end
    geomOrder=convertStringsToChars(p.Results.GeometricOrder);
    nc=numel(geomOrder);
    if(strncmpi(geomOrder,'linear',nc))
        linearOrder=true;
    else
        linearOrder=false;
    end
    if~isempty(FacesToTrack)

        FacesToTrack=FacesToTrack-1;
    end

    if isempty(HardPoints)
        try
            meshS=sm_mesh_generate(filePath,MeshVolume,...
            Hmax,Hmin,Hgrad,linearOrder,...
            FacesToTrack,QueryPoints',enumQueryType,...
            ComputeNormals);
        catch
            pm_error('sm:sli:callbacks:FileReadingError',filePath);
        end
    else
        try
            meshS=sm_mesh_generate_with_hardpoints(filePath,linearOrder,...
            FacesToTrack,HardPoints');
        catch
            pm_error('sm:sli:callbacks:FileReadingError',filePath);
        end
    end

    if(meshS.numNodes==-1)
        pm_error('sm:sli:callbacks:FileReadingError',filePath);
    elseif(meshS.numNodes==0)
        pm_error('sm:sli:callbacks:MeshingFailed');
    end

    n=meshS.nodes;
    n=reshape(n,3,numel(n)/3)';
    e=meshS.elements;
    numNodesPerElement=numel(e)/meshS.numElements;
    e=reshape(e,numNodesPerElement,meshS.numElements)';
    e=e+1;
    msh.numNodes=meshS.numNodes;
    msh.numElements=meshS.numElements;
    msh.numNodesPerElement=numNodesPerElement;
    msh.hMaxUsed=meshS.hMaxUsed;
    msh.nodes=n;
    msh.elements=e;
    msh.trackedFaceNodes=meshS.trackedFaceNodes;
    msh.hardNodes=meshS.hardNodes;
    msh.nearestNodes=[];
    msh.nearestElements=[];
    msh.boundaryNodes=[];
    msh.boundaryNodeNormals=[];
    if isfield(meshS,'nearestNodes')
        msh.nearestNodes=meshS.nearestNodes;
    end
    if isfield(meshS,'nearestElements')
        msh.nearestElements=meshS.nearestElements;
    end
    if isfield(meshS,'boundaryNodes')
        n=meshS.boundaryNodes;
        n=reshape(n,3,numel(n)/3)';
        msh.boundaryNodes=n;
    end
    if isfield(meshS,'boundaryNodeNormals')
        n=meshS.boundaryNodeNormals;
        n=reshape(n,3,numel(n)/3)';
        msh.boundaryNodeNormals=n;
    end
end







function enumQueryType=queryTypeToQueryEnum(qt)

    enumQueryType=0;
    nc=numel(qt);
    if strncmpi(qt,'node',nc)
        enumQueryType=1;
    elseif strncmpi(qt,'element',nc)
        enumQueryType=2;
    elseif strncmpi(qt,'boundaryNode',nc)
        enumQueryType=3;
    end
end


function ok=isValidFaceId(fid)
    if~any(isreal(fid))||any(ischar(fid))||any(fid<0)||issparse(fid)||~any(isfinite(fid))
        pm_error('sm:sli:callbacks:InvalidFaceId');
    end
    ok=true;
end

function ok=isValidHmax(hval)
    if~isreal(hval)||~isscalar(hval)||ischar(hval)||hval<0||issparse(hval)||~isfinite(hval)
        pm_error('sm:sli:callbacks:InvalidHmax');
    end
    ok=true;
end

function ok=isValidHmin(hval)
    if~isreal(hval)||~isscalar(hval)||ischar(hval)||hval<0||issparse(hval)||~isfinite(hval)
        pm_error('sm:sli:callbacks:InvalidHmin');
    end
    ok=true;
end

function ok=isValidHgrad(hgrad)
    if~isreal(hgrad)||~isscalar(hgrad)||ischar(hgrad)||issparse(hgrad)||~isfinite(hgrad)
        pm_error('sm:sli:callbacks:InvalidHgrad');
    elseif hgrad<=0||hgrad>2
        pm_error('sm:sli:callbacks:InvalidHgrad');
    end
    ok=true;
end

function ok=isValidGeomOrder(go)
    go=convertStringsToChars(go);
    if(~ischar(go)||isempty(go))
        pm_error('sm:sli:callbacks:InvalidGeomOrder');
    end
    nc=numel(go);
    if~(strncmpi(go,'linear',nc)||strncmpi(go,'quadratic',nc))
        pm_error('sm:sli:callbacks:InvalidGeomOrder');
    end
    ok=true;
end

function ok=isValidQueryType(qt)
    qt=convertStringsToChars(qt);
    if(~ischar(qt)||isempty(qt))
        pm_error('sm:sli:callbacks:InvalidQueryType');
    end
    nc=numel(qt);
    if~(strncmpi(qt,'node',nc)||strncmpi(qt,'element',nc)||...
        strncmpi(qt,'boundaryNode',nc))
        pm_error('sm:sli:callbacks:InvalidQueryType');
    end
    ok=true;
end

function ok=isValidQueryPoint(qp)
    if~any(isreal(qp))||ischar(qp)||issparse(qp)||~any(isfinite(qp(:)))
        pm_error('sm:sli:callbacks:InvalidQueryPoint');
    end
    if~isempty(qp)
        if size(qp,2)~=3
            pm_error('sm:sli:callbacks:InvalidQueryPoint');
        end
    end
    ok=true;
end