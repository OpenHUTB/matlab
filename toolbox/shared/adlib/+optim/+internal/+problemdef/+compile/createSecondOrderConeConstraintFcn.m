function probStruct=createSecondOrderConeConstraintFcn(probStruct)











    socConstraints=probStruct.socConstraints;
    probStruct.nonlcon=@(x)socConstraintsFcn(x,socConstraints);
    probStruct=rmfield(probStruct,'socConstraints');



    probStruct.constraintDerivative="closed-form";

    function[cineq,ceq,cgineq,cgeq]=socConstraintsFcn(x,soc)

        ceq=[];
        nCon=numel(soc);
        nVar=numel(x);
        cineq=zeros(nCon,1);
        for i=1:nCon
            cineq(i)=norm(soc(i).A*x(:)-soc(i).b)-soc(i).d'*x(:)+soc(i).gamma;
        end

        if nargout>2


            cgineq=zeros(nVar,nCon);










            for i=1:nCon
                t0=soc(i).A*x-soc(i).b;
                numerator=soc(i).A'*t0;
                denominator=sqrt(sum(t0.^2));
                gradNorm=numerator/denominator;
                cgineq(:,i)=gradNorm-soc(i).d;
            end


            cgeq=[];

        end

