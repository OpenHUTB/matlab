function[fullfilename]=uiGetFile(varargin)




    titleString=getString(message('MATLAB:uistring:uiopen:DialogOpen'));
    fileExtension={'*.mat',getString(message('MATLAB:uistring:uiopen:MATfiles'))};

    if nargin>0
        fileExtension={varargin{1}{1},varargin{1}{2}};
    end

    if nargin>1
        titleString=varargin{2};
    end

    [filename,pathname]=uigetfile(fileExtension,titleString);

    fullfilename='';


    if(filename~=0)
        fullfilename=fullfile(pathname,filename);
    end
