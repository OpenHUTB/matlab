classdef(Sealed)DataGenerator<fixed.DataGeneratorEngine




















    methods

        function obj=DataGenerator(varargin)









            obj=obj@fixed.DataGeneratorEngine(varargin{:});
        end

        function varargout=getUniqueValues(obj)





            narginchk(1,1);
            nargoutchk(0,numel(obj.DataSpecifications));
            validateattributes(obj,{'fixed.DataGenerator'},{'scalar'},1);

            if~obj.isLocked


                obj.setup;
                cleanupObj=onCleanup(@()release(obj));
            end
            varargout=obj.ValueSets;
        end

        function varargout=outputAllData(obj,format)



















            narginchk(1,2);
            nargoutchk(0,numel(obj.DataSpecifications));
            validateattributes(obj,{'fixed.DataGenerator'},{'scalar'},1);
            if nargin==1
                format='array';
            else
                format=validatestring(format,{'array','timeseries','Dataset'},2);
            end

            if~obj.isLocked


                obj.setup;
                cleanupObj=onCleanup(@()release(obj));
            end


            th=2^31-1;
            assert(double(obj.CPFold)*obj.CPSize<=th,...
            message("fixed:datagen:excessiveOutputSize",th));


            outbuf=cell(1,obj.NumDataSpecs);
            cpsz=obj.CPSize;
            nrep=1;
            ncyc=cpsz;
            for i=1:obj.NumDataSpecs
                vs=reshape(obj.ValueSets{i},[1,obj.ValueSetSizes(i)]);
                dof=getDegreesOfFreedom(obj.DataSpecifications{i});
                v=zeros([dof,cpsz],'like',vs);
                for j=1:dof
                    ncyc=ncyc/obj.ValueSetSizes(i);
                    v(j,:)=reshape(repmat(vs,nrep,ncyc),1,[]);
                    nrep=nrep*obj.ValueSetSizes(i);
                end
                assembler=getBatchAssembler(obj.DataSpecifications{i});
                outbuf{i}=assembler(v,cpsz);
            end


            switch format
            case 'array'
                varargout=outbuf;
            case 'timeseries'
                varargout=obj.array2timeseries(outbuf);
            case 'Dataset'
                varargout{1}=obj.array2dataset(outbuf);
            end
        end

        function bool=isDone(obj)





            narginchk(1,1);
            nargoutchk(0,1);
            validateattributes(obj,{'fixed.DataGenerator'},{'scalar'},1);

            bool=obj.IsDone;
        end
    end


    methods(Access=protected)
        function nout=getNumOutputsImpl(obj)


            nout=numel(obj.DataSpecifications);
        end

        function varargout=stepImpl(obj)



            varargout=cell(1,nargout);
            for i=1:nargout
                varargout{i}=obj.OutBuf{i};
            end


            stepImpl@fixed.DataGeneratorEngine(obj);
        end
    end

    methods(Access=private)
        function ts=array2timeseries(obj,ar)
            ts=cell(size(ar));
            for i=1:obj.NumDataSpecs
                nend=obj.CPSize-1;
                if isscalar(obj.DataSpecifications{i}.Dimensions)
                    ts{i}=timeseries(ar{i}.',0:nend);
                else
                    ts{i}=timeseries(ar{i},0:nend);
                end
            end
        end

        function dataset=array2dataset(obj,ar)
            ts=obj.array2timeseries(ar);
            dataset=Simulink.SimulationData.Dataset;
            dataset.Name='TestData';
            for i=1:obj.NumDataSpecs
                dataset=addElement(dataset,ts{i},"u"+i);
            end
        end
    end
end
