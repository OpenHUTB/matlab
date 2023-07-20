classdef MemoryProfiler<TargetsMemory_MemoryProfiler









    properties(SetAccess='protected')

        memoryBuffers;
        resetWords;

        ideObj;
    end

    methods(Access='protected')
        function write(this,memoryBuffer,resetWord)







            narginchk(3,3);


            memUnits=typecast(resetWord,memoryBuffer.dataType);


            numWords=memoryBuffer.memSize;
            memUnits=repmat(memUnits,1,numWords);


            this.ideObj.write([memoryBuffer.baseAddress,memoryBuffer.addressPage],memUnits);

        end

        function words=read(this,memoryBuffer)







            narginchk(2,2);


            this.validateBufferSize(memoryBuffer);


            memUnits=this.ideObj.read(...
            [memoryBuffer.baseAddress,memoryBuffer.addressPage],...
            memoryBuffer.dataType,...
            memoryBuffer.memSize);


            wordType=class(this.resetWords);
            words=typecast(memUnits,wordType);

        end

    end

    methods
        function setup(this,varargin)

            narginchk(1,1);

            this.reset;

        end
    end




    methods(Access='public')


        function this=MemoryProfiler(memoryBuffers,resetWords,ideObj)


            narginchk(3,3);




            class_memoryBuffers='linkfoundation.autointerface.MemoryBuffer';
            if~isa(memoryBuffers,class_memoryBuffers)
                error(message('ERRORHANDLER:autointerface:InvalidMemoryBufferObject',class(memoryBuffers),class_memoryBuffers));
            end


            if length(memoryBuffers)~=length(resetWords)
                error(message('ERRORHANDLER:autointerface:InconsistentResetWordsSize'));
            end

            ideObjClass='linkfoundation.autointerface.baselink';
            if~isa(ideObj,ideObjClass)
                error(message('ERRORHANDLER:autointerface:InvalidIDEObject',class(ideObj),ideObjClass));
            end





            this.memoryBuffers=memoryBuffers;
            this.resetWords=resetWords;
            this.ideObj=ideObj;
        end

    end




    methods(Access='private')

        function validateBufferSize(this,memoryBuffer)

        end

    end
end

