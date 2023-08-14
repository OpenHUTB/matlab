function assignedInterfaces=getAssignedInterfacesFromUITable(hInterfaceList)



    assignedInterfaces={};

    com.mathworks.project.impl.plugin.PluginManager.allowMatlabThreadUse();

    try
        javaProject=com.mathworks.project.impl.ProjectGUI.getInstance().getCurrentProject();
    catch
        return
    end

    javaConfig=javaProject.getConfiguration();

    try
        tableData=javaConfig.getParamReader('param.hdl.TargetInterface');
    catch
        return;
    end

    assignedInterfacesMap=containers.Map();
    port=tableData.getChild('Port');
    while port.isPresent()
        interfaceNameFromUI=char(port.readText('SelectedInterface'));

        interfaceID='';
        maxMatchLen=0;
        for ii=1:length(hInterfaceList)
            foundInterfaceMatch=strfind(interfaceNameFromUI,hInterfaceList{ii});
            if~isempty(foundInterfaceMatch)
                matchLen=length(hInterfaceList{ii});
                if matchLen==length(interfaceNameFromUI)
                    interfaceID=hInterfaceList{ii};
                    break
                elseif matchLen>=maxMatchLen
                    interfaceID=hInterfaceList{ii};
                    maxMatchLen=matchLen;
                end
            end
        end
        if~isempty(interfaceID)
            assignedInterfacesMap(interfaceID)=true;
        end
        port=port.next();
    end
    assignedInterfaces=assignedInterfacesMap.keys;
