function result=BlockConstraintsFixitCB(varargin)




    result='';
    operation=varargin{1};
    block=varargin{2};
    parameter=varargin{3};
    value=varargin{4};
    switch(operation)
    case{'GT','LEN'}
        if(str2double(value)>str2double(varargin{5}))
            set_param(block,parameter,value);
        else
            error(['Value should be greater than ',varargin{5}]);
        end
    case{'GE','LTN'}
        if(str2double(value)>=str2double(varargin{5}))
            set_param(block,parameter,value);
        else
            error(['Value should be greater than or equal to ',varargin{5}]);
        end
    case{'LT','GEN'}
        if(str2double(value)<str2double(varargin{5}))
            set_param(block,parameter,value);
        else
            error(['Value should be less than ',varargin{5}]);
        end
    case{'LE','GTN'}
        if(str2double(value)<=str2double(varargin{5}))
            set_param(block,parameter,value);
        else
            error(['Value should be less than or equal to ',varargin{5}]);
        end
    case 'EQ'
        if(value==varargin{5})
            set_param(block,parameter,value);
        else
            error(['Value should be set to ',varargin{5}]);
        end
    case 'EQN'
        if(value~=varargin{5})
            set_param(block,parameter,value);
        else
            error(['Value should not be set to ',varargin{5}]);
        end
    case 'EQOR'
        set_param(block,parameter,value);
    case 'RANGE'
        if(str2double(value)>str2double(varargin{5})...
            &&str2double(value)<str2double(varargin{6}))
            set_param(block,parameter,value);
        else
            error(['Value should be set within the range of ',varargin{5},' and ',varargin{6}]);
        end
    case 'RANGEN'
        if(str2double(value)<=str2double(varargin{5})...
            ||str2double(value)>=str2double(varargin{6}))
            set_param(block,parameter,value);
        else
            error(['Value should not be set within the range of ',varargin{5},' and ',varargin{6}]);
        end
    end
end
