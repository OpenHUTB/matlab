classdef(StrictDefaults)HVCounter<matlab.System









































































%#codegen
%#ok<*EMCLS>


    properties(Nontunable)


        ActivePixelsPerLine=320;


        ActiveVideoLines=240;
    end

    properties(Access=private)
        InputControlReg;
        HResetValue;
        VResetValue;
        HCount;
        VCount;
        InFrame;
        InLine;
        InFramePrev;
        InLinePrev;
        ValidPrev;
        OutputControlReg;
        VCountNext;
    end

    methods
        function obj=HVCounter(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','Vision_HDL_Toolbox'))
                    error(message('visionhdl:visionhdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','Vision_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:});
        end

        function set.ActivePixelsPerLine(obj,val)
            validateattributes(val,{'numeric'},{'scalar','integer','real','>=',2},'','Active Pixels Per Line');
            obj.ActivePixelsPerLine=val;
        end

        function set.ActiveVideoLines(obj,val)
            validateattributes(val,{'numeric'},{'scalar','integer','real','>=',2},'','Active Video Lines');
            obj.ActiveVideoLines=val;
        end
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl

            header=matlab.system.display.Header('visionhdl.HVCounter',...
            'ShowSourceLink',false,...
            'Title','HVCounter');
        end

        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end
    end

    methods(Access=protected)
        function validateInputsImpl(~,ctrlIn)
            coder.extrinsic('validatecontrolsignals');
            if isempty(coder.target)||~eml_ambiguous_types

                validatecontrolsignals(ctrlIn);
            end
        end

        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                if~isempty(findprop(obj,fn{ii}))
                    obj.(fn{ii})=s.(fn{ii});
                end
            end
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);
            if obj.isLocked
                s.InputControlReg=obj.InputControlReg;
                s.HResetValue=obj.HResetValue;
                s.VResetValue=obj.VResetValue;
                s.HCount=obj.HCount;
                s.VCount=obj.VCount;
                s.InFrame=obj.InFrame;
                s.InLine=obj.InLine;
                s.InFramePrev=obj.InFramePrev;
                s.InLinePrev=obj.InLinePrev;
                s.ValidPrev=obj.ValidPrev;
                s.OutputControlReg=obj.OutputControlReg;
                s.VCountNext=obj.VCountNext;
            end
        end

        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end

        function setupImpl(obj,~)
            hWL=ceil(log2(1+double(obj.ActivePixelsPerLine)));
            vWL=ceil(log2(1+double(obj.ActiveVideoLines)));
            obj.HResetValue=fi(1,0,hWL,0);
            obj.VResetValue=fi(1,0,vWL,0);

            resetImpl(obj);
            obj.InputControlReg=pixelcontrolstruct(false,false,false,false,false);
            obj.OutputControlReg=pixelcontrolstruct(false,false,false,false,false);
        end

        function resetImpl(obj)
            obj.HCount=obj.HResetValue;
            obj.VCount=obj.VResetValue;
            obj.InFrame=false;
            obj.InLine=false;
            obj.InFramePrev=false;
            obj.InLinePrev=false;
            obj.ValidPrev=false;
            obj.VCountNext=false;
        end

        function[hCount,vCount,ctrlOut]=outputImpl(obj,~)
            if(obj.OutputControlReg.valid==true)
                hCount=obj.HCount;
                vCount=obj.VCount;
                ctrlOut=obj.OutputControlReg;
            else

                hCount=cast(0,'like',obj.HResetValue);
                vCount=cast(0,'like',obj.VResetValue);
                ctrlOut=obj.OutputControlReg;
            end
        end

        function updateImpl(obj,ctrlIn)

            lineFrameFSM(obj);

            obj.OutputControlReg=obj.InputControlReg;
            obj.InputControlReg=ctrlIn;
        end


        function lineFrameFSM(obj,varargin)


            obj.InFramePrev=obj.InFrame;
            obj.InLinePrev=obj.InLine;
            if obj.VCountNext
                obj.VCount(:)=obj.VCount+cast(1,'like',obj.VResetValue);
                obj.VCountNext=false;
            end

            if obj.InputControlReg.valid
                if obj.InFrame&&obj.InLine
                    obj.HCount(:)=obj.HCount+cast(1,'like',obj.HResetValue);
                end
                if obj.InputControlReg.vStart
                    obj.InFrame=true;
                    obj.VCount(:)=obj.VResetValue;

                    if obj.InputControlReg.hStart
                        obj.InLine=true;
                        obj.HCount(:)=obj.HResetValue;
                    else

                    end
                elseif obj.InFrame&&obj.InputControlReg.vEnd
                    obj.InFrame=false;
                    if obj.InputControlReg.hEnd
                        obj.InLine=false;
                    else

                    end
                elseif obj.InFrame&&obj.InLine&&obj.InputControlReg.hEnd
                    obj.VCountNext=true;
                    obj.InLine=false;
                elseif obj.InFrame&&obj.InputControlReg.hStart
                    obj.InLine=true;
                    obj.HCount(:)=obj.HResetValue;
                elseif obj.InFrame&&~obj.InLine&&obj.InputControlReg.hEnd
                    obj.InLine=false;

                elseif~obj.InFrame&&(obj.InputControlReg.hStart||obj.InputControlReg.hEnd)

                end
            end
        end

        function num=getNumInputsImpl(~)
            num=1;
        end

        function num=getNumOutputsImpl(~)
            num=3;
        end


        function icon=getIconImpl(~)
            icon=sprintf('HV Counter');
        end


        function varargout=getInputNamesImpl(obj)
            numInputs=getNumInputs(obj);
            varargout=cell(1,numInputs);
            varargout{1}='ctrl';
        end


        function varargout=getOutputNamesImpl(obj)
            numOutputs=getNumOutputs(obj);
            varargout=cell(1,numOutputs);
            varargout{1}='hCount';
            varargout{2}='vCount';
            varargout{3}='ctrl';
        end


        function varargout=getOutputSizeImpl(obj)
            varargout{1}=[1,1];
            varargout{2}=[1,1];
            varargout{3}=propagatedInputSize(obj,1);
        end

        function varargout=isOutputComplexImpl(~)
            varargout{1}=false;
            varargout{2}=false;
            varargout{3}=false;
        end

        function varargout=getOutputDataTypeImpl(obj)
            varargout{1}=numerictype(0,ceil(log2(1+double(obj.ActivePixelsPerLine))),0);
            varargout{2}=numerictype(0,ceil(log2(1+double(obj.ActiveVideoLines))),0);
            varargout{3}=pixelcontrolbustype;
        end

        function varargout=isOutputFixedSizeImpl(obj)
            varargout{1}=propagatedInputFixedSize(obj,1);
            varargout{2}=propagatedInputFixedSize(obj,1);
            varargout{3}=propagatedInputFixedSize(obj,1);

        end

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

    end

end

