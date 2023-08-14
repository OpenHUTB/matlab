function updatePeriodogramMatrix(obj,Pall,varargin)




    obj.pNumAvgsCounter=min(obj.pNumAvgsCounter+1,obj.SpectralAverages);
    obj.pNewPeriodogramIdx=max(1,mod(obj.pNewPeriodogramIdx+1,obj.SpectralAverages+1));



    if isempty(varargin)
        obj.pPeriodogramMatrix(:,obj.pNewPeriodogramIdx,:)=Pall;
    else
        i=varargin{1};
        obj.pPeriodogramMatrix(:,obj.pNewPeriodogramIdx,:)=Pall(:,i,:);
    end
