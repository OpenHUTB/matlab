



function typeIdSet=emitInputRegistration(this,codeWriter,typeIdSet)

    if nargin<3

        typeIdSet=containers.Map('KeyType','uint32','ValueType','logical');
    end


    codeWriter.wNewLine;
    codeWriter.wCmt('Set the number of input ports');
    codeWriter.wLine('if (!ssSetNumInputPorts(S, %d)) return;',this.LctSpecInfo.Inputs.Numel);


    for ii=1:this.LctSpecInfo.Inputs.Numel

        dataSpec=this.LctSpecInfo.Inputs.Items(ii);
        dataType=this.LctSpecInfo.DataTypes.Items(dataSpec.DataTypeId);
        dataIdx=ii-1;

        codeWriter.wNewLine;
        codeWriter.wCmt('Configure the input port %d',ii);


        if dataType.HasObject

            typeIdSet(dataType.Id)=true;
            this.emitNamedTypeRegistration(codeWriter,dataType.DTName,dataIdx,'ssSetInputPortDataType');


            if dataType.IsBus
                codeWriter.wLine('ssSetBusInputAsStruct(S, %d, 1);',dataIdx);
            end
        else

            this.emitBuiltinTypeRegistration(codeWriter,dataType,dataIdx,'ssSetInputPortDataType');
        end


        this.emitInputOutputDimsRegistration(codeWriter,dataSpec);


        if dataSpec.IsComplex==1
            codeWriter.wLine('ssSetInputPortComplexSignal(S, %d, COMPLEX_YES);',dataIdx);
        else
            codeWriter.wLine('ssSetInputPortComplexSignal(S, %d, COMPLEX_NO);',dataIdx);
        end

        codeWriter.wLine('ssSetInputPortDirectFeedThrough(S, %d, 1);',dataIdx);

        optimOpts=loc_getOptimOpts(this.LctSpecInfo,ii);
        bool=loc_AcceptExprAndOverWritable(this.LctSpecInfo,optimOpts,ii);

        codeWriter.wLine('ssSetInputPortAcceptExprInRTW(S, %d, %d);',dataIdx,bool);
        codeWriter.wLine('ssSetInputPortOverWritable(S, %d, %d);',dataIdx,bool);
        codeWriter.wLine('ssSetInputPortOptimOpts(S, %d, %s);',dataIdx,optimOpts);
        codeWriter.wLine('ssSetInputPortRequiredContiguous(S, %d, 1);',dataIdx);
        if dataSpec.IsDynamicArray
            codeWriter.wLine('ssSetInputPortDimensionsMode(S, %d, VARIABLE_DIMS_MODE);',dataIdx);
        else
            codeWriter.wLine('ssSetInputPortDimensionsMode(S, %d, FIXED_DIMS_MODE);',dataIdx);
        end
    end



    function optimOpts=loc_getOptimOpts(lctSpecInfo,currInputId)











        isGlobal=lctSpecInfo.Specs.Options.stubSimBehavior&&...
        loc_isGlobal(lctSpecInfo.GlobalIO.Inputs,currInputId);
        if(numel(lctSpecInfo.Fcns.Start)==1&&~lctSpecInfo.Fcns.Start.IsSpecified)||~isGlobal
            optimOpts='SS_REUSABLE_AND_LOCAL';
        else
            optimOpts='SS_NOT_REUSABLE_AND_GLOBAL';
        end



        function isGlobal=loc_isGlobal(globalIOInputs,currInputId)


            isGlobal=false;
            for kGlobalInput=1:numel(globalIOInputs)
                if globalIOInputs(kGlobalInput).VarSpec.Data.Id==currInputId
                    isGlobal=true;
                    break;
                end
            end



            function bool=loc_AcceptExprAndOverWritable(lctSpecInfo,optimOpts,currInputId)



                bool=lctSpecInfo.Specs.Options.isMacro==false;
                if bool
                    for jj=1:lctSpecInfo.Fcns.Output.RhsArgs.Numel
                        argSpec=lctSpecInfo.Fcns.Output.RhsArgs.Items(jj);
                        if argSpec.Data.isInput()&&(argSpec.Data.Id==currInputId)
                            if~argSpec.PassedByValue
                                bool=false;
                            end
                            break
                        end
                    end
                end


                bool=bool&&strcmp(optimOpts,'SS_REUSABLE_AND_LOCAL');


