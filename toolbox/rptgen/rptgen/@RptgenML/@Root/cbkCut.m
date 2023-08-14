function actionPerformed=cbkCut(this,justTesting,varargin)




    actionPerformed=false;
    if~isa(this.Editor,'DAStudio.Explorer')
        return;
    end

    if nargin<2
        justTesting=false;
        varargin={};
    end

    try
        actionPerformed=cbkCopy(this,justTesting,varargin{:});
    catch ME
        warning(ME.message);
        actionPerformed=false;
    end

    if actionPerformed
        try
            actionPerformed=cbkDelete(this,justTesting,varargin{:});
        catch ME
            warning(ME.message);
            actionPerformed=false;
        end
    end
