classdef ReservedNamesChecker




















































    properties(Constant)
        DefaultExclusionList={
        'Vector','Matrix','BlockIO','ExternalInputs','ContinuousStates'...
        ,'StateDerivatives','StateDisabled','CstateAbsTol','ExternalOutputs'...
        ,'Parameters','ConstParam','ConstParamWithInit'}
    end

    properties(SetAccess=immutable)
ExclusionList
    end

    methods(Access=private)
        function obj=ReservedNamesChecker(listToUse)
            obj.ExclusionList=listToUse;
        end

        function out=mangleName(obj,name)%#ok<INUSL>
            out=[name,'_'];
        end

        function out=unmangleName(~,name)
            assert(endsWith(name,'_'));
            out=name(1:end-1);
        end
    end


    methods(Access={?dds.bus.ReservedNamesChecker,?matlab.unittest.TestCase})
        function out=isMangledName(obj,name)


            out=name(end)=='_'&&ismember(name(1:end-1),obj.ExclusionList);
        end
    end


    methods
        function out=isReserved(obj,name)



            out=ismember(name,obj.ExclusionList);
        end

        function[out,isReserved]=mangleNameIfNeeded(obj,name)






            isReserved=ismember(name,obj.ExclusionList);
            if isReserved
                out=obj.mangleName(name);
            else
                out=name;
            end
        end

        function[out,isReserved]=unmangleNameIfMangled(obj,name)





            isReserved=startsWith(name,dds.internal.simulink.ReservedNamesChecker.DefaultExclusionList);
            if isReserved
                out=obj.unmangleName(name);
            else
                out=name;
            end
        end
    end


    methods(Static)
        function[isAvailable,list]=exclusionListForTesting(listToUse)







            persistent exclusionList
            if nargin>0

                assert(isempty(listToUse)||iscellstr(listToUse)||isstring(listToUse));
                exclusionList=listToUse;
            end
            isAvailable=~(isa(exclusionList,'double')&&isempty(exclusionList));
            list=exclusionList;
        end

        function obj=getInstance()
            [isAvailable,list]=dds.internal.simulink.ReservedNamesChecker.exclusionListForTesting();
            if isAvailable
                obj=dds.internal.simulink.ReservedNamesChecker(list);
            else
                obj=dds.internal.simulink.ReservedNamesChecker(...
                dds.internal.simulink.ReservedNamesChecker.DefaultExclusionList);
            end
        end

    end

end
