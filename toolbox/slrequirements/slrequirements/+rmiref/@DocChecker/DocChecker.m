


classdef DocChecker<handle



    properties
type
docname
links
pathFixed
labelFixed
isBad
badModel
badObject
isOneWay
summary
reportname
sessionId
skipped
    end

    properties(Constant)
        UNSUPPORTED_COMMAND='Unsupported command';
        UNRESOLVED_MODEL='Unresolved model in Simulink reference';
        UNRESOLVED_OBJECT='Unresolved object ID in Simulink reference';
        FIX_CALLBACK='rmiref.docFixRef';
        DELETE='DOC_CHECKER_DELETE';
    end

    methods

        function checker=DocChecker(name)
            checker.docname=name;
            checker.links=[];
            checker.skipped=cell(0,3);
        end

        function makeSummary(this)

            summaryInfo.docname=this.getDocName();
            summaryInfo.location=this.getDocLocation();
            summaryInfo.modified=this.getModificationInfo();

            summaryInfo.totalLinks=length(this.links);
            summaryInfo.totalModels=length(unique({this.links.model}));

            summaryInfo.pathsFixed=length(find(this.pathFixed));
            summaryInfo.labelsFixed=length(find(this.labelFixed));
            summaryInfo.totalBad=length(find(this.isBad));
            summaryInfo.badModels=length(find(this.badModel));
            summaryInfo.badObjects=length(find(this.badObject));
            summaryInfo.isOneWay=length(find(this.isOneWay));

            summaryInfo.skipped=sum(~strcmp(this.skipped,''));

            summaryInfo.report_date=datestr(now);
            this.summary=summaryInfo;
        end







    end

    methods(Static)

        function sId=makeSessionId()
            sId=num2str(cputime);
        end

        function mismatch=pathMismatch(path1,path2)
            path1=strrep(path1,'\','/');
            path2=strrep(path2,'\','/');
            while~isempty(path1)&&path1(end)=='/'
                path1=path1(1:end-1);
            end
            while~isempty(path2)&&path2(end)=='/'
                path2=path1(1:end-1);
            end
            if ispc()
                path1=lower(path1);
                path2=lower(path2);
            end
            if strcmp(path1,path2)
                mismatch=false;
            else
                mismatch=true;
            end
        end

        function newModelPath=promptModel()
            currentModel=rmiref.DocChecker.getCurrentModel();
            if~isempty(currentModel)
                modelH=get_param(currentModel,'Handle');
                modelStr=get_param(modelH,'FileName');
                [filename,pathname]=uigetfile({'*.mdl;*.slx','Simulink model (*.mdl;*.slx)'},'Please specify the target model',modelStr);
            else
                [filename,pathname]=uigetfile({'*.mdl;*.slx','Simulink model (*.mdl;*.slx)'},'Please specify the target model');
            end
            if~ischar(filename)||isempty(filename)
                newModelPath='';
            else
                linkSettings=rmi.settings_mgr('get','linkSettings');
                if strcmp(linkSettings.modelPathStorage,'absolute')
                    newModelPath=fullfile(pathname,filename);
                    newModelPath=regexprep(newModelPath,'\','/');
                else
                    newModelPath=filename;
                end
            end
        end


        function model=getCurrentModel()
            model=[];
            current=gcs;
            if~isempty(current)
                current=bdroot(current);


                if strcmp(get_param(current,'Shown'),'on')
                    model=current;
                end
            end
        end

        function modelStr=getCurrentModelString()
            modelStr='';
            model=rmiref.DocChecker.getCurrentModel();
            if~isempty(model)
                modelH=get_param(model,'Handle');
                linkSettings=rmi.settings_mgr('get','linkSettings');
                if strcmp(linkSettings.modelPathStorage,'absolute')
                    modelStr=get_param(modelH,'FileName');
                    modelStr=regexprep(modelStr,'\','/');
                else
                    [~,modelName,mdlExt]=rmisl.modelFileParts(modelH);
                    modelStr=[modelName,mdlExt];
                end
            end
        end

    end

    methods(Abstract)
        printable_name=getDocName(this)
        printable_location=getDocLocation(this)
        info=getModificationInfo(this)
        total_links=findLinks(this)
        [reasonIdx,data]=getSkippedItems(this);
        saveDocument(this);
    end


    methods(Static,Abstract)
        current=getCurrentDoc()
        located=locateDocument(doc)
        rptName=makeReportName(docName)
        fixed=fix(doc,item,issue,allArgs)
        restored=restore(doc,item)
    end
end
