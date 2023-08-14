function count=populateInformerData(modelH,inUI)












    if ischar(modelH)
        modelH=get_param(modelH,'Handle');
    end

    rmi('init');

    if nargin<2
        inUI=false;
    end
    if inUI
        rmiut.progressBarFcn('set',0,...
        getString(message('Slvnv:rmiut:progressBar:InformerCheckingForLinks')),...
        getString(message('Slvnv:rmiut:progressBar:InformerDataTitle')));
    else
        fprintf(1,'%s\n',getString(message('Slvnv:rmi:informer:InformerCheckingForLinks')));
    end
    [linkedSids,nestedIds]=rmidata.getSidsWithLinks(modelH);
    allSids=unique([linkedSids,nestedIds]);
    count=length(allSids);

    if count>0

        rmi.Informer.cache('incrementSessionId');

        if ispc
            [~,has_word,has_excel]=rmi.probeReqs(modelH);
            if has_word||has_excel
                rmiut.msOfficeApps('cache');
            end
        end


        if builtin('_license_checkout','Simulink_Requirements','quiet')
            warning(message('Slvnv:rmi:informer:NoLicense'));
            count=0;
            return;
        end

        if~inUI
            fprintf(1,'%s',getString(message('Slvnv:rmi:informer:InformerGettingLinksInfo')));
        end
        docTable=cell(0,2);
        objCount=0;
        for i=1:count
            mySid=allSids{i};
            if inUI
                rmiut.progressBarFcn('set',i/count,...
                getString(message('Slvnv:rmiut:progressBar:InformerDataFor',mySid)));
            else
                fprintf(1,'..');
            end
            needToCheckSubRoot=any(strcmp(nestedIds,mySid));
            docSubTable=rmi.Informer.updateEntry(mySid,needToCheckSubRoot);
            if~isempty(docSubTable)
                objCount=objCount+1;
                docTable=rmiut.updateDocTable(docTable,docSubTable);
            end
            if inUI&&rmiut.progressBarFcn('isCanceled')
                break;
            end
        end
        if inUI
            rmiut.progressBarFcn('delete');
        else
            fprintf(1,'%s\n',getString(message('Slvnv:rmi:informer:InformerDoneCount',num2str(count))));
        end
        modelName=get_param(modelH,'Name');
        rmi.Informer.setSummary(modelName,objCount,docTable);
        rmi.Informer.setCurrent(modelName);

        if ispc
            if has_word||has_excel
                rmiut.msOfficeApps('restore');
            end
        end

    else
        if inUI
            rmiut.progressBarFcn('delete');
        else
            fprintf(1,'%s\n',getString(message('Slvnv:rmi:informer:InformerNoLinks')));
        end
    end
end

