classdef BaseVarInfo<handle

    properties(Access=private)


fieldIndex
isStructField
rootStructInfo
structFieldVarMap




isClone
    end

    properties

SimMin
SimMax
IsAlwaysInteger
HistogramOfNegativeValues
HistogramOfPositiveValues
RatioOfRange


proposed_Type
userSpecifiedAnnotation
    end

    methods

        function set.SimMin(this,val)
            if this.isStructField

                this.rootStructInfo.setStructPropUsingIndices(this.fieldIndex,'SimMin',val,this.isStruct()||this.isVarInSrcCppSystemObj());
            else
                this.SimMin=val;
            end
        end

        function val=get.SimMin(this)
            if this.isStructField

                val=this.rootStructInfo.getStructPropUsingIndices(this.fieldIndex,'SimMin',this.isStruct()||this.isVarInSrcCppSystemObj());
            else
                val=this.SimMin;
            end
        end

        function set.SimMax(this,val)
            if this.isStructField

                this.rootStructInfo.setStructPropUsingIndices(this.fieldIndex,'SimMax',val,this.isStruct()||this.isVarInSrcCppSystemObj());
            else
                this.SimMax=val;
            end
        end

        function val=get.SimMax(this)
            if this.isStructField

                val=this.rootStructInfo.getStructPropUsingIndices(this.fieldIndex,'SimMax',this.isStruct()||this.isVarInSrcCppSystemObj());
            else
                val=this.SimMax;
            end
        end

        function set.IsAlwaysInteger(this,val)
            if this.isStructField

                this.rootStructInfo.setStructPropUsingIndices(this.fieldIndex,'IsAlwaysInteger',val,this.isStruct()||this.isVarInSrcCppSystemObj());
            else
                this.IsAlwaysInteger=val;
            end
        end

        function val=get.IsAlwaysInteger(this)
            if this.isStructField

                val=this.rootStructInfo.getStructPropUsingIndices(this.fieldIndex,'IsAlwaysInteger',this.isStruct()||this.isVarInSrcCppSystemObj());
            else
                val=this.IsAlwaysInteger;
            end
        end

        function set.HistogramOfNegativeValues(this,val)
            if this.isStructField

                this.rootStructInfo.setStructPropUsingIndices(this.fieldIndex,'HistogramOfNegativeValues',val,this.isStruct()||this.isVarInSrcCppSystemObj());
            else
                this.HistogramOfNegativeValues=val;
            end
        end

        function val=get.HistogramOfNegativeValues(this)
            if this.isStructField

                val=this.rootStructInfo.getStructPropUsingIndices(this.fieldIndex,'HistogramOfNegativeValues',this.isStruct()||this.isVarInSrcCppSystemObj());
            else
                val=this.HistogramOfNegativeValues;
            end
        end

        function set.HistogramOfPositiveValues(this,val)
            if this.isStructField

                this.rootStructInfo.setStructPropUsingIndices(this.fieldIndex,'HistogramOfPositiveValues',val,this.isStruct()||this.isVarInSrcCppSystemObj());
            else
                this.HistogramOfPositiveValues=val;
            end
        end

        function val=get.HistogramOfPositiveValues(this)
            if this.isStructField

                val=this.rootStructInfo.getStructPropUsingIndices(this.fieldIndex,'HistogramOfPositiveValues',this.isStruct()||this.isVarInSrcCppSystemObj());
            else
                val=this.HistogramOfPositiveValues;
            end
        end

        function set.RatioOfRange(this,val)
            if this.isStructField

                this.rootStructInfo.setStructPropUsingIndices(this.fieldIndex,'RatioOfRange',val,this.isStruct()||this.isVarInSrcCppSystemObj());
            else
                this.RatioOfRange=val;
            end
        end

        function val=get.RatioOfRange(this)
            if this.isStructField

                val=this.rootStructInfo.getStructPropUsingIndices(this.fieldIndex,'RatioOfRange',this.isStruct()||this.isVarInSrcCppSystemObj());
            else
                val=this.RatioOfRange;
            end
        end

        function set.proposed_Type(this,val)
            if this.isStructField

                this.rootStructInfo.setStructPropUsingIndices(this.fieldIndex,'proposed_Type',val,this.isStruct()||this.isVarInSrcCppSystemObj());
            else
                this.proposed_Type=val;
            end
        end

        function val=get.proposed_Type(this)
            if this.isStructField

                val=this.rootStructInfo.getStructPropUsingIndices(this.fieldIndex,'proposed_Type',this.isStruct()||this.isVarInSrcCppSystemObj());
            else
                val=this.proposed_Type;
            end
        end

        function set.userSpecifiedAnnotation(this,val)
            if this.isStructField

                this.rootStructInfo.setStructPropUsingIndices(this.fieldIndex,'userSpecifiedAnnotation',val,this.isStruct()||this.isVarInSrcCppSystemObj());
            else
                this.userSpecifiedAnnotation=val;
            end
        end

        function val=get.userSpecifiedAnnotation(this)
            if this.isStructField
                if~isempty(this.rootStructInfo.userSpecifiedAnnotation)

                    val=this.rootStructInfo.getStructPropUsingIndices(this.fieldIndex,'userSpecifiedAnnotation',this.isStruct()||this.isVarInSrcCppSystemObj());
                else
                    val=[];
                end
            else
                val=this.userSpecifiedAnnotation;
            end
        end
    end

    methods(Access=public)

        function this=BaseVarInfo()
            this.fieldIndex=[];
            this.isStructField=false;
            this.rootStructInfo=coder.internal.VarTypeInfo.empty();
            this.structFieldVarMap=coder.internal.lib.Map();
        end

        function res=isRootStruct(this)
            res=~this.isStructField&&isempty(this.rootStructInfo);
        end

        function s=getRootStruct(this)
            s=this.rootStructInfo;
        end

        function val=getIsClone(this)
            val=this.isClone;
        end

        function setIsClone(this,val)
            this.isClone=val;
        end
    end

    methods(Access=protected)


        function assignStructRoot(this,fieldIndex,rootStructInfo)
            assert(rootStructInfo.isStruct()||this.isVarInSrcCppSystemObj());

            this.fieldIndex=fieldIndex;
            this.isStructField=true;
            this.rootStructInfo=rootStructInfo;
        end

        function addStructFieldVarInfo(this,fullFieldName,varInfo)
            assert(~this.isAStructField);
            this.structFieldVarMap(fullFieldName)=varInfo;
        end

        function res=hasStructFieldVarInfo(this,fullFieldName)
            assert(~this.isAStructField);
            res=this.structFieldVarMap.isKey(fullFieldName);
        end

        function varInfo=getStructFieldVarInfo(this,fullFieldName)
            assert(~this.isAStructField);
            varInfo=this.structFieldVarMap(fullFieldName);
        end

        function val=isAStructField(this)
            val=this.isStructField;
        end

        function val=getRootStructInfo(this)
            val=this.rootStructInfo;
        end
    end

    methods(Access=private)



        function val=getStructPropUsingIndices(this,index,propName,retainPropertyType)
            if this.isStruct()||this.isVarInSrcCppSystemObj()
                if strcmp(propName,'fimath')
                    val=this.getFimathForStructField(index);
                else



                    propertyVal=this.(propName);
                    if isempty(propertyVal)
                        val=propertyVal;
                        return;
                    end
                    if retainPropertyType
                        val=getPropertyValueAt(this,propertyVal,index);
                    else
                        if 1==length(index)
                            if iscell(propertyVal)

                                val=getCellPropertyValueAt(this,propertyVal,index);
                            else

                                val=getPropertyValueAt(this,propertyVal,index);
                            end
                        else

                            val=getPropertyValueAt(this,propertyVal,index);
                        end
                    end
                end
            else
                error('not a struct');
            end
        end

        function val=getCellPropertyValueAt(~,propertyVal,index)
            if 1<size(propertyVal,1)


                val=propertyVal{index,:};
            else
                val=propertyVal{index};
            end
        end

        function val=getPropertyValueAt(~,propertyVal,index)
            if 1<size(propertyVal,1)


                val=propertyVal(index,:);
            else
                val=propertyVal(index);
            end
        end

        function setStructPropUsingIndices(this,index,propName,val,retainPropertyType)

            arrayProps={'SimMin','SimMax','DesignMin','DesignMax','DerivedMin','DerivedMax','DesignIsInteger'};

            if this.isStruct()||this.isVarInSrcCppSystemObj()






                propertyVal=this.(propName);
                if isempty(propertyVal)
                    if any(strcmp(arrayProps,propName))
                        propertyVal=[];
                    else
                        propertyVal=cell(1,length(this.loggedFields));
                    end
                end
                if retainPropertyType
                    propertyVal(index)=val;
                else
                    if iscell(propertyVal)
                        propertyVal{index}=val;
                    else
                        propertyVal(index)=val;
                    end
                end
                this.(propName)=propertyVal;
            else
                error('not a struct');
            end
        end
    end
end