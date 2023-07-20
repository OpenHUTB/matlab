function atomicsubsystems=getAtomicSubsystems(~,hN)




    atomicsubsystems=hdlhtml.reportingWizard.generateSystemLink(hN.FullPath);
    numInstances=length(hN.instances);
    instances=hN.instances;
    for ii=1:numInstances
        subsystemName=[instances(ii).Owner.FullPath,'/',instances(ii).Name];
        if(~strcmp(hN.FullPath,subsystemName))
            atomicsubsystems=[atomicsubsystems,' &nbsp ',hdlhtml.reportingWizard.generateSystemLink(subsystemName)];
        end
    end
end
