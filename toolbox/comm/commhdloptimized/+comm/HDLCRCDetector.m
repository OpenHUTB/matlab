classdef(StrictDefaults)HDLCRCDetector<matlab.System








































































































%#codegen
%#ok<*EMCLS>

    properties(Nontunable)





        Polynomial=[1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,1];









        InitialState=0;








        DirectMethod(1,1)logical=false;




        ReflectInput(1,1)logical=false;





        ReflectCRCChecksum(1,1)logical=false;











        FinalXORValue=0;
    end

    properties(Access=private)

        cHDLCRCGenerator;
        crcInBufEn=false;
        mReg;
        csuminReg;
        startInReg;
        validInReg;
        endInReg;
        outputCRC=false;
        outputCRCReg;
        sysenb=false;
        processCRC=false;
        counter1=0;
        counter2=0;
        counter3=0;
        counter4=0;
        counter1En=false;
        counter4En=false;
        crcInBuf;
        yReg;
        yIni;
        startOutReg;
        validOutReg;

    end


    properties(Nontunable,Access=private)
        crclen=16;
        datalen;
        depth=1;
        isIntIn=false;
        inDisp;
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl


            header=matlab.system.display.Header('comm.HDLCRCDetector',...
            'ShowSourceLink',false,...
            'Title','General CRC Syndrome Detector HDL Optimized');
        end
    end

    methods(Access=public)
        function latency=getLatency(obj)
            latency=(obj.crclen/obj.datalen)*(3)+2;
        end
    end

    methods
        function obj=HDLCRCDetector(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','Communication_Toolbox'))
                    error(message('comm:HDLCRC:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','Communication_Toolbox');
            end
            setProperties(obj,nargin,varargin{:},'Polynomial');
        end

        function set.Polynomial(obj,val)
            obj.validateVectorInputs(val,'Polynomial');
            val=reshape(val,[1,length(val)]);
            obj.Polynomial=val;
            obj.crclen=length(val)-1;%#ok<*MCSUP>
        end

        function set.InitialState(obj,val)
            validateInitValue(obj,val,1);
            obj.InitialState=val;
        end

        function set.FinalXORValue(obj,val)
            validateInitValue(obj,val,2);
            obj.FinalXORValue=val;
        end
    end


    methods(Access=protected)

        function resetImpl(obj)

            reset(obj.cHDLCRCGenerator);
            obj.crcInBufEn=false;
            obj.mReg(:)=0;
            obj.csuminReg(:)=0;
            obj.startInReg(:)=0;
            obj.validInReg(:)=0;
            obj.endInReg(:)=0;
            obj.outputCRC=false;
            obj.outputCRCReg=false;
            obj.sysenb=false;
            obj.processCRC=false;
            obj.counter1(:)=0;
            obj.counter2(:)=0;
            obj.counter3(:)=0;
            obj.counter4(:)=0;
            obj.counter1En=false;
            obj.counter4En=false;
            obj.crcInBuf(:)=0;
            obj.yReg(:)=0;
            obj.yIni(:)=0;
            obj.startOutReg(:)=0;
            obj.validOutReg(:)=0;
        end


        function[y,startOut,endOut,validOut,err]=outputImpl(obj,m,startIn,endIn,validIn)%#ok<INUSL>







            [ty,tstartOut,tendOut,tvalidOut]=output(...
            obj.cHDLCRCGenerator,...
            obj.mReg(:,1),...
            obj.startInReg(1)&&validIn,...
            endIn&&validIn,...
            obj.validInReg(1)&&validIn);%#ok<ASGLU>

            y=obj.yReg(:,1);
            startOut=obj.startOutReg(1);
            endOut=tendOut;
            validOut=obj.validOutReg(1);


            if obj.depth==1
                if obj.isIntIn
                    t=(obj.crcInBuf~=ty);
                else
                    t=~isempty(find(xor(obj.crcInBuf,ty),1));
                end
            else






                dataSel=obj.outputCRC;



                if obj.isIntIn
                    tcomp=(obj.crcInBuf(:,1)~=ty);
                else
                    tcomp=~isempty(find(xor(obj.crcInBuf(:,1),ty),1));
                end



                if dataSel&&tcomp
                    obj_counter3=obj.counter3+1;
                else
                    obj_counter3=obj.counter3;
                end
                t=obj_counter3>0;

            end



            if tendOut
                err=t;
            else
                err=false;
            end
        end

        function updateImpl(obj,m,startIn,endIn,validIn)









            [ty,tstartOut,tendOut,tvalidOut]=step(...
            obj.cHDLCRCGenerator,...
            obj.mReg(:,1),...
            obj.startInReg(1)&&validIn,...
            endIn&&validIn,...
            obj.validInReg(1)&&validIn);







            if obj.depth==1







                if obj.crcInBufEn
                    obj.crcInBuf=obj.csuminReg(:,1);
                end

                if endIn&&validIn
                    obj.crcInBufEn=true;
                else
                    obj.crcInBufEn=false;
                end

                dataSel=tendOut;
            else


                outputCRCGen(obj,endIn&&validIn);
                dataSel=obj.outputCRCReg;


                obj.crcInBufEn=obj.counter1En;


                if obj.isIntIn
                    tcomp=(obj.crcInBuf(:,1)~=ty);
                else

                    tcomp=~isempty(find(xor(obj.crcInBuf(:,1),ty),1));
                end


                if dataSel&&tcomp

                    obj.counter3=obj.counter3+1;
                end




                if tendOut
                    obj.counter3=0;
                end


                if obj.counter1En

                    obj.crcInBuf(:,1:end-1)=obj.crcInBuf(:,2:end);
                    obj.crcInBuf(:,end)=obj.csuminReg(:,1);
                elseif dataSel
                    obj.crcInBuf(:,1:end-1)=obj.crcInBuf(:,2:end);
                    obj.crcInBuf(:,end)=0;
                end



                if obj.counter1En
                    obj.counter1=obj.counter1+1;
                    if obj.counter1==obj.depth
                        obj.counter1=0;
                        obj.counter1En=false;
                    end
                end

                if endIn&&validIn
                    obj.counter1En=true;
                end


            end










            if dataSel
                yRegIn=obj.yIni;
                validRegIn=false;
            else

                yRegIn=ty;
                validRegIn=tvalidOut;
            end


            if(obj.depth>1)&&(validIn)
                obj.mReg(:,1:end-1)=obj.mReg(:,2:end);
            end
...
...
...
...
...
...

            if(obj.depth>1)
                if(endIn&&validIn)
                    obj.csuminReg(:,1:end-1)=obj.mReg(:,1:end-1);
                elseif obj.crcInBufEn
                    obj.csuminReg(:,1:end-1)=obj.csuminReg(:,2:end);
                end
            end

            if(obj.depth>1)&&validIn
                obj.startInReg(1:end-1)=obj.startInReg(2:end);
                obj.validInReg(1:end-1)=obj.validInReg(2:end);
            end

            if(obj.depth>1)
                obj.yReg(:,1:end-1)=obj.yReg(:,2:end);
                obj.startOutReg(1:end-1)=obj.startOutReg(2:end);
                obj.validOutReg(1:end-1)=obj.validOutReg(2:end);
            end

            if validIn
                obj.mReg(:,end)=m;
                obj.startInReg(end)=startIn&&validIn;
                obj.validInReg(end)=validIn;
            end

            if(endIn&&validIn)||obj.crcInBufEn
                obj.csuminReg(:,end)=m;
            end

            obj.yReg(:,end)=yRegIn;
            obj.startOutReg(end)=tstartOut;
            obj.validOutReg(end)=validRegIn;


            if(endIn&&validIn)

                obj.mReg(:)=0;
                obj.startInReg(:)=0;
                obj.validInReg(:)=0;
            end

        end



        function outputCRCGen(obj,endIn)
























            obj.outputCRCReg=obj.outputCRC;
            obj.outputCRC=obj.counter4En;

            if obj.processCRC
                obj.counter2=obj.counter2+1;
            end

            if obj.counter4En
                obj.counter4=obj.counter4+1;

            end


            if obj.counter4==obj.depth

                obj.counter4En=false;
                obj.counter4=0;
            end

            if obj.counter2==obj.depth

                obj.processCRC=false;

                obj.sysenb=false;
                obj.counter2=0;
                obj.counter4En=true;
            end



            if obj.endInReg&&obj.sysenb
                obj.processCRC=true;

            end

            obj.endInReg=(endIn);












            if obj.startInReg(1)&&~obj.sysenb

                obj.sysenb=true;

            end





        end


        function setupImpl(obj,m,startIn,endIn,validIn)




            name='Input message';
            isScalarIn=isscalar(m);
            obj.isIntIn=isScalarIn&&~isa(m,'double')&&~isa(m,'logical');

            if obj.isIntIn
                validateattributes(m,{'uint8','uint16','uint32','uint64','embedded.fi'},{'scalar','integer'},'',name);
            else
                if isa(m,'double')
                    validateattributes(m,{'double'},...
                    {'vector','binary','column'},'',name);
                else
                    validateattributes(m,{'logical','double'},{'vector','binary','column'},'',name);
                end
            end



            if~obj.isIntIn
                obj.datalen=coder.const(length(m));
            end

            if isempty(coder.target)||~coder.internal.isAmbiguousTypes



                dataclass=class(m);
                isUInt=~isempty(strfind(dataclass,'uint'));

                if obj.isIntIn
                    coder.internal.errorIf(isScalarIn&&~isUInt&&issigned(m),...
                    'comm:HDLCRC:UnsignedIntFixptExpected');

                    obj.datalen=coder.const(dsphdlshared.hdlgetwordsizefromdata(m));

                    if~isUInt
                        coder.internal.errorIf(m.FractionLength~=0,...
                        'comm:HDLCRC:UnsignedIntFixptExpected');

                    end

                end



                tlen=length(obj.Polynomial);
                if tlen>=2&&tlen>=obj.datalen

                    obj.crclen=length(obj.Polynomial(2:end));
                    clenflag=false;
                else
                    clenflag=true;
                end





                coder.internal.errorIf(clenflag||mod(obj.crclen,obj.datalen)~=0,...
                'comm:HDLCRC:InvPolyDataWidth');

                coder.internal.errorIf(obj.ReflectInput&&mod(obj.datalen,8)~=0||obj.datalen<1,...
                'comm:HDLCRC:InvDataWidth');




                validateattributes(startIn,{'logical'},{'scalar'},'','startIn');
                validateattributes(endIn,{'logical'},{'scalar'},'','endIn');
                validateattributes(validIn,{'logical'},{'scalar'},'','validIn');
            else
                dataclass='uint8';
                isUInt=true;
            end





            obj.depth=round(obj.crclen/obj.datalen);


            obj.startInReg=false(obj.depth,1);
            obj.validInReg=false(obj.depth,1);


            obj.endInReg=false;
            obj.startOutReg=false(obj.depth,1);
            obj.validOutReg=false(obj.depth,1);


            if obj.isIntIn

                if isUInt
                    obj.crcInBuf=cast(zeros(1,obj.depth),dataclass);
                    obj.mReg=cast(zeros(1,obj.depth),dataclass);
                    obj.csuminReg=cast(zeros(1,obj.depth),dataclass);
                    obj.yReg=cast(zeros(1,obj.depth),dataclass);
                    obj.yIni=cast(0,dataclass);
                else
                    obj.crcInBuf=fi(zeros(1,obj.depth),m.numerictype);
                    obj.mReg=fi(zeros(1,obj.depth),m.numerictype);
                    obj.csuminReg=fi(zeros(1,obj.depth),m.numerictype);
                    obj.yReg=fi(zeros(1,obj.depth),m.numerictype);
                    obj.yIni=fi(0,m.numerictype);
                end
            else

                obj.crcInBuf=false(obj.datalen,obj.depth);
                obj.mReg=false(obj.datalen,obj.depth);
                obj.csuminReg=false(obj.datalen,obj.depth);
                obj.yReg=cast(zeros(obj.datalen,obj.depth),dataclass);
                obj.yIni=false(obj.datalen,1);








            end



            obj.cHDLCRCGenerator=comm.HDLCRCGenerator(...
            'Polynomial',obj.Polynomial,...
            'InitialState',obj.InitialState,...
            'DirectMethod',obj.DirectMethod,...
            'ReflectInput',obj.ReflectInput,...
            'ReflectCRCChecksum',obj.ReflectCRCChecksum,...
            'FinalXORValue',obj.FinalXORValue);

        end
        function validateInputsImpl(obj,m,~,~,~)
            name='Input message';
            isScalarIn=isscalar(m);
            obj.isIntIn=isScalarIn&&~isa(m,'double')&&~isa(m,'logical');

            if~obj.isIntIn
                obj.datalen=coder.const(length(m));
            end

            if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                if obj.isIntIn
                    obj.datalen=coder.const(dsphdlshared.hdlgetwordsizefromdata(m));
                end
                obj.inDisp=~isempty(m);
            end
        end



        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end


        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked


                s.cHDLCRCGenerator=matlab.System.saveObject(obj.cHDLCRCGenerator);
                s.crcInBufEn=obj.crcInBufEn;
                s.mReg=obj.mReg;
                s.csuminReg=obj.csuminReg;
                s.startInReg=obj.startInReg;
                s.validInReg=obj.validInReg;
                s.endInReg=obj.endInReg;
                s.outputCRC=obj.outputCRC;
                s.outputCRCReg=obj.outputCRCReg;
                s.sysenb=obj.sysenb;
                s.processCRC=obj.processCRC;
                s.counter1=obj.counter1;
                s.counter2=obj.counter2;
                s.counter3=obj.counter3;
                s.counter4=obj.counter4;
                s.counter1En=obj.counter1En;
                s.counter4En=obj.counter4En;
                s.crcInBuf=obj.crcInBuf;
                s.yReg=obj.yReg;
                s.yIni=obj.yIni;
                s.startOutReg=obj.startOutReg;
                s.validOutReg=obj.validOutReg;

            end
        end


        function loadObjectImpl(obj,s,wasLocked)
            if wasLocked
                obj.cHDLCRCGenerator=matlab.System.loadObject(s.cHDLCRCGenerator);
                s=rmfield(s,'cHDLCRCGenerator');
            end
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end



        function num=getNumInputsImpl(~)
            num=4;
        end


        function num=getNumOutputsImpl(~)
            num=5;
        end


        function icon=getIconImpl(obj)
            if isempty(obj.inDisp)
                icon='General CRC\nSyndrome\nDetector\nHDL Optimized\nLatency = --';
            else
                icon=['General CRC\nSyndrome\nDetector\nHDL Optimized\nLatency = ',num2str(getLatency(obj))];
            end
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
            varargout{5}='err';
        end


        function validateInitValue(obj,val,flag)


            if(flag==1)
                para='InitialState';
            else
                para='FinalXORValue';
            end
            obj.validateVectorInputs(val,para);
            val=reshape(val,[1,length(val)]);

            coder.internal.errorIf(length(val)~=obj.crclen&&length(val)~=1,...
            'comm:HDLCRC:NotSameLength');

        end

    end


    methods(Static,Access=private)


        function validateVectorInputs(x,name)
            if isa(x,'double')
                validateattributes(x,{'double'},...
                {'vector','binary'},'',name);
            else
                validateattributes(x,{'logical','double'},{'vector','binary'},'',name);
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
