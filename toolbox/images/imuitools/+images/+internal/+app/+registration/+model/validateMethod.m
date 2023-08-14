function TF=validateMethod()




    stack=dbstack;
    stackLen=length(stack);
    for i=1:stackLen
        if(strcmp(stack(i).name,'Session.createAlignmentsFromNames')||strcmp(stack(i).name,'Session.setUpRigidOperatorFromName')||strcmp(stack(i).name,'TestRunner.runTest'))
            TF=true;
            return;
        end
    end
    TF=false;
end