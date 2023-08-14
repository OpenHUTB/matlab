function val=checkSetDeploymentConfigSet(cs,opt,type,varargin)




    assert(strcmp(type,'model')||strcmp(type,'parallel'));
    assert(length(varargin)<=1);

    switch opt
    case 'check'
        val=checkDeploymentConfigSet(cs);
    case 'set'
        setDeploymentConfigSet(cs);
        val=[];
    case 'checkArchitecture'
        assert(isequal(length(varargin),1));
        val=checkArchitectureConfigSet(cs,varargin{1});
    otherwise
        assert(false,'Unhandled opt argument in checkSetDeploymentConfigSet');
    end






    function val=checkDeploymentConfigSet(cs)

        val=[];

        if isa(cs,'Simulink.ConfigSetRef')
            cs=cs.getRefConfigSet;
        end

        props=requiredProperties(cs);

        skipProps={'TargetLang','TargetOS'};

        for pIdx=1:2:length(props)
            propName=props{pIdx};
            propVal=props{pIdx+1};

            if any(strcmp(skipProps,propName)),continue;end;

            if isValidParam(cs,propName)&&...
                ~strcmpi(get_param(cs,propName),propVal)
                val=[val,{propName}];%#ok
                val=[val,{propVal}];%#ok
            end
        end


        if isValidParam(cs,'CodeInterfacePackaging')&&...
            strcmpi(get_param(cs,'CodeInterfacePackaging'),'Reusable function')
            val=[val,{'CodeInterfacePackaging'}];%#ok
            val=[val,{'Nonreusable function'' or ''C++ class'}];%#ok        
        end





        function setDeploymentConfigSet(cs)

            if isa(cs,'Simulink.ConfigSetRef')
                return;
            end

            props=requiredProperties(cs);
            for pIdx=1:2:length(props)
                propName=props{pIdx};
                propVal=props{pIdx+1};
                if isValidParam(cs,propName)
                    set_param(cs,propName,propVal);
                end
            end





            function props=requiredProperties(cs)

                assert(~isa(cs,'Simulink.ConfigSetRef'));

                props={...
                'SolverType','Fixed-step',...
                'EnableFixedStepZeroCrossing','off',...
                'MultiTaskDSMMsg','error',...
                'MultiTaskCondExecSysMsg','error',...
                'MultiTaskRateTransMsg','error',...
                };

                if strcmpi(get_param(cs,'SystemTargetFile'),'ert.tlc')
                    props=[props,{'TargetOS','NativeThreadsExample'}];
                end













                function errs=checkArchitectureConfigSet(cs,arch)

                    errs=[];

                    if isa(cs,'Simulink.ConfigSetRef')
                        cs=cs.getRefConfigSet;
                    end

                    for pIdx=1:length(arch.ConfigSetConstraints)
                        propName=arch.ConfigSetConstraints(pIdx).ParameterName;
                        propVal=arch.ConfigSetConstraints(pIdx).ParameterValues;


                        if isValidParam(cs,propName)&&...
                            ~any(strcmpi(get_param(cs,propName),propVal)==1)





                            if(strcmpi(propName,'SystemTargetFile')==1)
                                stf=get_param(cs,propName);
                                if(strcmpi(stf,'rsim.tlc')==1)||...
                                    (strcmpi(stf,'raccel.tlc')==1)
                                    continue;
                                end
                            end

                            errs=[errs,{propName}];%#ok
                            val=propVal(1);
                            for j=2:length(propVal)
                                val=strcat(val,',',propVal(j));
                            end
                            errs=[errs,val{1}];%#ok
                        end
                    end



