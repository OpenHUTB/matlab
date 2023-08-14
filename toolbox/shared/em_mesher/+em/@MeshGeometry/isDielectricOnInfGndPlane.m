function tf=isDielectricOnInfGndPlane(epsilonr,propVal)
    tf=false;
    if~isempty(propVal)
        if~isequal(epsilonr,1)&&isinf(propVal)
            tf=true;
        end
    end
























