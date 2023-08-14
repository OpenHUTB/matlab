classdef Subsystem<Simulink.CMI.cpp.Subsystem
    properties
sess
    end
    methods
        function obj=Subsystem(session,varargin)
            obj=obj@Simulink.CMI.cpp.Subsystem(varargin{:});
            obj.sess=session;
        end
        function bc=getSystemNumber(obj)
            bc=getSystemNumber@Simulink.CMI.cpp.Subsystem(obj,obj.sess);
        end
        function bc=getSortedInfo(obj)
            bc=getSortedInfo@Simulink.CMI.cpp.Subsytem(obj,obj.sess);
        end
        function bc=getSortedList(obj,varargin)
            if nargin<=1
                bct=getSortedList@Simulink.CMI.cpp.Subsystem(obj,obj.sess,-1);
                bc=Simulink.CMI.CompiledBlock.empty;
                for i=1:length(bct)
                    bc=[bc,Simulink.CMI.CompiledBlock(obj.sess,bct(i).Handle)];%#ok<AGROW>
                end
            elseif nargin>1
                bct=getSortedList@Simulink.CMI.cpp.Subsystem(obj,obj.sess,varargin{:});
                bc=Simulink.CMI.CompiledBlock.empty;
                for i=1:length(bct)
                    bc=[bc,Simulink.CMI.CompiledBlock(obj.sess,bct(i).Handle)];%#ok<AGROW>
                end
            end
        end
        function bc=getCompiledBlockList(obj)
            bci=getCompiledBlockList@Simulink.CMI.cpp.Subsystem(obj,obj.sess);
            bc=Simulink.CMI.CompiledBlock.empty;
            for i=1:length(bci)
                bc=[bc,Simulink.CMI.CompiledBlock(obj.sess,bci(i).Handle)];%#ok<AGROW>
            end
        end
        function bc=getNeededDSMemBlks(obj)
            bc=getNeededDSMemBlks@Simulink.CMI.cpp.Subsystem(obj,obj.sess);
        end
        function carr=conceptualIO(obj)
            ctemp=getConceptualIO(obj,obj.sess);
            if(isempty(ctemp))
                carr=struct();
                return;
            end
            piarr=Simulink.CMI.OutPort.empty;
            ctemparr=ctemp{1};
            for i=1:length(ctemparr)
                piarr=[piarr,Simulink.CMI.OutPort(obj.sess,ctemparr(i).Handle)];%#ok<AGROW>
            end
            poarr=Simulink.CMI.OutPort.empty;
            ctemparr=ctemp{2};
            for i=1:length(ctemparr)
                poarr=[poarr,Simulink.CMI.OutPort(obj.sess,ctemparr(i).Handle)];%#ok<AGROW>
            end
            carr=struct('Inputs',piarr,'Outputs',poarr);
        end
    end
end
