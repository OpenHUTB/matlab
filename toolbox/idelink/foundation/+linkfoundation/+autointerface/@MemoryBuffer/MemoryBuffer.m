classdef MemoryBuffer<TargetsMemory_MemoryBuffer

















    properties(SetAccess='protected')
        dataType;
        addressPage;
    end

    methods



        function this=MemoryBuffer(...
            name,...
            baseAddress,...
            memSize,...
            dataType,...
            growDirection)

            narginchk(5,5);

            if strcmpi(growDirection,'ascending')
                growDirection='up';
            elseif strcmpi(growDirection,'descending')
                growDirection='down';
            else
                error(message('ERRORHANDLER:utils:InvalidStackGrowthDirection',growDirection));
            end


            this=this@TargetsMemory_MemoryBuffer(name,...
            baseAddress(1),...
            memSize,...
            growDirection);


            this.dataType=dataType;
            this.addressPage=baseAddress(2);

        end

    end

end