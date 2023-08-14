function varargout=explore(varargin)








    rgRoot=RptgenML.Root;
    inputCount=length(varargin);
    if inputCount==0



        rgRoot.getEditor;
    else

        refreshAction=rgRoot.refreshReportList('-deferred');

        rgRoot.getEditor;

        for i=1:length(varargin)
            varargout{i}=rgRoot.addReport(varargin{i});
        end

        rgRoot.refreshReportList(refreshAction);

    end