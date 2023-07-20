classdef Node<matlab.mixin.internal.TreeNode



    properties(SetAccess=protected,GetAccess=public)

        m_modelName='';


        m_blockName='';


        m_selected=false;


        m_normalMode=true;


        m_main=[];


        m_proxy=[];


        m_blkobj=[];


        m_mdlobj=[];
    end

    methods(Abstract)

        [valueStored,valueChanged]=doSetSelected(this,value)
        propname=getCheckableProperty(this)
        cm=getContextMenu(this,~)
        name=getName(this)
        dLabel=getDisplayLabel(this)

    end

    methods

        function obj=Node(modelName,blockName,normalMode,main,proxy)

            obj.m_modelName=modelName;
            obj.m_blockName=blockName;
            obj.m_main=main;
            obj.m_normalMode=normalMode;
            obj.m_proxy=proxy;


            if(~isempty(blockName))
                obj.m_blkobj=get_param(blockName,'Object');
            end

            obj.m_mdlobj=get_param(modelName,'Object');

            obj.m_selected=false;

        end



        function valueStored=setSelected(this,value)





            if isnumeric(value)
                value=logical(value);
            elseif ischar(value)
                value=logical(str2double(propValue));
            end

            [valueStored,valueChanged]=this.doSetSelected(value);

            if(valueChanged)
                dialog=this.m_main.m_editor.getDialog;
                tag=[Simulink.ModelReference.HierarchyExplorerUI.UI.getUITagBase(),'Apply'];
                dialog.setEnabled(tag,true)
            end
        end




        function varargout=addToHierarchy(this,newNode)
            firstChild=this.getFirstChild;

            if(~isempty(firstChild))&&(firstChild==newNode)

            else
                addChildren(this,newNode);
            end

            if nargout>0
                varargout{1}=newNode;
            end
        end



        function expandChildren(r,c,ime)
            if nargin<3||isempty(ime)
                if isempty(r.getEditor)
                    return;
                end
                ime=DAStudio.imExplorer;
                ime.setHandle(r.getEditor);

                if nargin<2||isempty(c)
                    c=r;
                end
            end

            childNodes=getHierarchicalChildren(c);
            if~isempty(childNodes)
                ime.expandTreeNode(c);

                for i=1:length(childNodes)
                    r.expandChildren(childNodes(i),ime);
                end
            end
        end






        function children=getAllChildren(this)

            children=[];
            currChild=this.getFirstChild;
            while~isempty(currChild)
                catChildren=getAllChildren(currChild);
                children=[children;currChild;catChildren(:)];%#ok<AGROW>                   
                currChild=currChild.getNext();
            end
        end



        function e=getEditor(this)
            e=this.m_main.m_editor;
        end




        function key=getMapKey(this)
            if(isempty(this.m_blockName))
                key=this.m_modelName;
            else
                key=this.m_blockName;
            end
        end





        function topModel=getTopModelHandle(this)

            parent=this.getParent();
            if(~isempty(parent))
                topModel=getTopModelHandle(parent);
            else
                topModel=this;
            end
        end




        function destroy(this)
            allCh=this.getHierarchicalChildren;

            for idx=1:length(allCh)
                destroy(allCh(idx));
                delete(allCh(idx));
            end
        end

    end


    methods(Hidden)




        function proxy=getDialogProxy(this)
            proxy=this.m_proxy;
        end







        function propType=getPropDataType(this,propName)
            propType='other';
            if(strcmp(propName,'m_selected'))
                propType='bool';
            end
        end


        function valid=isValidProperty(~,propname)
            valid=false;
            if strcmp(propname,'m_selected')
                valid=true;
            end
        end


        function setPropValue(this,propName,propValue)
            if(strcmp(propName,'m_selected'))
                value=logical(str2double(propValue));
                this.setSelected(value);
            end
        end


        function value=getPropValue(this,propName)
            if(strcmp(propName,'m_selected'))
                value=eval(['this.',propName]);
                value=num2str(value);
            else
                value='';
            end
        end





        function fileName=getDisplayIcon(this)
            if isempty(this.m_blockName)
                fileName='toolbox/shared/dastudio/resources/SimulinkModelIcon.png';
            elseif this.m_normalMode
                fileName='toolbox/shared/dastudio/resources/MdlRefBlockIconNormal.png';
            else
                fileName='toolbox/shared/dastudio/resources/MdlRefBlockIcon.png';
            end
        end




        function children=getHierarchicalChildren(this)


            children=this.getChildren();
        end






        function val=isHierarchical(~)
            val=true;
        end





        function val=areChildrenOrdered(~)
            val=true;
        end

    end


    methods(Static)


        function ar=activeRoot(varargin)
            persistent ActiveRoot;

            if~isempty(varargin)
                ActiveRoot=varargin{1};
            end
            ar=ActiveRoot;
        end


        function openCallback
            ar=Simulink.ModelReference.HierarchyExplorerUI.Node.activeRoot;

            open_system(ar.m_modelName);

            if~isempty(ar.m_blkobj)
                ar.m_blkobj.exploreAction;
            end
        end

    end

end

