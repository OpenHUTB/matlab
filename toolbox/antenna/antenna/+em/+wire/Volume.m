classdef Volume<handle



    properties
Surfaces
ColorsMap
Colors
    end

    properties(Dependent,Hidden)
Bounds
    end

    methods
        function out=clone(obj)
            out=em.wire.Volume;
            out.Surfaces=obj.Surfaces;
            out.ColorsMap=obj.ColorsMap;
            out.Colors=obj.Colors;
        end

        function set.Colors(obj,val)
            validateattributes(val,{'numeric'},{'nonempty','finite',...
            'real','nonnan'})
            obj.Colors=val;
        end

        function bounds=get.Bounds(obj)
            bounds=[...
            min(obj.Surfaces{1}.Vertices,[],1);
            max(obj.Surfaces{1}.Vertices,[],1)];
            for i=2:numel(obj.Surfaces)
                bounds=[...
                min(bounds(1,:),min(obj.Surfaces{i}.Vertices,[],1));
                max(bounds(2,:),max(obj.Surfaces{i}.Vertices,[],1))];
            end
        end

        function add(obj,val,clr,clrPrev)
            if nargin==3
                clrPrev=clr;
            end
            if isa(val,'em.wire.Surface')
                obj.Surfaces{end+1}=val;
                if isscalar(clr)

                    obj.ColorsMap{end+1}=[clrPrev*...
                    ones(1,size(val.Vertices,1)/2)...
                    ,clr*ones(1,size(val.Vertices,1)/2)];
                end
                obj.Colors(end+1,:)=clr;
            elseif isa(val,'em.wire.Volume')
                obj.Surfaces=[obj.Surfaces,val.Surfaces];
                obj.ColorsMap=[obj.ColorsMap,val.ColorsMap];
                obj.Colors=[obj.Colors;val.Colors];
            end
        end

        function obj=transform(obj,T)
            for i=1:numel(obj.Surfaces)
                obj.Surfaces{i}.Vertices=...
                transform(T,obj.Surfaces{i}.Vertices);
            end
        end

        function curv=trajectory(obj)
            n=numel(obj.Surfaces);
            pts=zeros(n+1,3);
            for i=1:n
                pts(i,:)=obj.Surfaces{i}.Vertices(1,:);
            end
            pts(n+1,:)=obj.Surfaces{n}.Vertices(2,:);
            curv=em.wire.Curve(pts);
        end

        function out=show(obj,dim,mult)
            if nargin<2||isempty(dim)
                dim=3;
            end
            if nargin<3
                mult=1;
            end


            p=[];
            if dim~=0
                for i=1:numel(obj.Surfaces)
                    if isempty(obj.ColorsMap)
                        morePatches=show(obj.Surfaces{i},...
                        obj.Colors(i,:),dim,[],mult);
                    else
                        morePatches=show(obj.Surfaces{i},...
                        obj.Colors(obj.ColorsMap{i}+1).',dim,[],mult);
                    end
                    p=[p,morePatches];%#ok<AGROW>
                end
            else
                Vertices=zeros(numel(obj.Surfaces)*2,3);
                for i=1:numel(obj.Surfaces)
                    Vertices(2*i-1,:)=obj.Surfaces{i}.Vertices(1,:)*mult;
                    Vertices(2*i,:)=obj.Surfaces{i}.Vertices(2,:)*mult;
                end
                Vertices=uniquetol(Vertices,'ByRows',true,'DataScale',...
                sqrt(eps(max(abs(Vertices),[],1))));
                p=line(Vertices(:,1),Vertices(:,2),Vertices(:,3));
                set(p,...
                'Color',[0.85,0.325,0.098],...
                'LineWidth',0.5,...
                'LineStyle','none',...
                'Marker','x',...
                'MarkerSize',4);
            end

            if isempty(findobj(gcf,'type','light'))


light
            end


            b=obj.Bounds*mult;
            db=b(2,:)-b(1,:);
            j=find(db==0);
            if~isempty(j)
                m=max(db);
                if m==0
                    m=1;
                end
                b(1,j)=-m/2;
                b(2,j)=m/2;
                axis(b(:)');
            else
                axis equal

            end

            if nargout
                out=p;
            end
        end
    end
end
