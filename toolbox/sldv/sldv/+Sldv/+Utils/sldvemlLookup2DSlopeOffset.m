function[slpX,slpY,off]=sldvemlLookup2DSlopeOffset(mode,nx,ny,x,y,table)




    assert(mode==0||mode==1,getString(message('Sldv:sldv:EmlAuthoring:FailRecogTableType')));

    if mode==0
        slpX=zeros(int32(nx-1),int32(ny-1));
        slpY=zeros(int32(nx-1),int32(ny-1));
        off=zeros(int32(nx-1),int32(ny-1));
        for xIdxL=1:int32(nx-1)
            xIdxR=xIdxL+1;
            for yIdxL=1:int32(ny-1)
                yIdxR=yIdxL+1;
                [slpX(xIdxL,yIdxL),slpY(xIdxL,yIdxL),off(xIdxL,yIdxL)]=...
                utilSlopeOffset(mode,nx,ny,xIdxL,xIdxR,yIdxL,yIdxR,x,y,table);
            end
        end
    else
        slpX=zeros(int32(nx+1),int32(ny+1));
        slpY=zeros(int32(nx+1),int32(ny+1));
        off=zeros(int32(nx+1),int32(ny+1));
        for xIdxL=0:int32(nx)
            xIdxR=xIdxL+1;
            for yIdxL=0:int32(ny)
                yIdxR=yIdxL+1;
                [slpX(xIdxR,yIdxR),slpY(xIdxR,yIdxR),off(xIdxR,yIdxR)]=...
                utilSlopeOffset(mode,nx,ny,xIdxL,xIdxR,yIdxL,yIdxR,x,y,table);
            end
        end
    end
end
function[slpX,slpY,off]=utilSlopeOffset(mode,nx,ny,xIdxL,xIdxR,yIdxL,yIdxR,x,y,table)

    assert(mode==0||mode==1,getString(message('Sldv:sldv:EmlAuthoring:FailRecogTableType')));

    if mode==0
        zLeftLeft=table(xIdxL+(yIdxL-1)*int32(nx));
        zLeftRght=table(xIdxL+(yIdxR-1)*int32(nx));
        zRghtLeft=table(xIdxR+(yIdxL-1)*int32(nx));
        zRghtRght=table(xIdxR+(yIdxR-1)*int32(nx));
        xL=x(xIdxL);
        xR=x(xIdxR);
        yL=y(yIdxL);
        yR=y(yIdxR);
    else
        if xIdxL==0&&yIdxL==0
            zLeftLeft=table(xIdxL+1);
            zLeftRght=zLeftLeft;
            zRghtLeft=zLeftLeft;
            zRghtRght=zLeftLeft;
            xL=x(xIdxL+1);
            xR=xL;
            yL=y(yIdxL+1);
            yR=yL;
        elseif xIdxL>0&&xIdxL<nx&&yIdxL==0
            zLeftLeft=table(xIdxL);
            zLeftRght=zLeftLeft;
            zRghtLeft=table(xIdxR);
            zRghtRght=zRghtLeft;
            xL=x(xIdxL);
            xR=x(xIdxR);
            yL=y(yIdxL+1);
            yR=yL;
        elseif xIdxL==0&&yIdxL>0&&yIdxL<ny
            zLeftLeft=table(xIdxL+1+(yIdxL-1)*int32(nx));
            zLeftRght=table(xIdxL+1+(yIdxR-1)*int32(nx));
            zRghtLeft=zLeftLeft;
            zRghtRght=zLeftRght;
            xL=x(xIdxL+1);
            xR=xL;
            yL=y(yIdxL);
            yR=y(yIdxR);
        elseif xIdxL==0&&yIdxL==ny
            zLeftLeft=table(xIdxL+1+(yIdxL-1)*int32(nx));
            zLeftRght=zLeftLeft;
            zRghtLeft=zLeftLeft;
            zRghtRght=zLeftLeft;
            xL=x(xIdxL+1);
            xR=xL;
            yL=y(yIdxL);
            yR=yL;
        elseif xIdxL>0&&xIdxL<nx&&yIdxL==ny
            zLeftLeft=table(xIdxL+(yIdxL-1)*int32(nx));
            zLeftRght=zLeftLeft;
            zRghtLeft=table(xIdxR+(yIdxL-1)*int32(nx));
            zRghtRght=zRghtLeft;
            xL=x(xIdxL);
            xR=x(xIdxR);
            yL=y(yIdxL);
            yR=yL;
        elseif xIdxL==nx&&yIdxL==ny
            zLeftLeft=table(xIdxL+(yIdxL-1)*int32(nx));
            zLeftRght=zLeftLeft;
            zRghtLeft=zLeftLeft;
            zRghtRght=zLeftLeft;
            xL=x(xIdxL);
            xR=xL;
            yL=y(yIdxL);
            yR=yL;
        elseif xIdxL==nx&&yIdxL>0&&yIdxL<ny
            zLeftLeft=table(xIdxL+(yIdxL-1)*int32(nx));
            zLeftRght=table(xIdxL+(yIdxR-1)*int32(nx));
            zRghtLeft=zLeftLeft;
            zRghtRght=zLeftRght;
            xL=x(xIdxL);
            xR=xL;
            yL=y(yIdxL);
            yR=y(yIdxR);
        elseif xIdxL==nx&&yIdxL==0
            zLeftRght=table(xIdxL+(yIdxL+1-1)*int32(nx));
            zLeftLeft=zLeftRght;
            zRghtRght=zLeftRght;
            zRghtLeft=zLeftRght;
            xL=x(xIdxL);
            xR=xL;
            yL=y(yIdxL+1);
            yR=yL;
        else
            zLeftLeft=table(xIdxL+(yIdxL-1)*int32(nx));
            zLeftRght=table(xIdxL+(yIdxR-1)*int32(nx));
            zRghtLeft=table(xIdxR+(yIdxL-1)*int32(nx));
            zRghtRght=table(xIdxR+(yIdxR-1)*int32(nx));
            xL=x(xIdxL);
            xR=x(xIdxR);
            yL=y(yIdxL);
            yR=y(yIdxR);
        end
    end

    xmean=(xL+xR)/2;
    ymean=(yL+yR)/2;
    zmean=(zLeftLeft+zLeftRght+zRghtLeft+zRghtRght)/4;

    if(xL==xR)&&(yR==yL)
        slpX=0;
        slpY=0;
    elseif(xL~=xR)&&(yR==yL)
        slpY=0;
        slpX=utilDiv((zRghtRght+zRghtLeft-zLeftRght-zLeftLeft),(2*(xR-xL)));
    elseif(xL==xR)&&(yR~=yL)
        slpX=0;
        slpY=utilDiv((zRghtRght+zLeftRght-zRghtLeft-zLeftLeft),(2*(yR-yL)));
    else
        slpX=utilDiv((zRghtRght+zRghtLeft-zLeftRght-zLeftLeft),(2*(xR-xL)));
        slpY=utilDiv((zRghtRght+zLeftRght-zRghtLeft-zLeftLeft),(2*(yR-yL)));
    end

    off=zmean-(slpX)*xmean-(slpY)*ymean;
end
function out=utilDiv(n,d)
    if d==0
        dtemp=1;
    else
        dtemp=d;
    end
    out=n/dtemp;
end
