


classdef Flavor_CppEnc<coder.internal.wizard.OptionBase
    methods
        function obj=Flavor_CppEnc(env)
            id='Flavor_CppEnc';
            obj@coder.internal.wizard.OptionBase(id,env);
            obj.NextQuestion_Id='Analyze';
            obj.Type='radio';
            obj.Value=false;
            obj.DepInfo='';
        end

        function onNext(obj)
            env=obj.Env;
            env.CSM.SwitchToERT;
            env.setParamRequired('TargetLang','C++');
            obj.configureForCpp();
            env.Flavor='CppEncap';
        end


        function configureForCpp(obj)
            env=obj.Env;

            env.setParamRequired('CodeInterfacePackaging','C++ class');



            env.setParamRequired('ZeroExternalMemoryAtStartup','off');
            env.setParamRequired('GenerateExternalIOAccessMethods','None');
            env.setParamRequired('ExternalIOMemberVisibility','public');

            env.setParamRequired('GenerateTestInterfaces','off');
            env.setParamRequired('CombineOutputUpdateFcns','on');
            env.setParamRequired('GenerateAllocFcn','off');
            env.setParamRequired('GRTInterface','off');
            env.setParamRequired('GenerateASAP2','off');
            env.setParamRequired('RootIOFormat','structure reference');
            env.setParamRequired('RateGroupingCode','on');
        end
    end
end
