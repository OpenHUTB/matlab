function code_model_interface_header_file(fileNameInfo)



    import CGXE.Coder.*;

    fileName=fullfile(fileNameInfo.targetDirName,'modelInterface.h');

    file=fopen(fileName,'Wt');
    if file<0
        throw(MException('Simulink:cgxe:FailedToCreateFile',fileName));
    end

    fprintf(file,'/* Model Interface Include files */\n');
    fprintf(file,'#include "%s"\n',fileNameInfo.modelHeaderFile);

    fclose(file);
    try_indenting_file(fileName);
