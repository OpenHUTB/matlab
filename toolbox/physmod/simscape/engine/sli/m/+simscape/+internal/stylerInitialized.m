function v=stylerInitialized(var)








    mlock;

    persistent pVal;


    if isempty(pVal)
        pVal=false;
    end

    if nargin==1
        pVal=var;
    end

    v=pVal;

end
