function savesolution(obj,I,frequency,addtermination,ElemNumber)




    if anynan(I)||any(isinf(I),"all")
        error(message('antenna:antennaerrors:InvalidAnswer'));
    end

    if isa(obj,'infiniteArray')
        if~isempty(obj.SolverStruct.Solution.ScanElevation)&&...
            ((obj.SolverStruct.Solution.ScanElevation==obj.ScanElevation)&&...
            (obj.SolverStruct.Solution.ScanAzimuth==obj.ScanAzimuth))
            obj.SolverStruct.Solution.Frequency=...
            [obj.SolverStruct.Solution.Frequency,frequency];
            obj.SolverStruct.Solution.I=...
            [obj.SolverStruct.Solution.I,1i*2*pi*frequency*I];
        else
            obj.SolverStruct.Solution.I=1i*2*pi*frequency*I;
            obj.SolverStruct.Solution.Frequency=frequency;
        end
        obj.SolverStruct.Solution.ScanElevation=obj.ScanElevation;
        obj.SolverStruct.Solution.ScanAzimuth=obj.ScanAzimuth;
    elseif isa(obj,'planeWaveExcitation')||strcmpi(obj.SolverStruct.Source.type,'planewave')
        idx=[];
        if~isempty(obj.SolverStruct.Solution.Sfrequency)
            idx=find(obj.SolverStruct.Solution.Sfrequency==frequency,1);
        end

        if isprop(obj,'SolverType')&&~strcmpi(obj.SolverType,'FMM')||...
            ~isprop(obj,'SolverType')
            omega_scaling=1i*2*pi*frequency;
        else
            omega_scaling=1;
        end
        if isempty(idx)
            obj.SolverStruct.Solution.Sfrequency=...
            [obj.SolverStruct.Solution.Sfrequency,frequency];
            obj.SolverStruct.Solution.SI=...
            [obj.SolverStruct.Solution.SI,omega_scaling*I];
        else
            obj.SolverStruct.Solution.SI(:,idx)=omega_scaling*I;
        end
    elseif getNumFeedLocations(obj)==1
        if getNumFeedLocations(obj)==1
            obj.SolverStruct.Solution.Frequency=...
            [obj.SolverStruct.Solution.Frequency,frequency];


            if isprop(obj,'SolverType')&&~strcmpi(obj.SolverType,'FMM')||...
                ~isprop(obj,'SolverType')
                I(1:obj.SolverStruct.RWG.EdgesTotal)=...
                1i*2*pi*frequency*I(1:obj.SolverStruct.RWG.EdgesTotal);
            end
            obj.SolverStruct.Solution.I=[obj.SolverStruct.Solution.I,I];
        else
            yparam=calcyparams(obj,I,frequency);
            obj.SolverStruct.Solution.YPFrequency=...
            [obj.SolverStruct.Solution.YPFrequency,frequency];
            obj.SolverStruct.Solution.yparam=...
            [obj.SolverStruct.Solution.yparam,yparam(:)];
        end
    elseif getNumFeedLocations(obj)>1&&addtermination==0

        obj.SolverStruct.Solution.Frequency=...
        [obj.SolverStruct.Solution.Frequency,frequency];


        if isprop(obj,'SolverType')&&~strcmpi(obj.SolverType,'FMM')||...
            ~isprop(obj,'SolverType')
            I(1:obj.SolverStruct.RWG.EdgesTotal,1)=...
            1i*2*pi*frequency*I(1:obj.SolverStruct.RWG.EdgesTotal,1);
            obj.SolverStruct.Solution.I=[obj.SolverStruct.Solution.I,I(:,1)];
            obj.SolverStruct.Solution.Iperport=cat(3,obj.SolverStruct.Solution.Iperport,1i*2*pi*frequency*I(:,2:end));

            yparam=calcyparams(obj,I(:,2:end),frequency);
            obj.SolverStruct.Solution.YPFrequency=...
            [obj.SolverStruct.Solution.YPFrequency,frequency];
            obj.SolverStruct.Solution.yparam=...
            [obj.SolverStruct.Solution.yparam,yparam(:)];
        else
            obj.SolverStruct.Solution.I=[obj.SolverStruct.Solution.I,I];


            if~isempty(ElemNumber)
                yparam=calcyparams(obj,I(:,2:end),frequency,false);
                obj.SolverStruct.Solution.YPFrequency=...
                [obj.SolverStruct.Solution.YPFrequency,frequency];
                obj.SolverStruct.Solution.yparam=...
                [obj.SolverStruct.Solution.yparam,yparam(:)];
            end
        end
    elseif getNumFeedLocations(obj)>1&&addtermination==1
        if isprop(obj,'SolverType')&&~strcmpi(obj.SolverType,'FMM')||...
            ~isprop(obj,'SolverType')


            I(1:obj.SolverStruct.RWG.EdgesTotal,:)=...
            1i*2*pi*frequency*I(1:obj.SolverStruct.RWG.EdgesTotal,:);
            obj.SolverStruct.Solution.embeddedI=I;
        else
            obj.SolverStruct.Solution.embeddedI=I;
        end
    end

    obj.SolverStruct.Solution.addtermination=addtermination;
end

function yparam=calcyparams(obj,I,frequency,isfreqmul)

    if nargin==3
        isfreqmul=true;
    end
    feededge=obj.SolverStruct.RWG.feededge;
    if isfreqmul
        mul=(1i*2*pi*frequency);
    else
        mul=1;
    end
    if size(feededge,1)==1
        edgemat=repmat(obj.SolverStruct.RWG.EdgeLength(feededge).'...
        ,[1,numel(feededge)]);
        yparam=I(feededge,:).*edgemat.*(mul);
    else
        yparam=zeros(getNumFeedLocations(obj),getNumFeedLocations(obj));
        for m=1:getNumFeedLocations(obj)
            index=find(feededge(:,m));
            edgemat=repmat(...
            obj.SolverStruct.RWG.EdgeLength(feededge(index,m)).',...
            [1,getNumFeedLocations(obj)]);
            if numel(index)>1
                yparam(m,:)=sum(I(feededge(index,m),:).*edgemat).*(mul);
            else
                yparam(m,:)=(I(feededge(index,m),:).*edgemat).*(mul);
            end
        end
    end
end


