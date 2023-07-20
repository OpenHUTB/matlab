function[current,Points,hfig]=currentd(obj,freq,flag,scale,port_ex)
























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


    TetrahedraTotal=numel(obj.SolverStruct.strdiel.VolumeT);
    current=zeros(3,TetrahedraTotal);
    for m=1:TetrahedraTotal
        for n=1:obj.SolverStruct.strdiel.EdgesTNI(m)
            M=obj.SolverStruct.strdiel.EdgesTN(n,m);
            basis=obj.SolverStruct.strdiel.BasisTC(:,n,m);
            current(:,m)=current(:,m)+D(M)*basis/(obj.SolverStruct.const.Epsilon_r(m)...
            +1j*obj.SolverStruct.const.tan_delta(m));
        end
    end

    Points=obj.SolverStruct.strdiel.CenterT;

    if flag==0

        currentNorm=sqrt(sum(current.*conj(current)));
        [currentNorm1,~,U]=engunits(currentNorm);

        [clrbarHdl,axesHdl,hfig]=volumeplot(obj,currentNorm1,scale);
        if strcmpi(scale,'linear')
            ylabel(clrbarHdl,[U,'A/m']);
            title(axesHdl,'Current distribution');
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
    end

end