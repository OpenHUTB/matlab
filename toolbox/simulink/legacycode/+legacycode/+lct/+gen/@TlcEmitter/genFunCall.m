



function[lhs,fcnName,argList]=genFunCall(this,funSpec,skipNDMarshaling)

    if nargin<3
        skipNDMarshaling=false;
    end


    dataTypeTable=this.LctSpecInfo.DataTypes;


    lhs='';
    fcnName=funSpec.Name;
    argList={};


    funSpec.forEachArg(@(f,a)addArg(a));

    function addArg(argSpec)


        dataSpec=argSpec.Data;
        dataType=dataTypeTable.Items(dataSpec.DataTypeId);


        if argSpec.PassedByValue
            suffix='_val';
        else
            suffix='_ptr';
        end


        needPtrCast=~argSpec.PassedByValue&&(numel(dataSpec.Dimensions)>1);


        needConstCast=~argSpec.PassedByValue&&~dataSpec.isOutput()&&~dataSpec.isDWork();


        dtName='';
        if needPtrCast||needConstCast

            dataType=dataTypeTable.getTypeForDeclaration(dataType);
            dtName=dataType.Name;
        end


        ptrCastStr='';
        if needPtrCast&&false
            ptrCastStr=legacycode.lct.CodeEmitter.genPtrCastForNDArg(2,dtName,dataSpec.Dimensions);
        end








        constCastStr='';
        if needConstCast
            assert(~argSpec.PassedByValue);
            optStar='*';
            if dataSpec.IsComplex


                dtName=sprintf('c%s',dtName);
            end
            constCastStr=sprintf('(%s%s)',dtName,optStar);
        end

        if dataSpec.CArrayND.DWorkIdx>0&&~skipNDMarshaling

            apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'tlc');


            optStar='';
            if argSpec.PassedByValue
                optStar='*';
            end
            argStr=sprintf('%s%s%s',optStar,ptrCastStr,apiInfo.WANDName);
        else

            if dataSpec.IsDynamicArray
                argStr=sprintf('%s%s(%%<%s%s>)->data()',ptrCastStr,constCastStr,dataSpec.Identifier,suffix);
            else
                argStr=sprintf('%s%s%%<%s%s>',ptrCastStr,constCastStr,dataSpec.Identifier,suffix);
            end
        end


        if argSpec.IsReturn
            lhs=argStr;
        else
            argList{end+1}=argStr;
        end
    end
end
