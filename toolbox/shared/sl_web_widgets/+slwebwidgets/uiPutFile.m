function[fullfilename]=uiPutFile(varargin)




    titleString=getString(message('sl_sta_general:common:saveas'));
    fileExtension={'*.mat',getString(message('MATLAB:uistring:uiopen:MATfiles'))};

    if nargin<1
        [filename,pathname]=uiputfile(fileExtension,titleString);
    else
        if nargin==1
            fileExtension={varargin{1}{1},varargin{1}{2}};
            [filename,pathname]=uiputfile(fileExtension,titleString);
        elseif nargin==2
            fileExtension={varargin{1}{1},varargin{1}{2}};
            titleString=varargin{2};
            [filename,pathname]=uiputfile(fileExtension,titleString);
        elseif nargin==3
            fileExtension={varargin{1}{1},varargin{1}{2}};
            titleString=varargin{2};
            fileAsDefault=varargin{3};
            [filename,pathname]=uiputfile(fileExtension,titleString,fileAsDefault);
        end

    end

    fullfilename='';


    if(filename~=0)
        fullfilename=fullfile(pathname,filename);
    end
