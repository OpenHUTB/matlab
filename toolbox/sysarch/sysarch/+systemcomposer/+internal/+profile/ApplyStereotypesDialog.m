classdef ApplyStereotypesDialog<systemcomposer.internal.mixin.ModelClose&...
    systemcomposer.internal.mixin.CenterDialog





    properties(Constant)

        ARCHITECTURE=0;
        ELEMENTS=1;
        COMPONENTS=2;
        PORTS=3;
        CONNECTORS=4;


        NONE=0
        SELECTION=1;
        LAYER=2;
        ENTIRE_MODEL=3;
        LOCAL_OR_DICTIONARY=4
    end

    properties

        INTERFACES=5;
        FUNCTIONS=6;
    end

    properties(Access=private)
        mRootArch=[];
        mBDH=[];
        mDDName=[];
        mPortInterfaceCatalog=[];
        mCurrentArch=[];
        mStereotypeNames=[];
        mStereotypeStates=[];
        mMap=[];
        mIsNullWarnState=[];
        mArchitectureElements=[];
        mMdlName=[];
        mStudio=[];
        mDialogInstance=[];
        mSelectedElements=[];
        mScopeEnabled=false;
        mApplyButtonEnabled=false;


        mIncludeChildren=false;
        mIncludeChildrenEnabled=true;


        mApplyToType=0;
        mScopeType=0;
    end

    methods(Access=private)
        function this=ApplyStereotypesDialog()

        end
    end

    methods(Static)

        function launch(cbinfo)


            instance=systemcomposer.internal.profile.ApplyStereotypesDialog.instance(cbinfo);


            instance.registerCloseListener(bdroot(cbinfo.studio.App.blockDiagramHandle));

            if isempty(instance.mDialogInstance)||~ishandle(instance.mDialogInstance)
                instance.mDialogInstance=DAStudio.Dialog(instance);
            end


            instance.mDialogInstance.show();
            instance.mDialogInstance.refresh();


            dlg=findDDGByTag('system_composer_stereotypes_dialog');
            imd=DAStudio.imDialog.getIMWidgets(dlg);
            stereotypeTable=imd.find('tag','stereotypesTable');
            instance.enableApplyButton(...
            ~isempty(stereotypeTable.getAllTableItems));
        end

        function obj=instance(cbinfo)


            persistent instance
            if isempty(instance)||~isvalid(instance)
                instance=systemcomposer.internal.profile.ApplyStereotypesDialog;
            end




            w=warning('query','dastudio:studio:IsNull');
            instance.mIsNullWarnState=w.state;
            warning('off','dastudio:studio:IsNull');


            instance.mRootArch=[];
            instance.mBDH=[];
            instance.mDDName=[];
            instance.mPortInterfaceCatalog=[];
            instance.mCurrentArch=[];
            instance.mStereotypeNames=[];
            instance.mStereotypeStates=[];
            instance.mMap=[];
            instance.mArchitectureElements=[];
            instance.mMdlName=SLStudio.Utils.getModelName(cbinfo);
            instance.mStudio=cbinfo.studio;
            instance.mSelectedElements=[];
            instance.mScopeEnabled=false;
            instance.mIncludeChildrenEnabled=true;





            instance.initialize();

            obj=instance;
        end
    end

    methods(Access=private)




        function initialize(this)



            editor=this.mStudio.App.getActiveEditor();



            for idx=1:editor.getSelection.size
                m3iBlk=editor.getSelection.at(idx);
                peers=systemcomposer.utils.getArchitecturePeer(m3iBlk.handle);
                for idx1=1:numel(peers)
                    p=peers(idx1);

                    if isa(p,'systemcomposer.architecture.model.design.ComponentPort')
                        p=p.getArchitecturePort;
                    end
                    this.mSelectedElements=[this.mSelectedElements,p];
                end
            end


            this.mBDH=get_param(editor.getName(),'Handle');
            this.mCurrentArch=systemcomposer.utils.getArchitecturePeer(this.mBDH);
            if~isa(this.mCurrentArch,'systemcomposer.architecture.model.design.Architecture')
                this.mCurrentArch=this.mCurrentArch.getArchitecture();
            end
            this.mRootArch=this.mCurrentArch.getTopLevelArchitecture;




            if isempty(this.mSelectedElements)
                this.setApplyToType(this.ARCHITECTURE);
                this.setScopeType(this.NONE);
            else
                this.setApplyToType(this.ELEMENTS);
                this.setScopeType(this.SELECTION);
            end
            this.setIncludeChildren(false);


            this.mDDName=get_param(bdroot(this.mBDH),'DataDictionary');


            if~isempty(this.mDDName)
                ddObj=Simulink.data.dictionary.open(this.mDDName);
                mf0Model=Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel(ddObj.filepath());
            else
                app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdroot(this.mBDH));
                mf0Model=app.getCompositionArchitectureModel;
            end
            this.mPortInterfaceCatalog=systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog(mf0Model);


            functionsEditor=swarch.internal.spreadsheet.UIManager.Instance.getSpreadsheet(this.mStudio);
            if~isempty(functionsEditor)
                this.mSelectedElements=[this.mSelectedElements,...
                functionsEditor.getSelectedModelElements()];
            end


            this.updateStereotypesOptions();
        end

        function setApplyToType(this,applyToType)



            lastApplyToType=this.mApplyToType;

            this.mApplyToType=applyToType;

            if applyToType==this.ARCHITECTURE

                this.mScopeEnabled=false;


                setScopeType(this,this.NONE);
            elseif applyToType==this.INTERFACES



                if isempty(systemcomposer.InterfaceEditor.SelectedInterfaces(this.mRootArch.getName()))

                    this.mScopeEnabled=false;

                    setScopeType(this,this.LOCAL_OR_DICTIONARY);
                else


                    this.mScopeEnabled=true;
                    setScopeType(this,this.SELECTION);
                end
            else

                this.mScopeEnabled=true;




                if lastApplyToType==this.ARCHITECTURE||...
                    lastApplyToType==this.INTERFACES
                    if isempty(this.mSelectedElements)

                        setScopeType(this,this.LAYER);
                    else

                        setScopeType(this,this.SELECTION);
                    end
                end
            end
        end

        function setScopeType(this,scopeType)

            this.mScopeType=scopeType;
        end

        function setIncludeChildren(this,val)

            this.mIncludeChildren=val;
        end

        function enableIncludeChildrenCB(this,val)

            this.mIncludeChildrenEnabled=val;
        end

        function validElements=getValidElements(this,data)
            validElements=[];

            switch this.mApplyToType
            case this.ELEMENTS






                if isa(data,'systemcomposer.architecture.model.design.Architecture')
                    data=[data.getComponents(),...
                    filterAdapterVariantPorts(data.getPorts()),...
                    data.getConnectors()];
                end


                validElements=this.getValidComponentsInCollection(data);
                if this.mIncludeChildren
                    children=[];
                    for comp=validElements
                        arch=comp.getArchitecture();
                        children=[children...
                        ,arch.getComponentsAcrossHierarchy()...
                        ,filterAdapterVariantPorts(arch.getPortsAcrossHierarchy())...
                        ,arch.getConnectorsAcrossHierarchy()];
                    end
                    validNonCompIdxs=arrayfun(@(x)...
                    isa(x,'systemcomposer.architecture.model.design.ArchitecturePort')||...
                    isa(x,'systemcomposer.architecture.model.design.BaseConnector'),...
                    children);
                    validCompIdxs=arrayfun(@isValidComponent,children);
                    validFunctions=...
                    this.getFunctionsCallingComponents(...
                    [validElements,children(validCompIdxs)]);

                    validElements=[validElements,...
                    children(validCompIdxs|validNonCompIdxs),...
validFunctions
                    ];
                end

                validElements=[validElements...
                ,this.getPortsInCollection(data)...
                ,this.getConnectorsInCollection(data)];


                functionsEditor=swarch.internal.spreadsheet.UIManager.Instance.getSpreadsheet(this.mStudio);
                if~isempty(functionsEditor)
                    validElements=[validElements,functionsEditor.getSelectedModelElements()];
                end
            case this.COMPONENTS





                if isa(data,'systemcomposer.architecture.model.design.Architecture')
                    data=data.getComponents();
                end

                validElements=this.getValidComponentsInCollection(data);
                if this.mIncludeChildren
                    children=[];
                    for comp=validElements
                        arch=comp.getArchitecture();
                        children=[children,arch.getComponentsAcrossHierarchy()];
                    end
                    validChildren=this.getValidComponentsInCollection(children);
                    validElements=[validElements,validChildren];
                end
            case this.PORTS






                if isa(data,'systemcomposer.architecture.model.design.Architecture')
                    if this.mIncludeChildren
                        allPorts=data.getPortsAcrossHierarchy();
                    else
                        allPorts=data.getPorts();
                    end
                    validElements=filterAdapterVariantPorts(allPorts);
                    return;
                end

                allPorts=this.getPortsInCollection(data);
                if this.mIncludeChildren
                    components=this.getValidComponentsInCollection(data);
                    children=[];
                    for comp=components
                        arch=comp.getArchitecture();
                        children=[children,arch.getPortsAcrossHierarchy()];
                    end
                    allPorts=[allPorts,children];
                end
                validElements=filterAdapterVariantPorts(allPorts);
            case this.CONNECTORS






                if isa(data,'systemcomposer.architecture.model.design.Architecture')
                    if this.mIncludeChildren
                        validElements=data.getConnectorsAcrossHierarchy();
                    else
                        validElements=data.getConnectors();
                    end
                    return;
                end

                validElements=this.getConnectorsInCollection(data);
                if this.mIncludeChildren
                    components=this.getValidComponentsInCollection(data);
                    children=[];
                    for comp=components
                        arch=comp.getArchitecture();
                        children=[children,arch.getConnectorsAcrossHierarchy()];
                    end
                    validElements=[validElements,children];
                end
            case this.FUNCTIONS


                assert(isa(data,'systemcomposer.architecture.model.design.Architecture'));
                topLevelComps=data.getComponents();


                validComponents=this.getValidComponentsInCollection(topLevelComps);
                validElements=this.getFunctionsCallingComponents(validComponents);
            otherwise
                assert(false,'Unrecognized APPLY TO type');
            end
        end

        function callers=getFunctionsCallingComponents(this,components)


            callers=[];

            rootPartTrait=this.mCurrentArch.getTopLevelArchitecture().getTrait(...
            systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass);
            if isempty(rootPartTrait)
                return;
            end

            allFunctions=rootPartTrait.getFunctionsOfType(...
            systemcomposer.architecture.model.swarch.FunctionType.OSFunction);


            functionCallsIntoOneOf=@(f,comps)any(arrayfun(@(comp)f.calledFunctionParent==comp,comps));
            callers=allFunctions(arrayfun(@(f)...
            functionCallsIntoOneOf(f,components),allFunctions));
        end

        function validComponents=getValidComponentsInCollection(~,allComponents)

            validIdxs=arrayfun(@isValidComponent,allComponents);
            validComponents=allComponents(validIdxs);
        end

        function validPorts=getPortsInCollection(~,allPorts)

            validIdxs=cell2mat(arrayfun(@(x)...
            isa(x,'systemcomposer.architecture.model.design.ArchitecturePort'),...
            allPorts,'UniformOutput',false));
            validPorts=allPorts(validIdxs);
        end

        function validConnectors=getConnectorsInCollection(~,allConnectors)

            validIdxs=cell2mat(arrayfun(@(x)...
            isa(x,'systemcomposer.architecture.model.design.BaseConnector'),...
            allConnectors,'UniformOutput',false));
            validConnectors=allConnectors(validIdxs);
        end

        function updateStereotypesOptions(this)



            if this.mApplyToType==this.ARCHITECTURE

                this.mArchitectureElements=this.mCurrentArch;
                this.setIncludeChildren(false);
                this.enableIncludeChildrenCB(false);
                this.updateAllPrototypesFromArchProfile('systemcomposer.Component');
            elseif this.mApplyToType==this.INTERFACES

                this.mArchitectureElements={};

                this.setIncludeChildren(false);
                this.enableIncludeChildrenCB(false);
                if systemcomposer.internal.modelHasLocallyScopedInterfaces(this.mBDH)
                    this.updateAllPrototypesFromArchProfile('systemcomposer.PortInterface');
                else
                    this.updateAllPrototypesFromDictionaryProfile();
                end


                if this.mScopeType==this.LOCAL_OR_DICTIONARY

                    this.mArchitectureElements=this.mPortInterfaceCatalog.getPortInterfaces();
                else

                    selectedInterfaces=...
                    systemcomposer.InterfaceEditor.SelectedInterfaces(this.mRootArch.getName());
                    interfaces=this.mPortInterfaceCatalog.getPortInterfaces();
                    for idx=1:numel(interfaces)
                        interface=interfaces(idx);
                        for selectedInterface=selectedInterfaces
                            if selectedInterface{1}==interface

                                this.mArchitectureElements=[this.mArchitectureElements,interface];
                            end
                        end
                    end
                end
            else


                this.enableIncludeChildrenCB(true);

                this.mArchitectureElements={};
                elemArch=this.mCurrentArch;



                switch this.mApplyToType
                case this.ELEMENTS





                    switch this.mScopeType
                    case this.SELECTION

                        allElements=...
                        this.getValidElements(...
                        this.mSelectedElements);
                    case this.LAYER

                        allElements=...
                        this.getValidElements(elemArch);
                    case this.ENTIRE_MODEL


                        this.enableIncludeChildrenCB(false);
                        this.setIncludeChildren(true);
                        allElements=...
                        this.getValidElements(...
                        elemArch.getTopLevelArchitecture());
                    otherwise
                        assert(false,'Unrecognized SCOPE type');
                    end
                    if~isempty(allElements)

                        this.mArchitectureElements=allElements;
                        elemClass=arrayfun(@class,...
                        allElements,'UniformOutput',...
                        false);
                        uniqueClasses=unique(elemClass);



                        hasComponents=find(cellfun(@(x)strcmp(x,'systemcomposer.architecture.model.design.Component'),...
                        uniqueClasses,'UniformOutput',1),1);
                        if isempty(hasComponents)
                            this.enableIncludeChildrenCB(false);
                            this.setIncludeChildren(false);
                        end

                        if length(uniqueClasses)==1
                            type=this.getPrototypeClassForElement(uniqueClasses{1});
                        else
                            type='MIXIN';
                        end
                        updateAllPrototypesFromArchProfile(this,type);
                    else
                        this.mStereotypeNames=[];
                    end
                case this.COMPONENTS


                    switch this.mScopeType
                    case this.SELECTION

                        validComponents=...
                        this.getValidElements(...
                        this.mSelectedElements);
                    case this.LAYER

                        validComponents=...
                        this.getValidElements(elemArch);
                    case this.ENTIRE_MODEL

                        this.enableIncludeChildrenCB(false);
                        this.setIncludeChildren(true);
                        validComponents=...
                        this.getValidElements(...
                        elemArch.getTopLevelArchitecture());
                    otherwise
                        assert(false,'Unrecognized SCOPE type');
                    end
                    if~isempty(validComponents)

                        this.mArchitectureElements=validComponents;
                        updateAllPrototypesFromArchProfile(this,'systemcomposer.Component');
                    else
                        this.mStereotypeNames=[];
                    end
                case this.PORTS


                    switch this.mScopeType
                    case this.SELECTION

                        this.enableIncludeChildrenCB(false);
                        this.setIncludeChildren(false);
                        ports=...
                        this.getValidElements(...
                        this.mSelectedElements);
                    case this.LAYER

                        this.enableIncludeChildrenCB(false);
                        this.setIncludeChildren(false);
                        ports=...
                        this.getValidElements(elemArch);
                    case this.ENTIRE_MODEL

                        this.enableIncludeChildrenCB(false);
                        this.setIncludeChildren(true);
                        ports=...
                        this.getValidElements(...
                        elemArch.getTopLevelArchitecture());
                    otherwise
                        assert(false,'Unrecognized SCOPE type');
                    end
                    if~isempty(ports)

                        this.mArchitectureElements=ports;
                        updateAllPrototypesFromArchProfile(this,'systemcomposer.Port');
                    else
                        this.mStereotypeNames=[];
                    end
                case this.CONNECTORS


                    switch this.mScopeType
                    case this.SELECTION

                        this.enableIncludeChildrenCB(false);
                        this.setIncludeChildren(false);
                        connectors=...
                        this.getValidElements(...
                        this.mSelectedElements);
                    case this.LAYER

                        this.enableIncludeChildrenCB(false);
                        this.setIncludeChildren(false);
                        connectors=...
                        this.getValidElements(elemArch);
                    case this.ENTIRE_MODEL

                        this.enableIncludeChildrenCB(false);
                        this.setIncludeChildren(true);

                        connectors=...
                        this.getValidElements(...
                        elemArch.getTopLevelArchitecture());
                    otherwise
                        assert(false,'Unrecognized SCOPE type');
                    end
                    if~isempty(connectors)

                        this.mArchitectureElements=connectors;
                        updateAllPrototypesFromArchProfile(this,'systemcomposer.Connector');
                    else
                        this.mStereotypeNames=[];
                    end
                case this.FUNCTIONS
                    switch this.mScopeType
                    case this.SELECTION

                        this.enableIncludeChildrenCB(false);
                        this.setIncludeChildren(false);
                        functions=...
                        this.mSelectedElements(...
                        arrayfun(@(sel)isa(sel,'systemcomposer.architecture.model.swarch.Function'),this.mSelectedElements));
                    case this.LAYER

                        this.enableIncludeChildrenCB(false);
                        this.setIncludeChildren(false);
                        functions=this.getValidElements(elemArch);
                    case this.ENTIRE_MODEL

                        this.enableIncludeChildrenCB(false);
                        this.setIncludeChildren(true);

                        rootPartTrait=elemArch.getTopLevelArchitecture().getTrait(...
                        systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass);
                        functions=rootPartTrait.getFunctionsOfType(...
                        systemcomposer.architecture.model.swarch.FunctionType.OSFunction);
                    otherwise
                        assert(false,'Unrecognized SCOPE type');
                    end
                    if~isempty(functions)

                        this.mArchitectureElements=functions;
                        updateAllPrototypesFromArchProfile(this,'systemcomposer.Function');
                    else
                        this.mStereotypeNames=[];
                    end
                otherwise
                    assert(false,'Unrecognized APPLY TO type');
                end
            end



            this.mMap=containers.Map('KeyType','char','ValueType','any');
            this.mStereotypeStates=[];
            for elem=this.mArchitectureElements
                if isa(elem,'systemcomposer.architecture.model.design.Component')
                    name=elem.getQualifiedName();
                    e=elem.getArchitecture;
                elseif isa(elem,'systemcomposer.architecture.model.swarch.Function')
                    name=elem.getName();
                    e=swarch.utils.getPrototypableFunction(elem);
                else
                    name=elem.getName();
                    e=elem;
                end




                for p=e.getPrototype
                    idx=find(contains(this.mStereotypeNames,p.fullyQualifiedName));
                    if~isempty(idx)

                        this.mStereotypeStates=[this.mStereotypeStates,idx];
                        if isKey(this.mMap,p.fullyQualifiedName)
                            val=this.mMap(p.fullyQualifiedName);
                            this.mMap(p.fullyQualifiedName)=[val,{name}];
                        else
                            this.mMap(p.fullyQualifiedName)={name};
                        end
                    end
                end
            end


            this.enableApplyButton(~isempty(this.mStereotypeNames));
        end

        function updateAllPrototypesFromArchProfile(this,elemClass)

            allPrototypes=systemcomposer.internal.arch.internal.getAllPrototypesFromArchProfile(...
            this.mRootArch.getName(),true,elemClass);
            this.mStereotypeNames=arrayfun(@(x)x.fullyQualifiedName,...
            allPrototypes,'UniformOutput',false);
        end

        function updateAllPrototypesFromDictionaryProfile(this)

            allPrototypes=systemcomposer.internal.arch.internal.getAllPrototypesFromArchProfile(...
            this.mDDName,true,'Interface');
            this.mStereotypeNames=arrayfun(@(x)x.fullyQualifiedName,...
            allPrototypes,'UniformOutput',false);
        end

        function type=getPrototypeClassForElement(~,elemClass)

            switch elemClass
            case 'systemcomposer.architecture.model.design.Component'
                type='systemcomposer.Component';
            case 'systemcomposer.architecture.model.design.BaseConnector'
                type='systemcomposer.Connector';
            case 'systemcomposer.architecture.model.design.Architecture'
                type='systemcomposer.Component';
            case 'systemcomposer.architecture.model.design.ArchitecturePort'
                type='systemcomposer.Port';
            otherwise
                type='MIXIN';
            end
        end

        function enableApplyButton(this,state)



            dlg=DAStudio.ToolRoot.getOpenDialogs(this);
            if~isempty(dlg)



                dlg.setEnabled('applyButton',state);
                this.mApplyButtonEnabled=state;
            end
        end
    end

    methods



        function[success,msg]=dialogCallback(this,dlg,action)

            success=true;
            msg='';

            switch action
            case 'Apply'
                dlg.apply;
            case 'Close'
                dlg.delete;
            case 'Help'
                this.handleClickHelp();
            end
        end

        function stereotypeSelectionChange(this,dlg,tag)


            rows=dlg.getSelectedTableRows(tag);
            if isempty(rows)



                dlg.setFocus('applyToCombo');
                this.enableApplyButton(false);
            else

                this.enableApplyButton(true);
            end
        end

        function handleApplyToComboChange(this,~,val)



            setApplyToType(this,val);
            updateStereotypesOptions(this);
        end

        function handleScopeComboChange(this,~,val)


            setScopeType(this,val);
            updateStereotypesOptions(this);
        end

        function handleIncludeChildrenChange(this,~,val)

            this.setIncludeChildren(val);
            updateStereotypesOptions(this);
        end

        function[isValid,msg]=handlePreApply(this,dlg)

            isValid=true;
            msg='';

            rows=dlg.getSelectedTableRows('stereotypesTable');
            if isempty(rows)
                isValid=false;
                msg='No stereotypes selected';
                return;
            end



            selectedIdxs=dlg.getSelectedTableRows('stereotypesTable');
            selectedStereotypes=this.mStereotypeNames(selectedIdxs+1);


            for elem=this.mArchitectureElements


                if isa(elem,'systemcomposer.architecture.model.design.Component')
                    e=elem.getArchitecture;

                elseif isa(elem,'systemcomposer.architecture.model.swarch.Function')
                    e=swarch.utils.getPrototypableFunction(elem);
                else
                    e=elem;

                end

                for stName=selectedStereotypes




                    found=false;
                    for p=e.getPrototype
                        if strcmp(char(stName),p.fullyQualifiedName)
                            found=true;
                            break;
                        end
                    end
                    if~found
                        try
                            systemcomposer.internal.arch.applyPrototype(e,char(stName));
                            if(isa(elem,'systemcomposer.architecture.model.design.BaseComponent')&&...
                                (elem.isReferenceComponent||elem.isImplComponent)&&~systemcomposer.internal.isStateflowBehaviorComponent(systemcomposer.utils.getSimulinkPeer(elem)))
                                archName=elem.getParentArchitecture.getName;


                                mdlRefBlksInBd=find_system(archName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','ModelReference');
                                blkH=Simulink.SystemArchitecture.internal.ApplicationManager.getBlockHandleForComponent(elem);
                                mdlName=get_param(blkH,'ModelName');
                                mdlRefBlksToBeRefreshed=find_system(mdlRefBlksInBd,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ModelName',mdlName);
                                for i=1:numel(mdlRefBlksToBeRefreshed)
                                    mdlRefBlk=get_param(mdlRefBlksToBeRefreshed{i},'Object');
                                    mdlRefBlk.refreshModelBlock;
                                end
                            end
                        catch ex
                            dp=DAStudio.DialogProvider;
                            wDlg=dp.warndlg(...
                            ex.message,...
                            DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:ErrorApplyingStereotype'),...
                            true);
                            this.positionDialog(wDlg,dlg);
                        end
                    end
                end
            end


            if this.mScopeType==this.SELECTION
                if isa(this.mArchitectureElements(end),'systemcomposer.architecture.model.interface.PortInterface')

                    systemcomposer.internal.arch.internal.propertyinspector.SysarchInterfacePropertySchema.refresh(this.mArchitectureElements(end));
                else

                    try
                        hdl=systemcomposer.utils.getSimulinkPeer(this.mArchitectureElements(end));
                    catch
                        hdl=-1;
                    end
                    if ishandle(hdl)
                        systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.refresh(hdl);
                    end
                end
            end


            updateStereotypesOptions(this);
        end

        function handleOpenDialog(this,dlg)

            this.positionDialog(dlg,this.mMdlName);
        end

        function[isValid,msg]=handleClose(this,dlg)

            isValid=true;
            msg='';


            warning(this.mIsNullWarnState,'dastudio:studio:IsNull');

            if ishandle(dlg)
                dlg.delete;
            end
        end

        function handleClickHelp(~)


            helpview(fullfile(docroot,'systemcomposer','helptargets.map'),'stereotypeapply');
        end




        function[data,selectedRow]=getStereotypesTableData(this)




            selectedRow=0;
            data=cell(numel(this.mStereotypeNames),1);
            for idx=0:length(data)-1
                data{idx+1}.Type='edit';
                data{idx+1}.Value=this.mStereotypeNames{idx+1};


                if isKey(this.mMap,this.mStereotypeNames{idx+1})


                    if numel(this.mArchitectureElements)==numel(this.mMap(this.mStereotypeNames{idx+1}))


                        data{idx+1}.Enabled=false;
                        if(idx==selectedRow)
                            selectedRow=selectedRow+1;
                        end
                    end
                end
            end
        end

        function schema=getApplyStereotypesSchema(this)

            row=1;
            col=1;


            desc.Type='text';
            desc.Tag='txtDesc';
            desc.RowSpan=[row,row];
            desc.ColSpan=[col,col+1];
            desc.Name=DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:Description');


            row=row+1;
            applyToCombo.Type='combobox';
            applyToCombo.Tag='applyToCombo';
            applyToCombo.Name=DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:ApplyTo');
            applyToCombo.NameLocation=1;

            entries={
            DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:Architecture'),...
            DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:Elements'),...
            DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:Components'),...
            DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:Ports'),...
            DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:Connectors')
            };

            if~isempty(this.mDDName)||systemcomposer.internal.modelHasLocallyScopedInterfaces(bdroot(this.mBDH))

                entries=[entries,...
                {DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:Interfaces')}];
                this.INTERFACES=numel(entries)-1;
            else
                this.INTERFACES=-1;
            end

            if Simulink.internal.isArchitectureModel(bdroot(this.mBDH),'SoftwareArchitecture')
                entries=[entries,...
                {DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:Functions')}];
                this.FUNCTIONS=numel(entries)-1;
            else
                this.FUNCTIONS=-1;
            end

            applyToCombo.Entries=entries;
            applyToCombo.Value=this.mApplyToType;
            applyToCombo.Source=this;
            applyToCombo.ObjectMethod='handleApplyToComboChange';
            applyToCombo.MethodArgs={'%dialog','%value'};
            applyToCombo.ArgDataTypes={'handle','mxArray'};
            applyToCombo.Mode=true;
            applyToCombo.DialogRefresh=true;
            applyToCombo.RowSpan=[row,row];
            applyToCombo.ColSpan=[col,col+1];
            applyToCombo.ToolTip=DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:ApplyToDesc');


            row=row+1;
            scopeCombo.Type='combobox';
            scopeCombo.Tag='scopeCombo';
            scopeCombo.Name=DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:Scope');
            scopeCombo.NameLocation=1;
            if this.mApplyToType==this.INTERFACES

                if systemcomposer.internal.modelHasLocallyScopedInterfaces(this.mBDH)
                    ldMsg=DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:LocalInterfaces');
                else
                    ldMsg=DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:Dictionary',this.mDDName);
                end
                entries={
                DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:Selection'),ldMsg};
                values=[this.SELECTION,this.LOCAL_OR_DICTIONARY];
            elseif~this.mScopeEnabled

                entries={};
                values=[];
            elseif isempty(this.mSelectedElements)

                entries={
                DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:Layer'),...
                DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:EntireModel')};
                values=[this.LAYER,this.ENTIRE_MODEL];
            else

                entries={
                DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:Selection'),...
                DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:Layer'),...
                DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:EntireModel')};
                values=[this.SELECTION,this.LAYER,this.ENTIRE_MODEL];
            end
            scopeCombo.Enabled=this.mScopeEnabled;
            scopeCombo.Entries=entries;
            scopeCombo.Values=values;
            scopeCombo.Source=this;
            scopeCombo.Value=this.mScopeType;
            scopeCombo.ObjectMethod='handleScopeComboChange';
            scopeCombo.MethodArgs={'%dialog','%value'};
            scopeCombo.ArgDataTypes={'handle','mxArray'};
            scopeCombo.Mode=true;
            scopeCombo.DialogRefresh=true;
            scopeCombo.RowSpan=[row,row];
            scopeCombo.ColSpan=[col,col+1];
            scopeCombo.ToolTip=DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:ScopeDesc');

            row=row+1;
            includeChildrenCheckBox.Type='checkbox';
            includeChildrenCheckBox.Tag='includeHierarchy';
            includeChildrenCheckBox.Name=DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:IncludeChildren');
            includeChildrenCheckBox.Value=this.mIncludeChildren;
            includeChildrenCheckBox.Source=this;
            includeChildrenCheckBox.ObjectMethod='handleIncludeChildrenChange';
            includeChildrenCheckBox.MethodArgs={'%dialog','%value'};
            includeChildrenCheckBox.ArgDataTypes={'handle','mxArray'};
            includeChildrenCheckBox.Mode=true;
            includeChildrenCheckBox.DialogRefresh=true;
            includeChildrenCheckBox.Enabled=this.mIncludeChildrenEnabled;
            includeChildrenCheckBox.RowSpan=[row,row];
            includeChildrenCheckBox.ColSpan=[1,2];
            includeChildrenCheckBox.ToolTip=DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:IncludeChildrenDesc');

            row=row+1;
            [tableData,selectedRow]=this.getStereotypesTableData();
            stereotypesTable.Tag='stereotypesTable';
            stereotypesTable.Type='table';
            stereotypesTable.SelectionBehavior='row';
            stereotypesTable.HeaderVisibility=[0,0];
            stereotypesTable.Grid=false;
            stereotypesTable.Data=tableData;
            stereotypesTable.SelectedRow=selectedRow;
            stereotypesTable.ColumnStretchable=[1];
            stereotypesTable.MultiSelect=true;
            stereotypesTable.Source=this;
            stereotypesTable.ObjectMethod='stereotypeSelectionChange';
            stereotypesTable.MethodArgs={'%value'};
            stereotypesTable.ArgDataTypes={'mxArray'};
            stereotypesTable.SelectionChangedCallback=@(dlg,tag)this.stereotypeSelectionChange(dlg,tag);
            stereotypesTable.Graphical=true;
            stereotypesTable.Size=size(this.mStereotypeNames');
            stereotypesTable.RowSpan=[row,row];
            stereotypesTable.ColSpan=[col,col+1];

            schema.Type='group';
            schema.Name='';
            schema.Items={desc,applyToCombo,scopeCombo,includeChildrenCheckBox,stereotypesTable};
            schema.LayoutGrid=[1,col+1];
        end

        function schema=getDialogSchema(this)



            profileSchema=this.getApplyStereotypesSchema();

            panel.Type='panel';
            panel.Tag='main_panel';
            panel.Items={profileSchema};
            panel.LayoutGrid=[4,2];
            panel.RowStretch=[0,0,1,0];
            panel.ColStretch=[1,0];




            applyButton.Type='pushbutton';
            applyButton.Name=DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:Apply');
            applyButton.Tag='applyButton';
            applyButton.WidgetId='apply_button_id';
            applyButton.ObjectMethod='dialogCallback';
            applyButton.MethodArgs={'%dialog','Apply'};
            applyButton.ArgDataTypes={'handle','string'};
            applyButton.Enabled=this.mApplyButtonEnabled;


            closeButton.Type='pushbutton';
            closeButton.Name=DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:Close');
            closeButton.Tag='closeButton';
            closeButton.WidgetId='close_button_id';
            closeButton.ObjectMethod='dialogCallback';
            closeButton.MethodArgs={'%dialog','Close'};
            closeButton.ArgDataTypes={'handle','string'};


            helpButton.Type='pushbutton';
            helpButton.Name=DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:Help');
            helpButton.Tag='helpButton';
            helpButton.WidgetId='help_button_id';
            helpButton.ObjectMethod='dialogCallback';
            helpButton.MethodArgs={'%dialog','Help'};
            helpButton.ArgDataTypes={'handle','string'};

            buttonPanel.Type='panel';
            buttonPanel.LayoutGrid=[1,3];
            buttonPanel.ColStretch=[1,1,1];
            buttonPanel.Items={applyButton,closeButton,helpButton};
            buttonPanel.Tag='applyStereotypesButtonPanel';

            schema.StandaloneButtonSet=buttonPanel;
            schema.OpenCallback=@(dlg)this.handleOpenDialog(dlg);
            schema.PreApplyCallback='handlePreApply';
            schema.PreApplyArgs={this,'%dialog'};
            schema.CloseCallback='handleClose';
            schema.CloseArgs={this,'%dialog'};
            schema.HelpMethod='handleClickHelp';
            schema.HelpArgs={};
            schema.HelpArgsDT={};
            schema.DialogTitle=DAStudio.message('SystemArchitecture:ApplyStereotypesDialog:Title');
            schema.Items={panel};
            schema.DialogTag='system_composer_stereotypes_dialog';
            schema.Source=this;
            schema.SmartApply=true;
            schema.MinMaxButtons=true;
            schema.ShowGrid=1;
            schema.DisableDialog=false;
            schema.Sticky=true;
            schema.ExplicitShow=true;
            schema.DialogRefresh=true;
        end
    end
end

function valid=isValidComponent(comp)


    valid=isa(comp,'systemcomposer.architecture.model.design.BaseComponent')&&...
    ~comp.isReferenceComponent&&~comp.isAdapterComponent&&...
    ~isa(comp,'systemcomposer.architecture.model.design.VariantComponent');
end

function filteredPorts=filterAdapterVariantPorts(ports)
    filteredPorts=[];
    for port=ports
        parentComponent=port.getContainingArchitecture.getParentComponent;
        if~(~isempty(parentComponent)&&parentComponent.isAdapterComponent)&&...
            ~isa(parentComponent,'systemcomposer.architecture.model.design.VariantComponent')
            filteredPorts=[filteredPorts,port];
        end
    end
end


