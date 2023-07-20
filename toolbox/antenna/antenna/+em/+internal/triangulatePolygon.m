function tri=triangulatePolygon(x,y,method)





































    x=x(:);
    y=y(:);






    n=isnan(x(:));


    x(n)=[];
    y(n)=[];


    constraints=buildConstraintsMatrix(n);



    w(4)=warning('off','MATLAB:delaunayTriangulation:DupPtsWarnId');
    w(3)=warning('off','MATLAB:delaunayTriangulation:ConsSplitPtWarnId');
    w(2)=warning('off','MATLAB:delaunayTriangulation:DupPtsConsUpdatedWarnId');
    w(1)=warning('off','MATLAB:delaunayTriangulation:ConsConsSplitWarnId');
    c=onCleanup(@()warning(w));
    tri=delaunayTriangulation(x,y,constraints);

    if(nargin>2)&&strcmp(method,'incenters')

        ic=incenter(tri);
        tri.Points(end+1:end+size(ic,1),:)=ic;
    end



    function c=buildConstraintsMatrix(n)












        m=numel(n);




        i1=(1:(m-1))';



        i2=(2:m)';















        c=[i1,i2];




























        t=cumsum(double(n));
        c=c-[t(i1),t(i2)];


























        c(n(i1)|n(i2),:)=[];
