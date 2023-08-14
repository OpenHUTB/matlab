classdef Map<handle






    properties(Access=private)
map
keyList
valueList
capacity
numItem
currIdx
hasher
    end

    methods(Access=public)








        function self=Map(varargin)
            argParser=inputParser();
            argParser.addParameter('InitCapacity',10,@(x)(isnumeric(x)&&isscalar(x)));
            argParser.addParameter('KeyType','char',@(x)ischar(x)||isStringScalar(x));
            argParser.addParameter('HashFcn',@(x)x,@(x)isa(x,'function_handle'));
            argParser.parse(varargin{:})

            self.map=containers.Map(...
            'KeyType',argParser.Results.KeyType,...
            'ValueType','uint64');
            self.capacity=argParser.Results.InitCapacity;
            self.keyList=cell(1,self.capacity);
            self.valueList=cell(1,self.capacity);
            self.numItem=0;
            self.currIdx=0;
            self.hasher=argParser.Results.HashFcn;
        end



        function self=set(self,key,value)
            fake_key=self.hasher(key);
            if~self.map.isKey(fake_key)
                self.ensureCapacity();
                self.numItem=self.numItem+1;
                self.currIdx=self.currIdx+1;
                self.keyList{self.currIdx}=key;
                self.valueList{self.currIdx}=value;
                self.map(fake_key)=self.currIdx;
            else
                self.valueList{self.map(fake_key)}=value;
            end
        end




        function self=subsasgn(self,S,B)
            if numel(S)==1&&strcmp(S(1).type,'()')&&numel(S(1).subs)==1
                self.set(S(1).subs{1},B);
            else
                assert(false,'unexpected assignment expression for autosar.mm.util.Map');
            end
        end



        function ret=get(self,key)
            fake_key=self.hasher(key);
            ret=[];
            if self.map.isKey(fake_key)
                ret=self.valueList{self.map(fake_key)};
            end
        end




        function ret=subsref(self,S)
            ret=[];

            switch S(1).type
            case '()'
                if numel(S(1).subs)==1
                    ret=self.get(S(1).subs{1});
                end
            case '.'
                if numel(S)>1
                    ret=self.(S(1).subs)(S(2).subs{:});
                else
                    ret=self.(S.subs);
                end
            otherwise

                assert(false,'unexpected subscript reference expression for autosar.mm.util.Map');
            end
        end





        function ret=remove(self,key)
            fake_key=self.hasher(key);
            ret=[];
            if self.map.isKey(fake_key)
                idx=self.map(fake_key);
                self.map.remove(fake_key);
                self.keyList{idx(1)}={};
                ret=self.valueList{idx(1)};
                self.valueList{idx(1)}={};
                self.numItem=self.numItem-1;
            end
        end




        function ret=isKey(self,key)
            ret=self.map.isKey(self.hasher(key));
        end




        function ret=isempty(self)
            ret=self.numItem<1;
        end




        function ret=getLength(self)
            ret=self.numItem;
        end




        function ret=getKeys(self)
            ret=self.keyList;
            ret(cellfun(@isempty,ret))=[];
        end




        function ret=getValues(self)
            ret=self.valueList(~cellfun(@isempty,self.keyList));
        end




        function rehash(self)
            self.ensureCapacity();
        end
    end

    methods(Access=private)


        function ensureCapacity(self)
            if self.currIdx==self.capacity
                self.keyList=[self.keyList,cell(1,self.capacity)];
                self.valueList=[self.valueList,cell(1,self.capacity)];
                self.capacity=self.capacity*2;
            end
        end
    end

end


