classdef(StrictDefaults)MeasureTiming<matlab.System




















































































%#codegen
%#ok<*EMCLS>

    properties(Access=private)
        HCount;
        VCount;
        InFrame;
        InLine;
ActivePixelCounter
ActiveLineCounter
TotalPixelCounter
TotalLineCounter
VBICounter
HBICounter
ActivePixelAvg
ActiveLineAvg
TotalPixelAvg
TotalLineAvg
VBIAvg
HBIAvg
    end

    properties(Access=private,Nontunable)
        PrivNRegions;
    end

    methods
        function obj=MeasureTiming(varargin)
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
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl

            header=matlab.system.display.Header('visionhdl.MeasureTiming',...
            'ShowSourceLink',false,...
            'Title','Measure Timing');
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
                s.HCount=obj.HCount;
                s.VCount=obj.VCount;
                s.InFrame=obj.InFrame;
                s.InLine=obj.InLine;
                s.ActivePixelCounter=obj.ActivePixelCounter;
                s.ActiveLineCounter=obj.ActiveLineCounter;
                s.TotalPixelCounter=obj.TotalPixelCounter;
                s.TotalLineCounter=obj.TotalLineCounter;
                s.VBICounter=obj.VBICounter;
                s.HBICounter=obj.HBICounter;
                s.ActivePixelAvg=obj.ActivePixelAvg;
                s.ActiveLineAvg=obj.ActiveLineAvg;
                s.TotalPixelAvg=obj.TotalPixelAvg;
                s.TotalLineAvg=obj.TotalLineAvg;
                s.VBIAvg=obj.VBIAvg;
                s.HBIAvg=obj.HBIAvg;
            end
        end

        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end



        function setupImpl(obj,~)
            resetImpl(obj);
        end

        function resetImpl(obj)
            obj.HCount=uint32(0);
            obj.VCount=uint32(0);
            obj.InFrame=false;
            obj.InLine=false;

            obj.ActivePixelCounter=uint32(0);
            obj.ActiveLineCounter=uint32(0);
            obj.TotalPixelCounter=uint32(0);
            obj.TotalLineCounter=uint32(0);
            obj.VBICounter=uint32(0);
            obj.HBICounter=uint32(0);

            obj.ActivePixelAvg=double(0);
            obj.ActiveLineAvg=double(0);
            obj.TotalPixelAvg=double(0);
            obj.TotalLineAvg=double(0);
            obj.VBIAvg=double(0);
            obj.HBIAvg=double(0);
        end

        function[activePixels,activeLines,totalPixels,totalLines,horizBlank,vertBlank]=outputImpl(obj,~)
            activePixels=obj.ActivePixelAvg;
            activeLines=obj.ActiveLineAvg;
            totalPixels=obj.TotalPixelAvg;
            totalLines=obj.TotalLineAvg;
            vertBlank=obj.VBIAvg;
            horizBlank=obj.HBIAvg;
        end


        function updateImpl(obj,ctrlIn)
            lineFrameFSM(obj,ctrlIn);
        end


        function lineFrameFSM(obj,ctrlIn)








            obj.TotalLineCounter=obj.TotalLineCounter+1;
            if obj.InFrame
                obj.TotalPixelCounter=obj.TotalPixelCounter+1;
            end
            if ctrlIn.valid
                if obj.InFrame&&obj.InLine
                    obj.HCount(:)=obj.HCount+1;
                    obj.ActivePixelCounter=obj.ActivePixelCounter+1;
                end
                if ctrlIn.vStart
                    obj.InFrame=true;
                    obj.VCount=uint32(1);
                    obj.ActiveLineCounter=uint32(1);
                    obj.ActivePixelCounter=uint32(1);
                    if ctrlIn.hStart
                        obj.InLine=true;
                        obj.HCount=uint32(1);
                    else

                    end
                elseif obj.InFrame&&ctrlIn.vEnd
                    obj.InFrame=false;
                    if ctrlIn.hEnd
                        obj.InLine=false;
                    else

                    end

                    delta=double(obj.ActivePixelCounter)-obj.ActivePixelAvg;
                    if obj.ActiveLineCounter==1
                        obj.ActivePixelAvg=double(obj.ActivePixelCounter);
                    else
                        obj.ActivePixelAvg=obj.ActivePixelAvg+delta/double(obj.ActiveLineCounter);
                    end

                    obj.ActiveLineAvg=double(obj.ActiveLineCounter);
                    obj.TotalLineAvg=double(obj.TotalLineCounter)/double(obj.TotalPixelAvg);
                    obj.VBIAvg=(double(obj.VBICounter)-obj.HBIAvg)/obj.TotalPixelAvg;
                    obj.HBICounter=uint32(0);
                    obj.VBICounter=uint32(0);
                    obj.ActivePixelCounter=uint32(1);
                    obj.ActiveLineCounter=uint32(1);
                    obj.TotalPixelCounter=uint32(0);
                    obj.TotalLineCounter=uint32(0);

                elseif obj.InFrame&&obj.InLine&&ctrlIn.hEnd
                    obj.VCount(:)=obj.VCount+1;
                    obj.InLine=false;
                    delta=double(obj.ActivePixelCounter)-obj.ActivePixelAvg;
                    deltaHBI=double(obj.HBICounter)-obj.HBIAvg;
                    if obj.ActiveLineCounter==1
                        obj.ActivePixelAvg=double(obj.ActivePixelCounter);
                    else
                        obj.ActivePixelAvg=obj.ActivePixelAvg+delta/double(obj.ActiveLineCounter);
                    end

                    if obj.ActiveLineCounter==2
                        obj.HBIAvg=double(obj.HBICounter);
                    elseif obj.ActiveLineCounter>2
                        obj.HBIAvg=obj.HBIAvg+deltaHBI/double(obj.ActiveLineCounter-2);
                    end
                    obj.ActivePixelCounter=uint32(0);
                    obj.HBICounter=uint32(0);
                    obj.ActiveLineCounter=obj.ActiveLineCounter+1;
                elseif obj.InFrame&&ctrlIn.hStart
                    obj.InLine=true;
                    obj.HCount=uint32(1);
                    obj.ActivePixelCounter=obj.ActivePixelCounter+1;

                    delta=double(obj.TotalPixelCounter)-obj.TotalPixelAvg;
                    if obj.ActiveLineCounter==2
                        obj.TotalPixelAvg=double(obj.TotalPixelCounter);
                    else
                        obj.TotalPixelAvg=obj.TotalPixelAvg+delta/double(obj.ActiveLineCounter-1);
                    end
                    obj.TotalPixelCounter=uint32(0);
                elseif obj.InFrame&&~obj.InLine&&ctrlIn.hEnd
                    obj.InLine=false;

                elseif~obj.InFrame&&(ctrlIn.hStart||ctrlIn.hEnd)

                end
            else
                if obj.InFrame&&obj.InLine

                elseif obj.InFrame

                    obj.HBICounter=obj.HBICounter+1;
                else

                    obj.VBICounter=obj.VBICounter+1;
                end
            end
        end

        function icon=getIconImpl(~)
            icon=sprintf('MeasureTiming');
        end


        function varargout=getOutputSizeImpl(obj)
            for ii=1:getNumOutputs(obj)
                varargout{ii}=1;
            end
        end

        function varargout=isOutputComplexImpl(obj)
            for ii=1:getNumOutputs(obj)
                varargout{ii}=false;
            end
        end

        function varargout=getOutputDataTypeImpl(obj)
            for ii=1:getNumOutputs(obj)
                varargout{ii}=numerictype('double');
            end
        end

        function varargout=isOutputFixedSizeImpl(obj)
            for ii=1:getNumOutputs(obj)
                varargout{ii}=true;
            end
        end


        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

    end

end

