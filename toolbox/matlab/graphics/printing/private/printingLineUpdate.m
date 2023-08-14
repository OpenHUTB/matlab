function old=printingLineUpdate(line,input,old)

















    allStyleLines=line.allStyleLines;
    allLineWidth=line.allLineWidth;

    printUtility=matlab.graphics.internal.printUtility;


    if~isempty(input.LineStyleMap)&&...
        ~strcmp(input.LineStyleMap,'none')&&...
        ~isempty(allStyleLines)


        oldlstyle=printUtility.getValuesAsCell(allStyleLines,'LineStyle');
        oldstylemode=printUtility.getValuesAsCell(allStyleLines,'LineStyleMode');


        old=printUtility.pushOldData(old,allStyleLines,{'LineStyleMode'},oldstylemode);
        old=printUtility.pushOldData(old,allStyleLines,{'LineStyle'},oldlstyle);

        newlstyle=oldlstyle;
        if ischar(input.LineStyleMap)&&strcmpi(input.LineStyleMap,'bw')
            styleLinesCell=printUtility.getValuesAsCell(allStyleLines,'Color');
            newlstyle=LocalMapColorToStyle(styleLinesCell);
        else
            try
                newlstyle=feval(input.LineStyleMap,allStyleLines);
            catch ex
                warning(message('MATLAB:hgexport:SkippingStylemap',ex.getReport('basic')));
            end
        end
        printUtility.setValues(allStyleLines,'LineStyle',newlstyle);
    end


    if~isempty(input.LineMode)&&~strcmp(input.LineMode,'none')

        allLineWidth=allLineWidth(isprop(allLineWidth,'LineWidth'));
        oldlinewidth=printUtility.getValuesAsCell(allLineWidth,'LineWidth');
        oldlinewidthmode=printUtility.getValuesAsCell(allLineWidth,'LineWidthMode');


        old=printUtility.pushOldData(old,allLineWidth,{'LineWidthMode'},oldlinewidthmode);
        old=printUtility.pushOldData(old,allLineWidth,{'LineWidth'},oldlinewidth);

        switch(input.LineMode)


        case 'fixed'
            if isfield(input,'ApplyLineWidthMin')&&input.ApplyLineWidthMin&&...
                input.LineWidthMin>0&&input.LineWidthMin>input.FixedLineWidth
                printUtility.setValues(allLineWidth,'LineWidth',input.LineWidthMin);
            else
                printUtility.setValues(allLineWidth,'LineWidth',input.FixedLineWidth);
            end
        case 'scaled'
            if strcmp(input.ScaledLineWidth,'auto')
                scale=input.sizescale;
            else
                scale=input.ScaledLineWidth/100;
            end
            newlines=matlab.graphics.internal.printUtility.scaleValues(oldlinewidth,scale,input.LineWidthMin);
            printUtility.setValues(allLineWidth,'LineWidth',newlines);
        case 'screen'


            if isfield(input,'LineWidthMin')&&input.LineWidthMin>0
                newLinewidth=oldlinewidth;
                oldlinewidth=cell2mat(oldlinewidth);
                indices=(oldlinewidth<input.LineWidthMin);
                [newLinewidth{indices}]=deal(input.LineWidthMin);
                if any(indices)
                    printUtility.setValues(allLineWidth,'LineWidth',newLinewidth);
                end
            end
        end
    end
end



function newArray=LocalMapColorToStyle(inArray)



    my_n=length(inArray);
    newArray=cell(my_n,1);
    styles={'-','--',':','-.'};
    uniques=[];
    nstyles=length(styles);
    for my_k=1:my_n
        gray=matlab.graphics.internal.printUtility.mapToGrayScale(inArray{my_k});
        if isempty(gray)||ischar(gray)||gray<.05
            newArray{my_k}='-';
        else
            if~isempty(uniques)&&any(gray==uniques)
                ind=find(gray==uniques);
            else
                uniques=[uniques,gray];%#ok<AGROW>
                ind=length(uniques);
            end
            newArray{my_k}=styles{mod(ind-1,nstyles)+1};
        end
    end
end