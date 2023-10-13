classdef MIDIInterface<handle


    properties(Access=private)

pSystemUnderTest

pControls

pLaws

        pOKToSync=true;

pSUTType

pTuningInterface
    end

    events

ParameterChangedViaMIDI
    end

    methods(Hidden)
        function delete(obj)

            disconnect(obj);
        end
    end

    methods
        function obj=MIDIInterface(SUT)


            obj.pSystemUnderTest=SUT;
            if isa(SUT,'audio.internal.loadableAudioPlugin')
                obj.pSUTType='ExternalAudioPlugin';
            elseif isa(SUT,'audioPlugin')||isa(SUT,'audioPluginSource')
                obj.pSUTType='AudioPlugin';
            else
                obj.pSUTType='ASTSystemObject';
            end
        end

        function disconnect(obj,varargin)
            entries=getSelectedEntries(obj,varargin{:});
            obj.pControls(entries)=[];
            obj.pLaws(entries)=[];
        end

        function p=getConnections(obj)

            p=[];
            isExtPlugin=strcmp(obj.pSUTType,'ExternalAudioPlugin');
            for index=getSelectedEntries(obj)
                propInfo=obj.pLaws{index};
                propName=propInfo.Property;

                if isExtPlugin
                    p.(propName).ParameterIndex=propInfo.Index;
                    p.(propName).DisplayName=propInfo.DisplayName;
                else
                    p.(propName).Law=propInfo.Law;
                    switch propInfo.Law
                    case{'lin','log','int','fader'}
                        p.(propName).Min=propInfo.Min;
                        p.(propName).Max=propInfo.Max;
                    case 'pow'
                        p.(propName).Min=propInfo.Min;
                        p.(propName).Max=propInfo.Max;
                        p.(propName).Pow=propInfo.Pow;
                    case{'enum','enumclass'}
                        p.(propName).Law='enum';
                        p.(propName).Enums=propInfo.Enums;
                    end
                end
                str=evalc('disp(obj.pControls{index})');
                str=strrep(str,'midicontrols object: ','');
                str=strrep(str,newline,'');
                p.(propName).MIDIControl=str;
            end
        end

        function configure(obj,propertyName,controlNumber,deviceName,enableCodeGeneration)

            if~isempty(propertyName)
                connectToProperty(obj,propertyName,controlNumber,deviceName);
            else
                params=getTuningInterface(obj);
                names=fieldnames(params);
                L=length(names);
                MIDIInfo={};
                for index=1:L
                    MIDIInfo{end+1}=params.(names{index});;%#ok
                end

                [MIDIControls,MIDIMappings]=getCachedConnections(obj,MIDIInfo);
                obj.pOKToSync=false;
                launchMIDIUI(obj,MIDIInfo,MIDIControls,MIDIMappings,enableCodeGeneration)
                obj.pOKToSync=true;
            end
        end

        function flag=skipSync(obj)
            flag=~obj.pOKToSync;
        end
    end

    methods(Hidden)
        function updateConnectedMIDIControl(obj,propertyName)


            entries=getSelectedEntries(obj,propertyName);
            isExtPlugin=strcmp(obj.pSUTType,'ExternalAudioPlugin');
            for idx=entries
                midiControl=obj.pControls{idx};
                param=obj.pLaws{idx};
                if isExtPlugin
                    val=getPropertyValue(obj,param.Index);
                    midisync(midiControl,val);
                else
                    val=getPropertyValue(obj,param.Property);
                    [~,fromPropFcn]=getPluginMappingRules(param);
                    midisync(midiControl,fromPropFcn(val));
                end
            end
        end

        function p=getConnectedMIDIControls(obj,varargin)



            p=[];
            for index=getSelectedEntries(obj,varargin{:})
                propName=obj.pLaws{index}.Property;
                [p.(propName).ControlNumber,p.(propName).DeviceName]=...
                midiinfo(obj.pControls{index});
            end
        end
    end

    methods(Access=protected)
        function entries=getSelectedEntries(obj,propertyName)

            entries=[];
            if nargin>1&&~isempty(propertyName)
                for index=1:length(obj.pControls)
                    if strcmp(obj.pLaws{index}.Property,propertyName)
                        entries=index;
                        return;
                    end
                end
            else
                entries=1:length(obj.pControls);
            end
        end

        function[pCachedMIDIControls,pMIDIMappings]=getCachedConnections(obj,MIDIInfo)

            L=length(MIDIInfo);
            pCachedMIDIControls={};
            pMIDIMappings={};
            for index=1:L
                for index2=1:length(obj.pControls)
                    if strcmp(MIDIInfo{index}.Property,obj.pLaws{index2}.Property)
                        pCachedMIDIControls{end+1}=obj.pControls{index2};%#ok
                        pMIDIMappings{end+1}=obj.pLaws{index2};%#ok
                        break;
                    end
                end
            end
        end

        function params=getTuningInterface(obj)


            SUT=obj.pSystemUnderTest;
            if isempty(obj.pTuningInterface)||strcmp(obj.pSUTType,'ASTSystemObject')


                if isa(SUT,'audio.internal.loadableAudioPlugin')
                    [~,params]=audio.testbench.internal.ExternalAudioPluginTuningModel.getAudioPluginInterface(SUT);
                elseif isa(SUT,'audioPlugin')
                    [~,paramStruct]=checkPluginClass(class(SUT));
                    for index=1:length(paramStruct)
                        params.(paramStruct(index).Property)=paramStruct(index);
                    end
                else
                    interface=SUT.getDefaultPluginInterface;
                    params=interface.Parameters;
                end
                obj.pTuningInterface=params;
            end
            params=obj.pTuningInterface;
        end

        function val=getPropertyValue(obj,propName)
            SUT=obj.pSystemUnderTest;
            if strcmp(obj.pSUTType,'ExternalAudioPlugin')
                val=getParameter(SUT,propName);
            else
                val=SUT.(propName);
            end
        end

        function connectToProperty(obj,propName,MIDIControlNumber,MIDIDevice)


            SUT=obj.pSystemUnderTest;
            val=getPropertyValue(obj,propName);


            IsVector=false;
            if~ischar(val)&&~isscalar(val)
                IsVector=true;
                L=length(val);
            else
                L=1;
            end

            params=getTuningInterface(obj);


            paramNames=fieldnames(params);
            if strcmp(obj.pSUTType,'ExternalAudioPlugin')
                if isnumeric(propName)
                    propIdx=propName;
                else
                    propIdx=1;
                    for idx=1:length(paramNames)
                        if strcmp(params.(paramNames{idx}).DisplayName,propName)
                            propIdx=idx;
                            break;
                        end
                    end
                end
                propName=paramNames{propIdx};
            elseif~isfield(params,propName)&&isfield(params,[propName,'1'])
                IsVector=true;
            end

            MIDIControlNumberCell=cell(1,L);
            if isscalar(MIDIControlNumber)||isempty(MIDIControlNumber)
                for ind=1:L
                    MIDIControlNumberCell{ind}=MIDIControlNumber;
                end
            else
                coder.internal.errorIf(length(MIDIControlNumber)~=L,'audio:shared:MIDIControlWrongLength');
                for ind=1:L
                    MIDIControlNumberCell{ind}=MIDIControlNumber(ind);
                end
            end

            MIDIDeviceCell=cell(1,L);
            if ischar(MIDIDevice)||isempty(MIDIDevice)
                for ind=1:L
                    MIDIDeviceCell{ind}=MIDIDevice;
                end
            else
                coder.internal.errorIf(length(MIDIDevice)~=L,'audio:shared:MIDIDeviceWrongLength');
                MIDIDeviceCell=MIDIDevice;
            end

            for index=1:L






                if IsVector
                    PropertyName=[propName,num2str(index)];
                else
                    PropertyName=propName;
                end


                ind=length(obj.pLaws)+1;
                for index2=1:length(obj.pLaws)
                    if strcmp(obj.pLaws{index2}.Property,PropertyName)
                        ind=index2;
                        break;
                    end
                end

                [fromNormFcn,fromPropFcn]=getPluginMappingRules(params.(PropertyName));
                if IsVector
                    v=val(index);
                else
                    v=val;
                end
                initialMIDIVal=fromPropFcn(v);

                if isempty(MIDIDeviceCell{index})
                    midicontrol=midicontrols(MIDIControlNumberCell{index},initialMIDIVal);
                else
                    midicontrol=midicontrols(MIDIControlNumberCell{index},initialMIDIVal,'MIDIDevice',MIDIDeviceCell{index});
                end
                if~contains(evalc('midicontrol'),'no MIDI device')
                    if strcmp(obj.pSUTType,'ExternalAudioPlugin')
                        midicallback(midicontrol,@(midicontrol)midiObjectCallbackExternalPlugin(...
                        midicontrol,SUT,params.(PropertyName),obj));
                    else
                        midicallback(midicontrol,@(midicontrol)midiObjectCallback(...
                        midicontrol,SUT,PropertyName,fromNormFcn,obj));
                    end
                    midisync(midicontrol,initialMIDIVal);
                    obj.pControls{ind}=midicontrol;
                    obj.pLaws{ind}=params.(PropertyName);
                end
            end
        end

        function launchMIDIUI(obj,MIDIInfo,pMIDIControls,pMIDIMappngs,enableCodeGeneration)
            SUT=obj.pSystemUnderTest;
            [controls,mappings]=configureMIDIDevice(SUT,MIDIInfo,pMIDIControls,pMIDIMappngs,obj,enableCodeGeneration);
            for index=1:length(controls)

                for index2=1:length(obj.pLaws)
                    if strcmp(obj.pLaws{index2}.Property,mappings{index}.Property)
                        obj.pControls(index2)=[];
                        obj.pLaws(index2)=[];
                        break;
                    end
                end

                if~isempty(controls{index})
                    obj.pControls{end+1}=controls{index};
                    obj.pLaws{end+1}=mappings{index};
                end
            end
        end
    end

    methods(Static)
        function checkObjectValidity(SUT)


            coder.internal.errorIf(~MIDIInterface.isSupported(SUT),'audio:shared:NoMIDISupport');
        end

        function flag=isSupported(SUT)
            if isa(SUT,'audioPlugin')||isa(SUT,'audioPluginSource')
                flag=true;
                return;
            else
                mc=metaclass(SUT);
                names={mc.MethodList.Name};
                flag=~isempty(find(ismember(names,'getDefaultPluginInterface'),1));
            end
        end
    end
end