function[isFixed,fixedVertices]=fixVertices(testVertices,shapeVertices,tol)



    isFixed=false;

    id=isnan(testVertices(:,1));
    testVertices(id,:)=[];

    fixedVertices=testVertices;

    for m=1:numel(testVertices(:,1))
        dx=abs(testVertices(m,1)-shapeVertices(:,1));
        idx=find(dx<tol);
        if~isempty(idx)
            isFixed=true;
            if numel(idx)>1
                [~,iddx]=min(dx(idx));
                idx=idx(iddx);
            end
            fixedVertices(m,1)=shapeVertices(idx,1);
        end
        dy=abs(testVertices(m,2)-shapeVertices(:,2));
        idy=find(dy<tol);
        if~isempty(idy)
            isFixed=true;
            if numel(idy)>1
                [~,iddy]=min(dy(idy));
                idy=idy(iddy);
            end
            fixedVertices(m,2)=shapeVertices(idy,2);
        end
    end