classdef Node<Simulink.ModelReference.HierarchyExplorerUI.Node





    properties(SetAccess=protected,GetAccess=public)
        m_root=[];
        m_simMode='';
        m_copiedBlocks=[];
        m_isObserver=false;
        m_isCheckable=true;
    end

    methods

        function this=Node(modelName,blockName,simMode,main,proxy)


            this=this@Simulink.ModelReference.HierarchyExplorerUI.Node(modelName,blockName,strcmpi(simMode,'normal'),main,proxy);
            this.m_copiedBlocks=[];
            if isempty(blockName)
                simMode=cv.ModelRefSelectorUI.UI.getSimMode(modelName);
            elseif strcmpi(get_param(blockName,'BlockType'),'ObserverReference')
                this.m_isObserver=true;
            end
            this.m_simMode=simMode;
        end

        function setRoot(this,aNode)
            this.m_root=aNode;
        end

    end

    methods(Hidden)


        function appendModelBlock(this,modelBlock)

            if isempty(this.m_copiedBlocks)
                this.m_copiedBlocks={modelBlock};
            else
                this.m_copiedBlocks{end+1}=modelBlock;
            end
        end



        function[valueStored,valueChanged]=doSetSelected(this,value)
            valueChanged=false;



            if(value==this.m_selected)
                valueStored=value;
                return;
            else
                valueChanged=true;
            end

            children=findMultiInstance(this);
            for idx=1:numel(children)
                children(idx).m_selected=value;
            end

            ed=DAStudio.EventDispatcher;
            for idx=1:numel(children)
                ed.broadcastEvent('PropertyChangedEvent',children(idx));
            end
            valueStored=value;
        end

        function setCheckableProperty(this,val)
            this.m_isCheckable=val;
        end


        function propname=getCheckableProperty(this)

            if~this.m_isCheckable
                propname='';
            else
                propname='m_selected';
            end
        end



        function cm=getContextMenu(this,~)

            e=this.getEditor;

            am=DAStudio.ActionManager;
            cm=am.createPopupMenu(e);

            Simulink.ModelReference.HierarchyExplorerUI.Node.activeRoot(this);
            children=this.getAllChildren()';

            selStatus=[];
            if(~isempty(children))
                selStatus=[children.m_selected];
            end

            selStatus=nonzeros(selStatus);
            allSelected=isequal(length(selStatus),length(children));
            allUnSelected=isequal(length(selStatus),0);

            if~allSelected&&this.m_normalMode
                eMenu=am.createAction(e,...
                'Text',getString(message('Slvnv:simcoverage:mdlRefUISelectAllCallback')),...
                'Callback','cv.ModelRefSelectorUI.Node.enableCallback(1);',...
                'Icon',fullfile(matlabroot,'toolbox','slcoverage','@cv','@CovMdlRefSelUI'),...
                'StatusTip',getString(message('Slvnv:simcoverage:mdlRefUISelectAllTooltip')));
                cm.addMenuItem(eMenu);
            end

            if~allUnSelected&&this.m_normalMode
                eMenu=am.createAction(e,...
                'Text',getString(message('Slvnv:simcoverage:mdlRefUIDeselectAllCallback')),...
                'Callback','cv.ModelRefSelectorUI.Node.enableCallback(0);',...
                'Icon',fullfile(matlabroot,'toolbox','slcoverage','@cv','@CovMdlRefSelUI'),...
                'StatusTip',getString(message('Slvnv:simcoverage:mdlRefUIDeselectAllTooltip')));
                cm.addMenuItem(eMenu);
            end

            eMenu=am.createAction(e,...
            'Text',getString(message('Slvnv:simcoverage:mdlRefUIOpenCallback')),...
            'Callback','Simulink.ModelReference.HierarchyExplorerUI.Node.openCallback;',...
            'Icon',fullfile(matlabroot,'toolbox','slcoverage','@cv','@CovMdlRefSelUI'),...
            'StatusTip',getString(message('Slvnv:simcoverage:mdlRefUIOpenTooltip')));
            cm.addMenuItem(eMenu);
        end



        function name=getDisplayLabel(this)

            suffix='';
            if this.m_isObserver
                suffix=' (Observer)';
            elseif strcmp(this.m_simMode,'sil')
                suffix=' (SIL)';
            elseif strcmp(this.m_simMode,'pil')
                suffix=' (PIL)';
            elseif strcmp(this.m_simMode,'accel')
                suffix=' (Accel)';
            end

            name=[this.getName(),suffix];

        end



        function name=getName(this)
            name=this.m_modelName;
        end


        function retVal=getPropertyStyle(this,~)



            retVal=DAStudio.PropertyStyle;

            tooltip=this.m_blockName;
            for i=1:length(this.m_copiedBlocks)
                tooltip=sprintf('%s,\n%s',tooltip,this.m_copiedBlocks{i});
            end

            retVal.Tooltip=tooltip;

        end

    end


    methods(Static)

        function enableCallback(enable)


            ar=Simulink.ModelReference.HierarchyExplorerUI.Node.activeRoot;
            setSelected(ar,enable);
            allCh=ar.getAllChildren();
            for idx=1:length(allCh)
                setSelected(allCh(idx),enable);
            end

        end

    end

end



function res=findMultiInstance(this)
    if isempty(this.m_root)||(strcmpi(this.m_modelName,this.m_root.m_modelName))

        res=this;
        return;
    end

    children=this.m_root.getAllChildren();

    if(~isempty(children))
        modelNames={children.m_modelName};
        simModes={children.m_simMode};

        resi=[];
        for idx=1:numel(modelNames)
            if strcmpi(modelNames{idx},this.m_modelName)...
                &&strcmp(simModes{idx},this.m_simMode)
                resi(end+1)=idx;%#ok<AGROW>
            end
        end
        res=children(resi);
    else
        res=children;
    end
end
