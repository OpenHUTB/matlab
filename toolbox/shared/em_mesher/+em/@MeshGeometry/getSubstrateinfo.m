function[epsr,subname]=getSubstrateinfo(obj)

    if~isprop(obj,'Substrate')&&~isa(obj,'conformalArray')&&~isprop(obj,'Phantom')&&~isa(obj,'em.internal.authoring.customAntenna')
        epsr=[];
        subname=[];
        return;
    end
    if isa(obj,'em.internal.authoring.customAntenna')
        epsr=obj.Shape.Material.EpsilonR;
        subname='mysub';
    end

    if iscell(obj.MesherStruct.Geometry)
        epsr=[];subname=[];
        for i=1:numel(obj.MesherStruct.Geometry)
            if isSubstrate(obj.MesherStruct.Geometry{i})
                if isprop(obj,'Element')
                    if iscell(obj.Element)
                        if isa(obj.Element{i},'em.BackingStructure')&&...
                            isDielectricSubstrate(obj.Element{i}.Exciter)
                            tepsr=obj.Element{i}.Exciter.Substrate.EpsilonR;
                            tsubname=obj.Element{i}.Exciter.Substrate.Name;
                        else
                            tepsr=obj.Element{i}.Substrate.EpsilonR;
                            tsubname=obj.Element{i}.Substrate.Name;
                        end
                    else
                        if isscalar(obj.Element)
                            if isa(obj.Element,'em.BackingStructure')&&...
                                isDielectricSubstrate(obj.Element.Exciter)
                                tepsr=obj.Element.Exciter.Substrate.EpsilonR;
                                tsubname=obj.Element.Exciter.Substrate.Name;
                            else

                                tepsr=obj.Element.Substrate.EpsilonR;
                                tsubname=obj.Element.Substrate.Name;
                            end
                        else
                            if isa(obj.Element,'em.BackingStructure')&&...
                                isDielectricSubstrate(obj.Element(i).Exciter)
                                tepsr=obj.Element(i).Exciter.Substrate.EpsilonR;
                                tsubname=obj.Element(i).Exciter.Substrate.Name;
                            else
                                tepsr=obj.Element(i).Substrate.EpsilonR;
                                tsubname=obj.Element(i).Substrate.Name;
                            end
                        end
                    end
                else
                    tepsr=obj.Substrate.EpsilonR;
                    tsubname=obj.Substrate.Name;
                end
            else
                tepsr=[];
                tsubname=[];
            end
            epsr=[epsr,tepsr];
            subname=[subname,tsubname];
        end
    else
        if isa(obj,'em.Array')&&(isa(obj.Element,'draRectangular')||...
            isa(obj.Element,'draCylindrical')||...
            (isa(obj.Element,'monopoleTopHat')&&...
            (any((obj.Element(1).Substrate.EpsilonR)~=1))))
            epsr=obj.Substrate.EpsilonR;
            subname=obj.Substrate.Name;
            if isa(obj,'linearArray')||isa(obj,'circularArray')
                numiter=obj.NumElements;
            elseif isa(obj,'rectangularArray')
                numiter=obj.Size(1)*obj.Size(2);
            end


            if numel(obj.Substrate.EpsilonR)>1
                temp=epsr;
                for e=1:numiter-1
                    epsr(end+1:end+size(temp,2))=temp;
                    subname=[subname(:)',obj.Substrate.Name(:)'];
                end
            end

        elseif(isa(obj,'stripLine')||isa(obj,'coupledStripLine'))&&...
            (numel(obj.Substrate.EpsilonR))==1
            epsr=obj.Substrate.EpsilonR;
            subname=obj.Substrate.Name;


        elseif isa(obj,'em.BackingStructure')&&isDielectricSubstrate(obj.Exciter)
            epsr=obj.Exciter.Substrate.EpsilonR;
            subname=obj.Exciter.Substrate.Name;


        elseif isa(obj,'em.Array')&&isa(obj.Element,'em.BackingStructure')&&...
            isDielectricSubstrate(obj.Element(1).Exciter)

            epsr=repmat(obj.Element(1).Exciter.Substrate.EpsilonR,[1,prod(obj.ArraySize)]);
            if iscell(obj.Element(1).Exciter.Substrate.Name)
                subname=repmat(obj.Element(1).Exciter.Substrate.Name,[1,prod(obj.ArraySize)]);
            else
                subname=obj.Element(1).Exciter.Substrate.Name;
            end
        else
            if isprop(obj,'Substrate')
                epsr=obj.Substrate.EpsilonR;
                subname=obj.Substrate.Name;
            else
                epsr=1;
                subname='Air';
            end
        end
    end

end

function tf=isSubstrate(GeomStruct)
    tf=~isempty(GeomStruct.SubstrateVertices);
end