


classdef Flavor_CppEnc<simulinkcoder.internal.wizard.OptionBase
    methods
        function obj=Flavor_CppEnc(env)
            id='Flavor_CppEnc';
            obj@simulinkcoder.internal.wizard.OptionBase(id,env);
            obj.NextQuestion_Id='Optimization';
            obj.Type='radio';
            obj.Value=false;
            obj.DepInfo='';
        end

        function onNext(obj)
            env=obj.Env;
            env.CSM.SwitchToGRT;
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
        end
    end
end


