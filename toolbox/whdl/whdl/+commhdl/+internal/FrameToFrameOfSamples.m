classdef(StrictDefaults)FrameToFrameOfSamples<matlab.System




%#codegen

    properties(Nontunable)





        InterSampleIdleCycles=0;





        InterFrameIdleCycles=0;







        OutputSize=1;











        InterleaveSamples(1,1)logical=false;
    end

    properties(Nontunable,Access=private)


        pInterSampleIdleCycles=0;
        pInterFrameIdleCycles=0;
        pOutputSize=1;

        pInterleaveSamples(1,1)logical=false;
    end

    methods
        function obj=FrameToFrameOfSamples(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','LTE_HDL_Toolbox'))
                    error(message('whdl:whdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','LTE_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:});
        end

        function set.InterFrameIdleCycles(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','finite','>=',0},'FrameToFrameOfSamples','InterFrameIdleCycles');
            obj.InterFrameIdleCycles=val;
        end

        function set.InterSampleIdleCycles(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','finite','>=',0},'FrameToFrameOfSamples','InterSampleIdleCycles');
            obj.InterSampleIdleCycles=val;
        end

        function set.OutputSize(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','finite','>',0},'FrameToFrameOfSamples','OutputSize');
            obj.OutputSize=val;
        end

    end

    methods(Access=protected)

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

        function[dataOut,ctrlOut]=outputImpl(obj,inputFrame)





            pInputFrameLength=size(inputFrame,1);
            assert(isfloat(pInputFrameLength));
            assert(isscalar(pInputFrameLength));
            coder.internal.errorIf(~(mod(pInputFrameLength,obj.pOutputSize)==0),...
            'whdl:FrameToFrameOfSamples:InvalidOutputSize',...
            obj.pOutputSize,pInputFrameLength);

            validateattributes(inputFrame,{'numeric','embedded.fi','logical'},...
            {'column'},'FrameToFrameOfSamples','input frame');


            [dataOut,ctrlOut]=commhdlframetosamples(inputFrame,...
            obj.pInterSampleIdleCycles,obj.pInterFrameIdleCycles,...
            obj.pOutputSize,obj.pInterleaveSamples...
            );

        end

        function setupImpl(obj,~)



            obj.pInterFrameIdleCycles=obj.InterFrameIdleCycles;
            obj.pInterSampleIdleCycles=obj.InterSampleIdleCycles;
            obj.pOutputSize=obj.OutputSize;


            if(obj.pOutputSize~=1)
                obj.pInterleaveSamples=obj.InterleaveSamples;
            else
                obj.pInterleaveSamples=false;
            end

            assert(isfloat(obj.pInterFrameIdleCycles));
            assert(isfloat(obj.pInterSampleIdleCycles));
            assert(isfloat(obj.pOutputSize));
            assert(isscalar(obj.pInterFrameIdleCycles));
            assert(isscalar(obj.pInterSampleIdleCycles));
            assert(isscalar(obj.pOutputSize));

            validateattributes(obj.pOutputSize,...
            {'numeric'},{'scalar','integer',...
            '>=',1},'FrameToFrameOfSamples','OutputSize');


            validateattributes(obj.pInterFrameIdleCycles,...
            {'numeric'},{'scalar','integer',...
            '>=',0},'FrameToFrameOfSamples','InterFrameIdleCycles');
            validateattributes(obj.pInterSampleIdleCycles,...
            {'numeric'},{'scalar','integer',...
            '>=',0},'FrameToFrameOfSamples','InterSampleIdleCycles');
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

        function flag=isInputSizeMutableImpl(~,~)
            flag=true;
        end

        function num=getNumInputsImpl(~)
            num=1;
        end

        function num=getNumOutputsImpl(~)
            num=2;
        end

        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            varargout{1}='frame';
        end

        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='frameofsamples';
            varargout{2}='ctrl';
        end


        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;


            if obj.OutputSize==1&&strcmpi(prop,'Interleavesamples')
                flag=true;
            end
        end
    end

    methods(Static,Access=protected)

        function header=getHeaderImpl
            header=matlab.system.display.Header('commhdl.internal.FrameToFrameOfSamples',...
            'ShowSourceLink',false,...
            'Title','Frame To Frame Of Samples');
        end

        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end

    end

end
