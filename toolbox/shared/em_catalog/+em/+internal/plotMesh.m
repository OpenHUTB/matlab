function plotMesh(P,T,varargin)

    nameOfFunction='plotMesh';

    if size(P,2)==2
        P(:,3)=0;
    end

    if size(T,2)==3
        T(:,4)=0;
    end
    validateattributes(P,{'numeric'},{'ncols',3,'nonnan'},nameOfFunction,'Matrix of points, P',1);
    validateattributes(T,{'numeric'},{'ncols',4,'nonnan'},nameOfFunction,'Matrix of triangles/tetrahedra, T',2);
    if all(T(:,4)==0)
        fv.faces=T(:,1:3);
        fv.vertices=P;
        if nargin<3
            colorString='y';
        else
            colorString=validatestring(varargin{1},{'b','g','r','c','m','y','k','w'});
        end
        patch(fv,'FaceColor',colorString);
        axis equal;
        axis tight;
        grid on;
        hfig=gcf;
        ax=findobj(hfig,'type','axes');
        z=zoom;
        z.setAxes3DPanAndZoomStyle(ax,'camera');
        view(-40,30)
    else

        tetramesh(T,P,ones(size(T,1),1),'FaceAlpha',1);
        axis equal;
        axis tight;
    end