



function emitInitializeSizes(this,codeWriter)

    codeWriter.wNewLine;
    codeWriter.wMultiCmtStart('Function: mdlInitializeSizes ===========================================');
    codeWriter.wMultiCmtMiddle('Abstract:');
    codeWriter.wMultiCmtMiddle('  The sizes information is used by Simulink to determine the S-function');
    codeWriter.wMultiCmtMiddle('  block''s characteristics (number of inputs, outputs, states, etc.).');
    codeWriter.wMultiCmtEnd();
    codeWriter.wLine('static void mdlInitializeSizes(SimStruct *S)');
    codeWriter.wBlockStart();


    typeIdSet=containers.Map('KeyType','uint32','ValueType','logical');


    if this.LctSpecInfo.hasRowMajorNDArray
        codeWriter.wCmt('Flag for row-major conversion');
        codeWriter.wLine('boolean_T isRowMajorEnabled = IS_ROW_MAJOR_CODEGEN_ENABLED(S);');
        codeWriter.wNewLine;
    end








    if this.LctSpecInfo.hasWrapper
        codeWriter.wCmt('Flag for detecting standalone or simulation target mode');
        codeWriter.wLine('boolean_T isSimulationTarget = IS_SIMULATION_TARGET(S);');
        codeWriter.wNewLine;
    end

    if this.LctSpecInfo.useInt64
        codeWriter.wCmt('Required for registering int64/uint64');
        codeWriter.wLine('ssFxpSetU32BitRegionCompliant(S, 1);');
        codeWriter.wNewLine;
    end

    this.emitParameterRegistration(codeWriter);

    this.emitDWorkRegistration(codeWriter,typeIdSet);

    this.emitInputRegistration(codeWriter,typeIdSet);

    this.emitOutputRegistration(codeWriter,typeIdSet);

    this.emitRegisterGlobalDataStoreInfo(codeWriter);

    emitReservedNameRegistration(this,codeWriter);

    emitOptions(this,codeWriter);

    emitCheckDataTypes(this,codeWriter,typeIdSet);

    codeWriter.wBlockEnd();

end


function emitReservedNameRegistration(this,codeWriter)


    hasFunSpecification=false;
    this.LctSpecInfo.forEachFunction(@(o,k,f)isFunSpecified(f));

    if hasFunSpecification
        codeWriter.wNewLine;
        codeWriter.wCmt('Register reserved identifiers to avoid name conflict');
        codeWriter.wBlockStart('if (ssRTWGenIsCodeGen(S) || ssGetSimMode(S)==SS_SIMMODE_EXTERNAL)');








        this.LctSpecInfo.forEachFunction(@(o,k,f)reserveFunName(f,k));



        if(this.LctSpecInfo.hasWrapper==true||this.LctSpecInfo.isCPP==true)
            codeWriter.wNewLine;
            codeWriter.wCmt('Register reserved identifier for wrappers');


            if this.LctSpecInfo.hasWrapper==true


                codeWriter.wBlockStart('if (isSimulationTarget)');
            else

                codeWriter.wBlockStart('if (ssRTWGenIsModelReferenceSimTarget(S))');
            end


            this.LctSpecInfo.forEachFunction(@(o,k,f)reserveWrapperFunName(f,k));

            if this.LctSpecInfo.DWorksForBus.Numel>0


                codeWriter.wNewLine;
                codeWriter.wCmt('Register reserved identifier for allocating PWork for SimulationTarget');
                codeWriter.wLine('ssRegMdlInfo(S, "%s_wrapper_allocmem", MDL_INFO_ID_RESERVED, 0, 0, ssGetPath(S));',...
                this.LctSpecInfo.Specs.SFunctionName);

                codeWriter.wNewLine;
                codeWriter.wCmt('Register reserved identifier for freeing PWork for SimulationTarget');
                codeWriter.wLine('ssRegMdlInfo(S, "%s_wrapper_freemem", MDL_INFO_ID_RESERVED, 0, 0, ssGetPath(S));',...
                this.LctSpecInfo.Specs.SFunctionName);
            end

            codeWriter.wBlockEnd();
        end

        codeWriter.wBlockEnd();
    end

    if this.LctSpecInfo.hasRowMajorNDArray

        codeWriter.wNewLine;
        codeWriter.wBlockStart('if (ssRTWGenIsCodeGen(S) || ssGetSimMode(S)==SS_SIMMODE_EXTERNAL)');


        this.LctSpecInfo.forEachDataSetDataOnly(@(d)reserveNameForNDMarshaling(d));





        codeWriter.wBlockEnd();
    end

    function isFunSpecified(funSpec)
        hasFunSpecification=hasFunSpecification||funSpec.IsSpecified;
    end

    function reserveFunName(funSpec,funKind)
        if funSpec.IsSpecified
            codeWriter.wNewLine;
            codeWriter.wCmt('Register reserved identifier for %FcnSpec',funKind);
            codeWriter.wLine('ssRegMdlInfo(S, "%s", MDL_INFO_ID_RESERVED, 0, 0, ssGetPath(S));',...
            funSpec.Name);
        end
    end

    function reserveWrapperFunName(funSpec,funKind)
        if funSpec.IsSpecified
            codeWriter.wNewLine;
            codeWriter.wCmt('Register reserved identifier for %FcnSpec (for SimulationTarget)',...
            funKind);
            codeWriter.wLine('ssRegMdlInfo(S, "%s_wrapper_%s", MDL_INFO_ID_RESERVED, 0, 0, ssGetPath(S));',...
            funSpec.Name,funKind);
        end
    end

    function reserveNameForNDMarshaling(dataSpec)
        if dataSpec.CArrayND.DWorkIdx>0


            apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'sfun');
            codeWriter.wLine('ssRegMdlInfo(S, "%s", MDL_INFO_ID_RESERVED, 0, 0, ssGetPath(S));',...
            apiInfo.CVarWBusName);
            codeWriter.wLine('ssRegMdlInfo(S, "%s", MDL_INFO_ID_RESERVED, 0, 0, ssGetPath(S));',...
            apiInfo.CVarWANDName);
        end
    end
end


function emitOptions(this,codeWriter)


    codeWriter.wNewLine;
    if iHasNDSignals(this.LctSpecInfo)
        codeWriter.wCmt('Set the option for ND signals support');
        codeWriter.wLine('ssAllowSignalsWithMoreThan2D(S);');
        codeWriter.wNewLine;
    end

    codeWriter.wCmt('This S-function can be used in referenced model simulating in normal mode');
    codeWriter.wLine('ssSetModelReferenceNormalModeSupport(S, MDL_START_AND_MDL_PROCESS_PARAMS_OK);');
    codeWriter.wNewLine;

    codeWriter.wCmt('Set the number of sample time');
    codeWriter.wLine('ssSetNumSampleTimes(S, 1);');
    codeWriter.wNewLine;

    codeWriter.wCmt('Set the compliance for the operating point save/restore.');
    if this.LctSpecInfo.DWorksInfo.NumPWorks==0





        codeWriter.wLine('ssSetOperatingPointCompliance(S, USE_DEFAULT_OPERATING_POINT);');
    else


        codeWriter.wLine('ssSetOperatingPointCompliance(S, OPERATING_POINT_COMPLIANCE_UNKNOWN);');
    end

    if this.LctSpecInfo.canUseSFunCgAPI
        codeWriter.wNewLine;
        codeWriter.wCmt('Generate code with S-Function Code Construction API');
        codeWriter.wLine('ssSetRTWCG(S, true);');
        codeWriter.wNewLine;
        codeWriter.wLine('ssSetSupportedForRowMajorCodeGen(S, true);');
    end

    codeWriter.wNewLine;


    if this.LctSpecInfo.Specs.Options.isRowMajorLayoutForCodeGen


        codeWriter.wLine('ssSetArrayLayoutForCodeGen(S, SS_ROW_MAJOR);');
    elseif this.LctSpecInfo.Specs.Options.stubSimBehavior


        codeWriter.wLine('ssSetArrayLayoutForCodeGen(S, SS_COLUMN_MAJOR);');
    else








        if this.LctSpecInfo.hasRowMajorNDArray
            codeWriter.wBlockStart('if (isRowMajorEnabled)');
            codeWriter.wLine('ssSetArrayLayoutForCodeGen(S, SS_ROW_MAJOR);');
            codeWriter.wBlockMiddle('else');
            codeWriter.wLine('ssSetArrayLayoutForCodeGen(S, SS_ALL);');
            codeWriter.wBlockEnd();
        elseif this.LctSpecInfo.hasNDArray
            codeWriter.wLine('ssSetArrayLayoutForCodeGen(S, SS_COLUMN_MAJOR);');
        else
            codeWriter.wLine('ssSetArrayLayoutForCodeGen(S, SS_ALL);');
        end
    end

    codeWriter.wNewLine;
    codeWriter.wCmt('Set the Simulink version this S-Function has been generated in');
    codeWriter.wLine('ssSetSimulinkVersionGeneratedIn(S, "%s");',legacycode.lct.spec.Common.SLVer.Version);


    codeWriter.wNewLine;
    this.emitSSOptions(codeWriter);

end


function emitCheckDataTypes(this,codeWriter,typeIdSet)



    if this.LctSpecInfo.hasSLObject



        codeWriter.wNewLine;
        codeWriter.wCmt('Verify Data Type consistency with specification');
        codeWriter.wLine('#if defined(MATLAB_MEX_FILE)');
        codeWriter.wBlockStart('if ((ssGetSimMode(S)!=SS_SIMMODE_SIZES_CALL_ONLY))');



        this.LctSpecInfo.forEachFunction(@(o,k,f)f.forEachArg(@(f,a)reserveDataTypeIfNeeded(a)));


        codeWriter.wLine('CheckDataTypes(S);');

        codeWriter.wBlockEnd();
        codeWriter.wLine('#endif');
    end

    function reserveDataTypeIfNeeded(argSpec)

        dataSpec=argSpec.Data;
        if~(dataSpec.isParameter()||dataSpec.isExprArg())
            return
        end



        dataType=this.LctSpecInfo.DataTypes.Items(dataSpec.DataTypeId);
        if~dataType.HasObject||typeIdSet.isKey(dataType.Id)
            return
        end


        codeWriter.wNewLine;
        codeWriter.wBlockStart();
        codeWriter.wLine('DTypeId dataTypeIdReg;');
        codeWriter.wNewLine;
        codeWriter.wLine('ssRegisterTypeFromNamedObject(S, "%s", &dataTypeIdReg);',dataType.DTName);
        codeWriter.wLine('if(dataTypeIdReg == INVALID_DTYPE_ID) return;');
        codeWriter.wBlockEnd();


        typeIdSet(dataType.Id)=true;
    end
end


function bool=iHasNDSignals(lctSpecInfo)




    bool=false;


    for ii=1:lctSpecInfo.Inputs.Numel
        if numel(lctSpecInfo.Inputs.Items(ii).Dimensions)>2
            bool=true;
            return
        end
    end


    for ii=1:lctSpecInfo.Outputs.Numel
        if numel(lctSpecInfo.Outputs.Items(ii).Dimensions)>2
            bool=true;
            return
        end
    end
end



