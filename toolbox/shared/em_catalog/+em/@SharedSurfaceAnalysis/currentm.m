function[current,Points,hfig]=currentm(obj,frequency,flag,region,scale,...
    type,direction,port_ex)





















    if nargin==7
        port_ex=[];
    end

    hfig=[];
    if strcmpi(obj.SolverStruct.Source.type,'voltage')
        idx=find(obj.SolverStruct.Solution.Frequency==frequency,1);
        if~isempty(port_ex)

            if port_ex.NumPorts>1
                I=obj.SolverStruct.Solution.embeddedI;
            else
                I=obj.SolverStruct.Solution.I(:,idx);
            end

            port_wts=port_ex.FeedVoltage.*exp(1i*port_ex.FeedPhase*pi/180);
            port_wts=repmat(port_wts,size(I,1),1);
            I=sum(I.*port_wts,2);
        else
            I=obj.SolverStruct.Solution.I(:,idx);
        end
    elseif strcmpi(obj.SolverStruct.Source.type,'planewave')
        idx=find(obj.SolverStruct.Solution.Sfrequency==frequency,1);
        I=obj.SolverStruct.Solution.SI(:,idx);
    end

    CenterRho(:,1,:)=obj.SolverStruct.RWG.Center-...
    obj.MesherStruct.Mesh.p(:,obj.MesherStruct.Mesh.t(1,:));
    CenterRho(:,2,:)=obj.SolverStruct.RWG.Center-...
    obj.MesherStruct.Mesh.p(:,obj.MesherStruct.Mesh.t(2,:));
    CenterRho(:,3,:)=obj.SolverStruct.RWG.Center-...
    obj.MesherStruct.Mesh.p(:,obj.MesherStruct.Mesh.t(3,:));

    if isfield(obj.MesherStruct,'infGP')&&obj.MesherStruct.infGP&&...
        ~obj.SolverStruct.hasDielectric&&~strcmpi(obj.MesherStruct.Mesh.FeedType,'multiedge')
        if strcmpi(class(obj),'planeWaveExcitation')
            NumJoints=size(obj.Element.FeedLocation,1);
        else
            NumJoints=size(obj.FeedLocation,1);
        end
        if strcmpi(class(obj),'infiniteArray')&&obj.RemoveGround==1
            edgestotal=obj.SolverStruct.RWG.EdgesTotal;
            pointstotal=size(obj.MesherStruct.Mesh.p,2);
            trianglestotal=obj.SolverStruct.RWG.TrianglesTotal;
        elseif strcmpi(class(obj),'planeWaveExcitation')...
            &&strcmpi(class(obj.Element),'infiniteArray')...
            &&obj.Element.RemoveGround==1
            edgestotal=obj.SolverStruct.RWG.EdgesTotal;
            pointstotal=size(obj.MesherStruct.Mesh.p,2);
            trianglestotal=obj.SolverStruct.RWG.TrianglesTotal;
        else
            edgestotal=(obj.SolverStruct.RWG.EdgesTotal-NumJoints)/2;
            trianglestotal=obj.SolverStruct.RWG.TrianglesTotal/2;
            pointstotal=size(obj.MesherStruct.Mesh.p,2)/2;
        end

    else
        edgestotal=obj.SolverStruct.RWG.EdgesTotal;
        pointstotal=size(obj.MesherStruct.Mesh.p,2);
        trianglestotal=obj.SolverStruct.RWG.TrianglesTotal;
    end

    if isfield(obj.SolverStruct,'UseMcode')&&(obj.SolverStruct.UseMcode==1)
        offset=0;
    else
        offset=1;
    end

    current=zeros(3,trianglestotal);
    for m=1:edgestotal
        TP=obj.SolverStruct.RWG.TrianglePlus(m)+offset;
        TM=obj.SolverStruct.RWG.TriangleMinus(m)+offset;
        rhoP=+CenterRho(:,obj.SolverStruct.RWG.VerP(m)+offset,TP);
        rhoM=-CenterRho(:,obj.SolverStruct.RWG.VerM(m)+offset,TM);
        current(:,TP)=current(:,TP)+I(m)*rhoP*...
        obj.SolverStruct.RWG.EdgeLength(m)/(2*obj.SolverStruct.RWG.Area(TP));
        current(:,TM)=current(:,TM)+I(m)*rhoM*...
        obj.SolverStruct.RWG.EdgeLength(m)/(2*obj.SolverStruct.RWG.Area(TM));
    end

    if obj.MesherStruct.infGPconnected&&~obj.SolverStruct.hasDielectric&&...
        ~strcmpi(obj.MesherStruct.Mesh.FeedType,'multiedge')
        for m=edgestotal+1:edgestotal+NumJoints
            TP=obj.SolverStruct.RWG.TrianglePlus(m)+offset;
            rhoP=+CenterRho(:,obj.SolverStruct.RWG.VerP(m)+offset,TP);
            current(:,TP)=current(:,TP)+I(m)*rhoP*...
            obj.SolverStruct.RWG.EdgeLength(m)/(2*obj.SolverStruct.RWG.Area(TP));
        end
    end

    if isfield(obj.MesherStruct,'infGP')&&obj.MesherStruct.infGP&&...
        obj.SolverStruct.hasDielectric
        index=find(obj.SolverStruct.RWG.Center(3,:)>=0);
        Points=obj.SolverStruct.RWG.Center(:,index);
        if flag~=0
            current=current(:,index);
        end
    else
        Points=obj.SolverStruct.RWG.Center(:,1:trianglestotal);
    end

    if strcmpi(direction,'on')
        vectorindex=1;
    else
        vectorindex=0;
    end


    if strcmpi(type,'real')
        current=real(current);
    elseif strcmpi(type,'imaginary')
        current=imag(current);
    end

    if flag==0


        t=obj.MesherStruct.Mesh.t(:,1:trianglestotal);
        currentv=zeros(3,pointstotal);
        if~iscell(obj.MesherStruct.Mesh.FeedType)

            if all(t(4,:)==0)
                for m=1:pointstotal
                    [~,q]=find(t(1:3,:)-m==0);
                    if~isempty(q)
                        currentv(:,m)=sum(current(:,q),2)/length(q);
                    end
                end
            else


                idx=find(t(4,:)==0);
                t(4,idx)=max(t(4,:))+1;%#ok<FNDSB>
                if any(t(4,:)>6)
                    ind=t(4,:)>6;
                    t(4,ind)=6;
                end
                weight=[0.01,1,0.01,0.1,0.1,0.1];
                for m=1:pointstotal
                    [~,q]=find(t(1:3,:)-m==0);
                    if~isempty(q)
                        weights=weight(t(4,q));
                        currentv(1,m)=sum(current(1,q).*weights,2)/sum(weights);
                        currentv(2,m)=sum(current(2,q).*weights,2)/sum(weights);
                        currentv(3,m)=sum(current(3,q).*weights,2)/sum(weights);
                    end
                end
            end
        else
            for m=1:pointstotal
                [~,q]=find(t(1:3,:)-m==0);
                if~isempty(q)
                    currentv(:,m)=sum(current(:,q),2)/length(q);
                end
            end
        end
        if strcmpi(type,'absolute')
            currentNorm=sqrt(sum(currentv.*conj(currentv)));
        elseif strcmpi(type,'real')
            currentNorm=real(currentv);

        else
            currentNorm=imag(currentv);

        end
        [currentNorm1,~,U]=engunits((currentNorm));



        [clrbarHdl,axesHdl,hfig]=surfaceplot(obj,currentNorm1,region,scale,vectorindex,current);


        if strcmpi(scale,'linear')
            ylabel(clrbarHdl,[U,'A/m']);
            if strcmpi(type,'real')
                title(axesHdl,'Real current distribution');
            elseif strcmpi(type,'imaginary')
                title(axesHdl,'Imaginary current distribution');
            else
                title(axesHdl,'Current distribution');
            end
        elseif strcmpi(scale,'log')
            ylabel(clrbarHdl,['log(',U,'A/m)']);
            title(axesHdl,'Current distribution (log)');
        elseif strcmpi(scale,'log10')
            ylabel(clrbarHdl,['log10(',U,'A/m)']);
            title(axesHdl,'Current distribution (log10)');
        else
            ylabel(clrbarHdl,[char(scale),'(',U,'A/m)']);
            title(axesHdl,['Current distribution (',char(scale),')']);
        end
    else
        if any(strcmpi(obj.MesherStruct.Mesh.FeedType,'multiedge'))&&...
            isfield(obj.MesherStruct,'infGP')&&obj.MesherStruct.infGP
            idx=Points(3,:)<0;
            Points(:,idx)=[];
            current(:,idx)=[];
        end
    end

end



















