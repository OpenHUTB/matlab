function addsubstrate(obj,usebaseunits)




    if nargin==1
        usebaseunits=0;
    end

    if~isprop(obj,'Substrate')&&~isa(obj,'conformalArray')&&~isa(obj,'em.internal.authoring.customAntenna')
        return;
    end


    colGmax=0.7;
    colGmin=0.1;

    if iscell(obj.MesherStruct.Geometry)
        if~isfield(obj.MesherStruct.Geometry{1},'multiplier')||usebaseunits==1
            mul=1;
        else
            mul=obj.MesherStruct.Geometry{1}.multiplier;
        end
    else
        if~isfield(obj.MesherStruct.Geometry,'multiplier')||usebaseunits==1
            mul=1;
        else
            mul=obj.MesherStruct.Geometry.multiplier;
        end
    end
    if isa(obj,'em.internal.authoring.customAntenna')
        if strcmpi(obj.Shape.ShapeDimension,'3D')&&~isempty(obj.Shape.TetrahedraShape)
            FaceColor=makeFaceColorMatrix(obj.Shape.TetrahedraShape.Material.EpsilonR,colGmax,colGmin);
            makeSubstratePatchForGeometry(obj.MesherStruct.Geometry,...
            FaceColor,obj.Shape.TetrahedraShape.Material.EpsilonR,'mysub',mul);
            feedwidth=max(getFeedWidth(obj));
            resizeAxis([obj.MesherStruct.Geometry.BorderVertices;...
            obj.MesherStruct.Geometry.SubstrateVertices]*mul,feedwidth*mul);
            return;
        else
            return;
        end
    end
    if iscell(obj.MesherStruct.Geometry)
        geomverts=[];
        for i=1:numel(obj.MesherStruct.Geometry)
            if isSubstrate(obj.MesherStruct.Geometry{i})
                if isprop(obj,'Element')
                    if iscell(obj.Element)

                        if isa(obj.Element{i},'em.BackingStructure')&&...
                            isDielectricSubstrate(obj.Element{i}.Exciter)
                            epsr=obj.Element{i}.Exciter.Substrate.EpsilonR;
                            subname=obj.Element{i}.Exciter.Substrate.Name;
                        else
                            epsr=obj.Element{i}.Substrate.EpsilonR;
                            subname=obj.Element{i}.Substrate.Name;
                        end
                    else
                        if isscalar(obj.Element)
                            if isa(obj.Element,'em.BackingStructure')&&...
                                isDielectricSubstrate(obj.Element.Exciter)
                                epsr=obj.Element.Exciter.Substrate.EpsilonR;
                                subname=obj.Element.Exciter.Substrate.Name;
                            else

                                epsr=obj.Element.Substrate.EpsilonR;
                                subname=obj.Element.Substrate.Name;
                            end
                        else
                            if isa(obj.Element,'em.BackingStructure')&&...
                                isDielectricSubstrate(obj.Element(i).Exciter)
                                epsr=obj.Element(i).Exciter.Substrate.EpsilonR;
                                subname=obj.Element(i).Exciter.Substrate.Name;
                            else

                                epsr=obj.Element(i).Substrate.EpsilonR;
                                subname=obj.Element(i).Substrate.Name;
                            end
                        end
                    end
                else

                    epsr=obj.Substrate.EpsilonR;
                    subname=obj.Substrate.Name;
                end
            else


                epsr=1;
                subname='Air';
            end
            FaceColor=makeFaceColorMatrix(epsr,colGmax,colGmin);
            makeSubstratePatchForGeometry(obj.MesherStruct.Geometry{i},...
            FaceColor,epsr,subname,mul);
            geomverts=[geomverts;obj.MesherStruct.Geometry{i}.BorderVertices;...
            obj.MesherStruct.Geometry{i}.SubstrateVertices];
        end
        feedwidth=max(getFeedWidth(obj));
        resizeAxis(geomverts*mul,feedwidth*mul)
    else
        FaceColor=makeFaceColorMatrix(obj.Substrate.EpsilonR,colGmax,...
        colGmin);
        if isa(obj,'em.Array')&&(isa(obj.Element,'draRectangular')||isa(obj.Element,'draCylindrical')||...
            (isa(obj.Element,'monopoleTopHat')&&(any((obj.Element(1).Substrate.EpsilonR)~=1))))
            epsir=obj.Substrate.EpsilonR;
            name=obj.Substrate.Name;
            if isa(obj,'linearArray')||isa(obj,'circularArray')
                numiter=obj.NumElements;
            elseif isa(obj,'rectangularArray')
                numiter=obj.Size(1)*obj.Size(2);
            end
            FaceColor=makeFaceColorMatrix(obj.Element.Substrate.EpsilonR,colGmax,...
            colGmin);


            if numel(obj.Substrate.EpsilonR)>1
                fc=FaceColor;
                epsiir=epsir;

                for e=1:numiter-1
                    FaceColor(end+1:end+size(fc,1),:)=fc;
                    epsir(end+1:end+size(epsiir,2))=epsiir;
                    name=[name(:)',obj.Substrate.Name(:)'];
                end
            end
            makeSubstratePatchForGeometry(obj.MesherStruct.Geometry,...
            FaceColor,epsir,name,mul);

        elseif(isa(obj,'stripLine')||isa(obj,'coupledStripLine'))&&(numel(obj.Substrate.EpsilonR))==1
            epsR=obj.Substrate.EpsilonR;
            makeSubstratePatchForGeometry(obj.MesherStruct.Geometry,...
            [FaceColor;FaceColor],[epsR,epsR],{obj.Substrate.Name,...
            obj.Substrate.Name},mul);


        elseif isa(obj,'em.BackingStructure')&&isDielectricSubstrate(obj.Exciter)
            FaceColor=makeFaceColorMatrix(obj.Exciter.Substrate.EpsilonR,colGmax,...
            colGmin);
            makeSubstratePatchForGeometry(obj.MesherStruct.Geometry,...
            FaceColor,obj.Exciter.Substrate.EpsilonR,obj.Exciter.Substrate.Name,mul);


        elseif isa(obj,'em.Array')&&isa(obj.Element,'em.BackingStructure')&&...
            isDielectricSubstrate(obj.Element(1).Exciter)
            FaceColor=repmat(FaceColor,prod(obj.ArraySize),1);
            epsR=repmat(obj.Element(1).Exciter.Substrate.EpsilonR,[1,prod(obj.ArraySize)]);
            if iscell(obj.Element(1).Exciter.Substrate.Name)
                nameR=repmat(obj.Element(1).Exciter.Substrate.Name,[1,prod(obj.ArraySize)]);
            else
                nameR=obj.Element(1).Exciter.Substrate.Name;
            end
            makeSubstratePatchForGeometry(obj.MesherStruct.Geometry,...
            FaceColor,epsR,nameR,mul);

        else
            makeSubstratePatchForGeometry(obj.MesherStruct.Geometry,...
            FaceColor,obj.Substrate.EpsilonR,obj.Substrate.Name,mul);
        end


        feedwidth=max(getFeedWidth(obj));
        resizeAxis([obj.MesherStruct.Geometry.BorderVertices;...
        obj.MesherStruct.Geometry.SubstrateVertices]*mul,feedwidth*mul);
    end
end


function makeSubstratePatchForGeometry(geometry,facecolor,epsr,name,mul)

    if isSubstrate(geometry)


        if isscalar(epsr)
            epsr=epsr*ones(1,numel(geometry.SubstratePolygons));
        end
        if size(facecolor,1)==1
            facecolor=repmat(facecolor,numel(geometry.SubstratePolygons),1);
        end
        for m=1:numel(geometry.SubstratePolygons)
            if epsr(m)==1
                edgeC='none';
                facealpha=0;
            else
                edgeC='k';
                facealpha=0.8;
            end

            if isfield(geometry,'SubstrateBoundary')&&...
                ~isempty(geometry.SubstrateBoundary)
                patchinfo.Vertices=geometry.SubstrateVertices.*mul;
                patchinfo.Faces=geometry.SubstratePolygons{m};
                hpatch=patch(patchinfo,'FaceColor',facecolor(m,:),...
                'EdgeColor','none','FaceAlpha',facealpha);
                patchinfo.Faces=geometry.SubstrateBoundary{m};
                patchinfo.Vertices=geometry.SubstrateBoundaryVertices.*mul;
                hedge=patch(patchinfo,'FaceColor','none',...
                'EdgeColor',edgeC,'FaceOffsetFactor',0.01,'Tag','SubstrateBoundary');
                hAnnotation=get(hedge,'Annotation');
                hLegendEntry=get(hAnnotation','LegendInformation');
                set(hLegendEntry,'IconDisplayStyle','off');
            else
                patchinfo.Vertices=geometry.SubstrateVertices.*mul;
                patchinfo.Faces=geometry.SubstratePolygons{m};
                hpatch=patch(patchinfo,'FaceColor',facecolor(m,:),...
                'FaceAlpha',facealpha,'EdgeColor',edgeC,...
                'FaceOffsetFactor',0.01);
            end
            if iscell(name)
                if~strcmpi(name{m},'Air')
                    set(hpatch,'DisplayName',name{m},'Tag','substrate');
                else
                    if(epsr(m)~=1)
                        set(hpatch,'DisplayName',"dielectric"+num2str(m),'Tag','substrate');
                    else
                        hAnnotation=get(hpatch,'Annotation');
                        hLegendEntry=get(hAnnotation','LegendInformation');
                        set(hLegendEntry,'IconDisplayStyle','off');
                    end
                end
            else
                set(hpatch,'DisplayName',name,'Tag','substrate');
            end

        end
    end
end

function resizeAxis(p,feedwidth)
    if isempty(feedwidth)
        feedwidth=0;
    end
    marginRatio=10/100;
    minX=min(p(:,1));
    minY=min(p(:,2));
    minZ=min(p(:,3));
    maxX=max(p(:,1));
    maxY=max(p(:,2));
    maxZ=max(p(:,3));
    margins=marginRatio*[maxX-minX,maxY-minY,maxZ-minZ]+10^-5;
    if~any(size(feedwidth)>1)
        if any(margins<feedwidth)
            index=margins<feedwidth;
            margins(index)=1.5*feedwidth;
        end
    else
        if any(margins<feedwidth(1))
            index=margins<feedwidth(1);
            margins(index)=1.5*feedwidth(1);
        end
    end
    axis([minX-margins(1),maxX+margins(1)...
    ,minY-margins(2),maxY+margins(2),minZ-margins(3),maxZ+margins(3)]);

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
























function tf=isSubstrate(GeomStruct)
    tf=~isempty(GeomStruct.SubstrateVertices);
end
