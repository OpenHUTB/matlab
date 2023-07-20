function hyperlink=getModelHyperlink(modelName,originalModel)





    currentDir=pwd;
    modelName=strrep(modelName,newline,' ');


    modelPath=fullfile(currentDir,'sschdl',originalModel,modelName);
    hyperlink=strcat('<a href="matlab:open_system(''',...
    modelPath,...
    ''')">',...
    modelName,...
    '</a>');
end
