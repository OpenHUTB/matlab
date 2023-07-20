function hObj=PmDropDown(varargin)
























    p=inputParser;
    addRequired(p,'BlockHandle',@ishandle);
    addRequired(p,'Label',@(theLabel)ischar(theLabel)||iscell(theLabel));
    addRequired(p,'ValueBlkParam',@isvarname);
    addRequired(p,'Choices',@iscellstr);
    addOptional(p,'LabelAttrb',0,@isnumeric);
    addOptional(p,'Value','',@ischar);
    addOptional(p,'ChoiceVals',[],@isnumeric);
    addOptional(p,'MapVals',{},@iscell);

    parse(p,varargin{:});

    hObj=PMDialogs.PmDropDown;
    hObj.CreateInstanceFcn=PMDialogs.PmCreateInstance;

    hObj.Label=p.Results.Label;
    hObj.ValueBlkParam=p.Results.ValueBlkParam;
    hObj.Choices=lValidateVectorVals(p.Results.Choices,'Choices');
    hObj.LabelAttrb=int32(p.Results.LabelAttrb);
    hObj.Value=p.Results.Value;
    hObj.ChoiceVals=lValidateVectorVals(p.Results.ChoiceVals,'ChoiceVals');
    hObj.MapVals=lValidateVectorVals(p.Results.MapVals,'MapVals');

    if~isempty(hObj.ChoiceVals)&&~(numel(hObj.Choices)==numel(hObj.ChoiceVals))
        error('PmDropDown:PmDropDown:BadChoiceArray',...
        'ChoiceVals array must be same size as Choices array.');
    end

    if~isempty(hObj.MapVals)&&~(numel(hObj.Choices)==numel(hObj.MapVals))
        error('PmDropDown:PmDropDown:BadMap',...
        'MapVals array must be same size as Choices array.');
    end

end

function newVal=lValidateVectorVals(val,argName)



    newVal=val;
    if isempty(val)
        return;
    end

    if~isvector(val)
        error('PmDropDown:PmDropDown:ExpectVector',...
        'Expected vector (1-D array) for %s array.',argName);
    end
end
