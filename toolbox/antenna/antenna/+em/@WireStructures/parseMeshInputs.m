function meshControlOptions=parseMeshInputs(obj,varargin)
    m=inputParser;
    expectedParams={'MaxEdgeLength','GrowthRate','View','Slicer'};
    maxEdgeLengthValidationFcn=@(x)validateattributes(x,{'double'},...
    {'scalar','nonempty','nonzero','real','finite',...
    'nonnan','positive'});
    growthRateValidationFcn=@(x)validateattributes(x,{'double'},...
    {'scalar','nonempty','nonzero','real','finite','nonnan','positive'...
    ,'>',0});
    expectedview={'wire segments','matching points','all'};
    expectedoption={'on','off'};

    ti=[];tid=[];
    for i=1:nargin-1
        ti(i)=strcmpi(varargin{i},'Slicer');
    end
    if~isempty(ti)
        tid=find(ti,1);
    end
    slicertypeValidationFcn=@(x)any(validatestring(x,expectedoption));
    if~isempty(tid)

        if(size(varargin,2)==tid)
            varargin{tid+1}='off';
        end

        if~isa(varargin{tid+1},'char')&&~isa(varargin{tid+1},'string')
            slicertypeValidationFcn=@(x)validateattributes(x,{'logical',...
            'double'},{'nonempty','scalar','real','nonnan','finite','binary'});
        end
    end


    defaultGRate=obj.MesherStruct.Mesh.MeshGrowthRate-1;

    defaultHmax=obj.MesherStruct.Mesh.MaxEdgeLength;
    addParameter(m,expectedParams{1},defaultHmax,maxEdgeLengthValidationFcn);
    addParameter(m,expectedParams{2},defaultGRate,growthRateValidationFcn);
    addParameter(m,expectedParams{3},'all',@(x)any(validatestring(x,expectedview)));
    addParameter(m,expectedParams{4},'off',slicertypeValidationFcn);

    parse(m,varargin{:});
    meshControlOptions.Hmax=m.Results.MaxEdgeLength;
    meshControlOptions.Grate=1+m.Results.GrowthRate;
    meshControlOptions.View=m.Results.View;
    meshControlOptions.slicer=m.Results.Slicer;