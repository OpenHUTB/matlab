function[e1,e2]=testForEdgeVertices(pointset,testpoint)

    n=1:size(pointset,1);
    e1=[];
    e2=[];
    eSet=[];

    if numel(n)>1
        testSet=nchoosek(n,2);

        for i=1:size(testSet,1)
            C=[pointset(testSet(i,:),:);testpoint];
            if em.internal.isCollinear(C(1,:),C(2,:),C(3,:))
                eSet=[eSet,i];%#ok<AGROW>
            end
        end
    end
    if~isempty(eSet)
        Cset=testSet(eSet(1),:);
        e1=pointset(Cset(1),:);
        e2=pointset(Cset(2),:);
    end