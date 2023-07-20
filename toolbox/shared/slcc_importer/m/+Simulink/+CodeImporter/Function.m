



























classdef Function<handle

    properties(Hidden,SetAccess=protected)
        DeclarationLocation=[];
        DefinitionLocation=[];
        Types(1,:)string
        PortHeuristics(1,:)
        defaultPortSpecChecksum(1,1)string
    end

    properties(SetAccess=protected)


        Name(1,1)string



        CPrototype(1,1)string








        PortSpecification(1,1)Simulink.CodeImporter.SimulinkPortSpecification





        IsEntry(1,1)logical=false;





        IsDefined(1,1)logical=false;





        IsStub(1,1)logical=false;
    end

    properties



        ArrayLayout(1,1)internal.CodeImporter.FunctionArrayLayout=internal.CodeImporter.FunctionArrayLayout.NotSpecified;








        IsDeterministic(1,1)logical=false;
    end


    methods
        function obj=Function(modelHandle,functionName,passByPointerDefaultSize)
            if nargin<3
                return;
            end

            obj.Name=functionName;
            functionPortSpecification=slcc('getFunctionPortSpec',modelHandle,functionName);
            assert(~isempty(functionPortSpecification));
            assert(isa(functionPortSpecification,'Simulink.CustomCode.FunctionPortSpecification'));
            obj.CPrototype=functionPortSpecification.CPrototype;
            obj.PortSpecification=Simulink.CodeImporter.SimulinkPortSpecification(functionPortSpecification);
            if~strcmpi(passByPointerDefaultSize,"-1")
                obj.setPassByPointerDefaultSize(passByPointerDefaultSize);
            end
            obj.PortHeuristics=slcc('getFunctionPortHeuristics',modelHandle,functionName);
            obj.Types=slcc('getNonPrimitiveTypesUsedByFunction',modelHandle,functionName);
            obj.defaultPortSpecChecksum=cgxe('MD5AsString',obj.getPortSpecDataStruct());

            isDef=false;
            [location,status]=slcc('getCustomCodeFunctionLocation',modelHandle,functionName,isDef);
            assert(status>0&&~isempty(location))
            obj.DeclarationLocation=location;

            isDef=true;
            [location,status]=slcc('getCustomCodeFunctionLocation',modelHandle,functionName,isDef);
            if(status>0&&~isempty(location))
                obj.DefinitionLocation=location;
            end
        end

        function gotoDeclaration(obj)







            location=obj.DeclarationLocation;
            if~isempty(location)
                SLCC.Utils.OpenFileAndHighlight(location.path,...
                location.line,location.column,location.length);
            end
        end

        function gotoDefinition(obj)








            location=obj.DefinitionLocation;
            if~isempty(location)
                SLCC.Utils.OpenFileAndHighlight(location.path,...
                location.line,location.column,location.length);
            end
        end
    end

    methods(Hidden)
        function setIsEntry(obj,val)
            obj.IsEntry=val;
        end

        function setIsDefined(obj,val)
            obj.IsDefined=val;
        end

        function setIsStub(obj,val)
            obj.IsStub=val;
        end

        function ret=getPortSpecDataStruct(obj)
            ret=struct('ArgName',{},'PortName',{},'Scope',{},...
            'Index',{},'Type',{},'Size',{},...
            'IsGlobal',{});
            InAndOutArgs=[obj.PortSpecification.ReturnArgument...
            ,obj.PortSpecification.InputArguments];
            for arg=InAndOutArgs
                ret(end+1)=obj.getArgDataStruct(arg,false);
            end
            for globalArg=obj.PortSpecification.GlobalArguments
                ret(end+1)=obj.getArgDataStruct(globalArg,true);
            end
        end

        function setPassByPointerDefaultSize(obj,passByPointerDefaultSize)
            allArguments=[obj.PortSpecification.ReturnArgument...
            ,obj.PortSpecification.InputArguments...
            ,obj.PortSpecification.GlobalArguments];
            for arg=allArguments
                if strcmpi(arg.Size,"-1")
                    arg.Size=passByPointerDefaultSize;
                end
            end
        end

    end

    methods(Static,Hidden)
        function ret=getArgDataStruct(arg,isGlobal)
            ret=struct('ArgName',arg.Name,'PortName',arg.Label,...
            'Scope',arg.Scope,'Index',num2str(arg.PortNumber),...
            'Type',arg.Type,'Size',arg.Size,...
            'IsGlobal',isGlobal);
        end
    end

end
