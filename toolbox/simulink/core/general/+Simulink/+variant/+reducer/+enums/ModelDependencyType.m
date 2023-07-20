




classdef ModelDependencyType<uint8

    enumeration
        IGNORABLE(0);
        COMMON_REDUCIBLE(1);
        SELF_REDUCIBLE(2);
        NON_REDUCIBLE(3);
    end

end