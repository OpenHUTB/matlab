function refreshBaseWSWithModelWS(varargin)








    if nargin==0

        modelHandle=bdroot;
    elseif nargin==1
        modelHandle=varargin{1};
    end
    mws=get_param(modelHandle,'ModelWorkspace');

    requiredMWSElements=["SymbolTime","SampleInterval","RowSize","Aggressors","Modulation","ChannelImpulse"];
    variableList=whos(mws);
    for i=1:size(variableList,1)
        currentName=variableList(i).name;
        if endsWith(currentName,'Parameter')||any(contains(requiredMWSElements,currentName))
            currentVariable=mws.getVariable(variableList(i).name);
            assignin('caller',currentName,currentVariable.Value);
        end
    end
end