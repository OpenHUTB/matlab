function retVal=convertStoredIntegerToRealWorldValue(obj,propVal,varargin)


    if(nargin==2)
        context=[];
    else
        context=varargin{1};
    end
    dtObj=Simulink.data.getDataTypeObjIfFixpt(obj,varargin{:});
    SIValue=num2str(Simulink.data.evaluateExpressionInContext(propVal,context));



    fiObj=fi(0,dtObj);


    fiObjNoScaling=stripscaling(fiObj);


    fiObjNoScaling.Value=SIValue;
    fiObjWithRWValue=reinterpretcast(fiObjNoScaling,fiObj.numerictype);
    retVal=fiObjWithRWValue.Value;
end