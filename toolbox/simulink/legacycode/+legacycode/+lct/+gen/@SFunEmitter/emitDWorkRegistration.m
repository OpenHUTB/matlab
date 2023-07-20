



function typeIdSet=emitDWorkRegistration(this,codeWriter,typeIdSet)

    if nargin<3

        typeIdSet=containers.Map('KeyType','uint32','ValueType','logical');
    end

    codeWriter.wNewLine;
    codeWriter.wCmt('Set the number of work vectors');





    numDWorks=this.LctSpecInfo.DWorksInfo.NumDWorks;
    numDWorksBus=this.LctSpecInfo.DWorksForBus.Numel;
    numPWorks=this.LctSpecInfo.DWorksInfo.NumPWorks;
    totalNumDWorks=this.LctSpecInfo.TotalNumDWorks;

    numDWorksForNDArray=this.LctSpecInfo.hasRowMajorNDArray*this.LctSpecInfo.DWorksForNDArray.Num;


    if this.LctSpecInfo.hasBusOrStruct==false||this.LctSpecInfo.Specs.Options.stubSimBehavior

        codeWriter.wLine('if (!ssSetNumDWork(S, %s)) return;',...
        genTotalNumDWorksStr(totalNumDWorks,numDWorksForNDArray,0));
        codeWriter.wLine('ssSetNumPWork(S, %d);',numPWorks);
    else

        codeWriter.wBlockStart('if (!IS_SIMULATION_TARGET(S))');
        codeWriter.wLine('ssSetNumPWork(S, %d);',numPWorks);
        codeWriter.wLine('if (!ssSetNumDWork(S, %s)) return;',...
        genTotalNumDWorksStr(totalNumDWorks,numDWorksForNDArray,-2));
        codeWriter.decIndent;
        codeWriter.wLine('} else {');
        codeWriter.incIndent;
        codeWriter.wLine('ssSetNumPWork(S, %d);',numPWorks+numDWorksBus);
        codeWriter.wLine('if (!ssSetNumDWork(S, %d)) return;',totalNumDWorks);
        codeWriter.wNewLine;


        dataIdx=totalNumDWorks-2;
        dataWidth=numel(this.LctSpecInfo.DataTypes.BusInfo.DataTypeSizeTable);
        codeWriter.wCmt('Configure the dwork %d (__dtSizeInfo)',dataIdx+1);
        codeWriter.wLine('ssSetDWorkDataType(S, %d, SS_INT32);',dataIdx);
        codeWriter.wLine('ssSetDWorkUsageType(S, %d, SS_DWORK_USED_AS_DWORK);',dataIdx);
        codeWriter.wLine('ssSetDWorkName(S, %d, "dtSizeInfo");',dataIdx);
        codeWriter.wLine('ssSetDWorkWidth(S, %d, %d);',dataIdx,dataWidth);
        codeWriter.wLine('ssSetDWorkComplexSignal(S, %d, COMPLEX_NO);',dataIdx);
        codeWriter.wNewLine;


        dataIdx=totalNumDWorks-1;
        dataWidth=2*size(this.LctSpecInfo.DataTypes.BusInfo.BusElementHashTable,1);
        codeWriter.wCmt('Configure the dwork %d (__dtBusInfo)',dataIdx+1);
        codeWriter.wLine('ssSetDWorkDataType(S, %d, SS_INT32);',dataIdx);
        codeWriter.wLine('ssSetDWorkUsageType(S, %d, SS_DWORK_USED_AS_DWORK);',dataIdx);
        codeWriter.wLine('ssSetDWorkName(S, %d, "dtBusInfo");',dataIdx);
        codeWriter.wLine('ssSetDWorkWidth(S, %d, %d);',dataIdx,dataWidth);
        codeWriter.wLine('ssSetDWorkComplexSignal(S, %d, COMPLEX_NO);',dataIdx);

        codeWriter.wBlockEnd();
    end


    for ii=1:this.LctSpecInfo.DWorks.Numel

        dataSpec=this.LctSpecInfo.DWorks.Items(ii);
        dataType=this.LctSpecInfo.DataTypes.Items(dataSpec.DataTypeId);
        if isempty(dataSpec.dwIdx)

            continue
        end
        dataIdx=dataSpec.dwIdx-1;

        codeWriter.wNewLine;
        codeWriter.wCmt('Configure the dwork %d (%s)',dataIdx+1,dataSpec.Identifier);


        if dataType.IsOpaque

            assert(this.LctSpecInfo.Specs.Options.stubSimBehavior);
            typeIdSet(dataType.Id)=true;
            this.emitOpaqueTypeRegistration(codeWriter,dataType.DTName,dataIdx,'ssSetDWorkDataType');
        elseif dataType.HasObject

            typeIdSet(dataType.Id)=true;
            this.emitNamedTypeRegistration(codeWriter,dataType.DTName,dataIdx,'ssSetDWorkDataType');
        else

            this.emitBuiltinTypeRegistration(codeWriter,dataType,dataIdx,'ssSetDWorkDataType');
        end




        codeWriter.wLine('ssSetDWorkUsageType(S, %d, SS_DWORK_USED_AS_DWORK);',dataIdx);
        codeWriter.wLine('ssSetDWorkName(S, %d, "%s");',dataIdx,dataSpec.Identifier);


        dimStr=legacycode.lct.gen.ExprSFunEmitter.emitAllDims(this.LctSpecInfo,dataSpec,'init');
        nbDims=length(dimStr);



        if nbDims==1||ismember('DYNAMICALLY_SIZED',dimStr)

            codeWriter.wLine('ssSetDWorkWidth(S, %d, %s);',dataIdx,dimStr{1});
        else

            codeWriter.wBlockStart();
            codeWriter.wLine('int_T dims[%d];',nbDims);
            codeWriter.wLine('int_T width;');
            codeWriter.wNewLine;


            width='';
            mult='';
            for jj=1:numel(dimStr)
                codeWriter.wLine('dims[%d] = %s;',jj-1,dimStr{jj});
                stmts=legacycode.lct.gen.SFunEmitter.genCheckDimension(dataSpec,true,dimStr{jj},'dims',jj);
                cellfun(@(aLine)codeWriter.wLine(aLine),stmts);
                width=sprintf('%s %s dims[%d]',width,mult,jj-1);
                mult='*';
            end
            codeWriter.wLine('width = %s;',width);
            codeWriter.wLine('ssSetDWorkWidth(S, %d, width);',dataIdx);
            codeWriter.wBlockEnd();
        end


        if dataSpec.IsComplex
            codeWriter.wLine('ssSetDWorkComplexSignal(S, %d, COMPLEX_YES);',dataIdx);
        else
            codeWriter.wLine('ssSetDWorkComplexSignal(S, %d, COMPLEX_NO);',dataIdx);
        end
    end


    for ii=1:this.LctSpecInfo.DWorksForNDArray.Numel

        dWork=this.LctSpecInfo.DWorksForNDArray.Items(ii);
        dataType=this.LctSpecInfo.DataTypes.Items(dWork.DataTypeId);
        dataIdx=numDWorks+ii-1;


        apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dWork.CArrayND.Data,'sfun');

        codeWriter.wNewLine;
        codeWriter.wCmt('Configure the dwork %d (%s)',dataIdx+1,apiInfo.WANDName);


        codeWriter.wBlockStart('if (!isRowMajorEnabled)');


        if dataType.HasObject

            typeIdSet(dataType.Id)=true;
            this.emitNamedTypeRegistration(codeWriter,dataType.DTName,dataIdx,'ssSetDWorkDataType');
        else

            dataType=this.LctSpecInfo.DataTypes.Items(dataType.IdAliasedThruTo);
            codeWriter.wLine('ssSetDWorkDataType(S, %d, %s);',dataIdx,dataType.Enum);
        end




        codeWriter.wLine('ssSetDWorkUsageType(S, %d, SS_DWORK_USED_AS_DWORK);',dataIdx);
        codeWriter.wLine('ssSetDWorkName(S, %d, "%s");',dataIdx,apiInfo.WANDName);


        codeWriter.wLine('ssSetDWorkWidth(S, %d, DYNAMICALLY_SIZED);',dataIdx);


        if dWork.CArrayND.Data.IsComplex
            cplxFlag='YES';
        else
            cplxFlag='NO';
        end
        codeWriter.wLine('ssSetDWorkComplexSignal(S, %d, COMPLEX_%s);',dataIdx,cplxFlag);


        codeWriter.wBlockEnd();
    end


    function str=genTotalNumDWorksStr(totalNumDWorks,numDWorksForNDArray,term)

        if numDWorksForNDArray>0
            str=sprintf('(isRowMajorEnabled ? %d : %d)',...
            totalNumDWorks-numDWorksForNDArray+term,totalNumDWorks+term);
        else
            str=sprintf('%d',totalNumDWorks+term);
        end


