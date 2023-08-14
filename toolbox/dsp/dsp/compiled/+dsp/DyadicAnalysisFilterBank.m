classdef DyadicAnalysisFilterBank<matlab.system.SFunSystem















































































%#function mdspdwt

    properties(Nontunable)






























        Filter='Custom';







        CustomLowpassFilter=[0.0352,-0.0854,-0.135,0.4599,0.8069,0.3327];







        CustomHighpassFilter=[-0.3327,0.8069,-0.4599,-0.135,0.0854,0.0352];





        WaveletOrder=2;








        FilterOrder='[1 / 1]';





        NumLevels=2;














        TreeStructure='Asymmetric';
    end

    properties(Constant,Hidden)
        FilterSet=matlab.system.StringSet({...
        'Custom','Haar','Daubechies','Symlets','Coiflets',...
        'Biorthogonal','Reverse Biorthogonal','Discrete Meyer'});
        FilterOrderSet=matlab.system.StringSet({...
        '[1 / 1]','[1 / 3]','[1 / 5]','[2 / 2]',...
        '[2 / 4]','[2 / 6]','[2 / 8]','[3 / 1]',...
        '[3 / 3]','[3 / 5]','[3 / 7]','[3 / 9]',...
        '[4 / 4]','[5 / 5]','[6 / 8]'});
        TreeStructureSet=matlab.system.StringSet({'Asymmetric','Symmetric'});
    end

    methods
        function obj=DyadicAnalysisFilterBank(varargin)
            obj@matlab.system.SFunSystem('mdspdwt');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,false);
        end
    end

    methods(Hidden)
        function setParameters(obj)
            TreeStructureIdx=getIndex(...
            obj.TreeStructureSet,obj.TreeStructure);
            OutputFormatIdx=1;

            [phl,phh]=dspblkdwt('init',false,obj.CustomLowpassFilter,...
            obj.CustomHighpassFilter,TreeStructureIdx,...
            strrep(obj.Filter,'Custom','User-defined'),...
            obj.WaveletOrder,obj.FilterOrder);
            obj.compSetParameters({...
            phl,...
            phh,...
            obj.NumLevels,...
            TreeStructureIdx,...
OutputFormatIdx...
            ,1,...
            });
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case 'WaveletOrder'
                if strcmp(obj.Filter,'Custom')||...
                    strcmp(obj.Filter,'Haar')||...
                    strcmp(obj.Filter,'Discrete Meyer')||...
                    strcmp(obj.Filter,'Biorthogonal')||...
                    strcmp(obj.Filter,'Reverse Biorthogonal')
                    flag=true;
                end
            case 'FilterOrder'
                if strcmp(obj.Filter,'Custom')||...
                    strcmp(obj.Filter,'Haar')||...
                    strcmp(obj.Filter,'Discrete Meyer')||...
                    strcmp(obj.Filter,'Daubechies')||...
                    strcmp(obj.Filter,'Symlets')||...
                    strcmp(obj.Filter,'Coiflets')
                    flag=true;
                end
            case{'CustomLowpassFilter','CustomHighpassFilter'}
                if strcmp(obj.Filter,'Haar')||...
                    strcmp(obj.Filter,'Discrete Meyer')||...
                    strcmp(obj.Filter,'Daubechies')||...
                    strcmp(obj.Filter,'Symlets')||...
                    strcmp(obj.Filter,'Coiflets')||...
                    strcmp(obj.Filter,'Biorthogonal')||...
                    strcmp(obj.Filter,'Reverse Biorthogonal')
                    flag=true;
                end
            end
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspmlti4/Dyadic Analysis Filter Bank';
        end

        function props=getDisplayPropertiesImpl()
            props={...
'Filter'...
            ,'CustomLowpassFilter'...
            ,'CustomHighpassFilter'...
            ,'WaveletOrder'...
            ,'FilterOrder'...
            ,'NumLevels'...
            ,'TreeStructure'...
            };
        end

        function b=generatesCode
            b=false;
        end

    end
    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            for ii=1:getNumOutputs(obj)
                setPortDataTypeConnection(obj,1,ii);
            end
        end
    end
end
