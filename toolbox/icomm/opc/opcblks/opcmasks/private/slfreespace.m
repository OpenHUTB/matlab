function pos=slfreespace(srcBlk,destSys);
















    confPos=get_param(srcBlk,'Position');
    confSize=confPos([3,4])-confPos([1,2]);


    blks=find_system(destSys,'SearchDepth',1,'type','block');



    lns=find_system(destSys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','type','line');
    if isempty(blks),

        pos=[15,15,15+confSize];
    else
        blkPos=get_param(blks,'Position');
        blkPos=vertcat(blkPos{:});
        maxX=max(blkPos(:,3));
        maxY=max(blkPos(:,4));

        blkRect=[blkPos(:,1:2),blkPos(:,3:4)-blkPos(:,1:2)];

        if isempty(lns),
            lnVerts=[];
        else
            lnPts=get(lns,'Points');
            lnVerts=[];
            if~iscell(lnPts),
                lnPts={lnPts};
            end
            for k=1:length(lnPts)
                numVerts=size(lnPts{k},1)-1;
                thisVerts=zeros(numVerts,4);
                for v=1:numVerts
                    thisVerts(v,:)=[lnPts{k}(v,:),lnPts{k}(v+1,:)];
                end
                lnVerts(end+1:end+numVerts,1:4)=thisVerts;
            end
        end



        curPos=[15,0];
        canPlace=false;
        while~canPlace
            curPos(2)=curPos(2)+15;

            if(curPos(2)>(maxY-confSize(2)))
                curPos(2)=15;
                curPos(1)=curPos(1)+15;
                if(curPos(1)>(maxX-confSize(1)))
                    curPos=[15,maxY+15];
                    break;
                end
            end

            p=[curPos-[14,14],confSize+[28,28]];
            canPlace=all(rectint(p,blkRect)==0)&&~overline(lnVerts,p);
        end

        pos=[curPos,curPos+confSize];
    end


    function tf=overline(lnVerts,boxRect);

        bx1=boxRect(1);
        bx2=boxRect(1)+boxRect(3);
        by1=boxRect(2);
        by2=boxRect(2)+boxRect(4);
        tf=false;
        for k=1:size(lnVerts,1)
            x1=min(lnVerts(k,[1,3]));
            x2=max(lnVerts(k,[1,3]));
            y1=min(lnVerts(k,[2,4]));
            y2=max(lnVerts(k,[2,4]));

            if((x1==x2)&&(x1>bx1)&&(x1<bx2))&&((y1<=by1&&y2>=by1)||(y1<=by2&&y2>=by2))||...
                ((y1==y2)&&(y1>by1)&&(y1<by2))&&((x1<=bx1&&x2>=bx1)||(x1<=bx2&&x2>=bx2))
                tf=true;
                break;
            end
        end
