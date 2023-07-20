function result=feature_RuntimeManagerUI()




    result=false;

    if slfeature('PosixStackDeployment')>0
        result=true;
    end
end


