function setBlockPositions(varargin)




    if(nargin<1)
        MSLDiagnostic('TARGETFOUNDATION:blocks:setBlockPositionsNoLibName').reportAsWarning;
    elseif(nargin<2)
        params.locationX=100;
        params.locationY=100;
        params.leftMargin=35;
        params.topMargin=80;
        params.rightMargin=35;
        params.bottomMargin=35;
        params.blkMarginX=35;
        params.blkMarginY=25;
        params.blkWidth=100;
        params.blkHeight=60;
        params.numBlksInaRow=4;
        params.leftFrameMargin=170;
        params.topFrameMargin=170;
    else
        params=varargin{2};
    end


    libName=varargin{1};
    set_param(libName,'Lock','off');
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
                set_param(blksInRow{j},'Position',pos);
            end
        end
    end


    numCols=getNumCols(length(blks),params.numBlksInaRow);
    libLocation=[params.locationX,params.locationY,...
    params.locationX+params.leftMargin+numCols*params.blkWidth+...
    (numCols-1)*params.blkMarginX+params.rightMargin+params.leftFrameMargin,...
    params.locationY+params.topMargin+numRows*params.blkHeight+...
    (numRows-1)*params.blkMarginY+params.bottomMargin+params.topFrameMargin];
    if~isempty(title)
        set_param(title{1},'position',getTitlePosition(title,libLocation,params.leftFrameMargin)+scrollOffsetArr);
    end
    set_param(libName,'ZoomFactor','100');


    function numCols=getNumCols(numBlks,numBlksInaRow)

        if(numBlks>=numBlksInaRow)
            numCols=numBlksInaRow;
        else
            numCols=numBlks;
        end


        function pos=getTitlePosition(title,libLocation,leftFrameMargin)
            titlepos=get_param(title{1},'position');
            libwidth=(libLocation(3)-leftFrameMargin)-libLocation(1);
            titlewidth=titlepos(3)-titlepos(1);
            titleheight=titlepos(4)-titlepos(2);
            x1=(libwidth-titlewidth)/2;
            y1=(80-titleheight)/2;
            x2=x1+titlewidth;
            y2=y1+titleheight;
            pos=[x1,y1,x2,y2];
