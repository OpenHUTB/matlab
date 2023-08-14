function id=getNewInstanceId





    persistent instanceCtr;

    if isempty(instanceCtr)
        instanceCtr=0;
    else
        instanceCtr=instanceCtr+1;
    end


    id=['#',num2str(instanceCtr)];



