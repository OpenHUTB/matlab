function retVal=convertRealWorldToStoredIntegerValue(obj,propName,varargin)


    dtObj=Simulink.data.getDataTypeObjIfFixpt(obj,varargin{:});
    if isempty(dtObj)
        retVal='';
    else
        if~isempty(strfind(propName,'.'))
            propName=extractAfter(propName,'.');
        end

        assert(Simulink.data.isStoredIntProperty(propName));

        propName=extractAfter(propName,'StoredInt');
        if(nargin==4)
            obj=obj.(varargin{2});
        end
        propValue=obj.(propName);
        if isempty(propValue)
            retVal=getPropValue(obj,propName);
        else
            fiObjWithRWValue=fi(obj.(propName),dtObj);
            fiObjNoScaling=stripscaling(fiObjWithRWValue);
            retVal=fiObjNoScaling.Value;
        end
    end
end