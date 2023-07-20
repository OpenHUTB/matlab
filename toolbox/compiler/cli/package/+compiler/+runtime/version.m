function[varargout]=version()



















    narginchk(0,0);

    versionFile=fullfile(matlabroot,'toolbox','compiler',...
    'mcrversion.ver');

    if~exist(versionFile,'file')
        error(message('Compiler:mcrversion:MissingMCRVersionFile',versionFile));
    end

    versionString=fileread(versionFile);
    v=str2double(split(versionString,'.'));


    versionParts(1:3)=0;


    versionParts(1:length(v))=v;

    if nargout>=0
        varargout{1}=versionParts(1);
    end
    if nargout>1
        varargout{2}=versionParts(2);
    end
    if nargout>2
        varargout{3}=versionParts(3);
    end
    for k=4:nargout
        varargout{k}=0;
    end
end