function writeSfcnMdlDefines(h,fid,infoStruct)





    fprintf(fid,'/*\n');
    fprintf(fid,' * Must specify the S_FUNCTION_NAME as the name of the S-function.\n');
    fprintf(fid,' */\n');

    fprintf(fid,'#define S_FUNCTION_NAME  %s\n',infoStruct.Specs.SFunctionName);
    fprintf(fid,'#define S_FUNCTION_LEVEL 2\n');
    fprintf(fid,'\n');

    fprintf(fid,'/*\n');
    fprintf(fid,' * Need to include simstruc.h for the definition of the SimStruct and\n');
    fprintf(fid,' * its associated macro definitions.\n');
    fprintf(fid,' */\n');
    fprintf(fid,'#include "simstruc.h"\n');
    fprintf(fid,'\n');




    if infoStruct.canUseSFcnCGIRAPI||strcmp(infoStruct.Specs.Options.language,'C++')
        fprintf(fid,'/* Ensure that this S-Function is compiled with a C++ compiler */\n');
        fprintf(fid,'#ifndef __cplusplus\n');
        fprintf(fid,'#error This S-Function must be compiled with a C++ compiler. Enter mex(''-setup'') in the MATLAB Command Window to configure a C++ compiler.\n');
        fprintf(fid,'#endif\n');
    end

    if infoStruct.canUseSFcnCGIRAPI
        fprintf(fid,'/* Required header for accessing the SFunctionCodeConstruction API */\n');
        fprintf(fid,'#if defined(MATLAB_MEX_FILE)\n');
        fprintf(fid,'#define RTWCG_S_FUNCTION_API_REV 1\n');
        fprintf(fid,'#include "sfun_rtwcg.hpp"\n');
        fprintf(fid,'#endif\n');
        fprintf(fid,'\n');
    end



    nbInfo=size(infoStruct.DataTypes.BusInfo.BusElementHashTable,1);
    if(nbInfo~=0)||(infoStruct.DWorks.NumDWorkFor2DMatrix>0)
        fprintf(fid,'#include <string.h>\n');
        fprintf(fid,'#include <stdlib.h>\n');
        fprintf(fid,'\n');
    end


    headerFiles=legacycode.util.lct_pCollectAllHeaderFiles(infoStruct);

    if~isempty(headerFiles.GlobalHeaderFiles)
        fprintf(fid,'/*\n');
        fprintf(fid,' * Specific header file(s) required by the legacy code function.\n');
        fprintf(fid,' */\n');



        if infoStruct.canUseSFcnCGIRAPI&&strcmp(infoStruct.Specs.Options.language,'C')
            fprintf(fid,'extern "C" {\n');
        end
        for ii=1:length(headerFiles.GlobalHeaderFiles)
            thisHeaderFile=headerFiles.GlobalHeaderFiles{ii};
            dblQuote='"';
            if thisHeaderFile(1)=='<'||thisHeaderFile(1)=='"'
                dblQuote='';
            end
            fprintf(fid,'#include %s%s%s\n',dblQuote,thisHeaderFile,dblQuote);
        end

        if infoStruct.canUseSFcnCGIRAPI&&strcmp(infoStruct.Specs.Options.language,'C')
            fprintf(fid,'}\n');
            fprintf(fid,'\n');
        end
        fprintf(fid,'\n');
    end

    if~isempty(headerFiles.SlObjHeaderFiles)
        fprintf(fid,'/*\n');
        fprintf(fid,' * Specific header file(s) required for data types declarations.\n');
        fprintf(fid,' */\n');
        for ii=1:length(headerFiles.SlObjHeaderFiles)
            thisHeaderFile=headerFiles.SlObjHeaderFiles{ii};
            dblQuote='"';
            if thisHeaderFile(1)=='<'||thisHeaderFile(1)=='"'
                dblQuote='';
            end
            fprintf(fid,'#include %s%s%s\n',dblQuote,thisHeaderFile,dblQuote);
        end
        fprintf(fid,'\n');
    end

    if infoStruct.hasWrapper
        fprintf(fid,'/*\n');
        fprintf(fid,' * Code Generation Environment flag (simulation or standalone target).\n');
        fprintf(fid,' */\n');
        fprintf(fid,'static int_T isSimulationTarget;\n');
    end


    hasSampleTimeAsParameter=strcmp(infoStruct.SampleTime,'parameterized');

    if infoStruct.Parameters.Num~=0||hasSampleTimeAsParameter
        fprintf(fid,'#define EDIT_OK(S, P_IDX) \\\n');
        fprintf(fid,'       (!((ssGetSimMode(S)==SS_SIMMODE_SIZES_CALL_ONLY) && mxIsEmpty(ssGetSFcnParam(S, P_IDX))))\n');
        fprintf(fid,'\n');
    end

    if hasSampleTimeAsParameter

        fprintf(fid,'#define SAMPLE_TIME (ssGetSFcnParam(S, %d))\n',infoStruct.Parameters.Num);
        fprintf(fid,'\n');
    end

    fprintf(fid,'\n');

    isDWorkNeeded=['((!((ssRTWGenIsCodeGen(S) || ssGetSimMode(S)==SS_SIMMODE_EXTERNAL) && isSimulationTarget==0))'...
    ,' || ssIsRapidAcceleratorActive(S))'];

    fprintf(fid,['#define isDWorkNeeded(S) ',isDWorkNeeded,'\n\n']);


    if infoStruct.hasSLObject||infoStruct.hasWrapper||hasSampleTimeAsParameter
        fprintf(fid,'/*\n');
        fprintf(fid,' * Utility function prototypes.\n');
        fprintf(fid,' */\n');
        if hasSampleTimeAsParameter


            fprintf(fid,'static bool IsRealMatrix(const mxArray *m);\n');
        end
        if infoStruct.hasSLObject

            fprintf(fid,'static void CheckDataTypes(SimStruct *S);\n');
        end
        if infoStruct.hasWrapper


            fprintf(fid,'static int_T GetRTWEnvironmentMode(SimStruct *S);\n');
        end
    end


