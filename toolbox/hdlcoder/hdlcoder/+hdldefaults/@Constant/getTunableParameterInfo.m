function tunableParameterInfo=getTunableParameterInfo(this,slHandle)%#ok<INUSL>















    tunableParameterInfo=[];


    tunableProp={'Value'};


    rto=get_param(slHandle,'RuntimeObject');


    for ii=1:numel(tunableProp)

        propVal=get_param(slHandle,tunableProp{ii});

        tunableParamName=hdlimplbase.EmlImplBase.getTunableParameter(slHandle,propVal);

        if~isempty(tunableParamName)

            for jj=1:rto.NumRuntimePrms
                if strcmp(rto.RuntimePrm(jj).Name,tunableProp{ii})
                    tunableParam=rto.RuntimePrm(jj).Data;
                    break;
                end
            end

            isComplex=~isreal(tunableParam);

            dims=numel(tunableParam);

            dataType=getpirsignaltype(rto.RuntimePrm(jj).Datatype,isComplex,dims);

            sampleTime=rto.SampleTimes(1);

            info=struct();
            info.ParameterName=tunableParamName;
            info.PropertyName=tunableProp{ii};
            info.DataType=dataType;
            info.SampleTime=sampleTime;

            tunableParameterInfo=[tunableParameterInfo,info];%#ok<AGROW>
        end
    end
end
