function customCodeEmitFiles(ccChecksum,customCodeSettings,ccEmitFiles,targetDir,neeedSourceFile,useMExForDLL)


    emitTheHeader(ccChecksum,customCodeSettings,ccEmitFiles,targetDir,useMExForDLL);

    if neeedSourceFile
        emitTheSource(ccChecksum,customCodeSettings,ccEmitFiles,targetDir);
    end

    function emitTheSource(ccChecksum,customCodeSettings,ccEmitFiles,targetDir)%#ok<*INUSL>
        fileName=fullfile(targetDir,ccEmitFiles.customCodeSourceFile);
        file=fopen(fileName,'Wt','n',slCharacterEncoding);
        if file<3
            error(sprintf('Failed to create file: %s.',fileName),1);
        end


        fprintf(file,'#include "%s"\n',ccEmitFiles.customCodeHeaderFile);
        fprintf(file,'\n');
        if~isempty(customCodeSettings.customSourceCode)
            fprintf(file,'/* Custom Source Code */\n');
            fprintf(file,'%s\n',customCodeSettings.customSourceCode);
            fprintf(file,'\n');
        end

        fprintf(file,'/* Function Definition */\n');
        if~isempty(customCodeSettings.customInitializer)
            fprintf(file,'void %s(void)\n',ccEmitFiles.initFcnName);
            fprintf(file,'{\n');
            fprintf(file,'   %s\n',customCodeSettings.customInitializer);
            fprintf(file,'}\n');
        end
        fprintf(file,'\n');
        if~isempty(customCodeSettings.customTerminator)
            fprintf(file,'void %s(void)\n',ccEmitFiles.termFcnName);
            fprintf(file,'{\n');
            fprintf(file,'   %s\n',customCodeSettings.customTerminator);
            fprintf(file,'}\n');
        end
        fprintf(file,'\n');

        fclose(file);

        function emitTheHeader(ccChecksum,customCodeSettings,ccEmitFiles,targetDir,useMExForDLL)

            fileName=fullfile(targetDir,ccEmitFiles.customCodeHeaderFile);
            file=fopen(fileName,'Wt','n',slCharacterEncoding);
            if file<3
                error(sprintf('Failed to create file: %s.',fileName),1);
            end
            fprintf(file,'#ifndef __customcode_%s_h__\n',ccChecksum);
            fprintf(file,'#define __customcode_%s_h__\n',ccChecksum);
            fprintf(file,'\n');
            fprintf(file,'/* Include files */\n');
            fprintf(file,'#include "mex.h"\n');
            fprintf(file,'#include <string.h>\n');
            fprintf(file,'#include <stdlib.h>\n');
            fprintf(file,'#include <math.h>\n');
            fprintf(file,'#include "tmwtypes.h"\n');
            fprintf(file,'\n');
            fprintf(file,'\n');

            fprintf(file,'/* Helper definitions for DLL support */\n');
            fprintf(file,'#if defined _WIN32 \n');
            if useMExForDLL
                fprintf(file,'  #define DLL_EXPORT_CC __declspec(dllexport)\n');
            else
                fprintf(file,'  #define DLL_EXPORT_CC    \n');
            end
            fprintf(file,'#else\n');
            fprintf(file,'  #if __GNUC__ >= 4\n');
            fprintf(file,'    #define DLL_EXPORT_CC __attribute__ ((visibility ("default")))\n');
            fprintf(file,'  #else\n');
            fprintf(file,'    #define DLL_EXPORT_CC\n');
            fprintf(file,'  #endif\n');
            fprintf(file,'#endif\n');

            if~isempty(customCodeSettings.customCode)
                fprintf(file,'/* Custom Code from Simulation Target dialog */\n');
                fprintf(file,'%s\n',customCodeSettings.customCode);
                fprintf(file,'\n');
            end

            fprintf(file,'/* Function Declarations */\n');
            fprintf(file,'#ifdef __cplusplus\n');
            fprintf(file,'extern "C" {\n');
            fprintf(file,'#endif\n');
            if isempty(customCodeSettings.customInitializer)
                fprintf(file,'#define %s()\n',ccEmitFiles.initFcnName);
            else
                fprintf(file,'DLL_EXPORT_CC void %s(void);\n',ccEmitFiles.initFcnName);
            end
            fprintf(file,'\n');
            if isempty(customCodeSettings.customTerminator)
                fprintf(file,'#define %s()\n',ccEmitFiles.termFcnName);
            else
                fprintf(file,'DLL_EXPORT_CC void %s(void);\n',ccEmitFiles.termFcnName);
            end
            fprintf(file,'#ifdef __cplusplus\n');
            fprintf(file,'}\n');
            fprintf(file,'#endif\n');
            fprintf(file,'\n');
            fprintf(file,'#endif\n');
            fprintf(file,'\n');
            fclose(file);
