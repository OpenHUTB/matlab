function[fullfilename]=browseForFile(isForReading,varargin)





    titleString=message('sl_web_widgets:customfiledialog:dialogTitle').getString;


    if isForReading

        [filename,pathname]=uigetfile(...
        {'*.*',message('MATLAB:uistring:uiopen:AllFiles').getString},...
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

