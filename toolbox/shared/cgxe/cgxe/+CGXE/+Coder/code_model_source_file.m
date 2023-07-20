function code_model_source_file(fileNameInfo,modelName)



    import CGXE.Coder.*;

    fileName=fullfile(fileNameInfo.targetDirName,fileNameInfo.modelSourceFile);

    file=fopen(fileName,'Wt');
    if file<0
        throw(MException('Simulink:cgxe:FailedToCreateFile',fileName));
    end

    fprintf(file,'/* Include files */\n');
    fprintf(file,'#include "%s"\n',fileNameInfo.modelHeaderFile);

    for i=1:length(fileNameInfo.moduleHeaderFiles)
        fprintf(file,'#include "%s"\n',fileNameInfo.moduleHeaderFiles{i});
    end
    fprintf(file,'\n');






    fprintf(file,'\n');
    fprintf(file,'unsigned int cgxe_%s_method_dispatcher(SimStruct* S, int_T method, void* data)\n',modelName);
    fprintf(file,'{\n');
    for i=1:fileNameInfo.numModules
        fprintf(file,'    if (ssGetChecksum0(S) == %.17g &&\n',fileNameInfo.moduleInfo(i).checksums(1));
        fprintf(file,'        ssGetChecksum1(S) == %.17g &&\n',fileNameInfo.moduleInfo(i).checksums(2));
        fprintf(file,'        ssGetChecksum2(S) == %.17g &&\n',fileNameInfo.moduleInfo(i).checksums(3));
        fprintf(file,'        ssGetChecksum3(S) == %.17g) {\n',fileNameInfo.moduleInfo(i).checksums(4));
        fprintf(file,'        method_dispatcher_%s(S, method, data);\n',fileNameInfo.moduleUniqNames{i});
        fprintf(file,'        return 1;\n');
        fprintf(file,'    }\n');
    end
    fprintf(file,'    return 0;\n');
    fprintf(file,'}\n');
    fprintf(file,'\n');
    fclose(file);
    try_indenting_file(fileName);
