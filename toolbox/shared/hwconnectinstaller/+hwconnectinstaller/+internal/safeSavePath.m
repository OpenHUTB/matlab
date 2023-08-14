function varargout=safeSavePath(varargin)














    if hwconnectinstaller.internal.isSandboxEnvironment


        nl=sprintf('\n');
        msg=[...
        'SAVEPATH is disabled for Support Package Installer since ',nl...
        ,'this MATLAB is running in a sandbox environment. If you wish to ',nl...
        ,'save your MATLAB path, manually invoke SAVEPATH from the MATLAB',nl...
        ,'command line.'...
        ];
        warning('hwconnectinstaller:savepath:DisallowedSavePath',msg);
        if nargout>0

            varargout{1}=2;
        end
    else
        [varargout{1:nargout}]=savepath(varargin{:});
    end
