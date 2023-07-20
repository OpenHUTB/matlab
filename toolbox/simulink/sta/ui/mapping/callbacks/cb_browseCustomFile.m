function[filename,choseFile]=cb_browseCustomFile()

    [filename,~]=uigetfile(...
    {'*.m',getString(message('MATLAB:uistring:uiopen:MATLABFiles'))},...
    getString(message('MATLAB:uistring:uiopen:DialogOpen')));

    choseFile=true;


    if isnumeric(filename)
        filename='';
        choseFile=false;
    end
end