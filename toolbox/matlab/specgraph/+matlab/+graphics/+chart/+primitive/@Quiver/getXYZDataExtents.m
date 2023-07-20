function varargout=getXYZDataExtents(hObj,transform,~)







    if isempty(hObj.UData)||isempty(hObj.VData)
        varargout{1}=[0,0;0,0;0,0];
        return;
    end


    [x,y,z,u,v,w,msg]=hObj.preProcessData;


    nani=isfinite(x(:))&isfinite(y(:))&isfinite(z(:))&isfinite(u(:))&isfinite(v(:))&isfinite(w(:));
    x=x(nani);
    y=y(nani);
    z=z(nani);
    u=u(nani);
    v=v(nani);
    w=w(nani);

    if~isempty(msg)||isempty(x)||isempty(y)||isempty(u)||isempty(v)
        if~isempty(msg)
            warning(msg.identifier,msg.message);
        end
        varargout{1}=[];
        return
    end

    offset=hObj.getAlignmentOffset();

    is3D=hObj.is3D;



    if~isequal(transform,eye(4))
        vertices=transform*[x',y',z',ones(size(x'))]';
        x=vertices(1,:);
        y=vertices(2,:);
        z=vertices(3,:);

        vertices=transform*[u',v',w',ones(size(x'))]';
        u=vertices(1,:);
        v=vertices(2,:);
        w=vertices(3,:);



        if~(all(z==0)&&all(w==0))
            is3D=true;
        end
    end

    tailVData=calculateTailVertexData(hObj,is3D,x,y,z,u,v,w,offset);

    if strcmp(hObj.ShowArrowHead,'on')
        headVData=calculateHeadVertexData(hObj,is3D,x,y,z,u,v,w,offset);
        catVD=[tailVData;headVData];
    else
        catVD=tailVData;
    end

    xlim=matlab.graphics.chart.primitive.utilities.arraytolimits(catVD(:,1));
    ylim=matlab.graphics.chart.primitive.utilities.arraytolimits(catVD(:,2));
    zlim=matlab.graphics.chart.primitive.utilities.arraytolimits(catVD(:,3));
    varargout{1}=[xlim;ylim;zlim];
