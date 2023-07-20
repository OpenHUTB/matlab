


classdef CImplementation

    properties
        Name='';
        Arguments={};
        Return=[];
        SamplePeriod=-1;
        SampleOffset=-1;
        OwnerClass='';
    end

    methods


        function flag=hasReturn(aObj)
            flag=~isempty(aObj.Return);
        end

    end

end
