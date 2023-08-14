function[success,errorid]=applyproperties(this,dlghandle)




    success=true;
    errorid='';

    value=dlghandle.getWidgetValue('Tfldesigner_RegistryBaseTfl');
    if strcmp(value,'<Custom>')
        message=DAStudio.message('RTW:tfldesigner:InvalidBaseTflName');
        errorid=message;
        success=false;
        return;
    end

    dirname=uigetdir(pwd,...
    DAStudio.message('RTW:tfldesigner:SelectRegistrationFileLoc'));

    if dirname~=0
        if length(strfind(dirname,'+'))==1
            dirname=dirname(1:strfind(dirname,'+')-2);
        elseif length(strfind(dirname,'+'))>1
            dp=DAStudio.DialogProvider;
            dp.errordlg(DAStudio.message('RTW:tfldesigner:ErrorInvalidPath'),...
            DAStudio.message('RTW:tfldesigner:ErrorText'),true);
            return;
        end
        this.savepath=dirname;
    else
        success=false;
        return;
    end


    this.applydataspec(dlghandle);

    filename='rtwTargetInfo';
    ext='.m';

    try
        file=fopen(fullfile(this.savepath,[filename,ext]),'w');

        if(file==-1)

            dir=this.savepath;
            if isempty(this.savepath)
                dir=pwd;
            end
            message=DAStudio.message('RTW:tfldesigner:FileGenError',dir);
            errorid=message;
            success=false;
            return;
        end

        fprintf(file,['function ',filename,'(cm)\n\n']);
        fprintf(file,'cm.registerTargetInfo(@loc_register_crl);\n\n');

        fprintf(file,'function this = loc_register_crl\n\n');

        fprintf(file,'this(1) = RTW.TflRegistry;\n');
        fprintf(file,'this(1).Name = ''%s'';\n',...
        loc_format(strtrim(dlghandle.getWidgetValue('Tfldesigner_RegistryName'))));

        fprintf(file,'this(1).TableList = {');
        list=dlghandle.getWidgetValue('Tfldesigner_RegistryTableList');
        printcell(file,list);

        value=dlghandle.getWidgetValue('Tfldesigner_RegistryBaseTfl');
        if(strcmp(value,'None'))
            value='';
        end
        fprintf(file,'this(1).BaseTfl = ''%s'';\n',value);

        fprintf(file,'this(1).TargetHWDeviceType = {');
        list=dlghandle.getWidgetValue('Tfldesigner_RegistryTargetHWDevice');
        if isempty(list)
            list='*';
        end
        printcell(file,list);

        fprintf(file,'this(1).Description = ''%s'';\n',...
        loc_format(dlghandle.getWidgetValue('Tfldesigner_RegistryDescription')));


        this.printdataalignment(file);

        fclose(file);
        file=[];

        dir=this.savepath;
        if isempty(this.savepath)
            dir=pwd;
        end
        dp=DAStudio.DialogProvider;
        message=DAStudio.message('RTW:tfldesigner:RegistrationFileGenerated',...
        fullfile(dir,[filename,ext]));
        title=DAStudio.message('RTW:tfldesigner:FileGenComplete');
        dp.msgbox(message,title,true);

    catch ME
        errorid=ME.message;
        if~isempty(file)
            fclose(file);
        end
        if exist(fullfile(this.savepath,[filename,ext]),'file')==2
            delete(fullfile(this.savepath,[filename,ext]));
        end
        success=false;
        return;
    end


    function printcell(file,list)

        [list,remain]=strtok(list,',');
        fprintf(file,'''%s''',strtrim(list));
        while~isempty(remain)
            [list,remain]=strtok(remain,',');%#ok
            fprintf(file,',''%s''',strtrim(list));
        end
        fprintf(file,'};\n');


        function inStr=loc_format(inStr)
            indices=strfind(inStr,'''');
            if~isempty(indices)
                for i=1:length(indices)
                    inStr=[inStr(1:indices(i)),'''',inStr(indices(i)+1:end)];
                end
            end



