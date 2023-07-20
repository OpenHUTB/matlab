%#codegen
classdef(Abstract)Layer





    properties

        Name='';
    end

    properties(SetAccess=protected)


        Description=''


        Type=''
    end

    properties(Dependent,SetAccess=protected)

NumInputs


InputNames


NumOutputs


OutputNames
    end

    properties(Access=private)

        PrivateInputs={iDefaultInput()}


        PrivateOutputs={iDefaultOutput()}
    end

    methods(Hidden=true)
        function obj=Layer()
            coder.allowpcode('plain');


        end
    end

    methods(Abstract)
















        varargout=predict(aLayer,varargin);

    end

    methods
        function layer=set.Name(layer,val)
            layer.Name=convertStringsToChars(val);
        end

        function layer=set.Description(layer,val)
            layer.Description=val;
        end

        function layer=set.Type(layer,val)
            layer.Type=val;
        end

        function val=get.NumInputs(layer)
            val=numel(layer.PrivateInputs);
        end

        function val=get.NumOutputs(layer)
            val=numel(layer.PrivateOutputs);
        end

        function val=get.InputNames(layer)
            val=layer.PrivateInputs;
        end

        function val=get.OutputNames(layer)
            val=layer.PrivateOutputs;
        end

        function layer=set.NumInputs(layer,val)
            prefix=iDefaultInput();
            layer.PrivateInputs=iGenerateNames(prefix,val);
        end

        function layer=set.NumOutputs(layer,val)
            prefix=iDefaultOutput();
            layer.PrivateOutputs=iGenerateNames(prefix,val);
        end

        function layer=set.InputNames(layer,names)
            layer.PrivateInputs=names;
        end

        function layer=set.OutputNames(layer,names)
            layer.PrivateOutputs=names;
        end
    end

    methods(Hidden)
        function isRowMajor=isRowMajor(~)
            isRowMajor=coder.isRowMajor();
        end
    end

    methods(Static,Hidden)


        function optOut=matlabCodegenLowerToStruct(~)
            optOut=true;
        end

        function n=matlabCodegenNontunableProperties(~)
            n={'Name','Description','Type','NumInputs','NumOutputs',...
            'InputNames','OutputNames'};
        end
    end
end

function val=iDefaultInput()
    val='in';
end

function val=iDefaultOutput()
    val='out';
end

function names=iGenerateNames(prefix,numPorts)
    if numPorts==1
        names={prefix};
    else
        strNames=string(prefix)+(1:numPorts);
        names=cellstr(strNames);
    end
end
