function[fullfilename]=browseForFile(isForReading,varargin)








    if nargin==1
        titleString=getString(message('MATLAB:uistring:uiopen:DialogOpen'));
    else
        titleString=varargin{1};
    end


    if isForReading

        [filename,pathname]=uigetfile(...
        {'*.mat; *.xls; *.xlsx',getString(message('sl_sta:sta:AllImportExportFiles'));...
        '*.mat',getString(message('MATLAB:uistring:uiopen:MATfiles'));...
        '*.xls; *.xlsx',getString(message('sl_sta:sta:ExcelFiles'))},...
        titleString);
    else

        fileAsDefault=[];

        if nargin==3
            sigIds=varargin{2};
            repoUtil=starepository.RepositoryUtility();
            for k=1:length(sigIds)
                lastKnown=repoUtil.getMetaDataByName(sigIds{k}.id,'LastKnownFullFile');

                if~isempty(lastKnown)&&~strcmp(lastKnown,getString(message('sl_iofile:matfile:BaseWorkspace')))
                    fileAsDefault=lastKnown;
                    break;
                end
            end
        end


        if isempty(fileAsDefault)

            [filename,pathname]=uiputfile(...
            {'*.mat; *.xls; *.xlsx',getString(message('sl_sta:sta:AllImportExportFiles'));...
            '*.mat',getString(message('MATLAB:uistring:uiopen:MATfiles'));...
            '*.xls; *.xlsx',getString(message('sl_sta:sta:ExcelFiles'))},...
            titleString);
        else

            [filename,pathname]=uiputfile(...
            {'*.mat; *.xls; *.xlsx',getString(message('sl_sta:sta:AllImportExportFiles'));...
            '*.mat',getString(message('MATLAB:uistring:uiopen:MATfiles'));...
            '*.xls; *.xlsx',getString(message('sl_sta:sta:ExcelFiles'))},...
            titleString,...
            fileAsDefault);
        end
    end
    fullfilename='';


    if(filename~=0)
        fullfilename=fullfile(pathname,filename);
    end



end

