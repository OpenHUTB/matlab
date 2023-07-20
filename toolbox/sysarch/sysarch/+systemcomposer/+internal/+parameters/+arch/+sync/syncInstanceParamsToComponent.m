function syncInstanceParamsToComponent(blkInMdl,~,compImpl,actArch)





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



            prmUsg=compArch.addParameter(prmName);
            prmDef=prmUsg.Type;
            maskPrmVal=slResolve(maskPrm.Value,blkInMdl);
            assert(numel(size(maskPrmVal))<3,"3-d and above is not supported.");
            prmDef.Dimensions=mat2str(size(maskPrmVal));
            prmDef.DataType=class(maskPrmVal);



            prmUsg.Value=mat2str(maskPrmVal);




            if isscalar(maskPrmVal)


                comp.getImpl.setParamVal(prmName,mat2str(maskPrmVal));
            end
        end
    elseif blockisa(blkInMdl,'ModelReference')


        comp=systemcomposer.internal.getWrapperForImpl(compImpl);
        compParams=comp.getParameterNames;

        compParamsEscaped=replace(compParams,{'.','/'},'_');

        instParams=get_param(blkInMdl,'InstanceParameters');
        for j=1:length(instParams)
            aParam=instParams(j);
            aParamName=systemcomposer.internal.arch.internal.getFullNameFromInstanceParameter(aParam.Name,aParam.Path);


            matchedIdx=find(strcmp(compParamsEscaped,aParamName),1);
            if~isempty(matchedIdx)





                pName=compParams(matchedIdx);
                if strlength(aParam.Value)>0
                    comp.getImpl.setParamVal(pName,aParam.Value);
                else


                    comp.getImpl.resetParamToDefault(pName);
                end



                if size(pName,2)==1
                    paramNamesCell={convertStringsToChars(pName)};
                else
                    paramNamesCell=convertStringsToChars(pName);
                end
                if aParam.Argument
                    actArch.getImpl.exposeParameter(compImpl,compImpl.getQualifiedName,paramNamesCell);
                else
                    actArch.getImpl.unexposeParameter(compImpl,pName);
                end
            end
        end
    end

end


