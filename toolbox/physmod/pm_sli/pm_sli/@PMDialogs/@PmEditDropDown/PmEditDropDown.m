function hObj=PmEditDropDown(varargin)
























    hObj=PMDialogs.PmEditDropDown;
    hObj.CreateInstanceFcn=PMDialogs.PmCreateInstance;

    if((nargin<4)||(nargin>9))
        error('Wrong number of input arguments (need 4 or 8 arguments)');
    end

    if(ishandle(varargin{1}))
        hObj.BlockHandle=varargin{1};
    else
        error('Expecting handle for first argument.');
    end



    hObj.Label=varargin{2};
    hObj.ValueBlkParam=varargin{3};
    if~iscellstr(varargin{4})
        error('Expecting cellstr for the fourth argument.');
    end
    hObj.Choices=lValidateVectorVals(varargin{4},'Choices');
    hObj.LabelAttrb=0;
    hObj.Value='';

    if((nargin>4)&&isnumeric(varargin{5})&&(varargin{5}>=0&&varargin{5}<4))
        hObj.LabelAttrb=int32(varargin{5});
    end

    if(nargin>5)
        hObj.Value=varargin{6};
    end

    if(nargin>6)
        if~isempty(varargin{7})
            if(numel(hObj.Choices)==numel(varargin{7}))
                hObj.ChoiceVals=lValidateVectorVals(varargin{7},'ChoiceVals');
            else
                error('PmEditDropDown:PmEditDropDown:BadChoiceArray',...
                'ChoiceVals array must be same size as Choices array.');
            end
        end
    end

    if(nargin>7)
        if(~isempty(varargin{8}))
            if(numel(hObj.Choices)==numel(varargin{8}))
                hObj.MapVals=lValidateVectorVals(varargin{8},'MapVals');
            else
                error('PmEditDropDown:PmEditDropDown:BadMap',['MapVals array '...
                ,'must be same size as Choices array.']);
            end
        end
    end

    hObj.PreApplyFcn='';
    if(nargin>8)
        if~isempty(varargin{9})
            hObj.PreApplyFcn=varargin{9};
        end
    end

    function newVal=lValidateVectorVals(val,argName)



        newVal=val;
        if isempty(val)
            return;
        end

        if~isvector(val)
            error('PmEditDropDown:PmEditDropDown:ExpectVector',...
            'Expected vector (1-D array) for %s array.',argName);
        end
