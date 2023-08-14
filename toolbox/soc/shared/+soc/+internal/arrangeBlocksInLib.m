function arrangeBlocksInLib(libName)

















    params.locationX=100;
    params.locationY=100;
    params.leftMargin=75;
    params.topMargin=125;
    params.rightMargin=75;
    params.bottomMargin=200;
    params.blkMarginX=30;
    params.blkMarginY=30;
    params.blkWidth=150;
    params.blkHeight=80;
    params.numBlksInaRow=5;
    params.leftFrameMargin=75;
    params.topFrameMargin=75;

    params.exampleWidth=120;
    params.exampleHeight=50;

    handle=get_param(libName,'Handle');
    rootLib=bdroot(handle);
    lock=get_param(rootLib,'Lock');
    dirty_restorer=Simulink.PreserveDirtyFlag(rootLib,'blockDiagram');%#ok<NASGU>
    set_param(rootLib,'Lock','off');


    scrollOffset=get_param(libName,'ScrollBarOffset');
    scrollOffset=scrollOffset+[60,120];
    scrollOffsetArr=[scrollOffset(1),scrollOffset(2),scrollOffset(1),scrollOffset(2)];
    blks=find_system(libName,'SearchDepth',1,'type','block');
    title=find_system(libName,'SearchDepth',1,'masktype','Library Name');
    blks=setdiff(blks,title);

    if isempty(blks)
        return;
    end


    numBlks=length(blks);
    if(numBlks==0)
        libLocation=get_param(libName,'Location');
        newLocation=[...
        params.locationX,...
        params.locationY,...
        params.locationX+libLocation(3)-liblibLocation(1),...
        params.locationY+libLocation(4)-liblibLocation(2)];
        set_param(libName,'Location',newLocation);
        return
    end


    blkPos=zeros(numBlks,4);
    for i=1:numBlks
        blkPos(i,:)=get_param(blks{i},'Position');
    end
    [~,I]=sort(blkPos(:,2),'ascend');
    blkPos=blkPos(I);
    blks=blks(I);


    numRows=ceil(numBlks/params.numBlksInaRow);
    for i=1:numRows
        numCols=getNumCols(numBlks,params.numBlksInaRow);
        numBlks=numBlks-numCols;
        currTopMargin=params.topMargin+(i-1)*(params.blkHeight+params.blkMarginY);

        iCol=(i-1)*params.numBlksInaRow+1:(i-1)*params.numBlksInaRow+numCols;
        colBlkPos=blkPos(iCol,1);
        blksInRow=blks(iCol);
        [~,I]=sort(colBlkPos,'ascend');


        blksInRow=blksInRow(I);
        for j=1:numCols
            posX=params.leftMargin+(j-1)*(params.blkWidth+params.blkMarginX);
            pos=[posX,currTopMargin,posX+params.blkWidth,...
            currTopMargin+params.blkHeight]+scrollOffsetArr;
            if isequal(get_param(blksInRow{j},'MaskType'),'Target Preferences')
                set_param(blksInRow{j},'Position',[pos(1)+22,pos(2)+5,pos(1)+87,pos(2)+49]);
            else
                if contains(blksInRow{j},'Examples')

                    leftMargin=(params.blkWidth/2)-params.exampleWidth/2;
                    topMargin=(params.blkHeight/2)-params.exampleHeight/2;
                    posX=params.leftMargin+(numCols-1)*(params.blkWidth+params.blkMarginX)+leftMargin;
                    pos=[posX,...
                    currTopMargin+topMargin,posX+params.exampleWidth,...
                    currTopMargin+topMargin+params.exampleHeight]+scrollOffsetArr;
                elseif contains(blksInRow{j},'Templates')

                    leftMargin=(params.blkWidth/2)-params.exampleWidth/2;
                    topMargin=(params.blkHeight/2)-params.exampleHeight/2;
                    posX=params.leftMargin+(numCols)*(params.blkWidth+params.blkMarginX)+leftMargin;
                    pos=[posX,...
                    currTopMargin+topMargin,posX+params.exampleWidth,...
                    currTopMargin+topMargin+params.exampleHeight]+scrollOffsetArr;
                end
                set_param(blksInRow{j},'Position',pos);
            end
        end
    end

    set_param(libName,'ZoomFactor','100');
    set_param(rootLib,'Lock',lock);
end

function numCols=getNumCols(numBlks,numBlksInaRow)

    if(numBlks>=numBlksInaRow)
        numCols=numBlksInaRow;
    else
        numCols=numBlks;
    end
end