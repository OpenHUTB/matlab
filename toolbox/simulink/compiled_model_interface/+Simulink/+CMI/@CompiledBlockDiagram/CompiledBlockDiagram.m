classdef CompiledBlockDiagram<Simulink.CMI.cpp.CompiledBlockDiagram
    properties
sess
    end
    methods
        function obj=CompiledBlockDiagram(session,bd)


            if~isa(session,'Simulink.CMI.cpp.CompiledSession')
                throw(MException('MATLAB:class:InvalidSuperclass',...
                '''%s'' is not a subclass of Simulink.CMI.cpp.CompiledSession',...
                class(session)));
            end
            obj=obj@Simulink.CMI.cpp.CompiledBlockDiagram(bd);
            obj.sess=session;
        end
        function bc=isSingleRate(obj)
            bc=isSingleRate@Simulink.CMI.cpp.CompiledBlockDiagram(obj,obj.sess);
        end
        function bc=getCompiledBlockList(obj)
            bct=getCompiledBlockList@Simulink.CMI.cpp.CompiledBlockDiagram(obj,obj.sess);
            bc=Simulink.CMI.CompiledBlock.empty;
            for i=1:length(bct)
                bc=[bc,Simulink.CMI.CompiledBlock(obj.sess,bct(i).Handle)];%#ok<AGROW>
            end
        end
        function bc=getHiddenRootCondExecSystem(obj)
            bc=getHiddenRootCondExecSystem@Simulink.CMI.cpp.CompiledBlockDiagram(obj,obj.sess);
        end
        function bc=getSampleTimeValues(obj)
            bc=getSampleTimeValues@Simulink.CMI.cpp.CompiledBlockDiagram(obj,obj.sess);
        end
        function bc=getSortedInfo(obj)
            bc=getSortedInfo@Simulink.CMI.cpp.CompiledBlockDiagram(obj,obj.sess);
        end
        function bc=getSortedList(obj,varargin)
            if nargin<=1
                bct=getSortedList@Simulink.CMI.cpp.CompiledBlockDiagram(obj,obj.sess,-1);
                bc=Simulink.CMI.CompiledBlock.empty;
                for i=1:length(bct)
                    bc=[bc,Simulink.CMI.CompiledBlock(obj.sess,bct(i).Handle)];%#ok<AGROW>
                end
            elseif nargin>1
                bct=getSortedList@Simulink.CMI.cpp.CompiledBlockDiagram(obj,obj.sess,varargin{:});
                bc=Simulink.CMI.CompiledBlock.empty;
                for i=1:length(bct)
                    bc=[bc,Simulink.CMI.CompiledBlock(obj.sess,bct(i).Handle)];%#ok<AGROW>
                end
            end
        end
        function bc=isSampleTimeInherited(obj)
            bc=isSampleTimeInherited@Simulink.CMI.cpp.CompiledBlockDiagram(obj,obj.sess);
        end
        function bc=outputFcnHasAsyncRates(obj)
            bc=outputFcnHasAsyncRates@Simulink.CMI.cpp.CompiledBlockDiagram(obj,obj.sess);
        end
        function bc=outputFcnHasSinglePeriodicRate(obj)
            bc=outputFcnHasSinglePeriodicRate@Simulink.CMI.cpp.CompiledBlockDiagram(obj,obj.sess);
        end
        function bc=getGraph(obj,varargin)
            bc=getGraph@Simulink.CMI.cpp.CompiledBlockDiagram(obj,obj.sess,varargin{:});
        end
        function bc=getCondInputTree(obj)
            bc=getCondInputTree@Simulink.CMI.cpp.CompiledBlockDiagram(obj,obj.sess);
        end
        function bc=getCondExecTree(obj)
            bc=getCondExecTree@Simulink.CMI.cpp.CompiledBlockDiagram(obj,obj.sess);
        end
        function bc=getInjectionDataForSignalBasedLinearization(obj)
            bc=getInjectionDataForSignalBasedLinearization@Simulink.CMI.cpp.CompiledBlockDiagram(obj,obj.sess);
        end
        function bc=getTimeVaryingSourceBlocks(obj,s)
            bc=getTimeVaryingSourceBlocks@Simulink.CMI.cpp.CompiledBlockDiagram(obj,obj.sess,s);
        end
        function init(varargin)
            obj=varargin{1};
            init(obj.sess,varargin{:});
        end
        function term(obj)
            term(obj.sess,obj);
        end
    end
    methods(Hidden=true)
        function bc=analyzeDeps(obj)
            bc=analyzeDeps@Simulink.CMI.cpp.CompiledBlockDiagram(obj,obj.sess);
        end
    end

end
