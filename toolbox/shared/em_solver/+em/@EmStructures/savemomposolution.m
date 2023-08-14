function savemomposolution(obj,I,frequency,addtermination,ElemNumber)




    if anynan(I)||any(isinf(I),"all")
        error(message('antenna:antennaerrors:InvalidAnswer'));
    end

    if isa(obj,'planeWaveExcitation')||strcmpi(obj.SolverStruct.Source.type,'planewave')
        idx=[];
        if~isempty(obj.SolverStruct.Solution.Sfrequency)
            idx=find(obj.SolverStruct.Solution.Sfrequency==frequency,1);
        end
        if isempty(idx)
            obj.SolverStruct.Solution.Sfrequency=...
            [obj.SolverStruct.Solution.Sfrequency,frequency];
            obj.SolverStruct.Solution.SI=...
            [obj.SolverStruct.Solution.SI,1i*2*pi*frequency*I];
        else
            obj.SolverStruct.Solution.SI(:,idx)=1i*2*pi*frequency*I;
        end
    elseif getNumFeedLocations(obj)==1
        if getNumFeedLocations(obj)==1
            obj.SolverStruct.Solution.Frequency=...
            [obj.SolverStruct.Solution.Frequency,frequency];
            I(1:obj.SolverStruct.RWG.EdgesTotal)=...
            1i*2*pi*frequency*I(1:obj.SolverStruct.RWG.EdgesTotal);
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
        I(1:obj.SolverStruct.RWG.EdgesTotal,1)=...
        1i*2*pi*frequency*I(1:obj.SolverStruct.RWG.EdgesTotal,1);
        obj.SolverStruct.Solution.I=[obj.SolverStruct.Solution.I,I(:,1)];


        yparam=calcyparams(obj,I(:,2:end),frequency);
        obj.SolverStruct.Solution.YPFrequency=...
        [obj.SolverStruct.Solution.YPFrequency,frequency];
        obj.SolverStruct.Solution.yparam=...
        [obj.SolverStruct.Solution.yparam,yparam(:)];
    elseif getNumFeedLocations(obj)>1&&addtermination==1
        obj.SolverStruct.Solution.embeddedI=1i*2*pi*frequency*I;
    end

    obj.SolverStruct.Solution.addtermination=addtermination;

end

function yparam=calcyparams(obj,I,frequency)

    feededge=obj.SolverStruct.RWG.feededge;
    if size(feededge,1)==1
        edgemat=repmat(obj.SolverStruct.RWG.EdgeLength(feededge).'...
        ,[1,numel(feededge)]);
        yparam=I(feededge,:).*edgemat.*(1i*2*pi*frequency);
    else
        yparam=zeros(getNumFeedLocations(obj),getNumFeedLocations(obj));
        for m=1:getNumFeedLocations(obj)
            index=find(feededge(:,m));
            edgemat=repmat(...
            obj.SolverStruct.RWG.EdgeLength(feededge(index,m)).',...
            [1,getNumFeedLocations(obj)]);
            if numel(index)>1
                yparam(m,:)=sum(I(feededge(index,m),:).*edgemat).*...
                (1i*2*pi*frequency);
            else
                yparam(m,:)=(I(feededge(index,m),:).*edgemat).*...
                (1i*2*pi*frequency);
            end
        end
    end
end
