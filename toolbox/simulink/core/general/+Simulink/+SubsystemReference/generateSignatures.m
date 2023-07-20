function generateSignatures(varargin)











    narginchk(1,2);
    ssbd=varargin{1};
    inputType=get_param(ssbd,'Type');
    validType=strcmp(inputType,'block_diagram')&&bdIsSubsystem(ssbd);
    if~validType
        error(message('Simulink:SubsystemReference:InputMustBeSSBD'));
    end

    if 1==size(varargin)
        generateSignatureForUnitTest(ssbd);
        return;
    end

    input_unittest_names=varargin{2};
    if~iscell(input_unittest_names)
        error(message('Simulink:SubsystemReference:InputMustBeCellArrayOfUTNames'));
    end

    all_unittest_names=get_param(ssbd,'UnitTestNames');
    for index=1:length(input_unittest_names)
        unittest_name=input_unittest_names{index};
        if~any(strcmp(all_unittest_names,unittest_name))
            error(message('Simulink:SubsystemReference:InvalidTHName',...
            unittest_name,get_param(ssbd,'name')));
        end
        generateSignatureForUnitTest(ssbd,unittest_name);
    end
end

