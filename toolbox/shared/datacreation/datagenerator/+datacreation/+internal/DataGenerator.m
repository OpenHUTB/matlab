classdef DataGenerator<handle





    properties(Access='private')
        MUST_HAVE_FIELDS={'dataIn','timeIn','dataGenFunction'}

    end


    methods(Static)
        function aFactory=getInstance()
            persistent instance;
            mlock;

            if isempty(instance)
                instance=DataGenerator();
            end

            aFactory=instance;
        end


        function dataOut=randBetweenValues(lowerVal,upperVal)

            dataOut=lowerVal+(upperVal-lowerVal).*rand(size(lowerVal));
        end
    end


    methods


        function[dataOut,timeOut]=generateDataFromABaseLine(obj,inProperties)

            try
                checkInProperties(obj,inProperties);
            catch ME
                throwAsCaller(ME);
            end

            dataGenFcnH=str2func(inProperties.dataGenFunction);

            try
                [dataOut,timeOut]=dataGenFcnH(inProperties);
            catch ME
                throwAsCaller(ME);
            end
        end


        function propStruct=getCustomPropsFromString(obj,custProps)
            evalc(custProps);
            varsFromProps=who;
            propStruct=struct;
            for k=1:length(varsFromProps)
                if~any(strcmpi(varsFromProps{k},{'obj','custProps','ans'}))
                    propStruct.(varsFromProps{k})=eval(varsFromProps{k});
                end
            end
        end

    end


    methods(Access='protected')


        function obj=DataGenerator()

        end

    end


    methods(Access='private')


        function checkInProperties(obj,inProperties)


            errStr='input arguement must be a structure with fields dataIn and timeIn.';


            if~isstruct(inProperties)
                error(errStr);

            end


            if~all(isfield(inProperties,obj.MUST_HAVE_FIELDS))
                error(errStr);

            end


            if~isvector(inProperties.timeIn)||~strcmpi(class(inProperties.timeIn),'double')
                error('timeIn must be a vector of type double');
            end



            if length(inProperties.timeIn)~=length(inProperties.dataIn)
                error('timeIn and dataIn vectors must match length.');
            end
        end
    end
end

