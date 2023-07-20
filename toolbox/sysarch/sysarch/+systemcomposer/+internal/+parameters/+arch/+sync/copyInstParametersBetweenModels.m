function copyInstParametersBetweenModels(blkInMdl,~,compImpl,actArch)




    if isempty(compImpl)||...
        ~isa(compImpl,'systemcomposer.architecture.model.design.Component')

        return;
    end

    if blockisa(blkInMdl,'SubSystem')


        if strcmp(get_param(blkInMdl,'Mask'),'off')

            return;
        end

        comp=systemcomposer.internal.getWrapperForImpl(compImpl);
        compArch=comp.Architecture;
        maskObj=get_param(blkInMdl,'MaskObject');
        maskPrms=maskObj.Parameters;
        for j=1:length(maskPrms)
            maskPrm=maskPrms(j);
            isValidPrm=strcmp(maskPrm.Hidden,'off')&&...
            strcmp(maskPrm.ReadOnly,'off')&&...
            strcmp(maskPrm.NeverSave,'off')&&...
            strcmp(maskPrm.Evaluate,'on')&&...
            strcmp(maskPrm.Type,'edit');
            if~isValidPrm
                continue;
            end

            prmName=maskPrm.Name;

            maskPrmVal=slResolve(maskPrm.Value,blkInMdl);
            assert(numel(size(maskPrmVal))<3,"3-d and above is not supported.");
            dataType=class(maskPrmVal);
            if strcmpi(dataType,'auto')
                dataType="double";
            else
                dataType=systemcomposer.internal.parameters.arch.sync.processDataTypeObject(dataType,bdroot(blkInMdl));
            end
            if systemcomposer.internal.arch.internal.isParameterDataTypeUnsupported(dataType)

                continue;
            end
            prmUsg=compArch.addParameter(prmName);
            prmDef=prmUsg.Type;
            prmDef.Dimensions=mat2str(size(maskPrmVal));
            prmDef.DataType=class(maskPrmVal);

            prmUsg.Value=mat2str(maskPrmVal);


            if isscalar(maskPrmVal)
                comp.getImpl.setParamVal(prmName,mat2str(maskPrmVal));
            end
        end
    elseif blockisa(blkInMdl,'ModelReference')


        comp=systemcomposer.internal.getWrapperForImpl(compImpl);

        compParams=strrep(comp.getParameterNames,'.','_');
        instParams=get_param(blkInMdl,'InstanceParameters');
        for j=1:length(instParams)
            aParam=instParams(j);
            aParamName=systemcomposer.internal.arch.internal.getFullNameFromInstanceParameter(aParam.Name,aParam.Path);


            if~isempty(intersect(compParams,aParamName))






                try
                    if strlength(aParam.Value)>0
                        compParamValue=comp.getParameterValue(aParamName);
                        if~strcmp(compParamValue,aParam.Value)
                            comp.setParameterValue(aParamName,aParam.Value);
                        end
                    else


                        comp.setParameterValue(aParamName,'');
                    end
                catch e

                end



                if aParam.Argument
                    actArch.exposeParameter('Path',compImpl.getQualifiedName,'Parameters',aParamName);
                else
                    actArch.unexposeParameter('Path',compImpl.getQualifiedName,'Parameters',aParamName);
                end
            end
        end
    end

end


