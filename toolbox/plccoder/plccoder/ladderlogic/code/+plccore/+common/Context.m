classdef Context<plccore.common.Object




    properties(Access=protected)
BuiltinScope
Configuration
PLCConfigInfo
TargetIDE
    end

    methods
        function obj=Context(target_ide)
            obj.Kind='Context';
            obj.BuiltinScope=plccore.common.BuiltinScope;
            if(nargin>0)
                obj.TargetIDE=target_ide;
            else
                obj.TargetIDE='studio5000';
            end
            obj.BuiltinScope.processTarget(obj.TargetIDE);
        end

        function ret=toString(obj)
            txt=sprintf('%s\n',obj.kind);
            txt=sprintf('%s%s',txt,obj.BuiltinScope.toString);
            if~isempty(obj.Configuration)
                txt=sprintf('%s%s',txt,obj.Configuration.toString);
            end
            ret=txt;
        end

        function ret=builtinScope(obj)
            ret=obj.BuiltinScope;
        end

        function ret=NOC(obj)
            ret=obj.builtinScope.getSymbol('NOC');
        end

        function ret=NCC(obj)
            ret=obj.builtinScope.getSymbol('NCC');
        end

        function ret=Coil(obj)
            ret=obj.builtinScope.getSymbol('Coil');
        end

        function ret=LEQ(obj)
            ret=obj.builtinScope.getSymbol('LEQ');
        end

        function ret=GEQ(obj)
            ret=obj.builtinScope.getSymbol('GEQ');
        end

        function ret=SetCoil(obj)
            ret=obj.builtinScope.getSymbol('SetCoil');
        end

        function ret=ResetCoil(obj)
            ret=obj.builtinScope.getSymbol('ResetCoil');
        end

        function ret=TON(obj)
            ret=obj.builtinScope.getSymbol('TON');
        end

        function ret=TOF(obj)
            ret=obj.builtinScope.getSymbol('TOF');
        end

        function ret=CTU(obj)
            ret=obj.builtinScope.getSymbol('CTU');
        end

        function ret=CTD(obj)
            ret=obj.builtinScope.getSymbol('CTD');
        end

        function ret=CTUD(obj)
            ret=obj.builtinScope.getSymbol('CTUD');
        end

        function ret=JMP(obj)
            ret=obj.builtinScope.getSymbol('JMP');
        end

        function ret=LBL(obj)
            ret=obj.builtinScope.getSymbol('LBL');
        end

        function ret=JSR(obj)
            ret=obj.builtinScope.getSymbol('JSR');
        end

        function ret=getPLCConfigInfo(obj)
            assert(~isempty(obj.PLCConfigInfo));
            ret=obj.PLCConfigInfo;
        end

        function setPLCConfigInfo(obj,config_info)
            obj.PLCConfigInfo=config_info;
        end

        function ret=configuration(obj)
            ret=obj.Configuration;
        end

        function ret=createConfiguration(obj,name)
            ret=plccore.common.Configuration(name);
            obj.Configuration=ret;
        end

        function ret=targetIDE(obj)
            ret=obj.TargetIDE;
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitContext(obj,input);
        end
    end
end


