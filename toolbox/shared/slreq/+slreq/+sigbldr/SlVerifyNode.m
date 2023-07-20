classdef SlVerifyNode<handle




    properties
        name;
        slHandle;
        iconIdx;
        checked;
        filtered;
        filtChildren;
        subtreeFlags=0;

        allChildren slreq.sigbldr.SlVerifyNode
        parent slreq.sigbldr.SlVerifyNode
        depth=0;
    end

    methods

        function this=SlVerifyNode(name,slHandle,iconIdx,checked,filtered)
            if nargin<5
                filtered=false;
            end
            if nargin<4
                checked=false;
            end
            if nargin<3
                iconIdx=0;
            end

            this.name=name;
            this.slHandle=slHandle;
            this.iconIdx=iconIdx;
            this.checked=checked;
            this.filtered=filtered;

            this.allChildren=slreq.sigbldr.SlVerifyNode.empty();
            this.parent=slreq.sigbldr.SlVerifyNode.empty();
        end

        function add(this,chNode)
            this.allChildren(end+1)=chNode;
            chNode.parent=this;
        end

        function tf=hasCheckbox(this)
            tf=this.iconIdx==-1;
        end

        function tf=isChecked(this)
            tf=this.checked;
        end


        function propogateFilter(this)
            if this.getChildCount()>0
                this.filtered=true;
                ch=this.children();
                this.filtChildren=slreq.sigbldr.SlVerifyNode.empty();
                for n=1:length(ch)
                    child=ch(n);
                    child.propogateFilter()
                    if~child.filtered
                        this.filtChildren(end+1)=child;
                        this.filtered=false;
                    end
                end
            end
        end

        function removeFilter(this)
            this.filtChildren=slreq.sigbldr.SlVerifyNode.empty();
            if this.getChildCount()>0
                ch=this.children();

                for n=1:length(ch)
                    child=ch(n);
                    child.removeFilter();
                end
            end
            this.filtered=false;
        end

        function setFilter(this,value)
            this.filtered=value;
        end






        function flag=get_subtreeFlags(this)
            flag=this.subtreeFlags;
        end

        function set_subTreeFlags(this,flag)
            this.subtreeFlags=flag;
        end

        function flg=leaf_calc_subTreeFlags(this)
            if this.hasCheckbox()
                if this.isChecked()
                    flg=5;
                else
                    flg=9;
                end
            else
                flg=2;
            end
        end

        function flag=update_subTreeFlags(this)
            flag=0;
            if isempty(this.children)
                flag=this.leaf_calc_subTreeFlags();
            else

                chilrn=this.children;
                for n=1:length(chilrn)
                    child=chilrn(n);
                    flag=bitor(flag,child.update_subTreeFlags());
                end
            end
            this.set_subTreeFlags(flag);
        end


        function update_and_propogate_subTreeFlags(this)
            this.propogate_up_subTreeFlags(this.leaf_calc_subTreeFlags());
        end

        function rt=getRoot(this)
            rt=this;
            pa=this.parent;
            while~isempty(pa)
                rt=pa;
                pa=pa.parent;
            end
        end

        function pa=getParent(this)
            pa=this.parent;
        end

        function propogate_up_subTreeFlags(this,newFlag)
            oldFlag=this.get_subtreeFlags();
            siblingFlag=0;

            root=this.getRoot();

            if isempty(root.filtChildren)

                if~isempty(this.parent)
                    siblings=this.parent.children();
                    for n=length(siblings):-1:1
                        sib=siblings(n);
                        siblingFlag=bitor(siblingFlag,sib.get_subtreeFlags());
                    end
                    for n=1:length(siblings)
                        sib=siblings(n);
                        siblingFlag=bitor(siblingFlag,sib.get_subtreeFlags());
                    end
                end


                if(bitor(oldFlag,siblingFlag)~=bitor(newFlag,siblingFlag))
                    par=this.getParent();

                    if~isempty(par)
                        par.propogate_up_subTreeFlags(bitor(newFlag,siblingFlag));
                    end
                end
            end
            this.set_subTreeFlags(newFlag);

        end

        function setFilteredList(this,list)
            this.filtChildren=list;
        end

        function tf=isFiltered(this)
            tf=this.filtered;
        end

        function tf=isLeaf(this)
            tf=isempty(this.children);
        end

        function ch=children(this)
            if isempty(this.filtChildren)
                ch=this.allChildren;
            else
                ch=this.filtChildren;
            end
        end

        function node=getChildAt(this,childIndex)
            if isempty(this.filtChildren)
                node=this.allChildren(childIndex);
            else
                node=this.filtChildren(childIndex);
            end
        end

        function out=getChildCount(this)
            if isempty(this.filtChildren)
                out=numel(this.allChildren);
            else
                out=numel(this.filtChildren);
            end
        end

        function out=filtChildCount(this)
            out=numel(this.filtChildren);
        end

        function out=getIndex(this,node)
            if isempty(this.filtChildren)
                out=find(this.allChildren==node);
            else
                out=find(this.filtChildren==node);
            end
        end

        function setCheckedNoSideEffect(this,value)
            this.checked=value;
        end

        function setChecked(this,value)
            if(this.checked~=value)
                this.setCheckedNoSideEffect(value);
                this.update_and_propogate_subTreeFlags();
            end
        end

        function setIconIdxNoSideEffect(this,idx)
            this.iconIdx=idx;
        end

        function setIconIdx(this,idx)
            if(this.iconIdx~=idx)
                this.setIconIdxNoSideEffect(idx);
                this.update_and_propogate_subTreeFlags();
            end
        end

        function setVisible(this,tf)%#ok<INUSD>

        end

        function out=getLabel(this)
            out=this.name;
        end

        function setLabel(this,value)
            this.name=value;
        end

        function out=getHandle(this)
            out=this.slHandle;
        end

        function setHandle(this,value)
            this.slHandle=value;
        end

        function setUserObject(this,obj)

            if(obj==this)
                return;
            end
            super.setUserObject(obj);
        end

        function out=getIconIdx(this)
            out=this.iconIdx;
        end

        function out=getLeafCount(this)
            out=reqCountLeavesOf(this);
            function out=reqCountLeavesOf(node)
                out=0;
                chs=node.children;
                if node.isLeaf
                    out=out+1;
                end
                for n=1:length(chs)
                    num=reqCountLeavesOf(chs(n));
                    out=out+num;
                end
            end
        end

        function out=getNodeCount(this)
            out=recCount(this)-1;
            function out=recCount(node)
                out=0;
                chs=node.children;
                out=out+1;
                for n=1:length(chs)
                    num=recCount(chs(n));
                    out=out+num;
                end
            end
        end

        function out=getLeafNodes(this)
            out=collectLeavesOf(this);
            function out=collectLeavesOf(node)
                out=slreq.sigbldr.SlVerifyNode.empty;
                chs=node.allChildren;
                if node.isLeaf
                    out(end+1)=node;
                end
                for n=1:length(chs)
                    nodes=collectLeavesOf(chs(n));
                    out=[out,nodes];%#ok<AGROW>
                end
            end
        end

        function removeAllChildren(this)
            recRemoveChildren(this);
            function recRemoveChildren(node)
                chs=node.allChildren;
                for n=1:length(chs)
                    recRemoveChildren(chs(n));
                end
                node.parent=slreq.sigbldr.SlVerifyNode.empty();
                node.allChildren=slreq.sigbldr.SlVerifyNode.empty();
            end
        end

        function str=getNodeLabel(this)


            str='<html> <font style="font-size:11px" font-family:monospace>';
            wspace='&#8199';
            checkd='&#9745';
            unchecked='&#9744';
            subsys='&#9656';

            for n=1:this.depth-1
                str=[str,wspace];%#ok<AGROW>
            end

            if this.isLeaf()
                if this.iconIdx==2
                    str=[str,wspace,'<font color="gray">',checkd,'</font>',wspace];
                elseif this.checked
                    str=[str,wspace,checkd,wspace];
                else
                    str=[str,wspace,unchecked,wspace];
                end
            else
                str=[str,subsys,wspace];
            end

            isBodyBlack=true;
            if this.hasCheckbox
                if~this.isChecked
                    isBodyBlack=false;
                end
            else
                if this.getIconIdx()>=2

                else
                    isBodyBlack=false;
                end
            end
            if isBodyBlack
                str=[str,this.name];
            else
                str=[str,'<font color="gray">',this.name,'</font>'];
            end

            str=[str,'</font></html>'];
        end

        function str=getListLabel(this)


            wspace='&#8199';
            checkd='&#9745';
            unchecked='&#9744';

            color='';
            if this.hasCheckbox
                if~this.isChecked
                    color='color="gray"';
                end
            else
                if this.getIconIdx()>=2

                else
                    color='color="gray"';
                end
            end

            str=['<html> <font style="font-size:11px" font-family:monospace ',color,' >'];
            if this.slHandle==0

            elseif this.iconIdx==2
                str=[str,wspace,'<font color="gray">',checkd,'</font>',wspace];
            elseif this.checked
                str=[str,wspace,checkd,wspace];
            else
                str=[str,wspace,unchecked,wspace];
            end

            str=[str,this.name];

            str=[str,'</font></html>'];
        end

        function node=getNodeInTree(this,num)
            node=recDFS(this,num,0);
            function[retNode,x]=recDFS(node,num,x)
                retNode=[];
                if x==num
                    retNode=node;
                    x=-1;
                    return;
                end
                x=x+1;
                chs=node.children;
                for n=1:length(chs)
                    if x<0
                        return;
                    end
                    [retNode,x]=recDFS(chs(n),num,x);
                end
            end
        end

        function out=getProperty(this,propName)
            switch propName
            case 'Handle'
                out=this.slHandle;
            otherwise
                error('No such property %s',propName);
            end
        end

        function out=getAllItemsInFlatList(this)
            empty=slreq.sigbldr.SlVerifyNode.empty;
            out=recCollectChildren(this,empty);
            function out=recCollectChildren(node,out)
                if node.depth~=0
                    out=[out,node];
                end
                chs=node.children;
                for n=1:length(chs)
                    out=recCollectChildren(chs(n),out);
                end
            end
        end

        function out=getNodePos(this,obj)

            allitems=this.getAllItemsInFlatList();
            out=find(allitems==obj);
        end
    end
end
