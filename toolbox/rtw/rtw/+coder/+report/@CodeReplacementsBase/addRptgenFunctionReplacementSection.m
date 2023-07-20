function sectionId=addRptgenFunctionReplacementSection(obj,chapter,sectionId)
    [usedFcns,mergeIdxs]=obj.getUsedFunctions('');
    if~isempty(mergeIdxs)
        import mlreportgen.dom.*;
        templatePath=coder.report.internal.slcoderPublishCode.getPrivateTemplatePath();
        template=fullfile(templatePath,'SectionTemplate');
        section=DocumentPart(chapter.Type,template);
        while~strcmp(section.CurrentHoleId,'#end#')
            switch section.CurrentHoleId
            case 'SectionNumber'
                append(section,num2str(sectionId));
                sectionId=sectionId+1;
            case 'SectionTitle'
                append(section,obj.getFunctionReplacmentTitle);
            case 'SectionContents'
                append(section,Paragraph(obj.getCodeReplacmentsIntro));
                table=obj.createRptgenRepTable(usedFcns,mergeIdxs);
                section.append(table);
            end
            moveToNextHole(section);
        end
        chapter.append(section);
    end
end
