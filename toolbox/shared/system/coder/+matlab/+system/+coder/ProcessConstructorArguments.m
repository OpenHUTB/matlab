classdef ProcessConstructorArguments






%#codegen

    methods(Static)
        function do(obj,narg,varargin)
            coder.allowpcode('plain');
            coder.internal.allowHalfInputs;
            eml_prefer_const(narg);
            eml_prefer_const(varargin);

            if isempty(varargin)
                return;
            end


            numValueOnlyNames=coder.internal.const(length(varargin)-narg);

            if numValueOnlyNames~=0

                lastValueOnlyArgIndex=matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:});

                if lastValueOnlyArgIndex>numValueOnlyNames
                    matlab.system.internal.error('MATLAB:system:invalidValueOnlyProps',...
                    class(obj),numValueOnlyNames,lastValueOnlyArgIndex);
                end

                numNameValuePairs=length(varargin)-lastValueOnlyArgIndex-numValueOnlyNames;
                if(numNameValuePairs>0)&&rem(numNameValuePairs,2)
                    matlab.system.internal.error('MATLAB:system:invalidPVPairs');
                end


                valueOnlyNames=matlab.system.coder.ProcessConstructorArguments.getValueOnlyNames(numValueOnlyNames,lastValueOnlyArgIndex,varargin{:});

                names=matlab.system.coder.ProcessConstructorArguments.combineNames(valueOnlyNames,narg,varargin{:});
            else
                if rem(length(varargin),2)
                    matlab.system.internal.error('MATLAB:system:invalidPVPairs');
                end
                names=matlab.system.coder.ProcessConstructorArguments.getNameValueNames(varargin{:});
                lastValueOnlyArgIndex=0;
            end


            order=matlab.system.coder.ProcessConstructorArguments.getPropertySetOrder(class(obj),names);

            sortedNames=...
            matlab.system.coder.ProcessConstructorArguments.reorder(order,names);

            valueIdx=matlab.system.coder.ProcessConstructorArguments.getValueOnlyValueIdx(order,lastValueOnlyArgIndex);

            matlab.system.coder.ProcessConstructorArguments.setProperties(obj,sortedNames,valueIdx,varargin{:});
        end

        function indx_const=getLastValueOnlyArgIndex(objClass,varargin)
            indx=length(varargin);
            for ii=1:length(varargin)

                if(ischar(varargin{ii})||isStringScalar(varargin{ii}))&&eml_is_const(varargin{ii})&&...
                    matlab.system.coder.ProcessConstructorArguments.hasProperty(objClass,varargin{ii})
                    indx=ii-1;
                    break;
                end
            end

            indx_const=coder.internal.const(indx);
        end
    end

    methods(Static,Access=private)
        function valueOnlyNames=getValueOnlyNames(numValueOnlyNames,lastValueOnlyArgIndex,varargin)
            valueOnlyNames=cell(1,lastValueOnlyArgIndex);
            for n=coder.unroll(1:lastValueOnlyArgIndex)
                offset=coder.internal.const(numel(varargin)-numValueOnlyNames+n);
                valueOnlyNames{n}=coder.const(varargin{offset});
            end
        end

        function names=getNameValueNames(varargin)
            coder.internal.allowHalfInputs;
            coder.internal.prefer_const(varargin);
            numPairs=numel(varargin)/2;
            names=cell(1,numPairs);
            for n=coder.unroll(1:numPairs)
                names{n}=varargin{2*(n-1)+1};
            end
        end

        function names=combineNames(valueOnlyNames,narg,varargin)
            numNameValuePairs=(narg-numel(valueOnlyNames))/2;
            names=cell(1,numel(valueOnlyNames)+numNameValuePairs);

            for n=coder.unroll(1:numel(valueOnlyNames))
                names{n}=valueOnlyNames{n};
            end

            for n=coder.unroll(1:numNameValuePairs)
                names{n+numel(valueOnlyNames)}=varargin{numel(valueOnlyNames)+2*(n-1)+1};
            end
        end

        function idx=getValueOnlyValueIdx(propertySetOrder,lastValueOnlyArgIndex)
            coder.internal.prefer_const(propertySetOrder);
            idx=zeros(size(propertySetOrder));
            for n=coder.unroll(1:numel(propertySetOrder))
                order=propertySetOrder(n);
                if order<=lastValueOnlyArgIndex
                    idx(n)=order;
                else
                    idx(n)=lastValueOnlyArgIndex+((order-lastValueOnlyArgIndex)*2);
                end
            end
        end

        function flag_const=hasProperty(className,name)
            coder.extrinsic('matlab.system.coder.ProcessConstructorArguments.hasPropertyImpl');
            flag=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.hasPropertyImpl(className,name));
            flag_const=coder.internal.const(flag);
        end
    end


    methods(Static,Hidden)
        function b=hasPropertyImpl(className,name)
            publicProps=matlab.system.coder.ProcessConstructorArguments.getValueOnlyProps(className);
            b=any(strcmp(name,publicProps));
        end
    end

    methods(Static,Access=private)
        function publicProps=getValueOnlyProps(className)
            m=meta.class.fromName(className);
            pAll=m.Properties;

            N=numel(pAll);
            ip=false(size(pAll));
            pNames=cell(size(pAll));
            for i=1:N
                p=pAll{i};
                if~(p.Constant||p.Abstract||p.Transient)
                    ip(i)=true;
                    pNames{i}=p.Name;
                end
            end
            publicProps=pNames(ip);
        end
    end

    methods(Static,Access=private)
        function sortedData=reorder(idx,data)
            coder.internal.prefer_const(idx);
            coder.internal.prefer_const(data);
            sortedData=cell(coder.internal.const(size(data)));
            for n=coder.unroll(1:numel(idx))
                offset=coder.internal.const(idx(n));
                if coder.internal.isConst(data{offset})
                    sortedData{n}=coder.internal.const(data{offset});
                else
                    sortedData{n}=data{offset};
                end
            end
        end

        function idx=getPropertySetOrder(className,names)
            coder.extrinsic('matlab.system.coder.ProcessConstructorArguments.getPropertySetOrderImpl');
            idx=coder.internal.const(...
            matlab.system.coder.ProcessConstructorArguments.getPropertySetOrderImpl(className,names));
        end
    end


    methods(Static,Hidden)
        function idx=getPropertySetOrderImpl(className,names)
            metaClass=meta.class.fromName(className);
            idx=getPropertySetOrder(metaClass,names);

            idx=idx+1;
        end
    end

    methods(Static,Access=private)
        function setProperties(obj,names,valueIdx,varargin)
            coder.internal.allowHalfInputs;
            coder.internal.prefer_const(varargin);

            for ii=coder.unroll(1:numel(names))
                offset=coder.internal.const(valueIdx(ii));
                obj.(names{ii})=varargin{offset};
            end
        end
    end
end
