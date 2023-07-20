function destinationBlock=createOneBlockLibrary(jSourceFile,jSourceBlock,jDestinationFile,jDestinationBlock)




    destinationPath=char(jDestinationFile);
    [~,destinationName]=fileparts(destinationPath);

    sourcePath=char(jSourceFile);
    [~,sourceName]=fileparts(sourcePath);

    if~bdIsLoaded(sourceName)
        load_system(sourcePath);
    end

    sourceBlock=char(jSourceBlock);
    destinationBlock=i_getRefactoredBlock(char(jDestinationBlock),destinationName);

    new_system(destinationName,'Library');
    add_block(sourceBlock,destinationBlock);
    set_param(destinationBlock,'LinkStatus','none');
    save_system(destinationName,destinationPath);

end

function refactoredBlock=i_getRefactoredBlock(block,system)
    [~,blockPath]=strtok(block,'/');
    refactoredBlock=[system,blockPath];
end
