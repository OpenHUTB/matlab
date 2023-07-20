function[out,opts]=flattenForJson(in,recursive,varargin)



    if nargin<2||recursive
        recursiveFlatten=@doFlatten;
    else
        recursiveFlatten=@identity;
    end

    persistent ip;
    if isempty(ip)
        ip=inputParser();
        ip.addParameter('AnnotateObjectClass',false,@islogical);
        ip.addParameter('AnnotateFieldOrder',false,@islogical);
        ip.addParameter('ObjectAugmentor',[],@(s)isa(s,'function_handle'));
        ip.addParameter('CustomObjectSerializer',[],@(s)isa(s,'function_handle'));
        ip.addParameter('CustomObjectArraySerializer',[],@(s)isa(s,'function_handle'));
    end
    if nargin>2
        if~isstruct(varargin{1})

            ip.parse(varargin{:});
            opts=ip.Results;
        else
            opts=varargin{1};
        end
        annotateClass=opts.AnnotateObjectClass;
        annotateFieldOrder=opts.AnnotateFieldOrder;
        customObjSerializer=opts.CustomObjectSerializer;
        customObjArraySerializer=opts.CustomObjectArraySerializer;
        objectAugmentor=opts.ObjectAugmentor;
    else
        annotateClass=false;
        annotateFieldOrder=false;
        customObjSerializer=[];
        customObjArraySerializer=[];
        objectAugmentor=[];
        if nargout>1
            ip.parse();
            opts=ip.Results;
        end
    end

    warnState=warning('off');
    cleanup=onCleanup(@()warning(warnState));

    out=doFlatten(in);



    function out=doFlatten(obj)
        if ischar(obj)||isstring(obj)||isnumeric(obj)||islogical(obj)
            if~isenum(obj)
                assert(~issparse(obj));
                if isreal(obj)||isstring(obj)
                    out=obj;
                else

                    distrib=cell(1,ndims(obj));
                    for i=1:numel(distrib)
                        distrib{i}=ones(1,size(obj,i));
                    end
                    out=struct('r',mat2cell(real(obj),distrib{:}),'i',mat2cell(imag(obj),distrib{:}));
                end
            else
                oSize=size(obj);
                out=cell(oSize);
                for i=1:oSize(1)
                    for j=1:oSize(2)
                        out{i,j}=char(obj(i,j));
                    end
                end
            end
        elseif any(any(ishandle(obj)))||(isobject(obj)&&~isa(obj,'containers.Map')&&~iscategorical(obj))
            if isscalar(obj)
                out=flattenObject(obj);
            elseif~isempty(obj)
                if~isempty(customObjArraySerializer)
                    arrOut=customObjArraySerializer(obj);
                    if~isempty(arrOut)
                        out=arrOut;
                        return
                    end
                end
                for i=numel(obj):-1:1
                    out(i)=flattenObject(obj(i));
                end
            else
                out=[];
            end
        elseif isstruct(obj)
            out=processStruct(obj);
        elseif iscell(obj)
            out=obj;
            for i=1:numel(obj)
                out{i}=doFlatten(obj{i});
            end
        else
            out=obj;
        end
    end


    function out=processStruct(structArray)
        structFields=fieldnames(structArray);
        out=structArray;

        for i=1:numel(structArray)
            aStruct=structArray(i);
            recurse=false;

            for j=1:numel(structFields)
                val=aStruct.(structFields{j});

                if isobject(val)||isstruct(val)||iscell(val)
                    recurse=true;
                    break;
                elseif~isnumeric(val)&&~islogical(val)
                    areHandles=ishandle(val);
                    if~isempty(areHandles)&&any(areHandles(:))
                        recurse=true;
                        break;
                    end
                elseif~isreal(val)||isenum(val)
                    recurse=true;
                    break;
                end
            end

            if recurse
                temp=cell(numel(structFields),1);
                for j=1:numel(structFields)
                    temp{j}=recursiveFlatten(aStruct.(structFields{j}));
                end
                out(i)=cell2struct(temp,structFields,1);
            else
                out(i)=aStruct;
            end
        end

        if annotateFieldOrder
            [out.Fields__]=deal(structFields);
        end
    end


    function out=flattenObject(obj)
        if~isempty(customObjSerializer)
            out=customObjSerializer(obj);
            if~isempty(out)
                return;
            end
        end


        props=fieldnames(obj);
        propCount=numel(props);

        if propCount>0
            valueCell=cell(propCount,1);
            for pi=1:propCount
                try
                    value=obj.(props{pi});
                catch

                    continue;
                end
                valueCell{pi}=recursiveFlatten(value);
            end
            out=cell2struct(valueCell,props,1);
            if annotateClass
                out.MatlabType__=class(obj);
            end
        else
            out=struct();
        end

        if~isempty(objectAugmentor)
            augmented=objectAugmentor(obj,out);
            if~isempty(augmented)
                out=augmented;
            end
        end
    end
end



function x=identity(x)
end
