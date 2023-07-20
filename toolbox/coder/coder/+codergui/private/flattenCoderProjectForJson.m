function out=flattenCoderProjectForJson(coderProject)






    out=doFlatten(coderProject);
end

function out=doFlatten(arg)
    out=codergui.internal.flattenForJson(arg,true,...
    'AnnotateFieldOrder',true,...
    'AnnotateObjectClass',true,...
    'CustomObjectSerializer',@customSerializeSomeTypes,...
    'ObjectAugmentor',@augmentSerializableTypes);
end

function out=augmentSerializableTypes(type,out)
    switch class(type)
    case 'coder.CellType'
        out=cellAugmentor(type,out);
    case 'coder.FiType'
        out=useCurrentFimath(type,out);
    otherwise
        out=[];
    end
end

function out=customSerializeSomeTypes(obj)
    if isa(obj,'coder.Constant')


        out.ClassName=obj.ClassName;
        out.ValueType=doFlatten(coder.typeof(obj.Value));
    elseif isa(obj,'coder.internal.MxArrayConstant')
        out.ClassName=obj.ClassName;
        value=obj.Value;
        out.ValueType=struct(...
        'MatlabType__',class(obj),...
        'ClassName',class(value),...
        'SizeVector',size(value),...
        'VariableDims',[]);
    elseif isa(obj,'coder.CellType')&&obj.isHomogeneous()&&numel(obj.Cells)>1

        obj.Cells=obj.Cells(1);
        out=doFlatten(obj);
    elseif isa(obj,'coder.type.Base')

        out=doFlatten(obj.getCoderType());
    else
        out=[];
    end
end

function out=cellAugmentor(cellType,out)
    out.Homogenous=cellType.isHomogeneous();
    if cellType.isHeterogeneous()
        out.CellSubscripts=zeros(numel(cellType.Cells),numel(cellType.SizeVector));
        tempSubscripts=cell(size(cellType.SizeVector));
        for i=1:numel(cellType.Cells)
            [tempSubscripts{:}]=ind2sub(cellType.SizeVector,i);
            out.CellSubscripts(i,:)=cell2mat(tempSubscripts);
        end
    end
end

function out=useCurrentFimath(fiType,out)



    if isempty(fiType.Fimath)
        out.Fimath=fimath();
    else
        out=[];
    end
end