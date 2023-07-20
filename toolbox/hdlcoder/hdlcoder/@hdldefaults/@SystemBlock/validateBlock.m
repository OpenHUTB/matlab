function v=validateBlock(this,hC)




    v=hdlvalidatestruct;


    bfp=hC.SimulinkHandle;

    sysObjClassName=get_param(bfp,'System');


    if lowersysobj.isPIRSupportedObject(sysObjClassName)
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:matlabhdlcoder:systemobjectnotsupportedsystemblock',sysObjClassName));
    end

    system_name=get_param(hC.SimulinkHandle,'System');

    v=checkUnsupportedType(this,system_name,hC,v);

    [v,metaClass]=checkUnsupportedPropertyOrMethodSetting(this,system_name,hC,v);

    v=checkGlobals(sysObjClassName,metaClass,v);

end

function[v]=checkUnsupportedType(this,sysObjectName,hC,v)
    dialogParams=get_param(hC.SimulinkHandle,'DialogParameters');
    if~isempty(dialogParams)
        readOnlyAttributes=getReadOnlyAttribute(dialogParams);
        paramNames=fieldnames(dialogParams);
        validParamNames=paramNames(~readOnlyAttributes);
    else
        validParamNames={};
    end


    slbh=hC.SimulinkHandle;
    for ii=1:numel(validParamNames)
        paramName=validParamNames{ii};
        paramVal=get_param(hC.SimulinkHandle,paramName);
        paramInfo=dialogParams.(paramName);
        if strcmp(paramInfo.Type,'boolean')
            paramsValue=strcmp(paramVal,'on');
        elseif strcmp(paramInfo.Type,'string')
            try
                paramsValue=this.hdlslResolve(paramName,slbh);
            catch
                paramsValue=paramVal;

            end
        else
            paramsValue=paramVal;
        end
        v=checkSupportedValue(paramName,paramsValue,sysObjectName,v);
    end

end

function readOnlyAttributes=getReadOnlyAttribute(dialogParams)
    paramNames=fieldnames(dialogParams);
    readOnlyAttributes=false(1,numel(paramNames));
    for ii=1:numel(paramNames)
        paramName=paramNames{ii};
        paramInfo=dialogParams.(paramName);
        if any(strcmp(paramInfo.Attributes,'read-only'))
            readOnlyAttributes(ii)=true;
        end
    end
end

function v=checkSupportedValue(paramName,value,sysObjectName,v)


    if~isnumeric(value)&&~ischar(value)&&~islogical(value)&&...
        ~isa(value,'embedded.numerictype')&&~strcmp(paramName,'InputFimath')
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:matlabhdlcoder:systemobjectunsupportedpropvalue',...
        paramName,sysObjectName,class(value)));
    end
end

function[v,mc]=checkUnsupportedPropertyOrMethodSetting(this,sysObjectName,hC,v)

    mc=meta.class.fromName(sysObjectName);
    mp=mc.PropertyList;
    slbh=hC.SimulinkHandle;
    for ii=1:numel(mp)
        if isa(mp(ii),'matlab.system.CustomMetaProp')&&mp(ii).PropertyPortPolicy
            srcSetPolicy=eval([sysObjectName,'.',mp(ii).Name,'.','getPolicy(1)']);
            if isa(srcSetPolicy,'matlab.system.internal.PropertyOrMethod')



                ctrlPropName=srcSetPolicy.ControlPropertyName;
                ctrlPropValue=get_param(slbh,ctrlPropName);
                if strcmp(ctrlPropValue,'on')
                    paramName=strrep(mp(ii).Name,'Set','');
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcoder:matlabhdlcoder:systemobjectunsupportedpropertymethod',...
                    paramName,sysObjectName,ctrlPropName));%#ok<AGROW>
                end
            end
        end
    end

    num=matlab.system.coder.SystemProp.getNumPublicTunableProps(sysObjectName);
    hasUserProcessTunedPropertiesImpl=matlab.system.coder.hasUserImplementation.do(...
    sysObjectName,'processTunedPropertiesImpl');
    isPIRObject=lowersysobj.isPIRSupportedObject(sysObjectName);
    if~isPIRObject&&num>0&&hasUserProcessTunedPropertiesImpl
        v(end+1)=hdlvalidatestruct(2,message(...
        'hdlcoder:matlabhdlcoder:systemobjectprocesstunedpropertiesimpl',...
        sysObjectName));
    end

    dataFlowImported=false;

    if targetcodegen.targetCodeGenerationUtils.isNFPMode()&&~dataFlowImported
        for itr=1:length(hC.PirInputSignals)
            refType=hC.PirInputSignals(itr).Type.getLeafType;
            if(refType.isFloatType())
                msgObj=message('hdlcommon:nativefloatingpoint:Nfp_unsupported_block',getfullname(hC.SimulinkHandle));
                v(end+1)=hdlvalidatestruct(1,msgObj);%#ok<AGROW>
                return;
            end
        end
        for itr=1:length(hC.PirOutputSignals)
            refType=hC.PirOutputSignals(itr).Type.getLeafType;
            if(refType.isFloatType())
                msgObj=message('hdlcommon:nativefloatingpoint:Nfp_unsupported_block',getfullname(hC.SimulinkHandle));
                v(end+1)=hdlvalidatestruct(1,msgObj);%#ok<AGROW>
                return;
            end
        end
    end

end

function v=checkGlobals(sysObjClassName,metaClass,v)

    fileNamePath=which(sysObjClassName);
    isMCoded=exist(fileNamePath,'file')==2;
    if isMCoded

        t=mtree(fileNamePath,'-file');
        if~isempty(mtfind(t,'Kind','GLOBAL'))
            msgObj=message('hdlcoder:matlabhdlcoder:systemobjectglobalspresent',sysObjClassName);
            v(end+1)=hdlvalidatestruct(1,msgObj);
        end
    else


        mtds=metaClass.MethodList;
        for ii=1:numel(mtds)
            if strcmp(mtds(ii).Name,'getGlobalNamesImpl')
                if strcmp(mtds(ii).DefiningClass.Name,sysObjClassName)
                    msgObj=message('hdlcoder:matlabhdlcoder:systemobjectgetglobalnamesimplpresent',sysObjClassName);
                    v(end+1)=hdlvalidatestruct(1,msgObj);%#ok<AGROW>
                end
                break;
            end
        end
    end
end

