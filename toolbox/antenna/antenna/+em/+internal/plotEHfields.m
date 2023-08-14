function plotEHfields(E,H,Points,scale,viewflag,varargin)


    Xv=Points(1,:);
    Yv=Points(2,:);
    Zv=Points(3,:);
    Nsamples=size(Points,2);

    Emag=abs(E).*sign(angle(E));
    Hmag=abs(H).*sign(angle(H));


    Hmag_X=reshape(Hmag(1,:)',1,Nsamples);
    Hmag_Y=reshape(Hmag(2,:)',1,Nsamples);
    Hmag_Z=reshape(Hmag(3,:)',1,Nsamples);


    Emag_X=reshape(Emag(1,:)',1,Nsamples);
    Emag_Y=reshape(Emag(2,:)',1,Nsamples);
    Emag_Z=reshape(Emag(3,:)',1,Nsamples);

    if~isempty(get(groot,'CurrentFigure'))
        clf(gcf);
    end
    haxFieldLines=axes('Parent',gcf,'Position',[0.28,0.24,0.7,0.7]);
    if strcmpi(viewflag,'E')
        hE=quiver3(haxFieldLines,Xv,Yv,Zv,Emag_X,Emag_Y,Emag_Z,scale(1));%#ok<NASGU>
        title('Electric Field')
    elseif strcmpi(viewflag,'H')
        hH=quiver3(haxFieldLines,Xv,Yv,Zv,Hmag_X,Hmag_Y,Hmag_Z,scale(2));%#ok<NASGU>
        title('Magnetic Field')
    else
        hold on
        hE=quiver3(haxFieldLines,Xv,Yv,Zv,Emag_X,Emag_Y,Emag_Z,scale(1));%#ok<NASGU>
        hH=quiver3(haxFieldLines,Xv,Yv,Zv,Hmag_X,Hmag_Y,Hmag_Z,scale(2));%#ok<NASGU>
        hold off
        title('Electric (E) and Magnetic (H) Field')
        legend('E','H')
    end
    grid on
    if isempty(varargin)
        view(-45,30);
    else
        view(varargin{1}(1),varargin{1}(2));
    end
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    axis equal


end