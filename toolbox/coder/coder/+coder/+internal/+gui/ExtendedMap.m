classdef(Sealed)ExtendedMap<containers.Map
    properties(GetAccess=private,SetAccess=immutable)
reverseMap
hashFunction
extendedMode
actualKeyType
    end

    methods
        function this=ExtendedMap(varargin)
            parser=inputParser;
            parser.addParameter('KeyType','char');
            parser.addParameter('ValueType','any');
            parser.addParameter('HashFunction',[]);
            parser.parse(varargin{:});

            if~isempty(parser.Results.HashFunction)
                hashFunction=parser.Results.HashFunction;
                validateattributes(hashFunction,{'function_handle'},{'scalar'});
                assert(abs(nargin(hashFunction)*nargout(hashFunction))==1,...
                'The provided hash function must have one input and one output');
            else
                hashFunction=[];
            end


            if~ismember(parser.Results.KeyType,{'char','double','single','int32','uint32','int64','uint64'})
                if isempty(hashFunction)
                    error('Custom key type ''%s'' requires providing a HashFunction argument',parser.Results.KeyType);
                end
                extendedMode=true;
                keyType='char';
                actualKeyType=parser.Results.KeyType;
            else
                extendedMode=false;
                keyType=parser.Results.KeyType;
                actualKeyType=keyType;
            end

            this=this@containers.Map('KeyType',keyType,'ValueType',parser.Results.ValueType);

            this.reverseMap=containers.Map('KeyType','char','ValueType','any');
            this.hashFunction=hashFunction;
            this.extendedMode=extendedMode;
            this.actualKeyType=actualKeyType;
        end

        function contained=isKey(this,key)
            contained=isKey@containers.Map(this,this.keyify(key));
        end

        function allKeys=keys(this)
            allKeys=keys@containers.Map(this);

            if this.extendedMode

                for i=1:numel(allKeys)
                    allKeys{i}=this.reverseMap(allKeys{i});
                end
            end
        end

        function this=remove(this,keySet)
            if this.extendedMode
                if iscell(keySet)
                    for i=1:numel(keySet)
                        hashKey=this.keyify(keySet{i});
                        remove@containers.Map(this,hashKey);
                        this.reverseMap.remove(hashKey);
                    end
                else
                    hashKey=this.keyify(keySet);
                    remove@containers.Map(this,hashKey);
                    this.reverseMap.remove(hashKey);
                end
            else
                remove@containers.Map(this,keySet);
            end
        end

        function out=subsref(this,subs)
            if this.isRelevantIndexOperation(subs)
                subs(1).subs{1}=this.keyify(subs(1).subs{1});
            end
            out=subsref@containers.Map(this,subs);
        end

        function out=subsasgn(this,subs,value)
            if this.isRelevantIndexOperation(subs)
                actualKey=subs(1).subs{1};
                hashKey=this.keyify(actualKey);
                this.reverseMap(hashKey)=actualKey;
                subs(1).subs{1}=hashKey;
            end
            out=subsasgn@containers.Map(this,subs,value);
        end
    end

    methods(Access=private)
        function hashKey=keyify(this,key)
            if this.extendedMode
                assert(isa(key,this.actualKeyType),'Unexpected key type ''%s'' when expecting ''%s''.',...
                class(key),this.KeyType);

                hashKey=this.hashFunction(key);

                assert(isa(hashKey,this.KeyType),...
                'The hash function generated a ''%s'' while this map is expecting a ''%s''.',...
                class(hashKey),this.KeyType);
            else
                hashKey=key;
            end
        end

        function relevant=isRelevantIndexOperation(this,subs)
            relevant=this.extendedMode&&~isempty(subs)&&strcmp(subs(1).type,'()')&&numel(subs(1).subs)==1;
        end
    end
end