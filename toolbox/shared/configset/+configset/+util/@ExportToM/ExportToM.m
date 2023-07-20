classdef ExportToM<handle


    properties(Hidden)
adp
buffer
config
cs
name
result
containCustomCC
    end

    methods
        function obj=ExportToM(cs,name,varargin)

            obj.cs=cs;
            obj.name=name;
            if~configset.internal.util.hasConfigSetAdapter(cs)
                cleanup=onCleanup(@()configset.internal.util.clearConfigSetAdapter(cs));
            end





            obj.adp=configset.internal.getConfigSetAdapter(cs,true);
            if nargin==3
                obj.setupConfig(varargin{1});
            else
                obj.setupConfig([]);
            end




            wState=[warning;warning('query','RTW:configSet:migratedToCoderDictionary')];
            warning('off','RTW:configSet:migratedToCoderDictionary');
            wCleanup=onCleanup(@()warning(wState));

            obj.init();
        end

        saveToFile(obj)
        str=getString(obj)
    end

    methods(Access=private)
        init(obj)
        setupConfig(obj,configArray)
        generateHeader(obj)
        generateVersion(obj)
        generateEncoding(obj)
        generateSwitchTarget(obj)
        generateHardwareBoard(obj)
        generateCodeInterfacePackaging(obj)
        generateSolver(obj)
        generateOrder(obj)
        generateComponent(obj,cc)
        generateCustomComponent(obj,cc)
        generateHDLComponent(obj,cc)
        str=generateParameters(obj,cc,indent,saveToBridge);


        out=isParamSaved(~,cs,pdata)
    end
end

