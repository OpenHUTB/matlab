







function out=flattenForJava(obj,varargin)
    dataTypeModeWarning='fixed:numerictype:getDataTypeMode';
    state=warning('query',dataTypeModeWarning);
    warning('off',dataTypeModeWarning);
    finishup=onCleanup(@()warning(state.state,dataTypeModeWarning));


    if numel(varargin)>0&&isa(varargin{1},'function_handle')
        postProcessor=varargin{1};
    else
        postProcessor=[];
    end

    out=flattenForJavaRecursion(obj,postProcessor);

end


function out=flattenForJavaRecursion(obj,postProcessor)
    persistent ntStructBase;
    persistent ntFields;

    if isempty(obj)
        if(ischar(obj))
            out='';
        else
            out=[];
        end
    elseif(isstruct(obj)||isTreatableObject(obj)||isnumerictype(obj))...
        &&numel(obj)>1


        for i=numel(obj):-1:1
            out(i)=flattenForJavaRecursion(obj(i),postProcessor);
        end
    elseif iscell(obj)
        out=cell(1,numel(obj));
        for i=1:numel(obj)
            out{i}=flattenForJavaRecursion(obj{i},postProcessor);
        end
    elseif isTreatableObject(obj)
        p=properties(obj);
        if~isempty(p)
            tmp=cell(numel(p),1);
            for pi=1:numel(p)
                tmp{pi}=flattenForJavaRecursion(obj.(p{pi}),postProcessor);
            end
            out=cell2struct(tmp,p,1);

            if~isempty(postProcessor)
                out=postProcessor(obj,out);
            end
        else

            out=[];
        end
    elseif isnumerictype(obj)
        if isempty(ntStructBase)
            ntFields=fieldnames(obj);
            ntStructBase=cell2struct(cell(size(ntFields)),ntFields);
        end
        out=ntStructBase;
        for i=1:numel(ntFields)
            out.(ntFields{i})=obj.(ntFields{i});
        end
    elseif isstruct(obj)
        f=fieldnames(obj);
        recurse=false;

        for i=1:numel(f)
            val=obj.(f{i});
            if isTreatableObject(val)||isstruct(val)||iscell(obj)||isnumerictype(val)
                recurse=true;
                break;
            end
        end


        if recurse
            tmp=cell(numel(f),1);
            for i=1:numel(f)
                tmp{i}=flattenForJavaRecursion(obj.(f{i}),postProcessor);
            end
            out=cell2struct(tmp,f,1);
        else
            out=obj;
        end
    else
        out=obj;
    end
end


function yes=isTreatableObject(obj)
    yes=isobject(obj)&&~isa(obj,'half')&&~iscategorical(obj);
end