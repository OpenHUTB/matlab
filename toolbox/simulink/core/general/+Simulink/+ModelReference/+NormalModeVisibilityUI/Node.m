classdef Node<Simulink.ModelReference.HierarchyExplorerUI.Node


    properties(SetAccess=protected,GetAccess=public)

        m_multiInstanceNormalModeModel=false;
    end

    methods

        function obj=Node(modelName,blockName,normalMode,main,proxy)


            obj=obj@Simulink.ModelReference.HierarchyExplorerUI.Node(modelName,blockName,normalMode,main,proxy);
            obj.m_multiInstanceNormalModeModel=false;
        end

        function setMultiInstanceNormalModeModel(obj,value)
            value=logical(value);
            obj.m_multiInstanceNormalModeModel=value;
        end

    end

    methods(Hidden)


        function[valueStored,valueChanged]=doSetSelected(this,value)
            valueChanged=false;


            if(~this.m_normalMode)
                valueStored=false;
                return;
            end

            if(value==this.m_selected)
                valueStored=value;
                return;
            else
                valueChanged=true;
            end

            this.m_selected=value;
            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('PropertyChangedEvent',this);
            valueStored=value;

            if(value)
                parent=this.getParent();
                if(~isempty(parent))
                    if(~parent.m_selected)
                        setSelected(parent,value);
                    end
                end

                topModelHandle=this.getTopModelHandle();
                allChildren=topModelHandle.getAllChildren();
                for i=1:length(allChildren)
                    child=allChildren(i);
                    if((~isequal(child,this))&&...
                        (isequal(this.m_modelName,child.m_modelName))&&...
                        (child.m_selected))
                        setSelected(child,false);
                    end
                end
            else
                children=this.getChildren();
                for i=1:length(children)
                    child=children(i);
                    if(child.m_selected)
                        setSelected(child,value);
                    end
                end
            end
        end




        function propname=getCheckableProperty(this)
            if(~isempty(this.m_blockName)&&...
                this.m_normalMode&&...
                this.m_multiInstanceNormalModeModel)
                propname='m_selected';
            else
                propname='';
            end
        end



        function cm=getContextMenu(this,~)
            e=this.getEditor;

            am=DAStudio.ActionManager;
            cm=am.createPopupMenu(e);

            Simulink.ModelReference.HierarchyExplorerUI.Node.activeRoot(this);

            eMenu=am.createAction(e,...
            'Text',...
            DAStudio.message('Simulink:modelReference:NormalModeVisibilityExplorerOpenCallback'),...
            'Callback',...
            'Simulink.ModelReference.HierarchyExplorerUI.Node.openCallback;',...
            'StatusTip',...
            DAStudio.message('Simulink:modelReference:NormalModeVisibilityExplorerOpenTooltip'));
            cm.addMenuItem(eMenu);
        end





        function dLabel=getDisplayLabel(this)
            dLabel=this.getName();
        end



        function name=getName(this)
            if(isempty(this.m_blockName))
                name=this.m_modelName;
            else
                name=[this.m_modelName,' (',this.m_blockName,')'];
            end
        end




        function setInitialVisibilities(this,visibilities,depth)
            visibilityMap=containers.Map('KeyType','char','ValueType','any');


            for i=1:length(visibilities)
                visibility=visibilities(i);

                if(visibility.getLength()>=depth)
                    key=visibility.getBlock(depth);

                    if(~visibilityMap.isKey(key))
                        keyedVisibilities=[];
                    else
                        keyedVisibilities=visibilityMap(key);
                    end

                    keyedVisibilities=[keyedVisibilities,visibility];%#ok<AGROW>

                    visibilityMap(key)=keyedVisibilities;
                end
            end



            children=getChildren(this);
            for i=1:length(children)
                child=children(i);





                mangledBlockName=Simulink.SimulationData.BlockPath.manglePath(child.m_blockName);
                if(visibilityMap.isKey(mangledBlockName))
                    child.setSelected(true);

                    setInitialVisibilities(child,visibilityMap(mangledBlockName),depth+1);
                end
            end
        end

    end

end

