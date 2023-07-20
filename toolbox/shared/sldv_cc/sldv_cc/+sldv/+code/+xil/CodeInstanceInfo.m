



classdef CodeInstanceInfo<sldv.code.CodeInstanceInfo

    methods(Access=public)



        function this=CodeInstanceInfo(varargin)
            this@sldv.code.CodeInstanceInfo(varargin{:});
        end

    end

    methods(Access=public,Hidden=true)



        function setFromCodeDescriptor(this,codeDesc)

            this.StaticChecksum=codeDesc.checksum;

            this.InputPortInfo=struct([]);
            this.OutputPortInfo=struct([]);
            this.ParameterPortInfo=struct([]);
            this.DialogParameterInfo=struct([]);
            this.DWorkInfo=struct([]);
            this.DiscStateInfo=struct([]);
            this.DataStoreInfo=struct([]);

            propNames={...
            'Inports','InputPortInfo';...
            'Outports','OutputPortInfo';...
            'Parameters','ParameterPortInfo';...
            'DataStores','DataStoreInfo'...
            };
            for ii=1:size(propNames,1)
                srcProp=propNames{ii,1};
                dstProp=propNames{ii,2};
                numData=numel(codeDesc.codeInfo.(srcProp));
                if numData>0
                    if ii==3
                        defaultValue=sldv.code.CodeInstanceInfo.parameterInfo(' ',1);
                    else
                        defaultValue=sldv.code.CodeInstanceInfo.portInfo(' ',1);
                    end
                    this.(dstProp)=repmat(defaultValue,numData,1);
                    for jj=1:numData
                        this.(dstProp)(jj).Type=getTypeName(codeDesc.codeInfo.(srcProp)(jj).Type);
                        this.(dstProp)(jj).Dim=getTypeDimensions(codeDesc.codeInfo.(srcProp)(jj).Type);
                    end
                end
            end
        end
    end
end


function name=getTypeName(coderType)

    name=coderType.Name;
    if coderType.isMatrix()||coderType.isPointer()
        name=getTypeName(coderType.BaseType);
    end

end


function dims=getTypeDimensions(coderType)

    dims=1;
    if coderType.isMatrix()
        dims=coderType.Dimensions;
    end

end
