



function[lhs,fcnName,argListStr]=genWrapperPrototype(this,funSpec,funKind)



    dataTypeTable=this.LctSpecInfo.DataTypes;


    argList={};
    dynamicArrayInfoArgList={};
    funSpec.forEachArg(@(f,a)addArg(a));




    argList=[argList,dynamicArrayInfoArgList];


    if isempty(argList)
        argListStr='void';
    else
        argListStr=strjoin(argList,', ');
    end
    fcnName=[this.LctSpecInfo.Specs.SFunctionName,'_wrapper_',funKind];
    lhs='void';

    function addArg(argSpec)

        dataType=dataTypeTable.Items(argSpec.Data.DataTypeId);
        argName=argSpec.Data.Identifier;


        prefix='';
        if~isempty(dataType.HeaderFile)

            dtName='void';
            prefix='*';
        else

            if~argSpec.PassedByValue||argSpec.IsReturn
                prefix='*';
            end


            dataType=dataTypeTable.getTypeForDeclaration(dataType);
            dtName=dataType.Name;

            if argSpec.Data.IsComplex==1

                dtName=sprintf('c%s',dtName);
            end
        end


        if~argSpec.Data.isOutput()&&~argSpec.Data.isDWork()
            qualifier='const';
        else
            qualifier='';
        end


        if argSpec.Data.isDWork()&&strcmp(dataType.Name,'void')
            qualifier='';
            if~argSpec.PassedByValue
                prefix='**';
            else
                prefix='*';
            end
        end


        apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(argSpec.Data,'tlc');


        argList{end+1}=sprintf('%s %s%s %s',qualifier,dtName,prefix,argName);


        if dataType.isAggregateType()
            argList{end+1}=sprintf('void* %s',apiInfo.WBusName);
            if argSpec.Data.IsDynamicArray
                dynamicArrayInfoArgList{end+1}=sprintf('int_T %sDynamicArrayWidth',argSpec.Data.Identifier);
            end
        end


        if argSpec.Data.CArrayND.DWorkIdx>0
            argList{end+1}=sprintf('%s* %s',dtName,apiInfo.WANDName);
        end
    end
end
