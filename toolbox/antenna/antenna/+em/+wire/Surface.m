classdef Surface<handle

    properties
Faces
Vertices
    end

    methods
        function obj=Surface(curv1,curv2)


            if nargin==1
                if isa(curv1,'em.wire.Curve')
                    obj.Vertices=real([curv1.X,curv1.Y,curv1.Z]);
                    obj.Faces=(1:numel(curv1.X));
                elseif isa(curv1,'em.wire.Surface')

                    obj.Vertices=curv1.Vertices;
                    obj.Faces=curv1.Faces;
                end
            elseif nargin>1
                obj.Vertices=real([...
                curv1.X,curv1.Y,curv1.Z;
                curv2.X,curv2.Y,curv2.Z]);
                nF=numel(curv1.X);
                if nF>2
                    c=(1:nF)';
                    obj.Faces=[c,rem(c,nF)+1,nF+rem(c,nF)+1,nF+c];
                elseif nF==2
                    obj.Faces=[1,2,4,3];
                elseif nF==1
                    obj.Faces=[1,2];
                end
            end
        end

        function p=show(obj,clr,dim,edgeColor,mult)
            if nargin<2||isempty(clr)
                clr='k';
            end
            if nargin<3||isempty(dim)
                dim=3;
            end
            if nargin<4||isempty(edgeColor)
                if dim==3
                    edgeColor='none';

                elseif dim==2
                    edgeColor='k';
                else
                    edgeColor=clr;
                end
            end
            if nargin<5
                mult=1;
            end
            if isrow(clr)
                p=patch(...
                'Faces',obj.Faces,...
                'Vertices',obj.Vertices*mult,...
                'FaceColor',clr,...
                'EdgeColor',edgeColor,...
                'AmbientStrength',0.5,...
                'FaceLighting','gouraud',...
                'DiffuseStrength',0.8,...
                'SpecularColorReflectance',0.6,...
                'SpecularStrength',0.7);
            else
                p=patch(...
                'Faces',obj.Faces,...
                'Vertices',obj.Vertices*mult,...
                'FaceColor','interp',...
                'CData',clr,...
                'EdgeColor',edgeColor,...
                'AmbientStrength',0.5,...
                'FaceLighting','gouraud',...
                'DiffuseStrength',0.8,...
                'SpecularColorReflectance',0.6,...
                'SpecularStrength',0.7);
            end
            if dim==1
                set(p,...
                'LineWidth',2,...
                'FaceColor','none',...
                'Marker','o',...
                'MarkerFaceColor','k',...
                'MarkerSize',4);
            end
        end
    end
end
