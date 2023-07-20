




function emitDefines(this,codeWriter)

    codeWriter.wNewLine;
    codeWriter.wCmt('Must specify the S_FUNCTION_NAME as the name of the S-function');
    codeWriter.wLine('#define S_FUNCTION_NAME  %s',this.LctSpecInfo.Specs.SFunctionName);
    codeWriter.wLine('#define S_FUNCTION_LEVEL 2');
    codeWriter.wNewLine;

    codeWriter.wMultiCmtStart();
    codeWriter.wMultiCmtMiddle('Need to include simstruc.h for the definition of the SimStruct and');
    codeWriter.wMultiCmtMiddle('its associated macro definitions.');
    codeWriter.wMultiCmtEnd();
    codeWriter.wLine('#include "simstruc.h"');
    if this.LctSpecInfo.useInt64
        codeWriter.wLine('#include "fixedpoint.h"');
    end
    codeWriter.wNewLine;




    if this.LctSpecInfo.canUseSFunCgAPI||this.LctSpecInfo.isCPP
        codeWriter.wCmt('Ensure that this S-Function is compiled with a C++ compiler');
        codeWriter.wLine('#ifndef __cplusplus');
        codeWriter.wLine('#error This S-Function must be compiled with a C++ compiler. Enter mex(''-setup'') in the MATLAB Command Window to configure a C++ compiler.');
        codeWriter.wLine('#endif');
        codeWriter.wNewLine;
    end

    if this.LctSpecInfo.canUseSFunCgAPI
        codeWriter.wCmt('Required header for accessing the SFunctionCodeConstruction API');
        codeWriter.wLine('#if defined(MATLAB_MEX_FILE)');
        codeWriter.wLine('#define RTWCG_S_FUNCTION_API_REV 1');
        codeWriter.wLine('#include "sfun_rtwcg.hpp"');
        codeWriter.wLine('#endif');
        codeWriter.wNewLine;
    end


    if this.HasBusInfoToRegister||(this.LctSpecInfo.DWorksForNDArray.Numel>0)
        codeWriter.wLine('#include <string.h>');
        codeWriter.wLine('#include <stdlib.h>');
        codeWriter.wNewLine;
    end


    headerFiles=this.LctSpecInfo.extractAllHeaderFiles();

    if~this.LctSpecInfo.Specs.Options.stubSimBehavior
        if~isempty(headerFiles.GlobalHeaderFiles)
            codeWriter.wCmt('Specific header file(s) required by the legacy code function');
            emitIncludes(codeWriter,headerFiles.GlobalHeaderFiles,...
            this.LctSpecInfo.canUseSFunCgAPI&&~this.LctSpecInfo.isCPP);
            codeWriter.wNewLine;
        end

        if~isempty(headerFiles.SlObjHeaderFiles)
            codeWriter.wCmt('Specific header file(s) required for data types declarations');
            emitIncludes(codeWriter,headerFiles.SlObjHeaderFiles,false);
            codeWriter.wNewLine;
        end
    end


    if this.LctSpecInfo.Parameters.Numel~=0||this.HasSampleTimeAsParameter
        codeWriter.wLine('#define EDIT_OK(S, P_IDX) \');
        codeWriter.wLine('       (!((ssGetSimMode(S)==SS_SIMMODE_SIZES_CALL_ONLY) && mxIsEmpty(ssGetSFcnParam(S, P_IDX))))');
        codeWriter.wNewLine;
    end

    if this.HasSampleTimeAsParameter

        codeWriter.wLine('#define SAMPLE_TIME (ssGetSFcnParam(S, %d))',this.LctSpecInfo.Parameters.Numel);
        codeWriter.wNewLine;
    end

    if this.LctSpecInfo.hasWrapper||this.LctSpecInfo.hasRowMajorNDArray
        codeWriter.wLine(['#define IS_SIMULATION_TARGET(S) (',...
        'ssRTWGenIsAccelerator(S) || ',...
        'ssIsRapidAcceleratorActive(S) || ',...
        'ssRTWGenIsModelReferenceSimTarget(S) || ',...
        '(ssGetSimMode(S)==SS_SIMMODE_NORMAL) || ',...
        '(ssGetSimMode(S)==SS_SIMMODE_SIZES_CALL_ONLY) || ',...
        '!((ssRTWGenIsCodeGen(S) || ssGetSimMode(S)==SS_SIMMODE_EXTERNAL) && GetRTWEnvironmentMode(S)==0)',...
        ')']);

        codeWriter.wNewLine;
    end

    if this.LctSpecInfo.hasRowMajorNDArray
        codeWriter.wLine(['#define IS_ROW_MAJOR_CODEGEN_ENABLED(S) (',...
        '!IS_SIMULATION_TARGET(S) && GetRowMajorDimensionParam(S)',...
        ')']);
        codeWriter.wNewLine;
    end


    if this.LctSpecInfo.hasSLObject||this.LctSpecInfo.hasWrapper||this.HasSampleTimeAsParameter||this.LctSpecInfo.hasRowMajorNDArray
        codeWriter.wNewLine;
        codeWriter.wCmt('Utility function prototypes');
        if this.HasSampleTimeAsParameter


            codeWriter.wLine('static boolean_T IsRealMatrix(const mxArray *m);');
        end
        if this.LctSpecInfo.hasSLObject

            codeWriter.wLine('static void CheckDataTypes(SimStruct *S);');
        end
        if this.LctSpecInfo.hasWrapper||this.LctSpecInfo.hasRowMajorNDArray


            codeWriter.wLine('static int_T GetRTWEnvironmentMode(SimStruct *S);');
        end
        if this.LctSpecInfo.hasRowMajorNDArray


            codeWriter.wLine('static boolean_T GetRowMajorDimensionParam(SimStruct *S);');
        end
    end


    function emitIncludes(codeWriter,fileList,needExternC)



        if needExternC
            codeWriter.wLine('extern "C" {');
            codeWriter.incIndent;
        end

        for ii=1:numel(fileList)
            file=fileList{ii};
            dblQuote='"';
            if file(1)=='<'||file(1)=='"'
                dblQuote='';
            end
            codeWriter.wLine('#include %s%s%s',dblQuote,file,dblQuote);
        end

        if needExternC
            codeWriter.decIndent;
            codeWriter.wLine('}');
            codeWriter.wNewLine;
        end


