
function printRepositoryQueryLog(this,filename,varargin)

    warnAddSheet=warning('off','MATLAB:xlswrite:AddSheet');

    if nargin>2
        filename=fullfile(varargin{1},filename);
    else
        filename=fullfile(pwd,filename);
    end

    if exist(filename,'file')
        fprintf('\nOverwriting ''%s''\n',filename);
        delete(filename);
    end

    xlsPrintCells=this.sigRepository.getQueryLog();

    try

        fprintf('\nWriting tracer data from main thread...');
        xlswrite(filename,xlsPrintCells.MainThreadLog,'MainThread');


        fprintf('\nWriting tracer data from all threads...\n');
        xlswrite(filename,xlsPrintCells.AllThreadsLog,'AllThreads');
    catch me %#ok<NASGU>
        [direc,~]=fileparts(filename);
        fprintf('\n\nWRITE FAILURE: Do you have write permissions in directory ''%s''?\n\n',direc);
        return;
    end


    warning(warnAddSheet.state,warnAddSheet.identifier);


    fprintf('\nSUCCESS: Query log written to ''%s''\n\n',filename);
end