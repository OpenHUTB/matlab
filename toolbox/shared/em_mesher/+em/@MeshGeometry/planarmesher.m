function[varargout]=planarmesher(obj,varargin)




    if length(varargin)>7
        x=varargin{1};
        y=varargin{2};
        z=varargin{3};




        if isscalar(x)
            [P,Q]=meshgrid(y,z);

            r=x;
            order=[2,3,1];
        elseif isscalar(y)
            [P,Q]=meshgrid(x,z);

            r=y;
            order=[1,3,2];
        else
            [P,Q]=meshgrid(x,y);

            r=z;
            order=[1,2,3];
        end
        P=P(:);
        Q=Q(:);
        R=r.*ones(size(P));
        Dt=delaunayTriangulation(P,Q);
        p=Dt.Points;
        tmesh=Dt.ConnectivityList;
        pmesh(:,order(1))=p(:,1);
        pmesh(:,order(2))=p(:,2);
        pmesh(:,order(3))=R;
        if~isempty(varargin{8})
            smoothingoptions=varargin{8};
            numiterations=smoothingoptions{1};
            maxtriq=smoothingoptions{2};
            deltriq=smoothingoptions{3};
            [pmesh,tmesh]=em.MeshGeometry.smoothmesh(pmesh,...
            numiterations,maxtriq,deltriq,order);
        end
    else
        [pseed,order]=em.MeshGeometry.seedDomain(varargin{1},varargin{2});
        smoothingoptions=varargin{3};
        numiterations=smoothingoptions{1};
        maxtriq=smoothingoptions{2};
        deltriq=smoothingoptions{3};
        [pmesh,tmesh]=em.MeshGeometry.smoothmesh(pseed',...
        numiterations,maxtriq,deltriq,order);

    end
    varargout{1}=pmesh.';
    varargout{2}=tmesh.';
