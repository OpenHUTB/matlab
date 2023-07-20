function success=addcustomclass(customobj,type)








    me=TflDesigner.getexplorer;
    rt=me.getRoot;

    success=true;

    currnode=rt.currenttreenode;
    me.setStatusMessage(DAStudio.message('RTW:tfldesigner:CreateCustomClass'));
    [path,name,ext]=fileparts(currnode.Name);%#ok

    ResourcePath=fullfile(fileparts(mfilename('fullpath')),'..','resources');

    if strcmpi(name,'HitCache')||...
        strcmpi(name,'MissCache')||...
        strcmpi(ext,'.mat')||...
        strcmpi(ext,'.p')


        me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ErrorEntryNotAllowed'));
        return;
    else
        try
            if strcmp(type,'new')

                if~isempty(customobj.packagename)
                    mkdir(customobj.customfilepath,strcat('+',customobj.packagename));
                    directory=fullfile(customobj.customfilepath,strcat('+',customobj.packagename));
                else
                    directory=fullfile(customobj.customfilepath);
                end
                mkdir(directory,strcat('@',customobj.classname));


                customobj.createcustomclassfile;


                filename=fullfile(directory,strcat('@',customobj.classname),...
                strcat(customobj.classname,'.m'));
                edit(filename);

            else
                if~isempty(customobj.packagename)
                    directory=fullfile(customobj.customfilepath,strcat('+',customobj.packagename),...
                    strcat('@',customobj.classname));
                else
                    directory=fullfile(customobj.customfilepath,...
                    strcat('@',customobj.classname));
                end

                filename=fullfile(directory,strcat(customobj.classname,'.m'));
            end

            addpath(customobj.customfilepath);


            try
                if~isempty(customobj.packagename)
                    entry=eval([customobj.packagename,'.',customobj.classname]);
                else
                    entry=eval(customobj.classname);
                end
            catch ME
                dp=DAStudio.DialogProvider;
                dp.errordlg(ME.message,DAStudio.message('RTW:tfldesigner:ErrorText'),true);
                success=false;
                me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ErrorCreatingEntry'))
                return;
            end

            currelem=currnode.addchild(entry,false);
            currelem.iscustomtype=true;
            currelem.customfilepath=filename;


            am=DAStudio.ActionManager;
            if~isempty(customobj.packagename)
                action=am.createAction(me,...
                'icon',fullfile(ResourcePath,'new_entry.png'),...
                'Text',DAStudio.message('RTW:tfldesigner:FileCustomClassEntry',customobj.packagename,customobj.classname),...
                'ToolTip',DAStudio.message('RTW:tfldesigner:FileCustomClassEntryToolTip',customobj.packagename,customobj.classname),...
                'StatusTip',DAStudio.message('RTW:tfldesigner:FileCustomClassEntryStatusTip',customobj.packagename,customobj.classname),...
                'Callback',['TflDesigner.cba_createcustomentry(''',customobj.packagename,'.',customobj.classname,''');']);
                me.customactions.(['FILE_NEW_CUSTOM_ENTRY_',customobj.packagename,'_',customobj.classname])=action;
            else
                action=am.createAction(me,...
                'icon',fullfile(ResourcePath,'new_entry.png'),...
                'Text',DAStudio.message('RTW:tfldesigner:FileCustomClassEntryNoPackage',customobj.classname),...
                'ToolTip',DAStudio.message('RTW:tfldesigner:FileCustomClassEntryNoPackageToolTip',customobj.classname),...
                'StatusTip',DAStudio.message('RTW:tfldesigner:FileCustomClassEntryNoPackageStatusTip',customobj.classname),...
                'Callback',['TflDesigner.cba_createcustomentry(''',customobj.classname,''');']);
                me.customactions.(['FILE_NEW_CUSTOM_ENTRY_',customobj.classname])=action;
            end
            me.createui;
            me.show;
            TflDesigner.setcurrentlistnode(currelem);
        catch ME
            dp=DAStudio.DialogProvider;
            dp.errordlg(ME.message,DAStudio.message('RTW:tfldesigner:ErrorText'),true);
        end
    end

    me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ReadyStatus'));


