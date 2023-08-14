function[fileNames,harnessOwner,msgList,status]=topOffExternalCode(cvRslts,...
    topModel,modelOpts,shouldThrow)




    fileNames=[];
    harnessOwner=[];
    harnessModel=[];
    msgList=string.empty;
    isLibraryHarness=bdIsLibrary(topModel);
    cCallerBlockH=Simulink.findBlocksOfType(get_param(topModel,'Handle'),'CCaller');
    for i=1:numel(cCallerBlockH)
        opts=modelOpts.deepCopy();
        if isLibraryHarness&&~strcmp(cvRslts.modelinfo.harnessModel,'Not Unique')
            harnessOwner{i}=cvRslts.modelinfo.ownerBlock;%#ok<AGROW> 
            harnessModel{i}=cvRslts.modelinfo.harnessModel;%#ok<AGROW> 
            harnesslist=Simulink.harness.internal.find(harnessOwner{i},'Name',harnessModel{i});
            if isempty(harnesslist)
                sltest.harness.create(harnessOwner{i},"Name",harnessModel{i});
            end
            sltest.harness.load(harnessOwner{i},harnessModel{i});
            [~,flName,~,msg,fullCovgFlag]=sldvrun(harnessModel{i},opts,true,cvRslts);
            fileNames{i}=flName;%#ok<AGROW>
            sltest.harness.close(harnessOwner{i},harnessModel{i});
            [status,msgList]=checkSLDVData(fileNames{i},msg,fullCovgFlag,shouldThrow);
            break;
        else
            harnessOwner{i}=getfullname(cCallerBlockH(i));%#ok<AGROW>
            harnesslist=Simulink.harness.internal.find(harnessOwner{i});
            if isLibraryHarness
                harnessModel{i}=harnesslist(1).name;%#ok<AGROW> 
            else
                for idx=1:numel(harnesslist)
                    if harnesslist(idx).isOpen
                        sltest.harness.close(harnessOwner{i},harnesslist(idx).name);
                    end
                end
                harnessModel{i}=regexprep([get_param(cCallerBlockH(i),'Name'),'_harnessTopOff'],'\s+','');%#ok<AGROW> 
                harnesslist=Simulink.harness.internal.find(harnessOwner{i},'Name',harnessModel{i});
                if isempty(harnesslist)
                    sltest.harness.create(harnessOwner{i},"Name",harnessModel{i});
                end
            end
            sltest.harness.load(harnessOwner{i},harnessModel{i});


            [~,flName,~,msg,status]=sldvrun(harnessModel{i},opts,true,cvRslts);
            fileNames{i}=flName;%#ok<AGROW> 
            sltest.harness.close(harnessOwner{i},harnessModel{i});
            if i==1
                fullCovgFlag=status;
            else
                fullCovgFlag=status&&fullCovgFlag;
            end

            [status,msgList]=checkSLDVData(fileNames{i},msg,fullCovgFlag,shouldThrow);

            if~status
                return;
            end
        end
    end
end

function[status,msgList]=checkSLDVData(fileNames,msg,fullCovgFlag,shouldThrow)
    msgList=string.empty;
    matFile=fileNames.DataFile;
    if strlength(matFile)==0
        if fullCovgFlag
            error(message('stm:CoverageStrings:CovTopOff_Warning_AlreadyFullCoverageAchieved'));
        elseif isstruct(msg)
            msgList=string({msg.msg});
        elseif ischar(msg)
            msgList=string(msg);
        end

        if shouldThrow
            error(message('stm:CoverageStrings:CovTopOff_Error_SldvError',strjoin(msgList,'\n')));
        end
        status=false;
    else
        status=true;
    end
end
