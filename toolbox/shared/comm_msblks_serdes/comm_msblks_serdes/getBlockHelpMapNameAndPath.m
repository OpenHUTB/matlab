function[mapName,relativePathToMapFile,found]=getBlockHelpMapNameAndPath(block_type)








    if strcmp(block_type,'EyeDiagram')
        found=true;
        mapName='eye_diagram';
        if~isempty(ver('comm'))&&builtin('license','test','Communication_Toolbox')
            relativePathToMapFile='/comm/comm.map';
        elseif~isempty(ver('serdes'))&&builtin('license','test','SerDes_Toolbox')
            relativePathToMapFile='/serdes/helptargets.map';
        elseif~isempty(ver('msblks'))&&builtin('license','test','Mixed_Signal_Blockset')
            relativePathToMapFile='/msblks/helptargets.map';
        else
            relativePathToMapFile='/comm/comm.map';
        end
    else
        mapName='User Defined';
        relativePathToMapFile='/comm/comm.map';
        found=false;
    end