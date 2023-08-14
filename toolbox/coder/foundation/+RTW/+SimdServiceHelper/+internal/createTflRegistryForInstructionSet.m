function success=createTflRegistryForInstructionSet(instructionSetName,tableName,hardwareNameArray,savepath,isOverwrite)
    filename='rtwTargetInfo';
    ext='.m';
    fullFile=fullfile(savepath,[filename,ext]);

    try
        if isfile(fullFile)&&~isOverwrite
            file=fopen(fullFile,'a+');
            fprintf(file,'\n\n');
            fprintf(file,'idx = idx+1;\n');
        else
            file=fopen(fullFile,'w');
            fprintf(file,['function ',filename,'(cm)\n\n']);
            fprintf(file,'cm.registerTargetInfo(@loc_register_crl);\n\n');

            fprintf(file,'function this = loc_register_crl\n\n');
            fprintf(file,'idx = 1;\n');
        end

        fprintf(file,'this(idx) = RTW.TflRegistry;\n');

        libraryName=['generated_',instructionSetName,'_SIMD_Library'];
        fprintf(file,'this(idx).Name = ''%s'';\n',libraryName);

        fprintf(file,'this(idx).TableList = {''%s''};\n',[tableName,'.mat']);
        fprintf(file,'this(idx).BaseTfl = ''%s'';\n','');
        fprintf(file,'this(idx).IsVisible = false;\n');

        printSupportedHardwares(file,hardwareNameArray);

        Description=['Automatically generated SIMD library for ',instructionSetName];
        fprintf(file,'this(idx).Description = ''%s'';\n',Description);


        this.printdataalignment(file);

        fclose(file);
        success=true;
    catch
        success=false;
    end

end


function printSupportedHardwares(file,hardwareNameArray)
    fprintf(file,'this(idx).TargetHWDeviceType = {');
    if isempty(hardwareNameArray)
        fprintf(file,'''%s''','*');
    else
        num=length(hardwareNameArray);
        for i=1:num-1
            fprintf(file,'''%s'', ',hardwareNameArray{i});
        end
        fprintf(file,'''%s''',hardwareNameArray{num});
    end
    fprintf(file,'};\n');
end