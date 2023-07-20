



function cvdsum=getSumWithAddSubsys(this)
    try

        if all({this.allData.assoc}==string(this.allData(1).assoc))

            cvdsum=addData(this,this.allData);
            return;
        end


        if~any({this.allData.assoc}=="")
            cvdsum=[];
            return;
        end

        subsysData=containers.Map('KeyType','char','ValueType','any');
        modelData=[];
        for idx=1:numel(this.allData)
            data=this.allData(idx);
            checkTrace(this,data.cvd);
            if~isempty(data.assoc)
                if~isempty(subsysData)&&...
                    subsysData.isKey(data.assoc)
                    sd=subsysData(data.assoc);
                    sd(end+1)=data;%#ok<AGROW>
                else
                    sd=data;
                end
                subsysData(data.assoc)=sd;
            elseif isempty(modelData)
                modelData=data;
            else
                modelData(end+1)=data;%#ok<AGROW>
            end
        end

        cvdsum=addData(this,modelData);


        allKeys=subsysData.keys;
        for idx=1:numel(allKeys)
            assoc=allKeys{idx};
            scvd=subsysData(assoc);

            cvdsumS=addData(this,scvd);

            if isempty(cvdsum)
                cvdsum=cvdsumS;
            else

                if isa(cvdsum,'cvdata')
                    cvdt=cvdsum.addSubsystem(assoc,cvdsumS);
                    if~isempty(cvdt)
                        cvdsum=cvdt;
                    end
                else
                    cvdt=cvdsum.get(cvdsumS.modelinfo.ownerModel);
                    cvdt=cvdt.addSubsystem(assoc,cvdsumS);
                    if~isempty(cvdt)
                        cvdsum.add(cvdt);
                    end
                end
            end

        end
    catch MEx
        rethrow(MEx);
    end
end

function cvdsum=addData(this,modelData)
    cvdsum=[];
    for idx=1:numel(modelData)
        ccvd=modelData(idx).cvd;
        checkTrace(this,ccvd);
        if isempty(cvdsum)
            if isa(ccvd,'cv.cvdatagroup')



                cvdsum=cv.cvdatagroup;
                cvdsum.copy(ccvd);
            else
                cvdsum=ccvd;
            end
        else
            if isa(ccvd,'cv.cvdatagroup')
                cvdsum=cv.cvdatagroup(cvdsum);
            end
            cvdsum=cvdsum+ccvd;
        end
    end
end


function checkTrace(this,cvd)
    if isa(cvd,'cvdata')
        turnOnTrace(this,cvd);
    else
        cvdg=cvd.getAll;
        for idx=1:numel(cvdg)
            turnOnTrace(this,cvdg{idx});
        end
    end
end

function turnOnTrace(this,cvd)

    if this.isTraceOn&&...
        ~isempty(cvd.testRunInfo)&&...
        cvd.testRunInfo.runId~=0
        cvd.traceOn=true;
    end
end

