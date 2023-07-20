






classdef SignalDescriptor<handle
    properties(Hidden)


        children;


        childrenNames;



        parentBusName;
        indexInParent;


        inportIdx;



        busElemInfo;



        partialInfo=true;



        infoFromUnknownInport;
    end


    methods(Access=public,Hidden=true)


        function setParentInfo(obj,busName,childIdx)
            if~isempty(busName)&&childIdx>0
                obj.parentBusName=busName;
                obj.indexInParent=childIdx;
            end
        end


        function[busName,idxInParent]=getParentInfo(obj)
            busName=obj.parentBusName;
            idxInParent=obj.indexInParent;
        end


        function result=isFromUnknownSource(obj)
            result=obj.infoFromUnknownInport;
        end


        function setComplete(obj)
            obj.partialInfo=false;
        end


        function setInportIdx(obj,idx)

            if~isequal(floor(idx),idx)||idx<1
                return;
            end
            obj.inportIdx=idx;
        end


        function result=getInportIdx(obj)
            result=obj.inportIdx;
        end


        function setAttributes(obj,busElem)

            if obj.infoFromUnknownInport
                return;
            end

            obj.busElemInfo=busElem;
            obj.setComplete();
        end
    end

    methods(Access=public)











        function obj=SignalDescriptor(fromUnknownInport)
            if nargin<1
                fromUnknownInport=false;
            end

            obj.children=[];
            obj.childrenNames={};
            obj.busElemInfo=[];
            obj.partialInfo=true;
            obj.infoFromUnknownInport=fromUnknownInport;
        end


        function result=getElement(obj,index)











            if obj.infoFromUnknownInport
                result=Simulink.SignalDescriptor(true);
                return;
            end

            result=[];

            if~isequal(floor(index),index)
                return;
            end

            if index<1||index>length(obj.children)
                return;
            end


            result=obj.children(index);
        end


        function result=getElementName(obj,index)
            result=[];

            if~isequal(floor(index),index)
                return;
            end

            if index<1||index>length(obj.childrenNames)
                return;
            end
            result=obj.childrenNames{index};
        end


        function result=getNumElements(obj)
            result=length(obj.children);
        end


        function setDataTypeName(obj,name)


            if obj.infoFromUnknownInport||isempty(name)
                return;
            end

            if isempty(obj.busElemInfo)
                obj.busElemInfo=Simulink.BusElement;
            end

            obj.busElemInfo.DataType=name;
            obj.setComplete();
        end



        function result=getDataTypeName(obj)
            result=[];
            if~isempty(obj.busElemInfo)


                curDType=obj.busElemInfo.DataType;
                if obj.isBus()&&sl('sldtype_is_builtin',curDType)
                    return;
                else
                    result=curDType;
                end
            end
        end


        function result=getComplexity(obj)
            result=[];
            if~obj.isBus()&&~isempty(obj.busElemInfo)
                result=obj.busElemInfo.Complexity;
            end
        end


        function setDimensions(obj,dims)


            if obj.infoFromUnknownInport||isempty(dims)
                return;
            end

            if isempty(obj.busElemInfo)
                obj.busElemInfo=Simulink.BusElement;
            end

            obj.busElemInfo.Dimensions=dims;
            obj.setComplete();
        end


        function result=getDimensions(obj)
            result=[];
            if~isempty(obj.busElemInfo)
                result=obj.busElemInfo.Dimensions;
            end
        end


        function result=isBus(obj)
            if obj.infoFromUnknownInport||obj.isPartial()||...
                isempty(obj.children)
                result=false;
                return;
            end
            result=true;
        end


        function result=isPartial(obj)
            result=obj.partialInfo;
        end


        function addElement(obj,elem,name)
            assert(~isempty(elem));


            if obj.infoFromUnknownInport
                return;
            end


            if isa(elem,'Simulink.SignalDescriptor')
                obj.children=[obj.children,elem];
                obj.childrenNames=[obj.childrenNames,name];
                obj.setComplete();
                return;
            end



            if(isnumeric(elem)||islogical(elem)||isfi(elem)||isstring(elem))
                elemSigDesc=Simulink.SignalDescriptor;
                elemAttributes=Simulink.BusElement;


                elemAttributes.DataType=class(elem);

                if islogical(elem)
                    elemAttributes.DataType='boolean';
                end

                if isfi(elem)
                    elemAttributes.DataType=fixdt(numerictype(elem));
                end

                if isenum(elem)

                    enumStrHead="Enum: ";
                    elemAttributes.DataType=strcat(enumStrHead,class(elem));
                end


                elemAttributes.Dimensions=size(elem);

                if isequal(size(elem),[1,1])
                    elemAttributes.Dimensions=1;
                end


                if isnumeric(elem)&&~isreal(elem)
                    elemAttributes.Complexity='complex';
                end


                elemSigDesc.busElemInfo=elemAttributes;
                elemSigDesc.setComplete();
                obj.addElement(elemSigDesc,name);
                obj.setComplete();
                return;
            end


            if isa(elem,'Simulink.BusElement')
                elemSigDesc=Simulink.SignalDescriptor;
                elemSigDesc.busElemInfo=elem;
                elemSigDesc.setComplete();
                obj.addElement(elemSigDesc,name);
                obj.setComplete();
            end
        end
    end
end


