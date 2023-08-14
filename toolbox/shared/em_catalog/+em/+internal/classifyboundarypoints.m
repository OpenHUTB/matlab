function[p1,p2,p3,p4]=classifyboundarypoints(p)









    validateattributes(p,{'numeric'},{'nrows',3,'nonnan'},...
    'classifyboundarypoints','Matrix of points, p',1);


    idxBoundaryPts=convhull(p(1,:)',p(2,:)');
    boundary=p(:,idxBoundaryPts);
    xneg=min(p(1,:));
    xpos=max(p(1,:));
    yneg=min(p(2,:));
    ypos=max(p(2,:));

    tol=1e-5;
    p1=boundary(:,abs(boundary(1,:)-xneg)<tol)';
    p2=boundary(:,abs(boundary(2,:)-yneg)<tol)';
    p3=boundary(:,abs(boundary(1,:)-xpos)<tol)';
    p4=boundary(:,abs(boundary(2,:)-ypos)<tol)';
    p1=constructboundarypoints(p1,2);
    p2=constructboundarypoints(p2,1);
    p3=constructboundarypoints(p3,2);
    p4=constructboundarypoints(p4,1);
end

function p=constructboundarypoints(boundary,axisrow)
    p1_s=flipud(sortrows(boundary));
    p1_s=em.internal.antuniquetol(p1_s,1e-12);
    p=flipud(p1_s(:,axisrow));

end
