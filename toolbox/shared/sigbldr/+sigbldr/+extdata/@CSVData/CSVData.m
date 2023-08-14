



classdef CSVData<sigbldr.extdata.SBImportData



    methods
        function this=CSVData(fullPathName)
            sigbldr.extdata.SBImportData.verifyFileName(fullPathName);

            this.StatusMessage='';
            this.GroupSignalData=[];
            try
                [localtime,localdata,sigNames,grpNames]=this.readFile(fullPathName);
                this.Type='CSV';
            catch ME
                ME.throw();
            end
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

            sigNames={};
            grpNames={};
            try



                allData=dlmread(fullPathName);
                outtime=allData(:,1);
                outdata=allData(:,2:end);
            catch ME

                DAStudio.error('Sigbldr:import:CSVFileReadError');

            end
            this.StatusMessage=DAStudio.message('Sigbldr:import:CVSDataFileInfoNoSignalNames',...
            shortName,size(outdata,2));
        end



        function[status,msg]=converttoSBObj(this,intime,indata,grpNames,sigNames)

            sigCnt=length(sigNames);

            data=cell(sigCnt,1);
            time{1,1}=intime';
            for sidx=1:sigCnt
                data{sidx,1}=indata(:,sidx)';
            end
            try
                this.GroupSignalData=SigSuite(time,data,sigNames,grpNames);
                msg='';
                status=true;
            catch ME
                msg=ME.message;
                status=false;
            end
        end



        function[status,msg]=setGroupSignalData(this,intime,indata,sigNames,grpNames)
            [sigNames,grpNames]=sigbldr.extdata.SBImportData.updateGroupSignalNames(size(indata,2),1,sigNames,grpNames);
            [status,msg]=converttoSBObj(this,intime,indata,grpNames,sigNames);
        end

    end

end
