function utilCalculateRs(obj)





    autoFlag=zeros(numel(obj.listOfSwitches),1);
    for i=1:numel(obj.listOfSwitches)
        if obj.listOfSwitches(i).Approx&&strcmp(obj.listOfSwitches(i).Rs,'auto')
            autoFlag(i)=autoType(obj.listOfSwitches(i));
        end
    end


    if any(autoFlag==1)
        modelName=obj.SimscapeModel;


        if strcmp(get_param(modelName,'LoggingToFile'),'on')
            set_param(modelName,'LoggingToFile','off');
            oc=onCleanup(@()set_param(modelName,'LoggingToFile','on'));
        end
        if strcmp(get_param(modelName,'ReturnWorkspaceOutputs'),'on')
            set_param(modelName,'ReturnWorkspaceOutputs','off');
            oc=onCleanup(@()set_param(modelName,'ReturnWorkspaceOutputs','on'));
        end
        if~strcmp(get_param(modelName,'SimscapeLogType'),'all')
            prevLogType=get_param(modelName,'SimscapeLogType');
            set_param(modelName,'SimscapeLogType','all')
            oc=onCleanup(@()set_param(modelName,'SimscapeLogType',prevLogType));
        end

        sim(modelName);

        for i=1:length(autoFlag)
            if autoFlag(i)==1
                switchName=splitFullName(obj.listOfSwitches(i).Name);
                switchName=join(switchName,'.');
                maxI=eval(strcat('max(abs(values(simlog.',switchName{1},'.i.series)))'));
                maxV=eval(strcat('max(abs(values(simlog.',switchName{1},'.v.series)))'));
                Rs=maxV/maxI;
                obj.listOfSwitches(i).Rs=num2str(Rs);
            end
        end
    end

    if any(autoFlag==2)
        obj.listOfSwitches(autoFlag==2).Rs=num2str(20000);
    end

end


function flag=autoType(obj)
    switch obj.Type
    case 'Diode'
        flag=1;
    case 'Switch'
        flag=1;
    case 'IGBT'
        flag=1;
    case 'Nonlinear Inductor'
        flag=2;
    otherwise
        flag=0;
    end
end

function nameList=splitFullName(name)

    subsystemName=name;
    nameList="";
    while get_param(subsystemName,'parent')
        oneUpName=get_param(subsystemName,'parent');
        localName=subsystemName(length(oneUpName)+2:end);
        nameList=[localName;nameList];
        subsystemName=oneUpName;
    end
    nameList=nameList(1:end-1);

end
