function x=roundingHeuristic(xTest,intcon,A,b,Aeq,beq,lb,ub,ConstraintTolerance,IntegerTolerance)

    x=[];
    fractionalIntegersLogical=abs(round(xTest(intcon))-xTest(intcon))>IntegerTolerance;
    fractionalIntegers=intcon(fractionalIntegersLogical);

    if isempty(fractionalIntegers)
        x=xTest;
        return
    end

    upLocks=sum(A>0,1)+sum(abs(Aeq)>0,1);
    downLocks=sum(A<0,1)+sum(abs(Aeq)>0,1);
    numEqs=size(Aeq,1);

    while~isempty(fractionalIntegers)
        eqResiduals=Aeq*xTest-beq;
        ineqResiduals=A*xTest-b;
        if max([0;norm(eqResiduals,inf);ineqResiduals])>ConstraintTolerance
            xiMin=inf;jMin=inf;

            [~,i]=max([norm(eqResiduals,inf);ineqResiduals]);
            if i>numEqs
                a_i=A(i-numEqs,:);
            else
                a_i=Aeq(i,:);
            end
            for j=fractionalIntegers'
                if a_i(j)>0
                    xi_j=downLocks(j);
                    if xi_j<=xiMin
                        xiMin=xi_j;jMin=j;
                    end
                elseif a_i(j)<0
                    xi_j=upLocks(j);
                    if xi_j<=xiMin
                        xiMin=xi_j;jMin=j;
                    end
                end
            end
            if xiMin==inf
                return
            else
                if a_i(jMin)>0
                    xTest(jMin)=max(floor(xTest(jMin)),ceil(lb(jMin)));
                else
                    xTest(jMin)=min(ceil(xTest(jMin)),floor(ub(jMin)));
                end
                fractionalIntegers(fractionalIntegers==jMin)=[];
            end
        else
            xiMax=-1;jMin=inf;sigma=0;
            for j=fractionalIntegers'
                xi_j=upLocks(j);

                if xi_j>=xiMax
                    xiMax=xi_j;jMin=j;sigma=-1;
                end
                xi_j=downLocks(j);
                if xi_j>=xiMax
                    xiMax=xi_j;jMin=j;sigma=+1;
                end
            end
            if sigma==+1
                xTest(jMin)=min(ceil(xTest(jMin)),floor(ub(jMin)));
            else
                xTest(jMin)=max(floor(xTest(jMin)),ceil(lb(jMin)));
            end
            fractionalIntegers(fractionalIntegers==jMin)=[];
        end
    end

    if isFeasible(xTest,A,b,Aeq,beq,lb,ub,ConstraintTolerance)
        x=xTest;
    end


    function feasible=isFeasible(xTest,A,b,Aeq,beq,lb,ub,ConstraintTolerance)
        feasible=max([0;norm(Aeq*xTest-beq,inf);(lb-xTest);(xTest-ub);(A*xTest-b)])<=ConstraintTolerance;
