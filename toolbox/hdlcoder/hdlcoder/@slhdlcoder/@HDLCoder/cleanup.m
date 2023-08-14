function cleanup(this,varargin)




    if nargin>4





        hs.oldDriver=varargin{1};
        hs.oldMode=varargin{2};
        hs.oldAutosaveState=varargin{3};
        codegenstatus=varargin{4};
        if nargin>6
            closeconnection=varargin{5};
        else
            closeconnection=true;
        end
    else



        hs=varargin{1};
        codegenstatus=varargin{2};
        if nargin==4
            closeconnection=varargin{3};
        else
            closeconnection=true;
        end
    end

    if closeconnection


        this.closeConnection;



        numModels=numel(this.AllModels);
        for mdlIdx=1:numModels-1

            if isfield(this.AllModels(mdlIdx),'slFrontEnd')&&...
                ~isempty(this.AllModels(mdlIdx).slFrontEnd)
                this.AllModels(mdlIdx).slFrontEnd.SimulinkConnection.termModel;
                this.AllModels(mdlIdx).slFrontEnd.SimulinkConnection.restoreParams;
            end
        end
    end

    this.baseCleanup(hs);


    if closeconnection


        hdlresetgcb(this.OrigStartNodeName);
        this.cleanupModelRef;
    end


    this.TimeStamp=datestr(now,31);
    this.CodeGenSuccessful=codegenstatus;
    this.LastTargetLanguage=this.getParameter('target_language');
    this.LastStartNodeName=this.OrigStartNodeName;
end


