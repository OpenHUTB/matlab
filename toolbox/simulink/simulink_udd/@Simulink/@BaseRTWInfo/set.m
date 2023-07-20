function retVal=set(obj,varargin)











    switch nargin
    case 2

        propName=varargin{1};


        if~isvarname(propName)
            DAStudio.error('MATLAB:class:InvalidArgument',mfilename,mfilename);
        end


        switch propName
        case 'StorageClass'
            builtinSCs=coder.internal.getBuiltinStorageClasses;
            retVal=[builtinSCs;{'Custom'}];
        case{'CustomStorageClass','UnifiedStorageClass'}
            retVal=getPropAllowedValues(obj,propName);
        otherwise

            if ismember(propName,l_GetPropNames(obj))
                retVal={};
            else
                DAStudio.error('MATLAB:ClassUstring:setgetPropertyNotFound',...
                propName,class(obj),class(obj));
            end
        end

    case 1


        propNames=l_GetPropNames(obj);
        for idx=1:length(propNames)
            propName=propNames{idx};
            retVal.(propName)=set(obj,propName);
        end

    otherwise







        if(mod(nargin,2)==0)

            DAStudio.error('MATLAB:class:BadParamValuePairs');
        end


        for idx=1:2:(nargin-1)
            propName=varargin{idx};
            propValue=varargin{idx+1};
            obj.(propName)=propValue;
        end
    end
end




function propNames=l_GetPropNames(obj)
    props=Simulink.data.getPropList(obj,...
    'SetAccess','public',...
    'Hidden',false);
    props=props.get;
    propNames={props.Name}';
end


