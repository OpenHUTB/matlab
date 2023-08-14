function[Pmloss]=lumpedLoss(obj,freq,calc_emb_pattern,...
    ElemNumber)





    Pmloss=0;
    if~strcmpi(class(obj),'PlaneWaveExciation')||~strcmpi(class(obj),'InfiniteArray')
        [ZL,loadedge]=loadingedge(obj,1,freq,50,0,[]);
        if~isempty(loadedge)&&any(loadedge)>0
            Index1=loadedge;
            I1=zeros(length(Index1),1);
            Pmloss=zeros(length(Index1),1);
            [~,idx]=intersect(obj.SolverStruct.Solution.Frequency,freq);
            if getNumFeedLocations(obj)==1
                I=obj.SolverStruct.Solution.I(:,idx);
                for m=1:length(Index1)
                    index2=Index1(m);
                    I1(m)=I(index2)*obj.SolverStruct.RWG.EdgeLength(index2);
                    PL=I1(m)*(I1(m))';
                    Zs=ZL(m);
                    Pmloss(m)=0.5*real(Zs.*PL);
                end
            elseif getNumFeedLocations(obj)>1
                if calc_emb_pattern==0
                    I=obj.SolverStruct.Solution.I(:,idx);
                    for m=1:length(Index1)
                        index2=Index1(m);
                        I1(m)=I(index2)*obj.SolverStruct.RWG.EdgeLength(index2);
                        PL=I1(m)*(I1(m))';
                        Zs=ZL(m);
                        Pmloss(m)=0.5*real(Zs.*PL);
                    end
                else
                    I=obj.SolverStruct.Solution.embeddedI(:,ElemNumber);
                    for m=1:length(Index1)
                        index2=Index1(m);
                        I1(m)=I(index2)*obj.SolverStruct.RWG.EdgeLength(index2);
                        PL=I1(m)*(I1(m))';
                        Zs=ZL(m);
                        Pmloss(m)=0.5*real(Zs.*PL);
                    end
                end
            end
        end
    end
    Pmloss=abs(sum(Pmloss));
end

