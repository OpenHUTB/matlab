function removePathNoWarning(varargin)





    drawnow;

    id='MATLAB:rmpath:DirNotFound';
    s=warning('off',id);
    cleanUpHanlde=onCleanup(@()warning(s));
    rmpath(varargin{:});
end
