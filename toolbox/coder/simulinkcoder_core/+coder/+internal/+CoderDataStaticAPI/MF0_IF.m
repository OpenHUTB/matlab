classdef MF0_IF<coder.internal.CoderDataStaticAPI.DataModelIF





    methods(Static)
        function out=getClassName(entry)
            tokens=split(class(entry),'.');
            out=tokens{end};
        end

        function ret=createEntry(dd,type,name,varargin)
            hlp=coder.internal.CoderDataStaticAPI.getHelper();
            if isa(dd,'coderdictionary.softwareplatform.FunctionPlatform')
                mdl=slInternal('getCDModel',dd);
                switch type
                case{'StorageClass'}
                    ret=coderdictionary.data.StorageClass(mdl);
                    ret.init();
                    ret.Name=name;
                    seq=hlp.getServiceSequence(dd,type);
                    seq.add(ret);
                case{'MemorySection','DataMemorySection'}
                    ret=coderdictionary.data.MemorySection(mdl);
                    ret.Name=name;
                    seq=hlp.getServiceSequence(dd,type);
                    seq.add(ret);
                case hlp.getRTEServices
                    ret=hlp.createServiceEntry(dd,type,name);
                otherwise
                    assert(false,['Invalid code specification type:',type]);
                end
            else
                switch type
                case 'RuntimeEnvironment'
                    ret=hlp.createRuntimeEnvironmentEntry(dd,name);
                case hlp.getRTEServices
                    ret=hlp.createServiceEntry(dd,type,name);
                case{'StorageClass','AbstractStorageClass','LegacyStorageClass',...
                    'MemorySection','AbstractMemorySection','LegacyMemorySection',...
                    'SoftwareComponentTemplate','FunctionClass','FunctionCustomizationTemplate'}
                    ret=dd.create(type,name);
                otherwise
                    assert(false,'Invalid code specification type');
                end
            end
        end

        function setProp(entry,name,value)
            assert(~isempty(entry),'Entry does not contain a value');
            if(isa(entry.(name),'mf.zero.Sequence'))

                for i=1:entry.(name).Size
                    entry.(name).removeAt(1);
                end
                for i=1:length(value)
                    entry.(name).add(value(i));
                end
            else
                if isempty(value)&&isobject(entry.(name))
                    className=class(entry.(name));
                    entry.(name)=eval([className,'.empty']);
                else
                    entry.(name)=value;
                end
            end
        end


        function setEnumProp(entry,name,value)
            if(isa(entry.(name),'mf.zero.Sequence'))
                for i=1:entry.(name).Size
                    entry.(name).removeAt(1);
                end
                for i=1:length(value)
                    newValue=coderdictionary.data.([name,'Enum']).(value(i));
                    entry.(name).add(newValue);
                end
            else
                newValue=coderdictionary.data.([name,'Enum']).(value);
                entry.(name)=newValue;
            end
        end

        function out=getComponentInstanceProp(entry,type,name)

            if isa(entry,'coderdictionary.data.StorageClass')
                if strcmp(type,'SingleInstance')||...
                    strcmp(type,'ComponentSingleInstance')||...
                    strcmp(type,'SubComponentSingleInstance')
                    impl=entry.ComponentSingleInstance;
                elseif strcmp(type,'MultiInstance')||...
                    strcmp(type,'ComponentMultiInstance')||...
                    strcmp(type,'SubComponentMultiInstance')
                    impl=entry.ComponentMultiInstance;
                end
                switch name
                case 'StorageType'
                    if isa(impl,'coderdictionary.data.StructuredImplementation')
                        out='Structured';
                    else
                        out='Unstructured';
                    end
                otherwise
                    if isprop(impl,name)
                        out=impl.(name);
                    else
                        error([name,' is not a property of ',type]);
                    end
                end
            end
        end
        function setComponentInstanceProp(entry,type,name,value)

            if isa(entry,'coderdictionary.data.StorageClass')
                if strcmp(type,'SingleInstance')||...
                    strcmp(type,'ComponentSingleInstance')||...
                    strcmp(type,'SubComponentSingleInstance')
                    if strcmp(name,'StorageType')
                        entry.SingleInstanceStorageType=value;
                    else
                        entry.setComponentInstanceProperty('SingleInstance',name,value);
                    end
                elseif strcmp(type,'MultiInstance')||...
                    strcmp(type,'ComponentMultiInstance')||...
                    strcmp(type,'SubComponentMultiInstance')
                    if~strcmp(name,'StorageType')
                        entry.setComponentInstanceProperty('MultiInstance',name,value);
                    end
                end
            end
        end

        function out=getProp(entry,name)
            out=[];
            try
                out=entry.getPropertyValue(name);
            catch


            end


            if isa(out,'mf.zero.Sequence')
                out=out.toArray;
            elseif isempty(out)
                if isa(entry,'coderdictionary.data.LegacyStorageClass')||...
                    isa(entry,'coderdictionary.data.LegacyMemorySection')


                    cvalue=entry.LegacyProps;
                    prop=cvalue{name};
                    if~isempty(prop)
                        out=prop.Value;
                    end
                end
            end
        end

        function out=cloneEntry(dd,type,origName,~)
            orig=dd.findEntry(type,origName);

            if~isempty(orig)

                if orig.isBuiltin&&isa(orig,'coderdictionary.data.StorageClass')
                    out=orig.cloneTo(dd);
                else
                    out=orig.clone();
                end
            else
                out=[];
            end
        end

        function deleteEntry(dd,type,name)
            hlp=coder.internal.CoderDataStaticAPI.getHelper();
            if isa(dd,'coderdictionary.softwareplatform.FunctionPlatform')
                hlp.deleteServiceEntry(dd,type,name);
            else
                switch type
                case 'RuntimeEnvironment'
                case hlp.getRTEServices()
                    hlp.deleteServiceEntry(dd,type,name);
                case{'StorageClass','AbstractStorageClass','LegacyStorageClass',...
                    'MemorySection','AbstractMemorySection','LegacyMemorySection',...
                    'SoftwareComponentTemplate','FunctionClass','FunctionCustomizationTemplate'}
                    dd.remove(type,name);
                otherwise
                    assert(false,'Invalid code specification type');
                end
            end
        end

        function deleteAll(dd)
            dd.removeAll();
        end

        function out=getCoderData(dd,type)
            import coder.internal.CoderDataStaticAPI.MF0_IF.*;
            hlp=coder.internal.CoderDataStaticAPI.getHelper();
            if isa(dd,'coderdictionary.softwareplatform.FunctionPlatform')
                seq=hlp.getServiceSequence(dd,type);
                out=[];
                if~isempty(seq)
                    out=seq.toArray;
                end
            else
                if isa(dd,'coderdictionary.data.C_Definitions')
                    container=dd.owner;
                end
                switch(type)
                case{'StorageClass','AbstractStorageClass','LegacyStorageClass'}
                    refs=coderdictionary.data.SlCoderDataClient.getAllElementsOfCoderDataTypeForContainer(container,'StorageClasses');
                case{'MemorySection','AbstractMemorySection','LegacyMemorySection'}
                    refs=coderdictionary.data.SlCoderDataClient.getAllElementsOfCoderDataTypeForContainer(container,'MemorySections');
                case 'SoftwareComponentTemplate'
                    out=dd.SoftwareComponentTemplates.toArray;
                    return
                case{'FunctionClass','FunctionCustomizationTemplate'}
                    refs=coderdictionary.data.SlCoderDataClient.getAllElementsOfCoderDataTypeForContainer(container,'FunctionClasses');
                case{'RuntimeEnvironment','RTEDefinitions'}
                    out=dd.owner.RTEDefinition;
                    return
                case hlp.getRTEServices()
                    seq=hlp.getServiceSequence(dd,type);
                    out=[];
                    if~isempty(seq)
                        out=seq.toArray;
                    end
                    return;
                otherwise
                    assert(false,'Invalid code specification type');
                end
                out=getEntriesFromReferences(refs);
            end
        end

        function ret=getDDSection(dd,type)
            tmpret=coder.internal.CoderDataStaticAPI.getCoderData(dd,type);
            ret=tmpret.toArray;
        end

        function ret=getDefinitions(container,dictionaryType)
            import coder.internal.CoderDataStaticAPI.MF0_IF.*;
            if strcmp(dictionaryType,'C')
                ret=getProp(container,'CDefinitions');
                if isempty(ret)
                    container.init();
                    ret=getProp(container,'CDefinitions');
                end
            else
                assert(false,'Unsupported dictionary type');
            end
        end

        function[definitions,fPath,container]=openDD(dd,dictionaryType,needLocal)
            import coder.internal.CoderDataStaticAPI.MF0_IF.*;
            if nargin==1
                dictionaryType='C';
            end

            if nargin<3
                needLocal=false;
            end

            codegenProjectEnable=slfeature('CodeGenerationProject')>0;

            if isa(dd,'coderdictionary.data.AbstractDefinitions')


                if isa(dd,'coderdictionary.data.C_Definitions')
                    container=dd.owner;
                else
                    container=dd.getOwner;
                end
                definitions=dd;
                fPath='';

            elseif isa(dd,'coderdictionary.data.Container')

                container=dd;
                definitions=getDefinitions(dd,dictionaryType);
                fPath='';

            elseif isa(dd,'Simulink.data.Dictionary')
                if codegenProjectEnable
                    cDA=coder.internal.CoderDataStaticAPI.CoderDataAccessor(dd);
                    [definitions,fPath,container]=cDA.getCoderSpecifications(dictionaryType,needLocal);
                else
                    container=coderdictionary.data.api.getDictionary(dd.filepath);
                    definitions=getDefinitions(container,dictionaryType);
                    fPath=dd.filepath;
                end

            elseif codegenProjectEnable
                cDA=coder.internal.CoderDataStaticAPI.CoderDataAccessor(dd);
                [definitions,fPath,container]=cDA.getCoderSpecifications(dictionaryType,needLocal);

            elseif ischar(dd)||isstring(dd)


                [~,~,ext]=fileparts(dd);
                if strcmp(ext,'.sldd')

                    container=coderdictionary.data.api.getDictionary(dd);
                    definitions=getDefinitions(container,dictionaryType);
                    fPath=dd;
                else

                    container=get_param(dd,'CoderDictionary');
                    definitions=getDefinitions(container,dictionaryType);
                    fPath=get_param(dd,'FileName');
                end
            else

                assert(isfloat(dd),'Unrecognized dictionary container');


                container=get_param(dd,'CoderDictionary');
                hasLocal=~container.isEmpty;
                if hasLocal||needLocal

                    definitions=getDefinitions(container,dictionaryType);
                    fPath=get_param(dd,'FileName');
                else
                    ddStr=coderdictionary.data.SlCoderDataClient.getSharedCoderDictionarySource(get_param(dd,'Handle'));
                    if~isempty(ddStr)

                        dd=Simulink.data.dictionary.open(ddStr);
                        container=coderdictionary.data.api.getDictionary(dd.filepath);
                        definitions=getDefinitions(container,dictionaryType);
                        fPath=dd.filepath;
                    else


                        definitions=getDefinitions(container,dictionaryType);
                        fPath=get_param(dd,'FileName');
                    end
                end
            end
        end
        function out=isOpen(~)
            out=true;
        end

        function[out,ref]=findEntry(dd,type,name)
            import coder.internal.CoderDataStaticAPI.MF0_IF.*;
            if isequal(dd.owner.getConfigurationType,'ServiceInterface')
                ref=coderdictionary.data.SlCoderDataClient.getElementByNameOfCoderDataTypeInPlatform(dd.owner,dd.owner.SoftwarePlatforms(1).Name,type,name);
            else
                ref=coderdictionary.data.SlCoderDataClient.getElementByNameOfCoderDataTypeForContainer(dd.owner,type,name);
            end
            if isempty(ref)||ref.isEmpty
                tmp=getCoderData(dd,type);
                nResult=0;
                for i=1:length(tmp)
                    if(strcmp(getClassName(tmp(i)),'LegacyStorageClass')||...
                        strcmp(getClassName(tmp(i)),'LegacyMemorySection'))&&...
                        strcmp(name,tmp(i).ClassName)
                        out=tmp(i);
                        nResult=nResult+1;
                    end
                end
                if nResult~=1
                    out=[];
                    ref=[];
                end
            else
                if(~ref.isEmpty)
                    out=ref.getCoderDataEntry;
                end
            end
        end

        function out=hasSWCT(dd)
            out=(dd.SoftwareComponentTemplates.Size>0);
        end

        function out=hasFunctionClass(dd)
            out=(dd.FunctionClasses.Size>0);
        end

        function moveSingleSCToSWCT(swc,scEntry,category)
            import coder.internal.CoderDataStaticAPI.MF0_IF.*;
            cat=swc.getPropertyValue(category);
            allowableProps=cat.getPropertyValue('AllowableStorageClasses').toArray;
            hasEntry=false;
            for i=1:length(allowableProps)
                if strcmp(allowableProps(i).Name,scEntry.Name)
                    hasEntry=true;
                    break;
                end
            end

            if~hasEntry
                setProp(cat,'AllowableStorageClasses',[allowableProps,scEntry]);
            end
        end

        function moveSCToSWCT(dd,scEntries)
            import coder.internal.CoderDataStaticAPI.*;
            import coder.internal.CoderDataStaticAPI.MF0_IF.*;
            categories=Utils.getDataCategories();
            swcEntry=coder.internal.CoderDataStaticAPI.getSWCT(dd);
            for i=1:length(scEntries)
                scEntry=scEntries(i);
                for j=1:length(categories)
                    moveSingleSCToSWCT(swcEntry,scEntry,categories{j});
                end
            end
        end

        function swc=createSWCT(dd)
            import coder.internal.CoderDataStaticAPI.*;
            import coder.internal.CoderDataStaticAPI.MF0_IF.*;
            if~isInitialized(dd)
                createEntry(dd,'SoftwareComponentTemplate','CODER_DICTIONARY');
            end
            swc=dd.SoftwareComponentTemplates(1);
        end

        function out=heteroArrayHasEntry(arr,entryName)
            import coder.internal.CoderDataStaticAPI.MF0_IF.*;
            out=false;
            for i=1:length(arr)
                name=getProp(arr(i).Name);
                if strcmp(name,entryName)
                    out=true;
                    return;
                end
            end
        end

        function addAllowableCoderDataForElement(swcEntry,coderDataType,category,coderDataEntry,doingInit)
            import coder.internal.CoderDataStaticAPI.MF0_IF.*;
            assert(strcmp(coderDataType,'StorageClass')||strcmp(coderDataType,'MemorySection'));
            allowableCoderData=getAllowableCoderDataForElement(swcEntry,category,coderDataType);
            hasEntry=heteroArrayHasEntry(allowableCoderData,coderDataEntry.Name);

            if strcmp(coderDataType,'MemorySection')
                if isempty(allowableCoderData)
                    setAllowableCoderDataForElement(swcEntry,category,coderDataType,[coderDataEntry]);%#ok<NBRAK>
                elseif~hasEntry
                    setAllowableCoderDataForElement(swcEntry,category,coderDataType,[getAllowableCoderDataForElement(swcEntry,category,coderDataType),coderDataEntry]);
                end
            else
                if isempty(allowableCoderData)
                    setAllowableCoderDataForElement(swcEntry,category,coderDataType,[coderDataEntry],doingInit);%#ok<NBRAK>
                elseif~hasEntry
                    setAllowableCoderDataForElement(swcEntry,category,coderDataType,[getAllowableCoderDataForElement(swcEntry,category,coderDataType),coderDataEntry],doingInit);
                end
            end
        end

        function checkForLegacyCSCs(scEntries)
            if isa(scEntries,'mf.zero.Sequence')
                scEntries=scEntries.toArray;
            end
            for i=1:length(scEntries)
                scEntry=scEntries(i);
                if isa(scEntry,'coderdictionary.data.LegacyStorageClass')
                    msg=message('SimulinkCoderApp:core:CannotChangeLegacySCConstraints',scEntry.Name);
                    MSLE=MSLException([],msg);
                    throw(MSLE);
                end
            end
        end

        function setAllowableCoderDataForElement(swc,modelElementType,coderDataType,entries,varargin)
            import coder.internal.CoderDataStaticAPI.MF0_IF.*;
            skipCheckForLegacy=false;
            if nargin>4
                skipCheckForLegacy=varargin{1};
            end
            if strcmp(coderDataType,'StorageClass')
                if~skipCheckForLegacy
                    checkForLegacyCSCs(entries);
                end
                cat=swc.getPropertyValue(modelElementType);
                if~isempty(cat)
                    setProp(cat,'AllowableStorageClasses',entries);
                end
            elseif strcmp(coderDataType,'MemorySection')
                cat=swc.getPropertyValue(modelElementType);
                if~isempty(cat)
                    setProp(cat,'AllowableMemorySections',entries);
                end
            else
                assert(false,'unrecognized coder data type');
            end
        end

        function out=getAllowableCoderDataForElement(swc,modelElementType,coderDataType)
            out=[];
            if strcmp(coderDataType,'StorageClass')
                cat=swc.getPropertyValue(modelElementType);
                if~isempty(cat)
                    tmpout=cat.getPropertyValue('AllowableStorageClasses');
                    out=tmpout.toArray;
                end
            elseif strcmp(coderDataType,'MemorySection')
                cat=swc.getPropertyValue(modelElementType);
                if~isempty(cat)
                    tmpout=cat.getPropertyValue('AllowableMemorySections');
                    out=tmpout.toArray;
                end
            else
                assert(false,'Unrecognized coder data type');
            end
        end

        function out=beginTxn(dd)
            mmdl=slInternal('getCDModel',dd);
            out=mmdl.beginTransaction();
        end
        function commitTxn(txn)
            txn.commit();
        end
        function rollbackTxn(txn)
            txn.rollBack();
        end
        function out=getEntriesFromReferences(refs)


            out=[];
            for i=1:length(refs)
                if(~refs(i).isEmpty)
                    if isempty(out)
                        out=refs(i).getCoderDataEntry;
                    else
                        out(end+1)=refs(i).getCoderDataEntry;%#ok<AGROW>
                    end
                end
            end
        end
        function ret=getFunctionPlatforms(src)

            ret=struct('PlatformType',{},'Name',{},'Description',{},'DataSource',{});
            hlp=coder.internal.CoderDataStaticAPI.getHelper;
            [~,~,container]=hlp.openDD(src);
            if isValidSlObject(slroot,src)
                mdlHdl=get_param(src,'handle');
                functionComponents=coderdictionary.data.SlCoderDataClient.getAllElementsOfCoderDataType(mdlHdl,'FunctionPlatform');
                fcDataSource=coderdictionary.data.SlCoderDataClient.getSharedCoderDictionarySource(mdlHdl);
            else
                functionComponents=coderdictionary.data.SlCoderDataClient.getAllElementsOfCoderDataTypeForContainer(container,'FunctionPlatform');
                fcDataSource=src;
            end
            if~isempty(functionComponents)

                ret(end+1)=struct('PlatformType','ServiceInterfaceConfiguration',...
                'Name',functionComponents.getCoderDataEntry.Name,...
                'Description',functionComponents.getCoderDataEntry.Description,...
                'DataSource',fcDataSource);
            end
        end
        function ret=getSoftwarePlatforms(src)



            ret=coder.internal.CoderDataStaticAPI.MF0_IF.getFunctionPlatforms(src);
            if isa(src,'coderdictionary.data.C_Definitions')||coder.dictionary.exist(src)
                ret=[struct('PlatformType','DataInterfaceConfiguration',...
                'Name','Embedded Code',...
                'Description','Data interface configuration contains definitions of storage class, memory section, and function customization template.',...
                'DataSource',src);ret];
            end
        end
        function ret=getSoftwarePlatform(src,name)



            platforms=coder.internal.CoderDataStaticAPI.MF0_IF.getSoftwarePlatforms(src);
            ret=platforms(arrayfun(@(x)strcmp(x.Name,name),platforms));
        end
        function ret=getPlatformDefault(dd,type)
            ret=[];
            if isa(dd,'coderdictionary.data.C_Definitions')
                c=dd.owner;
            else
                c=dd.getOwner;
            end
            pcRef=coderdictionary.data.SlCoderDataClient.getAllElementsOfCoderDataTypeForContainer(c,'FunctionPlatform');
            initialData=coderdictionary.data.SlCoderDataClient.getDefaultCoderDataInPlatform(pcRef,type);
            if~initialData.isEmpty()
                ret=initialData.getCoderDataEntry;
            end
        end
        function ret=isPlatformDefault(dd,type,entry)
            ret=false;
            hlp=coder.internal.CoderDataStaticAPI.getHelper();
            default=hlp.getPlatformDefault(dd,type);
            if isequal(default,entry)
                ret=true;
            end
        end
        function setPlatformDefault(dd,type,entry)
            if isa(dd,'coderdictionary.data.C_Definitions')
                sdp=dd.owner.SoftwarePlatforms(1);
            else
                sdp=dd;
            end
            hlp=coder.internal.CoderDataStaticAPI.getHelper;
            if isa(sdp,'coderdictionary.softwareplatform.FunctionPlatform')
                sec=sdp.Component.ComponentSchedulingAndTimingInterface;
                comm=sdp.Component.Communication;
                switch type
                case{'DataReceiverService'}
                    comm.DataSenderReceiver.DefaultDataReceiver=entry;
                case{'DataSenderService'}
                    comm.DataSenderReceiver.DefaultDataSender=entry;
                case{'DataTransferService'}
                    sec.DataTransfer.DefaultDataTransfer=entry;
                case{'TimerService'}
                    sec.Timer.DefaultTimerService=entry;
                case{'ParameterTuningInterface'}
                    sdp.ParameterTuningAndMeasurementInterface.DefaultParameterTuningInterface=entry;
                case{'ParameterArgumentTuningInterface'}
                    sdp.ParameterTuningAndMeasurementInterface.DefaultParameterArgumentTuningInterface=entry;
                case{'MeasurementInterface'}
                    sdp.ParameterTuningAndMeasurementInterface.DefaultMeasurementInterface=entry;
                case{'SharedUtilityFunction'}
                    sdp.DefaultSharedUtilityFunction=entry;
                case{'SubcomponentEntryFunction'}
                    sdp.SubcomponentConfiguration.DefaultSubcomponentEntryFunction=entry;
                case{'DataTypeCustomizationService'}
                    sdp.DataTypeCustomizationInterface.DefaultDataTypeCustomization=entry;
                case hlp.getRTECallableFunctions
                    sec.CallableFunctionInterface.(['Default',type])=entry;
                otherwise
                    assert(true,['unknown service type:',type]);
                end
            end
        end
        function ret=exist(fileName,PlatformType)



            ret=false;
            switch PlatformType
            case 'ServiceInterfaceConfiguration'
                hlp=coder.internal.CoderDataStaticAPI.getHelper;
                dd=hlp.openDD(fileName);
                ret=dd.owner.SoftwarePlatforms.Size>0;
            case 'DataInterfaceConfiguration'
                ret=coder.dictionary.exist(fileName);
            end
        end
    end

    methods(Access=private,Static=true)
        function out=createServiceEntry(dd,type,name)
            hlp=coder.internal.CoderDataStaticAPI.getHelper();
            mdl=slInternal('getCDModel',dd);
            out=coderdictionary.softwareplatform.(type)(mdl);
            out.init;
            out.Name=name;
            switch type
            case 'MeasurementInterface'
                modelElement='InternalData';
            case 'ParameterTuningInterface'
                modelElement='LocalParameters';
            case 'ParameterArgumentTuningInterface'
                modelElement='ParameterArguments';
            otherwise
                modelElement='';
            end
            if~isempty(modelElement)&&isa(dd,'coderdictionary.softwareplatform.FunctionPlatform')
                scs=coderdictionary.data.SlCoderDataClient.getAllCoderDataForModelElementTypeInPlatform(...
                dd.getContainerOwner,dd.Name,modelElement,'StorageClass','IndividualLevel');
                if~isempty(scs)
                    out.StorageClass=scs(1).getCoderDataEntry;
                end
            end
            seq=hlp.getServiceSequence(dd,type);
            if~isempty(seq)
                if seq.Size==0
                    try
                        hlp.setPlatformDefault(dd,type,out);
                    catch

                    end
                end
                seq.add(out);
            end
        end
        function deleteServiceEntry(dd,type,name)
            hlp=coder.internal.CoderDataStaticAPI.getHelper();
            seq=hlp.getServiceSequence(dd,type);
            if~isempty(seq)
                resetPlatformDefaultToFirst=false;
                for i=1:seq.Size
                    if strcmp(seq(i).Name,name)
                        if hlp.doesCoderDataTypeHasPlatformDefault(type)
                            if hlp.isPlatformDefault(dd,type,seq(i))



                                if seq.Size==1
                                    DAStudio.error('SimulinkCoderApp:sdp:CannotRemoveLastElement',type);
                                else
                                    resetPlatformDefaultToFirst=true;
                                end
                            end
                        end
                        itemToBeDeleted=seq(i);
                        seq.remove(itemToBeDeleted);
                        itemToBeDeleted.destroy;
                        break;
                    end
                end
                if resetPlatformDefaultToFirst
                    seq=hlp.getServiceSequence(dd,type);
                    hlp.setPlatformDefault(dd,type,seq(1));
                end
            end
        end

        function ret=getServiceSequence(dd,type)
            ret=[];
            if isa(dd,'coderdictionary.data.C_Definitions')
                sdp=dd.owner.SoftwarePlatforms(1);
            else
                sdp=dd;
            end
            hlp=coder.internal.CoderDataStaticAPI.getHelper;
            if isa(sdp,'coderdictionary.softwareplatform.FunctionPlatform')
                sec=sdp.Component.ComponentSchedulingAndTimingInterface;
                comm=sdp.Component.Communication;
            else
                sec=sdp.Application;
            end
            switch type
            case{'DataReceiverService'}
                ret=comm.DataSenderReceiver.DataReceivers;
            case{'DataSenderService'}
                ret=comm.DataSenderReceiver.DataSenders;
            case{'DataTransferService'}
                ret=sec.DataTransfer.DataTransfers;
            case{'TimerService'}
                ret=sec.Timer.TimerServices;
            case{'FunctionMemorySection'}
                ret=sdp.CodeConfiguration.FunctionMemorySections;
            case{'StorageClass'}
                ret=sdp.CodeConfiguration.StorageClasses;
            case{'DataMemorySection','MemorySection'}
                ret=sdp.CodeConfiguration.MemorySections;
            case{'MeasurementInterface','ParameterTuningInterface','ParameterArgumentTuningInterface'}
                prop=[type,'s'];
                ret=sdp.ParameterTuningAndMeasurementInterface.(prop);
            case{'SharedUtilityFunction'}
                ret=sdp.SharedUtilityFunctions;
            case hlp.getRTECallableFunctions()
                prop=[type,'s'];
                ret=sec.CallableFunctionInterface.(prop);
            case{'SubcomponentEntryFunction'}
                ret=sdp.SubcomponentConfiguration.SubcomponentEntryFunctions;
            case{'DataTypeCustomizationService'}
                ret=sdp.DataTypeCustomizationInterface.DataTypeCustomizations;
            otherwise
                assert(true,['unknown service type:',type]);
            end
        end
        function ret=createRuntimeEnvironmentEntry(dd,name)
            mdl=slInternal('getCDModel',dd);
            rte=coderdictionary.data.RuntimeEnvironment(mdl);
            rte.Name=name;
            ts=coderdictionary.data.TimerService(mdl);
            rte.timerService=ts;
            dd.owner.RTEDefinition=rte;
            ret=rte;
        end
        function ret=getRTEServices()
            hlp=coder.internal.CoderDataStaticAPI.getHelper;
            ret=[{'DataReceiverService',...
            'DataSenderService',...
            'DataTransferService',...
            'TimerService',...
            'ParameterTuningInterface',...
            'ParameterArgumentTuningInterface',...
            'MeasurementInterface',...
            'FunctionMemorySection',...
            'SubcomponentEntryFunction',...
            'DataTypeCustomizationService',...
            'SharedUtilityFunction'},...
            hlp.getRTECallableFunctions()];
        end
        function ret=getRTECallableFunctions()
            ret={'IRTFunction',...
            'PeriodicAperiodicFunction'};
        end
        function ret=doesCoderDataTypeHasPlatformDefault(type)
            ret=~ismember(type,{'FunctionMemorySection',...
            'MemorySection','DataMemorySection','StorageClass'});
        end
    end
end



