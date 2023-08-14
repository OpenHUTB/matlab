function readModelRefMaskParams(this,slbh,blockPath,refNtwk,hNewC)





    instanceParams=get_param(slbh,'InstanceParameters');
    numOfInstanceParams=numel(instanceParams);
    for i=1:numOfInstanceParams
        instancePath=instanceParams(i).Path;
        if(instancePath.getLength>0)
            msg=message('hdlcoder:engine:UnsupportedNestedModelReferenceWithModelArguments');
            this.updateChecks(blockPath,'block',msg,'error');
        end
    end






    paramArgVals=get_param(slbh,'ParameterArgumentValues');
    if~isempty(paramArgVals)

        paramNames=fields(paramArgVals);

        paramValues=struct2cell(paramArgVals);
        maskValues=get_param(slbh,'MaskValues');

        if~isempty(maskValues)
            maskNames=get_param(slbh,'MaskNames');
            for kk=1:length(maskValues)
                for jj=1:length(paramValues)
                    if strcmp(maskNames{kk},paramValues{jj})==1
                        paramValues{jj}=maskValues{kk};
                        break;
                    end
                end
            end
        end

        numBlockParams=size(paramNames,1);
        numUsedParams=0;
        for itr=0:(refNtwk.NumberOfPirGenericPorts-1)
            genericName=refNtwk.getGenericPortName(itr);
            for kk=1:length(paramNames)
                paramName=paramNames{kk};

                if strcmpi(paramName,genericName)==1
                    genericDataType=refNtwk.getGenericPortDataType(itr);
                    hCParamVal=paramValues{kk};
                    maskVal=str2num(hCParamVal);%#ok
                    genericValue='';



                    if isempty(maskVal)
                        foundTopGeneric=false;
                        if~isempty(this.hParamArgMap)
                            if this.hParamArgMap.isKey(hCParamVal)
                                genericValue=hCParamVal;
                                numUsedParams=numUsedParams+1;
                                foundTopGeneric=true;
                            end
                        end
                        if foundTopGeneric==false

                            try
                                maskVal=evalin('base',hCParamVal);
                            catch
                                maskVal='';
                                msg=message('hdlcoder:validate:ModelRefArgumentValueUndefined',hCParamVal);
                                this.updateChecks(blockPath,'block',msg,'Error');
                            end
                        end
                    end


                    if~isempty(maskVal)
                        genericDataType=refNtwk.getGenericPortDataType(itr);
                        val=pirelab.getTypeInfoAsFi(genericDataType,'floor','wrap',maskVal,false);
                        genericValue=pirelab.getTypeInfoAsFi(genericDataType,'floor','wrap',val,false);
                        numUsedParams=numUsedParams+1;
                    end


                    if~isempty(genericValue)

                        if isnumeric(genericValue)&&~isscalar(genericValue)...
                            &&this.HDLCoder.getParameter('isVHDL')
                            msg=message('hdlcoder:validate:ModelRefArgumentValueUnsupported',paramName);
                            this.updateChecks(blockPath,'block',msg,'Error');
                        end
                        genericValue=convertMaskValueToInt(genericValue);
                        hNewC.addGenericPort(paramName,genericValue,genericDataType);
                    end
                    continue;
                end
            end
        end
        if numBlockParams>numUsedParams
            msg=message('hdlcoder:validate:ModelRefArgumentsUnused');
            this.updateChecks(blockPath,'block',msg,'Warning');
        end
    end
end



