classdef Instantiator<systemcomposer.internal.mixin.CenterDialog

    properties
        Architecture;
        AnalysisFunction char;
        FunctionArguments char;
        IterationMode;
        ModelName char;
        IsStrict=true;
        NormalizeUnits=false;
    end

    properties(Access=private)
        LastDialogPos=[];
        ProfileModels;
        TreeIDMap;
        HasErrors;
    end

    properties(Hidden,Transient)
        createdNewFile=false;
        PollingTimer=[];
    end

    methods(Static)
        function launch(a,varargin)


            obj=internal.systemcomposer.Instantiator(a,varargin{:});
            DAStudio.Dialog(obj);
        end
    end

    methods
        function handleNormalizeChange(this,~,value)

            this.NormalizeUnits=value;
        end

        function handleStrictChange(this,~,value)

            this.IsStrict=value;
        end
    end

    methods
        function fname=generateFunctionName(this)
            idx=1;
            fname=[this.ModelName,'_',num2str(idx),'.m'];
            while exist(fullfile(pwd,fname),'file')
                idx=idx+1;
                fname=[this.ModelName,'_',num2str(idx),'.m'];
            end
        end

        function checkFileExists(this,fname,timer,~)



            if exist(fname,'file')
                this.createdNewFile=true;
                stop(timer);
            end
        end

        function finishWaitingForFile(this,fname,timer,~)



            delete(timer);
            this.PollingTimer=[];

            if this.createdNewFile
                this.openCreatedFile(fname);
            end
        end

        function res=createAndOpenNewAnalysisFunction(this,fname)
            res=false;


            parts=split(string(fname),".");
            spec=this.getAnalysisFunctionTemplate(parts(1));

            dp=DAStudio.DialogProvider;
            if exist(fullfile(pwd,fname),'file')
                eDlg=dp.errordlg(...
                DAStudio.message('SystemArchitecture:Instantiator:FileAlreadyExists',fname),...
                DAStudio.message('SystemArchitecture:Instantiator:FileAlreadyExistsTitle'),...
                true);
                return;
            end

            fid=fopen(fname,'w');


            if fid<0
                eDlg=dp.errordlg(...
                DAStudio.message('SystemArchitecture:Instantiator:NoWriteAccess',fname),...
                DAStudio.message('SystemArchitecture:Instantiator:NoWriteAccessTitle'),...
                true);
                return;
            end
            fileGuard=onCleanup(@()fclose(fid));

            fprintf(fid,spec);
            delete(fileGuard);






            this.waitForFile(fname);
            res=true;
        end

        function template=getAnalysisFunctionTemplate(this,functionName)

            template=sprintf([...
'function %s(instance,varargin)\n'...
            ,'    %%%% %s Example Analysis Function\n'...
            ,'\n'],functionName,functionName);

            if~isempty(this.FunctionArguments)
                arguments=split(string(this.FunctionArguments),",");
                for a=1:length(arguments)
                    aString=sprintf("\tif varargin{%d}\n\t\targ%d = varargin{%d};\n\tend\n",a,a,a);
                    template=template+aString;
                end
            end

            properties=this.generateInstanceProperties();
            for idx=1:length(this.ProfileModels)
                model=this.ProfileModels(idx);


                profile=systemcomposer.internal.profile.Profile.getProfile(model);
                profileName=profile.getName;

                if isfield(properties,profileName)

                    profileStruct=properties.(profileName);
                    prototypeNames=fieldnames(profileStruct);

                    stereotypeSet=struct('Component',"",'Port',"",'Connector',"");


                    for prototypeIdx=1:length(prototypeNames)

                        prototypeName=prototypeNames{prototypeIdx};
                        prototypeStruct=profileStruct.(prototypeName);
                        prot=profile.prototypes.getByKey(prototypeName);
                        if~prot.abstract
                            if isfield(prototypeStruct,'elementKinds')
                                elementKinds=prototypeStruct.elementKinds;
                            else
                                elementKinds=["Component","Port","Connector"];
                            end

                            for e=elementKinds
                                if(isfield(stereotypeSet,e))
                                    stereotypeSet.(e)(end+1)=prototypeName;
                                end
                            end
                        end
                    end

                    fields=fieldnames(stereotypeSet);
                    sections=string.empty;

                    for f=1:length(fields)
                        stereotypes=stereotypeSet.(fields{f});

                        if length(stereotypes)>1
                            stereotypeCheck=sprintf("instance.is%s()\n",fields{f});

                            for p=2:length(stereotypes)
                                prototypeName=stereotypes{p};
                                prot=profile.prototypes.getByKey(prototypeName);
                                while~isempty(prot)
                                    properties=prot.propertySet.getAllProperties();
                                    for prop=properties
                                        propertyName=prop.getName;
                                        propertyString=sprintf('\t\t%s_%s = instance.getValue("%s.%s");\n',...
                                        prototypeName,propertyName,prot.getName,propertyName);
                                        stereotypeCheck=stereotypeCheck+propertyString;
                                    end
                                    prot=prot.parent;
                                end
                            end

                            if(string(fields{f})=="Component")
                                stereotypeCheck=stereotypeCheck+sprintf("\t\tif isempty(instance.Components)\n\t\telse\n\t\tend\n");
                            end

                            sections(end+1)=stereotypeCheck;

                        end
                    end

                    if sections.length>0
                        template=template+sprintf("\tif ")+sections(1);

                        for s=2:length(sections)
                            template=template+sprintf("\telseif ")+sections(s);
                        end

                        template=template+sprintf("\tend\n");
                    end
                end
            end

            template=template+sprintf("end\n");

        end

        function waitForFile(this,fname)



            this.PollingTimer=timer(...
            'TimerFcn',@(t,e)this.checkFileExists(fname,t,e),...
            'ExecutionMode','fixedRate',...
            'TasksToExecute',20,...
            'Period',0.5,...
            'ObjectVisibility','off',...
            'StopFcn',@(t,e)this.finishWaitingForFile(fname,t,e));
            start(this.PollingTimer);
        end

        function openCreatedFile(this,fname)


            edit(fname);

        end
    end
    methods
        function this=Instantiator(a,varargin)


            this.Architecture=a;
            if nargin>1
                this.AnalysisFunction=varargin{1};
            else
                this.AnalysisFunction='';
            end
            if nargin>2
                this.FunctionArguments=varargin{2};
            else
                this.FunctionArguments='';
            end
            this.ModelName=a.Name;
            if nargin>3
                this.IterationMode=str2double(varargin{3});
            else
                this.IterationMode=0;
            end

            this.ProfileModels=[];
            this.TreeIDMap=systemcomposer.internal.profile.internal.CheckableTreeNodeIDMap;
            this.HasErrors=false;

            this.initialize();
        end

        function schema=getDialogSchema(this)


            this.initializeProfiles();


            descGroup=this.getDescriptionSchema();
            descGroup.RowSpan=[1,1];
            descGroup.ColSpan=[1,2];


            profileSelector=this.getProfileSelectorSchema();
            profileSelector.RowSpan=[2,4];
            profileSelector.ColSpan=[1,1];


            analysis=this.getAnalysisSchema();
            analysis.RowSpan=[2,2];
            analysis.ColSpan=[2,2];


            filler.Type='text';
            filler.Name='';
            filler.WordWrap=true;
            filler.RowSpan=[3,3];
            filler.ColSpan=[2,2];


            buttons=this.getButtonSchema();
            buttons.RowSpan=[4,4];
            buttons.ColSpan=[2,2];

            panel.Type='panel';
            panel.Items={descGroup,profileSelector,analysis,filler,buttons};
            panel.LayoutGrid=[4,2];
            panel.RowStretch=[0,0,1,0];
            panel.ColStretch=[0,1];

            schema.DialogTitle=DAStudio.message('SystemArchitecture:Instantiator:DialogTitle');

            schema.Items={panel};
            schema.DialogTag='instantiate_architecture';
            schema.Source=this;
            schema.SmartApply=true;
            schema.HelpMethod='handleClickHelp';
            schema.HelpArgs={};
            schema.HelpArgsDT={};
            schema.OpenCallback=@(dlg)this.handleOpenDialog(dlg);
            schema.CloseMethod='handleCloseDialog';
            schema.CloseMethodArgs={'%dialog','%closeaction'};
            schema.CloseMethodArgsDT={'handle','char'};
            schema.StandaloneButtonSet={''};
            schema.MinMaxButtons=false;
            schema.ShowGrid=false;
            schema.DisableDialog=false;
            schema.Geometry=[300,300,600,450];
        end

        function setAnalysisFunction(this,dlg,tag,fname)


            p=which(fname);
            if isempty(p)
                this.error(dlg,tag,...
                DAStudio.message('SystemArchitecture:Instantiator:FunctionNotVisible',fname));
            else
                this.clearError(dlg,tag);
            end
            this.AnalysisFunction=fname;
        end

        function setFunctionArguments(this,val)


            this.FunctionArguments=val;
        end

        function setModelName(this,val)


            this.ModelName=val;
        end

        function setIterationMode(this,val)


            this.IterationMode=val;
        end

        function setIterationOrder(this,val)


            this.IterationOrder=val;
        end

        function handleOpenDialog(this,dlg)


            if isempty(this.LastDialogPos)
                this.positionDialog(dlg,[],[800,600]);
            else
                dlg.position=this.LastDialogPos;
            end
        end

        function handleCloseDialog(this,~,~)

            delete(this);
        end

        function handleClickCancel(~,dlg)


            delete(dlg);
        end

        function handleClickHelp(~)

            helpview(fullfile(docroot,'systemcomposer','helptargets.map'),'instantiatearchmodel');
        end

        function handleFunctionHelp(~)

            helpview(fullfile(docroot,'systemcomposer','helptargets.map'),'writeAnalysisFunction');
        end

        function handleProfileSelectionChanged(this,dlg,id,val)


            this.setTreeNodeCheckState(id,val);
            dlg.refresh();
        end


        function handleClickProfileEditor(~,dlg)




            okMsg=DAStudio.message('SystemArchitecture:Instantiator:OK');
            response=questdlg(...
            DAStudio.message('SystemArchitecture:Instantiator:CloseDialogQuestion'),...
            DAStudio.message('SystemArchitecture:Instantiator:Confirm'),...
            DAStudio.message('SystemArchitecture:Instantiator:Cancel'),...
            okMsg,okMsg);

            if strcmp(response,okMsg)
                delete(dlg);
                systemcomposer.internal.profile.Designer.launch();
            end
        end

        function handleClickBrowseFunction(this,dlg)


            [fname,pathname]=uigetfile('*.m',...
            DAStudio.message('SystemArchitecture:Instantiator:SelectAnalysisFunction'));
            if isempty(fname)||~ischar(fname)
                return;
            end
            fcn=strrep(fname,'.m','');


            p=which(fcn);
            if~strcmp(p,fullfile(pathname,fname))
                error(DAStudio.message('SystemArchitecture:Instantiator:FunctionNotVisible',fname));
            end

            this.AnalysisFunction=fcn;
            dlg.refresh();
        end

        function handleClickNewFunction(this,dlg)



            okMsg=DAStudio.message('SystemArchitecture:Instantiator:OK');
            response=questdlg(...
            DAStudio.message('SystemArchitecture:Instantiator:NewFunctionQuestion'),...
            DAStudio.message('SystemArchitecture:Instantiator:Confirm'),...
            DAStudio.message('SystemArchitecture:Instantiator:Cancel'),...
            okMsg,okMsg);

            if strcmp(response,okMsg)
                if isempty(this.AnalysisFunction)
                    fname=this.generateFunctionName();
                else
                    fname=[this.AnalysisFunction,'.m'];
                end

                if this.createAndOpenNewAnalysisFunction(fname)

                    parts=split(string(fname),".");
                    this.setAnalysisFunction(dlg,'fcnName',parts(1))
                    dlg.refresh();
                end
            end

        end


        function Properties=generateInstanceProperties(this)
            Properties=struct();
            isAbstract=true;
            for idx=1:length(this.ProfileModels)
                model=this.ProfileModels(idx);
                profile=systemcomposer.internal.profile.Profile.getProfile(model);

                ProtStruct=struct();

                prototypes=profile.prototypes.toArray;
                for c=1:length(prototypes)
                    proto=prototypes(c);
                    key=this.TreeIDMap.get(proto.fullyQualifiedName);
                    if this.TreeIDMap.checkStateMap.isKey(key)...
                        &&strcmp(this.TreeIDMap.checkStateMap(key),'checked')
                        if~proto.abstract

                            isAbstract=false;
                        end

                        mc=proto.appliesTo.toArray;
                        if~isempty(mc)
                            elements=struct('elementKinds',string(mc));
                            ProtStruct.(proto.getName)=elements;
                        else
                            ProtStruct.(proto.getName)=[];
                        end
                    end
                end
                if~isempty(fields(ProtStruct))
                    Properties.(profile.getName())=ProtStruct;
                    Properties.IsAbstract=isAbstract;
                end
            end
        end

        function handleClickInstantiate(this,dlg)

            Properties=this.generateInstanceProperties();

            if length(fields(Properties))<=1
                warndlg(DAStudio.message('SystemArchitecture:Instantiator:NoStereotypesSelected'),...
                DAStudio.message('SystemArchitecture:Instantiator:NoStereotypesTitle'),'modal');
            elseif Properties.IsAbstract
                warndlg(DAStudio.message('SystemArchitecture:Instantiator:OnlyAbstractStereotypesSelected'),...
                DAStudio.message('SystemArchitecture:Instantiator:NoStereotypesTitle'),'modal');
            else


                if~isempty(this.AnalysisFunction)
                    fnHandle=eval(['@',this.AnalysisFunction]);
                else
                    fnHandle=[];
                end

                existingInstance=systemcomposer.analysis.lookup(this.ModelName);
                if isempty(existingInstance)

                    instanceModel=this.Architecture.instantiate(Properties,this.ModelName,...
                    'Function',fnHandle,...
                    'Direction',this.IterationMode,...
                    'Strict',this.IsStrict,...
                    'NormalizeUnits',this.NormalizeUnits...
                    );
                    systemcomposer.analysis.openViewer('Source',instanceModel,...
                    'Arguments',this.FunctionArguments,...
                    'Direction',systemcomposer.IteratorDirection(this.IterationMode)...
                    );

                    delete(dlg);
                else
                    response=questdlg(...
                    DAStudio.message('SystemArchitecture:Instantiator:ModelExists',this.ModelName),...
                    DAStudio.message('SystemArchitecture:Instantiator:ChooseOption'),...
                    DAStudio.message('SystemArchitecture:Instantiator:OverWrite'),...
                    DAStudio.message('SystemArchitecture:Instantiator:Open'),...
                    DAStudio.message('SystemArchitecture:Instantiator:Cancel'),...
                    DAStudio.message('SystemArchitecture:Instantiator:Cancel'));
                    if~strcmp(response,DAStudio.message('SystemArchitecture:Instantiator:Cancel'))
                        if strcmp(response,DAStudio.message('SystemArchitecture:Instantiator:OverWrite'))


                            systemcomposer.internal.analysis.AnalysisService.deleteInstance(...
                            existingInstance.getUUID());


                            instanceModel=this.Architecture.instantiate(Properties,this.ModelName,...
                            'Function',fnHandle,...
                            'Direction',this.IterationMode,...
                            'Strict',this.IsStrict,...
                            'NormalizeUnits',this.NormalizeUnits...
                            );
                            systemcomposer.analysis.openViewer('Source',instanceModel,...
                            'Arguments',this.FunctionArguments,...
                            'Direction',systemcomposer.IteratorDirection(this.IterationMode)...
                            );
                        else

                            systemcomposer.analysis.openViewer('Source',existingInstance,...
                            'Arguments',this.FunctionArguments,...
                            'Direction',systemcomposer.IteratorDirection(this.IterationMode)...
                            );
                        end


                        delete(dlg);
                    end
                end
            end
        end





        function check=getTreeNodeCheckState(this,id)


            check=this.TreeIDMap.getCheckState(id);
        end

        function setTreeNodeCheckState(this,id,val)



            this.TreeIDMap.setCheckState(id,val);
        end

        function node=createTreeNode(this,source,parent)



            if nargin<3
                parent=[];
            end
            source.id=this.TreeIDMap.get(source.fqn);
            node=systemcomposer.internal.profile.internal.CheckableTreeNode(source,parent,this);
        end

        function node=createStereotypeNode(this,parent)
            assert(~isempty(parent));
            node=systemcomposer.internal.profile.internal.StereotypeTreeNode(parent,this);
        end

        function node=createPropertySetNode(this,parent)
            assert(~isempty(parent));
            node=systemcomposer.internal.profile.internal.PropertySetTreeNode(parent,this);
        end


        function id=getID(this,fqn)
            id=this.TreeIDMap.get(fqn);
        end

    end

    methods(Access=private)
        function schema=getDescriptionSchema(this)


            desc.Type='text';
            desc.Name=DAStudio.message('SystemArchitecture:Instantiator:DialogDescription');
            desc.WordWrap=true;
            desc.RowSpan=[1,1];
            desc.ColSpan=[1,1];

            help.Type='pushbutton';
            help.Tag='helpButton';
            help.Source=this;
            help.ObjectMethod='handleClickHelp';
            help.MethodArgs={};
            help.ArgDataTypes={};
            help.Graphical=true;
            help.RowSpan=[1,1];
            help.ColSpan=[2,2];
            help.Enabled=true;
            help.ToolTip=DAStudio.message('SystemArchitecture:Instantiator:TipHelp');
            help.FilePath=this.resource('help');
            help.Name='';

            schema.Type='group';
            schema.Name=DAStudio.message('SystemArchitecture:Instantiator:Description');
            schema.Items={desc,help};
            schema.LayoutGrid=[1,2];
            schema.ColStretch=[1,0];
        end

        function schema=getProfileSelectorSchema(this)


            desc.Type='text';
            desc.Name=DAStudio.message('SystemArchitecture:Instantiator:SelectPrototypeDesc');
            desc.WordWrap=true;
            desc.RowSpan=[1,1];
            desc.ColSpan=[1,2];


            model=cell(1,length(this.ProfileModels));
            for idx=1:length(this.ProfileModels)
                m=this.ProfileModels(idx);
                source.obj=systemcomposer.internal.profile.Profile.getProfile(m);
                source.fqn=source.obj.getName;
                model{1,idx}=this.createTreeNode(source);
            end

            profileBrowser.Type='tree';
            profileBrowser.Name='';
            profileBrowser.Tag='profileBrowserTree';
            profileBrowser.TreeModel=model;
            profileBrowser.TreeMultiSelect=true;
            profileBrowser.ExpandTree=true;
            profileBrowser.CheckStateChangedCallback=@(dlg,id,val)this.handleProfileSelectionChanged(dlg,id,val);
            profileBrowser.DialogRefresh=false;
            profileBrowser.Graphical=true;
            profileBrowser.RowSpan=[2,2];
            profileBrowser.ColSpan=[1,2];

            strict.Type='checkbox';
            strict.Tag='StrictCheckbox';
            strict.Name=DAStudio.message('SystemArchitecture:Instantiator:IsStrict');
            strict.Source=this;
            strict.Mode=true;
            strict.Graphical=true;
            strict.NameLocation=1;
            strict.Value=this.IsStrict;
            strict.ObjectMethod='handleStrictChange';
            strict.MethodArgs={'%dialog','%value'};
            strict.ArgDataTypes={'handle','mxArray'};
            strict.RowSpan=[3,3];
            strict.ColSpan=[1,2];
            strict.ToolTip=DAStudio.message('SystemArchitecture:Instantiator:IsStrictToolTip');

            profileGroup.Type='group';
            profileGroup.Items={desc,profileBrowser,strict};
            profileGroup.LayoutGrid=[3,1];
            profileGroup.RowStretch=[0,1,0];
            profileGroup.RowSpan=[1,1];
            profileGroup.ColSpan=[1,2];

            editorInfo.Type='text';
            editorInfo.Name=DAStudio.message('SystemArchitecture:Instantiator:DontSeeProfileQuest');
            editorInfo.Alignment=7;
            editorInfo.RowSpan=[3,3];
            editorInfo.ColSpan=[1,1];

            profEditor.Type='pushbutton';
            profEditor.Tag='profileEditorButton';
            profEditor.Source=this;
            profEditor.ObjectMethod='handleClickProfileEditor';
            profEditor.MethodArgs={'%dialog'};
            profEditor.ArgDataTypes={'handle'};
            profEditor.Graphical=true;
            profEditor.RowSpan=[3,3];
            profEditor.ColSpan=[2,2];
            profEditor.Enabled=true;
            profEditor.ToolTip=DAStudio.message('SystemArchitecture:Instantiator:TipProfileEditor');
            profEditor.Name='Profile Editor ...';

            schema.Type='group';
            schema.Name=DAStudio.message('SystemArchitecture:Instantiator:Step1SelectPrototypes');
            schema.Items={profileGroup,editorInfo,profEditor};
            schema.LayoutGrid=[2,2];
            schema.RowStretch=[1,0];
            schema.ColStretch=[1,0];
        end

        function schema=getAnalysisSchema(this)


            visitor=this.getVisitorSchema();
            visitor.RowSpan=[1,1];
            visitor.ColSpan=[1,1];

            iterator=this.getIteratorSchema();
            iterator.RowSpan=[2,2];
            iterator.ColSpan=[1,1];


            modelName=this.getModelNameSchema();
            modelName.RowSpan=[3,3];
            modelName.ColSpan=[1,1];

            schema.Type='group';
            schema.Name=DAStudio.message('SystemArchitecture:Instantiator:Step2ConfigureAnalysis');
            schema.Items={visitor,iterator,modelName};
            schema.LayoutGrid=[4,1];
        end

        function schema=getVisitorSchema(this)


            row=0;

            row=row+1;
            fcnNameLbl.Type='text';
            fcnNameLbl.Name=DAStudio.message('SystemArchitecture:Instantiator:AnalysisFunction');
            fcnNameLbl.RowSpan=[row,row];
            fcnNameLbl.ColSpan=[1,3];
            fcnNameLbl.Buddy='fcnName';

            row=row+1;
            fcnName.Type='edit';
            fcnName.Tag='fcnName';
            fcnName.Name='';
            fcnName.Mode=true;
            fcnName.FontFamily='consolas';
            fcnName.Source=this;
            fcnName.Value=this.AnalysisFunction;
            fcnName.ObjectMethod='setAnalysisFunction';
            fcnName.MethodArgs={'%dialog',fcnName.Tag,'%value'};
            fcnName.ArgDataTypes={'handle','char','char'};
            fcnName.Graphical=true;
            fcnName.DialogRefresh=true;
            fcnName.ToolTip=DAStudio.message('SystemArchitecture:Instantiator:TipAnalysisFunction');
            fcnName.RowSpan=[row,row];
            fcnName.ColSpan=[1,1];

            browseFcn.Type='pushbutton';
            browseFcn.Tag='browseFcn';
            browseFcn.Source=this;
            browseFcn.ObjectMethod='handleClickBrowseFunction';
            browseFcn.MethodArgs={'%dialog'};
            browseFcn.ArgDataTypes={'handle'};
            browseFcn.Graphical=true;
            browseFcn.RowSpan=[row,row];
            browseFcn.ColSpan=[2,2];
            browseFcn.Enabled=true;
            browseFcn.ToolTip=DAStudio.message('SystemArchitecture:Instantiator:TipBrowseFunction');
            browseFcn.FilePath=this.resource('open');

            newFcn.Type='pushbutton';
            newFcn.Tag='newFcn';
            newFcn.Source=this;
            newFcn.ObjectMethod='handleClickNewFunction';
            newFcn.MethodArgs={'%dialog'};
            newFcn.ArgDataTypes={'handle'};
            newFcn.Graphical=true;
            newFcn.RowSpan=[row,row];
            newFcn.ColSpan=[3,3];
            newFcn.Enabled=true;
            newFcn.ToolTip=DAStudio.message('SystemArchitecture:Instantiator:TipNewFunction');
            newFcn.FilePath=this.resource('add');


            helpButton.Type='pushbutton';
            helpButton.Tag='help';
            helpButton.Source=this;
            helpButton.ObjectMethod='handleFunctionHelp';
            helpButton.MethodArgs={};
            helpButton.ArgDataTypes={};
            helpButton.RowSpan=[row,row];
            helpButton.ColSpan=[4,4];
            helpButton.Enabled=true;
            helpButton.ToolTip=DAStudio.message('SystemArchitecture:ProfileDesigner:HelpTooltip');
            helpButton.FilePath=this.resource('help');

            row=row+1;
            fcnArgsLbl.Type='text';
            fcnArgsLbl.Name=DAStudio.message('SystemArchitecture:Instantiator:FunctionArguments');
            fcnArgsLbl.RowSpan=[row,row];
            fcnArgsLbl.ColSpan=[1,4];
            fcnArgsLbl.Buddy='fcnArgs';

            row=row+1;
            fcnArgs.Type='edit';
            fcnArgs.Tag='fcnArgs';
            fcnArgs.Name='';
            fcnArgs.FontFamily='consolas';
            fcnArgs.Mode=true;
            fcnArgs.Source=this;
            fcnArgs.Value=this.FunctionArguments;
            fcnArgs.ObjectMethod='setFunctionArguments';
            fcnArgs.MethodArgs={'%value'};
            fcnArgs.ArgDataTypes={'char'};
            fcnArgs.Graphical=true;
            fcnArgs.DialogRefresh=true;
            fcnArgs.ToolTip=DAStudio.message('SystemArchitecture:Instantiator:TipFunctionArguments');
            fcnArgs.RowSpan=[row,row];
            fcnArgs.ColSpan=[1,4];

            row=row+1;
            fcnProto.Type='text';
            fcnProto.Tag='fcnPrototype';
            fcnProto.Name=this.getFunctionPrototype();
            fcnProto.FontFamily='consolas';
            fcnProto.ToolTip=DAStudio.message('SystemArchitecture:Instantiator:TipFunctionPrototype');
            fcnProto.RowSpan=[row,row];
            fcnProto.ColSpan=[1,4];

            schema.Type='group';
            schema.Name=DAStudio.message('SystemArchitecture:Instantiator:Step2AFunction');
            schema.Items={fcnNameLbl,fcnName,fcnArgsLbl,fcnArgs,browseFcn,fcnProto,helpButton,newFcn};
            schema.LayoutGrid=[row+1,4];
            schema.RowStretch=[zeros(1,row),1];
            schema.ColStretch=[1,0,0,0];
        end

        function schema=getModelNameSchema(this)

            modelNameLbl.Type='text';
            modelNameLbl.Name=DAStudio.message('SystemArchitecture:Instantiator:ModelNameLabel');
            modelNameLbl.RowSpan=[1,1];
            modelNameLbl.ColSpan=[1,1];

            modelName.Type='edit';
            modelName.Tag='modelName';
            modelName.Name='';
            modelName.FontFamily='consolas';
            modelName.Mode=true;
            modelName.Source=this;
            modelName.Value=this.ModelName;
            modelName.ObjectMethod='setModelName';
            modelName.MethodArgs={'%value'};
            modelName.ArgDataTypes={'char'};
            modelName.Graphical=true;
            modelName.DialogRefresh=true;
            modelName.ToolTip=DAStudio.message('SystemArchitecture:Instantiator:TipModelName');
            modelName.RowSpan=[1,1];
            modelName.ColSpan=[2,2];
            normalize.Type='checkbox';
            normalize.Tag='NormalizeCheckbox';
            normalize.Name=DAStudio.message('SystemArchitecture:Instantiator:NormalizeUnits');
            normalize.Source=this;
            normalize.Mode=true;
            normalize.Graphical=true;
            normalize.NameLocation=1;
            normalize.ObjectMethod='handleNormalizeChange';
            normalize.MethodArgs={'%dialog','%value'};
            normalize.ArgDataTypes={'handle','mxArray'};
            normalize.RowSpan=[2,2];
            normalize.ColSpan=[1,2];
            normalize.ToolTip=DAStudio.message('SystemArchitecture:Instantiator:NormalizeUnitsToolTip');
            schema.Type='group';
            schema.Name=DAStudio.message('SystemArchitecture:Instantiator:ModelDetails');
            schema.Items={modelNameLbl,modelName,normalize};
            schema.LayoutGrid=[2,2];
            schema.ColStretch=[0,1];

        end

        function schema=getIteratorSchema(this)


            row=1;
            iterationMode.Type='combobox';
            iterationMode.Tag='iterationMode';
            iterationMode.Name=DAStudio.message('SystemArchitecture:Instantiator:Mode');
            iterationMode.NameLocation=1;
            iterationMode.Entries={...
            DAStudio.message('SystemArchitecture:Instantiator:PreOrder'),...
            DAStudio.message('SystemArchitecture:Instantiator:PostOrder'),...
            DAStudio.message('SystemArchitecture:Instantiator:TopDown'),...
            DAStudio.message('SystemArchitecture:Instantiator:BottomUp')...
            };
            iterationMode.Source=this;
            iterationMode.Value=this.IterationMode;
            iterationMode.ObjectMethod='setIterationMode';
            iterationMode.MethodArgs={'%value'};
            iterationMode.ArgDataTypes={'mxArray'};
            iterationMode.Mode=true;
            iterationMode.Graphical=true;
            iterationMode.RowSpan=[row,row];
            iterationMode.ColSpan=[1,1];
            iterationMode.ToolTip=DAStudio.message('SystemArchitecture:Instantiator:TipIterationMode');
            schema.Type='group';
            schema.Name=DAStudio.message('SystemArchitecture:Instantiator:Step2BIterator');
            schema.Items={iterationMode};
            schema.LayoutGrid=[row+1,1];
            schema.RowStretch=[zeros(1,row),1];

        end

        function schema=getButtonSchema(this)
            desc.Type='text';
            desc.Name='';
            desc.WordWrap=true;
            desc.RowSpan=[1,1];
            desc.ColSpan=[1,1];


            cancel.Type='pushbutton';
            cancel.Tag='cancelButton';
            cancel.Source=this;
            cancel.ObjectMethod='handleClickCancel';
            cancel.MethodArgs={'%dialog'};
            cancel.ArgDataTypes={'handle'};
            cancel.Graphical=true;
            cancel.RowSpan=[1,1];
            cancel.ColSpan=[2,2];
            cancel.Enabled=true;
            cancel.ToolTip=DAStudio.message('SystemArchitecture:Instantiator:TipCancel');
            cancel.FilePath=this.resource(fullfile('webkit','Cancel_24'));
            cancel.Name=DAStudio.message('SystemArchitecture:Instantiator:Cancel');

            instantiate.Type='pushbutton';
            instantiate.Tag='instantiateButton';
            instantiate.Source=this;
            instantiate.ObjectMethod='handleClickInstantiate';
            instantiate.MethodArgs={'%dialog'};
            instantiate.ArgDataTypes={'handle'};
            instantiate.Graphical=true;
            instantiate.RowSpan=[1,1];
            instantiate.ColSpan=[3,3];
            instantiate.FilePath=this.resource(fullfile('SLEditor','RunSimulation_24'));
            instantiate.Name=DAStudio.message('SystemArchitecture:Instantiator:Instantiate');
            instantiate.Enabled=~this.HasErrors;
            if this.HasErrors
                instantiate.ToolTip=DAStudio.message('SystemArchitecture:Instantiator:TipInstantiateError');
            else
                instantiate.ToolTip=DAStudio.message('SystemArchitecture:Instantiator:TipInstantiate');
            end

            schema.Type='panel';
            schema.Items={desc,cancel,instantiate};
            schema.LayoutGrid=[1,3];
            schema.ColStretch=[1,0,0];

        end

        function initialize(this)



            this.initializeProfiles();





            for idx=1:length(this.ProfileModels)
                model=this.ProfileModels(idx);
                profile=systemcomposer.internal.profile.Profile.getProfile(model);
                if~strcmp(profile.getName(),'systemcomposer')
                    profID=this.TreeIDMap.get(profile.getName());

                    prototypes=profile.prototypes.toArray;
                    protoIDs=zeros(1,length(prototypes));
                    for c=1:length(prototypes)
                        proto=prototypes(c);
                        protoIDs(c)=this.TreeIDMap.get(proto.fullyQualifiedName);
                    end
                    this.TreeIDMap.setChildren(profID,protoIDs);
                end
            end
        end

        function initializeProfiles(this)


            profileNames=systemcomposer.internal.profile.Profile.getLoadedProfileNames();

            numProfiles=length(profileNames);
            this.ProfileModels=[];

            for idx=1:numProfiles
                name=profileNames{idx};
                if~strcmp(name,'systemcomposer')
                    model=systemcomposer.internal.profile.Profile.loadFromFile(name);
                    this.ProfileModels=cat(1,this.ProfileModels,model);
                end
            end

            this.TreeIDMap.prune();
        end

        function proto=getFunctionPrototype(this)


            proto='';
            if this.HasErrors||isempty(this.AnalysisFunction)
                return;
            end
            comma=', ';
            if isempty(this.FunctionArguments)
                comma='';
            end
            proto=['>> ',this.AnalysisFunction,'(instance',comma,this.FunctionArguments,')'];
        end

        function fpath=resource(~,name)


            fpath=fullfile(matlabroot,'toolbox','shared','dastudio','resources',[name,'.png']);
        end

        function error(this,dlg,widget,msg)




            err=DAStudio.UI.Util.Error;
            err.ID=['SystemComposer:Instantiator:',widget];
            err.Tag=['Error_',widget];
            err.Type='Error';
            err.Message=msg;
            err.HiliteColor=[255,0,0,255];
            dlg.setWidgetWithError(widget,err);

            this.HasErrors=true;
            dlg.refresh();
        end

        function clearError(this,dlg,widget)


            dlg.clearWidgetWithError(widget);


            wError=dlg.getWidgetsWithError();
            this.HasErrors=~isempty(wError);

            dlg.refresh();
        end

    end
end
