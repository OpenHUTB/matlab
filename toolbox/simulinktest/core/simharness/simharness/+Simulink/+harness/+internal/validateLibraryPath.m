function validateLibraryPath(pathStr,side)

    if isempty(pathStr)
        DAStudio.error('Simulink:Harness:CustomPathMustBeSpecified');
    end


    tmpMdl=new_system([],'model');
    ports=[];

    try
        blk=add_block(pathStr,[get_param(tmpMdl,'name'),'/',date],'MakeNameUnique','on');
        ports=get_param(blk,'ports');
    catch

        close_system(tmpMdl,0);
        DAStudio.error('Simulink:Harness:InvalidLibPath',pathStr);
    end

    close_system(tmpMdl,0);


    if strcmp(side,'source')
        if ports(1)>0
            DAStudio.error('Simulink:Harness:InputPortsFoundForSourceBlock',pathStr);
        end

        if ports(2)==0||ports(2)>1
            DAStudio.error('Simulink:Harness:IncorrectNumberOfOutputPortsForSourceBlock',pathStr);
        end

        if sum(ports(3:end))>0
            DAStudio.error('Simulink:Harness:InvalidPortsFoundForSourceBlock',pathStr);
        end
    else
        assert(strcmp(side,'sink'));

        if ports(1)==0||ports(1)>1
            DAStudio.error('Simulink:Harness:IncorrectNumberOfInputPortsForSinkBlock',pathStr);
        end

        if ports(2)>0
            DAStudio.error('Simulink:Harness:OutputPortsFoundForSinkBlock',pathStr);
        end

        if sum(ports(3:end))>0
            DAStudio.error('Simulink:Harness:InvalidPortsFoundForSinkBlock',pathStr);
        end
    end

end
