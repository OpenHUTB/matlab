function out=enhancedMCDCOpts(varargin)











    persistent Config;
    mlock;

    if isempty(Config)
        Config=default_opts();
    end

    if nargin>=1
        method=varargin{1};
        switch(lower(method))
        case 'get'
            if nargin==2
                param=varargin{2};


                out=Config.(param);
            else
                error('No field name specified for ''get'' ')
            end
            return;

        case 'set'
            if nargin>=2
                param=varargin{2};
                val=varargin{3};
                Config.(param)=val;
                out=user_visible_opts(Config);
            else
                error('No field name, value specified for ''set'' ')
            end
            return;

        case 'all'
            out=Config;
            return;

        case 'default'
            Config=default_opts();
            out=user_visible_opts(Config);
            return;
        case 'setpathoptions'
            if nargin>=2
                val=varargin{2};
                Config=setPathOptions(Config,val);
            else
                error('No profileLevel set');
            end
            out=user_visible_opts(Config);
        end
    else
        out=user_visible_opts(Config);
    end
end

function userconfig=user_visible_opts(~)
    userconfig=[];
end

function config=default_opts()



    config.MaxPathLengthPerSrc=-1;
    config.MaxPathsPerSrc=-1;






    config.generatePathInfoData=false;





    config.AllBlocksInspection=true;


    config.InspectionBlkList={};


    config.AllowPassThrough=true;


    config.StartBlocks={};


    config.ResetBlocks={};


    config.MaxUnitDelayLength=0;


    config.ExpandAtomicSubsystems=false;


    config.BlocksToAnalyze={};













    config.ObservableBlocks={};

end



function newConfig=setPathOptions(oldConfig,pathOptsLevel)
    newConfig=oldConfig;


    if strcmp(pathOptsLevel,'SinglePath')
        newConfig.MaxPathsPerSrc=1;



    elseif strcmp(pathOptsLevel,'ConstrainedPath')
        newConfig.MaxPathLengthPerSrc=10;
        newConfig.MaxPathsPerSrc=5;

    elseif strcmp(pathOptsLevel,'default')
        newConfig.MaxPathLengthPerSrc=-1;
        newConfig.MaxPathsPerSrc=-1;
    end
end