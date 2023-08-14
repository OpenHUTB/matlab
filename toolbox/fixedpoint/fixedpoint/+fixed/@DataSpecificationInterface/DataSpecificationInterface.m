classdef(Abstract,Hidden)DataSpecificationInterface






    properties



Complexity






Dimensions
    end

    methods
        function obj=DataSpecificationInterface(varargin)







            p=inputParser;
            addParameter(p,'Complexity','real');
            addParameter(p,'Dimensions',1);
            parse(p,varargin{:});
            r=p.Results;


            obj.Complexity=r.Complexity;
            obj.Dimensions=r.Dimensions;
        end

        function obj=set.Complexity(obj,val)
            val=validatestring(val,{'real','complex'});

            if strcmp(val,'complex')

                [dataTypeStr,bool]=getDataTypeInfo(obj);
                try
                    fixed.internal.utility.cast(1i,numerictype(dataTypeStr),bool);
                catch ME
                    throwAsCaller(ME);
                end
            end

            obj.Complexity=val;
        end

        function obj=set.Dimensions(obj,val)
            validateattributes(val,{'numeric'},...
            {'real','integer','positive','row'});
            if prod(val)==1
                dims=1;
            elseif val(end)==1
                lastSolidDim=find(val>1,1,'last');
                if lastSolidDim==1
                    dims=val(1:2);
                else
                    dims=val(1:lastSolidDim);
                end
            else
                dims=val;
            end
            obj.Dimensions=int32(dims);
        end
    end

    methods(Abstract,Access={...
        ?fixed.DataSpecificationInterface,...
        ?fixed.DataGeneratorEngine,...
        ?matlab.unittest.TestCase})

        validateProperties(obj,identifier);









        [dtstr,isbuiltin]=getDataTypeInfo(obj);







        [szreq,szmin,szmax]=getValueSetSizeInfo(obj);









        vs=getValueSet(obj,sz);








    end

    methods(Access={?fixed.DataGeneratorEngine,?matlab.unittest.TestCase})
        function dof=getDegreesOfFreedom(obj)





            dof=(int32(strcmp(obj.Complexity,'complex')+1)*prod(obj.Dimensions));
        end

        function a=getUnitAssembler(obj)









            if isscalar(obj.Dimensions)
                dims=[1,obj.Dimensions];
            else
                dims=obj.Dimensions;
            end
            if strcmp(obj.Complexity,'complex')
                a=@(v)reshape(complex(v(1:2:end),v(2:2:end)),dims);
            else
                a=@(v)reshape(v,dims);
            end
        end

        function a=getBatchAssembler(obj)










            if strcmp(obj.Complexity,'complex')
                a=@(v,n)reshape(complex(v(1:2:end),v(2:2:end)),[obj.Dimensions,n]);
            else
                a=@(v,n)reshape(v,[obj.Dimensions,n]);
            end
        end
    end

    methods(Static,Hidden)
        function props=matlabCodegenNontunableProperties(~)



            props={'Complexity','Dimensions'};
        end
    end
end
