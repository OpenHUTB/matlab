function cellOut=ParseArgs(mode,varargin)
    filename='';
    if((~mod(numel(varargin),2))&&numel(varargin)<5)
        for i=1:2:numel(varargin)
            if(strcmpi(varargin{i},'Mode'))
                if(strcmpi(varargin{i+1},'MTree'))
                    mode='MTree';
                elseif(strcmpi(varargin{i+1},'Capture'))
                    mode='Capture';
                else
                    warning('Invalid value entered for parameter Mode. Using the default "Capture" Mode.');
                    mode='Capture';
                end
            elseif(strcmpi(varargin{i},'FileName'))
                filename=varargin{i+1};
            else
                warning(['Invalid parameter name entered. Skipping this parameter: ',varargin{i}]);
            end
        end
    else
        warning('Invalid number of parameters entered.');
    end
    cellOut={mode,filename};
end