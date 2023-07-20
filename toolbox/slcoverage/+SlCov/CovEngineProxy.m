



classdef CovEngineProxy<handle

    properties(GetAccess=public,SetAccess=protected,Hidden)
        id(1,1){mustBeNumeric}=0
    end
    properties(GetAccess=public,SetAccess=private,Hidden)
        isInvalidated(1,1){mustBeNumericOrLogical}=false;
    end
    properties(GetAccess=public,SetAccess=private,Hidden)
        testdataCleanupListener=[]
    end


    methods



        function this=CovEngineProxy(id)

            if nargin<1
                id=0;
            end

            validateattributes(id,{'numeric'},{'scalar'});

            if id~=0&&~cv('ishandle',id)
                throwAsCaller(MException(message('Slvnv:simcoverage:cvtest:NotTestdataObject',id)));
            end

            this.id=id;
        end




        function delete(this)
            if this.hasValidTestdataId()
                cv('DecrementRefCount',this.id);
            end
        end




        function set.id(this,val)

            if val~=0
                if~cv('ishandle',val)
                    throwAsCaller(MException(message('Slvnv:simcoverage:cvdata:CvObjNotExists',val)));
                end
                if cv('get',val,'.isa')~=cv('get','default','testdata.isa')
                    throwAsCaller(MException(message('Slvnv:simcoverage:cvdata:CvObjNotTestdata',val)));
                end

                cv('IncrementRefCount',val);
                this.registerTestdataCleanupCallback(val);
            end

            this.id=val;
        end




        function val=double(this)
            val=double(this.id);
        end




        function ret=isequal(this,other)
            ret=false;
            mc=metaclass(this);
            if(~isa(other,mc.Name))
                return;
            end
            if(this.id~=other.id)
                return;
            end




            propsToCompare=mc.PropertyList(~[mc.PropertyList.Dependent])';
            propsToCompare(strcmp({propsToCompare.Name},'testdataCleanupListener'))=[];
            for p=propsToCompare
                if~isequal(this.(p.Name),other.(p.Name))
                    return;
                end
            end

            ret=true;
        end
    end

    methods(Hidden,Access=public)
        function isvalid=hasValidTestdataId(this)
            isvalid=~this.isInvalidated&&(this.id>0)...
            &&cv('ishandle',this.id)...
            &&(cv('get',this.id,'.isa')==cv('get','default','testdata.isa'));
        end
    end

    methods(Hidden,Access=private)
        function testdataCleanupCallback(this,~,~)
            this.isInvalidated=true;
        end

        function registerTestdataCleanupCallback(this,id)
            cleanupToken=SlCov.CovEngineProxyCleanupToken.getToken(id);
            this.testdataCleanupListener=listener(cleanupToken,...
            'ObjectBeingDestroyed',@this.testdataCleanupCallback);
        end
    end
end


