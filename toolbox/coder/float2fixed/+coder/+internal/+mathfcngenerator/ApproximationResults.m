


classdef ApproximationResults
    properties
        DesignFile=''
        TestBenchFile=''
    end
    properties(Hidden)
        Error=struct('Absolute',[],'Relative',[],'MeanSquared',[]);
        LookupTable=struct('NumberOfPoints',[]);
        CORDIC=struct();
    end
    methods
        function disp(obj)
            disp(['   DesignFile : ''',obj.DesignFile,''''])
            disp(['TestBenchFile : ''',obj.TestBenchFile,''''])
        end
    end
end


