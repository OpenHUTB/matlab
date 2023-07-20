function[success,errorid]=applyproperties(this,dlghandle,kind)







    success=true;
    errorid='';

    switch kind
    case 'new'
        this.packagename=strtrim(dlghandle.getWidgetValue('Tfldesigner_PackageName'));
        this.classname=strtrim(dlghandle.getWidgetValue('Tfldesigner_EntryClass'));

        index=dlghandle.getWidgetValue('Tfldesigner_BaseEntryClass');
        switch index
        case 0
            this.custombaseclass='RTW.TflCOperationEntryML';
        otherwise
            this.custombaseclass='RTW.TflCFunctionEntryML';
        end
        this.customfilepath=strtrim(dlghandle.getWidgetValue('Tfldesigner_NewLocationCType'));

        if isempty(this.classname)
            errorstr=DAStudio.message('RTW:tfldesigner:InvalidCustomClassName');
            dp=DAStudio.DialogProvider;
            dp.errordlg(errorstr,DAStudio.message('RTW:tfldesigner:ErrorText'),true);
            return;
        end

        this.addcustomclass('new');

        dlghandle.delete;

    case 'open'

        pkgname=strtrim(dlghandle.getWidgetValue('Tfldesigner_PackageName'));

        if~isempty(pkgname)&&~isempty(strfind(pkgname(1),'+'))
            pkgname=pkgname(2:end);
        end

        this.packagename=pkgname;

        [~,clsname,~]=fileparts(strtrim(dlghandle.getWidgetValue('Tfldesigner_EntryClass')));

        if~isempty(clsname)&&~isempty(strfind(clsname(1),'@'))
            clsname=clsname(2:end);
        end

        this.classname=clsname;

        dirname=strtrim(dlghandle.getWidgetValue('Tfldesigner_OpenLocationCType'));
        if length(strfind(dirname,'+'))==1
            dirname=fullfile(dirname,'..');
        elseif length(strfind(dirname,'+'))>1
            dp=DAStudio.DialogProvider;
            dp.errordlg(DAStudio.message('RTW:tfldesigner:ErrorInvalidPath'),...
            DAStudio.message('RTW:tfldesigner:ErrorText'),true);
            return;
        end
        this.customfilepath=dirname;

        if isempty(this.classname)
            errorstr=DAStudio.message('RTW:tfldesigner:InvalidCustomClassName');
            dp=DAStudio.DialogProvider;
            dp.errordlg(errorstr,DAStudio.message('RTW:tfldesigner:ErrorText'),true);
            return;
        end

        ok=this.addcustomclass('open');

        if ok
            dlghandle.delete;
        end
    end

