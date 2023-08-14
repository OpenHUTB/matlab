function varargout=show(obj)


    nargoutchk(0,1);


    if strcmpi(obj.Shape,'box')
        makeBoxGeometry(obj);
    elseif strcmpi(obj.Shape,'cylinder')
        makeCylinderGeometry(obj);
    elseif strcmpi(obj.Shape,'polyhedron')
        makePolyhedronGeometry(obj);
    elseif strcmpi(obj.Shape,'sphere')
        makeSphereGeometry(obj);
    end

    if isequal(nargout,1)
        varargout{1}=obj.Geometry;
    else
        facecolor=makeFaceColorMatrix(obj.EpsilonR,0.7,0.1);
        makeSubstratePatchForGeometry(obj.Geometry,facecolor,obj.EpsilonR,obj.Name);

        if iscell(obj.Geometry)
            BorderVertices=cell2mat(cellfun(@(x)x.Vertices,...
            obj.Geometry','UniformOutput',false));
            X=BorderVertices(:,1);
            Y=BorderVertices(:,2);
            Z=BorderVertices(:,3);
        else
            X=obj.Geometry.Vertices(:,1);
            Y=obj.Geometry.Vertices(:,2);
            Z=obj.Geometry.Vertices(:,3);
        end
        em.MeshGeometry.decoratefigureandaxes(X,Y,Z);
        grid on
        box on
        legend('show')
        title('Dielectric material');
    end

end

function makeSubstratePatchForGeometry(geometry,facecolor,epsr,name)

    patchinfo.Vertices=geometry.Vertices;
    for m=1:numel(geometry.Polygons)
        if epsr(m)==1
            edgeC='none';
            facealpha=0;
        else
            edgeC='k';
            facealpha=0.8;
        end

        if isfield(geometry,'BoundaryEdges')
            patchinfo.Faces=geometry.BoundaryEdges{m};
            if epsr(m)~=1
                hpatch=patch(patchinfo,'FaceColor',facecolor(m,:),...
                'FaceAlpha',0,'EdgeColor','k');
                hAnnotation=get(hpatch,'Annotation');
                hLegendEntry=get(hAnnotation','LegendInformation');
                set(hLegendEntry,'IconDisplayStyle','off');
            end
            patchinfo.Faces=geometry.Polygons{m};
            hpatch=patch(patchinfo,'FaceColor',facecolor(m,:),...
            'FaceAlpha',facealpha,'EdgeColor','none');
        else
            patchinfo.Faces=geometry.Polygons{m};
            hpatch=patch(patchinfo,'FaceColor',facecolor(m,:),...
            'FaceAlpha',facealpha,'EdgeColor',edgeC);
        end


        if iscell(name)
            if~strcmpi(name{m},'Air')
                set(hpatch,'DisplayName',name{m});
            else
                hAnnotation=get(hpatch,'Annotation');
                hLegendEntry=get(hAnnotation','LegendInformation');
                set(hLegendEntry,'IconDisplayStyle','off');
            end
        else
            set(hpatch,'DisplayName',name);
        end
    end
end

function FaceColor=makeFaceColorMatrix(epsr,colGmax,colGmin)

    numColors=numel(unique(epsr));
    numLayers=numel(epsr);
    if numLayers>1
        deltaG=(colGmax-colGmin)/numColors;
        colors=(0:numColors-1)*deltaG;
        colors=colGmax-colors;
        if numColors~=numLayers
            [~,~,idx]=unique(epsr);
            colorval=colors(idx);
        else
            colorval=colors;
        end
        FaceColor=zeros(numLayers,3);
        FaceColor(:,1)=0.1;
        FaceColor(:,2)=colorval';
        FaceColor(:,3)=0.5;
    else
        FaceColor=[0.1,0.7,0.5];
    end
end
