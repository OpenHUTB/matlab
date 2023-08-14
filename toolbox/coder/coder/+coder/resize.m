function out=resize(t,varargin)
























































    try
        if nargin<1
            error(message('Coder:common:NotEnoughInputs'));
        end

        p=inputParser();
        p.FunctionName='coder.resize';
        p.addOptional('SizeVector',[]);
        p.addOptional('VariableDims',[]);
        p.addParameter('Recursive',false);
        p.addParameter('Uniform',false);
        p.addParameter('SizeLimits',[inf,inf]);
        p.addParameter('Gpu',false,@islogical);
        p.addParameter('MakeCategoricalCategoryNamesHomogeneous',true,@islogical);

        p.parse(varargin{:});
        r=p.Results;

        if r.Gpu&&isempty(r.SizeVector)&&all(t.SizeVector==1)
            r.SizeVector=[1,1];
        end


        if isempty(r.SizeVector)
            r.SizeVector=[];
        else
            validateattributes(r.SizeVector,{'numeric'},{'vector'},'coder.resize','SZ');
            r.SizeVector=double(r.SizeVector);
        end

        if isempty(r.VariableDims)
            r.VariableDims=[];
        else
            validateattributes(r.VariableDims,{'double','logical'},{'vector','real'},'coder.resize','VDIMS');
        end
        r.VariableDims=r.VariableDims~=0;

        validateattributes(r.Recursive,{'double','logical'},{'scalar'},'coder.resize','RECURSIVE');
        r.Recursive=r.Recursive~=0;

        validateattributes(r.Uniform,{'double','logical'},{'scalar'},'coder.resize','UNIFORM');
        r.Uniform=r.Uniform~=0;

        if isempty(r.SizeLimits)
            r.SizeLimits=[inf,inf];
        else
            validateattributes(r.SizeLimits,{'numeric'},{'vector','real'},...
            'coder.resize','SIZELIMITS');
            if numel(r.SizeLimits)>2
                error(message('Coder:common:ResizeSizeLimitsNumel'));
            end
            r.SizeLimits=double(r.SizeLimits);
            if isscalar(r.SizeLimits)
                r.SizeLimits(2)=r.SizeLimits(1);
            end
            if r.Uniform
                r.SizeLimits=max(r.SizeLimits,1);
            else
                r.SizeLimits=max(r.SizeLimits,2);
            end
        end



        if isa(t,'coder.type.Base')
            if~t.supportsCoderResize().supported
                error(message('Coder:common:CoderTypeResizeNotSupported',class(t)));
            end
        end

        out=worker(t,r.SizeVector,r.VariableDims,r.Recursive,r.Uniform,r.SizeLimits);
    catch me
        if isa(me,'coder.internal.PathException')
            x=coderprivate.msgSafeException('Coder:common:Resize',me.errPath);
            x=coderprivate.transferCauses(me,x);
        else
            x=me;
        end
        x.throwAsCaller();
    end
end

function out=worker(t,sz,vd,recursive,uniform,sizelimits)
    if iscell(t)
        out=t;
        for i=1:numel(t)
            try
                out{i}=worker(t{i},sz,vd,recursive,uniform,sizelimits);
            catch me
                errPath=['{',num2str(i),'}'];
                if isa(me,'coder.internal.PathException')
                    me.errPath=[errPath,me.exportErrorPath()];
                else
                    me=coder.internal.PathException(me,0,errPath);
                end
                me.throw();
            end
        end
    else
        if~(isa(t,'coder.Type')||isa(t,'coder.type.Base'))||~isscalar(t)
            error(message('Coder:common:ResizeRequireType'));
        end
        if recursive
            out=resizeStruct(t,sz,vd,uniform,sizelimits);
        else
            if isa(t,'coder.type.Base')||(isa(t,'coder.ClassType')&&coder.internal.classSupportsCoderResize(t.ClassName))


                out=resizeKnownClassesInternal(t,sz,vd,recursive,uniform,sizelimits);
            else

                out=t.resizeInternal(sz,vd,uniform,sizelimits);
            end
        end
    end
end

function t=resizeStruct(t,sz,vd,uniform,sizelimits)
    if isa(t,'coder.type.Base')
        error(message('Coder:common:CoderTypeRecursiveResize'));
    else

        t=t.resizeInternal(sz,vd,uniform,sizelimits);
    end

    if isa(t,'coder.StructType')
        fields=t.Fields;
        fnames=fieldnames(fields);
        for i=1:numel(fnames)
            fname=fnames{i};
            try
                fields.(fname)=resizeStruct(fields.(fname),sz,vd,uniform,sizelimits);
            catch me
                if~isa(me,'coder.internal.PathException')
                    me=coder.internal.PathException(me,0,'');
                end
                me.errPath=['.',fname,me.errPath];
                me.throw();
            end
        end
        t.Fields=fields;
    end

end

function vec=expandVector(vec,sz)
    if isscalar(vec)
        vec=repmat(vec,[1,numel(sz)]);
    else


        if~isrow(vec)
            vec=vec';
        end
    end
end

function out=resizeKnownClassesInternal(t,sz,vd,recursive,uniform,sizelimits)

    if isa(t,'coder.type.Base')
        resize=t.supportsCoderResize();


        if~isempty(sz)

            sz=expandVector(sz,t.Size);
            t=t.setSize('Size',sz);
        end


        if isempty(vd)
            vd=isinf(sz);
        end

        if~isempty(vd)
            vd=expandVector(vd,t.VarDims);
            t=t.setSize('VarDims',vd);
        end



        if isfield(resize,'callback')&&~isempty(resize.callback)


            out=feval(resize.callback,t,recursive,uniform,sizelimits);
        else
            if~isfield(resize,'property')||isempty(resize.property)
                error(message('Coder:common:CoderTypeInvalidResizeProp'));
            end



            if~isprop(t,resize.property)
                try

                    if startsWith(resize.property,'Properties.')
                        resizePropertyName=resize.property;
                    else
                        resizePropertyName=['Properties.',resize.property];
                    end

                    ct=t.getCoderType();
                    prop=eval(['ct.',resizePropertyName]);%#ok<EVLDOT> 
                    prop=prop.resizeInternal(sz,vd,uniform,sizelimits);%#ok<NASGU>
                    eval(['ct.',resizePropertyName,'= prop;']);%#ok<EVLDOT> 


                    t=t.setCoderType(ct,false);
                catch
                    error(message('Coder:common:CoderTypeInvalidResizeProp'));
                end
            else
                t.(resize.property)=t.(resize.property).resizeInternal(sz,vd,uniform,sizelimits);
            end

            t=t.updateSize();
            out=t;
        end
    elseif strcmp(t.ClassName,'table')||strcmp(t.ClassName,'timetable')
        out=resizeTable(t,sz,vd,recursive,uniform,sizelimits);
    else

        out=resizeSpoofReportClass(t,sz,vd,recursive,uniform,sizelimits);
    end
end

function out=resizeSpoofReportClass(t,sz,vd,~,uniform,sizelimits)



    out=t;
    props=fieldnames(t.Properties);



    if isempty(props)
        error(message('Coder:common:ResizeOnEmptyClassTypeNotSupported'));
    else
        prop=props{1};
        out.Properties.(prop)=out.Properties.(prop).resizeInternal(sz,vd,uniform,sizelimits);
    end
end

function out=resizeTable(t,sz,vd,recursive,uniform,sizelimits)



    if isempty(t.Properties)||~isfield(t.Properties,'data')
        error(message('Coder:common:ResizeOnEmptyClassTypeNotSupported'));
    end







    sz=scalarExpandTableSize(sz,[1,1]);
    vd=scalarExpandTableSize(vd,false(1,2));

    coder.internal.assert(sz(2)==t.Properties.data.SizeVector(2),'Coder:common:TableResizeNumVars');
    coder.internal.assert(vd(2)==false,'Coder:common:TableVariableNumVars');

    out=t;
    cs=out.Properties.data.Cells;
    for k=1:numel(cs)
        c=cs{k};
        rowSizeVector=c.SizeVector;
        rowSizeVector(1)=sz(1);
        rowVarDims=c.VariableDims;
        rowVarDims(1)=vd(1);
        cs{k}=worker(c,rowSizeVector,rowVarDims,recursive,uniform,sizelimits);
    end
    out.Properties.data.Cells=cs;
    if isfield(out.Properties.rowDim.Properties,'labels')
        rowNames=out.Properties.rowDim.Properties.labels;
        if~isequal(rowNames.SizeVector,[0,0])

            rowDims=[sz(1),1];
            rowVarDims=[vd(1),false];
            out.Properties.rowDim.Properties.labels=worker(rowNames,rowDims,rowVarDims,recursive,uniform,sizelimits);
        end
    end
end
function sz=scalarExpandTableSize(sz,default)
    if isempty(sz)
        sz=default;
    elseif isscalar(sz)
        sz=repmat(sz,[1,2]);
    else
        coder.internal.assert(numel(sz)==2,'Coder:common:Table2D');
    end
end
