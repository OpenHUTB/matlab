classdef(StrictDefaults)HDLRSEncoder<matlab.System
































































%#codegen
%#ok<*EMCLS>

    properties(Nontunable)

















        CodewordLength=7;




        MessageLength=3;







        PrimitivePolynomialSource='Auto';










        PrimitivePolynomial=[1,0,1,1];






        PuncturePatternSource='None';








        PuncturePattern=[ones(2,1);zeros(2,1)];



        BSource='Auto';





        B=1;
    end

    properties(Constant,Hidden)




        PrimitivePolynomialSourceSet=comm.CommonSetsHDL.getSet('AutoOrProperty');
        PuncturePatternSourceSet=comm.CommonSetsHDL.getSet('NoneOrProperty');
        BSourceSet=comm.CommonSetsHDL.getSet('AutoOrProperty');
    end

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
    properties(Access=private)

        MultTable;
        PowerTable;
        Corr;
        WordSize;

        InReg;
        StartReg;
        EndReg;
        DVReg;
        PrevReg;
        States;

        CodeCount;
        InPacket;
        OutputCode;

    end

    methods(Static,Access=protected)
        function header=getHeaderImpl


            header=matlab.system.display.Header('comm.HDLRSEncoder',...
            'ShowSourceLink',false,...
            'Title','Integer-Input RS Encoder HDL Optimized');
        end
    end

    methods
        function obj=HDLRSEncoder(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','Communication_Toolbox'))
                    error(message('comm:system:HDLRSDecoder:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','Communication_Toolbox');
            end
            setProperties(obj,nargin,varargin{:},'CodewordLength','MessageLength');
        end
    end

    methods(Access=protected)
        function s=saveObjectImpl(obj)



            s=saveObjectImpl@matlab.System(obj);


            s.MultTable=obj.MultTable;
            s.PowerTable=obj.PowerTable;
            s.Corr=obj.Corr;
            s.WordSize=obj.WordSize;



            s.InReg=obj.InReg;
            s.StartReg=obj.StartReg;
            s.EndReg=obj.EndReg;
            s.DVReg=obj.DVReg;
            s.PrevReg=obj.PrevReg;
            s.States=obj.States;

            s.CodeCount=obj.CodeCount;
            s.InPacket=obj.InPacket;
            s.OutputCode=obj.OutputCode;

        end

        function obj=loadObjectImpl(obj,s,~)


            loadObjectImpl@matlab.System(obj,s);

            f=fieldnames(s);
            for ii=1:numel(f)
                obj.(f{ii})=s.(f{ii});%#ok<EMCA>
            end

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
        end

        function resetImpl(obj)
            obj.resetStates;

            obj.InReg=uint32(0);
            obj.StartReg=false;
            obj.EndReg=false;
            obj.DVReg=false;
            obj.PrevReg=uint32(0);
        end

...
...
...
...

...
...
...
...
...
...
...
...
...
...
...
...
    end

    methods(Access=protected)

        function[y,startOut,endOut,validOut]=outputImpl(obj,x,startIn,endIn,validIn,varargin)%#ok<INUSD>


















            obj_InPacket=obj.InPacket;
            obj_OutputCode=obj.OutputCode;





            y=comm.HDLRSEncoder.dtcast(obj.PrevReg,x);
            startOut=obj.StartReg;
            endOut=false;
            if obj_InPacket
                validOut=obj.DVReg;
            else
                validOut=false;
            end

            if obj.StartReg&&obj.DVReg



                obj_InPacket=true;
                obj_OutputCode=false;
                startOut=true;
            end





            if obj_InPacket&&obj.DVReg









                y=comm.HDLRSEncoder.dtcast(obj.InReg,x);
                validOut=true;
            end

            if obj_OutputCode&&~obj.StartReg
                if~strcmp(obj.PuncturePatternSource,'None')
                    states=obj.States(logical(obj.PuncturePattern));
                    paritySize=sum(obj.PuncturePattern);
                else
                    states=obj.States;
                    paritySize=2*obj.Corr;
                end

                y=comm.HDLRSEncoder.dtcast(states(obj.CodeCount),x);
                validOut=true;

                if obj.CodeCount==paritySize
                    endOut=true;
                end
            end
        end

        function updateImpl(obj,x,startIn,endIn,validIn,varargin)

            if isempty(obj.States)
                obj.resetStates;
                obj.InReg=uint32(0);
                obj.StartReg=false;
                obj.EndReg=false;
                obj.DVReg=false;
                obj.PrevReg=uint32(0);
            end



            y=comm.HDLRSEncoder.dtcast(obj.PrevReg,x);








            if obj.StartReg&&obj.DVReg
                obj.resetStates;
                obj.InPacket=true;
                obj.OutputCode=false;

            end

            if obj.InPacket&&obj.DVReg
                gfx=obj.InReg;
                gtemp=bitand(bitxor(gfx,obj.States(1)),(2^obj.WordSize)-1);
                gvec=obj.MultTable(:,gtemp+1);
                for ii=1:2*obj.Corr-1
                    obj.States(ii)=bitxor(obj.States(ii+1),gvec(ii));
                end

                tmpindex=2*obj.Corr;
                obj.States(tmpindex)=gvec(tmpindex);
                y=comm.HDLRSEncoder.dtcast(obj.InReg,x);

            end

            if obj.OutputCode&&~obj.StartReg
                if~strcmp(obj.PuncturePatternSource,'None')
                    states=obj.States(logical(obj.PuncturePattern));
                    paritySize=sum(obj.PuncturePattern);
                else
                    states=obj.States;
                    paritySize=2*obj.Corr;
                end

                y=comm.HDLRSEncoder.dtcast(states(obj.CodeCount),x);


                if obj.CodeCount==paritySize

                    obj.CodeCount=1;
                    obj.OutputCode=false;
                else
                    obj.CodeCount=obj.CodeCount+1;
                end
            end

            if obj.InPacket&&obj.EndReg&&obj.DVReg
                obj.OutputCode=true;
                obj.InPacket=false;
                obj.CodeCount=1;
            end


            obj.InReg=uint32(x);
            obj.StartReg=startIn&&validIn;
            obj.EndReg=endIn&&validIn;
            obj.DVReg=validIn;
            obj.PrevReg=uint32(y);
        end





        function resetStates(obj)
            obj.States=zeros(128,1,'uint32');
            obj.InPacket=false;
            obj.OutputCode=false;
            obj.CodeCount=1;
        end

        function validateInputsImpl(obj,x,startIn,endIn,validIn)


            validateattributes(obj.CodewordLength,...
            {'numeric'},{'scalar','integer','>=',1,'<=',65536},'','CodewordLength');%#ok<EMCA>
            validateattributes(obj.MessageLength,...
            {'numeric'},{'scalar','integer','>=',1,'<',obj.CodewordLength},'','MessageLength');%#ok<EMCA>
            validateattributes(obj.CodewordLength-obj.MessageLength,...
            {'numeric'},{'scalar','even','integer','>=',2},'','CodewordLength - MessageLength');%#ok<EMCA>

            if~strcmp(obj.PrimitivePolynomialSource,'Auto')
                validateattributes(obj.PrimitivePolynomial,{'numeric'},{'integer'},'','PrimitivePolynomial');%#ok<EMCA>
            end
            if~strcmp(obj.BSource,'Auto')
                validateattributes(obj.B,{'numeric'},{'scalar','integer','nonnegative'},'','B');%#ok<EMCA>
            end
            if~strcmp(obj.PuncturePatternSource,'None')
                validateattributes(obj.PuncturePattern,{'numeric'},...
                {'vector','integer','>=',0,'<=',1,'numel',obj.CodewordLength-obj.MessageLength},...
                '','PuncturePattern');%#ok<EMCA>
            end

            validateattributes(x,{'numeric','embedded.fi'},{'scalar'},'','x');%#ok<EMCA>

            if isempty(coder.target)||~coder.internal.isAmbiguousTypes


                validateattributes(startIn,{'logical'},{'scalar'},'','startIn');%#ok<EMCA>
                validateattributes(endIn,{'logical'},{'scalar'},'','endIn');%#ok<EMCA>
                validateattributes(validIn,{'logical'},{'scalar'},'','validIn');%#ok<EMCA>




            end


        end

        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end

        function setupImpl(obj,x,~,~,~,varargin)








            coder.extrinsic('HDLRSGenPoly');

            if strcmp(obj.PrimitivePolynomialSource,'Auto')
                if isempty(coder.target)
                    [tMultTable,tPowerTable,tCorr,tWordSize,~,~]=HDLRSGenPoly(obj.CodewordLength,obj.MessageLength,obj.B);
                else
                    [tMultTable,tPowerTable,tCorr,tWordSize,~,~]=coder.internal.const(HDLRSGenPoly(obj.CodewordLength,obj.MessageLength,obj.B));
                end
            else
                if isempty(coder.target)
                    [tMultTable,tPowerTable,tCorr,tWordSize,~,~]=HDLRSGenPoly(obj.CodewordLength,obj.MessageLength,obj.B,obj.PrimitivePolynomial);
                else
                    [tMultTable,tPowerTable,tCorr,tWordSize,~,~]=coder.internal.const(HDLRSGenPoly(obj.CodewordLength,obj.MessageLength,obj.B,obj.PrimitivePolynomial));
                end
            end

            obj.MultTable=tMultTable;
            obj.PowerTable=tPowerTable;
            obj.Corr=tCorr;
            obj.WordSize=tWordSize;
            obj.resetStates;

            obj.InReg=uint32(0);
            obj.StartReg=false;
            obj.EndReg=false;
            obj.DVReg=false;
            obj.PrevReg=uint32(0);


            if isempty(coder.target)||~eml_ambiguous_types
                if~(isa(x,'double')||isa(x,'single'))
                    [inWL,~,~]=dsphdlshared.hdlgetwordsizefromdata(x);
                    coder.internal.errorIf(inWL~=obj.WordSize,...
                    'comm:system:HDLRSDecoder:InputWLMisMatch');

                end
            end

        end

        function icon=getIconImpl(~)

            icon=sprintf('Integer-Input\nRS Encoder\nHDL Optimized');
        end

        function varargout=getInputNamesImpl(obj)

            varargout=cell(1,getNumInputs(obj));
            varargout{1}='dataIn';
            varargout{2}='startIn';
            varargout{3}='endIn';
            varargout{4}='validIn';
        end

        function varargout=getOutputNamesImpl(obj)

            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='dataOut';
            varargout{2}='startOut';
            varargout{3}='endOut';
            varargout{4}='validOut';
        end

        function num=getNumInputsImpl(obj)%#ok
            num=4;
        end

        function num=getNumOutputsImpl(obj)%#ok
            num=4;
        end










        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case 'PrimitivePolynomial'
                if strcmp(obj.PrimitivePolynomialSource,'Auto')
                    flag=true;
                end
            case 'B'
                if strcmp(obj.BSource,'Auto')
                    flag=true;
                end
            case 'PuncturePattern'
                if strcmp(obj.PuncturePatternSource,'None')
                    flag=true;
                end
            end
        end
    end

    methods(Static,Hidden)

        function output=noCastData(data,~,~)
            output=data;
        end

        function output=castDataFixedPoint(data,input,~)


            output=fi(data,input.numerictype,'RoundMode','floor','OverflowMode','wrap');
            output.fimath=[];
        end

        function output=castData(data,input,dType)


            if isa(input,'embedded.fi')
                output=fi(data,input.numerictype);
            else
                output=cast(data,dType);
            end
        end


    end

    methods(Static,Access=private)
        function y=dtcast(u,v)
            if isa(v,'embedded.fi')
                y=fi(u,'numerictype',numerictype(v));
            else
                y=cast(u,class(v));
            end
        end
    end














    methods(Static,Access=protected)
        function isVisible=showSimulateUsingImpl

            isVisible=false;
        end
    end

    methods(Access=protected)
        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end
    end

end

