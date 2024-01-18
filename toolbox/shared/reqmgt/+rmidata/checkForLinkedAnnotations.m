function result=checkForLinkedAnnotations(objects,shouldWarn,isGUI)

    if length(objects)==1
        [slHs,~,slFlags]=rmisl.getAllObjectsAndRmiFlags(objects);
        slWithLinks=slHs(slFlags);
    else

        isSf=(ceil(objects)==objects);
        slWithLinks=objects(~isSf);
    end

    isAnnotation=false(size(slWithLinks));

    for i=1:length(slWithLinks)
        if strcmp(get_param(slWithLinks(i),'type'),'annotation')
            isAnnotation(i)=true;
        end
    end

    result=slWithLinks(isAnnotation);
    if~isempty(result)&&shouldWarn
        warnAboutLostLinks(isGUI);
    end
end


function warnAboutLostLinks(isGUI)
    if isGUI
        uiwait(warndlg(...
        getString(message('Slvnv:rmidata:RmiSlData:SkippingLinksOnAnnotations')),...
        getString(message('Slvnv:rmidata:RmiSlData:ProblemCopyingLinks'))));
    else
        MSLDiagnostic('Slvnv:rmidata:RmiSlData:SkippingLinksOnAnnotations').reportAsWarning;
    end
end
