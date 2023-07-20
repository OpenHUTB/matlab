function[labels,depths,locations]=listRequirements(requirements,parentName,offset)
    orderedIndex=oslc.Project.getOrderedIndex(requirements);
    labels=cell(size(requirements));
    locations=cell(size(requirements));
    depths=ones(size(requirements))*offset;
    progressMessage=getString(message('Slvnv:oslc:GettingContentsOf',parentName));
    for i=1:length(requirements)
        req=requirements(orderedIndex(i));
        labels{i}=[req.identifier,' (',req.title,')'];
        locations{i}=[req.resource,' (',req.identifier,')'];
        if mod(i,50)==0
            if rmiut.progressBarFcn('isCanceled')
                break;
            else
                progressValue=0.5+i/2/length(requirements);
                rmiut.progressBarFcn('set',progressValue,progressMessage);
            end
        end
    end
end
