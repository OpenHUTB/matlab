classdef BiMap<handle






    properties(Access=private)
leftMap
rightMap
    end

    methods(Access=public)










        function self=BiMap(varargin)
            argParser=inputParser();
            argParser.addParameter('InitCapacity',10,@(x)(isnumeric(x)&&isscalar(x)));
            argParser.addParameter('KeyType1','char',@(x)ischar(x)||isStringScalar(x));
            argParser.addParameter('HashFcn1',@(x)x,@(x)isa(x,'function_handle'));
            argParser.addParameter('KeyType2','char',@(x)ischar(x)||isStringScalar(x));
            argParser.addParameter('HashFcn2',@(x)x,@(x)isa(x,'function_handle'));
            argParser.parse(varargin{:});

            self.leftMap=autosar.mm.util.Map(...
            'InitCapacity',argParser.Results.InitCapacity,...
            'KeyType',argParser.Results.KeyType1,...
            'HashFcn',argParser.Results.HashFcn1);
            self.rightMap=autosar.mm.util.Map(...
            'InitCapacity',argParser.Results.InitCapacity,...
            'KeyType',argParser.Results.KeyType2,...
            'HashFcn',argParser.Results.HashFcn2);
        end




        function ret=isempty(self)
            ret=self.leftMap.isempty();
            assert(ret==self.rightMap.isempty(),...
            'Unexpected inconsistency between the left and right maps.')
        end




        function ret=getLength(self)
            ret=self.leftMap.getLength();
            assert(ret==self.rightMap.getLength(),...
            'Unexpected inconsistency between the left and right maps.')
        end




        function ret=getLeftKeys(self)
            ret=self.leftMap.getKeys();
        end




        function ret=getRightKeys(self)
            ret=self.rightMap.getKeys();
        end




        function ret=getLeftValues(self)
            ret=self.leftMap.getValues();
        end




        function ret=getRightValues(self)
            ret=self.rightMap.getValues();
        end



        function setLeft(self,key,value)
            if isempty(value)
                assert(false,'The second key cannot be empty for an autosar.mm.util.BiMap');
                return
            end
            self.leftMap.set(key,value);
            self.rightMap.set(value,key);
        end



        function setRight(self,key,value)
            if isempty(value)
                assert(false,'The second key cannot be empty for an autosar.mm.util.BiMap');
                return
            end
            self.setLeft(value,key);
        end



        function ret=getLeft(self,key)
            ret=self.leftMap.get(key);
        end



        function ret=getRight(self,key)
            ret=self.rightMap.get(key);
        end



        function removeLeft(self,key)
            value=self.leftMap.remove(key);
            if~isempty(value)
                self.rightMap.remove(value);
            else
                assert(false,'The second key cannot be empty for an autosar.mm.util.BiMap');
            end
        end



        function removeRight(self,key)
            value=self.rightMap.remove(key);
            if~isempty(value)
                self.leftMap.remove(value);
            else
                assert(false,'The first key cannot be empty for an autosar.mm.util.BiMap');
            end
        end

    end

end


