



































function[isGroundPoint,isGroundGridMap,in]=pcFindGroundPoints(pts,xLim,yLim,zLim,gridResolution,heightChangeFactor)

    if nargin<6
        heightChangeFactor=0.22;
    end

    [pts,in]=validateInputsPcRemoveGroundPoints(pts,xLim,yLim,zLim,gridResolution,heightChangeFactor);



    imHeight=ceil((xLim(2)-xLim(1))/gridResolution);
    imWidth=ceil((yLim(2)-yLim(1))/gridResolution);

    rowMidPoint=floor(imHeight/2);
    colMidPoint=floor(imWidth/2);


    h=zLim(2)*ones(imHeight,imWidth);


    H=zLim(1)*ones(size(h));
    hhat=zeros(size(h));


    isGroundGridMap=false(size(h));



    ptsX_index=max(min(imHeight-floor(pts(:,1)/gridResolution+rowMidPoint)+1,imHeight),1);
    ptsY_index=max(min(imWidth-floor(pts(:,2)/gridResolution+colMidPoint)+1,imWidth),1);


    for i=1:size(pts,1)
        row=ptsX_index(i);
        col=ptsY_index(i);
        h(row,col)=min(h(row,col),pts(i,3));
        H(row,col)=max(H(row,col),pts(i,3));
    end



    s=heightChangeFactor*gridResolution;

    isGroundGridMap(rowMidPoint,colMidPoint)=true;

    for x=[0:rowMidPoint,-1:-1:-rowMidPoint+1]
        for y=[0:colMidPoint,-1:-1:-colMidPoint+1]

            startX=rowMidPoint+x;
            startY=colMidPoint+y;


            maxH=h(startX,startY);
            for i=-1:1
                for j=-1:1
                    ii=startX+i;
                    jj=startY+j;
                    if ii>=1&&ii<=size(hhat,1)&&jj>=1&&jj<=size(hhat,2)
                        if h(ii,jj)>maxH
                            maxH=h(ii,jj);
                        end
                    end
                end
            end


            for i=-1:1
                for j=-1:1
                    ii=startX+i;
                    jj=startY+j;
                    if ii>=1&&ii<=size(hhat,1)&&jj>=1&&jj<=size(hhat,2)
                        hhat(ii,jj)=maxH;

                        isGroundGridMap(ii,jj)=(H(ii,jj)-h(ii,jj)<s)&&(H(ii,jj)<hhat(ii,jj)+s);

                        if isGroundGridMap(ii,jj)
                            hhat(ii,jj)=H(ii,jj);
                        end

                    end
                end
            end
        end
    end

    isGroundPoint=isGroundGridMap(sub2ind(size(isGroundGridMap),ptsX_index,ptsY_index));
end

function[pts,in]=validateInputsPcRemoveGroundPoints(pts,xLim,yLim,zLim,gridResolution,heightChangeFactor)

    functionName=mfilename;
    if isa(pts,'pointCloud')
        [pts,in]=removeInvalidPoints(pts);
        pts=pts.Location;
    else
        in=[];
        validateattributes(pts,{'numeric'},{'nonempty','real','nonsparse','ncols',3},functionName,'pts',1);
    end
    validateattributes(xLim,{'numeric'},{'increasing','finite','real','nonsparse','size',[1,2]},functionName,'xLim',2);
    validateattributes(yLim,{'numeric'},{'increasing','finite','real','nonsparse','size',[1,2]},functionName,'yLim',3);
    validateattributes(zLim,{'numeric'},{'increasing','finite','real','nonsparse','size',[1,2]},functionName,'zLim',4);
    validateattributes(gridResolution,{'numeric'},{'scalar','finite','real','nonsparse'},functionName,'gridResolution',5);
    validateattributes(heightChangeFactor,{'numeric'},{'scalar','finite','real','nonsparse'},functionName,'heightChangeFactor',6);
end
