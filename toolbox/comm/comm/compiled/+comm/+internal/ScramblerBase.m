classdef ScramblerBase<matlab.system.SFunSystem





%#function mcomscram2

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)




        CalculationBase=4












        Polynomial='1 + z^-1 + z^-2 + z^-4'








        InitialConditionsSource='Property'





        InitialConditions=[0,1,2,3]







        ResetInputPort(1,1)logical=false
    end


    properties(Constant,GetAccess=protected,Abstract,Nontunable)
pIsDescrambler
    end

    properties(Constant,Hidden)
        InitialConditionsSourceSet=...
        matlab.system.StringSet({'Property','Input port'})
    end

    methods

        function obj=ScramblerBase(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomscram2');
            setProperties(obj,nargin,varargin{:},'CalculationBase','Polynomial','InitialConditions');
            setVarSizeAllowedStatus(obj,true);
            setEmptyAllowedStatus(obj,true);
        end


        function set.InitialConditionsSource(obj,val)
            props={'Property','Input port'};
            obj.InitialConditionsSource=validatestring(val,props,...
            'comm.Scrambler','InitialConditionsSource');
        end
    end

    methods(Hidden)
        function setParameters(obj)
            [calculationBase,polynomial,initialConditions]=...
            commblkscram2(obj,obj.CalculationBase,obj.Polynomial,obj.InitialConditions);


            if isequal(obj.InitialConditionsSource,'Property')
                initialConditionsSource=1;
            elseif isequal(obj.InitialConditionsSource,'Input port')
                initialConditionsSource=2;
            end

            obj.compSetParameters({...
            calculationBase,...
            polynomial,...
            obj.pIsDescrambler,...
            initialConditionsSource,...
            initialConditions,...
            obj.ResetInputPort});
        end
        function y=supportsUnboundedIO(~)
            y=true;
        end
    end

    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={...
            'CalculationBase',...
            'Polynomial',...
            'InitialConditionsSource',...
            'InitialConditions',...
            'ResetInputPort'};
        end


        function props=getValueOnlyProperties()
            props={'CalculationBase','Polynomial','InitialConditions'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end

        function flag=isInactivePropertyImpl(obj,propertyName)
            if strcmp(propertyName,'InitialConditions')||strcmp(propertyName,'ResetInputPort')
                flag=isequal(obj.InitialConditionsSource,'Input port');
            else
                flag=false;
            end
        end
    end

end



