function[charge,Points,hfig]=chargem(obj,freq,flag,region,scale,port_ex)




















    if nargin==5
        port_ex=[];
    end

    hfig=[];
    if strcmpi(obj.SolverStruct.Source.type,'voltage')
        idx=find(obj.SolverStruct.Solution.Frequency==freq,1);
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
        idx=find(obj.SolverStruct.Solution.Sfrequency==freq,1);
        I=obj.SolverStruct.Solution.SI(:,idx);
    end

    if isfield(obj.MesherStruct,'infGP')&&obj.MesherStruct.infGP&&...
        ~obj.SolverStruct.hasDielectric&&~strcmpi(obj.MesherStruct.Mesh.FeedType,'multiedge')
        if strcmpi(class(obj),'planeWaveExcitation')
            NumJoints=size(obj.Element.FeedLocation,1);
        else
            NumJoints=size(obj.FeedLocation,1);
        end
        edgestotal=(obj.SolverStruct.RWG.EdgesTotal-NumJoints)/2;
        pointstotal=size(obj.MesherStruct.Mesh.p,2)/2;
        trianglestotal=obj.SolverStruct.RWG.TrianglesTotal/2;
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

    omega=2*pi*freq;
    charge=zeros(1,trianglestotal);

    for m=1:edgestotal
        IE=I(m)*obj.SolverStruct.RWG.EdgeLength(m);
        TP=obj.SolverStruct.RWG.TrianglePlus(m)+offset;
        TM=obj.SolverStruct.RWG.TriangleMinus(m)+offset;
        charge(TP)=charge(TP)+IE/(obj.SolverStruct.RWG.Area(TP));
        charge(TM)=charge(TM)-IE/(obj.SolverStruct.RWG.Area(TM));
    end

    if obj.MesherStruct.infGPconnected&&~obj.SolverStruct.hasDielectric&&...
        ~strcmpi(obj.MesherStruct.Mesh.FeedType,'multiedge')
        for m=edgestotal+1:edgestotal+NumJoints
            TP=obj.SolverStruct.RWG.TrianglePlus(m)+offset;
            charge(TP)=charge(TP)+IE/(obj.SolverStruct.RWG.Area(TP));
        end
    end
    charge=charge/(-1i*omega);

    if isfield(obj.MesherStruct,'infGP')&&obj.MesherStruct.infGP&&...
        obj.SolverStruct.hasDielectric
        index=find(obj.SolverStruct.RWG.Center(3,:)>=0);
        Points=obj.SolverStruct.RWG.Center(:,index);
        if flag~=0
            charge=charge(:,index);
        end
    else
        Points=obj.SolverStruct.RWG.Center(:,1:trianglestotal);
    end

    if flag==0


        t=obj.MesherStruct.Mesh.t(:,1:trianglestotal);
        chargev=zeros(1,pointstotal);

        if~iscell(obj.MesherStruct.Mesh.FeedType)

            if all(t(4,:)==0)
                for m=1:pointstotal
                    [~,q]=find(t(1:3,:)-m==0);
                    if~isempty(q)
                        chargev(m)=sum(charge(q),2)/length(q);
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
                        chargev(m)=sum(charge(q).*weights,2)/sum(weights);
                    end
                end
            end
        else
            for m=1:pointstotal
                [~,q]=find(t(1:3,:)-m==0);
                if~isempty(q)
                    chargev(m)=sum(charge(q),2)/length(q);
                end
            end
        end
        chargeabs1=sqrt(chargev.*conj(chargev));
        [chargeabs,~,U]=engunits(chargeabs1);

        [clrbarHdl,axesHdl,hfig]=surfaceplot(obj,chargeabs,region,scale,[],[]);

        if strcmpi(scale,'linear')
            ylabel(clrbarHdl,[U,'C/m']);
            title(axesHdl,'Charge distribution');
        elseif strcmpi(scale,'log')
            ylabel(clrbarHdl,['log(',U,'C/m)']);
            title(axesHdl,'Charge distribution (log)');
        elseif strcmpi(scale,'log10')
            ylabel(clrbarHdl,['log10(',U,'C/m)']);
            title(axesHdl,'Charge distribution (log10)');
        else
            ylabel(clrbarHdl,[char(scale),'(',U,'C/m)']);
            title(axesHdl,['Charge distribution (',char(scale),')']);
        end
    else
        if any(strcmpi(obj.MesherStruct.Mesh.FeedType,'multiedge'))&&...
            isfield(obj.MesherStruct,'infGP')&&obj.MesherStruct.infGP
            idx=Points(3,:)<0;
            Points(:,idx)=[];
            charge(:,idx)=[];
        end
    end

end









