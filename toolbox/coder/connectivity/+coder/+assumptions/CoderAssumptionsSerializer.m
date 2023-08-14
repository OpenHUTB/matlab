classdef(Hidden=true)CoderAssumptionsSerializer<handle








    properties(Access=private)
        ConfigInterface;
        CodeDescriptorRepo;
    end

    methods(Access=public)
        function this=CoderAssumptionsSerializer(configInterface,codeDescriptorPath)
            this.ConfigInterface=configInterface;
            this.CodeDescriptorRepo=this.initCodeDescriptorRepo(codeDescriptorPath);
        end


        function serializeCoderAssumptionsToCodeDescriptor(this)



            txn=this.CodeDescriptorRepo.beginTransaction;


            coderAssumptions=this.createDefaultCoderAssumptions(this.CodeDescriptorRepo);


            coderAssumptions.CoderConfig=this.populateCoderConfig(coderAssumptions);
            isPortableWordSizes=coderAssumptions.CoderConfig.PortableWordSizes;
            if isPortableWordSizes


                this.createDefaultCoderAssumptionsPWS(this.CodeDescriptorRepo,coderAssumptions)
            end
            coderAssumptions.Assumptions=this.populateAssumptions(coderAssumptions,isPortableWordSizes);

            if isa(this.ConfigInterface,'coder.connectivity.SimulinkConfig')



                model=coder.descriptor.Model.findModel(this.CodeDescriptorRepo);
            else
                model=coder.descriptor.Model(this.CodeDescriptorRepo);
            end

            model.CoderAssumptions=coderAssumptions;


            txn.commit;
        end
    end

    methods(Access=private)
        function coderConfig=populateCoderConfig(this,coderAssumptions)
            coderConfig=coderAssumptions.CoderConfig;
            coderConfig.PortableWordSizes=...
            this.onOffToBool(this.ConfigInterface.getParam('PortableWordSizes'));
            coderConfig.LongLongMode=...
            this.onOffToBool(this.ConfigInterface.getParam('TargetLongLongMode'));
            coderConfig.PurelyIntegerCode=...
            this.onOffToBool(this.ConfigInterface.getParam('PurelyIntegerCode'));
            coderConfig.HWDeviceType=this.ConfigInterface.getParam('TargetHWDeviceType');
            coderConfig.PreprocMaxBitsUint=this.ConfigInterface.getParam('TargetPreprocMaxBitsUint');
            coderConfig.PreprocMaxBitsSint=this.ConfigInterface.getParam('TargetPreprocMaxBitsSint');
        end

        function assumptions=populateAssumptions(this,coderAssumptions,isPortableWordSizes)
            assumptions=coderAssumptions.Assumptions;
            assumptions.MemoryAtStartup=...
            this.getMemoryAtStartup;
            assumptions.DynamicMemoryAtStartup=...
            this.getMemoryAtStartup;

            [ftz,daz]=this.getDenormalSupportFTZandDAZ;
            assumptions.DenormalFlushToZero=ftz;
            assumptions.DenormalAsZero=daz;

            useHostSettings=false;
            assumptions.TargetHardware=this.populateHWProps(assumptions,useHostSettings);
            if isPortableWordSizes

                useHostSettings=true;
                assumptions.PortableWordSizesHardware=...
                this.populateHWProps(assumptions,useHostSettings);
            end
        end

        function hwProps=populateHWProps(this,assumptions,useHostSettings)
            if~useHostSettings
                hwProps=this.populateHWPropsFromConfigSet(assumptions);
            else
                hwProps=this.populateHWPropsFromHostValues(assumptions);
            end
        end


        function hwProps=populateHWPropsFromConfigSet(this,assumptions)
            hwProps=assumptions.TargetHardware;
            hwImplValidator=rtw.pil.SILHWImplValidation(this.ConfigInterface);

            paramList=hwImplValidator.getHostWordLengthsParamList;
            wordLengths=cellfun(@(param)this.ConfigInterface.getParam(param),paramList);
            paramStructWithoutPrefix=...
            this.getParamStructWithoutPrefix(wordLengths,paramList);
            hwProps.WordLengths=this.populateWordLengths(hwProps,paramStructWithoutPrefix);

            paramList=hwImplValidator.getHostImplementationPropsParamList;
            hwImplProps=cellfun(@(param)this.ConfigInterface.getParam(param),paramList,'UniformOutput',false);
            paramStructWithoutPrefix=...
            this.getParamStructWithoutPrefix(hwImplProps,paramList);
            [hwProps.Endianess,hwProps.IntDivRoundTo,hwProps.ShiftRightIntArith]=...
            this.getHWImplProperties(paramStructWithoutPrefix);
        end


        function hwProps=populateHWPropsFromHostValues(this,assumptions)
            hwProps=assumptions.PortableWordSizesHardware;
            hwImplValidator=rtw.pil.SILHWImplValidation(this.ConfigInterface);

            [hostWordLengths,paramList]=hwImplValidator.getHostWordLengths;
            paramStructWithoutPrefix=...
            this.getParamStructWithoutPrefix(hostWordLengths,paramList);
            hwProps.WordLengths=this.populateWordLengths(hwProps,paramStructWithoutPrefix);

            [hostImplProps,paramList]=hwImplValidator.getHostImplementationProps;
            paramStructWithoutPrefix=...
            this.getParamStructWithoutPrefix(hostImplProps,paramList);
            [hwProps.Endianess,hwProps.IntDivRoundTo,hwProps.ShiftRightIntArith]=...
            this.getHWImplProperties(paramStructWithoutPrefix);
        end

        function[ftz,daz]=getDenormalSupportFTZandDAZ(this)

            denormaBehavior=this.ConfigInterface.getParam('DenormalBehavior');
            ftz=strcmp(denormaBehavior,'FlushToZero');


            daz=false;
        end
    end

    methods(Access=public,Static)
        function[modelZI,coderAssumptionsZI]=zeroInitCoderAssumptions()


            modelZI=mf.zero.Model;


            coderAssumptionsZI=coder.assumptions.CoderAssumptionsSerializer.createDefaultCoderAssumptions(modelZI);



            coderAssumptionsZI.Assumptions.TargetHardware.Endianess='Unspecified';
            coderAssumptionsZI.Assumptions.TargetHardware.IntDivRoundTo='Undefined';
        end
    end

    methods(Access=private,Static)
        function coderAssumptions=createDefaultCoderAssumptions(mfModel)



            coderAssumptions=coder.descriptor.CoderAssumptions(mfModel);
            coderAssumptions.CoderConfig=coder.descriptor.CoderConfig(mfModel);
            coderAssumptions.Assumptions=coder.descriptor.Assumptions(mfModel);
            coderAssumptions.Assumptions.TargetHardware=coder.descriptor.HWProperties(mfModel);
            coderAssumptions.Assumptions.TargetHardware.WordLengths=coder.descriptor.WordLengths(mfModel);
        end

        function createDefaultCoderAssumptionsPWS(mfModel,coderAssumptions)
            coderAssumptions.Assumptions.PortableWordSizesHardware=coder.descriptor.HWProperties(mfModel);
            coderAssumptions.Assumptions.PortableWordSizesHardware.WordLengths=...
            coder.descriptor.WordLengths(mfModel);
        end

        function wl=populateWordLengths(hwProps,paramStruct)
            wl=hwProps.WordLengths;
            wl.BitPerChar=paramStruct.BitPerChar;
            wl.BitPerShort=paramStruct.BitPerShort;
            wl.BitPerInt=paramStruct.BitPerInt;
            wl.BitPerLong=paramStruct.BitPerLong;
            wl.BitPerLongLong=paramStruct.BitPerLongLong;
            wl.BitPerFloat=paramStruct.BitPerFloat;
            wl.BitPerDouble=paramStruct.BitPerDouble;
            wl.BitPerPointer=paramStruct.BitPerPointer;
            wl.BitPerSizeT=paramStruct.BitPerSizeT;
            wl.BitPerPtrDiffT=paramStruct.BitPerPtrDiffT;
        end


        function repo=initCodeDescriptorRepo(codeDescriptorPath)
            repo=mf.zero.Model;
            mfdatasource.attachDMRDataSource(codeDescriptorPath,repo,mfdatasource.ToModelSync.None,mfdatasource.ToDataSourceSync.AllElements);
        end

        function boolValue=onOffToBool(onOffString)
            switch onOffString
            case 'on'
                boolValue=true;
            case 'off'
                boolValue=false;
            otherwise
                assert(false,'Unexpected setting for onOffToBool: %s',onOffString);
            end
        end

        function memoryAtStartup=getMemoryAtStartup

            status=coder.internal.connectivity.featureOn('CoderAssumptionsTestMode');
            if status==coder.internal.connectivity.CATestModes.TestMemoryAtStartup
                memoryAtStartup=1;
            else


                memoryAtStartup=0;
            end
        end

        function[endianess,intDivRoundTo,shiftRightIntArith]=...
            getHWImplProperties(paramStruct)
            endianess=coder.assumptions.CoderAssumptionsSerializer.getEndianess(paramStruct);
            intDivRoundTo=coder.assumptions.CoderAssumptionsSerializer.getIntDivRoundTo(paramStruct);
            shiftRightIntArith=coder.assumptions.CoderAssumptionsSerializer.getShiftRightIntArith(paramStruct);
        end

        function paramStructWithoutPrefix=getParamStructWithoutPrefix(values,paramList)
            if~iscell(values)
                values=num2cell(values);
            end
            paramStructWithoutPrefix=cell2struct(values,...
            regexprep(paramList,'^(Prod)|(Target)',''),2);
        end

        function endianess=getEndianess(hwImplStruct)
            endianess=coder.descriptor.EndianessEnum(hwImplStruct.Endianess);
        end

        function intDivRoundTo=getIntDivRoundTo(hwImplStruct)
            intDivRoundTo=coder.descriptor.IntDivRoundToEnum(hwImplStruct.IntDivRoundTo);
        end

        function shiftRightIntArith=getShiftRightIntArith(hwImplStruct)
            shiftRightIntArith=coder.assumptions.CoderAssumptionsSerializer.onOffToBool(hwImplStruct.ShiftRightIntArith);
        end
    end
end
