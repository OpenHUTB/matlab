function[FeedPower]=calcFeedpower(obj,freq)





    Index1=obj.SolverStruct.RWG.feededge;
    [~,idx]=intersect(obj.SolverStruct.Solution.Frequency,freq);
    I=obj.SolverStruct.Solution.I(:,idx);
    Current=I(Index1,:).'*obj.SolverStruct.RWG.EdgeLength(Index1)';
    Voltage=1.00;
    FeedPower=1/2*real(Voltage.*conj(Current));
end

