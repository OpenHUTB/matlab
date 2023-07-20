function[fullfilename]=browseForSnapShot(varargin)




    titleString=varargin{1};

    [filename,pathname]=uiputfile(...
    {'*.bmp';...
    '*.jpeg';...
    '*.png'},...
    titleString);

    fullfilename='';


    if(filename~=0)
        fullfilename=fullfile(pathname,filename);
    end
