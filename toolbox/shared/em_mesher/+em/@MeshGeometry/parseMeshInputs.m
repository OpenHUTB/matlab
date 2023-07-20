function meshControlOptions=parseMeshInputs(obj,varargin)




    m=inputParser;
    expectedParams={'MaxEdgeLength','MinEdgeLength','GrowthRate','View','Slicer'};
    if isa(obj,'em.Antenna')
        if(isa(obj,'em.BackingStructure')||isa(obj,'em.ParabolicAntenna'))&&...
            em.internal.checkLRCArray(obj.Exciter)
            typeValidationFcn=@(x)validateattributes(x,{'double'},...
            {'nonempty','nonzero','real','finite',...
            'nonnan','positive'});
        else
            typeValidationFcn=@(x)validateattributes(x,{'double'},...
            {'scalar','nonempty','nonzero','real','finite',...
            'nonnan','positive'});

        end
    else
        typeValidationFcn=@(x)validateattributes(x,{'double'},...
        {'nonempty','nonzero','real','finite',...
        'nonnan','positive'});
    end
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

    if any(strcmpi(varargin,'MaxEdgeLength'))
        defaultHmax=1e-3;
        addParameter(m,expectedParams{1},defaultHmax,typeValidationFcn);
    else
        if~isempty(obj.MesherStruct.Mesh.MaxEdgeLength)


            previousHmin=obj.MesherStruct.Mesh.MaxEdgeLength;
            addParameter(m,expectedParams{1},previousHmin,typeValidationFcn);
        else
            addParameter(m,expectedParams{1},0);
        end
    end

    userSpecifiedHmin=0;
    if any(strcmpi(varargin,'MinEdgeLength'))
        defaultHmin=1e-3;
        addParameter(m,expectedParams{2},defaultHmin,typeValidationFcn);
        userSpecifiedHmin=1;
    else
        addParameter(m,expectedParams{2},0);
    end

    userSpecifiedGrate=0;
    if any(strcmpi(varargin,'GrowthRate'))
        userSpecifiedGrate=1;
    end
    if isempty(obj.MesherStruct.Mesh.MeshGrowthRate)
        defaultGRate=getNewMesherGrowthRate(obj)-1;
    else
        defaultGRate=obj.MesherStruct.Mesh.MeshGrowthRate-1;
    end

    addParameter(m,expectedParams{3},defaultGRate,growthRateValidationFcn);
    addParameter(m,expectedParams{4},'all',@(x)any(validatestring(x,expectedview)));
    addParameter(m,expectedParams{5},'off',slicertypeValidationFcn);

    try
        parse(m,varargin{:});
    catch ME
        obj.MesherStruct.MeshingChoice='auto';
        rethrow(ME);
    end
    meshControlOptions.Hmax=m.Results.MaxEdgeLength;
    meshControlOptions.Cmin=m.Results.MinEdgeLength;
    meshControlOptions.Grate=m.Results.GrowthRate+1;
    meshControlOptions.View=m.Results.View;
    meshControlOptions.slicer=m.Results.Slicer;
    obj.MesherStruct.Mesh.isHminUserSpecified=userSpecifiedHmin;



    if userSpecifiedGrate
        if isa(obj,'conformalArray')&&~isscalar(obj.Element)
            for i=1:numel(obj.Element)
                if iscell(obj.Element)
                    setMeshGrowthRate(obj.Element{i},m.Results.GrowthRate+1);
                else
                    setMeshGrowthRate(obj.Element(i),m.Results.GrowthRate+1);
                end
            end
        elseif isa(obj,'quadCustom')
            setMeshGrowthRate(obj.Exciter,m.Results.GrowthRate+1);
            cellfun(@(x)setMeshGrowthRate(x,m.Results.GrowthRate+1),obj.Director)
            cellfun(@(x)setMeshGrowthRate(x,m.Results.GrowthRate+1),obj.Reflector);
        else
            objtemp=obj;

            while~isempty(objtemp.MesherStruct.Child)
                child=objtemp.MesherStruct.Child;
                setMeshGrowthRate(objtemp.MesherStruct.Child,m.Results.GrowthRate+1);
                objtemp=child;
            end

            while~isempty(objtemp.MesherStruct.Parent)
                objtemp2=objtemp.MesherStruct.Parent;
                objtemp=objtemp2;
            end
            obj=objtemp;
        end
    end



    if isHminUserSpecified(obj)
        parent=[];
        objtemp3=obj;

        while~isempty(objtemp3.MesherStruct.Parent)
            parent=objtemp3.MesherStruct.Parent;
            objtemp3=parent;
        end

        if~isempty(parent)&&isHminUserSpecified(parent)
            meshControlOptions.Cmin=getMinContourEdgeLength(parent);
        end
    end