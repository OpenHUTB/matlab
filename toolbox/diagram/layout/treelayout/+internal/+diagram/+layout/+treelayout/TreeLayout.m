classdef TreeLayout<handle



    properties
        configuration;
        boundsLeft=realmax;
        boundsRight=realmin;
        boundsTop=realmax;
        boundsBottom=realmin;
    end

    properties(Access='private')
        sizeOfLevel=[];

        tree;
        mod;
        thread;
        prelim;
        change;
        shift;
        ancestor;
        number;
        positions;
        nodeBounds;
    end

    methods(Access='private')

        function checkArg(~,condition,message)
            if~condition
                error(message);
            end
        end


        function val=getWidthOrHeightOfNode(obj,treeNode,returnWidth)
            if returnWidth
                val=obj.tree.getNodeWidth(treeNode);
            else
                val=obj.tree.getNodeHeight(treeNode);
            end
        end












        function thickness=getNodeThickness(obj,treeNode)
            thickness=obj.getWidthOrHeightOfNode(treeNode,~obj.isLevelChangeInYAxis());
        end











        function size=getNodeSize(obj,treeNode)
            size=obj.getWidthOrHeightOfNode(treeNode,obj.isLevelChangeInYAxis());
        end

        function change=isLevelChangeInYAxis(obj)
            rootLocation=obj.configuration.RootLocation;
            change=rootLocation==internal.diagram.layout.treelayout.Location.Top||rootLocation==internal.diagram.layout.treelayout.Location.Bottom;
        end

        function sign=getLevelChangeSign(obj)
            rootLocation=obj.configuration.RootLocation;
            if rootLocation==internal.diagram.layout.treelayout.Location.Bottom||rootLocation==internal.diagram.layout.treelayout.Location.Right
                sign=-1;
            else
                sign=1;
            end
        end




        function updateBounds(obj,node,centerX,centerY)
            width=obj.tree.getNodeWidth(node);
            height=obj.tree.getNodeHeight(node);
            left=centerX-width/2;
            right=centerX+width/2;
            top=centerY-height/2;
            bottom=centerY+height/2;

            if obj.boundsLeft>left
                obj.boundsLeft=left;
            end
            if obj.boundsRight<right
                obj.boundsRight=right;
            end
            if obj.boundsTop>top
                obj.boundsTop=top;
            end
            if obj.boundsBottom<bottom
                obj.boundsBottom=bottom;
            end
        end










        function bounds=getBounds(obj)
            bounds=[0,0,obj.boundsRight-obj.boundsLeft,...
            obj.boundsBottom-obj.boundsTop];
        end

        function calcSizeOfLevels(obj,node,level)
            oldSize=0;
            if length(obj.sizeOfLevel)<=level+1
                obj.sizeOfLevel=[obj.sizeOfLevel,0];
            else
                oldSize=obj.sizeOfLevel(level+1);
            end

            size=obj.getNodeThickness(node);
            if oldSize<size
                obj.sizeOfLevel(level+1)=size;
            end

            if~obj.tree.isLeaf(node)
                for child=obj.tree.getChildren(node)
                    obj.calcSizeOfLevels(child,level+1);
                end
            end
        end

        function levels=getLevelCount(obj)
            levels=length(obj.sizeOfLevel);
        end












        function size=getSizeOfLevel(obj,level)
            obj.checkArg(level>=0,'level must be >= 0');
            obj.checkArg(level<obj.getLevelCount(),'level must be < levelCount');

            size=obj.sizeOfLevel(level+1);
        end




        function val=getHashedVal(obj,node,mat,default)
            index=obj.tree.getIndex(node);
            if index>length(mat)
                mat(index)=default;
            end
            val=mat(index);
        end

        function setHashedVal(obj,node,matName,val)
            index=obj.tree.getIndex(node);
            obj.(matName)(index)=val;
        end

        function val=getHashedCell(obj,node,cellarr)
            index=obj.tree.getIndex(node);
            if index>length(cellarr)
                val=[];
            else
                val=cellarr{index};
            end
        end

        function setHashedCell(obj,node,cellName,val)
            index=obj.tree.getIndex(node);
            obj.(cellName){index}=val;
        end

        function mod=getMod(obj,node)
            mod=obj.getHashedVal(node,obj.mod,0);
        end

        function setMod(obj,node,d)
            obj.setHashedVal(node,'mod',d);
        end

        function node=getThread(obj,node)
            node=obj.getHashedCell(node,obj.thread);
        end

        function setThread(obj,node,thread)
            obj.setHashedCell(node,'thread',thread);
        end

        function node=getAncestor(obj,node)
            node=obj.getHashedCell(node,obj.ancestor);
        end


        function setAncestor(obj,node,ancestor)
            obj.setHashedCell(node,'ancestor',ancestor);
        end

        function prelim=getPrelim(obj,node)
            prelim=obj.getHashedVal(node,obj.prelim,0);
        end

        function setPrelim(obj,node,d)
            obj.setHashedVal(node,'prelim',d);
        end

        function change=getChange(obj,node)
            change=obj.getHashedVal(node,obj.change,0);
        end

        function setChange(obj,node,d)
            obj.setHashedVal(node,'change',d);
        end

        function shift=getShift(obj,node)
            shift=obj.getHashedVal(node,obj.shift,0);
        end

        function setShift(obj,node,d)
            obj.setHashedVal(node,'shift',d);
        end











        function distance=getDistance(obj,v,w)
            sizeOfNodes=obj.getNodeSize(v)+obj.getNodeSize(w);

            distance=sizeOfNodes/2...
            +obj.configuration.getGapBetweenNodes(v,w);
        end

        function node=nextLeft(obj,v)
            if obj.tree.isLeaf(v)
                node=obj.getThread(v);
            else
                node=obj.tree.getFirstChild(v);
            end
        end

        function node=nextRight(obj,v)
            if obj.tree.isLeaf(v)
                node=obj.getThread(v);
            else
                node=obj.tree.getLastChild(v);
            end
        end








        function number=getNumber(obj,node,parentNode)
            index=obj.tree.getIndex(node);
            if index>length(obj.number)||obj.number(index)==0
                number=1;
                children=obj.tree.getChildren(parentNode);
                while children(number)~=node
                    number=number+1;
                end
                obj.number(index)=number;
            else
                number=obj.number(index);
            end
        end









        function node=findAncestor(obj,vIMinus,~,parentOfV,defaultAncestor)
            anc=obj.getAncestor(vIMinus);





            if~isempty(anc)&&obj.tree.isChildOfParent(anc,parentOfV)
                node=anc;
            else
                node=defaultAncestor;
            end
        end

        function moveSubtree(obj,wMinus,wPlus,parent,shift)
            subtrees=obj.getNumber(wPlus,parent)-obj.getNumber(wMinus,parent);
            obj.setChange(wPlus,obj.getChange(wPlus)-shift/subtrees);
            obj.setShift(wPlus,obj.getShift(wPlus)+shift);
            obj.setChange(wMinus,obj.getChange(wMinus)+shift/subtrees);
            obj.setPrelim(wPlus,obj.getPrelim(wPlus)+shift);
            obj.setMod(wPlus,obj.getMod(wPlus)+shift);
        end









































        function node=apportion(obj,v,defaultAncestor,leftSibling,parentOfV)
            w=leftSibling;
            if isempty(w)

                node=defaultAncestor;
                return;
            end





            vOPlus=v;
            vIPlus=v;
            vIMinus=w;



            vOMinus=obj.tree.getFirstChild(parentOfV);

            sIPlus=obj.getMod(vIPlus);
            sOPlus=obj.getMod(vOPlus);
            sIMinus=obj.getMod(vIMinus);
            sOMinus=obj.getMod(vOMinus);

            nextRightVIMinus=obj.nextRight(vIMinus);
            nextLeftVIPlus=obj.nextLeft(vIPlus);

            while~isempty(nextRightVIMinus)&&~isempty(nextLeftVIPlus)
                vIMinus=nextRightVIMinus;
                vIPlus=nextLeftVIPlus;
                vOMinus=obj.nextLeft(vOMinus);
                vOPlus=obj.nextRight(vOPlus);
                obj.setAncestor(vOPlus,v);
                shift=(obj.getPrelim(vIMinus)+sIMinus)...
                -(obj.getPrelim(vIPlus)+sIPlus)...
                +obj.getDistance(vIMinus,vIPlus);

                if shift>0
                    obj.moveSubtree(obj.findAncestor(vIMinus,v,parentOfV,defaultAncestor),...
                    v,parentOfV,shift);
                    sIPlus=sIPlus+shift;
                    sOPlus=sOPlus+shift;
                end
                sIMinus=sIMinus+obj.getMod(vIMinus);
                sIPlus=sIPlus+obj.getMod(vIPlus);
                sOMinus=sOMinus+obj.getMod(vOMinus);
                sOPlus=sOPlus+obj.getMod(vOPlus);

                nextRightVIMinus=obj.nextRight(vIMinus);
                nextLeftVIPlus=obj.nextLeft(vIPlus);
            end

            if~isempty(nextRightVIMinus)&&isempty(obj.nextRight(vOPlus))
                obj.setThread(vOPlus,nextRightVIMinus);
                obj.setMod(vOPlus,obj.getMod(vOPlus)+sIMinus-sOPlus);
            end

            if~isempty(nextLeftVIPlus)&&isempty(obj.nextLeft(vOMinus))
                obj.setThread(vOMinus,nextLeftVIPlus);
                obj.setMod(vOMinus,obj.getMod(vOMinus)+sIPlus-sOMinus);
                defaultAncestor=v;
            end
            node=defaultAncestor;
        end






        function executeShifts(obj,v)
            shift=0;
            change=0;
            for w=obj.tree.getChildrenReverse(v)
                change=change+obj.getChange(w);
                obj.setPrelim(w,obj.getPrelim(w)+shift);
                obj.setMod(w,obj.getMod(w)+shift);
                shift=shift+obj.getShift(w)+change;
            end
        end










        function firstWalk(obj,v,leftSibling)
            if obj.tree.isLeaf(v)


                w=leftSibling;
                if~isempty(w)


                    obj.setPrelim(v,obj.getPrelim(w)+obj.getDistance(v,w));
                end
            else


                defaultAncestor=obj.tree.getFirstChild(v);
                previousChild=[];
                for w=obj.tree.getChildren(v)
                    obj.firstWalk(w,previousChild);
                    defaultAncestor=obj.apportion(w,defaultAncestor,previousChild,v);
                    previousChild=w;
                end
                obj.executeShifts(v);
                midpoint=(obj.getPrelim(obj.tree.getFirstChild(v))+obj.getPrelim(obj.tree.getLastChild(v)))/2.0;
                w=leftSibling;
                if~isempty(w)


                    obj.setPrelim(v,obj.getPrelim(w)+obj.getDistance(v,w));
                    obj.setMod(v,obj.getPrelim(v)-midpoint);
                else


                    obj.setPrelim(v,midpoint);
                end
            end
        end










        function secondWalk(obj,v,m,level,levelStart)




            levelChangeSign=obj.getLevelChangeSign();
            levelChangeOnYAxis=obj.isLevelChangeInYAxis();
            levelSize=obj.getSizeOfLevel(level);

            x=obj.getPrelim(v)+m;

            y=0;
            alignment=obj.configuration.AlignmentInLevel;
            if(alignment==internal.diagram.layout.treelayout.AlignmentInLevel.Center)
                y=levelStart+levelChangeSign*(levelSize/2);
            elseif(alignment==internal.diagram.layout.treelayout.AlignmentInLevel.TowardsRoot)
                y=levelStart+levelChangeSign*(obj.getNodeThickness(v)/2);
            else
                y=levelStart+levelSize-levelChangeSign...
                *(obj.getNodeThickness(v)/2);
            end

            if~levelChangeOnYAxis
                t=x;
                x=y;
                y=t;
            end

            obj.setHashedCell(v,'positions',internal.diagram.layout.treelayout.NormalizedPosition(obj,x,y));


            obj.updateBounds(v,x,y);


            if~obj.tree.isLeaf(v)
                nextLevelStart=levelStart...
                +(levelSize+obj.configuration.getGapBetweenLevels(level+1))...
                *levelChangeSign;
                for w=obj.tree.getChildren(v)
                    obj.secondWalk(w,m+obj.getMod(v),level+1,nextLevelStart);
                end
            end
        end
    end

    methods














        function bounds=getNodeBounds(obj)
            if isempty(obj.nodeBounds)
                obj.nodeBounds={};
                for i=1:length(obj.positions)
                    node=obj.tree.getNodeByIndex(i);
                    pos=obj.positions{i};
                    if~isempty(node)&&~isempty(pos)
                        w=obj.tree.getNodeWidth(node);
                        h=obj.tree.getNodeHeight(node);
                        x=pos.getX()-w/2;
                        y=pos.getY()-h/2;
                        obj.nodeBounds{obj.tree.getIndex(node)}=[x,y,w,h];
                    end
                end
            end
            bounds=obj.nodeBounds;
        end















        function obj=TreeLayout(tree)
            obj.tree=tree;
            obj.configuration=internal.diagram.layout.treelayout.TreeLayoutConfiguration;
            obj.mod=[];
            obj.thread={};
            obj.prelim=[];
            obj.change=[];
            obj.shift=[];
            obj.ancestor={};
            obj.number=[];
            obj.positions={};







            r=tree.getRoot();
            obj.firstWalk(r,[]);
            obj.calcSizeOfLevels(r,0);
            obj.secondWalk(r,-obj.getPrelim(r),0,0);
        end

    end

end