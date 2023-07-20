function res=getCallbackString(obj,command,varargin)




    res=['cvi.ResultsExplorer.ResultsExplorer.',command,'(''',obj.topModelName,''''];
    for idx=1:numel(varargin)
        res=[res,',',varargin{1}];%#ok<AGROW>
    end
    res=[res,');'];
end