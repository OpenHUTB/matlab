



function emitTrailer(this,codeWriter)

    if this.HasSampleTimeAsParameter



        codeWriter.wNewLine;
        codeWriter.wLine('#define MDL_RTW');
        codeWriter.wLine('#if defined(MATLAB_MEX_FILE) && defined(MDL_RTW)');
        codeWriter.wMultiCmtStart('Function: mdlRTW =======================================================');
        codeWriter.wMultiCmtMiddle('Abstract:');
        codeWriter.wMultiCmtMiddle('  This function is called when Simulink Coder is generating');
        codeWriter.wMultiCmtMiddle('  the model.rtw file.');
        codeWriter.wMultiCmtEnd();
        codeWriter.wLine('static void mdlRTW(SimStruct *S)');
        codeWriter.wBlockStart();
        codeWriter.wBlockEnd();
        codeWriter.wLine('#endif');
    end

    if this.LctSpecInfo.canUseSFunCgAPI
        codeWriter.wNewLine;
        codeWriter.wLine('#define MDL_RTWCG');
        codeWriter.wLine('#if defined(MATLAB_MEX_FILE) && defined(MDL_RTWCG)');
        codeWriter.wMultiCmtStart('Function: mdlRTWCG =====================================================');
        codeWriter.wMultiCmtMiddle('Abstract:');
        codeWriter.wMultiCmtMiddle('  This function is called when Simulink Coder is generating the model.rtw');
        codeWriter.wMultiCmtMiddle('  file and the S-Function uses the Code Construction API.');
        codeWriter.wMultiCmtEnd();
        codeWriter.wLine('static void mdlRTWCG(SimStruct *S, void *rtwBlk)');
        codeWriter.wBlockStart();
        codeWriter.wLine('SFun::construct_code_for_user_block<%s_Block>(S, rtwBlk);',this.LctSpecInfo.Specs.SFunctionName);
        codeWriter.wBlockEnd();
        codeWriter.wLine('#endif');
    end

    if this.HasSampleTimeAsParameter


        codeWriter.wNewLine;
        codeWriter.wMultiCmtStart('Function: IsRealMatrix =================================================');
        codeWriter.wMultiCmtMiddle('Abstract:');
        codeWriter.wMultiCmtMiddle('  Verify that the mxArray is a real (double) finite matrix');
        codeWriter.wMultiCmtEnd();
        codeWriter.wLine('boolean_T IsRealMatrix(const mxArray *m)');
        codeWriter.wBlockStart();
        test=[...
        'mxIsNumeric(m) && ',...
        'mxIsDouble(m) && ',...
        '!mxIsLogical(m) && ',...
        '!mxIsComplex(m) && ',...
        '!mxIsSparse(m) && ',...
        '!mxIsEmpty(m) && ',...
'(mxGetNumberOfDimensions(m)==2)'...
        ];
        codeWriter.wBlockStart('if (%s)',test);
        codeWriter.wLine('real_T *data = mxGetPr(m);');
        codeWriter.wLine('size_t  numEl = mxGetNumberOfElements(m);');
        codeWriter.wLine('size_t  i;');
        codeWriter.wNewLine;
        codeWriter.wBlockStart('for (i = 0; i < numEl; i++)');
        codeWriter.wBlockStart('if (!mxIsFinite(data[i]))');
        codeWriter.wLine('return 0;');
        codeWriter.wBlockEnd();
        codeWriter.wBlockEnd();
        codeWriter.wNewLine;
        codeWriter.wLine('return 1;');
        codeWriter.decIndent;
        codeWriter.wLine('} else {');
        codeWriter.incIndent;
        codeWriter.wLine('return 0;');
        codeWriter.wBlockEnd();
        codeWriter.wBlockEnd();
    end

    if this.LctSpecInfo.hasSLObject
        codeWriter.wNewLine;
        codeWriter.wMultiCmtStart('Function: CheckDataTypeChecksum ========================================');
        codeWriter.wMultiCmtMiddle('Abstract:');
        codeWriter.wMultiCmtMiddle('  CheckDataTypeChecksum invokes a MATLAB helper for checking the consistency');
        codeWriter.wMultiCmtMiddle('  between the data type definition used when this S-Function was generated');
        codeWriter.wMultiCmtMiddle('  and the data type used when calling the S-Function.');
        codeWriter.wMultiCmtEnd();
        codeWriter.wLine('static int_T CheckDataTypeChecksum(SimStruct *S, const char* dtypeName, uint32_T* chkRef)');
        codeWriter.wBlockStart();
        codeWriter.wLine('mxArray *plhs[1] = {NULL};');
        codeWriter.wLine('mxArray *prhs[3];');
        codeWriter.wLine('mxArray *err = NULL;');
        codeWriter.wLine('const char *bpath = ssGetPath(S);');
        codeWriter.wLine('int_T status = -1;');
        codeWriter.wNewLine;
        codeWriter.wLine('prhs[0] = mxCreateString(bpath);');
        codeWriter.wLine('prhs[1] = mxCreateString(dtypeName);');
        codeWriter.wLine('prhs[2] = mxCreateDoubleMatrix(1, 4, mxREAL);');
        codeWriter.wLine('mxGetPr(prhs[2])[0] = chkRef[0];');
        codeWriter.wLine('mxGetPr(prhs[2])[1] = chkRef[1];');
        codeWriter.wLine('mxGetPr(prhs[2])[2] = chkRef[2];');
        codeWriter.wLine('mxGetPr(prhs[2])[3] = chkRef[3];');
        codeWriter.wNewLine;
        codeWriter.wLine('err = mexCallMATLABWithTrap(1, plhs, 3, prhs, "legacycode.LCT.getOrCompareDataTypeChecksum");');
        codeWriter.wLine('mxDestroyArray(prhs[0]);');
        codeWriter.wLine('mxDestroyArray(prhs[1]);');
        codeWriter.wLine('mxDestroyArray(prhs[2]);');
        codeWriter.wNewLine;
        codeWriter.wBlockStart('if (err==NULL && plhs[0]!=NULL)');
        codeWriter.wLine('status = mxIsEmpty(plhs[0]) ? -1 : (int_T) (mxGetScalar(plhs[0]) != 0);');
        codeWriter.wLine('mxDestroyArray(plhs[0]);');
        codeWriter.wBlockEnd();
        codeWriter.wNewLine;
        codeWriter.wLine('return status;');
        codeWriter.wBlockEnd();
        codeWriter.wNewLine;
        codeWriter.wMultiCmtStart('Function: CheckDataTypes ===============================================');
        codeWriter.wMultiCmtMiddle('Abstract:');
        codeWriter.wMultiCmtMiddle('  CheckDataTypes verifies data type consistency between the data type ');
        codeWriter.wMultiCmtMiddle('  definition used when this S-Function was generated and the data type');
        codeWriter.wMultiCmtMiddle('  used when calling the S-Function.');
        codeWriter.wMultiCmtEnd();
        codeWriter.wLine('static void CheckDataTypes(SimStruct *S)');
        codeWriter.wBlockStart();




        namedTypeSource=this.LctSpecInfo.Specs.Options.namedTypeSource;



        if this.LctSpecInfo.hasEnum

            for ii=(this.LctSpecInfo.DataTypes.NumSLBuiltInDataTypes+1):this.LctSpecInfo.DataTypes.Numel
                dataType=this.LctSpecInfo.DataTypes.Items(ii);
                if dataType.HasObject&&dataType.IsEnum&&dataType.IsPartOfSpec



                    if dataType.isAliasType()

                        continue
                    end
                    iWriteEnumTypeCheck(codeWriter,namedTypeSource,this.LctSpecInfo.DataTypes,ii);
                end
            end
        end



        if this.LctSpecInfo.hasAlias

            for ii=(this.LctSpecInfo.DataTypes.NumSLBuiltInDataTypes+1):this.LctSpecInfo.DataTypes.Numel
                dataType=this.LctSpecInfo.DataTypes.Items(ii);
                if dataType.HasObject&&dataType.isAliasType()&&dataType.IsPartOfSpec
                    iWriteDataTypeCheck(codeWriter,namedTypeSource,this.LctSpecInfo.DataTypes,ii);
                end
            end
        end



        if this.LctSpecInfo.hasBusOrStruct
            for ii=1:numel(this.LctSpecInfo.DataTypes.BusInfo.BusDataTypesId)
                iWriteBusOrStructCheck(codeWriter,namedTypeSource,this.LctSpecInfo.DataTypes,...
                this.LctSpecInfo.DataTypes.BusInfo.BusDataTypesId(ii));
            end
        end

        codeWriter.wBlockEnd();
    end


    if this.LctSpecInfo.hasWrapper||this.LctSpecInfo.hasRowMajorNDArray
        codeWriter.wNewLine;
        codeWriter.wMultiCmtStart('Function: GetRTWEnvironmentMode ========================================');
        codeWriter.wMultiCmtMiddle('Abstract:');
        codeWriter.wMultiCmtMiddle('  Must be called when ssRTWGenIsCodeGen(S)==true. This function');
        codeWriter.wMultiCmtMiddle('  returns the code generation mode:');
        codeWriter.wMultiCmtMiddle('      -1 if an error occurred');
        codeWriter.wMultiCmtMiddle('       0 for standalone code generation target');
        codeWriter.wMultiCmtMiddle('       1 for simulation target (Accelerator, RTW-SFcn,...)');
        codeWriter.wMultiCmtEnd();
        codeWriter.wLine('static int_T GetRTWEnvironmentMode(SimStruct *S)');
        codeWriter.wBlockStart();
        codeWriter.wLine('int_T status;');
        codeWriter.wLine('mxArray * err;');
        codeWriter.wLine('mxArray *plhs[1];');
        codeWriter.wLine('mxArray *prhs[1];');
        codeWriter.wNewLine;
        codeWriter.wCmt('Get the name of the Simulink block diagram');
        codeWriter.wLine('prhs[0] = mxCreateString(ssGetBlockDiagramName(S));');
        codeWriter.wLine('plhs[0] = NULL;');
        codeWriter.wNewLine;
        codeWriter.wCmt('Call "isSimulationTarget = rtwenvironmentmode(modelName)" in MATLAB');
        codeWriter.wLine('err = mexCallMATLABWithTrap(1, plhs, 1, prhs, "rtwenvironmentmode");');
        codeWriter.wNewLine;
        codeWriter.wLine('mxDestroyArray(prhs[0]);');
        codeWriter.wNewLine;
        codeWriter.wCmt('Set the error status if an error occurred');
        codeWriter.wBlockStart('if (err)');
        codeWriter.wBlockStart('if (plhs[0])');
        codeWriter.wLine('mxDestroyArray(plhs[0]);');
        codeWriter.wLine('plhs[0] = NULL;');
        codeWriter.wBlockEnd('}');
        codeWriter.wLine('ssSetErrorStatus(S, "Unknown error during call to ''rtwenvironmentmode''.");');
        codeWriter.wLine('return -1;');
        codeWriter.wBlockEnd();
        codeWriter.wNewLine;
        codeWriter.wCmt('Get the value returned by rtwenvironmentmode(modelName)');
        codeWriter.wBlockStart('if (plhs[0])');
        codeWriter.wLine('status = (int_T) (mxGetScalar(plhs[0]) != 0);');
        codeWriter.wLine('mxDestroyArray(plhs[0]);');
        codeWriter.wLine('plhs[0] = NULL;');
        codeWriter.wBlockEnd();
        codeWriter.wNewLine;
        codeWriter.wLine('return status;');
        codeWriter.wBlockEnd();
    end


    if this.LctSpecInfo.hasRowMajorNDArray
        codeWriter.wNewLine;
        codeWriter.wMultiCmtStart('Function: GetRowMajorDimensionParam ====================================');
        codeWriter.wMultiCmtMiddle('Abstract:');
        codeWriter.wMultiCmtMiddle('  Return true if the model''s parameter RowMajorDimensionSupport is ''on''');
        codeWriter.wMultiCmtEnd();
        codeWriter.wLine('static boolean_T GetRowMajorDimensionParam(SimStruct *S)');
        codeWriter.wBlockStart();
        codeWriter.wLine('boolean_T status = 0;');
        codeWriter.wLine('mxArray * exception = NULL;');
        codeWriter.wLine('mxArray *plhs[1];');
        codeWriter.wLine('mxArray *prhs[1];');
        codeWriter.wNewLine;
        codeWriter.wCmt('Create the arguments');
        codeWriter.wLine('prhs[0] = mxCreateString(ssGetBlockDiagramName(S));');
        codeWriter.wLine('plhs[0] = NULL;');
        codeWriter.wNewLine;
        codeWriter.wCmt('Get the model''s parameter');
        codeWriter.wLine('exception = mexCallMATLABWithTrap(1, plhs, 1, prhs, "legacycode.lct.util.isRowMajorFeatureEnabled");');
        codeWriter.wNewLine;
        codeWriter.wCmt('Extract the value');
        codeWriter.wBlockStart('if (exception==NULL && plhs[0]!=NULL && !mxIsEmpty(plhs[0]) && mxIsScalar(plhs[0]))');
        codeWriter.wLine('status = (boolean_T)mxGetScalar(plhs[0]) > 0;');
        codeWriter.wBlockEnd('');
        codeWriter.wNewLine;
        codeWriter.wCmt('Free the memory');
        codeWriter.wLine('mxDestroyArray(prhs[0]);');
        codeWriter.wBlockStart('if (plhs[0]!=NULL)');
        codeWriter.wLine('mxDestroyArray(plhs[0]);');
        codeWriter.wBlockEnd('');
        codeWriter.wNewLine;
        codeWriter.wLine('return status;');
        codeWriter.wBlockEnd();
    end

    codeWriter.wNewLine;
    codeWriter.wCmt('Required S-function trailer');
    codeWriter.wLine('#ifdef    MATLAB_MEX_FILE');
    codeWriter.wLine('# include "simulink.c"');
    codeWriter.wLine('#else');
    codeWriter.wLine('# include "cg_sfun.h"');
    codeWriter.wLine('#endif');
    codeWriter.wNewLine;


    function iWriteTypeChecksumCheck(codeWriter,dtChk,dtName,dtDesc)

        dtChkStr=cellfun(@(x)sprintf('%d',x),num2cell(dtChk),'Uniformoutput',false);

        codeWriter.wBlockStart();
        codeWriter.wLine('uint32_T chk[] = {%s};',strjoin(dtChkStr,', '));
        codeWriter.wLine('int_T status;');
        codeWriter.wLine('status = CheckDataTypeChecksum(S, "%s", &chk[0]);',dtName);
        codeWriter.wLine('if (status==-1) {');
        codeWriter.wLine('  ssSetErrorStatus(S, "Unexpected error when checking the validity of the %s ''%s''");',dtDesc,dtName);
        codeWriter.wLine('} else if (status==0) {');
        codeWriter.wLine('  ssSetErrorStatus(S, "The %s ''%s'' definition has changed since the S-Function was generated");',dtDesc,dtName);
        codeWriter.wLine('}');
        codeWriter.wBlockEnd();


        function iWriteEnumTypeCheck(codeWriter,namedTypeSource,dataTypes,dataTypeId)


            dataType=dataTypes.Items(dataTypeId);

            codeWriter.wNewLine;
            codeWriter.wCmt('Verify Enumerated Type ''%s'' specification',dataTypes.Items(dataTypeId).DTName);


            chk=legacycode.LCT.getOrCompareDataTypeChecksum(namedTypeSource,dataType.DTName);
            if~isempty(chk)
                iWriteTypeChecksumCheck(codeWriter,chk,dataType.DTName,'Enumerated type');
            end


            function iWriteDataTypeCheck(codeWriter,namedTypeSource,dataTypes,dataTypeId)


                dataType=dataTypes.Items(dataTypeId);




                codeWriter.wNewLine;
                codeWriter.wCmt('Verify AliasType/NumericType ''%s'' specification',dataType.DTName);


                chk=legacycode.LCT.getOrCompareDataTypeChecksum(namedTypeSource,dataType.DTName);
                if~isempty(chk)
                    iWriteTypeChecksumCheck(codeWriter,chk,dataType.DTName,'Simulink AliasType/NumericType');
                end


                function iWriteBusOrStructCheck(codeWriter,namedTypeSource,dataTypes,dataTypeId)


                    dataType=dataTypes.Items(dataTypeId);

                    codeWriter.wNewLine;
                    codeWriter.wCmt('Verify Bus/StructType ''%s'', specification',dataType.DTName);


                    chk=legacycode.LCT.getOrCompareDataTypeChecksum(namedTypeSource,dataType.DTName);
                    if~isempty(chk)
                        iWriteTypeChecksumCheck(codeWriter,chk,dataType.DTName,'Simulink Bus/StructType');
                    end


