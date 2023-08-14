function noteList=sf_get_note(fullChartName)















    noteList=[];
    ch=sf_get(fullChartName,'ChartHandle');


    sortStatesByName=false;
    includeCommentedStates=false;
    allStates=sf('AllSubstatesIn',ch,sortStatesByName,includeCommentedStates);






    for i=1:length(allStates)
        isNoteBox=sf('get',allStates(i),'.isNoteBox');
        if isNoteBox==1
            note.name=sf('get',ch,'.name');
            note.handle=ch;
            note.comment=sf('get',allStates(i),'.labelString');
            noteList{end+1}=note;
        end
    end


