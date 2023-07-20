function addReportBody(reportWrapperObj)






    testObj=reportWrapperObj.Content;

    etrSection=addEvolutionTreeReport(reportWrapperObj,testObj);


    if reportWrapperObj.GenerateEvolutionReport
        parentObj=testObj;
        evolutionInfoObjs=getEvolutionsInSequence(testObj);
        for evolutionIdx=1:length(evolutionInfoObjs)
            addEvolutionReport(reportWrapperObj,evolutionInfoObjs(evolutionIdx),etrSection,parentObj);
        end
    end











    add(reportWrapperObj.Report,etrSection);
end

function etrSection=addEvolutionTreeReport(reportObj,testObj)



    etrSection=mlreportgen.report.Section;
    etrSection.Title=mlreportgen.dom.Text(testObj.getName);
    append(etrSection,mlreportgen.dom.LinkTarget(testObj.Id));
    etrSection.Title.FontSize='24px';


    if reportObj.GenerateEvolutionTreeReport

        createEvolutionTreeReportBody(reportObj,testObj,etrSection);
    end

end

function addEvolutionReport(reportObj,testObj,parentSection,parentObj)


    erSection=mlreportgen.report.Section;

    erSection.Title=mlreportgen.dom.Text(testObj.getName);

    erSection.Title.FontSize='24px';

    createEvolutionReportBody(reportObj,testObj,parentObj,erSection);


    add(parentSection,erSection);
end

function addArtifactFileReport(reportObj,testObj,parentSection,parentObj)


    afrSection=mlreportgen.report.Section;

    createArtifactFileReportBody(reportObj,testObj,parentObj,afrSection);

    add(parentSection,afrSection);
end


function evolutionInfoObjs=getEvolutionsInSequence(testObj)
    evolutionTreeIterator=evolutions.internal.tree.EvolutionTreeIterator(testObj.EvolutionManager.RootEvolution);

    count=1;
    evolutionInfoObjs=testObj.EvolutionManager.Infos.empty();
    while~isempty(evolutionTreeIterator.current)
        if~evolutionTreeIterator.current.IsWorking
            evolutionInfoObjs(count)=evolutionTreeIterator.current;
            count=count+1;
        end
        evolutionTreeIterator.next;
    end
    evolutionInfoObjs=flip(evolutionInfoObjs);
end

