classdef HWInterruptInfo<codertarget.Info





    properties(SetAccess=private,GetAccess=public)
        DefinitionFileName char='';
        TargetFolder char='';
    end


    properties(SetAccess='protected',GetAccess='public')

        Name char='';

        TargetName char='';


        IrqGroup codertarget.interrupts.InterruptGroup=codertarget.interrupts.InterruptGroup.empty;

        PriorityRange uint32=[0,intmax('uint32')];



        PositivePriorityOrder logical=false;


        SoftwareManagedPriority logical=false;


        CallbackForPriorityManagement char='';


        CallConfigureAfterScheduler logical=true;

        SynchronousSchIRQNumber uint32=intmax('int32');

        GenerateInInterruptsSource logical=true;
    end

    properties(SetAccess='protected',GetAccess='public',Hidden)





        Arbitration char{mustBeMember(Arbitration,{'Positive','Negative'})}='Positive';


        Prologue char=''


        Epilogue char=''
    end

    properties(SetAccess='protected',GetAccess='public')

        EnableInterruptPeripheralFcn char='';

        ConfigureIRQFcn char='';

        EnableIRQFcn char='';

        DisableIRQFcn char='';

        ClearPendingIRQFcn char='';



        IRQMaskFcn char='';



        IRQUnmaskFcn char='';

        DisableInterruptPeripheralFcn char='';
    end


    properties(Access='protected')

        BlockInitFcn='';

        BlockMaskInitFcn='';

        BlockCopyFcn='';

        BlockDeleteFcn='';
    end

    properties(Hidden)

        BuildConfigurationInfo codertarget.attributes.BuildConfigurationInfo=codertarget.attributes.BuildConfigurationInfo.empty;
    end

    methods
        function setEnableInterruptPeripheralFcn(obj,value)
            if~isempty(value)
                validateattributes(convertStringsToChars(value),{'char','string'},{'nonempty'},'','Enable interrupt peripheral function');
            end
            obj.EnableInterruptPeripheralFcn=value;
        end

        function setConfigureIRQFcn(obj,value)
            if~isempty(value)
                validateattributes(convertStringsToChars(value),{'char','string'},{'nonempty'},'','Configure IRQ function');
            end
            obj.ConfigureIRQFcn=value;
        end

        function setEnableIRQFcn(obj,value)
            if~isempty(value)
                validateattributes(convertStringsToChars(value),{'char','string'},{'nonempty'},'','Enable IRQ function');
            end
            obj.EnableIRQFcn=value;
        end

        function setDisableIRQFcn(obj,value)
            if~isempty(value)
                validateattributes(convertStringsToChars(value),{'char','string'},{'nonempty'},'','Disable IRQ function');
            end
            obj.DisableIRQFcn=value;
        end

        function setClearPendingIRQFcn(obj,value)
            if~isempty(value)
                validateattributes(convertStringsToChars(value),{'char','string'},{'nonempty'},'','Clear Pending IRQ function');
            end
            obj.ClearPendingIRQFcn=value;
        end

        function setIRQMaskFcn(obj,value)
            if~isempty(value)
                validateattributes(convertStringsToChars(value),{'char','string'},{'nonempty'},'','IRQ Mask function');
            end
            obj.IRQMaskFcn=value;
        end

        function setIRQUnmaskFcn(obj,value)
            if~isempty(value)
                validateattributes(convertStringsToChars(value),{'char','string'},{'nonempty'},'','IRQ Unmask function');
            end
            obj.IRQUnmaskFcn=value;
        end

        function setDisableInterruptPeripheralFcn(obj,value)
            if~isempty(value)
                validateattributes(convertStringsToChars(value),{'char','string'},{'nonempty'},'','Global disable function');
            end
            obj.DisableInterruptPeripheralFcn=value;
        end

        function setCallConfigureAfterScheduler(obj,value)
            if~isempty(value)
                validateattributes(value,{'numeric','logical'},{'binary','scalar'},'','Call configure function after scheduler');
            end
            obj.CallConfigureAfterScheduler=value;
        end
    end

    properties(Constant,Hidden)

        TokenInterruptNumber char='$(ISR_NUMBER)';
        TokenInterruptName char='$(ISR_NAME)';
    end

    properties(Constant,Hidden)
        NameTag='Name';
        TargetNameTag='TargetName';
        PriorityRangeTag='PriorityRange';
        SoftwareManagedPriorityTag='SoftwareManagedPriority';
        CallbackForPriorityManagementTag='CallbackForPriorityManagement';
        PositivePriorityOrderTag='PositivePriorityOrder';
        ArbitrationTag='Arbitration';
        IrqGroupTag='IrqGroup';
        IrqGroupNameTag='IrqGroupName';
        IrqNameTag='IrqName';
        IrqNumberTag='IrqNumber';
        IrqEventNameTag='IrqEventName';
        IrqEventStatusTag='IrqEventStatus';
        IrqEventClearStatusTag='IrqEventClearStatus';
        PrologueTag='Prologue';
        EpilogueTag='Epilogue';
        GlobalEnableFunctionTag='EnableInterruptPeripheralFcn';
        ConfigureIRQFunctionTag='ConfigureIRQFcn';
        EnableIRQFunctionTag='EnableIRQFcn';
        DisableIRQFunctionTag='DisableIRQFcn';
        ClearPendingIRQFunctionTag='ClearPendingIRQFcn';
        IRQMaskFunctionTag='IRQMaskFcn';
        IRQUnmaskFunctionTag='IRQUnmaskFcn';
        GlobalDisableFunctionTag='DisableInterruptPeripheralFcn';
        CallConfigureAfterSchedulerTag='CallConfigureAfterScheduler';
        SynchronousSchIRQNumberTag='SynchronousSchIRQNumber';
        GenerateInInterruptsSourceTag='GenerateInInterruptsSource';
    end

    methods(Access=protected)
        function setCallbackForPriorityManagement(obj,value)
            value=convertStringsToChars(value);
            if isempty(value)
                obj.CallbackForPriorityManagement='';
            else
                validateattributes(value,{'char'},{'vector','nrows',1},'','callback');
                assert(~isempty(which(value)),'%s function not found. Make sure to assign a valid function.',value);
                obj.CallbackForPriorityManagement=value;
            end
        end
    end

    methods
        function obj=HWInterruptInfo(filePathName)
            if(nargin==1)
                obj.DefinitionFileName=filePathName;
                obj.TargetFolder=fileparts(fileparts(fileparts(obj.DefinitionFileName)));
                obj.deserialize;
            end
        end

        function setTargetName(obj,value)
            if isempty(value)
                obj.TargetName='';
            else
                value=convertStringsToChars(value);
                validateattributes(value,{'char'},{'nonempty','vector','nrows',1},'','Target name');
                obj.TargetName=value;


                tgtFolder=codertarget.target.getTargetFolder(obj.TargetName);
                if~isempty(tgtFolder)

                    obj.TargetFolder='$(TARGET_ROOT)';
                    [~,fname,fext]=fileparts(obj.DefinitionFileName);
                    obj.DefinitionFileName=['$(TARGET_ROOT)/registry/interrupts/',fname,fext];
                end
            end
        end

        function setName(obj,value)
            if isempty(value)
                obj.Name='';
            else
                value=convertStringsToChars(value);
                validateattributes(value,{'char'},{'nonempty','vector','nrows',1},'','Name');
                obj.Name=value;
            end
        end

        function ret=getTargetName(obj)
            ret=obj.TargetName;
        end

        function setPriorityOrder(obj,value)
            if isnumeric(value)||islogical(value)
                validateattributes(value,{'numeric','logical'},{'binary','scalar'},'','Positive priority order');

                obj.PositivePriorityOrder=~isequal(value,0);
            else
                value=convertStringsToChars(value);
                value=validatestring(value,{'true','false'},'','Positive priority order');
                obj.PositivePriorityOrder=eval(value);
            end
        end

        function setSynchronousSchIRQNumber(obj,value)
            value=convertStringsToChars(value);
            if ischar(value)
                value=str2num(value);%#ok<ST2NM>
            end
            validateattributes(value,{'numeric'},{'nonempty','scalar','real','nonnan','nonnegative'},'','Synchronous IRQ Number');

            obj.SynchronousSchIRQNumber=value;
        end

        function setSoftwareManagedPriority(obj,value,callbackFcnName)
            validateattributes(value,{'numeric','logical'},{'binary','scalar'},'','Software managed priority');
            obj.SoftwareManagedPriority=value;

            setCallbackForPriorityManagement(obj,callbackFcnName);
        end

        function IntGrpNames=getInterruptGroupNames(obj)
            IntGrpNames='';
            if~isempty(obj.IrqGroup)
                IntGrpNames={obj.IrqGroup.Name};
            end
        end

        function Intr=getInterruptGroup(obj,InterruptGroupName)
            Intr=codertarget.interrupts.InterruptGroup.empty;
            IntGrpNames=getInterruptGroupNames(obj);

            if~isempty(IntGrpNames)
                InterruptGroupName=validatestring(InterruptGroupName,IntGrpNames);
                Intr=obj.IrqGroup(ismember(IntGrpNames,InterruptGroupName));
            end
        end

        function Intr=getInterruptGroupBasedOnInterruptName(obj,InterruptName)
            Intr=codertarget.interrupts.InterruptGroup.empty;

            if~isempty(obj.IrqGroup)
                for i=1:numel(obj.IrqGroup)
                    if~isempty(getInterrupt(obj.IrqGroup(i),InterruptName))
                        Intr=obj.IrqGroup(i);
                    end
                end
            end
        end

        function IntrGrp=addNewInterruptGroup(obj,InterruptGroupName)
            IntrGrpNames=getInterruptGroupNames(obj);
            if~isempty(IntrGrpNames)
                assert(isempty(intersect(IntrGrpNames,InterruptGroupName)),'%s interrupt group already exists.',InterruptGroupName);
            end
            obj.IrqGroup(end+1)=codertarget.interrupts.InterruptGroup(InterruptGroupName);
            IntrGrp=obj.IrqGroup(end);
        end

        function isrs=getAllInterrupts(obj)
            isrs=codertarget.interrupts.Interrupt.empty;
            if~isempty(obj.IrqGroup)
                for i=1:numel(obj.IrqGroup)
                    isrs=[isrs,obj.IrqGroup(i).IrqInfo];%#ok<AGROW>
                end
            end
        end

        function IntrGrp=removeInterruptGroup(obj,InterruptGroupName)
            IntrGrp=getInterruptGroup(obj,InterruptGroupName);
            if~isempty(IntrGrp)
                obj.IrqGroup(ismember(getInterruptGroupNames(obj),InterruptGroupName))=[];
            end
        end

        function validate(obj)






            IntNames=[];

            if~isempty(obj.IrqGroup)
                for i=1:numel(obj.IrqGroup)
                    IntNames=[IntNames,getInterruptNames(obj.IrqGroup(i))];%#ok<AGROW>
                end
                RepeatingInterrupts=obj.getNonUniqueEntriesInCell(IntNames);
                if~isempty(RepeatingInterrupts)
                    IntGrp=[];


                    for i=1:numel(obj.IrqGroup)
                        if ismember(RepeatingInterrupts,getInterruptNames(obj.IrqGroup(i)))
                            IntGrp=[IntGrp,{[obj.IrqGroup(i).Name]}];%#ok<AGROW>
                        end
                    end


                end

                IntNumbers=[];

                for i=1:numel(obj.IrqGroup)
                    IntNumbers=[IntNumbers,getInterruptNumbers(obj.IrqGroup(i))];%#ok<AGROW>
                end
                IntNumbersStr=strsplit(num2str(IntNumbers),' ');
                RepeatingInterrupts=obj.getNonUniqueEntriesInCell(IntNumbersStr);

                if~isempty(RepeatingInterrupts)
                    IntGrp=[];


                    for i=1:numel(obj.IrqGroup)
                        IsrNumberStr=num2str(getInterruptNumbers(obj.IrqGroup(i)));
                        IsrNumberStr=strsplit(IsrNumberStr,' ');
                        if ismember(RepeatingInterrupts,IsrNumberStr)
                            IntGrp=[IntGrp,{obj.IrqGroup(i).Name}];%#ok<AGROW>
                        end
                    end


                end
            end
        end

        function setDefinitionFileName(obj,name)
            obj.DefinitionFileName=name;
            obj.TargetFolder=fileparts(fileparts(fileparts(obj.DefinitionFileName)));
            if isempty(obj.TargetFolder)
                obj.TargetFolder='.';
            end
        end

        function ret=getShortDefinitionFileName(obj)
            [~,name,ext]=fileparts(obj.DefinitionFileName);
            ret=[name,ext];
        end

        function PrRange=getPriorityRangeStruct(obj)
            validateattributes(obj.PriorityRange,{'numeric'},{'nonempty','numel',2,'increasing','nonnegative'},'','Priority range');
            PrRange=struct('Min',obj.PriorityRange(1),'Max',obj.PriorityRange(2));
        end

        function setPriorityRangeStruct(obj,PrRange)

            assert(isa(PrRange,'struct'),'Input should be a structure with fields "Min" and "Max".');
            assert(isfield(PrRange,'Min'),'Min field should present in priority range structure.');
            assert(isfield(PrRange,'Max'),'Max field should present in priority range structure.');
            assert(isequal(numel(PrRange),1),'Structure should be a scalar');

            PrRange.Min=convertStringsToChars(PrRange.Min);
            PrRange.Max=convertStringsToChars(PrRange.Max);
            PriorityRangeLoc=zeros(1,2);
            if ischar(PrRange.Min)
                PriorityRangeLoc(1)=str2double(PrRange.Min);
            else
                PriorityRangeLoc(1)=PrRange.Min;
            end

            if ischar(PrRange.Max)
                PriorityRangeLoc(2)=str2double(PrRange.Max);
            else
                PriorityRangeLoc(2)=PrRange.Max;
            end

            validateattributes(PriorityRangeLoc,{'numeric'},{'nonempty','numel',2,'increasing','nonnegative'},'','Priority range');
            obj.PriorityRange=PriorityRangeLoc;
        end

        function serialize(obj)
            docObj=obj.createDocument('productinfo');
            docObj.item(0).setAttribute('version','3.0');
            obj.setElement(docObj,obj.NameTag,obj.Name);
            obj.setElement(docObj,obj.TargetNameTag,obj.TargetName);
            obj.setElement(docObj,obj.PositivePriorityOrderTag,obj.PositivePriorityOrder);
            obj.setElement(docObj,obj.ArbitrationTag,obj.Arbitration);
            obj.setElement(docObj,obj.PriorityRangeTag,obj.getPriorityRangeStruct);
            obj.setElement(docObj,obj.SoftwareManagedPriorityTag,obj.SoftwareManagedPriority);
            obj.setElement(docObj,obj.CallbackForPriorityManagementTag,obj.CallbackForPriorityManagement);
            obj.setElement(docObj,obj.GlobalEnableFunctionTag,obj.EnableInterruptPeripheralFcn);
            obj.setElement(docObj,obj.GlobalDisableFunctionTag,obj.DisableInterruptPeripheralFcn);
            obj.setElement(docObj,obj.EnableIRQFunctionTag,obj.EnableIRQFcn);
            obj.setElement(docObj,obj.DisableIRQFunctionTag,obj.DisableIRQFcn);
            obj.setElement(docObj,obj.ClearPendingIRQFunctionTag,obj.ClearPendingIRQFcn);
            obj.setElement(docObj,obj.IRQMaskFunctionTag,obj.IRQMaskFcn);
            obj.setElement(docObj,obj.IRQUnmaskFunctionTag,obj.IRQUnmaskFcn);
            obj.setElement(docObj,obj.ConfigureIRQFunctionTag,obj.ConfigureIRQFcn);
            obj.setElement(docObj,obj.CallConfigureAfterSchedulerTag,obj.CallConfigureAfterScheduler);
            obj.setElement(docObj,obj.PrologueTag,obj.Prologue);
            obj.setElement(docObj,obj.EpilogueTag,obj.Epilogue);
            obj.setElement(docObj,obj.SynchronousSchIRQNumberTag,obj.SynchronousSchIRQNumber);
            obj.setElement(docObj,obj.GenerateInInterruptsSourceTag,obj.GenerateInInterruptsSource);


            if~isempty(obj.BlockInitFcn)
                obj.setElement(docObj,'BlockInitFcn',obj.BlockInitFcn);
            end

            if~isempty(obj.BlockMaskInitFcn)
                obj.setElement(docObj,'BlockMaskInitFcn',obj.BlockMaskInitFcn);
            end

            if~isempty(obj.BlockCopyFcn)
                obj.setElement(docObj,'BlockCopyFcn',obj.BlockCopyFcn);
            end

            if~isempty(obj.BlockDeleteFcn)
                obj.setElement(docObj,'BlockDeleteFcn',obj.BlockDeleteFcn);
            end


            targetFolder=getTargetFolder(obj);


            for i=1:numel(obj.IrqGroup)
                st=getInterruptGroupStruct(obj.IrqGroup(i));
                if isfield(st,'BuildConfigurationInfo')


                    bcObjs=st.BuildConfigurationInfo;

                    st=rmfield(st,'BuildConfigurationInfo');
                    for j=1:numel(bcObjs)
                        bcObj=bcObjs(j);
                        if isempty(bcObj.DefinitionFileName)
                            bcObj.DefinitionFileName=[st.Name,'_bc',num2str(j)];
                        end
                        fileName=codertarget.internal.makeValidFileName(bcObj.DefinitionFileName);
                        absoluteFilename=[targetFolder,'/registry/interrupts/',fileName,'.xml'];
                        bcObj.DefinitionFileName=absoluteFilename;
                        bcObj.serialize();
                        if~isempty(obj.getTargetName)
                            relativeFileName=['$(TARGET_ROOT)','/registry/interrupts/',fileName,'.xml'];
                            bcObj.DefinitionFileName=relativeFileName;
                        else
                            relativeFileName=absoluteFilename;
                        end

                        if isempty(targetFolder)
                            relativeFileName=codertarget.utils.replacePathSep(relativeFileName);
                        end
                        st.('buildconfigurationinfofile')=relativeFileName;
                    end
                end
                obj.setElement(docObj,obj.IrqGroupTag,st);
            end



            for i=1:numel(obj.BuildConfigurationInfo)
                bcObj=obj.BuildConfigurationInfo(i);
                if isempty(bcObj.DefinitionFileName)
                    bcObj.DefinitionFileName=[obj.Name,'_bc',num2str(i)];
                end
                fileName=codertarget.internal.makeValidFileName(bcObj.DefinitionFileName);
                absoluteFilename=[targetFolder,'/registry/interrupts/',fileName,'.xml'];
                bcObj.DefinitionFileName=absoluteFilename;
                bcObj.serialize();
                if~isempty(obj.getTargetName)
                    relativeFileName=['$(TARGET_ROOT)','/registry/interrupts/',fileName,'.xml'];
                    bcObj.DefinitionFileName=relativeFileName;
                else
                    relativeFileName=absoluteFilename;
                end

                relativeFileName=codertarget.utils.replacePathSep(relativeFileName);
                obj.setElement(docObj,'buildconfigurationinfofile',relativeFileName);
            end
            defName=replaceTokens(obj,obj.DefinitionFileName);

            obj.write(codertarget.utils.replacePathSep(defName),docObj);
        end

        function deserialize(obj)
            docObj=obj.read(obj.DefinitionFileName);
            prodInfoList=docObj.getElementsByTagName('productinfo');
            rootItem=prodInfoList.item(0);
            prodInfo=struct;
            if rootItem.hasAttributes
                prodInfo.(char(rootItem.getAttributes.item(0).getName))=char(rootItem.getAttributes.item(0).getValue);
            end
            if~isfield(prodInfo,'version')
                prodInfo=struct('version','1.0');%#ok<NASGU>
            end


            obj.setName(obj.getElement(rootItem,obj.NameTag,'char',0));
            obj.setTargetName(obj.getElement(rootItem,obj.TargetNameTag,'char',0));
            obj.setPriorityOrder(obj.getElement(rootItem,obj.PositivePriorityOrderTag,'logical',0));
            obj.setArbitration(obj.getElement(rootItem,obj.ArbitrationTag,'char',0));
            PrRange=obj.getElement(rootItem,obj.PriorityRangeTag,'struct');
            obj.setPriorityRangeStruct(PrRange);
            obj.setSoftwareManagedPriority(obj.getElement(rootItem,obj.SoftwareManagedPriorityTag,'logical',0),obj.getElement(rootItem,obj.CallbackForPriorityManagementTag,'char',0));
            obj.setEnableInterruptPeripheralFcn(obj.getElement(rootItem,obj.GlobalEnableFunctionTag,'char',0));
            obj.setDisableInterruptPeripheralFcn(obj.getElement(rootItem,obj.GlobalDisableFunctionTag,'char',0));
            obj.setEnableIRQFcn(obj.getElement(rootItem,obj.EnableIRQFunctionTag,'char',0));
            obj.setDisableIRQFcn(obj.getElement(rootItem,obj.DisableIRQFunctionTag,'char',0));
            obj.setClearPendingIRQFcn(obj.getElement(rootItem,obj.ClearPendingIRQFunctionTag,'char',0));
            obj.setIRQMaskFcn(obj.getElement(rootItem,obj.IRQMaskFunctionTag,'char',0));
            obj.setIRQUnmaskFcn(obj.getElement(rootItem,obj.IRQUnmaskFunctionTag,'char',0));
            obj.setConfigureIRQFcn(obj.getElement(rootItem,obj.ConfigureIRQFunctionTag,'char',0));
            obj.setCallConfigureAfterScheduler(obj.getElement(rootItem,obj.CallConfigureAfterSchedulerTag,'logical',0));
            obj.setPrologue(obj.getElement(rootItem,obj.PrologueTag,'char',0));
            obj.setEpilogue(obj.getElement(rootItem,obj.EpilogueTag,'char',0));
            obj.setSynchronousSchIRQNumber(obj.getElement(rootItem,obj.SynchronousSchIRQNumberTag,'char',0));
            obj.setGenerateInInterruptsSource(obj.getElement(rootItem,obj.GenerateInInterruptsSourceTag,'logical',0));


            addBlockCallbackFcn(obj,'BlockInitFcn',obj.getElement(rootItem,'BlockInitFcn','char',0));
            addBlockCallbackFcn(obj,'BlockMaskInitFcn',obj.getElement(rootItem,'BlockMaskInitFcn','char',0));
            addBlockCallbackFcn(obj,'BlockCopyFcn',obj.getElement(rootItem,'BlockCopyFcn','char',0));
            addBlockCallbackFcn(obj,'BlockDeleteFcn',obj.getElement(rootItem,'BlockDeleteFcn','char',0));


            targetName=obj.getTargetName;
            targetFolder=codertarget.target.getTargetFolder(targetName);
            if~isempty(targetFolder)
                obj.TargetFolder='$(TARGET_ROOT)';
            end


            IrqGroupStruct=codertarget.Info.getElement(rootItem,'IrqGroup','struct');
            for i=1:numel(IrqGroupStruct)
                irqgrp=addNewInterruptGroupStruct(obj,IrqGroupStruct(i));

                if isfield(IrqGroupStruct(i),'buildconfigurationinfofile')&&~isempty(IrqGroupStruct(i).buildconfigurationinfofile)
                    if~iscell(IrqGroupStruct(i).buildconfigurationinfofile)
                        bcfiles={IrqGroupStruct(i).buildconfigurationinfofile};
                    else
                        bcfiles=IrqGroupStruct(i).buildconfigurationinfofile;
                    end
                    for bci=1:numel(bcfiles)
                        [~,fname,ext]=fileparts(bcfiles{bci});
                        abspath=fullfile(obj.TargetFolder,'registry','interrupts',[fname,ext]);
                        abspath=codertarget.utils.replacePathSep(abspath);
                        abspath=replaceTokens(obj,abspath);
                        bcObj=codertarget.attributes.BuildConfigurationInfo(abspath);
                        addNewBuildConfigurationInfo(irqgrp,bcObj);
                    end
                end
            end


            bcfiles=codertarget.Info.getElement(rootItem,'buildconfigurationinfofile');
            if~isempty(bcfiles)
                if~iscell(bcfiles)
                    bcfiles={bcfiles};
                end
                for bci=1:numel(bcfiles)
                    [~,fname,ext]=fileparts(bcfiles{bci});
                    abspath=fullfile(obj.TargetFolder,'registry','interrupts',[fname,ext]);
                    abspath=codertarget.utils.replacePathSep(abspath);
                    abspath=replaceTokens(obj,abspath);
                    bcObj=codertarget.attributes.BuildConfigurationInfo(abspath);
                    addNewBuildConfigurationInfo(obj,bcObj);
                end
            end

            obj.validate;
        end

        function setGenerateInInterruptsSource(obj,value)
            if isempty(value)


                obj.GenerateInInterruptsSource=true;
            else
                validateattributes(value,{'numeric','logical'},{'binary','nonempty','scalar'});

                obj.GenerateInInterruptsSource=value;
            end
        end

        function addBlockCallbackFcn(obj,varargin)
            p=inputParser;
            validateFcn=@(x)(isempty(x)||ischar(convertStringsToChars(x))||isa(convertStringsToChars(x),'function_handle'));
            addParameter(p,'BlockInitFcn','',validateFcn);
            addParameter(p,'BlockMaskInitFcn','',validateFcn);
            addParameter(p,'BlockCopyFcn','',validateFcn);
            addParameter(p,'BlockDeleteFcn','',validateFcn);
            parse(p,varargin{:});

            if~isempty(p.Results.BlockInitFcn)
                obj.BlockInitFcn=p.Results.BlockInitFcn;
            end

            if~isempty(p.Results.BlockMaskInitFcn)
                obj.BlockMaskInitFcn=p.Results.BlockMaskInitFcn;
            end

            if~isempty(p.Results.BlockCopyFcn)
                obj.BlockCopyFcn=p.Results.BlockCopyFcn;
            end

            if~isempty(p.Results.BlockDeleteFcn)
                obj.BlockDeleteFcn=p.Results.BlockDeleteFcn;
            end
        end

        function ret=getBlockCallbackFcn(obj,blockCallbackFcn)
            blockCallbackFcn=validatestring(blockCallbackFcn,{'BlockInitFcn','BlockMaskInitFcn','BlockCopyFcn','BlockDeleteFcn'},'','getBlockCallbackFcn');

            ret=obj.(blockCallbackFcn);
        end
    end

    methods(Access='public',Hidden)
        function ret=getHWInterruptInfoStruct(obj)
            props=properties(obj);
            ret=[];
            for i=1:numel(props)
                if isequal(props{i},'IrqGroup')
                    for j=1:numel(obj.IrqGroup)
                        ret.(props{i})=getInterruptGroupStruct(obj.IrqGroup);
                    end
                elseif isequal(props{i},'BuildConfigurationInfo')
                else
                    ret.(props{i})=obj.(props{i});
                end
            end
        end
        function addNewBuildConfigurationInfo(h,valueToSet)
            h.addNewElementToArrayProperty(h,'BuildConfigurationInfo',valueToSet);
        end
        function allBCs=getBuildConfigurationInfo(h,varargin)
            p=inputParser;
            p.addParameter('os','any');
            p.addParameter('toolchain','any');
            p.parse(varargin{:});
            res=p.Results;
            allBCs=[];
            for i=1:numel(h.BuildConfigurationInfo)
                bcObj=h.BuildConfigurationInfo(i);
                isSupportedOS=isequal(res.os,'any')||...
                isequal(bcObj.SupportedOperatingSystems,{'all'})||...
                ismember(res.os,bcObj.SupportedOperatingSystems);
                isSupportedToolchain=isequal(res.toolchain,'any')||...
                isequal(bcObj.SupportedToolchains,{'all'})||...
                ismember(res.toolchain,bcObj.SupportedToolchains);
                if isSupportedOS&&isSupportedToolchain
                    allBCs=[allBCs,bcObj];%#ok<AGROW>
                end
            end
        end
    end

    methods(Hidden)
        function setArbitration(obj,value)
            if isnumeric(value)||islogical(value)
                validateattributes(value,{'numeric','logical'},{'binary','scalar'},'','Arbitration');
                if isequal(value,1)
                    obj.Arbitration='Positive';
                else
                    obj.Arbitration='Negative';
                end
            else
                value=convertStringsToChars(value);
                value=validatestring(value,{'Positive','Negative'},'','Arbitration');
                obj.Arbitration=value;
            end
        end

        function setPrologue(obj,value)
            obj.Prologue=value;
        end

        function setEpilogue(obj,value)
            obj.Epilogue=value;
        end

        function IntrGrp=addNewInterruptGroupStruct(obj,InterruptGroupStruct)
            assert(isa(InterruptGroupStruct,'struct'),'Input should be structure.');
            assert(isfield(InterruptGroupStruct,'Name'),'Input should contain a field with Name.');
            assert(isfield(InterruptGroupStruct,'IrqInfo'),'Input should contain field with IrqInfo.');
            assert(isfield(InterruptGroupStruct,'IsrDefinitionSignature'),'Input should contain field with IsrDefinitionSignature.');
            assert(isequal(numel(InterruptGroupStruct),1),'Structure should be a scalar.');

            obj.IrqGroup(end+1)=codertarget.interrupts.InterruptGroup(InterruptGroupStruct.Name);

            IntrGrp=obj.IrqGroup(end);
            setIsrDefinitionSignature(IntrGrp,InterruptGroupStruct.IsrDefinitionSignature);

            for i=1:numel(InterruptGroupStruct.IrqInfo)
                if~isempty(InterruptGroupStruct.IrqInfo(i))
                    addNewInterruptStruct(IntrGrp,InterruptGroupStruct.IrqInfo(i));
                end
            end
        end

        function dstStr=replaceTokens(obj,dstStr,warnIfBadToken)%#ok<INUSD> 

            knownTokens={'$(TARGET_ROOT)','$(MATLAB_ROOT)'};
            for j=1:length(knownTokens)
                token=knownTokens{j};
                switch token
                case '$(TARGET_ROOT)'
                    tgtFolder=getTargetFolder(obj);
                    dstStr=strrep(dstStr,token,tgtFolder);
                case '$(MATLAB_ROOT)'
                    dstStr=strrep(dstStr,token,matlabroot);
                end
            end
        end

        function tgtFolder=getTargetFolder(obj)
            targetName=obj.getTargetName;
            tgtFolder=codertarget.target.getTargetFolder(targetName);
            if isempty(tgtFolder)
                tgtFolder=obj.TargetFolder;
            end
        end
    end

    methods(Static)
        function repeat_entries=getNonUniqueEntriesInCell(cell_array)
            [~,~,idx]=unique(cell_array,'stable');
            unique_idx=accumarray(idx(:),(1:length(idx))',[],@(x){(x)});
            repeat_idx=unique_idx(cellfun(@(x)(numel(x)>1),unique_idx));

            repeat_entries=[];
            if~isempty(repeat_idx)
                repeat_entries=cell_array{repeat_idx{1}(1)};
                for i=2:numel(repeat_idx)
                    repeat_entries=[repeat_entries,', ',cell_array{repeat_idx{i}(1)}];%#ok<AGROW>
                end
            end
        end
    end
end




