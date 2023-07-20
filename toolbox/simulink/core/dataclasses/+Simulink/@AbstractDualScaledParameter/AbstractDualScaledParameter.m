classdef(Abstract)AbstractDualScaledParameter<handle





    properties(Dependent=true)

        CalibrationValue=[];
        CalibrationMin=[];
        CalibrationMax=[];
    end


    properties

        CalToMainCompuNumerator=[];
        CalToMainCompuDenominator=[];
    end


    properties

        CalibrationName='';
        CalibrationDocUnits='';
    end


    properties(Dependent=true,SetAccess=private,Hidden=true)

        CalToInternalCompuNumerator=[];
        CalToInternalCompuDenominator=[];


        InternalToCalCompuNumerator=[];
        InternalToCalCompuDenominator=[];
    end


    properties(Dependent=true,SetAccess=private)
        IsConfigurationValid=true;
    end


    properties(SetAccess=private)
        DiagnosticMessage='';
    end





    methods

        function set.CalibrationName(obj,CalibrationName)




            validateattributes(CalibrationName,{'char'},{},...
            '','CalibrationName');

            obj.CalibrationName=CalibrationName;
        end


        function set.CalibrationDocUnits(obj,CalibrationDocUnits)




            validateattributes(CalibrationDocUnits,{'char'},{},...
            '','CalibrationDocUnits');

            obj.CalibrationDocUnits=CalibrationDocUnits;
        end


        function set.CalToMainCompuNumerator(obj,CalToMainCompuNumerator)






            if~isempty(obj.CalToMainCompuNumerator)
                DAStudio.error('Simulink:Data:CalToMainCompuNumDenNonEmpty','CalToMainCompuNumerator');
            end

            Simulink.AbstractDualScaledParameter.validateFiniteRealDoubleNonZeroArrayWith1or2Elements(...
            CalToMainCompuNumerator,'CalToMainCompuNumerator');

            Simulink.AbstractDualScaledParameter.validateCalToMainCompuMethodNotConstant(...
            CalToMainCompuNumerator,obj.CalToMainCompuDenominator);%#ok<MCSUP>

            obj.CalToMainCompuNumerator=Simulink.AbstractDualScaledParameter.polyRemoveLeadingZeros(...
            CalToMainCompuNumerator);
        end


        function set.CalToMainCompuDenominator(obj,CalToMainCompuDenominator)






            if~isempty(obj.CalToMainCompuDenominator)
                DAStudio.error('Simulink:Data:CalToMainCompuNumDenNonEmpty','CalToMainCompuDenominator');
            end

            Simulink.AbstractDualScaledParameter.validateFiniteRealDoubleNonZeroArrayWith1or2Elements(...
            CalToMainCompuDenominator,'CalToMainCompuDenominator');

            Simulink.AbstractDualScaledParameter.validateCalToMainCompuMethodNotConstant(...
            obj.CalToMainCompuNumerator,CalToMainCompuDenominator);%#ok<MCSUP>

            obj.CalToMainCompuDenominator=Simulink.AbstractDualScaledParameter.polyRemoveLeadingZeros(...
            CalToMainCompuDenominator);
        end


        function set.CalibrationValue(obj,CalibrationValue)







            if isempty(CalibrationValue)
                obj.Value=[];%#ok<MCNPR>
                return
            end

            validateattributes(CalibrationValue,{'double'},{'real','finite'},...
            '','CalibrationValue');

            Simulink.AbstractDualScaledParameter.validateMinMaxHasNoPole(...
            obj.CalibrationMin,obj.CalibrationMax,...
            obj.CalToMainCompuDenominator);

            obj.Value=ComputeMainFromCal(obj,CalibrationValue);%#ok<MCNPR>

            rCalibrationValue=ComputeCalFromMain(obj,obj.Value);

            Simulink.AbstractDualScaledParameter.checkValuesConsistent(...
            CalibrationValue,rCalibrationValue);
        end


        function CalibrationValue=get.CalibrationValue(obj)







            if isempty(obj.Value)
                CalibrationValue=[];
                return
            end
            try

                validateattributes(obj.Value,{'double'},{'real','finite'},'','Value');


                CalibrationValue=ComputeCalFromMain(obj,obj.Value);

                rValue=ComputeMainFromCal(obj,CalibrationValue);

                Simulink.AbstractDualScaledParameter.checkValuesConsistent(...
                obj.Value,rValue);
            catch ME
                obj.DiagnosticMessage=ME.message;
                CalibrationValue=[];
                warning('Simulink:Data:GetCalibrationValueFailed',ME.message);
            end
        end


        function set.CalibrationMin(obj,CalibrationMin)








            isInc=isIncreasing(obj);

            if isempty(CalibrationMin)

                setCalibrationMin(obj,[],isInc);
                return
            end

            validateattributes(CalibrationMin,{'double'},...
            {'real','finite','scalar'},'','CalibrationMin');


            Simulink.AbstractDualScaledParameter.validateMinMaxHasNoPole(...
            CalibrationMin,obj.CalibrationMax,...
            obj.CalToMainCompuDenominator);

            value=ComputeMainFromCal(obj,CalibrationMin);

            setCalibrationMin(obj,value,isInc);

            rCalibrationMin=ComputeCalFromMain(obj,value);

            Simulink.AbstractDualScaledParameter.checkValuesConsistent(...
            CalibrationMin,rCalibrationMin);
        end


        function CalibrationMin=get.CalibrationMin(obj)








            if isempty(obj.Min)&&isempty(obj.Max)
                CalibrationMin=[];
                return
            end
            try

                isInc=isIncreasing(obj);

                if(isInc)
                    min=obj.Min;
                else
                    min=obj.Max;
                end

                if isempty(min)
                    CalibrationMin=[];
                    return
                end


                CalibrationMin=ComputeCalFromMain(obj,min);

                rmin=ComputeMainFromCal(obj,CalibrationMin);

                Simulink.AbstractDualScaledParameter.checkValuesConsistent(min,rmin);
            catch ME
                obj.DiagnosticMessage=ME.message;
                CalibrationMin=[];
                warning('Simulink:Data:GetCalibrationMinFailed',ME.message);
            end

        end


        function set.CalibrationMax(obj,CalibrationMax)








            isInc=isIncreasing(obj);

            if isempty(CalibrationMax)

                setCalibrationMax(obj,[],isInc);
                return
            end

            validateattributes(CalibrationMax,{'double'},...
            {'real','finite','scalar'},'','CalibrationMax');

            Simulink.AbstractDualScaledParameter.validateMinMaxHasNoPole(...
            obj.CalibrationMin,CalibrationMax,...
            obj.CalToMainCompuDenominator);

            value=ComputeMainFromCal(obj,CalibrationMax);

            setCalibrationMax(obj,value,isInc);

            rCalibrationMax=ComputeCalFromMain(obj,value);

            Simulink.AbstractDualScaledParameter.checkValuesConsistent(...
            CalibrationMax,rCalibrationMax);
        end


        function CalibrationMax=get.CalibrationMax(obj)








            if isempty(obj.Min)&&isempty(obj.Max)
                CalibrationMax=[];
                return
            end
            try

                isInc=isIncreasing(obj);

                if(isInc)
                    max=obj.Max;
                else
                    max=obj.Min;
                end

                if isempty(max)
                    CalibrationMax=[];
                    return
                end


                CalibrationMax=ComputeCalFromMain(obj,max);

                rmax=ComputeMainFromCal(obj,CalibrationMax);

                Simulink.AbstractDualScaledParameter.checkValuesConsistent(max,rmax);
            catch ME
                obj.DiagnosticMessage=ME.message;
                CalibrationMax=[];
                warning('Simulink:Data:GetCalibrationMaxFailed',ME.message);%#ok
            end
        end


        function CalToInternalCompuNumerator=get.CalToInternalCompuNumerator(obj)




            ndt=fixdt(obj.getCompiledBaseNumericTypeName);
            CalToInternalCompuNumerator=getCalToInternalCompuNumerator(obj,ndt);
        end


        function CalToInternalCompuDenominator=get.CalToInternalCompuDenominator(obj)



            ndt=fixdt(obj.getCompiledBaseNumericTypeName);
            CalToInternalCompuDenominator=getCalToInternalCompuDenominator(obj,ndt);
        end


        function InternalToCalCompuNumerator=get.InternalToCalCompuNumerator(obj)




            ndt=fixdt(obj.getCompiledBaseNumericTypeName);
            InternalToCalCompuNumerator=getInternalToCalCompuNumerator(obj,ndt);
        end


        function InternalToCalCompuDenominator=get.InternalToCalCompuDenominator(obj)



            ndt=fixdt(obj.getCompiledBaseNumericTypeName);
            InternalToCalCompuDenominator=getInternalToCalCompuDenominator(obj,ndt);
        end


        function DiagnosticMessage=get.DiagnosticMessage(obj)






            obj.DiagnosticMessage='';
            obj.CalibrationValue;
            if~isempty(obj.DiagnosticMessage)
                DiagnosticMessage=obj.DiagnosticMessage;
                return
            end
            obj.CalibrationMax;
            if~isempty(obj.DiagnosticMessage)
                DiagnosticMessage=obj.DiagnosticMessage;
                return
            end
            obj.CalibrationMin;
            DiagnosticMessage=obj.DiagnosticMessage;
        end


        function IsConfigurationValid=get.IsConfigurationValid(obj)




            IsConfigurationValid=isempty(obj.DiagnosticMessage);
        end

    end




    methods(Hidden=true,Sealed=true)

        function dlgStruct=getDialogSchema(obj,name)

            dlgStructBase=dataddg(obj,name,'data');
            dlgStruct=DualScaledParameterDDG(obj,dlgStructBase);
        end


        function mainValue=ComputeMainFromCal(obj,calValue)





            validateCalToMainCompuMethodNonEmpty(obj);

            num_eval=polyval(obj.CalToMainCompuNumerator,calValue);
            den_eval=polyval(obj.CalToMainCompuDenominator,calValue);

            if numel(den_eval)~=nnz(den_eval)
                DAStudio.error('Simulink:Data:CompuDenEvalToZero','CalToMain');
            end
            mainValue=num_eval./den_eval;
        end


        function calValue=ComputeCalFromMain(obj,mainValue)







            MainToCalCompuNumerator=ComputeMainToCalCompuNumerator(obj);
            MainToCalCompuDenominator=ComputeMainToCalCompuDenominator(obj);

            Simulink.AbstractDualScaledParameter.validateMinMaxHasNoPole(...
            obj.Min,obj.Max,MainToCalCompuDenominator);

            num_eval=polyval(MainToCalCompuNumerator,mainValue);
            den_eval=polyval(MainToCalCompuDenominator,mainValue);

            if numel(den_eval)~=nnz(den_eval)
                DAStudio.error('Simulink:Data:CompuDenEvalToZero','MainToCal');
            end
            calValue=num_eval./den_eval;
        end


        function MainToCalCompuNumerator=ComputeMainToCalCompuNumerator(obj)







            validateCalToMainCompuMethodNonEmpty(obj);

            [num,den]=Simulink.AbstractDualScaledParameter.polySameSize(...
            obj.CalToMainCompuNumerator,obj.CalToMainCompuDenominator);

            MainToCalCompuNumerator=[den(2),-num(2)];

            MainToCalCompuNumerator=Simulink.AbstractDualScaledParameter.polyRemoveLeadingZeros(...
            MainToCalCompuNumerator);
        end


        function MainToCalCompuDenominator=ComputeMainToCalCompuDenominator(obj)







            validateCalToMainCompuMethodNonEmpty(obj);

            [num,den]=Simulink.AbstractDualScaledParameter.polySameSize(...
            obj.CalToMainCompuNumerator,obj.CalToMainCompuDenominator);

            MainToCalCompuDenominator=[-den(1),num(1)];

            MainToCalCompuDenominator=Simulink.AbstractDualScaledParameter.polyRemoveLeadingZeros(...
            MainToCalCompuDenominator);
        end


        function result=getCalToInternalCompuNumerator(obj,ndt)





            if isempty(obj.CalToMainCompuNumerator)&&isempty(obj.CalToMainCompuDenominator)
                result=[];
                return
            end

            validateCalToMainCompuMethodNonEmpty(obj);





            if isa(ndt,'coder.descriptor.types.Type')
                if ndt.isFixed
                    slope=ndt.Slope;
                    bias=ndt.Bias;
                else
                    slope=1;
                    bias=0;
                end
            else
                slope=ndt.Slope;
                bias=ndt.Bias;
            end

            num1=obj.CalToMainCompuNumerator./slope;
            num2=-(bias/slope).*obj.CalToMainCompuDenominator;
            result=Simulink.AbstractDualScaledParameter.polyAdd(num1,num2);

            result=Simulink.AbstractDualScaledParameter.polyRemoveLeadingZeros(result);
        end


        function result=getCalToInternalCompuDenominator(obj,nt)%#ok




            if isempty(obj.CalToMainCompuNumerator)&&isempty(obj.CalToMainCompuDenominator)
                result=[];
                return
            end

            validateCalToMainCompuMethodNonEmpty(obj);
            result=obj.CalToMainCompuDenominator;
        end


        function result=getInternalToCalCompuNumerator(obj,ndt)





            if isempty(obj.CalToMainCompuNumerator)&&isempty(obj.CalToMainCompuDenominator)
                result=[];
                return
            end


            [num,den]=Simulink.AbstractDualScaledParameter.polySameSize(...
            obj.getCalToInternalCompuNumerator(ndt),...
            obj.getCalToInternalCompuDenominator(ndt));

            result=[den(2),-num(2)];

            result=Simulink.AbstractDualScaledParameter.polyRemoveLeadingZeros(result);
        end


        function result=getInternalToCalCompuDenominator(obj,ndt)




            if isempty(obj.CalToMainCompuNumerator)&&isempty(obj.CalToMainCompuDenominator)
                result=[];
                return
            end


            [num,den]=Simulink.AbstractDualScaledParameter.polySameSize(...
            obj.getCalToInternalCompuNumerator(ndt),...
            obj.getCalToInternalCompuDenominator(ndt));

            result=[-den(1),num(1)];

            result=Simulink.AbstractDualScaledParameter.polyRemoveLeadingZeros(result);
        end


        function validateCalToMainCompuMethodNonEmpty(obj)



            validateattributes(obj.CalToMainCompuNumerator,...
            {'double'},{'nonempty'},'','CalToMainCompuNumerator');
            validateattributes(obj.CalToMainCompuDenominator,...
            {'double'},{'nonempty'},'','CalToMainCompuDenominator');
        end


        function isInc=isIncreasing(obj)



            validateCalToMainCompuMethodNonEmpty(obj);

            [num,den]=Simulink.AbstractDualScaledParameter.polySameSize(...
            obj.CalToMainCompuNumerator,obj.CalToMainCompuDenominator);

            slopeNumerator=num(1)*den(2)-num(2)*den(1);

            isInc=(slopeNumerator>0);
        end


        function obj=setCalibrationMin(obj,value,isInc)



            if isInc

                obj.Min=value;

            else

                obj.Max=value;
            end
        end


        function obj=setCalibrationMax(obj,value,isInc)



            if isInc

                obj.Max=value;

            else

                obj.Min=value;
            end
        end

    end




    methods(Hidden=true,Static=true)


        function[p1,p2]=polySameSize(p1,p2)



            p1=Simulink.AbstractDualScaledParameter.polyRemoveLeadingZeros(p1);
            p2=Simulink.AbstractDualScaledParameter.polyRemoveLeadingZeros(p2);
            [r1,c1]=size(p1);
            [r2,c2]=size(p2);
            assert(r1==1&&r2==1);
            if c1>c2
                p2=[zeros(r2,c1-c2),p2];
            elseif c1<c2
                p1=[zeros(r1,c2-c1),p1];
            end
        end


        function p3=polyAdd(p1,p2)



            [p1,p2]=Simulink.AbstractDualScaledParameter.polySameSize(p1,p2);
            p3=p1+p2;
        end


        function p=polyRemoveLeadingZeros(p)






            ii=logical(cumprod(double(0==p)));
            p(ii)=[];
        end


        function validateFiniteRealDoubleNonZeroArrayWith1or2Elements(value,name)



            validateattributes(value,{'double'},...
            {'finite','real','nonempty','nrows',1},'',name);
            if~any(value)
                DAStudio.error('Simulink:Data:PropertyEvalToZero',name);
            end

            validateattributes(numel(value),{'double'},{'<=',2},'',['numel(',name,')']);
        end


        function validateCalToMainCompuMethodNotConstant(CalToMainCompuNumerator,CalToMainCompuDenominator)




            if isempty(CalToMainCompuNumerator)||isempty(CalToMainCompuDenominator)
                return
            end

            [num,den]=Simulink.AbstractDualScaledParameter.polySameSize(...
            CalToMainCompuNumerator,CalToMainCompuDenominator);
            divRes=num./den;



            if(divRes(1)==divRes(end)||isnan(divRes(1))||isnan(divRes(end)))
                DAStudio.error('Simulink:Data:CalToMainCompuMethodConst');
            end
        end


        function validateMinMaxHasNoPole(min,max,den)



            if isempty(min)||isempty(max)
                return
            end
            pole=[];

            if numel(den)==2
                pole=-den(2)/den(1);
            end

            if~isempty(pole)
                if pole>=min&&pole<=max
                    DAStudio.error('Simulink:Data:PoleWithinMinMax',...
                    num2str(min),num2str(max),num2str(pole));
                end
            end
        end


        function checkValuesConsistent(baseValue,roundtripValue)



            if isequaln(baseValue,roundtripValue)
                return
            end

            delta_abs=abs(baseValue-roundtripValue);
            if isfinite(delta_abs)
                max_abs=max(abs(baseValue),abs(roundtripValue));
                if delta_abs<(32*sqrt(eps(max_abs)))
                    return
                end
            end
            DAStudio.error('Simulink:Data:ValuesInconsistent');
        end


        function lstr=getHelpLink()%#ok<STOUT>



        end

    end

end


