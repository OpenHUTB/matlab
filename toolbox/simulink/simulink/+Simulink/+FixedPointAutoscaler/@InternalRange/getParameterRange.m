

function outRange=getParameterRange(obj,parameterName,varargin)




    assert(nargin==2||nargin==4,...
    'Incorrect number of inputs in Simulink.FixedPointAutoscaler.InternalRange.getParameterRange');




    [outRange,foundExprRange]=getRangeForComplicatedParamExpr(...
    obj,parameterName);

    if foundExprRange
        return;
    end









    if nargin==2
        paramMinExpr='[]';
        paramMaxExpr='[]';
    else
        paramMinExpr=varargin{1};
        paramMaxExpr=varargin{2};
    end
    blockParamMin=slResolve(paramMinExpr,obj.blockObject.Handle);
    blockParamMax=slResolve(paramMaxExpr,obj.blockObject.Handle);
    blockParamRange=makeRange(double(blockParamMin),double(blockParamMax));



    simpleExprRange=getRangeFromSimpleParamExpr(obj,parameterName);
    outRange=obj.intersectRange(simpleExprRange,blockParamRange);


    function outRange=getRangeFromSimpleParamExpr(obj,parameterName)


        isTunable=Advisor.Utils.Simulink.isTunableBlockParameter(...
        obj.blockObject.getFullName,parameterName);



        parameterExpr=get_param(obj.blockObject.Handle,parameterName);

        try



            slResolveValue=slResolve(parameterExpr,obj.blockObject.Handle,'variable');
        catch

            slResolveValue=slResolve(parameterExpr,obj.blockObject.Handle);
        end

        if isa(slResolveValue,'Simulink.Parameter')
            outRange=getRangeFromParameterObject(...
            obj.blockObject.Handle,slResolveValue,parameterExpr,isTunable);
        else
            outRange=getRangeFromParameterValue(slResolveValue,isTunable);
        end


        function outRange=getRangeFromParameterObject(...
            blockHandle,paramObj,parameterExpr,isTunable)






            isTunable=isTunable||~strcmp(paramObj.CoderInfo.StorageClass,'Auto');
            if isTunable


                outRange=makeRange(double(paramObj.Min),double(paramObj.Max));
            else
                val=SimulinkFixedPoint.EntityAutoscalers.ParameterObjectEntityAutoscaler.resolveParameterObjectValue(...
                paramObj,parameterExpr,blockHandle);
                outRange=makeRangeFromParamVal(double(val));
            end


            function outRange=getRangeFromParameterValue(value,isTunable)
                if isTunable

                    outRange=makeRange([],[]);
                else

                    outRange=makeRangeFromParamVal(double(value));
                end


                function[outRange,foundExprRange]=getRangeForComplicatedParamExpr(obj,parameterName)




                    outRange=[];
                    foundExprRange=false;

                    runtimeBlkObj=obj.blockObject.RuntimeObject;

                    paramIdx=-1;
                    for idx=1:numel(runtimeBlkObj.NumRuntimePrms)
                        if strcmp(parameterName,runtimeBlkObj.RuntimePrm(idx).Name)
                            paramIdx=idx;
                            break;
                        end
                    end

                    assert(paramIdx~=-1,...
                    'Invalid parameter name in Simulink.FixedPointAutoscaler.InternalRange.getParameterRange');

                    blockSID=Simulink.ID.getSID(obj.blockObject);




                    paramPort=1000000+paramIdx-1;
                    paramSID=Simulink.URL.PortURL(blockSID,'out',paramPort);
                    result=[];
                    ascalerData=obj.runObj.getMetaData;
                    if~isempty(ascalerData)
                        result=ascalerData.getInternalDerivedRangeData(paramSID.char);
                    end

                    if~isempty(result)
                        outRange=makeRange(double(result.DerivedMin),double(result.DerivedMax));
                        foundExprRange=true;
                    end


                    function outRange=makeRangeFromParamVal(val)
                        outRange=[];
                        for idx=1:numel(val)
                            outRange=Simulink.FixedPointAutoscaler.InternalRange.unionRange(...
                            outRange,pointRange(val));
                        end


                        function outRange=makeRange(rangeMin,rangeMax)
                            range=[];
                            if isempty(rangeMin)
                                range(end+1)=-Inf;
                            else
                                range(end+1)=rangeMin;
                            end

                            if isempty(rangeMax)
                                range(end+1)=Inf;
                            else
                                range(end+1)=rangeMax;
                            end

                            outRange=[min(range),max(range)];


                            function range=pointRange(val)
                                if isreal(val)
                                    range=[val,val];
                                else
                                    range=Simulink.FixedPointAutoscaler.InternalRange.unionRange(real(val),imag(val));
                                end


