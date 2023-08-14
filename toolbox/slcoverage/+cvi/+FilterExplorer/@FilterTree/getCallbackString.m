function res=getCallbackString(command,filterExplorerUUID,varargin)




    res=['cvi.FilterExplorer.FilterTree.',command,'(''',filterExplorerUUID,''''];
    for idx=1:numel(varargin)
        res=[res,',',varargin{1}];%#ok<AGROW>
    end
    res=[res,');'];
end