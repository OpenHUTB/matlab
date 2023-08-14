function[p_element,t_element]=makeHomogeneousArrayMesh(obj)





    if isa(obj,'linearArray')||isa(obj,'circularArray')
        numelements=obj.NumElements;
    else
        numelements=prod(obj.Size);
    end

    edgeLength=getMeshEdgeLength(obj);
    if isempty(edgeLength)
        edgeLength=getMeshingLambda(obj)/10;
    end
    growthRate=getMeshGrowthRate(obj);

    if~isscalar(edgeLength)
        if any(edgeLength(2:end)-edgeLength(1)~=0)
            error(message('antenna:antennaerrors:MultipleMaxEdgeLengthSpecified'));
        elseif numel(edgeLength)>=numelements


            edgeLength=edgeLength(1);
            warning(message('antenna:antennaerrors:MaxEdgeLengthSpecifiedExceedsSizeOfElement'));
        end
    else
        edgeLength=edgeLength(1);
    end

    if~isscalar(growthRate)
        if any(growthRate(2:end)-growthRate(1)~=0)
            error(message('antenna:antennaerrors:MultipleGrowthRateSpecified'));
        else
            growthRate=growthRate(1);
        end
    end

    [~]=mesh(obj.Element,'MaxEdgeLength',edgeLength);
    dynamicPropState=getDynamicPropertyState(obj);


    obj.MesherStruct.Mesh.ArrayParts.p={[]};
    obj.MesherStruct.Mesh.ArrayParts.t={[]};
    if dynamicPropState
        ZeroGPState=(isequal(obj.GroundPlaneLength,0))||...
        (isequal(obj.GroundPlaneWidth,0));

        if ZeroGPState
            dynamicPropState=~dynamicPropState;
        end
    end

    if dynamicPropState
        if~getInfGPState(obj)
            [pGP,tGP]=makeGroundPlaneMesh(obj,edgeLength,growthRate);

            obj.MesherStruct.Mesh.ArrayParts.p={pGP};
            obj.MesherStruct.Mesh.ArrayParts.t={tGP};

            numParts=obj.Element.MesherStruct.Mesh.PartMesh.NumParts;
        end
        if isa(obj.Element,'em.HelixAntenna')&&isDielectricSubstrate(obj.Element)
            [pPart,tPart]=collapsePartMesh(obj);



            [p_base,t_base]=assembleArrayMesh(obj,pPart{1},tPart{1},numelements);
            p_base=cell2mat(p_base');
            t_base=cell2mat(t_base');

            p_temp=pPart{2};
            t_temp=tPart{2};


            Mi=em.internal.meshprinting.imprintMesh(p_base',t_base(1:3,:)',pGP',tGP(1:3,:)');
            numLayers=checkSubstrateThicknessVsLambda(obj.Substrate,obj.Element);
            Mi.NumLayers=numLayers;
            [feed_pt1,feed_pt2]=em.internal.findPortPoints(Mi.P,Mi.t,obj.DefaultFeedLocation);
            Mi.FeedVertex1=[feed_pt1];
            Mi.FeedVertex2=[feed_pt2];


            mt=[Mi.t,ones(size(Mi.t,1),1)];
            obj.MesherStruct.Mesh.ArrayParts.p={Mi.P'};
            obj.MesherStruct.Mesh.ArrayParts.t={mt'};



            [p_element,t_element,T]=assembleArrayMesh(obj,p_temp,t_temp,numelements);
            p_element=cell2mat(p_element');
            t_element=cell2mat(t_element');
            Mi.t(:,4)=0;
            id=max(max(t_element));
            [p_all,t_all]=em.internal.joinmesh(Mi.P',Mi.t',p_element(:,1:id),t_element);


            p_element=[p_all,p_element];
            for i=1:size(T,1)
                T{i}=size(p_all,2)+T{i};
            end
            t_element=t_all;
            exciterMesh=obj.Element.MesherStruct.Mesh;
            totalT=cell2mat(T');


            obj.MesherStruct.Mesh.T=totalT;
            obj.MesherStruct.Mesh.Eps_r=repmat(exciterMesh.Eps_r,[1,prod(obj.ArraySize)]);
            obj.MesherStruct.Mesh.tan_delta=repmat(exciterMesh.tan_delta,[1,prod(obj.ArraySize)]);

        elseif isfield(obj.Element.MesherStruct.Mesh.PartMesh,'GndConnectionDomain')&&...
            ~isempty(obj.Element.MesherStruct.Mesh.PartMesh.GndConnectionDomain)


            p_temp=[];
            t_temp=[];
            [pPart,tPart]=collapsePartMesh(obj);



            if~isequal(obj.Element.MesherStruct.Mesh.PartMesh.NumFeeds,0)&&isequal(numParts,3)
                [p_rad,t_rad]=assembleArrayMesh(obj,pPart{3},tPart{3},numelements);
            else
                [p_rad,t_rad]=assembleArrayMesh(obj,pPart{2},tPart{2},numelements);
            end
            p_rad=cell2mat(p_rad');
            t_rad=cell2mat(t_rad');


            obj.MesherStruct.Mesh.ArrayParts.p={pGP};
            obj.MesherStruct.Mesh.ArrayParts.t={tGP};


            for i=2:numParts
                [p_temp,t_temp]=em.internal.joinmesh(p_temp,t_temp,pPart{i},tPart{i});
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
                p_temp=obj.Element.MesherStruct.Mesh.PartMesh.Radiators.p{1};
                t_temp=obj.Element.MesherStruct.Mesh.PartMesh.Radiators.t{1};
                [p_element,t_element,T]=assembleArrayMesh(obj,p_temp,t_temp,numelements);
                p_element=cell2mat(p_element');
                t_element=cell2mat(t_element');
                Parts=em.internal.makeMeshPartsStructure('Gnd',[{pGP},{tGP}],...
                'Rad',[{p_element},{t_element}]);
                savePartMesh(obj,Parts);
                if isa(obj.Element,'monopoleCylindrical')
                    [p_element,t_element]=em.internal.joinmesh(p_element,t_element,pGP,tGP);
                else
                    if isa(obj.Element,'em.BackingStructure')&&isDielectricSubstrate(obj.Element.Exciter)



                        exciterMesh=obj.Element.Exciter.MesherStruct.Mesh;
                        parray={p_element,pGP};
                        tarray={t_element,tGP};
                        t=tarray{1}(1:3,:);
                        tdomain=tarray{1}(4,:);
                        temp=tarray{2}(1:3,:)+size(p_element,2);
                        tempdomain=tarray{2}(4,:);
                        t=[t,temp];
                        tdomain=[tdomain,tempdomain];
                        t_element=[t;tdomain];
                        p_element=cell2mat(parray);
                        totalT=cell2mat(T');


                        obj.MesherStruct.Mesh.T=totalT;
                        obj.MesherStruct.Mesh.Eps_r=repmat(exciterMesh.Eps_r,[1,prod(obj.ArraySize)]);
                        obj.MesherStruct.Mesh.tan_delta=repmat(exciterMesh.tan_delta,[1,prod(obj.ArraySize)]);
                    else
                        [p_element,t_element]=em.MeshGeometry.assembleMesh({p_element,pGP},{t_element,tGP});
                    end
                end
            else
                p_temp=obj.Element.MesherStruct.Mesh.PartMesh.Radiators.p{2};
                t_temp=obj.Element.MesherStruct.Mesh.PartMesh.Radiators.t{2};
                [p_element,t_element]=assembleArrayMesh(obj,p_temp,t_temp,numelements);
                p_element=cell2mat(p_element');
                t_element=cell2mat(t_element');




                if~obj.MesherStruct.infGPconnected
                    p_image=obj.Element.MesherStruct.Mesh.PartMesh.Radiators.p{1};
                    t_image=obj.Element.MesherStruct.Mesh.PartMesh.Radiators.t{1};
                    [p_image,t_image]=assembleArrayMesh(obj,p_image,...
                    t_image,numelements);
                    pimage=cell2mat(p_image');
                    timage=cell2mat(t_image');
                    [pfull_element,tfull_element]=em.MeshGeometry.assembleMesh(...
                    {p_element,pimage},{t_element,timage});
                elseif strcmpi(obj.MesherStruct.Mesh.FeedType,'multiedge')
                    [pimage,timage]=createImage(obj,p_element,t_element);
                    [pfull_element,tfull_element]=em.internal.joinmesh(...
                    p_element,t_element,pimage,timage);
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

        [p_temp,t_temp]=getMesh(obj.Element);

        [p_element,t_element,T]=assembleArrayMesh(obj,p_temp,t_temp,numelements);
        if isa(obj.Element,'dipoleHelix')&&isDielectricSubstrate(obj)
            p_element=cell2mat(p_element');
            t_element=cell2mat(t_element');
            exciterMesh=obj.Element.MesherStruct.Mesh;

            obj.MesherStruct.Mesh.T=cell2mat(T');
            obj.MesherStruct.Mesh.Eps_r=repmat(exciterMesh.Eps_r,[1,prod(obj.ArraySize)]);
            obj.MesherStruct.Mesh.tan_delta=repmat(exciterMesh.tan_delta,[1,prod(obj.ArraySize)]);
        end

        if isa(obj.Element,'em.BackingStructure')&&isDielectricSubstrate(obj.Element.Exciter)



            exciterMesh=obj.Element.Exciter.MesherStruct.Mesh;
            T_temp{1}=obj.Element.MesherStruct.Mesh.T;
            offset_index=max(size(p_temp));
            for i=2:numelements
                T_temp{i}(1:4,:)=T_temp{i-1}(1:4,:)+offset_index;%#ok<AGROW>
            end

            obj.MesherStruct.Mesh.T=cell2mat(T_temp);
            obj.MesherStruct.Mesh.Eps_r=repmat(exciterMesh.Eps_r,[1,numelements]);
            obj.MesherStruct.Mesh.tan_delta=repmat(exciterMesh.tan_delta,[1,numelements]);
        end
    end


    meshconfig(obj.Element,'auto');

end


function[p,t,T]=assembleArrayMesh(obj,p_temp,t_temp,numelements)
    p=cell(numelements,1);
    t=cell(numelements,1);
    T=cell(numelements,1);

    if isa(obj.Element,'em.BackingStructure')&&isDielectricSubstrate(obj.Element.Exciter)
        exciterMesh=obj.Element.Exciter.MesherStruct.Mesh;
        T_temp=exciterMesh.T;
        T{1}=T_temp;
        offset_index=max(size(p_temp));

        for i=2:numelements
            T{i}(1:4,:)=T{i-1}(1:4,:)+offset_index;
        end
    end

    if(isa(obj.Element,'helix')||isa(obj.Element,'dipoleHelix'))&&...
        isDielectricSubstrate(obj.Element)
        exciterMesh=obj.Element.MesherStruct.Mesh;
        T_temp1=exciterMesh.T;

        T_temp2=T_temp1-min(min(T_temp1))+1;
        if isa(obj.Element,'dipoleHelix')
            T{1}=T_temp1;
        else
            T{1}=T_temp2;
        end
        offset_index=max(size(p_temp));

        for i=2:numelements
            T{i}(1:4,:)=T{i-1}(1:4,:)+offset_index;
        end
    end

    p{1}=em.internal.translateshape(p_temp,obj.TranslationVector(1,:));
    t{1}=t_temp;

    obj.MesherStruct.Mesh.ArrayParts.p=[obj.MesherStruct.Mesh.ArrayParts.p;p(1)];
    obj.MesherStruct.Mesh.ArrayParts.t=[obj.MesherStruct.Mesh.ArrayParts.t;{t_temp}];

    offset_index=max(size(p_temp));
    for i=2:numelements
        if strcmpi(class(obj.Element),'dipoleCrossed')
            p{i}=em.internal.translateshape(p_temp,obj.TranslationVector(i*2,:));
            if i==2||i==4
                p{i}(:,1:end/2)=em.internal.translateshape(p_temp(:,1:end/2),obj.TranslationVector((i*2)-1,:));
            end
        elseif isprop(obj.Element,'Exciter')&&strcmpi(class(obj.Element.Exciter),'dipoleCrossed')
            p{i}=em.internal.translateshape(p_temp,obj.TranslationVector(i*2,:));
        else
            p{i}=em.internal.translateshape(p_temp,obj.TranslationVector(i,:));
        end


        obj.MesherStruct.Mesh.ArrayParts.p=[obj.MesherStruct.Mesh.ArrayParts.p;p(i)];
        obj.MesherStruct.Mesh.ArrayParts.t=[obj.MesherStruct.Mesh.ArrayParts.t;{t_temp}];
        t{i}(1:3,:)=t{i-1}(1:3,:)+offset_index;
        t{i}(4,:)=t{i-1}(4,:);
    end
end
