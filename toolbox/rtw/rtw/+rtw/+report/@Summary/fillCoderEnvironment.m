function fillCoderEnvironment(obj,chapter)
    import mlreportgen.dom.*;
    aTable=Table(obj.getSummary);
    aTable.StyleName='TableStyleAltRowNormal';
    chapter.append(aTable);
end
