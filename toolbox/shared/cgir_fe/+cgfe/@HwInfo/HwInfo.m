


classdef HwInfo<cgfe.util.BaseClass

    properties(Constant,GetAccess=public,Hidden)
        HWNAMES={'x86','x86_64','generic32','generic16','generic8'};
    end

    properties
        Endianness='little';
        CharNumBits=int32(8);
        ShortNumBits=int32(16);
        IntNumBits=int32(32);
        LongNumBits=int32(32);
        LongLongNumBits=int32(64);
        FloatNumBits=int32(32);
        DoubleNumBits=int32(64);
        LongDoubleNumBits=int32(64);
        PointerNumBits=int32(32);
        Name='custom';
    end

    methods
        function this=HwInfo(varargin)
            [varargin{:}]=convertStringsToChars(varargin{:});
            if nargin==1
                if isa(varargin{1},'cgfe.HwInfo')
                    this=varargin{1};

                elseif ischar(varargin{1})

                    if strcmpi(varargin{1},'x86_64')
                        this=get_x86_64();
                    elseif strcmpi(varargin{1},'x86')
                        this=get_x86();
                    elseif strcmpi(varargin{1},'generic32')
                        this=get_generic32();
                    elseif strcmpi(varargin{1},'generic16')
                        this=get_generic16();
                    elseif strcmpi(varargin{1},'generic8')
                        this=get_generic8();
                    else
                        this=get_default();
                    end

                    this.Name=varargin{1};

                elseif isnumeric(varargin{1})

                    vararg=varargin{1};
                    props={...
                    'CharNumBits','ShortNumBits','IntNumBits','LongNumBits',...
                    'LongLongNumBits','FloatNumBits','DoubleNumBits',...
                    'LongDoubleNumBits','PointerNumBits'...
                    };

                    for ii=1:numel(vararg)
                        this.(props{ii})=vararg(ii);
                    end
                end
            end
        end

        function this=set.Name(this,aValue)
            cgfe.util.verifyStringValue('Name',aValue);
            this.Name=lower(aValue);
        end

        function this=set.Endianness(this,aValue)
            cgfe.util.verifyStringValue('Endianness',aValue);
            this.Endianness=cgfe.util.verifyEnumValue('Endianness',...
            {'little','big'},lower(aValue));
        end

        function this=set.CharNumBits(this,aValue)
            this.CharNumBits=cgfe.util.verifyInt32Value('CharNumBits',aValue);
        end

        function this=set.ShortNumBits(this,aValue)
            this.ShortNumBits=cgfe.util.verifyInt32Value('ShortNumBits',aValue);
        end

        function this=set.IntNumBits(this,aValue)
            this.IntNumBits=cgfe.util.verifyInt32Value('IntNumBits',aValue);
        end

        function this=set.LongNumBits(this,aValue)
            this.LongNumBits=cgfe.util.verifyInt32Value('LongNumBits',aValue);
        end

        function this=set.LongLongNumBits(this,aValue)
            this.LongLongNumBits=cgfe.util.verifyInt32Value('LongLongNumBits',aValue);
        end

        function this=set.FloatNumBits(this,aValue)
            this.FloatNumBits=cgfe.util.verifyInt32Value('FloatNumBits',aValue);
        end

        function this=set.DoubleNumBits(this,aValue)
            this.DoubleNumBits=cgfe.util.verifyInt32Value('DoubleNumBits',aValue);
        end

        function this=set.LongDoubleNumBits(this,aValue)
            this.LongDoubleNumBits=cgfe.util.verifyInt32Value('LongDoubleNumBits',aValue);
        end

        function this=set.PointerNumBits(this,aValue)
            this.PointerNumBits=cgfe.util.verifyInt32Value('PointerNumBits',aValue);
        end
    end
end

function hw=get_default()
    hw=cgfe.HwInfo();
end

function hw=get_x86()
    hw=get_default();
end

function hw=get_generic32()
    hw=cgfe.HwInfo();
end

function hw=get_generic16()
    hw=cgfe.HwInfo();
    hw.IntNumBits=16;
    hw.PointerNumBits=16;
end

function hw=get_generic8()
    hw=cgfe.HwInfo();
    hw.ShortNumBits=8;
    hw.IntNumBits=16;
    hw.PointerNumBits=8;
end

function hw=get_x86_64()
    hw=cgfe.HwInfo();
    hw.LongNumBits=64;
    hw.PointerNumBits=64;
    hw.LongDoubleNumBits=96;
end


