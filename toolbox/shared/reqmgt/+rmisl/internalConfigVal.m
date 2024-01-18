function out=internalConfigVal(name,value)

    out=[];
    prefD=prefdir;

    if~exist(prefD,'dir')
        return;
    end
    configMatFile=fullfile(prefD,'slreq_config.mat');

    if exist(configMatFile,'file')
        if nargin<1
            out=configMatFile;
        else
            try
                allVals=load(configMatFile);
            catch Mx
                allVals=[];
            end
        end
    else
        allVals=[];
    end

    if nargin<1
        return;
    end
    if~isempty(allVals)&&isstruct(allVals)&&isfield(allVals,name)
        out=allVals.(name);
    end

    if nargin>1
        allVals.(name)=value;

        try
            save(configMatFile,'-struct','allVals');
        catch Mx
        end
    end
end
