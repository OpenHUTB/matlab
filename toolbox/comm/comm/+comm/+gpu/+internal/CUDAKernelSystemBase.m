classdef CUDAKernelSystemBase<comm.gpu.internal.GPUBase

    properties(Constant,GetAccess=protected)
        MaxThreadBlockSize=256;

    end


    properties(Access=private)
ptxext

    end


    methods
        function this=CUDAKernelSystemBase(varargin)
            this@comm.gpu.internal.GPUBase(varargin);

            this.ptxext=parallel.gpu.ptxext;

        end
    end


    methods(Access=protected)
        function ker=makeKernel(this,proto,func,dt,kernelFile)
            kerFile=makePTXFilename(this,kernelFile);
            kerName=comm.gpu.internal.makePTXFunction(func,dt);
            ker=parallel.gpu.CUDAKernel(kerFile,proto,kerName);

        end
    end


    methods(Access=protected)
        function fname=makePTXFilename(this,filebasename)
            ptxfile=[filebasename,'.',this.ptxext];
            fname=fullfile(toolboxdir('comm'),'gpu','commptx',dct_arch,ptxfile);
        end
    end


end


