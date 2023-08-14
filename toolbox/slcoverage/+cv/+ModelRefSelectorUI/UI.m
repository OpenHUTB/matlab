classdef UI<Simulink.ModelReference.HierarchyExplorerUI.UI





    properties
        m_CovIncludeTopModel='';
        m_CovModelRefEnable='';
        m_CovModelRefExcluded='';
        m_callerSource=[];
        m_parentDialog=[];
    end

    methods

        function this=UI(modelH,varargin)
            load_system(get_param(modelH,'Name'));

            this.m_parentDialog=varargin{1};

            if numel(varargin)>1
                this.m_CovIncludeTopModel=varargin{2};
                this.m_CovModelRefEnable=varargin{3};
                this.m_CovModelRefExcluded=varargin{4};
            end

            this.m_showObservers=SlCov.CoverageAPI.supportObserverCoverage;
            this.m_addAccelChildren=slfeature('SlCovAccelSimSupport')==1&&...
            strcmpi(get_param(modelH,'CovAccelSimSupport'),'on');

            this.doInitialization(modelH);
            this.m_root.setRoot(this.m_root);
        end

    end
    methods(Hidden,Static)
        function simMode=getSimMode(modelBlock)
            switch lower(get_param(modelBlock,'SimulationMode'))
            case 'software-in-the-loop (sil)'
                simMode='sil';
            case 'processor-in-the-loop (pil)'
                simMode='pil';
            case 'accelerator'
                simMode='accel';
            otherwise
                simMode='normal';
            end
        end
    end

    methods(Hidden)


        function[mdlMap,newNode]=addInstance(this,modelBlock,parentNode,mdlMap,~,isObserver)




            newNode=[];

            if isObserver
                modelName=get_param(modelBlock,'ObserverModelName');
            else
                modelName=get_param(modelBlock,'ModelName');
            end
            topmodel=this.m_root.m_modelName;

            if~this.m_addAccelChildren&&...
                ~strcmpi(topmodel,parentNode.m_modelName)&&...
                strcmpi(parentNode.m_simMode,'accel')

                parentNode.setCheckableProperty(false);
                return;
            end

            try
                load_system(modelName);
            catch ME
                dialogTitle=this.getTitle();
                id='Simulink:modelReference:HierarchyExplorerCouldNotLoadModel';
                msg=DAStudio.message(id,dialogTitle,topmodel,modelName);

                newE=MException(id,msg);
                newE=newE.addCause(ME);
                throw(newE);
            end
            existingNode=[];
            simMode='normal';
            if~isObserver
                simMode=cv.ModelRefSelectorUI.UI.getSimMode(modelBlock);


                if(strcmpi(parentNode.m_simMode,'accel')&&strcmpi(simMode,'normal'))||...
                    strcmpi(parentNode.m_simMode,'sil')||...
                    strcmpi(parentNode.m_simMode,'pil')
                    simMode=parentNode.m_simMode;
                end
                existingNode=findMatchingSibling(modelName,simMode,parentNode);
            end

            if isempty(existingNode)
                newNode=this.createNode(modelName,modelBlock,simMode,this.m_proxy);
                mdlMap(newNode.getMapKey())=newNode;


                if~this.m_addAccelChildren&&...
                    ~strcmpi(topmodel,modelName)&&...
                    strcmpi(newNode.m_simMode,'accel')
                    newNode.setCheckableProperty(false);
                end

                parentNode.addToHierarchy(newNode);
            else
                existingNode.appendModelBlock(modelBlock);
            end

            if this.m_addAccelChildren
                setCheckableProp(this);
            end
        end

        function setCheckableProp(this)
            children=this.m_root.getAllChildren();

            for i=1:numel(children)
                modelName=children(i).m_modelName;
                sameModel=children({children.m_modelName}==string(modelName));
                accModels=sameModel({sameModel.m_simMode}=="accel");
                normalModels=sameModel({sameModel.m_simMode}=="normal");
                if~isempty(accModels)&&~isempty(normalModels)
                    arrayfun(@(x)(x.setCheckableProperty(false)),accModels)
                end
            end
        end


        function applySelection(this)

            store_selected(this);

            if~isempty(this.m_panelH)

                awtinvoke(java(this.m_panelH),'setMdlRefSelStatus','');
            elseif~isempty(this.m_callerSource)
                this.m_callerSource.mdlRefUIOKCallback(this);


                hsrc=this.m_parentDialog.getSource;
                if isa(hsrc,'Simulink.ConfigSet')||isa(hsrc,'SlCovCC.ConfigComp')
                    selection=this.m_parentDialog.getWidgetValue('SlCov_ConfigComp_CovScope');
                    this.m_parentDialog.setWidgetValue('SlCov_ConfigComp_CovScope',selection);
                end
                this.m_parentDialog.enableApplyButton(true,false);
            end
        end





        function newNode=createNode(this,modelName,blockName,normalMode,proxy)
            newNode=...
            cv.ModelRefSelectorUI.Node(modelName,...
            blockName,...
            normalMode,...
            this,...
            proxy);
            newNode.setRoot(this.m_root);
        end



        function val=getInstructions(~)
            if slfeature('SlCovAccelSimSupport')
                covAccelOptionName=DAStudio.message('Slvnv:simcoverage:dialog:CovAccelSimSupport_Name');
                val=DAStudio.message('Slvnv:simcoverage:mdlRefUIInstructions',covAccelOptionName);
            else
                val=DAStudio.message('Slvnv:simcoverage:mdlRefUILegacyInstructions');
            end
        end




        function title=getTitle(~)
            title=DAStudio.message('Slvnv:simcoverage:mdlRefUITitle');
        end



        function tag=getUITag(~)
            tag='slvnv_coverage';
        end



        function launchHelp(~)
            helpview([docroot,'/slcoverage/helptargets.map'],'modelrefselector');
        end



        function setInitialSelectedNodes(this)

            this.m_root.setSelected(strcmpi(this.m_CovIncludeTopModel,'on'));

            children=this.m_root.getAllChildren();
            if~isempty(children)
                if strcmpi(this.m_CovModelRefEnable,'all')||strcmpi(this.m_CovModelRefEnable,'on')
                    for idx=1:numel(children)
                        cc=children(idx);
                        isSelected=1;

                        if strcmpi(cc.m_simMode,'accel')&&~this.m_addAccelChildren
                            isSelected=0;
                        end
                        cc.setSelected(isSelected);
                    end
                elseif strcmpi(this.m_CovModelRefEnable,'filtered')
                    excludedModelInfo=SlCov.Utils.extractExcludedModelInfo(this.m_CovModelRefExcluded);
                    for idx=1:numel(children)
                        cc=children(idx);
                        if isfield(excludedModelInfo,cc.m_simMode)
                            excludedModelsOfType=excludedModelInfo.(cc.m_simMode);
                            if strcmpi(cc.m_simMode,'accel')&&~this.m_addAccelChildren
                                isSelected=0;
                            else
                                isSelected=~ismember(cc.m_modelName,excludedModelsOfType);
                            end
                            cc.setSelected(isSelected);
                        end
                    end
                else
                    for idx=1:numel(children)
                        cc=children(idx);
                        cc.setSelected(0);
                    end
                end
            end
        end


        function set_root_enabled_status(this)


            root=this.m_root;
            if~isempty(this.m_panelH)
                root.setSelected(this.m_panelH.getCovEnabled);
            elseif~isempty(this.m_callerSource)
                root.setSelected(this.m_callerSource.getCovEnabled);
            else
                root.setSelected(strcmpi(get_param(root.m_modelName,'RecordCoverage'),'on'));
            end
            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('HierarchyChangedEvent',root);

        end


        function cb=getDestroyCallback(~)
            cb=[];
        end


    end


    methods(Static)


        function simModeChanged(selectorObj,varargin)

            if~isa(selectorObj,'cv.ModelRefSelectorUI.UI')||~ishandle(selectorObj.m_editor)
                return
            end

            dialog=selectorObj.m_editor.getDialog();
            if~isempty(dialog)
                tag=[Simulink.ModelReference.HierarchyExplorerUI.UI.getUITagBase(),'Apply'];
                dialog.setEnabled(tag,true);
            end

        end

    end

end


function node=findMatchingSibling(modelName,simMode,parentH)
    node=[];

    if~isempty(parentH)
        siblings=parentH.getChildren();
        if~isempty(siblings)
            sameModels=siblings({siblings.m_modelName}==string(modelName));
            if~isempty(sameModels)
                node=sameModels({sameModels.m_simMode}==string(simMode));
            end
        end
    end
end

function store_selected(this)


    if this.m_root.m_selected
        this.m_CovIncludeTopModel='on';
    else
        this.m_CovIncludeTopModel='off';
    end


    children=this.m_root.getAllChildren();
    excludedChildren={};

    if~isempty(children)


        modelModeSelections=[];
        for idx=1:length(children)
            cc=children(idx);
            modelModeSelections.(cc.m_modelName).(cc.m_simMode)=cc.m_selected;
        end



        modelNames=fields(modelModeSelections);
        for idx=1:length(modelNames)
            curModel=modelNames{idx};
            curModeSelections=modelModeSelections.(curModel);
            curModelSimModes=fields(curModeSelections);
            allModesExcluded=true;
            excludedChildSimModes=[];
            for modeIdx=1:length(curModelSimModes)
                curSimMode=curModelSimModes{modeIdx};
                curSelected=curModeSelections.(curSimMode);
                if curSelected
                    allModesExcluded=false;
                else
                    identifier=[curModel,':',curSimMode];
                    excludedChildSimModes=cat(2,excludedChildSimModes,{identifier});
                end
            end



            if allModesExcluded
                excludedChildSimModes={curModel};
            end

            excludedChildren=cat(2,excludedChildren,excludedChildSimModes);
        end
    end

    if isempty(excludedChildren)
        this.m_CovModelRefEnable='all';
        this.m_CovModelRefExcluded='';
    else
        this.m_CovModelRefEnable='filtered';
        this.m_CovModelRefExcluded=excludedChildren{1};
        for idx=2:numel(excludedChildren)
            this.m_CovModelRefExcluded=[this.m_CovModelRefExcluded,',',excludedChildren{idx}];
        end
    end
end


