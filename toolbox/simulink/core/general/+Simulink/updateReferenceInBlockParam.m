function updateReferenceInBlockParam(blockH,prop,paramExpr,oldname,newname,varargin)










    if~isempty(varargin)
        identifier=varargin{1};
    end
    if ischar(paramExpr)
        if isDataTypeProperty(blockH,prop)
            [prefix,exprAfterPrefix]=...
            parseDataTypeProperty(paramExpr);
            exprAfterPrefix=...
            Simulink.internal.replaceID(exprAfterPrefix,oldname,newname);
            paramExpr=[prefix,exprAfterPrefix];
        else
            paramExpr=Simulink.internal.replaceID(paramExpr,oldname,newname);
        end

        blockType=get_param(blockH,'BlockType');
        if strcmp(blockType,'ModelReference')
            instParams=get_param(blockH,'InstanceParameters');
            for i=1:length(instParams)
                if isequal(instParams(i).Name,prop)
                    instParams(i).Value=paramExpr;
                end
            end
            set_param(blockH,'InstanceParameters',instParams);
        else
            set_param(blockH,prop,paramExpr);
        end

    elseif iscell(paramExpr)
        for m=1:numel(paramExpr)
            assert(ischar(paramExpr{m}));
            paramExpr{m}=Simulink.internal.replaceID(paramExpr{m},oldname,newname);
        end
        set_param(blockH,prop,paramExpr);
    elseif isstruct(paramExpr)





        switch(prop)
        case 'Variants'
            assert(isequal(prop,'Variants'));

            blockType=get_param(identifier,'BlockType');
            if isequal(blockType,'ModelReference')


                for m=1:numel(paramExpr)
                    paramExpr(m).Name=Simulink.internal.replaceID(paramExpr(m).Name,oldname,newname);
                end
                set_param(blockH,prop,paramExpr);
            elseif isequal(blockType,'SubSystem')





                for m=1:numel(paramExpr)
                    blockName=paramExpr(m).BlockName;
                    variantControl=get_param(blockName,'VariantControl');
                    variantControl=Simulink.internal.replaceID(variantControl,oldname,newname);
                    set_param(blockName,'VariantControl',variantControl);
                end
            else
                assert(false,'Unexpected Variant BlockType')
            end

        case 'ParameterArgumentValues'
            blockType=get_param(identifier,'BlockType');
            assert(strcmp(blockType,'ModelReference'));
            args=fields(paramExpr);
            for m=1:length(args)
                arg=args{m};
                paramExpr.(arg)=Simulink.internal.replaceID(paramExpr.(arg),oldname,newname);
            end
            set_param(blockH,prop,paramExpr);
        otherwise
        end
    else
        assert(false,'Unexpected type for parameter expression');
    end
end

function result=isDataTypeProperty(blk,propName)
    featureStatus=slfeature('GetFormalDlgPrmsForTestingOnly',1);
    featureCleanup=onCleanup(@()slfeature('GetFormalDlgPrmsForTestingOnly',featureStatus));
    dlgParams=get_param(blk,'DialogParameters');
    if isfield(dlgParams,propName)
        param=dlgParams.(propName);
        result=isequal(param.Type,'DataTypeStr');
    else
        result=false;
    end
end




function[prefix,remainder]=parseDataTypeProperty(paramExpr)
    assert(ischar(paramExpr));

    prefix='';
    dataTypePrefixes={'Bus:','Enum:'};
    for i=1:numel(dataTypePrefixes)
        thisPrefix=dataTypePrefixes{i};
        if strncmp(paramExpr,thisPrefix,numel(thisPrefix))
            prefix=thisPrefix;
            break;
        end
    end
    remainder=paramExpr(numel(prefix)+1:end);
end
