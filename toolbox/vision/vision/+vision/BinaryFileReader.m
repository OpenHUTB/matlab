classdef BinaryFileReader<matlab.system.SFunSystem&...
    matlab.system.mixin.FiniteSource

%#function mvipfileread

    properties(Nontunable)




        Filename='vipmen.bin';



        VideoFormat='Four character codes';





        FourCharacterCode='I420';



        BitstreamFormat='Planar';



        OutputSize=[120,160];





        VideoComponentCount=3;







        LineOrder='Top line first';




        ByteOrder='Little endian';



        PlayCount=1;





        InterlacedVideo(1,1)logical=false;




        SignedData(1,1)logical=false;
    end

    properties(Dependent,Nontunable)





        VideoComponentBits=[8,8,8];









        VideoComponentSizes=[120,160;60,80;60,80];








        VideoComponentOrder=[1,2,3];
    end

    properties(Access=private)
        pVideoComponentBits=[8,8,8,8];
        pVideoComponentSizes=[120,160;60,80;60,80;288,352];
        pVideoComponentOrder=[1,2,3,4];
    end

    properties(Constant,Hidden,Nontunable)
        VideoFormatSet=matlab.system.StringSet({...
        'Four character codes',...
        'Custom'});
        FourCharacterCodeSet=matlab.system.StringSet(getFourccInCellArray);
        BitstreamFormatSet=matlab.system.StringSet({...
        'Packed',...
        'Planar'});
        LineOrderSet=matlab.system.StringSet({...
        'Top line first',...
        'Bottom line first'});
        ByteOrderSet=matlab.system.StringSet({...
        'Little endian',...
        'Big endian'});
    end

    methods

        function obj=BinaryFileReader(varargin)
            if nargin>0
                [varargin{:}]=convertStringsToChars(varargin{:});
            end
            obj@matlab.system.SFunSystem('mvipfileread');
            if mod(nargin,2)



                args=varargin;
            else
                if~isdeployed
                    args=varargin;
                else




                    args=[{'vipmen.bin'},varargin];
                    for ii=1:2:nargin

                        if ischar(varargin{ii})&&strcmp(varargin{ii},'Filename')
                            args=varargin;
                            break;
                        end
                    end
                end
            end
            setProperties(obj,length(args),args{:},'Filename');
            if strcmp(get(obj,'Filename'),'vipmen.bin')

                set(obj,'Filename','vipmen.bin');
            end
        end

        function set.Filename(obj,value)
            validateattributes(value,{'char'},{'nonempty'},'','Filename');
            theFile=which(value);
            if isempty(theFile)
                theFile=value;
            end
            obj.Filename=theFile;
        end

        function set.VideoFormat(obj,value)

            getIndex(obj.VideoFormatSet,value);

            oldVideoFormat=obj.VideoFormat;
            newVideoFormat=value;
            oldBitstreamFormat=obj.BitstreamFormat;%#ok<MCSUP>
            newBitstreamFormat=obj.BitstreamFormat;%#ok<MCSUP>
            checkAndAdjustVideoComponentOrder(obj,oldVideoFormat,...
            newVideoFormat,oldBitstreamFormat,newBitstreamFormat);

            obj.VideoFormat=value;
        end

        function set.BitstreamFormat(obj,value)

            getIndex(obj.BitstreamFormatSet,value);

            oldVideoFormat=obj.VideoFormat;%#ok<MCSUP>
            newVideoFormat=obj.VideoFormat;%#ok<MCSUP>
            oldBitstreamFormat=obj.BitstreamFormat;
            newBitstreamFormat=value;
            checkAndAdjustVideoComponentOrder(obj,oldVideoFormat,...
            newVideoFormat,oldBitstreamFormat,newBitstreamFormat);

            obj.BitstreamFormat=value;
        end

        function set.OutputSize(obj,value)
            value=value(:).';
            validateattributes(value,{'numeric'},{'vector','size',[1,2]},...
            '','OutputSize');
            obj.OutputSize=value;
        end

        function set.VideoComponentCount(obj,value)
            coder.internal.errorIf(~any(value==1:4),...
            'vision:binaryFileIO:invalidVideoComponentCount');
            obj.VideoComponentCount=value;
        end

        function set.VideoComponentBits(obj,value)
            coder.internal.errorIf(any(value<=0)||...
            ~isa(value,'double')||...
            any(floor(value)~=value)||...
            length(value)~=obj.VideoComponentCount||...
            isempty(value),...
            'vision:binaryFileIO:invalidVideoComponentBits',...
            obj.VideoComponentCount);

            obj.pVideoComponentBits(1:length(value))=value;
        end

        function value=get.VideoComponentBits(obj)
            value=obj.pVideoComponentBits(1:obj.VideoComponentCount);
        end

        function set.VideoComponentSizes(obj,value)
            coder.internal.errorIf(any(any(value<=0))||~isa(value,'double')||...
            any(any(floor(value)~=value))||...
            (size(value,1)~=obj.VideoComponentCount||...
            isempty(value)||size(value,2)~=2),...
            'vision:binaryFileIO:invalidVideoComponentSizes',...
            obj.VideoComponentCount);

            obj.pVideoComponentSizes(1:size(value,1),:)=value;
        end

        function value=get.VideoComponentSizes(obj)
            value=obj.pVideoComponentSizes(1:obj.VideoComponentCount,:);
        end

        function set.VideoComponentOrder(obj,value)
            coder.internal.errorIf(any(value<=0)||~isreal(value)||...
            any(floor(value)~=value)||...
            isempty(value),...
            'vision:binaryFileIO:invalidVideoComponentOrder');

            if isPackedFormat(obj)
                obj.pVideoComponentOrder=value;
            else
                coder.internal.errorIf(...
                length(value)~=obj.VideoComponentCount,...
                'vision:binaryFileIO:invalidVideoComponentOrderLength');

                obj.pVideoComponentOrder(1:length(value))=value;
            end

        end

        function value=get.VideoComponentOrder(obj)
            if isPackedFormat(obj)
                value=obj.pVideoComponentOrder;
            else
                value=obj.pVideoComponentOrder(1:obj.VideoComponentCount);
            end
        end
    end

    methods(Hidden)
        function setParameters(obj)
            if isCustomFormat(obj)
                if isPackedFormat(obj)
                    coder.internal.errorIf(length(obj.pVideoComponentOrder)<obj.VideoComponentCount,...
                    'vision:binaryFileIO:invalidVideoComponentOrderMinLength',obj.VideoComponentCount);
                    coder.internal.errorIf(~isequal(1:obj.VideoComponentCount,unique(obj.pVideoComponentOrder)),...
                    'vision:binaryFileIO:invalidVideoComponentOrderCoverage');
                else
                    componentOrder=obj.pVideoComponentOrder(1:obj.VideoComponentCount);
                    coder.internal.errorIf(~isequal(sort(componentOrder),unique(componentOrder)),...
                    'vision:binaryFileIO:duplicatedVideoComponentOrder');
                end
            end


            VideoFormatIdx=getIndex(...
            obj.VideoFormatSet,obj.VideoFormat);
            BitstreamFormatIdx=getIndex(...
            obj.BitstreamFormatSet,obj.BitstreamFormat);
            LineOrderIdx=getIndex(...
            obj.LineOrderSet,obj.LineOrder);
            FileEndian=getIndex(...
            obj.ByteOrderSet,obj.ByteOrder);


            Rows=cell(1,obj.VideoComponentCount);
            Cols=cell(1,obj.VideoComponentCount);
            Bits=cell(1,obj.VideoComponentCount);
            for ii=1:obj.VideoComponentCount
                Rows{ii}=obj.VideoComponentSizes(ii,1);
                Cols{ii}=obj.VideoComponentSizes(ii,2);
                Bits{ii}=obj.VideoComponentBits(ii);
            end

            [FrameSizes,PackFrameSize,FOURCC,NumOutputs,...
            ~,Bits,pFilename]=vipblkreadbinaryfile(...
            obj.VideoComponentCount,...
            {'Y''','Cb','Cr','Alpha'},...
            obj.VideoComponentOrder,...
            Rows,...
            Cols,...
            obj.OutputSize(1),...
            obj.OutputSize(2),...
            Bits,...
            obj.Filename,...
            obj.VideoFormat,...
            obj.BitstreamFormat,...
            obj.FourCharacterCode,'on');

            VideoComponentOrderIdx=obj.VideoComponentOrder-1;
            if(obj.PlayCount==1)
                LoopOrNot=0;
            else
                LoopOrNot=1;
            end

            obj.compSetParameters({...
            pFilename,...
            LoopOrNot,...
            obj.PlayCount,...
            VideoFormatIdx,...
            FOURCC,...
            BitstreamFormatIdx,...
            NumOutputs,...
            Bits,...
            VideoComponentOrderIdx,...
            double(obj.InterlacedVideo),...
            LineOrderIdx,...
            FrameSizes,...
            PackFrameSize,...
            double(obj.SignedData),...
            FileEndian,...
            double(true)...
            ,1...
            });
        end
    end

    methods(Access=protected)

        function status=isDoneImpl(obj)





            if isLocked(obj)
                status=lastOutput(obj,int32(getNumOutputs(obj)));
            else
                status=false;
            end
        end

        function flag=isInactivePropertyImpl(obj,prop)
            if strcmpi(obj.VideoFormat,'Four character codes')
                props={...
'BitstreamFormat'...
                ,'VideoComponentCount'...
                ,'VideoComponentBits'...
                ,'VideoComponentSizes'...
                ,'VideoComponentOrder'...
                ,'InterlacedVideo'...
                ,'SignedData'...
                ,'ByteOrder'};
            else
                props={'FourCharacterCode'};
                if~strcmp(obj.BitstreamFormat,'Packed')
                    props{end+1}='OutputSize';
                else
                    props{end+1}='VideoComponentSizes';
                end
            end
            flag=ismember(prop,props);
        end

        function flag=isCustomFormat(obj)
            flag=strcmp(obj.VideoFormat,'Custom');
        end

        function flag=isPackedFormat(obj)
            flag=isCustomFormat(obj)&&...
            strcmp(obj.BitstreamFormat,'Packed');
        end

        function checkAndAdjustVideoComponentOrder(obj,oldVideoFormat,...
            newVideoFormat,oldBitstreamFormat,newBitstreamFormat)

            wasPackedFormat=strcmp(oldVideoFormat,'Custom')...
            &&strcmp(oldBitstreamFormat,'Packed');
            isPackedFormat=strcmp(newVideoFormat,'Custom')...
            &&strcmp(newBitstreamFormat,'Packed');

            if~wasPackedFormat&&isPackedFormat


                validLengthOfComponentOrder=...
                min(length(obj.pVideoComponentOrder),obj.VideoComponentCount);
                obj.pVideoComponentOrder=...
                obj.pVideoComponentOrder(1:validLengthOfComponentOrder);

            elseif wasPackedFormat&&~isPackedFormat



                numelOrder=length(obj.pVideoComponentOrder);
                if numelOrder<4
                    obj.pVideoComponentOrder(numelOrder+1:4)=numelOrder+1:4;
                end
            end
        end
    end

    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={...
'Filename'...
            ,'VideoFormat'...
            ,'FourCharacterCode'...
            ,'BitstreamFormat'...
            ,'OutputSize'...
            ,'VideoComponentCount'...
            ,'VideoComponentBits'...
            ,'VideoComponentSizes'...
            ,'VideoComponentOrder'...
            ,'InterlacedVideo'...
            ,'LineOrder'...
            ,'SignedData'...
            ,'ByteOrder'...
            ,'PlayCount'...
            };
        end



        function props=getValueOnlyProperties()
            props={'Filename'};
        end
    end

    methods(Sealed,Hidden)
        function close(obj)




            warning(message('MATLAB:system:throwObsoleteMethodWarningNewName',...
            class(obj),'close','release'));
            release(obj);
        end
    end
    methods(Access=public,Static,Hidden)

        function eofport=isEOFPortAvailable(~)
            eofport=true;
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='visionsources/Read Binary File';
        end
    end
end


function fourccnames=getFourccInCellArray
    fourcclist=vipblkgetFOURCCLIST;
    fourccnames=cell(1,size(fourcclist,1));
    for cnt=1:size(fourcclist,1)
        fourccnames{cnt}=fourcclist{cnt,1};
    end
end
