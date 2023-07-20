classdef CRCGenerator<matlab.system.SFunSystem





































































%#function mcomcrcgen

    properties(Nontunable)



























        Polynomial='z^16 + z^12 + z^5 + 1'







        InitialConditions=0








        DirectMethod(1,1)logical=false






        ReflectInputBytes(1,1)logical=false




        ReflectChecksums(1,1)logical=false










        FinalXOR=0



















        ChecksumsPerFrame=1
    end

    properties(Hidden,Transient,Dependent,Nontunable)



















CheckSumsPerFrame
    end

    methods
        function obj=CRCGenerator(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomcrcgen');
            setProperties(obj,nargin,varargin{:},'Polynomial');
            setEmptyAllowedStatus(obj,true);
        end

        function set.CheckSumsPerFrame(obj,val)
            obj.ChecksumsPerFrame=val;
        end

        function val=get.CheckSumsPerFrame(obj)
            val=obj.ChecksumsPerFrame;
        end
    end

    methods(Hidden)
        function setParameters(obj)
            [genPoly,numBits,iniStates,finalXOR]=commblkcrcgen(...
            obj.Polynomial,obj.InitialConditions,obj.FinalXOR);


            obj.compSetParameters({...
            genPoly,...
            numBits,...
            iniStates,...
            finalXOR,...
            obj.ChecksumsPerFrame,...
            double(obj.DirectMethod),...
            double(obj.ReflectInputBytes),...
            double(obj.ReflectChecksums)});
        end
        function y=supportsUnboundedIO(~)
            y=true;
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commcrc2/General CRC Generator';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'Polynomial',...
            'InitialConditions',...
            'DirectMethod',...
            'ReflectInputBytes',...
            'ReflectChecksums',...
            'FinalXOR',...
            'ChecksumsPerFrame'};
        end



        function props=getValueOnlyProperties()
            props={'Polynomial'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end
    end

end


