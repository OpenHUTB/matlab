function retVal=layoutconservative(hSystem,arrangeBlocks)
















    if nargin<2
        arrangeBlocks=true;
    end

    hSystem=get_param(hSystem,'Handle');


    lPositionBlkDgm(hSystem);


    if arrangeBlocks
        lBlockAutoLayout(hSystem);
    end

    retVal=true;

end

function lPositionBlkDgm(hSystem)


    hParent=get_param(hSystem,'Parent');
    if~isempty(hParent)
        hParent=get_param(hParent,'Handle');

        parentLoc=get_param(hParent,'Location');
        offset=[20,27];
        basePt=parentLoc(1:2)+offset;
    else
        basePt=[30,60];
    end

    libLoc=get_param(hSystem,'Location');
    libLoc(3)=basePt(1)+(libLoc(3)-libLoc(1));
    libLoc(4)=basePt(2)+(libLoc(4)-libLoc(2));
    libLoc(1)=basePt(1);
    libLoc(2)=basePt(2);
    set_param(hSystem,'Location',libLoc);

end

function lBlockAutoLayout(hSystem)


    if(strcmpi(get_param(hSystem,'Type'),'block_diagram')&&...
        ~isempty(get_param(hSystem,'Parent')))
        return;
    end


    tmpList=find_system(hSystem,'SearchDepth',1,...
    'LookUnderMasks','graphical');
    nBlocks=numel(tmpList);
    matchIdx=find(strcmp(getfullname(hSystem),getfullname(tmpList)));
    if~isempty(matchIdx)
        tmpList(matchIdx)=[];
        nBlocks=nBlocks-1;
    end
    blkList=tmpList;


    hNotes=find_system(hSystem,'SearchDepth',1,'FindAll','on',...
    'Type','annotation');



    justSubLibs=false;
    if~isempty(blkList)
        justSubLibs=strcmp(get_param(blkList(1),'ShowName'),'off');
    end


    if(justSubLibs)
        horzspace=40;
        vertspace=40;
        defaultWidth=100;
        defaultHeight=40;
    else
        horzspace=100;
        vertspace=70;
        defaultWidth=100;
        defaultHeight=40;
    end

    maxcols=4;



    needsLastRow=false;
    if(nBlocks<maxcols)
        nrows=1;
        ncols=nBlocks;
    else
        ncols=maxcols;
        nrows=nBlocks/maxcols;
        nrows_tmp=floor(nrows);
        if nrows_tmp<nrows
            needsLastRow=true;
            nrows=nrows_tmp;
        end
    end

    positions=get_param(blkList,'Position');

    if iscell(positions)
        positions=cell2mat(positions);
    end

    blockWidths=positions(:,3)-positions(:,1);
    blockHeights=positions(:,4)-positions(:,2);

    sysLoc=get_param(hSystem,'Location');
    blockIdx=1;


    columnWidth=repmat(defaultWidth,1,ncols);
    rowHeight=repmat(defaultHeight,1,nrows);



    for idx=1:ncols
        startIdx=(idx-1)*nrows+1;
        if nrows==1
            colWidths=blockWidths;
        else
            colWidths=blockWidths(startIdx:startIdx+nrows-1);
        end
        maxWidth=max(colWidths);
        if columnWidth(idx)<maxWidth
            columnWidth(idx)=maxWidth;
        end
    end



    for idx=1:nrows
        heights=blockHeights(idx:nrows:nrows*ncols);
        maxHeight=max(heights);
        if rowHeight(idx)<maxHeight
            rowHeight(idx)=maxHeight;
        end
    end

    xmargin=40;
    ymargin=25;


    yNext=ymargin;
    for rowidx=1:nrows
        xNext=xmargin;

        y0=yNext;
        yNext=y0+rowHeight(rowidx)+vertspace;

        for colidx=1:ncols
            x0=xNext;
            xNext=x0+columnWidth(colidx)+horzspace;


            xmin=x0;
            ymin=y0;
            xmax=xmin+columnWidth(colidx);
            ymax=ymin+rowHeight(rowidx);

            p=lComputePosition(blkList(blockIdx),[xmin,ymin,xmax,ymax]);
            set_param(blkList(blockIdx),'Position',p);

            blockIdx=blockIdx+1;

        end
    end



    sysWidth=sum(columnWidth)+xmargin*2+(ncols)*horzspace;
    sysHeight=sum(rowHeight)+ymargin*2+(nrows-1)*vertspace;


    newSysWt=sysWidth;
    newSysHt=sysHeight;


    if needsLastRow


        nBlocksInLastRow=nBlocks-(nrows*ncols);


        lastRowBlockWidths=blockWidths(nBlocks-nBlocksInLastRow+1:nBlocks);
        lastRowBlockHeights=blockHeights(nBlocks-nBlocksInLastRow+1:nBlocks);



        lastRowBlockWidths(lastRowBlockWidths<defaultWidth)=defaultWidth;
        lastRowBlockHeights(lastRowBlockHeights<defaultHeight)=defaultHeight;

        totalLastRowBlockWidths=sum(lastRowBlockWidths);
        maxLastRowHeight=max(lastRowBlockHeights);



        if(totalLastRowBlockWidths+2*ymargin+(nBlocksInLastRow-1)*horzspace...
            >sysWidth)
            warning('pm:sli:liblayout_nooverlap:LastRowTooWide',...
            'Last row is too wide');
        end


        y0=sysHeight+vertspace;
        ymin=y0;
        ymax=y0+maxLastRowHeight;


        totalWidth=sum(columnWidth)+(ncols-1)*horzspace;
        xNext=xmargin+...
        0.5*(totalWidth-...
        (totalLastRowBlockWidths+(nBlocksInLastRow-1)*horzspace));



        for idx=1:nBlocksInLastRow
            xmin=xNext;
            xmax=xmin+lastRowBlockWidths(idx);
            xNext=xNext+lastRowBlockWidths(idx)+horzspace;
            p=lComputePosition(blkList(nBlocks-nBlocksInLastRow+idx),...
            [xmin,ymin,xmax,ymax]);
            set_param(blkList(nBlocks-nBlocksInLastRow+idx),'Position',p);
        end
        newSysHt=y0+maxLastRowHeight+vertspace;
    end


    sysLoc(3)=sysLoc(1)+newSysWt;
    sysLoc(4)=sysLoc(2)+newSysHt;


    if~isempty(hNotes)
        notePos(1)=(newSysWt*0.5);
        notePos(2)=newSysHt;
        set_param(hNotes(1),'Position',notePos);
        sysLoc(4)=sysLoc(4)+ceil(vertspace);
    else
        sysLoc(4)=sysLoc(4)+ceil(.25*vertspace);
    end

    set_param(hSystem,'Location',sysLoc);
end

function pOut=lComputePosition(blk,pIn)

    blkPos=get_param(blk,'Position');
    blkWt=blkPos(3)-blkPos(1);
    blkHt=blkPos(4)-blkPos(2);

    xmin=pIn(1);
    ymin=pIn(2);
    xmax=pIn(3);
    ymax=pIn(4);


    midX=xmin+floor(0.5*(xmax-xmin));
    midY=ymin+floor(0.5*(ymax-ymin));


    xmin=midX-(0.5*blkWt);
    ymin=midY-(0.5*blkHt);
    xmax=xmin+blkWt;
    ymax=ymin+blkHt;

    pOut=[xmin,ymin,xmax,ymax];
end

