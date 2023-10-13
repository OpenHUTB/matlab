function[p_element,t_element]=makeHeterogeneousArrayMesh(obj)

    edgeLength=getMeshEdgeLength(obj);
    growthRate=getMeshGrowthRate(obj);

    if isa(obj,'linearArray')||isa(obj,'circularArray')
        numelements=obj.NumElements;
    else
        numelements=prod(obj.Size);
    end



    obj.MesherStruct.Mesh.ArrayParts.p={[]};
    obj.MesherStruct.Mesh.ArrayParts.t={[]};


    if isa(obj,'linearArray')||isa(obj,'circularArray')


        if isscalar(edgeLength)
            edgeLength=edgeLength.*ones(obj.NumElements,1);
        else

            if numel(edgeLength)<obj.NumElements
                error(message('antenna:antennaerrors:InsufficientMaxEdgeLengthSpecified'));
            end


            if numel(edgeLength)>obj.NumElements
                edgeLength=edgeLength(1:obj.NumElements);
                warning(message('antenna:antennaerrors:MaxEdgeLengthSpecifiedExceedsSizeOfElement'));
            end
        end
    else


        if isscalar(edgeLength)
            edgeLength=edgeLength.*ones(obj.Size);
        else

            if numel(edgeLength)<prod(obj.Size)
                error(message('antenna:antennaerrors:InsufficientMaxEdgeLengthSpecified'));
            end


            if size(edgeLength,1)>obj.Size(1)&&size(edgeLength,2)>obj.Size(2)
                edgeLength=edgeLength(obj.Size(1),obj.Size(2));
                warning(message('antenna:antennaerrors:MaxEdgeLengthSpecifiedExceedsSizeOfElement'));
            end
        end
    end

    for i=1:numelements
        [~]=mesh(obj.Element(i),'MaxEdgeLength',edgeLength(i));

        meshconfig(obj.Element(i),'auto');
    end

    dynamicPropState=getDynamicPropertyState(obj);
    if dynamicPropState
        ZeroGPState=(isequal(obj.GroundPlaneLength,0))||...
        (isequal(obj.GroundPlaneWidth,0));

        if ZeroGPState
            dynamicPropState=~dynamicPropState;
        end
    end


    obj.MesherStruct.Mesh.ArrayParts.p={[]};
    obj.MesherStruct.Mesh.ArrayParts.t={[]};


    if dynamicPropState
        if~getInfGPState(obj)
            [pGP,tGP]=makeGroundPlaneMesh(obj,max(max(edgeLength)),max(max(growthRate)));

            obj.MesherStruct.Mesh.ArrayParts.p={pGP};
            obj.MesherStruct.Mesh.ArrayParts.t={tGP};

            numParts=obj.Element(1).MesherStruct.Mesh.PartMesh.NumParts;
        end
        if isfield(obj.Element(1).MesherStruct.Mesh.PartMesh,'GndConnectionDomain')&&...
            ~isempty(obj.Element(1).MesherStruct.Mesh.PartMesh.GndConnectionDomain)



            [pPart,tPart]=collapsePartMesh(obj);



            if~isequal(obj.Element(1).MesherStruct.Mesh.PartMesh.NumFeeds,0)&&isequal(numParts,3)
                [p_rad,t_rad]=assembleArrayMesh(obj,pPart(:,3)',tPart(:,3)',numelements);
            else
                [p_rad,t_rad]=assembleArrayMesh(obj,pPart(:,2)',tPart(:,2)',numelements);
            end

            p_rad=cell2mat(p_rad');
            t_rad=cell2mat(t_rad');


            obj.MesherStruct.Mesh.ArrayParts.p={pGP};
            obj.MesherStruct.Mesh.ArrayParts.t={tGP};


            p_temp=cell(1,numelements);
            t_temp=cell(1,numelements);
            for i=1:numel(obj.Element)
                for j=2:numParts
                    [p_temp{i},t_temp{i}]=em.internal.joinmesh(p_temp{i},t_temp{i},pPart{i,j},tPart{i,j});
                end
            end

            p_all=pGP;
            t_all=tGP;



            [p_element,t_element]=assembleArrayMesh(obj,p_temp,t_temp,numelements);
            p_element=cell2mat(p_element');
            t_element=cell2mat(t_element');
            [p_all,t_all]=em.internal.joinmesh(p_all,t_all,p_element,t_element);
            Parts=em.internal.makeMeshPartsStructure('Gnd',[{pGP},{tGP}],...
            'Rad',[{p_rad},{t_rad}]);
            savePartMesh(obj,Parts);
            p_element={p_all};
            t_element={t_all};
        else


            if~getInfGPState(obj)
                [p_temp,t_temp]=collapsePartMesh(obj);
                [p_element,t_element,T]=assembleArrayMesh(obj,p_temp(:,2)',t_temp(:,2)',numelements);
                p_element=cell2mat(p_element');
                t_element=cell2mat(t_element');
                Parts=em.internal.makeMeshPartsStructure('Gnd',[{pGP},{tGP}],...
                'Rad',[{p_element},{t_element}]);
                savePartMesh(obj,Parts);
                if isa(obj.Element,'monopoleCylindrical')
                    [p_element,t_element]=em.internal.joinmesh(p_element,t_element,pGP,tGP);
                else
                    if isa(obj.Element(1),'em.BackingStructure')&&isDielectricSubstrate(obj.Element(1).Exciter)



                        parray={p_element,pGP};
                        tarray={t_element,tGP};
                        t=tarray{1}(1:3,:);
                        tdomain=tarray{1}(4,:);
                        temp=tarray{2}(1:3,:)++size(p_element,2);
                        tempdomain=tarray{2}(4,:);
                        t=[t,temp];
                        tdomain=[tdomain,tempdomain];
                        t_element=[t;tdomain];
                        p_element=cell2mat(parray);

                        obj.MesherStruct.Mesh.T=[];
                        obj.MesherStruct.Mesh.Eps_r=[];
                        obj.MesherStruct.Mesh.tan_delta=[];

                        for i=1:prod(obj.ArraySize)
                            exmesh=obj.Element(i).Exciter.MesherStruct.Mesh;
                            obj.MesherStruct.Mesh.T=[obj.MesherStruct.Mesh.T,T{i}];
                            obj.MesherStruct.Mesh.Eps_r=[obj.MesherStruct.Mesh.Eps_r,exmesh.Eps_r];
                            obj.MesherStruct.Mesh.tan_delta=[obj.MesherStruct.Mesh.tan_delta,exmesh.tan_delta];
                        end
                    else
                        [p_element,t_element]=em.MeshGeometry.assembleMesh({p_element,pGP},{t_element,tGP});
                    end
                end
            else
                [p_temp,t_temp]=collapsePartMesh(obj);
                [p_element,t_element]=assembleArrayMesh(obj,p_temp(:,2)',t_temp(:,2)',numelements);
                p_element=cell2mat(p_element');
                t_element=cell2mat(t_element');
                if~obj.MesherStruct.infGPconnected
                    p_image=p_temp(:,1)';
                    t_image=t_temp(:,1)';
                    [p_image,t_image]=assembleArrayMesh(obj,p_image,...
                    t_image,numelements);
                    pimage=cell2mat(p_image');
                    timage=cell2mat(t_image');
                    [pfull_element,tfull_element]=em.MeshGeometry.assembleMesh(...
                    {p_element,pimage},{t_element,timage});
                else

                    Ctemp=1/3*(p_element(:,t_element(1,:))+...
                    p_element(:,t_element(2,:))+p_element(:,t_element(3,:)));
                    [~,index]=sort(-Ctemp(3,:));
                    t_element=t_element(:,index);


                    [pimage,timage]=createImage(obj,p_element,t_element);
                    [pfull_element,tfull_element]=em.MeshGeometry.assembleMesh(...
                    {p_element,pimage},{t_element,timage});
                end

                obj.MesherStruct.Mesh.ArrayParts.p(numelements+1:end)=[];
                obj.MesherStruct.Mesh.ArrayParts.t(numelements+1:end)=[];
                Parts=em.internal.makeMeshPartsStructure('Rad',[{pimage},{timage}],...
                'Rad',[{p_element},{t_element}]);
                savePartMesh(obj,Parts);
                p_element=pfull_element;
                t_element=tfull_element;
            end
            p_element={p_element};
            t_element={t_element};
        end
    else
        [p_temp,t_temp]=arrayfun(@getMesh,obj.Element,'UniformOutput',false);
        [p_element,t_element]=assembleArrayMesh(obj,p_temp,t_temp,numelements);

        if isa(obj.Element(1),'em.BackingStructure')&&isDielectricSubstrate(obj.Element(1).Exciter)



            T_temp=obj.Element(1).MesherStruct.Mesh.T;
            T{1}=T_temp;

            [~,nc]=cellfun(@size,p_temp);
            nc=reshape(nc,1,[]);
            x=cumsum(nc);

            offset_index=0;
            obj.MesherStruct.Mesh.T=[];
            obj.MesherStruct.Mesh.Eps_r=[];
            obj.MesherStruct.Mesh.tan_delta=[];





            for i=1:numelements
                exmesh=obj.Element(i).MesherStruct.Mesh;
                T{i}(1:4,:)=obj.Element(i).MesherStruct.Mesh.T+offset_index;
                obj.MesherStruct.Mesh.T=[obj.MesherStruct.Mesh.T,T{i}];
                obj.MesherStruct.Mesh.Eps_r=[obj.MesherStruct.Mesh.Eps_r,exmesh.Eps_r];
                obj.MesherStruct.Mesh.tan_delta=[obj.MesherStruct.Mesh.tan_delta,exmesh.tan_delta];
                offset_index=x(i);
            end
        end
    end
end

function[p,t,T]=assembleArrayMesh(obj,p_temp,t_temp,numelements)
    p=cell(numelements,1);
    t=cell(numelements,1);
    T=cell(numelements,1);

    if isa(obj.Element(1),'em.BackingStructure')&&isDielectricSubstrate(obj.Element(1).Exciter)
        exciterMesh=obj.Element(1).Exciter.MesherStruct.Mesh;
        T_temp=exciterMesh.T;
        T{1}=T_temp;
        p{1}=em.internal.translateshape(p_temp{1},obj.TranslationVector(1,:));
        t{1}=t_temp{1};
        obj.MesherStruct.Mesh.ArrayParts.p=[obj.MesherStruct.Mesh.ArrayParts.p;p(1)];
        obj.MesherStruct.Mesh.ArrayParts.t=[obj.MesherStruct.Mesh.ArrayParts.t;t_temp(:)];

        [~,nc]=cellfun(@size,p_temp);
        nc=reshape(nc,1,[]);
        x=cumsum(nc);


        for i=2:numelements
            p{i}=em.internal.translateshape(p_temp{i},obj.TranslationVector(i,:));
            offset_index=x(i-1);
            T{i}(1:4,:)=obj.Element(i).Exciter.MesherStruct.Mesh.T+offset_index;
            t{i}(1:3,:)=t_temp{i}(1:3,:)+offset_index;
            t{i}(4,:)=t_temp{i}(4,:);
            obj.MesherStruct.Mesh.ArrayParts.p=[obj.MesherStruct.Mesh.ArrayParts.p;p(i)];
        end
    else
        p{1}=em.internal.translateshape(p_temp{1},obj.TranslationVector(1,:));
        t{1}=t_temp{1};
        obj.MesherStruct.Mesh.ArrayParts.p=[obj.MesherStruct.Mesh.ArrayParts.p;p(1)];
        obj.MesherStruct.Mesh.ArrayParts.t=[obj.MesherStruct.Mesh.ArrayParts.t;t_temp(:)];
        for i=2:numelements
            p{i}=em.internal.translateshape(p_temp{i},obj.TranslationVector(i,:));
            offset_index=max(max(t{i-1}));


            obj.MesherStruct.Mesh.ArrayParts.p=[obj.MesherStruct.Mesh.ArrayParts.p;p(i)];
            t{i}(1:3,:)=t_temp{i}(1:3,:)+offset_index;
            t{i}(4,:)=t_temp{i}(4,:);
        end
    end
end
