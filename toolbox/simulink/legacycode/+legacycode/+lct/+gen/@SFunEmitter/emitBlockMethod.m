



function emitBlockMethod(this,codeWriter,funSpec,canAllocPWork,canDeallocPWork)


    if nargin<5
        canDeallocPWork=false;
    end
    if nargin<4
        canAllocPWork=false;
    end


    assert((canAllocPWork&&canDeallocPWork)==false);
    isStartOrTerminate=canAllocPWork||canDeallocPWork;

    if this.LctSpecInfo.Specs.Options.stubSimBehavior
        return
    end


    specHasNDArrayArg=false;
    if this.LctSpecInfo.hasBusOrStruct||this.LctSpecInfo.hasRowMajorNDArray
        if this.LctSpecInfo.hasRowMajorNDArray


            specHasNDArrayArg=funSpec.HasNDArrayArg;
        end


        codeWriter.wBlockStart('if (IS_SIMULATION_TARGET(S))');
    end


    specHasDynamicArrayArg=false;
    if this.LctSpecInfo.hasDynamicArrayAggregate||funSpec.HasDynamicArrayArg

        specHasDynamicArrayArg=funSpec.HasDynamicArrayOutputArg;
        if specHasDynamicArrayArg
            codeWriter.wBlockStart();
            this.LctSpecInfo.Outputs.forEachData(@(o,id,d)setOutputCurrentDims(this,d,codeWriter));
            codeWriter.wBlockEnd();
        end



        if~isStartOrTerminate&&this.HasBusInfoToRegister&&...
            this.LctSpecInfo.hasBusOrStruct&&...
            (this.LctSpecInfo.hasDynamicArrayAggregate||funSpec.HasDynamicArrayArg)
            specHasDynamicArrayArg=true;
            codeWriter.wBlockStart();


            emitLocalsForStructInfo(this,codeWriter);


            emitTypeAndBusInformationExtraction(this,codeWriter);


            emitPWorkAllocateDeallocate(this,codeWriter,true,true);

            codeWriter.wBlockEnd();
        end


        if specHasDynamicArrayArg
            codeWriter.wBlockStart();
        end
    end

    if this.LctSpecInfo.hasBusOrStruct

        this.emitLocalsForStructInfo(codeWriter);


        if canAllocPWork&&this.HasBusInfoToRegister

            emitTypeAndBusInformationExtraction(this,codeWriter);


            emitPWorkAllocateDeallocate(this,codeWriter,true);
        end
    end

    if funSpec.IsSpecified
        if(canAllocPWork||canDeallocPWork)&&this.HasBusInfoToRegister

            codeWriter.wBlockStart();
        end


        this.emitLocalsForFunCall(codeWriter,funSpec);

        if this.LctSpecInfo.hasRowMajorNDArray&&specHasNDArrayArg

            this.emitLocalsForNDMarshaling(codeWriter,funSpec);
        end

        if this.LctSpecInfo.hasBusOrStruct

            this.emitLocalsForStructMarshaling(codeWriter,funSpec);


            this.emitStructConversion(codeWriter,funSpec,true);
        end

        if this.LctSpecInfo.hasRowMajorNDArray&&specHasNDArrayArg

            this.emitNDArrayConversion(codeWriter,funSpec,true);
        end


        this.emitFunCall(codeWriter,funSpec);

        if this.LctSpecInfo.hasRowMajorNDArray&&specHasNDArrayArg

            this.emitNDArrayConversion(codeWriter,funSpec,false);
        end

        if this.LctSpecInfo.hasBusOrStruct

            this.emitStructConversion(codeWriter,funSpec,false);
        end


        this.emitPWorkUpdate(codeWriter,funSpec);

        if(canAllocPWork||canDeallocPWork)&&this.HasBusInfoToRegister

            codeWriter.wBlockEnd();
        end
    end


    if this.LctSpecInfo.hasBusOrStruct


        if canDeallocPWork&&this.HasBusInfoToRegister
            emitPWorkAllocateDeallocate(this,codeWriter,false);
        end
    end

    if specHasDynamicArrayArg

        codeWriter.wBlockEnd();


        if~isStartOrTerminate&&funSpec.HasDynamicArrayArg
            codeWriter.wBlockStart();
            emitPWorkAllocateDeallocate(this,codeWriter,false,true);
            codeWriter.wBlockEnd();
        end
    end

    if this.LctSpecInfo.hasBusOrStruct||this.LctSpecInfo.hasRowMajorNDArray

        codeWriter.wBlockEnd();
    end

end


function emitTypeAndBusInformationExtraction(this,codeWriter)

    codeWriter.wNewLine;
    codeWriter.wCmt('Get common data type Id');
    for ii=1:numel(this.LctSpecInfo.DataTypes.BusInfo.DataTypeSizeTable)

        dtName=this.LctSpecInfo.DataTypes.BusInfo.DataTypeSizeTable{ii};
        if~isempty(regexp(dtName,'^u?int64$','once'))
            codeWriter.wLine('DTypeId __%sId = ssRegisterDataTypeFxpBinaryPoint(S, %d, 64, 0, 1);',...
            dtName,dtName(1)~='u');
        else
            codeWriter.wLine('DTypeId __%sId = ssGetDataTypeId(S, "%s");',...
            dtName,dtName);
        end
    end
    codeWriter.wNewLine;

    codeWriter.wCmt('Get common data type size');
    for ii=1:numel(this.LctSpecInfo.DataTypes.BusInfo.DataTypeSizeTable)
        codeWriter.wLine('__dtSizeInfo[%d] = ssGetDataTypeSize(S, __%sId);',...
        ii-1,this.LctSpecInfo.DataTypes.BusInfo.DataTypeSizeTable{ii});
    end
    codeWriter.wNewLine;


    for ii=1:size(this.LctSpecInfo.DataTypes.BusInfo.BusElementHashTable,1)
        codeWriter.wCmt('Get information for accessing %s',this.LctSpecInfo.DataTypes.BusInfo.BusElementHashTable{ii,2}.PathStr);
        codeWriter.wLine('__dtBusInfo[%d] = %s;',...
        this.LctSpecInfo.DataTypes.BusInfo.BusElementHashTable{ii,2}.OffsetIdx,...
        this.LctSpecInfo.DataTypes.BusInfo.BusElementHashTable{ii,2}.OffsetStr);

        codeWriter.wLine('__dtBusInfo[%d] = %s;',...
        this.LctSpecInfo.DataTypes.BusInfo.BusElementHashTable{ii,2}.SizeIdx,...
        this.LctSpecInfo.DataTypes.BusInfo.BusElementHashTable{ii,2}.SizeStr);

        codeWriter.wNewLine;
    end

end


function emitPWorkAllocateDeallocate(this,codeWriter,forAlloc,forDynArray)

    if nargin<4
        forDynArray=false;
    end

    codeWriter.wNewLine;
    for ii=1:this.LctSpecInfo.DWorksForBus.Numel

        dWork=this.LctSpecInfo.DWorksForBus.Items(ii);
        dWorkIdx=this.LctSpecInfo.DWorksInfo.NumPWorks+ii-1;
        dataType=this.LctSpecInfo.DataTypes.Items(dWork.DataTypeId);
        typeName=dataType.DTName;



        specData=dWork.BusInfo.Data;
        isDynamicArray=specData.IsDynamicArray;
        if(forDynArray&&~isDynamicArray)||(~forDynArray&&isDynamicArray)
            continue
        end


        apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dWork.BusInfo.Data,'sfun');
        dWorkName=apiInfo.CVarWBusName;

        if forAlloc
            type='Alloc';
        else
            type='Free';
        end
        codeWriter.wCmt('%s memory for the pwork %d (%s)',type,dWorkIdx+1,dWorkName);

        dwDecl=sprintf('%s* %s',typeName,dWorkName);
        codeWriter.wBlockStart();
        if forAlloc
            codeWriter.wLine('%s = (%s*)calloc(sizeof(%s), %s);',dwDecl,typeName,typeName,apiInfo.Width);
            codeWriter.wBlockStart('if (%s==NULL)',dWorkName);
            codeWriter.wLine('ssSetErrorStatus(S, "Unexpected error during the memory allocation for %s");',dWorkName);
            codeWriter.wLine('return;');
            codeWriter.wBlockEnd();
            codeWriter.wLine('ssSetPWorkValue(S, %d, %s);',dWorkIdx,dWorkName);
        else
            codeWriter.wLine('%s = (%s*)ssGetPWorkValue(S, %d);',dwDecl,typeName,dWorkIdx);
            codeWriter.wBlockStart('if (%s!=NULL)',dWorkName);
            codeWriter.wLine('free(%s);',dWorkName);
            codeWriter.wLine('ssSetPWorkValue(S, %d, NULL);',dWorkIdx);
            codeWriter.wBlockEnd();
        end
        codeWriter.wBlockEnd();
        codeWriter.wNewLine;
    end

end


function setOutputCurrentDims(this,dataSpec,codeWriter)

    if dataSpec.IsDynamicArray
        codeWriter.wCmt('Set output port %d current dimension',dataSpec.Id);

        dimStr=legacycode.lct.gen.ExprSFunEmitter.emitAllDims(this.LctSpecInfo,dataSpec,'');


        for ii=1:numel(dimStr)
            codeWriter.wLine('ssSetCurrentOutputPortDimensions(S,  %d, %d, (int_T)(%s));',...
            dataSpec.Id-1,ii-1,dimStr{ii});
        end
    end

end


