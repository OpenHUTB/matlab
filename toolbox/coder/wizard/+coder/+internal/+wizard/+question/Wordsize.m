



classdef Wordsize<coder.internal.wizard.QuestionBase
    properties
        HWCC=[]
    end
    methods
        function obj=Wordsize(env)
            id='Wordsize';
            topic=message('RTW:wizard:Topic_Wordsize').getString;
            obj@coder.internal.wizard.QuestionBase(id,topic,env);


            obj.getAndAddOption(env,'Wordsize_HardwareFamily');
            obj.getAndAddOption(env,'Wordsize_Processor');

            obj.getAndAddOption(env,'Wordsize_Table');

        end
        function out=getHWCC(obj)
            if isempty(obj.HWCC)
                env=obj.Env;
                obj.HWCC=env.CSM.getHWCC;
            end
            out=obj.HWCC;
        end
        function refresh_question=applyOnChange(obj)
            refresh_question=true;
            isCustomBeforeChange=obj.isCustom;
            obj.onChange;
            isCustomAfterChange=obj.isCustom;


            if isCustomBeforeChange&&isCustomAfterChange
                refresh_question=false;
            end
        end
        function onChange(obj)
            env=obj.Env;
            q=env.CurrentQuestion;
            prodVendor=q.Options{1}.Answer;
            typeOption=q.Options{2};
            prodType=q.Options{2}.Answer;
            if~obj.isCustom
                hh=targetrepository.getHardwareImplementationHelper();
                devices=hh.getDevices('Production',prodVendor);
                if~isempty(devices)
                    hwTypes={devices.Name};
                    if~ismember(prodType,hwTypes)


                        typeOption.Value=hwTypes;
                        prodType=hwTypes{1};

                        obj.Options{2}.setAnswer(prodType);
                    end
                end

                ProdHWDeviceType=[prodVendor,'->',prodType];
                hwCC=obj.getHWCC();
                hwCC.setPropEnabled('ProdHWDeviceType',true);
                slprivate('setHardwareDevice',hwCC,'Production',ProdHWDeviceType);

                env.CSM.setHardwareDevice(ProdHWDeviceType);
            else

                ProdHWDeviceType='Custom Processor->Custom';
                hwCC=obj.getHWCC();
                hwCC.setPropEnabled('ProdHWDeviceType',true);
                slprivate('setHardwareDevice',hwCC,'Production',ProdHWDeviceType);
                env.CSM.setHardwareDevice(ProdHWDeviceType);

                o=env.getOptionObj('Wordsize_Table');
                o.applyChangeToHWCC;
            end
        end
        function[prodVendor,prodType]=getDefaultHW(~)
            persistent prodVendorCache;
            persistent prodTypeCache;
            if isempty(prodVendorCache)
                defaultCS=Simulink.ConfigSet;
                defaultVal=get_param(defaultCS,'ProdHWDeviceType');
                delimLocation=strfind(defaultVal,'->');
                assert(~isempty(delimLocation),'The production hardware device type string (ProdHWDeviceType) is incorrectly formatted');
                prodVendorCache=defaultVal(1:delimLocation-1);
                prodTypeCache=defaultVal(delimLocation+2:end);
            end
            prodVendor=prodVendorCache;
            prodType=prodTypeCache;
        end
        function preShow(obj)
            preShow@coder.internal.wizard.QuestionBase(obj);

            env=obj.Env;
            if~obj.isAnswered

                tr=RTW.TargetRegistry.get();
                filtered={'ASIC/FPGA'};
                hh=targetrepository.getHardwareImplementationHelper();


                changeToDefault=false;
                prodDevice=env.CSM.getProdDevice(hh);
                if isempty(prodDevice)||isa(prodDevice,'target.internal.FPGA')||prodDevice.Grandfathered

                    [prodVendor,prodType]=obj.getDefaultHW();
                    changeToDefault=true;
                    devices=hh.getDevices(target.internal.compatibility.HardwareImplementationPlatform.Production,prodVendor);
                else
                    if isempty(prodDevice.Manufacturer)
                        prodVendor=prodDevice.Name;
                        devices=prodDevice;
                    else
                        prodVendor=prodDevice.Manufacturer;
                        devices=hh.getDevices(target.internal.compatibility.HardwareImplementationPlatform.Production,prodVendor);
                    end

                    prodType=prodDevice.Name;
                end


                o=env.getOptionObj('Wordsize_Processor');
                o.setAnswer(prodType);
                o.Value={devices.Name}';

                hw_family=hh.getVendorList(target.internal.compatibility.HardwareImplementationPlatform.Production);

                hw_family=hw_family(~ismember(hw_family,filtered));

                o=env.getOptionObj('Wordsize_HardwareFamily');
                o.setAnswer(prodVendor);
                o.Value=hw_family;

                if changeToDefault
                    obj.onChange;
                end
            end


            o=env.getOptionObj('Wordsize_Table');
            o.setWordsizeTable;
        end
        function out=isAnswered(obj)
            env=obj.Env;
            o1=env.getOptionObj('Wordsize_Processor');
            o2=env.getOptionObj('Wordsize_HardwareFamily');
            NotAnswered=isnumeric(o1.Answer)&&o1.Answer==-1&&isnumeric(o2.Answer)&&o2.Answer==-1;
            out=~NotAnswered;
        end
        function out=isCustom(obj)
            prodVendor=obj.Options{1}.Answer;
            prodType=obj.Options{2}.Answer;
            out=(strcmp(prodVendor,'Generic')&&strcmp(prodType,'Custom'))||...
            (strcmp(prodVendor,'Custom Processor')&&strcmp(prodType,'Custom Processor'));
        end
        function out=getSummary(obj)
            out='';
            if obj.Options{1}.Answer==-1
                return;
            end
            if~obj.isCustom
                out=[message('RTW:wizard:QuestionSummary_Wordsize').getString,': ',obj.Options{1}.Answer,'->',obj.Options{2}.Answer];
            else
                out=[message('RTW:wizard:QuestionSummary_Wordsize').getString,': ',message('RTW:wizard:CustomWordsize').getString];
            end
        end
        function onNext(obj)
            env=obj.Env;

            if obj.isCustom
                o=env.getOptionObj('Wordsize_Table');
                o.applyChangeToChangeLog;
            end
        end
    end
end


