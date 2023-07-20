function slParams=make_params(pname,pval,varargin)
























    slParams(1)=pm.sli.MaskParameter;
    slParams(1).VarName=pname;
    slParams(1).Value=pval;
    slParams(1).Evaluate=true;
    slParams(1).RuntimeConfigurable=false;

    if(nargin>=4)

        slParams(end+1)=pm.sli.MaskParameter;
        slParams(end).VarName=varargin{1};
        slParams(end).Value=varargin{2};
        slParams(end).Evaluate=false;
        slParams(end).RuntimeConfigurable=false;
    end

    rtp=false;
    if((nargin==3||nargin==5)&&islogical(varargin{end}))
        rtp=varargin{end};
    end

    if rtp

        slParams(1).RuntimeConfigurable=true;
        slParams(1).Tunable=true;
        slParams(end+1)=pm.sli.MaskParameter;
        slParams(end).VarName=[pname,pm_message(fullId('Suffix'))];
        slParams(end).Value=pm_message(fullId('CompileTime'));
        slParams(end).Evaluate=false;
    end

end

function fullMsgId=fullId(msgId)
    fullMsgId=['mech2:messages:parameters:common:rtp:',msgId];
end


