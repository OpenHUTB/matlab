

classdef MATData<sigbldr.extdata.SBImportData



    methods
        function this=MATData(fullPathName)
            sigbldr.extdata.SBImportData.verifyFileName(fullPathName);

            try
                [~]=whos('-file',fullPathName);
                this.Type='MAT';
            catch ME
                ME.throw();
            end


            this.StatusMessage='';
            this.GroupSignalData=[];
            [localtime,localdata,sigNames,grpNames]=this.readFile(fullPathName);
            [newstatus,msg]=this.setGroupSignalData(localtime,localdata,sigNames,grpNames);
            if(~newstatus)
                DAStudio.error('Sigbldr:import:ExcelCVSMATData',msg)
            end
        end
    end
    methods(Access=protected)



        function[outtime,outdata,sigNames,grpNames]=readFile(this,varargin)
            fullPathName=varargin{1};
            [~,fileName,fileExt]=fileparts(fullPathName);
            shortName=[fileName,fileExt];
            premsg=DAStudio.message('Sigbldr:import:nonCompliantFormat',shortName);


            sigNames={};
            grpNames={};
            outtime=[];
            outdata=[];
            idxDs=false;
            dsVarNames={};

            try
                soe=Simulink.sdi.internal.SimOutputExplorer;
                [varNames,varValues]=soe.ExploreMATFile(fullPathName);

                if~isempty(varNames)
                    numNames=numel(varNames);

                    for k=numNames:-1:1
                        idxDs(k)=isa(varValues{k},'Simulink.SimulationData.Dataset');
                    end
                end

                if any(idxDs)

                    dsVarNames=varNames(idxDs);


                    if~isempty(soe.Outputs)
                        for lll=1:numel(dsVarNames)
                            name=dsVarNames{lll};
                            idxSigDs(lll,:)=strncmp(name,{soe.Outputs(:).RootSource},length(name));%#ok<AGROW>
                        end
                    end
                end

                if all(idxDs)

                    soe_OutputsDs=soe.Outputs;
                    soe_OutputsOther=[];
                elseif any(idxDs)

                    soe_OutputsDs=soe.Outputs;
                    if~isempty(soe.Outputs)
                        soe_OutputsOther=soe.Outputs(~logical(sum(idxSigDs)));
                    else
                        soe_OutputsOther=[];
                    end
                else

                    soe_OutputsOther=soe.Outputs;
                    soe_OutputsDs=[];
                end

                if(~isempty(soe_OutputsOther)||~isempty(soe_OutputsDs))
                    outtime={};
                    outdata={};
                    noNameSigCnt=0;
                    index=0;
                    numGrps=0;

                    for i=1:length(soe_OutputsOther)

                        IthRow=soe_OutputsOther(i);
                        sampleDim=soe_OutputsOther(i).SampleDims;
                        if(sampleDim==1)
                            index=index+1;
                            outtime{1}{index,:}=IthRow.TimeValues';
                            outdata{1}{index,:}=IthRow.DataValues';
                            if isempty(IthRow.SignalLabel)
                                noNameSigCnt=noNameSigCnt+1;
                                sigNames{1}{index,:}=['Imported_Signal ',num2str(noNameSigCnt)];
                            else
                                sigNames{1}{index,:}=IthRow.SignalLabel;
                            end
                        else
                            flattendOutput=Simulink.sdi.internal.SimOutputLower.lower(soe_OutputsOther(i),2);
                            for j=1:sampleDim
                                index=index+1;
                                outtime{1}{index,:}=flattendOutput(j).TimeValues';
                                outdata{1}{index,:}=flattendOutput(j).DataValues.Data';
                                if isempty(flattendOutput(j).SignalLabel)
                                    noNameSigCnt=noNameSigCnt+1;
                                    sigNames{1}{index,:}=['Imported_Signal ',num2str(noNameSigCnt)];
                                else
                                    sigNames{1}{index,:}=flattendOutput(j).SignalLabel;
                                end
                            end
                        end
                    end

                    if~isempty(soe_OutputsOther)
                        index=0;
                        numGrps=1;
                        grpNames{numGrps}=[];
                    end

                    for m=1:numel(dsVarNames)
                        numGrps=numGrps+1;

                        grpNames{numGrps}=varValues{m}.Name;%#ok<AGROW>


                        soe_Outputs=soe_OutputsDs(idxSigDs(m,:));

                        for i=1:length(soe_Outputs)

                            IthRow=soe_Outputs(i);
                            sampleDim=soe_Outputs(i).SampleDims;
                            if(sampleDim==1)
                                index=index+1;
                                outtime{numGrps}{index,:}=IthRow.TimeValues';%#ok<AGROW>
                                outdata{numGrps}{index,:}=IthRow.DataValues';%#ok<AGROW>
                                if isempty(IthRow.SignalLabel)
                                    noNameSigCnt=noNameSigCnt+1;
                                    sigNames{numGrps}{index,:}=['Imported_Signal ',num2str(noNameSigCnt)];%#ok<AGROW>
                                else
                                    sigNames{numGrps}{index,:}=IthRow.SignalLabel;%#ok<AGROW>
                                end
                            else
                                flattendOutput=Simulink.sdi.internal.SimOutputLower.lower(soe_Outputs(i),2);
                                for j=1:sampleDim
                                    index=index+1;
                                    outtime{numGrps}{index,:}=flattendOutput(j).TimeValues';%#ok<AGROW>
                                    outdata{numGrps}{index,:}=flattendOutput(j).DataValues.Data';%#ok<AGROW>
                                    if isempty(flattendOutput(j).SignalLabel)
                                        noNameSigCnt=noNameSigCnt+1;
                                        sigNames{numGrps}{index,:}=['Imported_Signal ',num2str(noNameSigCnt)];%#ok<AGROW>
                                    else
                                        sigNames{numGrps}{index,:}=flattendOutput(j).SignalLabel;%#ok<AGROW>
                                    end
                                end
                            end
                        end
                        index=0;
                    end

                    grpNamesString=sprintf('   %s\n',grpNames{:});
                    this.StatusMessage=DAStudio.message('Sigbldr:import:MATDataFileInfoGroups',...
                    shortName,numGrps,grpNamesString);

                    for iii=1:numGrps
                        sigNamesString=sprintf('   %s\n',sigNames{iii}{:});
                        numSigs=numel(sigNames{iii});
                        this.StatusMessage=[this.StatusMessage,DAStudio.message(...
                        'Sigbldr:import:MATDataFileInfoSignalNamesPerGroup',...
                        iii,sprintf('   %s\n',grpNames{iii}),numSigs,sigNamesString)];
                    end

                else
                    dataStruct=load(fullPathName);
                    paramNames=fieldnames(dataStruct);



                    if length(paramNames)>=2
                        if~any(ismember(paramNames,'time'))
                            DAStudio.error('Sigbldr:import:MATDataUndefinedTimeDataParam',premsg,'time');
                        end
                        if~any(ismember(paramNames,'data'))
                            DAStudio.error('Sigbldr:import:MATDataUndefinedTimeDataParam',premsg,'data');
                        end






                        outtime=dataStruct.time;
                        if(~iscell(outtime)&&~isnumeric(outtime))||iscellstr(outtime)
                            DAStudio.error('Sigbldr:import:MATDataEmptyTimeDataParam',premsg,'time');
                        end
                        outdata=dataStruct.data;
                        if(~iscell(outdata)&&~isnumeric(outdata))||iscellstr(outdata)
                            DAStudio.error('Sigbldr:import:MATDataEmptyTimeDataParam',premsg,'data');
                        end

                        hasGroupNames=false;
                        if any(ismember(paramNames,'grpNames'))
                            grpNames=dataStruct.grpNames;
                            hasGroupNames=true;
                            if~iscell(grpNames)
                                grpNames={grpNames};
                            end
                            grpNamesString=sprintf('   %s\n',grpNames{:});
                        end

                        if any(ismember(paramNames,'sigNames'))
                            sigNames=dataStruct.sigNames;
                            if~iscell(sigNames)
                                sigNames={sigNames};
                            end
                            sigNamesString=sprintf('   %s\n',sigNames{:});

                            if(hasGroupNames)
                                this.StatusMessage=DAStudio.message('Sigbldr:import:MATDataFileInfoWithSignalNamesWithGroupNames',...
                                shortName,size(outdata,2),grpNamesString,size(outdata,1),sigNamesString);
                            else
                                this.StatusMessage=DAStudio.message('Sigbldr:import:MATDataFileInfoWithSignalNamesNoGroupNames',...
                                shortName,size(outdata,2),size(outdata,1),sigNamesString);
                            end
                        else
                            if(hasGroupNames)
                                this.StatusMessage=DAStudio.message('Sigbldr:import:MATDataFileInfoNoSignalNamesWithGroupNames',...
                                shortName,size(outdata,2),grpNamesString,size(outdata,1));
                            else
                                this.StatusMessage=DAStudio.message('Sigbldr:import:MATDataFileInfoNoSignalNamesNoGroupNames',...
                                shortName,size(outdata,2),size(outdata,1));
                            end
                        end
                    end
                end

            catch ME
                ME.throw();
            end
        end



        function[status,msg]=converttoSBObj(this,intime,indata,grpNames,sigNames)

            if~iscellstr(sigNames)

                numGrp=numel(grpNames);
                sigSuiteObj=SigSuite();
                try
                    for j=numGrp:-1:1
                        sigSuiteObj.Groups(j)=SigSuiteGroup(intime{j},indata{j},sigNames{j},grpNames(:,j));
                        msg='';
                        status=true;
                    end
                    this.GroupSignalData=sigSuiteObj;
                catch ME
                    msg=ME.message;
                    status=false;
                end
            else

                try
                    this.GroupSignalData=SigSuite(intime,indata,sigNames,grpNames);
                    msg='';
                    status=true;

                catch ME
                    msg=ME.message;
                    status=false;
                end
            end
        end



        function[status,msg]=setGroupSignalData(this,intime,indata,sigNames,grpNames)
            if~iscellstr(sigNames)

                numGrp=numel(grpNames);
                for j=numGrp:-1:1
                    [sigNames{j},grpNames(:,j)]=sigbldr.extdata.SBImportData.updateGroupSignalNames(size(indata{j},1),size(indata{j},2),sigNames{j},grpNames(:,j));
                end
                [status,msg]=converttoSBObj(this,intime,indata,grpNames,sigNames);
            else

                [sigNames,grpNames]=sigbldr.extdata.SBImportData.updateGroupSignalNames(size(indata,1),size(indata,2),sigNames,grpNames);
                [status,msg]=converttoSBObj(this,intime,indata,grpNames,sigNames);
            end
        end
    end

end



