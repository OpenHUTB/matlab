















function[vtxs,tris,isValid]=triangulateCrossSection_implementation(X,Y)

    try




        if~iscell(X)
            X={X};
        end

        if~iscell(Y)
            Y={Y};
        end


























































        p=polyshape(X,Y,'SolidBoundaryOrientation','auto',...
        'Simplify',false,...
        'KeepCollinearPoints',true);
        n=p.numboundaries();










        isValid=n>0;







        isValid=isValid&&p.issimplified();










        isValid=isValid&&~p.ishole(1)&&(n==1||all(p.ishole(2:n)));












        if~isValid
            ps=p.simplify('KeepCollinearPoints',true);
            if ps.numboundaries()==0
                p=polyshape(X{1},Y{1},'KeepCollinearPoints',true);
            else
                p=ps;
            end
        end





































        t=p.triangulation();




        vtxs=t.Points;
        tris=t.ConnectivityList;










        isValid=isValid&&size(rmmissing(p.Vertices),1)==size(t.Points,1);









        normals=t.faceNormal;

        assert(~any(normals(:,[1,2]),'all'),...
        'simscape:multibody:internal:IncorrectTriangulationNormals',...
        'Incorrect triangulation normals.');

        trisToFlip=normals(:,3)<0;
        tris(trisToFlip,[2,3])=tris(trisToFlip,[3,2]);







    catch caughtException




        ME=MException('simscape:multibody:internal:TriangulationProblem',...
        'A problem was encountered during triangulation.');
        ME=addCause(ME,caughtException);
        throw(ME);

    end

end
