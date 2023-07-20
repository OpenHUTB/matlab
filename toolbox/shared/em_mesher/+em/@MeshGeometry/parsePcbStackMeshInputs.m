function meshControlOptions=parsePcbStackMeshInputs(obj,varargin)%#ok<INUSL>

    m=inputParser;
    expectedParams={'MaxEdgeLength','MinEdgeLength','GrowthRate','View',...
    'Slicer'};
    maxEdgeLengthValidationFcn=@(x)validateattributes(x,{'double'},...
    {'scalar','nonempty','nonzero','real','finite',...
    'nonnan','positive'});
    minEdgeLengthValidationFcn=@(x)validateattributes(x,{'double'},...
    {'nonempty','nonzero','real','finite','nonnan','positive'});
    growthRateValidationFcn=@(x)validateattributes(x,{'double'},...
    {'scalar','nonempty','nonzero','real','finite','nonnan','positive'...
    ,'>',0,'<',1});
    expectedview={'metal','dielectric volume','dielectric surface','all'};
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


    defaultCmin=1e-2;
    defaultGRate=0.7;

    onlyview=1;
    val=zeros(1,numel(varargin));
    for idx=1:numel(varargin)
        val(idx)=any(strcmpi(varargin{idx},{'MaxEdgeLength','MinEdgeLength','GrowthRate'}));
    end
    if any(val==1)
        onlyview=0;
    end

    if onlyview
        addParameter(m,expectedParams{1},0);
    else
        defaultHmax=1e-2;
        addParameter(m,expectedParams{1},defaultHmax,maxEdgeLengthValidationFcn);
    end
    addParameter(m,expectedParams{2},defaultCmin,minEdgeLengthValidationFcn);
    addParameter(m,expectedParams{3},defaultGRate,growthRateValidationFcn);
    addParameter(m,expectedParams{4},'all',@(x)any(validatestring(x,expectedview)));
    addParameter(m,expectedParams{5},'off',slicertypeValidationFcn);

    parse(m,varargin{:});
    meshControlOptions.Hmax=m.Results.MaxEdgeLength;
    if any(strcmpi(m.UsingDefaults,'MinEdgeLength'))
        meshControlOptions.Cmin=meshControlOptions.Hmax;
    else
        meshControlOptions.Cmin=m.Results.MinEdgeLength;
    end
    meshControlOptions.Grate=1+m.Results.GrowthRate;
    meshControlOptions.View=m.Results.View;
    meshControlOptions.slicer=m.Results.Slicer;




    if isHminUserSpecified(obj)
        parent=[];
        objtemp=obj;

        while~isempty(objtemp.MesherStruct.Parent)
            parent=objtemp.MesherStruct.Parent;
            objtemp=parent;
        end

        if~isempty(parent)&&isHminUserSpecified(parent)
            meshControlOptions.Cmin=getMinContourEdgeLength(parent);
        end
    end







