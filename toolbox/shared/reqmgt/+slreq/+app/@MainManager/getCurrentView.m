function obj=getCurrentView(this,varargin)










    obj=[];
    if nargin==1

        if~isempty(this.lastOperatedView)
            obj=this.lastOperatedView;

        end
        return;
    else
        modelH=get_param(bdroot(varargin{1}),'Handle');
    end

    if~isempty(this.spreadsheetManager)
        obj=this.getCurrentSpreadSheetObject(modelH);
        if isempty(obj)
            if isempty(obj)

                obj=this.requirementsEditor;
            end
        end
    end
end
