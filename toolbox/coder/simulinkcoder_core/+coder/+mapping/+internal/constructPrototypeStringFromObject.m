function proto=constructPrototypeStringFromObject(modelName,isCpp,funcObj,varargin)




    convertToBlockName=false;
    convertToSid=false;
    externalPrototype='';
    if nargin>=4
        convertToBlockName=isequal(varargin{1},'SidToBlockName');
        convertToSid=isequal(varargin{1},'BlockNameToSid');
        if nargin>=5
            externalPrototype=varargin{2};
        end
    end

    hasArguments=~isempty(funcObj.returnArguments)||...
    ~isempty(funcObj.arguments);

    proto='';
    space=' ';

    if~isempty(funcObj.returnArguments)
        if length(funcObj.returnArguments)>1
            DAStudio.error('RTW:codeGen:MultipleReturnArgs',externalPrototype);
        end

        retArg=funcObj.returnArguments{1};
        qualifier=getQualifierString(retArg);
        tempSpace='';
        if~isempty(qualifier)
            proto=[proto,qualifier,space];
            tempSpace=' ';
        end
        passBy=getPassByString(retArg);
        if~isempty(passBy)
            proto=[proto,tempSpace,passBy,space];
        end

        if~isempty(retArg.mappedFrom)
            retUserMappedFrom=retArg.mappedFrom{1};
        else
            retUserMappedFrom=retArg.name;
        end
        if~isempty(qualifier)&&(convertToBlockName||convertToSid)



            DAStudio.error('RTW:fcnClass:outportConst',retUserMappedFrom)
        end
        if convertToBlockName

            retMappedFrom=getBlockNameFromSid(modelName,retUserMappedFrom);
            proto=[proto,retMappedFrom,space];
        elseif convertToSid

            [retMappedFrom,blockType]=getSidFromBlockName(modelName,retUserMappedFrom);
            if~isequal(blockType,'Outport')

                DAStudio.error('coderdictionary:api:InportAsReturnArgument',retUserMappedFrom)
            end
            proto=[proto,retMappedFrom,space];
        elseif~isempty(retArg.mappedFrom)

            proto=[proto,retUserMappedFrom,space];
        end

        proto=[proto,retArg.name,space,'=',space];
    end


    fcnName=funcObj.name;
    if~isempty(fcnName)
        proto=[proto,fcnName];
    end


    comma='';
    proto=[proto,'('];
    for arg=funcObj.arguments
        qualifier=getQualifierString(arg{1});
        proto=[proto,comma];%#ok<*AGROW>
        tempSpace='';
        if~isempty(qualifier)
            proto=[proto,qualifier,space];
            tempSpace=' ';
        end
        passBy=getPassByString(arg{1});
        if~isempty(passBy)
            proto=[proto,tempSpace,passBy,space];
        end
        if~isempty(arg{1}.mappedFrom)
            argUserMappedFrom=arg{1}.mappedFrom{1};
        else
            argUserMappedFrom=arg{1}.name;
        end
        if convertToBlockName

            argMappedFrom=getBlockNameFromSid(modelName,argUserMappedFrom);
            proto=[proto,argMappedFrom,space];
        elseif convertToSid

            [argMappedFrom,blockType]=getSidFromBlockName(modelName,argUserMappedFrom);
            if isequal(blockType,'Outport')&&~isempty(qualifier)

                DAStudio.error('RTW:fcnClass:outportConst',argUserMappedFrom)
            end
            proto=[proto,argMappedFrom,space];
        elseif~isempty(arg{1}.mappedFrom)

            proto=[proto,argUserMappedFrom,space];
        end
        proto=[proto,arg{1}.name];
        comma=', ';
    end
    proto=[proto,')'];

    if~hasArguments
        if isequal(fcnName,'USE_DEFAULT_FROM_FUNCTION_CLASSES')
            fcnName='';
        end
        proto=fcnName;
    end


    function qualifier=getQualifierString(arg)
        qualifier='';
        switch arg.qualifier
        case coder.parser.Qualifier.Const
            qualifier='const';
        case coder.parser.Qualifier.ConstPointer
            qualifier='const *';
        case coder.parser.Qualifier.ConstPointerToConstData
            qualifier='const * const';
        end
    end


    function passBy=getPassByString(arg)
        passBy='';
        switch arg.passBy
        case coder.parser.PassByEnum.Pointer
            if~isequal(arg.qualifier,coder.parser.Qualifier.ConstPointerToConstData)
                passBy='*';
            end
        case coder.parser.PassByEnum.Reference
            passBy='&';
            if~isCpp
                DAStudio.error('coderdictionary:api:ReferenceNotSupportedForC',...
                arg.name);
            end
        end
    end



    function blockName=getBlockNameFromSid(modelName,argName)
        try
            blockName=get_param([modelName,':',argName],'Name');
        catch

            DAStudio.error('coderdictionary:api:NoBlockForArgument',...
            modelName,argName)
        end
        if~isvarname(blockName)


            DAStudio.error('coderdictionary:api:InvalidBlockNameForArgument',...
            modelName,blockName)
        end
    end



    function[compactSID,blockType]=getSidFromBlockName(modelName,argName)
        try
            modelSidPrefix=[modelName,':'];
            modelPathPrefix=[modelName,'/'];
            fullSID=Simulink.ID.getSID([modelPathPrefix,argName]);
            compactSID=strrep(fullSID,modelSidPrefix,'');
            blockType=get_param(fullSID,'BlockType');
        catch

            DAStudio.error('coderdictionary:api:NoBlockForArgument',...
            modelName,argName)
        end
    end

end
