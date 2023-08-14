classdef UI<Simulink.ModelReference.HierarchyExplorerUI.UI


    methods

        function this=UI(modelName)
            load_system(modelName);
            this.doInitialization(get_param(modelName,'Handle'));


            l1=Simulink.listener(this.m_root.m_mdlobj,'ObjectBeingDestroyed',@(~,~)this.destroy);
            this.addListener(l1);
        end



        function delete(this)
            Simulink.ModelReference.NormalModeVisibility(this.m_root.m_modelName,'Close');
        end

    end

    methods(Hidden)


        function applySelection(this)
            [visibilities,multiInstanceSet]=getVisibilitiesToSet(this,this.m_root,{});
            if(multiInstanceSet)
                set_param(this.m_root.m_modelName,...
                'ModelBlockNormalModeVisibility',...
                visibilities);
            else
                set_param(this.m_root.m_modelName,...
                'ModelBlockNormalModeVisibility',...
                []);


            end
        end





        function newNode=createNode(this,modelName,blockName,normalMode,proxy)
            newNode=...
            Simulink.ModelReference.NormalModeVisibilityUI.Node(modelName,...
            blockName,...
            normalMode,...
            this,...
            proxy);
        end




        function val=getInstructions(~)
            val=DAStudio.message('Simulink:modelReference:NormalModeVisibilityExplorerInstructions');
        end



        function title=getTitle(~)
            title=DAStudio.message('Simulink:modelReference:NormalModeVisibilityExplorerTitle');
        end



        function tag=getUITag(~)
            tag='NormalModeVisibility';
        end



        function launchHelp(~)
            helpview([docroot,'/toolbox/simulink/ug/simulink_ug.map'],'NormalModeVisibility_HelpButton');
        end




        function setInitialSelectedNodes(this)
            topModel=this.m_root.m_modelName;
            visibilities=get_param(topModel,'ModelBlockNormalModeVisibility');

            this.m_root.setInitialVisibilities(visibilities,1);

            nodes=this.m_root.getAllChildren();


            mdlMap=containers.Map('KeyType','char','ValueType','uint32');
            for i=1:length(nodes)
                node=nodes(i);


                if(~node.m_normalMode)
                    continue;
                end

                mdlName=node.m_modelName;

                if(mdlMap.isKey(mdlName))
                    mdlMap(mdlName)=mdlMap(mdlName)+1;
                else
                    mdlMap(mdlName)=1;
                end
            end


            ed=DAStudio.EventDispatcher;
            for i=1:length(nodes)
                node=nodes(i);

                if(~node.m_normalMode)
                    continue;
                end

                mdlName=node.m_modelName;

                count=mdlMap(mdlName);

                node.setMultiInstanceNormalModeModel(count>1);
            end



            ed.broadcastEvent('HierarchyChangedEvent',this.m_root);
        end

    end

end


function[visibilities,multiInstanceSet]=getVisibilitiesToSet(this,uinode,path)
    visibilities=[];
    multiInstanceSet=false;


    children=uinode.getChildren();

    for idx=1:length(children)
        child=children(idx);
        if child.m_normalMode&&child.m_selected
            newPath=[path,child.m_blockName];

            [childVisibilities,childMultiInstanceSet]=...
            getVisibilitiesToSet(this,child,newPath);
            multiInstanceSet=multiInstanceSet||childMultiInstanceSet;






            if(isempty(childVisibilities))

                if(child.m_multiInstanceNormalModeModel)
                    bp=Simulink.BlockPath(newPath);
                    visibilities=[visibilities,bp];%#ok<AGROW>
                    multiInstanceSet=true;
                end
            else
                visibilities=[visibilities,childVisibilities];%#ok<AGROW>
            end
        end
    end
end