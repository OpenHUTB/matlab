function varargout=matchType(op,varargin)







    isNumeric=cellfun(@isnumeric,varargin);
    NonNumericArg=varargin(~isNumeric);


    isModel=cellfun(@(x)isa(x,'InputOutputModel'),NonNumericArg);
    if~all(isModel)
        error(message('Control:general:InvalidOperand',...
        class(NonNumericArg{find(~isModel,1)})))
    end


    ModelTypes=cellfun(@class,NonNumericArg,'UniformOutput',false);
    Types=ModelTypes;
    nT=numel(Types);


    for ct=1:nT

        ctype=feval([Types{ct},'.toClosed'],op);
        if isempty(ctype)

            error(message('Control:general:NonCombinableType',Types{ct}))
        end
        Types{ct}=ctype;
    end


    DA=InputOutputModel.defaultAttributes();
    AList=fieldnames(DA);
    for ct=nT:-1:1
        A(ct,1)=feval([Types{ct},'.getAttributes'],DA);
    end
    isFRD=[A.FRD];


    for cta=1:numel(AList)
        Attribute=AList{cta};
        isDominant=[A.(Attribute)];
        if any(isDominant)&&any(~isDominant)

            idx=find(~isDominant);
            for ct=1:length(idx)
                GenType=feval([Types{idx(ct)},'.to',Attribute]);
                Types{idx(ct)}=GenType;
                A(idx(ct))=feval([GenType,'.getAttributes'],DA);
            end
        end
    end







    maxType=Types{1};
    supTypes=feval([maxType,'.superiorTypes']);
    for ct=2:length(Types)
        t=Types{ct};
        if~strcmp(t,maxType)
            supTypes=intersect(supTypes,feval([t,'.superiorTypes']),'stable');
            maxType=supTypes{1};
        end
    end




    narg=numel(varargin);
    NeedConvert=true(narg,1);
    NeedConvert(~isNumeric)=~strcmp(ModelTypes,maxType);
    if any(isFRD)

        isFRDType=false(narg,1);
        isFRDType(~isNumeric)=isFRD;
        refFRD=varargin{find(isFRDType,1)};
        for ct=1:narg
            if~isFRDType(ct)

                varargin{ct}=feval([maxType,'.convert'],varargin{ct},refFRD);
            elseif NeedConvert(ct)

                varargin{ct}=feval(maxType,varargin{ct});
            end
        end
    else



        for ct=1:narg
            if NeedConvert(ct)
                varargin{ct}=feval([maxType,'.convert'],varargin{ct});
            end
        end
    end
    varargout=varargin;

end
