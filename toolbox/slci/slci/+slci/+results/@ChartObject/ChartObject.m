



classdef ChartObject<slci.results.StateflowObject

    properties(SetAccess=protected,GetAccess=protected)




        fIsRootChart=false;
        fIsEmpty=false;
    end

    methods(Access=public,Hidden=true)


        function obj=ChartObject(aSID,aName)
            if nargin==0
                DAStudio.error('Slci:results:DefaultConstructorError',...
                'CHARTOBJECT');
            end
            aKey=slci.results.ChartObject.constructKey(aSID);
            obj@slci.results.StateflowObject(aKey,aSID,aName);
        end

        function setParent(obj,aParent)
            if isa(aParent,'slci.results.ChartObject')||...
                isa(aParent,'slci.results.StateObject')||...
                isa(aParent,'slci.results.BlockObject')||...
                isa(aParent,'slci.results.HiddenBlockObject')
                obj.fParent=aParent.getKey();
            else
                DAStudio.error('Slci:results:InvalidInputArg');
            end
        end

        function isRootChart=getIsRootChart(obj)
            isRootChart=obj.fIsRootChart;
        end

        function setIsRootChart(obj,isRootChart)
            if islogical(isRootChart)
                obj.fIsRootChart=isRootChart;
            else
                DAStudio.error('Slci:results:InvalidInputArg');
            end
        end

        function setIsInline(obj,isInline)
            if islogical(isInline)
                if isInline
                    obj.addPrimVerSubstatus('INLINED');
                    obj.addPrimTraceSubstatus('INLINED');
                end
            else
                DAStudio.error('Slci:results:InvalidInputArg');
            end
        end

        function isInline=getIsInline(obj)
            primSubstatus=obj.getPrimVerSubstatus();
            if any(strcmpi(primSubstatus,'INLINED'))
                isInline=true;
            else
                isInline=false;
            end
        end

        function setIsEmpty(obj,isEmpty)
            if islogical(isEmpty)
                obj.fIsEmpty=isEmpty;
                if isEmpty
                    obj.setIsVirtual();
                end
            else
                DAStudio.error('Slci:results:InvalidInputArg');
            end
        end

        function isEmpty=getIsEmpty(obj)
            isEmpty=obj.fIsEmpty;
        end


        function computeStatus(obj,varargin)

            verInfo=obj.getVerificationInfo();
            if~verInfo.IsEmpty()
                engineStatus=verInfo.getComputedEngineStatus();




                if strcmpi(engineStatus,'VERIFIED')&&...
                    isempty(obj.getTraceArray())&&...
                    any(strcmp('OPTIMIZED',obj.getPrimTraceSubstatus))&&...
                    obj.getIsInline()
                    obj.setSubstatus('INLINED');
                    obj.setStatus(obj.fReportConfig.getStatus('INLINED'));
                else
                    obj.setSubstatus(verInfo.getComputedEngineSubstatus());
                    obj.setStatus(engineStatus);
                end
            else
                aggSubstatus=obj.aggVerSubstatus();
                obj.setSubstatus(aggSubstatus);
                obj.setStatus(obj.fReportConfig.getStatus(obj.getSubstatus));
            end


            if slcifeature('SLCIJustification')==1
                assert(nargin==2,'SLCI Configuration is not passed.');
                obj.justifyBlock(varargin{1});
            end
        end

        function aDispName=getDispName(obj,datamgr)
            reader=datamgr.getReader('BLOCK');
            if~isempty(obj.getParent())
                parentObj=reader.getObject(obj.getParent());
                parentName=parentObj.getDispName(datamgr);
            else

                parentName=obj.fReportConfig.getRepModelName();
            end
            fullName=[parentName,'/',obj.getName()];
            aDispName=slci.internal.encodeString(fullName,'all','encode');
        end
    end

    methods(Access=private)
        function setIsVirtual(obj)
            obj.addPrimVerSubstatus('VIRTUAL');
            obj.addPrimTraceSubstatus('VIRTUAL');
        end
    end

    methods(Access=protected)

        function deriveTraceSubstatus(obj)

            deriveTraceSubstatus@slci.results.StateflowObject(obj);



            if isempty(obj.getTraceArray())&&...
                strcmp(obj.getTraceSubstatus(),'OPTIMIZED')&&...
                obj.getIsInline()
                obj.setTraceSubstatus('INLINED');
            end
        end

    end

    methods(Access=public,Static=true,Hidden=true)

        function key=constructKey(aSID)

            key=slci.results.BlockObject.constructKey(get_param(aSID,'handle'));
        end

    end


end
