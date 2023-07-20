classdef Data<handle




    properties(SetObservable=true)
        uniqueId=''
        aggregatedIds=[]
        cvd=[]
        isCvdatagroup=false
        filename=''
        fullFileName=''
        analyzedModel=''
        checksum=0
        tag=''
        description=''
        info=''
        summaryHtml=''
        date=''
        saveId=0
        lastReport=''
        marked=false
        needSave=false
        userEditedTag=false
        userEditedDescr=false
        invalid=false
        dstNode=[]
        sdiRunId=[]
    end
    methods(Static=true)

        function data=createData(dataStruct)
            data=cvi.ResultsExplorer.Data('',[]);
            fn=fields(dataStruct);
            for idx=1:numel(fn)
                data.(fn{idx})=dataStruct.(fn{idx});
            end
        end

        function[fullFileName,filename]=getFullFileName(filename)
            [path,filename,~]=fileparts(filename);
            fullFileName=fullfile(path,[filename,'.cvt']);
        end
    end
    methods


        function data=Data(filename,cvd)
            if~isempty(cvd)

                data.tag=cvd.tag;
                data.cvd=cvd;
                data.aggregatedIds=cvd.aggregatedIds;
                setFileName(data,filename);
                if~isempty(cvd.uniqueId)
                    data.uniqueId=cvd.uniqueId;
                    data.description=cvd.description;


                    if~isa(cvd,'cv.cvdatagroup')
                        data.checksum=cvd.checksum;
                    else
                        data.isCvdatagroup=true;
                    end
                    data.info=getInfo(data);
                end
            end
        end

        function setFileName(data,filename)
            [data.fullFileName,data.filename]=cvi.ResultsExplorer.Data.getFullFileName(filename);
            setDate(data);
        end


        function setDate(data)
            t=dir(data.fullFileName);
            if~isempty(t)
                data.date=t.date;
            end
        end

        function s=getSaveData(obj)
            s.uniqueId=obj.uniqueId;
            s.aggregatedIds=obj.aggregatedIds;

            s.filename=obj.filename;
            s.fullFileName=obj.fullFileName;
            s.analyzedModel=obj.analyzedModel;
            s.checksum=obj.checksum;
            s.tag=obj.tag;
            s.description=obj.description;
            s.info=obj.info;
            s.summaryHtml=obj.summaryHtml;
            s.date=obj.date;
            s.lastReport=obj.lastReport;
            s.marked=obj.marked;
            s.needSave=obj.needSave;
        end

        function mark(data)
            data.marked=true;
        end

        function unMark(data)
            data.marked=false;
        end



        function res=setTag(data,tag)
            res=true;
            if strcmp(data.tag,tag)
                res=false;
                return;
            end
            data.tag=tag;
            data.getCvd().tag=tag;
            data.needSave=true;

        end

        function str=getTag(data)
            str=data.tag;
        end

        function resetLastReport(data)
            data.lastReport='';
        end


        function res=setDescription(data,description)
            res=true;
            if strcmp(data.description,description)
                res=false;
                return;
            end

            data.description=description;
            data.getCvd().description=description;
            data.needSave=true;
        end

        function res=getDescription(data)
            res=data.description;
        end

        function cvd=getCvd(data)
            try

                if isempty(data.cvd)


                    warning_state=warning('off');
                    warningCleanup=onCleanup(@()warning(warning_state));
                    [~,lcvd]=cvload(data.fullFileName);
                    if~isempty(lcvd)
                        data.cvd=lcvd{1};
                    end
                end
                cvd=data.cvd;
            catch MEx %#ok<NASGU>
                data.invalid=true;
                cvd=[];
            end
        end

        function[warnMsg,warnMsgTitle]=saveCvd(data)
            warnMsg=[];
            warnMsgTitle=[];
            if data.needSave
                [res,userWrite]=cvi.ReportUtils.checkUserWrite(data.fullFileName);
                if res==0
                    warnMsg=getString(message('Slvnv:simcoverage:ioerrors:FolderDoesNotExist'));
                    warnMsgTitle=getString(message('Slvnv:simcoverage:cvresultsexplorer:SaveData'));
                elseif~userWrite
                    [~,fileName]=fileparts(data.fullFileName);
                    warnMsg=getString(message('Slvnv:simcoverage:cvresultsexplorer:ReadOnlyFile',fileName));
                    warnMsgTitle=getString(message('Slvnv:simcoverage:cvresultsexplorer:SaveData'));
                else
                    cvsave(data.fullFileName,data.getCvd);
                    setDate(data);
                    data.needSave=false;
                end
            end
        end


        function info=getInfo(data)
            cvdata=data.getCvd();
            if data.isCvdatagroup
                allCvd=data.getCvd().getAll;


                found=false;
                for idx=1:numel(allCvd)
                    for ii=1:numel(allCvd{idx})
                        currCvd=allCvd{idx}(ii);
                        if~currCvd.isExternalFile()
                            cvdata=currCvd;
                            found=true;
                            break
                        end
                    end
                    if found
                        break
                    end
                end
                if~found

                    cvdata=allCvd{1}(1);
                end
            end
            info{1}={getString(message('Slvnv:simcoverage:cvhtml:DatabaseVersion')),...
            cvdata.dbVersion,'DatabaseVersion'};
            info{end+1}={getString(message('Slvnv:simcoverage:cvhtml:ModelVersion')),...
            cvdata.modelinfo.modelVersion,'ModelVersion'};
            info{end+1}={getString(message('Slvnv:simcoverage:cvhtml:Author')),...
            cvdata.modelinfo.creator,'Author'};
            info{end+1}={getString(message('Slvnv:simcoverage:cvhtml:StartedExecution')),...
            cvdata.startTime,'StartedExecution'};




            info{end+1}={getString(message('Slvnv:simcoverage:cvresultsexplorer:FileName')),data.filename,'FileName'};
        end

        function resetSummary(data)
            data.summaryHtml='';
        end

        function createSummary(data)
            d=data.getCvd();
            data.summaryHtml='';
            opt=cvi.CvhtmlSettings;
            opt.summaryMode=1;
            opt.isLinked=false;
            opt.barGrInMdlSumm=0;
            try
                cvhtml('summary',d,opt);
                data.summaryHtml=opt.summaryHtml;
            catch
                warndlg(getString(message('Slvnv:simcoverage:cvresultsexplorer:SummaryErrorDueToModelChange')),...
                getString(message('Slvnv:simcoverage:cvresultsexplorer:Summary')),'modal');
            end
        end

        function str=getSummary(data)
            str='';
            if isempty(data)
                return;
            end
            if isempty(data.summaryHtml)
                createSummary(data);
            end
            str=data.summaryHtml;
        end

        function applyFilterOnCvData(data,filterFileNames)


            tcvd=data.getCvd;
            if isa(tcvd,'cv.cvdatagroup')
                allCvd=tcvd.getAll('Mixed');
            else
                allCvd={tcvd};
            end
            for idx=1:numel(allCvd)
                ccvd=allCvd{idx};
                ccvd.filter=filterFileNames;
            end
        end

    end
end
