function addParameter(this,displayText,blockPath,parameterName)







    controlName=this.getUniqueControlName();



    controlType=this.ParameterControlTypes{1};



    this.createComponentForPropsMap(controlName,controlType);

    param=createParameter(...
    blockPath,...
    parameterName,...
    controlName,...
    controlType,...
    '',...
    '',...
    '',...
    true);



    if isempty(this.BindingData)
        this.BindingData={param};
    else
        this.BindingData{end+1}=param;
    end



    rowdata{this.BindingTableTypeColIdx}='';
    rowdata{this.BindingTableAppDataColIdx}=displayText;
    rowdata{this.BindingTableControlNameColIdx}=this.BindingData{end}.ControlName;
    rowdata{this.BindingTableControlTypeColIdx}=this.BindingData{end}.ControlType;
    this.BindingTable.Data(end+1,:)=rowdata;



    this.refreshStyles();
end

function param=createParameter(varargin)
    if nargin==8
        param.BlockPath=varargin{1};
        param.ParamName=varargin{2};
        param.ControlName=varargin{3};
        param.ControlType=varargin{4};
        param.ConvToComp=varargin{5};
        param.ConvToTarget=varargin{6};
        param.Element=varargin{7};
        param.Valid=varargin{8};
    else
        param=...
        struct(...
        'BlockPath',{},...
        'ParamName',{},...
        'ControlName',{},...
        'ControlType',{},...
        'ConvToComp',{},...
        'ConvToTarget',{},...
        'Element',{},...
        'Valid',{}...
        );
    end
end
