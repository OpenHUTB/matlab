function tree=generateDecisionTree(CC,set)







    tree=make_decision_tree(CC,set);


    needSizeCorrection=isPartitionSolelyOnVarSize(tree);



    if needSizeCorrection
        tree=growTreeWithMoreInfo(tree,set);
    end
end

function tree=make_decision_tree(CC,set)
    n=numel(set);


    if n==0
        tree=[];
        return;
    end
    if n==1
        tree=struct('leaf',set{1}.val);
        tree.idx=set{1}.idx;
        return;
    end


    [part,f,s]=find_partition(set);
    children=cell(numel(part),1);


    if strcmp(f.type,'size_string')
        sizeVector=cell(numel(part),1);
        for i=1:numel(part)
            sizeVector{i}=f.handle(part{i}{1}.val);
        end

        part=coder.internal.sort_size(part,sizeVector{:});

    end

    if strcmp(f.type,'constant')
        if isprop(CC.ConfigInfo,'ConstantInputs')&&~strcmp(CC.ConfigInfo.ConstantInputs,'CheckValues')
            error(message('Coder:configSet:UnsupportedConfigForMultiSignatureMex',CC.ConfigInfo.ConstantInputs,'ConstantInputs'));
        end
        constantVector=cell(numel(part),1);
        for i=1:numel(part)
            constantVector{i}=f.handle(part{i}{1}.val);
        end
        part=sort_constants(part,constantVector);
    end


    for i=1:numel(part)

        subtree=make_decision_tree(CC,part{i});

        children{i}=struct('key',f.handle(part{i}{1}.val),'type',f.type,'tree',subtree);
    end

    tree=struct('check',s,'match',{children});
end

function[part,f,s]=find_partition(set)
    type_set=cell(1,numel(set));
    for i=1:numel(set)
        type_set{i}=set{i}.val;
    end

    [f,s]=first_difference(type_set,false);




    if isfield(s,'subcondition')&&strcmp(s.subcondition.condition,'ConditionType_SizeLength')
        if isfield(s,'action')


            argIdx=s.action+1;
            nthArgTypeCell=cellfun(@(x)x.(strcat('fInput',num2str(argIdx))),type_set,'UniformOutput',false);
            sizeInfo=cellfun(@(x)coder.internal.size_string(x),nthArgTypeCell,'UniformOutput',false);



            newSet=createSetWith2DSize(sizeInfo,set,argIdx);


            for i=1:numel(newSet)
                set{end+1}=newSet{i};%#ok<AGROW>
            end
        end

    end


    part=partition(set,f.handle);
end

function part=partition(set,f)

    type_set=cell(1,numel(set));
    for i=1:numel(set)
        type_set{i}=set{i}.val;
    end
    part={{}};
    R=cellfun(f,type_set,'UniformOutput',false);

    visited=false(numel(R),1);
    binNum=0;
    for ii=1:numel(R)
        if~visited(ii)
            binNum=binNum+1;
            part{binNum}={};
            part{binNum}{end+1}=set{ii};
            visited(ii)=true;

            for jj=(ii+1):numel(R)
                if isequaln(R{ii},R{jj})
                    part{binNum}{end+1}=set{jj};
                    visited(jj)=true;
                end
            end
        end

    end
end

function[f,s]=first_difference(set,isOverlapAllowed)
    if numel(set)<2
        f.handle=@(x)false;
        f.type='bool';
        s='false';
        return
    end


    if isa(set{1},'struct')
        [f,s]=first_difference_input(set);
        return
    end

    domain=cellfun(@(x)(isa(x,'coder.Constant')),set,'UniformOutput',true);
    if any(domain)
        [f,s]=first_difference_constant(set);
        return
    end


    domain=cellfun(@(x)x.ClassName,set,'UniformOutput',false);
    if~isequal(domain{:})
        f.handle=@(x)x.ClassName;
        f.type='string';
        s.condition='ConditionType_ClassName';
        return
    end


    domain=cellfun(@(x)length(x.SizeVector),set,'UniformOutput',false);
    if~isequal(domain{:})
        f.handle=@(x)length(x.SizeVector);
        f.type='numeric';
        s.condition='ConditionType_SizeLength';
        return
    end


    domain=cellfun(@(x)coder.internal.size_string(x),set,'UniformOutput',false);
    if~coder.internal.isFixedSize(domain{:})
        f.handle=@(x)coder.internal.size_string(x);
        f.type='size_string';
        s.condition='ConditionType_Size';
        return
    end


    domain=cellfun(@(x)coder.internal.isComplex(x),set,'UniformOutput',false);
    if~isequal(domain{:})
        f.handle=@(x)coder.internal.isComplex(x);
        f.type='bool';
        s.condition='ConditionType_Complexity';
        return
    end

    domain=cellfun(@(x)isSparse(x),set,'UniformOutput',false);
    if~isequal(domain{:})
        f.handle=@(x)isSparse(x);
        f.type='bool';
        s.condition='ConditionType_Sparse';
        return
    end


    domain_size=cellfun(@(x)coder.internal.size_string(x),set,'UniformOutput',false);
    if~isequal(domain_size{:})

        isOverlap=coder.internal.isVarSizeOverlap(set);

        if~isOverlap||isOverlapAllowed

            f.handle=@(x)coder.internal.size_string(x);
            f.type='size_string';
            s.condition='ConditionType_Size';
            return
        end
    end


    cls=set{1}.ClassName;
    if strcmp(cls,'cell')
        [f,s]=first_difference_cell(set,isOverlapAllowed);
    elseif strcmp(cls,'struct')
        [f,s]=first_difference_struct(set,isOverlapAllowed);
    elseif isa(set{1},'coder.ClassType')
        [f,s]=first_difference_classdef(set,isOverlapAllowed);
    elseif isa(set{1},'coder.FiType')
        [f,s]=first_difference_fitype(set);
    else
        if(isOverlapAllowed)
            error(message('Coder:configSet:UnsupportedClassForMultiSignatureMex',class(set{1})));
        end
        f=[];
        s=[];
    end
end

function[f,s]=first_difference_cell(set,isOverlapAllowed)

    domain=cellfun(@(x)x.isHeterogeneous(),set,'UniformOutput',false);
    if~isequal(domain{:})
        f.handle=@(x)x.isHeterogeneous();
        f.type='bool';
        s.condition='ConditionType_Heterogeneous';
        return
    end


    domain=cellfun(@(x)numel(x.Cells),set,'UniformOutput',false);


    if~isequal(domain{:})
        f.handle=@(x)numel(x.Cells);
        f.type='numeric';
        s.condition='ConditionType_NumCellElements';
        return;
    end


    for i=1:numel(set{1}.Cells)
        domain=cellfun(@(x)x.Cells{i},set,'UniformOutput',false);

        condition=~isequal(domain{:});

        if coder.internal.isVarSizeOverlap(domain)&&~isOverlapAllowed





            domainNormalized=cellfun(@(x)normalizeType(x),domain,'UniformOutput',false);
            condition=~isequal(domainNormalized{:});
        end

        if condition
            [f1,s1]=first_difference(domain,isOverlapAllowed);
            if(isempty(f1)||isempty(s1))
                continue;
            end
            f.handle=@(x)f1.handle(x.Cells{i});
            f.type=f1.type;
            s.condition='ConditionType_Cell';
            s.action=i-1;
            s.subcondition=s1;
            return
        end
    end


    f=[];
    s=[];
end

function[f,s]=first_difference_struct(set,isOverlapAllowed)


    domain=cellfun(@(x)numel(fieldnames(x.Fields)),set,'UniformOutput',false);
    if~isequal(domain{:})
        f.handle=@(x)numel(fieldnames(x.Fields));
        f.type='numeric';
        s.condition='ConditionType_NumStructFields';
        return;
    end

    numNames=domain{1};
    for i=1:numNames
        domain=cellfun(@(x)coder.internal.getfieldname(x.Fields,i),set,'UniformOutput',false);
        if~isequal(domain{:})
            f.handle=@(x)coder.internal.getfieldname(x.Fields,i);
            f.type='string';
            s.condition='ConditionType_StructFieldName';
            s.action=i-1;
            return;
        end
    end


    fieldNames=fieldnames(set{1}.Fields);
    for i=1:numNames
        name=fieldNames{i};
        domain=cellfun(@(x)x.Fields.(name),set,'UniformOutput',false);

        condition=~isequal(domain{:});

        if coder.internal.isVarSizeOverlap(domain)&&~isOverlapAllowed





            domainNormalized=cellfun(@(x)normalizeType(x),domain,'UniformOutput',false);
            condition=~isequal(domainNormalized{:});
        end


        if condition
            [f1,s1]=first_difference(domain,isOverlapAllowed);
            if(isempty(f1)||isempty(s1))
                continue;
            end
            f.handle=@(x)f1.handle(x.Fields.(name));
            f.type=f1.type;

            s.condition='ConditionType_StructField';
            s.action=name;
            s.subcondition=s1;

            return;
        end
    end


    f=[];
    s=[];
end

function[f,s]=first_difference_classdef(set,isOverlapAllowed)
    domain=cellfun(@(x)(x.ClassName),set,'UniformOutput',false);
    if~isequal(domain{:})
        f.handle=@(x)(x.ClassName);
        f.type='string';
        s.condition='ConditionType_ClassName';
        return;
    end
    domain=cellfun(@(x)numel(fieldnames(x.Properties)),set,'UniformOutput',false);
    if~isequal(domain{:})
        f.handle=@(x)numel(fieldnames(x.Properties));
        f.type='numeric';
        s.condition='ConditionType_NumProperties';
        return;
    end
    numNames=domain{1};
    for i=1:numNames
        domain=cellfun(@(x)coder.internal.getfieldname(x.Properties,i),set,'UniformOutput',false);
        if~isequal(domain{:})
            f.handle=@(x)coder.internal.getfieldname(x.Properties,i);
            f.type='string';
            s.condition='ConditionType_PropertyName';
            s.action=i;
            return;
        end
    end

    domain=cellfun(@(x)(x.RedirectedClass),set,'UniformOutput',false);
    if~isequal(domain{:})
        f.handle=@(x)(x.RedirectedClass);
        f.type='string';
        s.condition='ConditionType_RedirectedClassName';
        return;
    end

    fieldNames=fieldnames(set{1}.Properties);
    for i=1:numNames
        name=fieldNames{i};
        domain=cellfun(@(x)x.Properties.(name),set,'UniformOutput',false);
        if~isequal(domain{:})
            [f1,s1]=first_difference(domain,isOverlapAllowed);
            if(isempty(f1)||isempty(s1))
                continue;
            end
            f.handle=@(x)f1.handle(x.Properties.(name));
            f.type=f1.type;
            s.condition='ConditionType_Property';
            s.action=name;
            s.subcondition=s1;
            return;
        end
    end


    f=[];
    s=[];
end

function[f,s]=first_difference_fitype(set)

    domain=cellfun(@(x)(x.Complex),set,'UniformOutput',false);
    if~isequal(domain{:})
        f.handle=@(x)(x.Complex);
        f.type='bool';
        s.condition='ConditionType_FiComplex';
        return;
    end

    if~isequal(set{:})
        f.handle=@(x)(struct('fimath',x.Fimath,'numerictype',x.NumericType));
        f.type='fitype';
        s.condition='ConditionType_FiType';
        return;
    end

    f=[];
    s=[];
end

function[f,s]=first_difference_input(set)

    domain=cellfun(@(x)numel(fieldnames(x)),set,'UniformOutput',false);
    if~isequal(domain{:})
        f.handle=@(x)numel(fieldnames(x));
        f.type='numeric';
        s.condition='ConditionType_NumRuntimeArgs';
        return
    end

    fieldNames=fieldnames(set{1});

    nFields=numel(fieldNames);

    isOverlapAllowed=false;






    nTry=2;
    for tryIter=1:nTry
        for i=1:nFields
            name=fieldNames{i};
            domain=cellfun(@(x)x.(name),set,'UniformOutput',false);
            condition=~isequal(domain{:});

            if coder.internal.isVarSizeOverlap(domain)&&~isOverlapAllowed





                domainNormalized=cellfun(@(x)normalizeType(x),domain,'UniformOutput',false);
                condition=~isequal(domainNormalized{:});
            end

            if condition
                [f1,s1]=first_difference(domain,isOverlapAllowed);
                if(isempty(f1)||isempty(s1))
                    continue;
                end
                f.handle=@(x)f1.handle(x.(name));
                f.type=f1.type;
                s.condition='ConditionType_ExtractRuntimeArg';
                s.action=i-1;
                s.subcondition=s1;
                return;
            end
        end




        isOverlapAllowed=true;
    end

    error(message('Coder:configSet:Invalid_MultiSignatureMexSignature'));

end

function[f,s]=first_difference_constant(set)

    domain=cellfun(@(x)(getConstValue(x)),set,'UniformOutput',false);
    if~isequal(domain{:})
        f.handle=@(x)(getConstValue(x));
        f.type='constant';
        s.condition='ConditionType_Constant';
        return;
    end


    f=[];
    s=[];
end

function val=getConstValue(aConst)
    val=struct('Value',[],'Type',[],'IsConst',false);
    if(isa(aConst,'coder.Constant'))
        val.Value=aConst.Value;
        val.IsConst=true;
        val.Type=coder.typeof(aConst.Value);
        return
    end
end

function sortedPart=sort_constants(part,constantVector)

    sortedPart=part;
    idx=-1;
    for i=1:numel(constantVector)
        if~(constantVector{i}.IsConst)
            idx=i;
            break;
        end
    end
    if idx>0
        sortedPart(idx)=[];
        sortedPart{end+1}=part{idx};
    end

end

function sparse=isSparse(aType)
    sparse=false;
    if(isa(aType,'coder.PrimitiveType'))
        sparse=aType.Sparse;
    end

end

function normalizedType=normalizeType(aType)
    if(isa(aType,'coder.CellType')&&(aType.isHeterogeneous))||isa(aType,'coder.ClassType')
        normalizedType=aType;
    else
        normalizedType=coder.resize(aType,[1,1]);
    end
end

function flag=isPartitionSolelyOnVarSize(tree)









    flag=false;

    if isfield(tree,'leaf')

        return;
    end

    match=tree.match;
    for i=1:numel(match)
        matchNode=match{i};
        if isequal(matchNode.type,'size_string')&&any(matchNode.key.VariableDims)&&isfield(matchNode.tree,'leaf')
            flag=true;
            return
        end

        flag=flag||isPartitionSolelyOnVarSize(matchNode.tree);
    end
end

function tree=growTreeWithMoreInfo(tree,set)







    numInputs=numel(fieldnames(set{1}.val));
    inputStruct=cellfun(@(x)(x.val),set,'UniformOutput',true);
    nThInputTypeCell={inputStruct(:).(strcat('fInput',num2str(numInputs)))};

    hasSizeInfo=cellfun(@(x)isprop(x,'SizeVector'),nThInputTypeCell);



    if~all(hasSizeInfo)
        return;
    end

    sizeInfoCell=cellfun(@(x)coder.internal.size_string(x),nThInputTypeCell,'UniformOutput',false);

    subtree.check.condition='ConditionType_ExtractRuntimeArg';
    subtree.check.action=numInputs-1;
    subtree.check.subcondition.condition='ConditionType_Size';


    if isfield(tree,'leaf')
        return;
    end

    match=tree.match;
    for i=1:numel(match)
        matchNode=match{i};
        if isequal(matchNode.type,'size_string')&&any(matchNode.key.VariableDims)&&isfield(matchNode.tree,'leaf')
            currIdx=matchNode.tree.idx;
            k=1;
            for j=currIdx:numel(set)
                subtree.match{k}.type='size_string';
                subtree.match{k}.key=sizeInfoCell{j};
                subtree.match{k}.tree=struct('leaf',set{j}.val,'idx',j);
                k=k+1;
            end
            tree.match{i}.tree=subtree;
            continue;
        end
        tree.match{i}.tree=growTreeWithMoreInfo(tree.match{i}.tree,set);
    end


end

function newSet=createSetWith2DSize(sizeInfo,set,argIdx)




    newSet={};
    k=1;
    for i=1:numel(sizeInfo)
        SizeVector=sizeInfo{i}.SizeVector;
        VariableDims=sizeInfo{i}.VariableDims;



        if(numel(VariableDims)>2)&&all(VariableDims(2:end))
            trimmedSizeVector=SizeVector(1:2);
            trimmedVariableDims=VariableDims(1:2);

            newSet{k}=set{i};%#ok<AGROW>
            newSet{k}.val.(strcat('fInput',num2str(argIdx)))=coder.resize(set{i}.val.(strcat('fInput',num2str(argIdx))),trimmedSizeVector,trimmedVariableDims);%#ok<AGROW>
            k=k+1;
        end
    end
end