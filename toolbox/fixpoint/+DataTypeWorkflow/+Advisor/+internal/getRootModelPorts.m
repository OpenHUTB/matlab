function[rootInportHandle,rootOutportHandle]=getRootModelPorts(subSystemPath)





    rootModelHandle=get_param(subSystemPath,'Handle');
    rootInportHandle=find_system(rootModelHandle,'SearchDepth',1,'BlockType','Inport');
    rootOutportHandle=find_system(rootModelHandle,'SearchDepth',1,'BlockType','Outport');

end

