function customlocation(this,dlghandle,tag)








    switch tag

    case 'Tfldesigner_NewLocationButton'

        dirname=uigetdir(pwd,DAStudio.message('RTW:tfldesigner:NewCustomClassSaveLocation'));

        if dirname~=0
            this.customfilepath=dirname;
        end

    case 'Tfldesigner_OpenLocationButton'
        dirname=uigetdir(pwd,DAStudio.message('RTW:tfldesigner:ExistingCustomClassLocation'));

        if dirname~=0
            packagename='';
            classname='';
            if length(strfind(dirname,'+'))==1
                if length(strfind(dirname,'@'))==1
                    classname=dirname(strfind(dirname,'@'):end);
                    dirname=dirname(1:strfind(dirname,'@')-2);
                end
                packagename=dirname(strfind(dirname,'+'):end);
                dirname=dirname(1:strfind(dirname,'+')-2);
            elseif length(strfind(dirname,'+'))>1
                dp=DAStudio.DialogProvider;
                dp.errordlg(DAStudio.message('RTW:tfldesigner:ErrorInvalidPath'),...
                DAStudio.message('RTW:tfldesigner:ErrorText'),true);
                return;
            end
            this.customfilepath=dirname;
            dlghandle.setWidgetValue('Tfldesigner_PackageName',packagename);
            dlghandle.setWidgetValue('Tfldesigner_EntryClass',classname);
        end
    end