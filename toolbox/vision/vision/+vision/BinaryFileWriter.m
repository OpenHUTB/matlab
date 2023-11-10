classdef BinaryFileWriter<matlab.system.SFunSystem

%#function mvipfilewrite

    properties(Nontunable)

        Filename='output.bin';

        VideoFormat='Four character codes';

        FourCharacterCode='I420';

        BitstreamFormat='Planar';

        VideoComponentCount=3;

        VideoComponentBitsSource='Auto';

        LineOrder='Top line first';

        ByteOrder='Little endian';
        InterlacedVideo(1,1)logical=false;

        SignedData(1,1)logical=false;
    end

    properties(Dependent,Nontunable)

        VideoComponentBits=[8,8,8];

        VideoComponentOrder=[1,2,3];
    end

    properties(Access=private)
        pVideoComponentBits=[8,8,8,8];
        pVideoComponentOrder=[1,2,3,4];
    end

    properties(Constant,Hidden)
        VideoFormatSet=matlab.system.StringSet({...
        'Four character codes',...
        'Custom'});
        FourCharacterCodeSet=matlab.system.StringSet(getFourccInCellArray());
        BitstreamFormatSet=matlab.system.StringSet({...
        'Packed',...
        'Planar'});
        LineOrderSet=matlab.system.StringSet({...
        'Top line first',...
        'Bottom line first'});
        ByteOrderSet=matlab.system.StringSet({...
        'Little endian',...
        'Big endian'});
        VideoComponentBitsSourceSet=matlab.system.StringSet({...
        'Auto',...
        'Property'});
    end

    methods

        function obj=BinaryFileWriter(varargin)
            obj@matlab.system.SFunSystem('mvipfilewrite');
            setProperties(obj,nargin,varargin{:},'Filename');
            setVarSizeAllowedStatus(obj,false);
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
            VideoComponentBitsSourceIdx=getIndex(...
            obj.VideoComponentBitsSourceSet,obj.VideoComponentBitsSource);
            VideoComponentBitsSourceIdx=2-VideoComponentBitsSourceIdx;

            Bits=obj.VideoComponentBits;
            Components={'Y''','Cb','Cr','Alpha'};

            [FrameRatios,PackSizeLoc,FOURCC,NumInputs,~,Bits]...
            =vipblkwritebinaryfile(...
            obj.VideoComponentCount,...
            Components,...
            obj.VideoComponentOrder,...
            Bits,...
            obj.VideoFormat,...
            obj.BitstreamFormat,...
            obj.FourCharacterCode,...
            obj.Filename);

            VideoComponentOrderIdx=obj.VideoComponentOrder-1;

            obj.compSetParameters({...
            obj.Filename,...
            VideoFormatIdx,...
            FOURCC,...
            BitstreamFormatIdx,...
            NumInputs,...
            VideoComponentBitsSourceIdx,...
            Bits,...
            VideoComponentOrderIdx,...
            double(obj.InterlacedVideo),...
            LineOrderIdx,...
            FrameRatios,...
            PackSizeLoc,...
            double(obj.SignedData),...
FileEndian...
            });
        end
    end

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)

            if strcmpi(obj.VideoFormat,'Four character codes')
                props={'BitstreamFormat'...
                ,'VideoComponentCount'...
                ,'VideoComponentBitsSource'...
                ,'VideoComponentBits'...
                ,'VideoComponentOrder'...
                ,'InterlacedVideo'...
                ,'SignedData'...
                ,'ByteOrder'};
            else
                props={'FourCharacterCode'};
                if~strcmp(obj.VideoComponentBitsSource,'Property')
                    props{end+1}='VideoComponentBits';
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
            ,'VideoComponentCount'...
            ,'VideoComponentBitsSource'...
            ,'VideoComponentBits'...
            ,'VideoComponentOrder'...
            ,'InterlacedVideo'...
            ,'LineOrder'...
            ,'SignedData'...
            ,'ByteOrder'...
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

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='visionsinks/Write Binary File';
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

