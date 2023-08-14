function treenode=setjavaxtreenode(varargin)











    err=javachk('Swing','SIMULINK');
    if~isempty(err)
        error(err);
    end


    if nargin==1
        model=varargin{1};


        blks=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
    elseif nargin==2
        model=varargin{1};
        blks=varargin{2};
    else
        treenode=javax.swing.tree.DefaultMutableTreeNode;
        return;
    end
    treenode=javax.swing.tree.DefaultMutableTreeNode(model);

    prevBlkParent='';
    lastNode=[];

    for i=1:length(blks)
        lvl=0;
        blk=blks{i};


        thisBlkParent=get_param(blk,'Parent');




        blk=regexprep(blk,'//','~|');
        thisBlkParent=regexprep(thisBlkParent,'//','~|');
        prevBlkParent=regexprep(prevBlkParent,'//','~|');


        [tmp,blk]=strtok(blk,'/');

        if~isempty(findstr(thisBlkParent,'/'))&&...
            ~isempty(lastNode)

            prevNodeDepth=length(findstr(prevBlkParent,'/'))+1;

            thisBlk=thisBlkParent;
            prevBlk=prevBlkParent;


            if prevNodeDepth~=0&&~isempty(thisBlkParent)
                for nodeIdx=1:prevNodeDepth
                    [thisNode,thisBlk]=strtok(thisBlk,'/');
                    [prevNode,prevBlk]=strtok(prevBlk,'/');
                    if strcmp(thisNode,prevNode)
                        lvl=lvl+1;
                    else
                        break;
                    end
                end
            end


            for j=1:lvl-1
                [tmp,blk]=strtok(blk,'/');
            end


            for j=1:length(findstr(prevBlkParent,'/'))+2-lvl
                lastNode=lastNode.getParent;
                if isempty(lastNode)
                    DAStudio.error('Simulink:blocks:corruptedDialogStructure');
                end
            end
        end

        while~isempty(blk)
            [nodeStr,blk]=strtok(blk,'/');


            sp=find((nodeStr==10)==1);
            if~isempty(sp)
                nodeStr(sp)=' ';
            end


            nodeStr=strrep(nodeStr,'~|','/');


            node=javax.swing.tree.DefaultMutableTreeNode(nodeStr);

            if lvl==0
                treenode.add(node);
                lvl=lvl+1;
            else
                lastNode.add(node);
            end
            lastNode=node;

        end

        prevBlkParent=get_param(blks{i},'Parent');
    end


