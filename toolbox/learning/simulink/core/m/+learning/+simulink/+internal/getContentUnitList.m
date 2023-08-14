function contentUnitTable=getContentUnitList(contentRoot,course)

    contentUnitFile=fullfile(contentRoot,['course_',course,'.json']);
    contentUnitStruct=jsondecode(fileread(contentUnitFile));

    chapters=contentUnitStruct.chapters;


    numContentUnits=length(vertcat(contentUnitStruct.chapters.conceptSequence));
    contentUnitTable=table('Size',[numContentUnits,3],...
    'VariableTypes',{'double','double','string'},...
    'VariableNames',{'Chapter','Lesson','Path'});

    cuIdx=1;
    for idx=1:length(chapters)

        cs=chapters(idx).conceptSequence;
        for jdx=1:numel(cs)

            lesson=cs{jdx};
            lesson=replace(lesson,'/',filesep);
            contentUnitTable.Chapter(cuIdx)=idx;
            contentUnitTable.Lesson(cuIdx)=jdx;
            contentUnitTable.Path(cuIdx)=fullfile(contentRoot,lesson);
            cuIdx=cuIdx+1;
        end
    end