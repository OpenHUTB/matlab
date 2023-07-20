function sections=getDocStructure(doc)

    utilObj=rmiref.ExcelUtil.docUtilObj(doc);
    totalRows=length(utilObj.iLevels);

    sections=cell(totalRows,3);
    prevParent=-1;
    allFontSizes=[];
    for i=1:totalRows
        thisFontSize=utilObj.iLevels(i);
        if~any(allFontSizes==thisFontSize)
            allFontSizes(end+1)=thisFontSize;%#ok<AGROW>
        end
        if thisFontSize==0
            sections(i,:)={'',prevParent,-1};
        else
            prevParent=utilObj.iParents(i);
            sections(i,:)={utilObj.getLabel(i),prevParent,thisFontSize};
        end
    end
    sortedFontSizes=sort(allFontSizes,'descend');
    for i=1:totalRows
        thisFontSize=sections{i,3};
        if thisFontSize>0
            sections{i,3}=find(sortedFontSizes==thisFontSize);
        end
    end
end

