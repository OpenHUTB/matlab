function uname=user(varargin)













    persistent doPrompt
    if isempty(doPrompt)
        doPrompt=true;
    end

    if nargin<1
        uname=rmipref('OslcServerUser');

    elseif isempty(varargin{1})
        doPrompt=true;
        if nargout==0
            return;
        else
            uname=rmipref('OslcServerUser');
        end

    else
        uname=varargin{1};
        doPrompt=(nargin==2&&strcmp(varargin{2},'prompt'));
    end

    if doPrompt||isempty(uname)
        result=uiPrompt(uname);
        if isempty(result)



            error(message('Slvnv:oslc:UserNameNotEntered'));
        else
            uname=result{1};
            doPrompt=false;
        end
    end


    rmipref('OslcServerUser',uname);
end

function uname=uiPrompt(uname)
    if isempty(uname)
        if ispc
            uname=getenv('USERNAME');
        else
            uname=getenv('USER');
        end
    end
    prompt=getString(message('Slvnv:oslc:PromptServerUsername'));
    name=getString(message('Slvnv:oslc:PromptServerUsernameTitle'));
    uname=inputdlg(prompt,name,1,{uname});
end

