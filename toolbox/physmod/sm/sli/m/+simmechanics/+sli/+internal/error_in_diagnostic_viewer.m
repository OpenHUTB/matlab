function error_in_diagnostic_viewer(hSl,stageDesc,varargin)













    pm_assert((nargin==3)||(nargin==4));

    excps=MSLException.empty();

    if nargin==3
        excps=varargin{1};
        pm_assert(isa(excps,'MSLException'));
    else
        msgIds=varargin{1};
        msgs=varargin{2};
        pm_assert(iscellstr(msgIds)&&iscellstr(msgs)||...
        ischar(msgIds)&&ischar(msgs));

        if iscell(msgIds)
            assert(isvector(msgIds)&&isvector(msgs));
            assert(length(msgIds)==length(msgs));
            for idx=1:length(msgIds)
                excps(end+1)=MSLException(hSl,msgIds{idx},'%s',msgs{idx});
            end
        else
            excps=MSLException(hSl,msgIds,'%s',msgs);
        end
    end

    stage=Simulink.output.Stage(stageDesc,...
    'ModelName',get_param(bdroot(hSl),'Name'),...
    'UIMode',true);

    for idx=1:length(excps)
        Simulink.output.error(excps(idx),'Component',...
        pm_message('sm:sli:ApplicationName'));
    end
