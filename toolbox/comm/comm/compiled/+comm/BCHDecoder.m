classdef BCHDecoder<matlab.system.SFunSystem






















































































































%#function mcomberlekamp

    properties(Nontunable)










        CodewordLength=15




        MessageLength=5









        ShortMessageLengthSource='Auto'








        PrimitivePolynomialSource='Auto'







        PrimitivePolynomial='X^4+X+1'



















        GeneratorPolynomialSource='Auto'













        GeneratorPolynomial='X^10 + X^8 + X^5 + X^4 + X^2 + X + 1'






        PuncturePatternSource='None'








        PuncturePattern=[ones(8,1);zeros(2,1)]
    end

    properties(Nontunable,Dependent)



        ShortMessageLength=5
    end

    properties(Nontunable)









        CheckGeneratorPolynomial(1,1)logical=true










        ErasuresInputPort(1,1)logical=false



        NumCorrectedErrorsOutputPort(1,1)logical=true
    end

    properties(Constant,Hidden)




        ShortMessageLengthSourceSet=comm.CommonSets.getSet('AutoOrProperty')
        PrimitivePolynomialSourceSet=comm.CommonSets.getSet('AutoOrProperty')
        GeneratorPolynomialSourceSet=comm.CommonSets.getSet('AutoOrProperty')
        PuncturePatternSourceSet=comm.CommonSets.getSet('NoneOrProperty')
    end

    properties(Access=private,Nontunable)
        pShortMessageLength=5
    end

    methods
        function obj=BCHDecoder(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomberlekamp');


            if(nargin>=3)&&~comm.internal.utilities.isCharOrStringScalar(varargin{1})&&...
                ~comm.internal.utilities.isCharOrStringScalar(varargin{2})&&...
                ~(comm.internal.utilities.isCharOrStringScalar(varargin(3))&&ismember(varargin(3),obj.getDisplayPropertiesImpl))
                obj.GeneratorPolynomialSource='Property';
            end



            setProperties(obj,nargin,varargin{:},'CodewordLength','MessageLength','GeneratorPolynomial','ShortMessageLength');

            setVarSizeAllowedStatus(obj,false);
        end

        function set.ShortMessageLength(obj,value)
            obj.pShortMessageLength=value;
            obj.ShortMessageLengthSource='Property';
        end

        function value=get.ShortMessageLength(obj)
            if strcmp(obj.ShortMessageLengthSource,'Auto')
                value=obj.MessageLength;
            else
                value=obj.pShortMessageLength;
            end
        end
    end

    methods(Access=protected)
        function s=infoImpl(obj)






            s.ErrorCorrectionCapability=bchnumerr(obj.CodewordLength,...
            obj.MessageLength);
        end
    end


    methods(Hidden)
        function setParameters(obj)

            if isSizesOnlyCall(obj)


                obj.compSetParameters({...
                15,...
                5,...
                4,...
                3,...
                19,...
                1,...
                0,...
                0,...
                [1;1;1;1;1;1;1;1;0;0],...
                double(obj.ErasuresInputPort),...
                double(obj.NumCorrectedErrorsOutputPort),...
                1});
            else

                puncturePatternOptionIdx=getIndex(obj.PuncturePatternSourceSet,...
                obj.PuncturePatternSource)-1;
                specShortening=strcmp(obj.ShortMessageLengthSource,'Property');





                [eStr,params]=commblkbchrs([],'init',...
                obj.CodewordLength,...
                obj.MessageLength,...
                specShortening,...
                obj.ShortMessageLength,...
                obj.PrimitivePolynomial,...
                obj.GeneratorPolynomial,...
                puncturePatternOptionIdx,...
                obj.PuncturePattern,...
                double(obj.ErasuresInputPort),...
                double(obj.NumCorrectedErrorsOutputPort),...
                1,...
                'decoder',...
                'binary',...
                'Same as input',...
                obj.PrimitivePolynomialSource,...
                obj.GeneratorPolynomialSource,...
                obj.CheckGeneratorPolynomial);

                if eStr.ecode
                    colons=coder.internal.const(strfind(eStr.eID,':'));
                    final_token=eStr.eID(colons(end)+1:end);
                    coder.internal.errorIf(true,['comm:system:BCHRS:',final_token]);
                end

                if specShortening
                    n=obj.CodewordLength-params.shortened;
                    k=obj.MessageLength-params.shortened;
                else
                    n=obj.CodewordLength;
                    k=obj.MessageLength;
                end




                obj.compSetParameters({...
                n,...
                k,...
                params.m,...
                params.t,...
                params.primPoly,...
                1,...
                params.shortened,...
                puncturePatternOptionIdx,...
                obj.PuncturePattern,...
                double(obj.ErasuresInputPort),...
                double(obj.NumCorrectedErrorsOutputPort),...
                params.codeType...
                });
            end
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            if strcmp(obj.PrimitivePolynomialSource,'Auto')
                props{end+1}='PrimitivePolynomial';
            end
            if strcmp(obj.GeneratorPolynomialSource,'Auto')
                props{end+1}='GeneratorPolynomial';
                props{end+1}='CheckGeneratorPolynomial';
            end
            if strcmp(obj.PuncturePatternSource,'None')
                props{end+1}='PuncturePattern';
            end
            flag=ismember(prop,props);
        end

        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
            if obj.NumCorrectedErrorsOutputPort
                setPortDataTypeConnection(obj,1,2);
            end
        end

        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.system.SFunSystem(obj);

            s.pShortMessageLength=obj.pShortMessageLength;
        end

        function loadObjectImpl(obj,s,~)

            if isfield(s,'ShortMessageLengthSource')
                obj.pShortMessageLength=s.pShortMessageLength;
            end

            loadObjectImpl@matlab.system.SFunSystem(obj,s);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commblkcod2/BCH Decoder';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'CodewordLength',...
            'MessageLength',...
            'ShortMessageLengthSource',...
            'ShortMessageLength',...
            'GeneratorPolynomialSource',...
            'GeneratorPolynomial',...
            'CheckGeneratorPolynomial',...
            'PrimitivePolynomialSource',...
            'PrimitivePolynomial',...
            'PuncturePatternSource',...
            'PuncturePattern',...
            'ErasuresInputPort',...
            'NumCorrectedErrorsOutputPort'};
        end


        function props=getValueOnlyProperties()
            props={'CodewordLength','MessageLength','GeneratorPolynomial','ShortMessageLength'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

end

