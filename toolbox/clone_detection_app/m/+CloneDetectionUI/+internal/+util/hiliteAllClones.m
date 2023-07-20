function hiliteAllClones(cloneDetectionStatus,similarCount,blockPathCategoryMap,colorCodes)



    if cloneDetectionStatus&&~isempty(blockPathCategoryMap)


        stylerName='CloneDetection.styleAllClones';
        styler=diagram.style.getStyler(stylerName);


        if(isempty(styler))
            diagram.style.createStyler(stylerName);
            styler=diagram.style.getStyler(stylerName);
        end

        keyList=keys(blockPathCategoryMap);


        exactColor=CloneDetectionUI.internal.util.getExactColorCodeNumerical;
        exactstyle=diagram.style.Style;
        exactstyle.set('FillStyle','Solid');
        exactstyle.set('FillColor',[exactColor,1.0]);
        exactstyle.set('TextColor',[exactColor,1.0]);

        exactstyleName='ExactStyle';
        exactTagRule=styler.addRule(exactstyle,diagram.style.ClassSelector(exactstyleName));


        darkest=CloneDetectionUI.internal.util.getSimilarColorCodeNumerical;
        lightest=CloneDetectionUI.internal.util.getSimilarLightColorCodeNumerical;
        red=linspace(lightest(1),darkest(1),similarCount+1);
        green=linspace(lightest(2),darkest(2),similarCount+1);
        blue=linspace(lightest(3),darkest(3),similarCount+1);


        for i=1:similarCount
            similarColor=[red(similarCount-i+1),green(similarCount-i+1),blue(similarCount-i+1)];
            similarstyle=diagram.style.Style;
            similarstyle.set('FillStyle','Solid');
            similarstyle.set('FillColor',[similarColor,1.0]);
            similarstyle.set('TextColor',[similarColor,1.0]);

            similarstyleName=['SimilarStyle',int2str(i)];
            similarTagRule(i)=styler.addRule(similarstyle,diagram.style.ClassSelector(similarstyleName));
        end


        exclusionColor=CloneDetectionUI.internal.util.getExclusionColorCodeNumerical;
        exclusionstyle=diagram.style.Style;
        exclusionstyle.set('FillStyle','Solid');
        exclusionstyle.set('FillColor',[exclusionColor,1.0]);
        exclusionstyle.set('TextColor',[exclusionColor,1.0]);
        exclusionRule=styler.addRule(exclusionstyle,diagram.style.ClassSelector('ExclusionStyle'));

        try
            for i=1:length(keyList)
                try
                    get_param(keyList{i},'handle');
                catch
                    continue;
                end

                categoryKey=blockPathCategoryMap(keyList{i}).CloneGroupKey;
                if contains(categoryKey,'Exact')
                    applyClassRecursively(keyList{i},styler,'ExactStyle');
                elseif contains(categoryKey,'Similar')
                    str=textscan(categoryKey,'%s','Delimiter','-');
                    similarstyleName=['SimilarStyle',str{1}{end}];
                    applyClassRecursively(keyList{i},styler,similarstyleName);

                elseif contains(categoryKey,'Exclusion')
                    applyClassRecursively(keyList{i},styler,'ExclusionStyle');

                end
            end
        catch ME
            DAStudio.error(ME.message);
        end

    end
end




function applyClassRecursively(blkname,styler,applyclass)

    styler.applyClass(blkname,applyclass);

    parentname=get_param(blkname,'Parent');


    if isempty(parentname)
        return;
    end
    bdrootname=bdroot(blkname);
    while~strcmp(parentname,bdrootname)
        styler.applyClass(parentname,applyclass);
        parentname=get_param(parentname,'Parent');
    end
end






