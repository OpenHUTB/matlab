function addPathNoException(varargin)




    drawnow;

    try
        addpath(varargin{1:end-1},'-begin');
    catch
        matlabpath([char(varargin{end}),matlabpath]);
    end

end

