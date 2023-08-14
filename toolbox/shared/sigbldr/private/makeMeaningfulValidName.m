function outputName=makeMeaningfulValidName(inputName)





















    if~ischar(inputName)
        error(message('sigbldr_ui:exportMatFile:InvalidInputToMakeValidName'));
    end


    inputName=convertStringsToChars(inputName);


    inputName=strtrim(inputName);




    start_id=regexp(inputName,'(\w{1}\s+\w{1})');
    id_of_space_between_alphanum=start_id+1;
    inputName(id_of_space_between_alphanum)='_';




    Prefix='Test_Case_';



    ReplacementStyle='underscore';


    nonEnglishCharsRegExp='[^a-zA-Z]';
    afterNonEnglishCharsAreRemoved=regexprep(inputName,nonEnglishCharsRegExp,'');
    allCharsAreNonEnglish=isempty(afterNonEnglishCharsAreRemoved);
    if allCharsAreNonEnglish


        ReplacementStyle='delete';



        inputName=regexprep(inputName,'_','');
    end


    outputName=matlab.lang.makeValidName(inputName,...
    'Prefix',Prefix,'ReplacementStyle',ReplacementStyle);

end

