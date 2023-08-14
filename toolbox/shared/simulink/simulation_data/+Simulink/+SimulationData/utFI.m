classdef utFI


    methods(Static)
        function data=handleFixedPointType(data,FixedPointParameters,className)




            sign=FixedPointParameters.isSigned;
            wordLen=FixedPointParameters.WordLength;
            slopeAdj=FixedPointParameters.SlopeAdjustmentFactor;
            exp=FixedPointParameters.Exponent;
            bias=FixedPointParameters.Bias;

            if(slopeAdj==1&&bias==0)
                NT=numerictype(sign,wordLen,-exp);
            else
                NT=numerictype(sign,wordLen,slopeAdj,exp,bias);
            end
            needScaledDouble=strcmp(className,'scaled-double');
            if needScaledDouble
                NT=numerictype(NT,'DataType','ScaledDouble');
            end

            if isempty(data)
                try
                    data=embedded.fi([],NT);
                catch

                    data=[];
                end
            else
                fh=@sim2fi;
                data=fh(data,NT);
            end
            if needScaledDouble
                data=Simulink.SimulationData.utFI.createScaledDoubleFI(...
                data.double,NT);
            end


        end

        function A=createScaledDoubleFI(DblArray,varargin)







            try
                [doRobust,numerictype_args]=...
                Simulink.SimulationData.utFI.robustRequest(varargin{:});

                T=Simulink.SimulationData.utFI.getNumericType(numerictype_args{:});


                if Simulink.SimulationData.utFI.checkoutFiLicense(T)
                    A=embedded.fi(DblArray,T);
                else
                    if doRobust

                        warning(message('SimulationData:Objects:LicenseResortToDoubles'));
                        A=DblArray;
                    else

                        Simulink.SimulationData.utError('LicenseFixPtDesignerRequired');
                    end
                end
            catch me
                throwAsCaller(me);
            end
        end
    end
    methods(Static,Access=private)

        function gotIt=checkoutFiLicense(T)

            needLicense=fixed.internal.isFxdNeeded(T);

            if~needLicense
                gotIt=true;
                return
            end

            gotIt=false;
            if license('test','Fixed_Point_Toolbox')
                try



                    gotIt=0~=license('checkout','Fixed_Point_Toolbox');
                catch me %#ok<NASGU>
                end
            end
        end


        function T=getNumericType(varargin)
            narginchk(1,6);
            switch nargin
            case{1,2}

                T=varargin{1};
            case{3,4}

                T=numerictype;
                T.DataType='ScaledDouble';
                T.Scaling='BinaryPoint';
                T.Signed=varargin{1};
                T.WordLength=varargin{2};
                T.FractionLength=varargin{3};
            case{5,6}


                T=numerictype;
                T.DataType='ScaledDouble';
                T.Scaling='SlopeBias';
                T.Signed=varargin{1};
                T.WordLength=varargin{2};
                T.SlopeAdjustmentFactor=varargin{3};
                T.FixedExponent=varargin{4};
                T.Bias=varargin{5};
            otherwise
                error(message('MATLAB:narginchk:tooManyInputs'));
            end
        end


        function[doRobust,numerictype_args]=robustRequest(varargin)







            if(nargin>1)&&ischar(varargin{end})


                doRobust=strncmpi('robust',varargin{end},6);
                numerictype_args=varargin(1:end-1);
            else
                doRobust=true;
                numerictype_args=varargin;
            end
        end
    end
end

