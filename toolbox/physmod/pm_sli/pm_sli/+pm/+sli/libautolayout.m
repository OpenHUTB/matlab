function retVal=libautolayout(hSystem,arrangeBlocks)







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




    tmpList=find_system(hSystem,'SearchDepth',1,'LookUnderMasks','graphical',...
    'Parent',getfullname(hSystem));
    nBlocks=numel(tmpList);





    if(nBlocks>1)
        [~,blkSortOrder]=pm.sli.internal.getSortedBlkNames(get_param(tmpList,'Name'));
        blkList=tmpList(blkSortOrder);
    else
        blkList=tmpList;
    end


    hNotes=find_system(hSystem,'SearchDepth',1,'FindAll','on','Type','annotation');


    justSubLibs=false;
    if~isempty(blkList)
        justSubLibs=all(strcmp(get_param(blkList,'ShowName'),'off'));
    end

    if(justSubLibs)
        horzspace=40;
        vertspace=40;
        blockSize.width=100;
        blockSize.height=40;
    else
        horzspace=100;
        vertspace=70;
        blockSize.width=100;
        blockSize.height=40;
    end

    maxcols=4;
    lastRowOffset=0;

    nrows=1;%#ok
    ncols=nBlocks;%#ok


    if(nBlocks<maxcols)
        nrows=1;
        ncols=nBlocks;
    else
        nrows_tmp=nBlocks/maxcols;
        nrows=ceil(nrows_tmp);
        ncols=maxcols;
        if(nrows_tmp<nrows)
            nLastRowBlk=nBlocks-floor(nrows_tmp)*maxcols;
            totalWidth=(maxcols*blockSize.width)+((maxcols-1)*horzspace);
            lastRowOffset=ceil(0.5*(totalWidth-((nLastRowBlk*blockSize.width)+...
            ((nLastRowBlk-1)*horzspace))));
        end
    end

    sysLoc=get_param(hSystem,'Location');
    blockIdx=1;
    for rowidx=1:nrows
        x0=40;
        y0=25+((rowidx-1)*(blockSize.height+vertspace));
        if(rowidx==nrows&&lastRowOffset>0)
            x0=x0+lastRowOffset;
        end

        for colidx=1:ncols

            blkPos=get_param(blkList(blockIdx),'Position');
            blkWt=blkPos(3)-blkPos(1);
            blkHt=blkPos(4)-blkPos(2);


            if ncols==1&&~isempty(hNotes)

                sysWidth=sysLoc(3)-sysLoc(1);
                xmin=(sysWidth-blockSize.width)/2;
            else
                xmin=x0+((colidx-1)*(blockSize.width+horzspace));
            end
            ymin=y0;
            xmax=xmin+blockSize.width;
            ymax=ymin+blockSize.height;


            midX=xmin+floor(0.5*(xmax-xmin));
            midY=ymin+floor(0.5*(ymax-ymin));


            xmin=midX-(0.5*blkWt);
            ymin=midY-(0.5*blkHt);
            xmax=xmin+blkWt;
            ymax=ymin+blkHt;

            set_param(blkList(blockIdx),'Position',[xmin,ymin,xmax,ymax]);
            blockIdx=blockIdx+1;
            if(blockIdx>nBlocks)
                break;
            end
        end
    end

    if(nBlocks==0||nBlocks==1)&&~isempty(hNotes)

        newSysWt=sysLoc(3)-sysLoc(1);
    else
        newSysWt=(ncols*blockSize.width)+((ncols)*horzspace)+40;
    end
    newSysHt=(nrows*blockSize.height)+((nrows)*vertspace);
    sysLoc(3)=sysLoc(1)+newSysWt;
    sysLoc(4)=sysLoc(2)+newSysHt;


    if~isempty(hNotes)
        curNotePos=get(hNotes(1),'Position');
        newNotePos(1)=(newSysWt-(curNotePos(3)-curNotePos(1)))*0.5;
        newNotePos(2)=newSysHt+ceil(.25*vertspace);
        newNotePos(3)=newNotePos(1)+curNotePos(3)-curNotePos(1);
        newNotePos(4)=newNotePos(2)+curNotePos(4)-curNotePos(2);
        set_param(hNotes(1),'Position',newNotePos,...
        'HorizontalAlignment','center',...
        'VerticalAlignment','top');
        sysLoc(4)=sysLoc(4)+ceil(1.5*vertspace);
    else
        sysLoc(4)=sysLoc(4)+ceil(.25*vertspace);
    end

    sysLoc(3)=sysLoc(3)+40;
    sysLoc(4)=sysLoc(4)+210;

    set_param(hSystem,'Location',sysLoc);
end
