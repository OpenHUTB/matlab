function[tfInAndOn,tfInAndNotOn,p_temp]=isLayerWithinBoardLimits(obj,p_temp)



    x_min=min(obj.BoardShape.ShapeVertices(:,1));
    y_min=min(obj.BoardShape.ShapeVertices(:,2));
    x_max=max(obj.BoardShape.ShapeVertices(:,1));
    y_max=max(obj.BoardShape.ShapeVertices(:,2));

    tfInAndOn=true;
    tfInAndNotOn=true;
    pcbRegion=[x_min,y_min;x_max,y_min;x_max,y_max;x_min,y_max];

    for i=1:numel(p_temp)
        x_temp=p_temp{i}(1,:);
        y_temp=p_temp{i}(2,:);
        [in,on]=inpolygon(x_temp,y_temp,obj.BoardShape.ShapeVertices(:,1),obj.BoardShape.ShapeVertices(:,2));


        idx_in=find(in==false);
        idx_on=find(on==true);
        if~isempty(idx_in)
            for j=1:numel(idx_in)
                iddx=find(abs(x_temp(idx_in(j))-pcbRegion(:,1))<sqrt(eps));
                if~isempty(iddx)
                    p_temp{i}(1,idx_in(j))=pcbRegion(iddx(1),1);
                    x_temp(idx_in(j))=pcbRegion(iddx(1),1);
                end
                iddy=find(abs(y_temp(idx_in(j))-pcbRegion(:,2))<sqrt(eps));
                if~isempty(iddy)
                    p_temp{i}(2,idx_in(j))=pcbRegion(iddy(1),2);
                    y_temp(idx_in(j))=pcbRegion(iddy(1),2);
                end
            end
            [in,on]=inpolygon(x_temp,y_temp,obj.BoardShape.ShapeVertices(:,1),obj.BoardShape.ShapeVertices(:,2));
        end


        tfInAndOn=tfInAndOn&&isempty(x_temp(~in))&&isempty(y_temp(~in));
        tfInAndNotOn=tfInAndNotOn&&(~isempty(x_temp(in&~on)))&&(~isempty(y_temp(in&~on)));
    end

end