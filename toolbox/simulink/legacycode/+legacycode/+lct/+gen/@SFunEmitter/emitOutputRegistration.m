



function typeIdSet=emitOutputRegistration(this,codeWriter,typeIdSet)

    if nargin<3

        typeIdSet=containers.Map('KeyType','uint32','ValueType','logical');
    end


    codeWriter.wNewLine;
    codeWriter.wCmt('Set the number of output ports');
    codeWriter.wLine('if (!ssSetNumOutputPorts(S, %d)) return;',this.LctSpecInfo.Outputs.Numel);


    for ii=1:this.LctSpecInfo.Outputs.Numel

        dataSpec=this.LctSpecInfo.Outputs.Items(ii);
        dataType=this.LctSpecInfo.DataTypes.Items(dataSpec.DataTypeId);
        dataIdx=ii-1;

        codeWriter.wNewLine;
        codeWriter.wCmt('Configure the output port %d',ii);


        if dataType.HasObject

            typeIdSet(dataType.Id)=true;
            this.emitNamedTypeRegistration(codeWriter,dataType.DTName,dataIdx,'ssSetOutputPortDataType');


            if dataType.IsBus
                codeWriter.wLine('ssSetBusOutputObjectName(S, %d, (void *)"%s");',...
                dataIdx,dataType.DTName);
                codeWriter.wLine('ssSetBusOutputAsStruct(S, %d, 1);',dataIdx);
            end
        else

            this.emitBuiltinTypeRegistration(codeWriter,dataType,dataIdx,'ssSetOutputPortDataType');
        end


        this.emitInputOutputDimsRegistration(codeWriter,dataSpec);


        if dataSpec.IsComplex==1
            codeWriter.wLine('ssSetOutputPortComplexSignal(S, %d, COMPLEX_YES);',dataIdx);
        else
            codeWriter.wLine('ssSetOutputPortComplexSignal(S, %d, COMPLEX_NO);',dataIdx);
        end







        bool=(this.LctSpecInfo.Outputs.Numel<=1)&&(this.LctSpecInfo.hasRowMajorNDArray==false)&&~this.LctSpecInfo.GlobalIO.HasGlobalOutputs;
        for jj=1:this.LctSpecInfo.Fcns.Output.RhsArgs.Numel
            argSpec=this.LctSpecInfo.Fcns.Output.RhsArgs.Items(jj);
            if argSpec.Data.isOutput()&&(argSpec.Data.Id==ii)
                bool=false;
                break
            end
        end
        if this.LctSpecInfo.Fcns.Output.LhsArgs.Numel==1
            argSpec=this.LctSpecInfo.Fcns.Output.LhsArgs.Items(1);
            if(argSpec.Data.Id==ii)&&dataType.isAggregateType()
                bool=false;
            end
        end


        if this.LctSpecInfo.Specs.Options.outputsConditionallyWritten
            portOptim='SS_NOT_REUSABLE_AND_GLOBAL';
        else
            portOptim='SS_REUSABLE_AND_LOCAL';
        end
        codeWriter.wLine('ssSetOutputPortOptimOpts(S, %d, %s);',dataIdx,portOptim);
        codeWriter.wLine('ssSetOutputPortOutputExprInRTW(S, %d, %d);',dataIdx,bool&&~dataSpec.IsDynamicArray);
        if dataSpec.IsDynamicArray
            codeWriter.wLine('ssSetOutputPortDimensionsMode(S, %d, VARIABLE_DIMS_MODE);',dataIdx);
        else
            codeWriter.wLine('ssSetOutputPortDimensionsMode(S, %d, FIXED_DIMS_MODE);',dataIdx);
        end
    end
