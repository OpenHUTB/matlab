classdef(Hidden=true)HandleVariableMgr<handle










    properties(Access=private)

handlesMap

    end

    methods




        function this=HandleVariableMgr()
            this.handlesMap=containers.Map('KeyType','char','ValueType','any');
        end




        function[valueRef,numInstances]=addValueRef(this,key,valueRef)
            validateattributes(key,{'char'},{'row'},'polyspace.internal.HandleVariableMgr');
            if nargin>=3
                validateattributes(valueRef,{'polyspace.internal.HandleVariable'},{'scalar'},'polyspace.internal.HandleVariableMgr');
            end


            if this.handlesMap.isKey(key)
                s=this.handlesMap(key);




            else

                if nargin<3

                    valueRef=polyspace.internal.HandleVariable();
                end
                s=struct('numInstances',0,'valueRef',valueRef);
            end

            s.numInstances=s.numInstances+1;
            this.handlesMap(key)=s;
            valueRef=s.valueRef;
            numInstances=s.numInstances;
        end




        function numInstances=removeValueRef(this,key)
            validateattributes(key,{'char'},{'row'},'polyspace.internal.HandleVariableMgr');


            try
                s=this.handlesMap(key);

                s.numInstances=s.numInstances-1;
                if s.numInstances>0
                    this.handlesMap(key)=s;
                else
                    this.handlesMap.remove(key);
                end
                numInstances=s.numInstances;
            catch
                numInstances=0;
            end
        end




        function clear(this)
            this.handlesMap=containers.Map('KeyType','char','ValueType','any');
        end
    end

end
