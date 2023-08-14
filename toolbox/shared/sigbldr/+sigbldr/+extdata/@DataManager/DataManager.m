


classdef DataManager



    properties(SetAccess='private',GetAccess='private')
        FullFileName=[];
    end

    properties(SetAccess='private',Hidden=true)
        AllowCustom=false;
        parentH=[];
    end

    properties(SetAccess='protected',GetAccess='protected')
        ImportData=[];
    end

    properties
        StatusMessage=[];
    end



    methods

        function this=DataManager(newFullFileName,varargin)
            this.FullFileName=newFullFileName;
            if(nargin==2)
                this.parentH=varargin{1};
            end






            [~,~,fileExt]=fileparts(newFullFileName);
            try
                sigbldr.extdata.SBImportData.verifyFileName(newFullFileName);
                switch(lower(fileExt))
                case{'.xls','.xlsx'}
                    this.ImportData=sigbldr.extdata.ExcelData(newFullFileName,varargin{:});
                case '.mat'
                    this.ImportData=sigbldr.extdata.MATData(newFullFileName);
                case '.csv'
                    this.ImportData=sigbldr.extdata.CSVData(newFullFileName);
                otherwise

                    if(this.AllowCustom)
                        this=processCustomFile(this,newFullFileName);
                    else
                        DAStudio.error('Sigbldr:import:noSupportForCustomFile',newFullFileName);
                    end
                end
                this.StatusMessage=this.ImportData.StatusMessage;
            catch ME
                if(this.AllowCustom)
                    supported=false;
                    notFound=true;
                    i=0;
                    Max=length(sigbldr.extdata.SBImportData.SUPPORTED_TYPES);
                    while(notFound&&i<Max)
                        i=i+1;
                        if strfind(ME.identifier,...
                            cell2mat(sigbldr.extdata.SBImportData.SUPPORTED_TYPES(i)))
                            supported=true;
                            notFound=false;
                        end
                    end
                    if(supported)


                        try
                            this=processCustomFile(this,newFullFileName);
                        catch E

                            sigbldr.ui.progressBar('destroy');
                            E.throw();
                        end
                    else

                        sigbldr.ui.progressBar('destroy');
                        ME.throw();
                    end
                else


                    ME.throw();
                end
            end
        end

    end

    methods(Hidden=true)
        function this=processCustomFile(this,newFullFileName)
            sigbldr.ui.progressBar('create',[],this.parentH);
            sigbldr.ui.progressBar('update',DAStudio.message('Sigbldr:import:PBCustomFileSearch'));
            reader=[];
            if ispref('SignalBuilder','CustomReader')
                reader=getpref('SignalBuilder','CustomReader');
                if~iscell(reader)
                    reader={reader};
                end
            end
            instance=length(reader);
            if(instance>0)
                sigbldr.ui.progressBar('update',DAStudio.message('Sigbldr:import:PBCustomFileFound',instance));
            else
                DAStudio.error('Sigbldr:import:noCustomFileReader',newFullFileName);
            end
            found=false;
            count=0;
            while(~found&&count<instance)
                sigbldr.ui.progressBar('update',DAStudio.message('Sigbldr:import:PBCustomFileTrying',count+1));
                try
                    count=count+1;



                    if(exist(reader{count},'file'))
                        [~,fileReaderName,ext]=fileparts(reader{count});
                        if~isempty(ext)
                            if strcmp(ext,'.m')==1
                                fileReader=fileReaderName;
                            else
                                DAStudio.error('Sigbldr:import:UnsupportedCustomFileReader');
                            end
                        else
                            fileReader=reader{count};
                        end
                    else



                        DAStudio.error('Sigbldr:sigbldr:invalidFile',reader{count});
                    end

                    this.ImportData=feval(fileReader,newFullFileName);
                    found=true;
                    sigbldr.ui.progressBar('destroy');
                catch ME
                    if strcmp(ME.identifier,'Sigbldr:sigbldr:invalidFile')==1||...
                        strcmp(ME.identifier,'Sigbldr:import:UnsupportedCustomFileReader')==1
                        msg=ME.message;
                    else
                        msg=DAStudio.message('Sigbldr:import:PBCustomFileTryingFailed',count);
                    end
                    sigbldr.ui.progressBar('update',msg,this.parentH);
                end
            end
            if(~found)
                DAStudio.error('Sigbldr:import:noCustomFileReader',newFullFileName);
            end
        end
    end


    methods



        function[dataObj]=getImportData(this)
            [dataObj]=this.ImportData;
        end



        function[dataObj]=getFileName(this)
            [dataObj]=this.FullFileName;
        end



        function[status]=getStatusMessage(this)
            status=this.StatusMessage;
        end
    end
end

