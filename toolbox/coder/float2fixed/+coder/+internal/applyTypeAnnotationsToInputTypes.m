function newTypes=applyTypeAnnotationsToInputTypes(origTypes,T,designName)
    fileNameWithPath=which(designName);
    fcnMTree=coder.internal.translator.F2FMTree(fileNameWithPath,'-file');
    [inVars,~]=coder.internal.MTREEUtils.getFcnInputOutputParamNames(fileNameWithPath,fcnMTree.root);

    if~iscell(origTypes)

        if isa(origTypes,'coder.Type')
            origTypesTmp={};
            for ii=1:numel(origTypes)
                origTypesTmp{ii}=origTypes(ii);%#ok<AGROW>
            end
            origTypes=origTypesTmp;
        else

            origTypes={origTypes};
        end
    end

    newTypes=origTypes;
    if length(origTypes)~=length(inVars)


        return;
    end

    if~isfield(T,designName)

        return;
    end


    T=T.(designName);

    for ii=1:length(inVars)
        inVarName=inVars{ii};
        origT=origTypes{ii};

        if isfield(T,inVarName)
            annotation=T.(inVarName);
            newT=applyTypeAnnotation(origT,annotation);

            newTypes{ii}=newT;
        end

    end
end


function newType=applyTypeAnnotation(origType,A)
    newType=origType;




    if iscell(origType)

        for ii=1:numel(origType)
            newType{ii}=applyTypeAnnotation(origType{ii},A{ii});
        end
    elseif~isscalar(origType)&&isa(origType,'coder.Type')

        for ii=1:numel(origType)
            newType(ii)=applyTypeAnnotation(origType(ii),A{ii});
        end

    elseif isa(origType,'coder.StructType')

        newType.Fields=applyTypeAnnotation(origType.Fields);
    elseif isstruct(origType)

        NAMES=fieldnames(origType);
        for ii=1:length(NAMES)
            fieldName=NAMES{ii};

            if isfield(A,fieldName)

                fieldType=origType.(fieldName);
                FA=A.(fieldName);
                newFieldType=applyTypeAnnotation(fieldType,FA);
                newType.(fieldName)=newFieldType;
            end
        end
    elseif islogical(origType)

        newType=origType;
    elseif isa(origType,'coder.Constant')

        newType=coder.Constant(applyTypeAnnotation(origType.Value,A));

    else

        if isnumeric(origType)
            assert(isnumeric(origType));

            newType=cast(origType,'like',A);
        else
            assert(isa(origType,'coder.Type'));
            newType=coder.typeof(coder.typeof(A),origType.SizeVector,origType.VariableDims);
        end
    end
end
