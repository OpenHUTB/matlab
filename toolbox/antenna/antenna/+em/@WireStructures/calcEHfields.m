function[E,H]=calcEHfields(obj,freq,Points,...
    ~,hemispehere)

    if nargin==4
        hemispehere=0;
    end

    if hemispehere
        E=nan(size(Points));
        H=nan(size(Points));
        [~,indexRemove]=find(Points(3,:)<0);
        [~,indexKeep]=find(Points(3,:)>=0);
        Points(:,indexRemove)=[];
    end

    E1=obj.Medium.Es(Points.',freq).';
    H1=obj.Medium.Hs(Points.',freq).';

    if hemispehere
        E(:,indexKeep)=E1;
        H(:,indexKeep)=H1;
    else
        E=E1;
        H=H1;
    end
end