function name=getNameForVersion(tmpLibrary,block,model)

    [~,blockPath]=strtok(block,'/');
    versionFor=getString(message('SimulinkProject:Upgrade:blockVersion'));
    modelTag=['_',versionFor,'_',model];
    name=[tmpLibrary,blockPath,modelTag];


    name(ismember(name,' '))=[];
end