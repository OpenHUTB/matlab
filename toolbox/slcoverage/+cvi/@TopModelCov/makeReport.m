function makeReport(this,res,cumRes,outputDir)




    resultSettings=this.resultSettings;

    if~resultSettings.makeReport&&...
        ~resultSettings.modelDisplay

        return
    end

    isCumulativeReport=~isempty(cumRes)&&resultSettings.covCumulativeReport;
    if isCumulativeReport
        dataTotal=cumRes;
        addData=resolve_additional_data(this,resultSettings);
    else
        dataTotal=res;
        addData=[];
    end

    if~isempty(addData)
        addDataSum=addData{1};
        for i=2:numel(addData)
            addDataSum=addDataSum+addData{i};
        end
        dataTotal=commitdelta(dataTotal+addDataSum);
    else
        addDataSum=[];
    end

    if resultSettings.makeReport
        if isCumulativeReport




            refModelCovObjs=this.getAllModelcovIds;
            oldCumul=cvi.TopModelCov.getRunningTotal(refModelCovObjs,true);

            if isempty(oldCumul)&&isempty(addDataSum)
                pars={res};
            else
                if~isempty(oldCumul)&&~isempty(addDataSum)
                    oldCumul=oldCumul+addDataSum;
                elseif isempty(oldCumul)&&~isempty(addDataSum)
                    oldCumul=addDataSum;
                end

                applyFilter(oldCumul,dataTotal);
                delta=commitdelta(dataTotal-oldCumul);
                set_label(res,getString(message('Slvnv:simcoverage:cvhtml:CurrentRun')));
                set_label(delta,getString(message('Slvnv:simcoverage:cvhtml:Delta')));
                set_label(dataTotal,getString(message('Slvnv:simcoverage:cvhtml:Cumulative')));

                pars={res,delta,dataTotal};
                resultSettings.cumulativeReport=true;
            end
        else
            pars={res};
        end
        fileName=get_param(this.topModelH,'name');
        if isa(res,'cv.cvdatagroup')
            fileName=[fileName,'_summary'];
        end

        fileName=cvi.ReportUtils.get_report_file_name(fileName,'fileDir',outputDir);
        cvhtml(fileName,pars{:},resultSettings);
    end

    if resultSettings.modelDisplay
        cvmodelview(dataTotal,resultSettings);
    end
end


function applyFilter(old,new)
    if isa(new,'cv.cvdatagroup')
        cvds=new.getAll('Mixed');
        filter=cvds{1}.filter;
    else
        filter=new.filter;
    end
    if isa(old,'cv.cvdatagroup')
        cvds=old.getAll('Mixed');
        for idx=1:length(cvds)
            cvds{idx}.filter=filter;
        end
    else
        old.filter=filter;
    end
end

function ncvd=commitdelta(cvd)
    if isa(cvd,'cv.cvdatagroup')
        ncvd=cv.cvdatagroup;
        cvds=cvd.getAll('Mixed');
        for idx=1:length(cvds)
            cvd=cvds{idx};
            if cvd.id==0
                commitdd(cvd);
            end
            ncvd.add(cvd);
        end
    else
        ncvd=commitdd(cvd);
    end

end


function set_label(cvd,label)
    if isa(cvd,'cv.cvdatagroup')
        cvds=cvd.getAll('Mixed');
        for idx=1:length(cvds)
            ccvd=cvds{idx};
            cv('set',ccvd.id,'.label',label);
        end
    else
        cv('set',cvd.id,'.label',label);
    end

end


function dataVect=resolve_additional_data(this,resultSettings)
    dataStr=resultSettings.covCompData;
    dataVect={};
    if~isempty(dataStr)

        [name,rem]=strtok(dataStr,' ,');

        while(~isempty(name))
            try
                notvalid=false;
                testParam=evalin('base',name);
                if valid(testParam)
                    dataVect{end+1}=testParam;%#ok<AGROW>
                else
                    notvalid=true;
                end
            catch MEx %#ok<NASGU>
                notvalid=true;
            end;
            if notvalid
                warning(message('Slvnv:simcoverage:genCovResults:InvalidArgument',name));
            end
            [name,rem]=strtok(rem,' ,');%#ok<STTOK>
        end
    end

end
