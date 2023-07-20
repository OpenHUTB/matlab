

classdef Manager<handle
    properties(Access='protected')
        GalleryPopup;
        Version='1.1.0';
        Categories={};
        Commands={};
        DefaultIcons={};
        CustomIcons={};
        SpecifyCustomIcon=[];
        LastId=0;
    end

    properties(Constant)
        CommandTypes={'Script','Function'};
    end

    properties(Abstract,Constant)
        ConfigName{mustBeTextScalar};
        DefaultCategory;
        Namespace{mustBeTextScalar};
        PrefFile{mustBeTextScalar};
        QABClassName{mustBeTextScalar};
        RefreshEvent;
        CommandEditorHelpArgs;
    end

    methods(Static,Access='protected')
        function out=setGetInstance(subclassName,instance)
            out=[];
            persistent instances;

            if isempty(instances)
                instances=containers.Map;
            end

            if nargin>1
                instances(subclassName)=instance;
                out=instance;
            else
                if isKey(instances,subclassName)
                    out=instances(subclassName);
                end
            end
        end
    end

    methods(Static)
        function obj=get(varargin)
            if nargin>0
                subclassName=varargin{1};
            else
                DAStudio.error('Simulink:utility:invNumArgsWithAbsValue',mfilename,1);
            end

            instance=dig.FavoriteCommands.Manager.setGetInstance(subclassName);
            if isempty(instance)||~isvalid(instance)
                mgr=feval(subclassName);
                if~isempty(mgr)
                    instance=dig.FavoriteCommands.Manager.setGetInstance(subclassName,mgr);
                end
            end
            obj=instance;
        end

        function clearInstance(subclassName)
            dig.FavoriteCommands.Manager.setGetInstance(subclassName,[]);
        end

        function gw=generate(userdata,~)
            manager=dig.FavoriteCommands.Manager.get(userdata);
            gw=manager.GalleryPopup;
        end

        function ret=getCommandTypeByIndex(index)
            ret=dig.FavoriteCommands.Manager.CommandTypes{index};
        end

        function index=getCommandTypeIndex(command)
            if(~isfield(command,'type'))
                commandType=dig.FavoriteCommands.Manager.CommandTypes{1};
            else
                commandType=command.type;
            end

            isType=cellfun(@(x)isequal(x,commandType),dig.FavoriteCommands.Manager.CommandTypes);
            [~,index]=find(isType);
        end

        function executeScript(userdata,~)
            evalin('base',userdata);
        end


        function ret=executeCallback(userdata,cbinfo)%#ok<STOUT,INUSD>
            eval(userdata);
        end




        function newFavorite(userdata,~,~)
            this=dig.FavoriteCommands.Manager.get(userdata);

            if~this.showDialog(dig.FavoriteCommands.NewCommandDialog.Tag)
                src=dig.FavoriteCommands.NewCommandDialog(this);
                DAStudio.Dialog(src);
            end
        end

        function newFavoriteCategory(userdata,~,~)
            this=dig.FavoriteCommands.Manager.get(userdata);

            if~this.showDialog(dig.FavoriteCommands.NewCategoryDialog.Tag)
                src=dig.FavoriteCommands.NewCategoryDialog(this);
                DAStudio.Dialog(src);
            end
        end

        function editFavorite(userdata,cbinfo)
            this=dig.FavoriteCommands.Manager.get(userdata);

            [command,~]=this.findCommandByTagQAB(cbinfo.EventData);

            if~isempty(command)&&~this.showDialog(dig.FavoriteCommands.EditCommandDialog.Tag)
                src=dig.FavoriteCommands.EditCommandDialog(this,command);
                DAStudio.Dialog(src);
            end
        end

        function editFavoriteCategory(userdata,cbinfo)
            this=dig.FavoriteCommands.Manager.get(userdata);

            [category,~]=this.findCategoryByTag(cbinfo.EventData);

            if~isempty(category)&&~this.showDialog(dig.FavoriteCommands.EditCategoryDialog.Tag)
                src=dig.FavoriteCommands.EditCategoryDialog(this,category);
                DAStudio.Dialog(src);
            end
        end

        function deleteFavorite(userdata,cbinfo)
            this=dig.FavoriteCommands.Manager.get(userdata);

            [command,~]=this.findCommandByTagQAB(cbinfo.EventData);

            if~isempty(command)&&~this.showDialog(dig.FavoriteCommands.DeleteCommandDialog.Tag)
                src=dig.FavoriteCommands.DeleteCommandDialog(this,command);
                DAStudio.Dialog(src);
            end
        end

        function deleteFavoriteCategory(userdata,cbinfo)
            this=dig.FavoriteCommands.Manager.get(userdata);

            [category,~]=this.findCategoryByTag(cbinfo.EventData);

            if~isempty(category)&&~this.showDialog(dig.FavoriteCommands.DeleteCategoryDialog.Tag)
                src=dig.FavoriteCommands.DeleteCategoryDialog(this,category);
                DAStudio.Dialog(src);
            end
        end
    end

    methods
        function ret=getConfiguration(this)
            ret=dig.Configuration.getOrCreate(this.ConfigName,pwd);
        end

        function val=getPrefFile(this)
            val=fullfile(prefdir,this.PrefFile);
        end

        function ret=getQABManager(this)
            ret=dig.QABManager.get(this.QABClassName);
        end

        function categories=getCategories(this)
            categories=this.Categories;
        end

        function categories=getCategoryNames(this)
            categories=this.map(this.getCategories(),@(item)item.label);
        end

        function commands=getCommands(this)
            commands=this.Commands;
        end

        function categories=getElidedCategoryNames(this)
            categories=this.map(this.getCategories(),@(item)this.elideString(item.label,80));
        end

        function icons=getIcons(this)
            icons=this.filter({this.DefaultIcons{1:end},this.CustomIcons{1:end},this.SpecifyCustomIcon},@(item)isfile(item.DisplayIcon));
        end

        function icon=getIcon(this,property,value)
            icons=this.getIcons();
            icon=findByProperty(this,icons,property,value);
        end

        function ret=hasIcon(this,property,value)
            icons=this.getIcons();
            ret=~isempty(find(strcmp(cellfun(@(item)item.(property),icons,'UniformOutput',false),{value}),1));
        end

        function ret=getIconImageURI(this,tag,imageSize)
            icons=this.getIcons();
            icon=this.find(icons,@(item)isequal(item.Tag,tag));

            if(isempty(icon))
                icon=icons{1};
            end

            path=icon.DisplayIcon;

            ret=dig.resizeAndEncode(path,imageSize,imageSize);
        end

        function prefs=getPreferences(this)
            prefs.version=this.Version;
            prefs.categories=this.Categories;
            prefs.commands=this.Commands;
            prefs.icons=this.CustomIcons;
            prefs.lastid=this.LastId;
        end

        function ret=findDescendantWidget(this,parent,name)
            ret=[];

            for i=1:parent.Children.Size
                child=parent.Children(i);

                if(strcmp(child.Name,name))
                    ret=child;
                elseif(isprop(child,'Children')&&~isempty(child.Children))
                    foundChild=this.findDescendantWidget(child,name);

                    if(~isempty(foundChild))
                        ret=foundChild;
                    end
                end
            end
        end

        function widget=getWidget(this,name)
            widget=this.findDescendantWidget(this.GalleryPopup.Widget,name);

            command=this.findCommandByTag(name);

            if isempty(command)
                showQABLabel=false;
            else
                hasShowQABLabel=isfield(command,'showQABLabel');
                showQABLabel=hasShowQABLabel&&command.showQABLabel;
            end
            widget.ShowText=showQABLabel;
        end

        function ret=elideString(~,str,len)
            if length(str)>len
                ret=[str(1:len),'…'];
            else
                ret=str;
            end
        end

        function tag=generateCategoryTag(~,id)
            tag=['simulinkFavoriteCommandsGalleryCategory_',id];
        end

        function tag=generateCommandTag(~,id)
            tag=['simulinkFavoriteCommandsGalleryItem_',id];
        end




        function ret=filterByProperty(this,collection,property,value)
            ret=this.filter(collection,@(item)strcmp(item.(property),value)==1);
        end

        function ret=findByProperty(this,collection,property,value)
            ret=this.find(collection,@(item)strcmp(item.(property),value)==1);
        end

        function ret=findCategory(this,label)
            ret=this.findByProperty(this.Categories,'label',label);
        end

        function ret=findCommand(this,label)
            ret=this.findByProperty(this.getCommands(),'label',label);
        end

        function ret=findCommandsByCategory(this,category)
            ret=this.filterByProperty(this.getCommands(),'category',category.tag);
        end

        function[ret,index]=findByTag(this,collection,tag)
            [ret,index]=this.find(collection,@(item)strcmp(item.tag,tag)==1||...
            strcmp([this.Namespace,':',item.tag],tag)==1);
        end

        function[ret,index]=findCategoryByTag(this,tag)
            [ret,index]=this.findByTag(this.getCategories(),tag);
        end

        function[ret,index]=findCommandByTag(this,tag)
            [ret,index]=this.findByTag(this.getCommands(),tag);
        end

        function[ret,index]=findCommandByTagQAB(this,tag)
            prefix=['qab:',dig.QABManager.CustomQAGroupName,':'];
            if strncmp(tag,prefix,length(prefix))
                parts=strsplit(tag,':');
                tag=[this.Namespace,':',parts{3}];
            end
            [ret,index]=this.findByTag(this.getCommands(),tag);
        end

        function target=mergeByProperty(this,propertyName,target,source)
            prevLen=length(target);

            for i=1:length(source)
                n=source{i};

                if(isprop(n,propertyName)||isfield(n,propertyName))...
                    &&isempty(this.findByProperty(target,propertyName,n.(propertyName)))
                    prevLen=prevLen+1;
                    target{prevLen}=n;
                end
            end
        end




        function tag=addCategory(this,label)
            category.label=label;
            category.tag=this.generateCategoryTag(this.generateId);
            tag=category.tag;

            this.Categories{end+1}=category;

            this.reset();
        end

        function tag=addCommand(this,label,code,categoryIndex,type,icon,addToQAB,showQABLabel)

            categories=this.getCategories();
            category=categories{categoryIndex+1};

            command.label=label;

            command.category=category.tag;
            command.type=type;
            command.code=code;
            command.icon=icon;
            command.addToQAB=logical(addToQAB);
            command.showQABLabel=logical(showQABLabel);
            this.LastId=this.LastId+1;
            command.tag=this.generateCommandTag(num2str(this.LastId));

            this.Commands{end+1}=command;

            this.savePreferences(this.getPrefFile());
            this.reset();

            tag=command.tag;

            this.createQABWidgets();
            dig.postStringEvent(dig.QABManager.CustomRefreshEvent);
        end

        function tag=addCommandStruct(this,varargin)




            command=varargin{1};
            categoryIndex=0;
            if nargin>2
                categoryIndex=varargin{2};
            end

            tag=this.addCommand(command.label,command.code,categoryIndex,...
            command.type,command.icon,command.addToQAB,command.showQABLabel);
        end

        function editCategory(this,tag,label)
            [category,index]=this.findCategoryByTag(tag);

            if~isempty(category)
                category.tag=tag;
                category.label=label;

                this.Categories{index}=category;

                this.reset();
            end
        end



        function updateCommandShowQABLabel(this,tag,showQABLabel)
            [command,index]=this.findCommandByTag(tag);

            if~isempty(command)
                command.showQABLabel=logical(showQABLabel);

                this.Commands{index}=command;

                this.reset();
                dig.postStringEvent(this.RefreshEvent);
            end
        end

        function editCommand(this,tag,label,code,categoryIndex,type,icon,addToQAB,showQABLabel)


            category=this.Categories{categoryIndex+1};

            [command,index]=this.findCommandByTag(tag);

            if~isempty(command)
                command.label=label;
                command.tag=tag;
                command.type=type;
                command.code=code;
                command.icon=icon;
                command.addToQAB=logical(addToQAB);
                command.showQABLabel=logical(showQABLabel);
                command.category=category.tag;

                this.Commands{index}=command;

                this.reset();
                this.createQABWidgets();

                dig.postStringEvent(this.RefreshEvent);
            end
        end

        function deleteCategory(this,tag)
            [category,index]=this.findCategoryByTag(tag);

            if~isempty(index)
                this.Categories(:,index)=[];

                if isempty(this.Categories)
                    this.Categories={};
                end

                qabmanager=this.getQABManager();

                for i=1:length(this.Commands)
                    command=this.Commands{i};

                    if(strcmp(command.category,category.tag)&&isfield(command,'addToQAB')&&command.addToQAB==1)
                        qabmanager.removeCustomWidget(command.tag);
                    end
                end

                this.Commands=this.filter(this.Commands,@(item)strcmp(item.category,category.tag)==0);

                if isempty(this.Commands)
                    this.Commands={};
                end

                this.reset();
                this.createQABWidgets();
                dig.postStringEvent(dig.QABManager.CustomRefreshEvent);
            end
        end

        function deleteCommand(this,tag)
            [~,index]=this.findCommandByTag(tag);

            qabmanager=this.getQABManager();
            qabmanager.removeCustomWidget(tag);

            if~isempty(index)
                this.Commands(:,index)=[];

                if isempty(this.Commands)
                    this.Commands={};
                end

                this.reset();
            end
        end




        function tag=addIcon(this,label,path,tag)
            this.CustomIcons{end+1}=SampleActionBuilder(label,path,tag);
        end

        function updateCommandAtIndex(this,idx,command)
            this.Commands{idx}=command;
        end

        function restorePreferencesFromStruct(this,prefs)
            rmIdx=0;
            if isstruct(prefs)
                if isfield(prefs,'lastid')
                    this.LastId=prefs.lastid;
                end

                if isfield(prefs,'categories')
                    if iscell(prefs.categories)
                        this.Categories=prefs.categories;
                    else


                        this.Categories=cell(1,length(prefs.categories));

                        for i=1:length(prefs.categories)
                            this.Categories{i}=prefs.categories(i);
                        end
                    end


                    [~,rmIdx]=this.findByTag(this.Categories,this.DefaultCategory.tag);
                    if rmIdx>0
                        this.Categories{rmIdx}=this.DefaultCategory;
                    end
                end

                if isfield(prefs,'commands')
                    this.Commands=prefs.commands;
                end

                if isfield(prefs,'icons')
                    this.CustomIcons=this.filter(prefs.icons,@(item)isfile(item.DisplayIcon));
                end
            end

            if isempty(this.findByTag(this.Categories,this.DefaultCategory.tag))
                this.Categories={this.DefaultCategory,this.Categories{1:end}};
            end

            this.reset();

            dig.postStringEvent(this.RefreshEvent);
            dig.postStringEvent(dig.QABManager.CustomRefreshEvent);
        end

        function restoreFactoryPresets(this)
            this.clearSavedPrefs();

            this.Categories={};
            this.Commands={};
            this.CustomIcons={};
            this.LastId=0;

            this.restorePreferences();
        end




        function backupPath=backupPreferences(this,prefs)
            backupPath=[this.getPrefFile,'.bak'];
            save(backupPath,'-struct','prefs','-mat');
        end

        function clearSavedPrefs(this)
            if exist(this.getPrefFile,'file')==2
                delete(this.getPrefFile);
            end
        end

        function loadPreferences(this,prefFilePath,varargin)
            prefs=this.readPreferences(prefFilePath);

            if(nargin>2&&varargin{1})

                if isfield(prefs,'commands')&&~isempty(prefs.commands)
                    for i=1:length(prefs.commands)
                        prefs.commands{i}.addToQAB=false;
                    end
                end
            end

            this.restorePreferencesFromStruct(prefs);
        end

        function prefs=readPreferences(~,prefFilePath)
            prefs=[];

            if exist(prefFilePath,'file')==2
                prefs=load(prefFilePath,'-mat');
            end
        end

        function restorePreferences(this)
            prefs=this.readPreferences(this.getPrefFile);
            this.restorePreferencesFromStruct(prefs);
        end

        function savePreferences(this,prefFilePath)
            prefs=this.getPreferences();


            save(prefFilePath,'-struct','prefs','-mat');
        end




        function createQABWidgets(this)
            commands=this.getCommands();
            for i=1:length(commands)
                command=commands{i};
                qabmanager=this.getQABManager();
                hasAddToQAB=isfield(command,'addToQAB');

                if(hasAddToQAB)
                    if(command.addToQAB)
                        widget=this.getWidget(command.tag);
                        shouldAddQABLabel=isfield(command,'showQABLabel')&&command.showQABLabel;
                        qabmanager.addWidgetToCustomGroup(widget,shouldAddQABLabel);
                    else
                        qabmanager.removeCustomWidget(command.tag);
                    end
                end
            end
        end

        function removeFavoritesFromQAB(this)
            qabManager=this.getQABManager();
            commands=this.getCommands();

            for i=1:length(commands)
                if commands{i}.addToQAB

                    qabManager.removeCustomWidget(commands{i}.tag);
                end
            end
        end

        function resetCommandQABSettings(this,tag)
            [command,index]=this.findCommandByTag(tag);

            if~isempty(command)
                command.addToQAB=false;
                command.showQABLabel=false;

                this.Commands{index}=command;

                this.createQABWidgets();
            end
        end

        function resetQABSettings(this)
            commands=this.getCommands();

            for i=1:length(commands)
                command=commands{i};
                command.addToQAB=false;
                command.showQABLabel=false;

                this.updateCommandAtIndex(i,command);
            end

            this.reset();
            this.createQABWidgets();
        end
    end

    methods(Access='protected')
        function ret=generateId(this)
            this.LastId=this.LastId+1;


            ret=num2str(this.LastId);
        end

        function ret=showDialog(~,tag)
            dlg=findDDGByTag(tag);

            if(~isempty(dlg)&&ishandle(dlg))
                dlg.show;
                ret=true;
            else
                ret=false;
            end
        end

        function ret=map(~,collection,fn)
            ret={};

            for i=1:length(collection)
                item=collection{i};
                ret=[ret(:)',{fn(item)}];
            end
        end

        function ret=filter(~,collection,fn)
            ret={};

            for i=1:length(collection)
                item=collection{i};

                if fn(item)
                    ret=[ret(:)',{item}];
                end
            end
        end

        function[ret,index]=find(~,collection,fn)
            ret={};
            index=-1;

            for i=1:length(collection)
                item=collection{i};

                if fn(item)
                    ret=item;
                    index=i;
                    break;
                end
            end
        end

        function widget=createGalleryPopup(this)
            widget=dig.GeneratedWidget(this.Namespace,'EditableGalleryPopup');
            widget.Widget.FooterName='simulinkFavoriteCommandsGalleryPopupFooter';
            widget.Widget.FavoritesEnabled=false;
            widget.Widget.ReorderCategory=true;
            widget.Widget.DisplayState='list_view';
            widget.Widget.ListViewDisplayDensity='compact';
            widget.Widget.ActionId='simulinkEditFavoriteCommandAction';
            widget.Widget.QabEligible=false;
        end

        function action=createCommandAction(this,name,command)
            action=this.GalleryPopup.createAction(name);
            action.enabled=true;
            action.optOutBusy=true;
            action.optOutLocked=true;

            if(isfield(command,'icon'))
                icon=command.icon;
            else
                icons=this.getIcons();
                icon=icons{1};
            end

            action.icon=this.getIconImageURI(icon,16);

            if(~isequal(command.label,command.code))
                action.description=command.code;
            end

            if(isequal(command.label,''))
                action.text=command.code;
            else
                action.text=command.label;
            end

            if(~isfield(command,'type')||strcmp(command.type,'Script')==1)
                action.setCallbackFromArray({'dig.FavoriteCommands.Manager.executeScript',command.code},dig.model.FunctionType.Action);
            else
                action.setCallbackFromArray({'dig.FavoriteCommands.Manager.executeCallback',command.code},dig.model.FunctionType.Action);
            end
        end

        function widget=createGalleryCategory(this,category,index)
            widget=this.GalleryPopup.Widget.addChild('GalleryCategory',category.tag);
            widget.Label=category.label;
            widget.HideWhenEmpty=false;
            widget.Index=index;
        end

        function widget=createGalleryItem(this,parent,command)
            widget=parent.addChild('GalleryItem',command.tag);

            if isempty(strtrim(command.label))
                if~isempty(command.code)
                    code=command.code;
                    stripCode=strip(code,'left');
                    p=regexp(stripCode,'%','once');

                    if~isempty(p)&&p==1
                        stripCode(p)=' ';
                        stripCode=strip(stripCode,'left');
                    end

                    widget.TextOverride=stripCode;
                end
            else
                widget.TextOverride=command.label;
            end

            action=this.createCommandAction([widget.Name,'_Action'],command);

            widget.ActionId=[this.Namespace,':',action.name];

            if(isfield(command,'icon')&&this.hasIcon('Tag',command.icon))
                icon=this.getIcon('Tag',command.icon);
            else
                icons=this.getIcons();
                icon=icons{1};
            end

            widget.IconOverride=this.getIconImageURI(icon.Tag,16);
        end

        function reset(this)
            this.setDefaultIcons();
            config=this.getConfiguration();

            if(~isempty(config.getGeneratedWidget(this.Namespace)))
                config.removeGeneratedWidget(this.Namespace);
            end

            this.GalleryPopup=this.createGalleryPopup();

            if isempty(this.findByTag(this.Categories,this.DefaultCategory.tag))
                this.DefaultGalleryCategory=this.createGalleryCategory(this.DefaultCategory,0);
                defaultCategoryCommands=this.findCommandsByCategory(this.DefaultCategory);

                for i=1:length(defaultCategoryCommands)
                    this.createGalleryItem(this.DefaultGalleryCategory,defaultCategoryCommands{i});
                end
            end

            for i=1:length(this.Categories)
                category=this.Categories{i};
                categoryWidget=this.createGalleryCategory(category,i);
                commands=this.findCommandsByCategory(category);

                for j=1:length(commands)
                    this.createGalleryItem(categoryWidget,commands{j});
                end
            end

            if(isempty(config.getGeneratedWidget(this.Namespace)))
                config.addGeneratedWidget(this.GalleryPopup);
            end
        end


        function setDefaultIcons(this)
            iconDir=[matlabroot,'/toolbox/simulink/ui/studio/config/icons/favorites/'];

            this.DefaultIcons={...
            SampleActionBuilder(DAStudio.message('simulink_ui:studio:resources:simulinkFavoriteCommandIconFavoriteText'),[iconDir,'favoriteCommand_16.png'],'favorite_command'),...
            SampleActionBuilder(DAStudio.message('simulink_ui:studio:resources:simulinkFavoriteCommandIconMATLABText'),[iconDir,'matlabFavorite_16.png'],'matlab_favorite'),...
            SampleActionBuilder(DAStudio.message('simulink_ui:studio:resources:simulinkFavoriteCommandIconSimulinkText'),[iconDir,'simulinkFavorite_16.png'],'simulink_favorite'),...
            SampleActionBuilder(DAStudio.message('simulink_ui:studio:resources:simulinkFavoriteCommandIconHelpText'),[iconDir,'helpFavorite_16.png'],'help_favorite'),...
            };

            this.SpecifyCustomIcon=SampleActionBuilder(DAStudio.message('simulink_ui:studio:resources:simulinkFavoriteCommandIconCustomText'),[iconDir,'favoriteCategory_16.png'],'custom');
        end
    end
end