function B=set(A,varargin)



























    narginchk(1,3);

    if~isscalar(A)
        error(message('MATLAB:class:ScalarObjectRequired','set'));
    end

    hClass=metaclass(A);






    if nargin==1
        propinfoHandles=Simulink.data.getPropList(A,...
        'SetAccess','public',...
        'Hidden',false);
        propNames={propinfoHandles.Name};

        for i=1:length(propNames)
            propName=propNames{i};

            if strcmpi(getPropDataType(A,propName),'enum')
                propPossibleVal=getPropAllowedValues(A,propName);
                if~isempty(propPossibleVal)
                    S.(propName)=propPossibleVal;
                else
                    S.(propName)={};
                end
            else
                S.(propName)={};
            end
        end
        if nargout==1
            B=S;
        else
            disp(S);
        end






    elseif nargin==2
        propName=varargin{1};

        propName=convertStringsToChars(propName);

        if~ischar(propName)
            error(message('MATLAB:class:BadParamValuePairs'));
        end

        propinfoHandles=hClass.PropertyList;
        propNames={propinfoHandles.Name};

        if ismember(propName,propNames)
            propPossibleVal=getPropAllowedValues(A,propName);

            if nargout==1
                B=propPossibleVal;
            else
                disp(propPossibleVal)
            end
        else
            error(message('MATLAB:noSuchMethodOrField',propName,class(A)));
        end
    else



        error(message('Simulink:DataType:setInvalidUse',class(A)));
    end



