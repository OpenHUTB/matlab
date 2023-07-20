function sections=getDocStructure(doc)























    utilObj=rmiref.WordUtil.docUtilObj(doc);
    totalParagraphs=length(utilObj.iLevels);
    sections=cell(totalParagraphs,3);
    for i=1:totalParagraphs
        if utilObj.iLevels(i)==0
            sections(i,:)={'',utilObj.iParents(i),utilObj.iLevels(i)};
        else
            sections(i,:)={utilObj.getLabel(i),utilObj.iParents(i),utilObj.iLevels(i)};
        end
    end
end
