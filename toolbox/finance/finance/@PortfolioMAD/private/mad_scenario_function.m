function y=mad_scenario_function(startindex,endindex,Y)




    N=size(Y,1);

    if isempty(startindex)||startindex<1
        startindex=1;
    end
    if isempty(endindex)||endindex>N
        endindex=N;
    end

    y=Y(startindex:endindex,:);
