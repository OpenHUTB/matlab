

classdef CriticalComponent
    properties(GetAccess=private,SetAccess=private)
reportFileName
delay
slComponent
gmHandle

lineHandle
fullPath
    end

    methods








        function this=CriticalComponent(gmPrefixOpt,reportFileName,delay,slComponent,gmHandle,lineHandle)
            import BA.New.Util;
            this.reportFileName=reportFileName;
            this.delay=delay;
            this.slComponent=slComponent;
            this.gmHandle=gmHandle;
            this.lineHandle=lineHandle;
            this.fullPath=[gmPrefixOpt.unwrapOr(''),Util.componentPath(slComponent)];
            this.checkRep();
        end


        function prettyPrint(this,indentWidth,indentLevel);











        end

        function reportFileName=getTVRName(this)
            reportFileName=this.reportFileName;
        end

        function delay=getDelay(this)
            delay=this.delay;
        end

        function comp=getSLComponent(this)
            comp=this.slComponent;
        end

        function gmHandle=getGMHandle(this)
            gmHandle=this.gmHandle;
        end

        function lineHandle=getLineHandle(this)
            lineHandle=this.lineHandle;
        end

        function fullPath=getFullPath(this)
            fullPath=this.fullPath;
        end
    end

    methods(Access=private)
        function checkRep(this)
            assert(~isempty(this.getTVRName()));
            assert(0<=this.getDelay());
        end
    end
end
