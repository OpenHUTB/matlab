function sheetNames=generateValidSheetNames(~,eng,runIDs)





    MAX_SHEET_NAME_LENGTH=31;
    runNames={};
    specialCharsToExclude='[:?*[]\\/]';
    for runIdx=1:length(runIDs)
        currRunName=eng.getRunName(runIDs(runIdx));


        if isempty(currRunName)
            currRunName=['Sheet',num2str(runIdx)];
        end


        currRunName=regexprep(currRunName,specialCharsToExclude,'_');
        runNames{end+1}=currRunName;%#ok
    end
    sheetNames=matlab.lang.makeUniqueStrings(runNames,{},MAX_SHEET_NAME_LENGTH);
end
