classdef(Abstract)AbstractConstraint<handle






    properties(SetAccess=protected,GetAccess=public)
path
portIndex
value
id
    end

    properties(Constant,Hidden)
        pathDivider=':';
    end

    methods
        function this=AbstractConstraint(path,portIndex,value)
            this.initializeConstraint(path,portIndex,value);
        end

        function cid=get.id(this)
            cid=[this.getMode(),this.pathDivider,this.tostring()];
        end

        function p=get.path(this)
            p=this.getPath();
        end

        function p=get.portIndex(this)
            p=this.getPortIndex();
        end

        function pathStr=tostring(this)





            pathStr=[this.path,sprintf('%s%i',this.pathDivider,this.portIndex)];
        end

    end

    methods(Abstract)

        modeStr=getMode(this)

        initializeConstraint(this)

        p=getPath(this)

        p=getPortIndex(this)
    end

end