







function[P,t]=meshreduce(P_excessive,t_desired)

    referencedVertices=sort(unique(vertcat(t_desired(:,1),t_desired(:,2),t_desired(:,3))));
    P=P_excessive(referencedVertices,:);


    updatedVertices=1:size(P,1);



    t=t_desired;
    for j=1:length(referencedVertices)
        t(t==referencedVertices(j))=updatedVertices(j);
    end


    if 0
        figure;%#ok<UNRCH> 
        subplot(2,1,1);
        patch('Faces',t_desired,'Vertices',P_excessive,'FaceColor','c','EdgeColor','r');
        axis equal;
        title('Input mesh');
        subplot(2,1,2);
        patch('Faces',t,'Vertices',P,'FaceColor','c','EdgeColor','r');
        axis equal;
        title('Output mesh');
    end


end