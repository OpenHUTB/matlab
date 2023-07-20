function[xout,yout,zout]=checkOutOfRangeVertices(ds,~,xin,yin,zin,filterZ)

















    xout=xin;
    yout=yin;
    zout=zin;
    if(isprop(ds,'XScale')&&strcmp(ds.XScale,'log'))
        xlim=ds.XLim;
        if(max(xlim)>0)
            if~isfloat(xout)
                xout=double(xout);
            end
            xout(xout<=0)=nan;
        else
            if~isfloat(xout)
                xout=double(xout);
            end
            xout(xout>=0)=nan;
        end
    end
    if(isprop(ds,'YScale')&&strcmp(ds.YScale,'log'))
        ylim=ds.YLim;
        if(max(ylim)>0)
            if~isfloat(yout)
                yout=double(yout);
            end
            yout(yout<=0)=nan;
        else
            if~isfloat(yout)
                yout=double(yout);
            end
            yout(yout>=0)=nan;
        end
    end
    if(filterZ&&isprop(ds,'ZScale')&&strcmp(ds.ZScale,'log'))
        zlim=ds.ZLim;
        if(max(zlim)>0)
            if~isfloat(zout)
                zout=double(zout);
            end
            zout(zout<=0)=nan;
        else
            if~isfloat(zout)
                zout=double(zout);
            end
            zout(zout>=0)=nan;
        end
    end
end
