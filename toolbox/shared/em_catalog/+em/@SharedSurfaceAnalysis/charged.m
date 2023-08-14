function[charge,Points,hfig]=charged(obj,freq,flag,scale,port_ex)






















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
        D=I(obj.SolverStruct.RWG.EdgesTotal+1:end);
    end

    charge=zeros(1,obj.SolverStruct.strdiel.FacesNontrivial);
    for n=1:obj.SolverStruct.strdiel.FacesNontrivial
        for c=1:obj.SolverStruct.strdiel.EdgesFNI(n)
            N=obj.SolverStruct.strdiel.EdgesFN(c,n);
            charge(n)=charge(n)+D(N)*...
            (obj.SolverStruct.strdiel.DiffContrast_real(c,n)+...
            1i*obj.SolverStruct.strdiel.DiffContrast_imag(c,n))/...
            obj.SolverStruct.strdiel.AreaF(n);
        end
    end
    Points=obj.SolverStruct.strdiel.CenterF(:,1:obj.SolverStruct.strdiel.FacesNontrivial);


    if flag==0

        chargev=zeros(1,length(obj.SolverStruct.strdiel.P));
        for m=1:size(obj.SolverStruct.strdiel.P,2)
            chargev(m)=0;
            [~,q]=find(obj.SolverStruct.strdiel.Faces(:,...
            1:obj.SolverStruct.strdiel.FacesNontrivial)-m==0);
            if~isempty(q)
                chargev(m)=sum(charge(:,q),2)/length(q);
            end
        end
        chargeabs1=sqrt(chargev.*conj(chargev));
        [chargeabs,~,U]=engunits(chargeabs1);

        [clrbarHdl,axesHdl,hfig]=surfaceplot(obj,chargeabs,'dielectric',scale,[],[]);

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
    end

end