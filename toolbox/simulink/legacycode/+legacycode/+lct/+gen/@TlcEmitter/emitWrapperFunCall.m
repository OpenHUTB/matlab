



function emitWrapperFunCall(this,codeWriter,funSpec,funKind)


    dataTypeTable=this.LctSpecInfo.DataTypes;


    argList={};
    dynamicArrayInfoArgList={};
    funSpec.forEachArg(@(f,a)addArg(a));




    argList=[argList,dynamicArrayInfoArgList];


    callStr=sprintf('%s_wrapper_%s(%s);',...
    this.LctSpecInfo.Specs.SFunctionName,funKind,strjoin(argList,', '));
    codeWriter.wLine(callStr);

    function addArg(argSpec)

        dataSpec=argSpec.Data;
        dataType=dataTypeTable.Items(dataSpec.DataTypeId);





        hasObject=~isempty(dataType.HeaderFile);
        suffix='_val';
        if argSpec.IsReturn||hasObject||~argSpec.PassedByValue
            suffix='_ptr';
        end



        castStr='';
        if dataSpec.isExprArg()&&~hasObject



            dataType=dataTypeTable.getTypeForDeclaration(dataType);
            castStr=sprintf('(%s)',dataType.Name);
        end

        isAggregateType=dataTypeTable.isAggregateType(dataType);
        isParameterSpecialCase=dataSpec.isParameter()&&...
        ~isAggregateType&&hasObject&&argSpec.PassedByValue;

        if isParameterSpecialCase



            argList{end+1}=sprintf('(void *)&%s_val',dataSpec.Identifier);
        elseif dataSpec.isExprArg()&&hasObject

            argList{end+1}=sprintf('(void *)&%s_val',dataSpec.Identifier);
        else
            if dataSpec.IsDynamicArray
                argList{end+1}=sprintf('%s(%%<%s%s>)->data()',castStr,dataSpec.Identifier,suffix);
                if isAggregateType
                    dynamicArrayInfoArgList{end+1}=sprintf('(int_T)((%%<%s%s>)->numel())',dataSpec.Identifier,suffix);
                end
            else
                argList{end+1}=sprintf('%s%%<%s%s>',castStr,dataSpec.Identifier,suffix);
            end
        end


        apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'tlc');


        if isAggregateType
            argList{end+1}=sprintf('%%<%s_ptr>',apiInfo.WBusName);
        end


        if dataSpec.CArrayND.DWorkIdx>0
            argList{end+1}=sprintf('%%<%s_ptr>',apiInfo.WANDName);
        end
    end
end
