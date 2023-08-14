function[PointSet,Frequencies]=SS_CreateSolutionPoints(NumberToCreate,lb,ub,options,Frequencies)













    nvars=length(lb);
    PointSet=zeros(NumberToCreate,nvars);
    range=ub-lb;

    switch lower(options.InitialSetMethod)
    case 'rand'
        PointSet=lb(ones(NumberToCreate,1),:)+range(ones(NumberToCreate,1),:).*rand(NumberToCreate,nvars);
    case 'stratrand'
        subRange=range./4;


        for SolutionIndex=1:NumberToCreate
            RecipFreqs=1./Frequencies;

            s=sum(RecipFreqs,2)*ones(1,4);

            RecipFreqs=RecipFreqs./s;


            ProbScores=cumsum(RecipFreqs,2);

            for var=1:nvars
                r=rand;
                if r<ProbScores(var,1)
                    PointSet(SolutionIndex,var)=lb(var)+subRange(var).*rand;
                    Frequencies(var,1)=Frequencies(var,1)+1;
                elseif r<ProbScores(var,2)
                    PointSet(SolutionIndex,var)=lb(var)+subRange(var).*(1+rand);
                    Frequencies(var,2)=Frequencies(var,2)+1;
                elseif r<ProbScores(var,3)
                    PointSet(SolutionIndex,var)=lb(var)+subRange(var).*(2+rand);
                    Frequencies(var,3)=Frequencies(var,3)+1;
                else
                    PointSet(SolutionIndex,var)=lb(var)+subRange(var).*(3+rand);
                    Frequencies(var,4)=Frequencies(var,4)+1;
                end
            end
        end
    end