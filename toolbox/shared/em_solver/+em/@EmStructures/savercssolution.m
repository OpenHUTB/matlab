function savercssolution(obj,I,frequency,phi,theta)





    idxfreq=[];
    idxangle=[];
    if~isempty(obj.SolverStruct.RCSSolution.Frequency)
        idxfreq=find(obj.SolverStruct.RCSSolution.Frequency==frequency,1);
    end
    if~isempty(obj.SolverStruct.RCSSolution.TxAngle)
        idxangle=find(obj.SolverStruct.RCSSolution.TxAngle==complex(phi,theta),1);
    end















    obj.SolverStruct.RCSSolution.I(:,1,:)=I;