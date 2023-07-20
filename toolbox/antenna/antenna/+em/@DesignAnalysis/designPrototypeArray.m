function designObj=designPrototypeArray(obj,freq,elementType,designElement)




    if isa(obj,'conformalArray')||isa(obj,'infiniteArray')
        designObj=designConfInf(obj,freq,elementType);
        return;
    end


    if designElement
        elem=design(elementType,freq);
    else
        elem=copy(elementType);
    end
    I=info(elementType);
    nominalSpacing=calculateNominalSpacing(elem,freq,I);
    designObj=copy(obj);
    switch class(obj)
    case 'linearArray'
        designObj.Element=elem;
        designObj.ElementSpacing=nominalSpacing;
    case 'rectangularArray'
        designObj.Element=elem;
        designObj.RowSpacing=nominalSpacing;
        designObj.ColumnSpacing=nominalSpacing;
    case 'circularArray'
        designObj.Element=elem;
        designObj.Radius=nominalSpacing;
    end


    ftest=freq/10;
    if ftest<1e3
        ftest=1e3;
    end
    lambda_test=physconst('lightspeed')/ftest;
    flag=true;
    mesherror=[];
    if isa(designObj.Element,'draRectangular')||isa(designObj.Element,'draCylindrical')
        d=designObj.Element.Substrate;
        designObj.Element.Substrate=d;

    else

        if strcmpi(I.HasSubstrate,"true")
            d=designObj.Element.Substrate;
            dtest=dielectric;
            designObj.Element.Substrate=dtest;
        end
    end
    while flag
        try
            [~]=mesh(designObj,'MaxEdgeLength',lambda_test);
            if isempty(mesherror)
                flag=false;
            end
        catch mesherror
            nominalSpacing=1.1*nominalSpacing;
            switch class(obj)
            case 'linearArray'
                designObj.ElementSpacing=nominalSpacing;
            case 'rectangularArray'
                designObj.RowSpacing=nominalSpacing;
                designObj.ColumnSpacing=nominalSpacing;
            case 'circularArray'
                designObj.Radius=nominalSpacing;
            end
            mesherror=[];
        end
    end

    if strcmpi(I.HasSubstrate,"true")
        designObj.Element.Substrate=d;
    end
    meshconfig(designObj,'auto');
    setHasStructureChanged(designObj);

    clearGeometryData(designObj);
    clearMeshData(designObj);
    clearSolutionData(designObj);

end

function designObj=designConfInf(obj,freq,elementType)
    designElement=true;
    if(isa(obj,'conformalArray'))
        ha=copy(obj);

        if~(numel(elementType)==1)
            singleElement=0;
            ha.ElementPosition=obj.ElementPosition;
            np=size(obj.ElementPosition,1);nel=numel(elementType);
            if(nel<=np)
                createElementPos=0;
                ha.ElementPosition=obj.ElementPosition(1:nel,:);
                ha.Element={elementType{1:size(ha.ElementPosition,1)}};
            else
                createElementPos=1;
                ha.ElementPosition=obj.ElementPosition(1:np,:);
                ha.Element=elementType(1:size(ha.ElementPosition,1));
                l=ha.getNextLocation(dipole);
                if(numel(l)==1&&l==-1)
                    ha.ElementPosition=[ha.ElementPosition;zeros(nel-np,3)];
                    createElementPos=0;
                end
            end

        else
            singleElement=1;
            createElementPos=0;
            ha.ElementPosition=obj.ElementPosition;
        end

    else
        ha=copy(obj);
    end
    elem=elementType;
    isDesign=designElement;

    if isa(obj,'conformalArray')
        if(isDesign)
            if(numel(elem)==1)
                if(any(strcmpi(class(elem),{'linearArray','rectangularArray','conformalArray'})))
                    ha.Element=design(elem,freq,elem.Element);
                else
                    ha.Element=design(elem,freq);
                end
            else

                elemarr={};
                for i=1:numel(elem)
                    if(any(strcmpi(class(elem{i}),{'linearArray','rectangularArray','conformalArray'})))
                        desEl=design(elem{i},freq,elem{i}.Element);
                    else
                        desEl=design(elem{i},freq);
                    end

                    if(i>size(ha.Element,1)&&createElementPos==1)
                        if(i>np)
                            tmp=ha.getNextLocation(desEl);
                            if(numel(tmp)==1&&tmp==-1)
                                createElementPos=0;
                                ha.ElementPosition=[ha.ElementPosition;[0,0,0]];
                            else
                                ha.ElementPosition=[ha.ElementPosition;tmp];
                            end
                        end
                        ha.Element{i}=desEl;

                    end
                    elemarr{i}=desEl;
                end
                if(size(ha.ElementPosition,1)~=numel(elemarr))
                    ha.ElementPosition=[ha.ElementPosition;zeros(numel(elemarr)-size(ha.ElementPosition,1),3)];
                    createElementPos=0;
                end
                ha.Element=elemarr;
            end
        else

            ha.Element=elem;
        end
        flag=true;
        mesherror=[];
        freq_test=freq/10;
        if(freq_test<1e3)
            freq_test=1e3;
        end
        lambda_test=physconst('lightspeed')/freq_test;
        iter=0;
        if numel(ha.Element)>1
            HasSubstrate=cell2mat(cellfun(@(x)isprop(x,'Substrate'),ha.Element,'UniformOutput',false));
        else
            HasSubstrate=isprop(ha.Element,'Substrate');
        end

        if any(HasSubstrate)
            ha.Reference='origin';
            idx=find(HasSubstrate);
            SubsElem=ha.Element(HasSubstrate);

            if iscell(SubsElem)
                SubstrateCell=cellfun(@(x)x.Substrate,SubsElem,'UniformOutput',false);
                for m=1:numel(idx)
                    if isa(ha.Element{idx(m)},'draRectangular')||...
                        isa(ha.Element{idx(m)},'draCylindrical')
                        cellfun(@(x)set(x,'Substrate',ha.Element{idx(m)}.Substrate),SubsElem(m),'UniformOutput',false);
                    else
                        cellfun(@(x)set(x,'Substrate',dielectric),SubsElem(m),'UniformOutput',false);
                    end
                end
            else
                SubstrateCell=SubsElem.Substrate;
                SubsElem.Substrate=dielectric;
            end

        end

        while(flag)
            iter=iter+1;
            if(iter==10)
                ha.adjustSpacing();
            end

            try
                [~]=mesh(ha,'MaxEdgeLength',lambda_test);
                if isempty(mesherror)
                    flag=false;
                end
            catch mesherror
                if(singleElement==1)
                    ha.ElementPosition=ha.ElementPosition*1.5;
                else
                    m=mean(ha.ElementPosition);
                    pt=ha.ElementPosition;
                    pt=(pt-m)*1.5;
                    ha.ElementPosition=pt+m;
                end
                mesherror=[];
            end
        end

        if(any(HasSubstrate))
            if iscell(SubsElem)
                for i=1:sum(HasSubstrate)
                    SubsElem{i}.Substrate=SubstrateCell{i};
                end
            else
                SubsElem.Substrate=SubstrateCell;
            end
        end
    else
        if isDesign
            ha.Element=design(elem,freq);
        else
            ha.Element=elem;
        end




























    end
    designObj=ha;
    meshconfig(designObj,'auto');
    setHasStructureChanged(designObj);

    clearGeometryData(designObj);
    clearMeshData(designObj);
    clearSolutionData(designObj);
end

function nominalSpacing=calculateNominalSpacing(elem,fc,I)

    createGeometry(elem);


    geom=getGeometry(elem);
    if~hasGnd(elem)||~hasExciter(elem)

        if iscell(geom)
            [~,dist]=dsearchn([0,0,0],geom{1}.BorderVertices);
            maxFeatureSize=max(dist);
        else
            [~,dist]=dsearchn([0,0,0],geom.BorderVertices);
            maxFeatureSize=max(dist);
        end
    else
        geom=getGeometry(elem.Exciter);

        [~,dist]=dsearchn([0,0,0],geom.BorderVertices);
        maxFeatureSize=max(dist);
    end




    lambda=physconst('lightspeed')/fc;
    if strcmpi(I.HasSubstrate,"true")
        eps_r=elem.Substrate.EpsilonR;
        lambda_g=lambda/sqrt(eps_r);
        nominalSpacing=lambda_g/2;
        if isa(elem,'draRectangular')
            nominalSpacing=1.5*lambda_g;
        elseif isa(elem,'draCylindrical')
            nominalSpacing=1.2*lambda_g;
        end
    else
        nominalSpacing=lambda/2;
    end

    if nominalSpacing<2*maxFeatureSize&&hasExciter(elem)
        nominalSpacing=1.01*(2*maxFeatureSize);
    end

end

function tf=hasGnd(obj)
    props=properties(obj);
    tf=any(contains(props,'Ground'));
end

function tf=hasExciter(obj)
    props=properties(obj);
    tf=any(contains(props,'Exciter'));
end
