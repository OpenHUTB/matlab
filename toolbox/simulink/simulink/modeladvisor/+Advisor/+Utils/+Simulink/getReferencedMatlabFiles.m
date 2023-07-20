function fileReferences=getReferencedMatlabFiles(system)




    model=bdroot(system);

    sysIsRoot=strcmp(model,system);

    try
        fileDependencyDigraph=dependencies.internal.analyze(which(model),...
        "Traverse","Test",...
        "Include",["MATLABFcn","StateflowMATLABFcn","MATLABFile","LibraryLink"],...
        "AnalyzeUnsaved",true);
    catch exception
        if strcmp(exception.identifier,'SimulinkDependencyAnalysis:Engine:UnsavedChanges')
            DAStudio.error('ModelAdvisor:engine:HimlModelNotSavedErrMsg',model);
        else
            rethrow(exception);
        end
    end



    fileRef=fileDependencyDigraph.Edges.EndNodes;



    fileRefLoc=fileDependencyDigraph.Edges.UpstreamComponent;

    if~isempty(fileRef)



        fileNames=fileRef(:,2);
        temp=false(1,length(fileNames));
        for m=1:length(fileNames)
            [~,~,ext]=fileparts(fileNames{m});
            if strcmp(ext,'.m')
                temp(m)=true;
            end
        end
        fileRef=fileRef(temp,:);
        fileRefLoc=fileRefLoc(temp);

        if~isempty(fileRef)

            if~sysIsRoot
                temp1=(cellfun(@(x)contains(x,system),fileRefLoc));
                fileRef=fileRef(temp1,:);
                fileRefLoc=fileRefLoc(temp1);
            end



            fileNames=fileRef(:,2);
            [~,temp]=unique(fileNames);
            fileRef=fileRef(temp,:);
            fileRefLoc=fileRefLoc(temp);


            if~isempty(fileRef)
                [len,~]=size(fileRef);
                fileReferences(len,1)=struct('FileName',[],'ReferenceLocationPath',[],'ReferenceLocation',[],'ParentEML',[]);

                for idx=1:len
                    fileReferences(idx).FileName=fileRef{idx,2};
                    fileReferences(idx).ReferenceLocationPath=fileRef{idx,1};
                    fileReferences(idx).ReferenceLocation=fileRefLoc{idx};
                    if contains(fileReferences(idx).ReferenceLocation,':')
                        try
                            ids=strsplit(fileReferences(idx).ReferenceLocation,':');

                            parentCh=idToHandle(sfroot,sfprivate('block2chart',get_param(ids{1},'handle')));
                            fileReferences(idx).ParentEML=parentCh.find('SSIdNumber',str2double(ids{end}));
                        catch
                            fileReferences(idx).ParentEML=[];
                        end
                    else
                        try
                            blockH=get_param(fileReferences(idx).ReferenceLocation,'Handle');
                            fileReferences(idx).ParentEML=idToHandle(sfroot,sfprivate('block2chart',blockH));
                        catch
                            fileReferences(idx).ParentEML=[];
                        end
                    end
                end


                while fileRefernceHasEmptyEML(fileReferences)
                    atLeastOneEMLIsAssignedPerLoop=false;
                    for idx=1:len
                        if isempty(fileReferences(idx).ParentEML)
                            for j=1:len



                                if strcmp(fileReferences(idx).ReferenceLocationPath,fileReferences(j).FileName)...
                                    &&~isempty(fileReferences(j).ParentEML)
                                    fileReferences(idx).ParentEML=fileReferences(j).ParentEML;
                                    atLeastOneEMLIsAssignedPerLoop=true;
                                end
                            end
                        end
                    end
                    if~atLeastOneEMLIsAssignedPerLoop
                        break;
                    end
                end
            else
                fileReferences=[];
            end
        else
            fileReferences=[];
        end
    else
        fileReferences=[];
    end
end

function empty=fileRefernceHasEmptyEML(fileReferences)
    empty=false;
    for i=1:numel(fileReferences)
        if isempty(fileReferences(i).ParentEML)
            empty=true;
            return;
        end
    end
end
