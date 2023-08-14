function choices=library_completions()

    choices=dir(fullfile(pwd,'+*'));


    choices={choices([choices.isdir]).name};


    choices=extractAfter(choices,1);


    isValidName=cellfun(@(c)isvarname(c),choices);
    choices=choices(isValidName);
end