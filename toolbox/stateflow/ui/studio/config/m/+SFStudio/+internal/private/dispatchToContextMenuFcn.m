
function dispatchToContextMenuFcn(cbInfo,func,varargin)
    subviewerId=SFStudio.Utils.getSubviewerId(cbInfo);
    Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,...
    'evalContextMenuFunctions',horzcat({func},varargin),false);
end