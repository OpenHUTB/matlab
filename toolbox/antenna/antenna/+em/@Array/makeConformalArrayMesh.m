function[p_element,t_element,T_element,array_dielectric]=makeConformalArrayMesh(obj)

    if iscell(obj.Element)
        tempElement=makeTemporaryElementCacheForConformal(obj,size(obj.FeedLocation,1));
    else
        tempElement=makeTemporaryElementCacheForConformal(obj,size(obj.ElementPosition,1));
    end
    edgeLength=getMeshEdgeLength(obj);
    numelements=numel(tempElement);

    if iscell(obj.Reference)
        tempReference=obj.Reference;
    else
        tempReference=repmat({obj.Reference},1,numelements);
    end



    obj.MesherStruct.Mesh.ArrayParts.p={[]};
    obj.MesherStruct.Mesh.ArrayParts.t={[]};



    if isscalar(edgeLength)
        edgeLength=edgeLength.*ones(numelements,1);
    else

        if numel(edgeLength)<numelements
            error(message('antenna:antennaerrors:InsufficientMaxEdgeLengthSpecified'));
        end


        if numel(edgeLength)>numelements
            edgeLength=edgeLength(1:numelements);
            warning(message('antenna:antennaerrors:MaxEdgeLengthSpecifiedExceedsSizeOfElement'));
        end
    end

    for i=1:numel(tempElement)
        if isprop(tempElement{i},'Element')
            isaBackingStructureAntenna(i)=isa(tempElement{i}.Element,'em.BackingStructure');
        else
            isaBackingStructureAntenna(i)=isa(tempElement{i},'em.BackingStructure');
        end
    end
    isaParabolicReflector=cellfun(@(x)isa(x,'reflectorParabolic'),tempElement(:));


    if any(isaBackingStructureAntenna)
        isProbeFeedEnabled=cellfun(@(x)isprop(x,'EnableProbeFeed')&&isequal(x.('EnableProbeFeed'),1),tempElement);
        if any(isProbeFeedEnabled)
            isaBackingStructureAntenna(isProbeFeedEnabled)=~isaBackingStructureAntenna(isProbeFeedEnabled);
        end
    end
    minel=[];
    for i=1:numelements
        [~]=mesh(tempElement{i},'MaxEdgeLength',edgeLength(i));

        meshconfig(tempElement{i},'auto');
        minel=[minel,getMinContourEdgeLength(tempElement{i})];
    end

    setMeshMinContourEdgeLength(obj,minel);
    [p_temp,t_temp,T_temp]=cellfun(@getMesh,tempElement,'UniformOutput',false);



    domainReflector=111;
    idx=find(isaParabolicReflector);
    if any(isaParabolicReflector)
        for i=1:sum(double(isaParabolicReflector))
            currentDomainNum=t_temp{idx(i)}(4,:);
            replaceDomain=currentDomainNum==101;
            t_temp{idx(i)}(4,replaceDomain)=domainReflector;
        end
    end


    array_epsilonr=cellfun(@(x)x.MesherStruct.Mesh.('Eps_r'),tempElement,'UniformOutput',false);
    array_losstangent=cellfun(@(x)x.MesherStruct.Mesh.('tan_delta'),tempElement,'UniformOutput',false);
    array_dielectric.EpsilonR=cell2mat(array_epsilonr);
    array_dielectric.LossTangent=cell2mat(array_losstangent);


    infgndstatus=cellfun(@getInfGPState,tempElement);

    if any(any(isaBackingStructureAntenna))
        [p_element,t_element,T_element]=assembleArrayMeshWithBacking(obj,p_temp,...
        t_temp,...
        T_temp,...
        numelements,...
        tempElement,...
        tempReference,...
        isaBackingStructureAntenna,...
        infgndstatus);
    else
        [p_element,t_element,T_element]=assembleArrayMesh(obj,p_temp,t_temp,T_temp,numelements);
    end


    if any(any(infgndstatus))
        [p_image,t_image]=createArrayImage(obj,numelements,p_element,t_element);
        p_element=cell2mat(p_element');

        meshbelowxyplane=p_element(3,:)<=0;
        if any(meshbelowxyplane)
            error(message('antenna:antennaerrors:StructureBelowIGP'));
        end
        p_image=cell2mat(p_image');
        t_element=cell2mat(t_element');
        t_image=cell2mat(t_image');
        [p_element,t_element]=em.MeshGeometry.assembleMesh(...
        {p_element,p_image},{t_element,t_image});
        p_element={p_element};
        t_element={t_element};
    end

    if isempty(obj.MesherStruct.Mesh.ArrayParts.p{1})
        obj.MesherStruct.Mesh.ArrayParts.p=obj.MesherStruct.Mesh.ArrayParts.p(2:end);
        obj.MesherStruct.Mesh.ArrayParts.t=obj.MesherStruct.Mesh.ArrayParts.t(2:end);
    end

end

function[p,t,T]=assembleArrayMesh(obj,p_temp,t_temp,T_temp,numelements)
    p=cell(numelements,1);
    t=cell(numelements,1);
    T=cell(numelements,1);
    offset_index=zeros(numelements,1);
    p{1}=em.internal.translateshape(p_temp{1},obj.TranslationVector(1,:));
    offset_index(1)=size(p{1},2);
    t{1}=t_temp{1};
    T{1}=T_temp{1};
    obj.MesherStruct.Mesh.ArrayParts.p(1)=p(1);
    obj.MesherStruct.Mesh.ArrayParts.t=t_temp(:);
    for i=2:numelements
        p{i}=em.internal.translateshape(p_temp{i},obj.TranslationVector(i,:));
        offset_index(i)=offset_index(i-1)+size(p{i},2);


        obj.MesherStruct.Mesh.ArrayParts.p=[obj.MesherStruct.Mesh.ArrayParts.p;p(i)];
        t{i}(1:3,:)=t_temp{i}(1:3,:)+offset_index(i-1);
        t{i}(4,:)=t_temp{i}(4,:);
        T{i}=T_temp{i}+offset_index(i-1);
    end

end

function[p,t,T]=assembleArrayMeshWithBacking(obj,p_temp,t_temp,T_temp,numelements,elements,reference,isaBackingStructureAntenna,hasinfGP)
    p=cell(numelements,1);
    t=cell(numelements,1);
    T=cell(numelements,1);
    offset_index=zeros(numelements,1);
    t{1}=t_temp{1};
    backingflag=isaBackingStructureAntenna(1);
    zerogpflag=false;
    if backingflag
        [pbacking,~]=getPartMesh(elements{1},'Gnd');
        zerogpflag=isempty(cell2mat(pbacking));
    end
    if backingflag
        if isequal(elements{1}.Substrate.EpsilonR,ones(size(elements{1}.Substrate.EpsilonR)))
            [p{1},ttemp]=buildArrayPartsWithBacking(obj,elements{1},obj.TranslationVector(1,:),reference{1},hasinfGP(1),zerogpflag);
            if~isempty(ttemp)
                t{1}=ttemp;
            end
        else
            [~,~]=buildArrayPartsWithBacking(obj,elements{1},obj.TranslationVector(1,:),reference{1},hasinfGP(1),zerogpflag);
            p{1}=em.internal.translateshape(p_temp{1},obj.TranslationVector(1,:));
        end
    else
        p{1}=em.internal.translateshape(p_temp{1},obj.TranslationVector(1,:));
        obj.MesherStruct.Mesh.ArrayParts.p{1}=p{1};
        obj.MesherStruct.Mesh.ArrayParts.t{1}=t{1};
    end
    if backingflag&&isprop(elements{1},'Exciter')...
        &&isDielectricSubstrate(elements{1}.Exciter)

        T1=T_temp{1}-(min(min(T_temp{1}))-1);
        [pb,~]=getPartMesh(elements{1},'Gnd');
        T2=T1+size(pb{1},2);
        T{1}=T2;
    else
        T{1}=T_temp{1};
    end
    offset_index(1)=size(p{1},2);
    for i=2:numelements



        backingflag=isaBackingStructureAntenna(i);
        zerogpflag=false;
        if backingflag
            [pbacking,~]=getPartMesh(elements{i},'Gnd');
            zerogpflag=isempty(cell2mat(pbacking));
        end
        if backingflag
            if isequal(elements{i}.Substrate.EpsilonR,ones(size(elements{i}.Substrate.EpsilonR)))
                [p{i},ttemp]=buildArrayPartsWithBacking(obj,elements{i},obj.TranslationVector(i,:),reference{i},hasinfGP(i),zerogpflag);
                if~isempty(ttemp)
                    t_temp{i}=ttemp;
                end
            else
                [~,~]=buildArrayPartsWithBacking(obj,elements{i},obj.TranslationVector(i,:),reference{i},hasinfGP(i),zerogpflag);
                p{i}=em.internal.translateshape(p_temp{i},obj.TranslationVector(i,:));
            end
        else
            p{i}=em.internal.translateshape(p_temp{i},obj.TranslationVector(i,:));
            obj.MesherStruct.Mesh.ArrayParts.p=[obj.MesherStruct.Mesh.ArrayParts.p;p(i)];
            obj.MesherStruct.Mesh.ArrayParts.t=[obj.MesherStruct.Mesh.ArrayParts.t;t_temp(i)];
        end
        offset_index(i)=offset_index(i-1)+size(p{i},2);

        t{i}(1:3,:)=t_temp{i}(1:3,:)+offset_index(i-1);
        t{i}(4,:)=t_temp{i}(4,:);

        id=find(isaBackingStructureAntenna);
        isExciterSubstrate=zeros(size(isaBackingStructureAntenna));
        if~isempty(id)
            for m=1:numel(id)
                if isprop(elements{id(m)},'Element')
                    tempofTempElem{m}=elements{id(m)}.Element.Exciter;
                else
                    tempofTempElem{m}=elements{id(m)}.Exciter;
                end
            end

            s1=cellfun(@(x)isprop(x,'Substrate')&&...
            ~isequal(x.Substrate.('EpsilonR'),ones(size(x.Substrate.('EpsilonR')))),...
            tempofTempElem,'UniformOutput',false);
            s2=cell2mat(s1);
            for m=1:numel(id)
                if s2(m)==1
                    isExciterSubstrate(id(m))=true;
                end
            end
        end


        if backingflag&&isExciterSubstrate(i)
            T1=T_temp{i}-(min(min(T_temp{i}))-1);
            [pb,~]=getPartMesh(elements{i},'Gnd');
            T2=T1+size(pb{1},2)+offset_index(i-1);
            T{i}=T2;
        else
            T{i}=T_temp{i}+offset_index(i-1);
        end

    end
end

function[pbackingelement,tbackingelement]=buildArrayPartsWithBacking(obj,element,tvec,reference,hasinfGP,zerogpflag)
    if~hasinfGP&&~zerogpflag
        [pbacking,tbacking]=getPartMesh(element,'Gnd');
        pbacking=orientGeom(element,cell2mat(pbacking));
        [prad,trad]=getPartMesh(element,'Rad');
        prad=orientGeom(element,cell2mat(prad));

        if strcmpi(reference,'feed')
            prad=em.internal.translateshape(prad,tvec);
        else
            pbacking=em.internal.translateshape(pbacking,tvec);
            prad=em.internal.translateshape(prad,tvec);
        end
        [~,subOnElement]=isDielectricSubstrate(obj);
        if subOnElement&&(isDielectricSubstrate(element))
            pbackingelement=[pbacking,prad];
            tbackingelement=[];
        else
            [pbackingelement,tbackingelement]=em.MeshGeometry.assembleMesh({pbacking,prad},...
            {cell2mat(tbacking),cell2mat(trad)});
        end
        obj.MesherStruct.Mesh.ArrayParts.p=[obj.MesherStruct.Mesh.ArrayParts.p;{pbacking};{prad}];
        obj.MesherStruct.Mesh.ArrayParts.t=[obj.MesherStruct.Mesh.ArrayParts.t;tbacking;trad];
    elseif~hasinfGP&&zerogpflag
        [prad,trad]=getPartMesh(element,'Rad');
        prad=prad{1};
        trad=trad{1};
        prad=orientGeom(element,prad);









        prad=em.internal.translateshape(prad,tvec);
        pbackingelement=prad;
        tbackingelement=trad;
        obj.MesherStruct.Mesh.ArrayParts.p=[obj.MesherStruct.Mesh.ArrayParts.p;{prad}];
        obj.MesherStruct.Mesh.ArrayParts.t=[obj.MesherStruct.Mesh.ArrayParts.t;trad];
    else
        [pback,tback]=getPartMesh(element,'Rad');
        pbacking=pback{1};
        tbacking=tback{1};
        prad=pback{2};
        trad=tback{2};
        pbacking=orientGeom(element,pbacking);
        prad=orientGeom(element,prad);









        prad=em.internal.translateshape(prad,tvec);
        pbackingelement=prad;
        tbackingelement=trad;
        obj.MesherStruct.Mesh.ArrayParts.p=[obj.MesherStruct.Mesh.ArrayParts.p;{prad}];
        obj.MesherStruct.Mesh.ArrayParts.t=[obj.MesherStruct.Mesh.ArrayParts.t;trad];
    end


end

function[p_image,t_image]=createArrayImage(obj,N,p_element,t_element)

    p_image=p_element;
    t_image=t_element;
    for i=1:N
        p_image{i}=em.internal.translateshape(p_image{i},[0,0,-2*obj.FeedLocation(i,3)]);
    end

end
