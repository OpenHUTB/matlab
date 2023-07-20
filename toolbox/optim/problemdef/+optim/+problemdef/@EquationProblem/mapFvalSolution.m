function fvalOut=mapFvalSolution(prob,fval)













    equations=prob.Equations;
    if isstruct(equations)

        eqnNames=fieldnames(equations);
        if~isempty(fval)

            eqOffset=1;
            for i=1:numel(eqnNames)

                eqnName=eqnNames{i};
                thisEqn=equations.(eqnName);
                if~isempty(thisEqn)
                    thisEqnSize=size(thisEqn);
                    m=numel(thisEqn);


                    fvalOut.(eqnName)=reshape(...
                    fval(eqOffset:eqOffset+m-1),thisEqnSize);
                    eqOffset=eqOffset+m;
                else
                    fvalOut.(eqnName)=[];
                end
            end
        else

            fvalOut=cell2struct(repmat({[]},numel(eqnNames),1),eqnNames,1);
        end
    elseif~isempty(equations)

        if~isempty(fval)
            fvalOut=reshape(fval,size(equations));
        else
            fvalOut=[];
        end
    else

        fvalOut=fval;
    end