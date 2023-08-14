function InputParameters=getInputParameters(this,varargin)








    if nargin==1
        if~isempty(this.ActiveCheck)
            InputParameters=this.ActiveCheck.getInputParameters;
        end
    elseif nargin==2
        if iscell(varargin{1})
            checkID=varargin{1}{1};
        else
            checkID=varargin{1};
        end
        checkObj=this.getCheckObj(checkID);
        if~isempty(checkObj)
            InputParameters=checkObj.getInputParameters;
        else

            DAStudio.error('Simulink:tools:MAIncorrectAPIUsage','getInputParameters');
        end
    else
        DAStudio.error('Simulink:tools:MAIncorrectAPIUsage','getInputParameters');
    end
