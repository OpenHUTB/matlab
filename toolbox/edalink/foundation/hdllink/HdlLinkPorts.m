classdef(Sealed,Hidden)HdlLinkPorts<hgsetget
    properties(GetAccess='private',Hidden)
        linkmode;
    end
    methods(Hidden)
        function disp(obj)

            fields=obj.fields;
            numFields=length(fields);
            for currFieldNum=1:numFields
                currField=fields{currFieldNum};
                currProp=obj.findprop(currField);
                description=currProp.Description;



                switch description
                case 'input'
                    inputStruct.(currField)=obj.(currField);
                case 'output'
                    outputStruct.(currField)=obj.(currField);
                case 'inout'
                    inoutStruct.(currField)=obj.(currField);
                otherwise
                    disp('Unknown access')
                end

            end
            if strcmp(obj.linkmode,'testbench')
                inputPortsLabel='   Read/Write';
                outputPortsLabel='   Read Only';
            else
                inputPortsLabel='   Read Only';
                outputPortsLabel='   Read/Write';
            end
            if exist('inputStruct','var')
                disp([inputPortsLabel,' Input Ports:']);
                disp(inputStruct);
            end
            if exist('outputStruct','var')
                disp([outputPortsLabel,' Output Ports:']);
                disp(outputStruct);
            end
            if exist('inoutStruct','var')
                disp('   Read/Write InOut Ports:');
                disp(inoutStruct);
            end

        end
        function delete(obj)

        end
    end

end
