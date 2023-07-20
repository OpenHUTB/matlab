classdef Label<matlab.project.LabelDefinition








    properties(SetAccess=private,GetAccess=private,Hidden=true)
        ProjectInstance;
    end

    properties(GetAccess=public,SetAccess=private)

        File;

        DataType;
    end

    properties(Dependent=true)

        Data;
    end

    properties(Dependent=true,Hidden=true,GetAccess=public,SetAccess=private)
        LabelUUID;
        CategoryUUID;
    end

    methods(Access=public,Hidden=true)

        function obj=Label(categoryName,labelName,projectInstance,file)



            obj@matlab.project.LabelDefinition(categoryName,labelName);
            obj.ProjectInstance=projectInstance;
            obj.File=file;
        end

    end

    methods

        function data=get.Data(obj)

            jFileLabel=obj.getJavaFileLabel();
            data=jFileLabel.getData();
            if(strcmp(obj.DataType,'integer'))
                data=obj.processIntegerToGet(jFileLabel);
            end
        end

        function obj=set.Data(obj,data)

            if isstring(data)
                data=char(data);
            end

            iAssertScalar(data);
            iAssertNonComplex(data);


            jFileLabel=obj.getJavaFileLabel();

            dataType=obj.getDataTypeFromJFileLabel(jFileLabel);
            obj.assertDataTypeMatch(data,dataType);


            if strcmp(dataType,'char')
                data=obj.processStringToSet(data);
            elseif strcmp(dataType,'integer')
                data=obj.processIntegerToSet(data);
            end


            import matlab.internal.project.util.processJavaCall;
            processJavaCall(@()jFileLabel.setData(data));
        end

        function dataType=get.DataType(obj)
            jFileLabel=obj.getJavaFileLabel();
            dataType=obj.getDataTypeFromJFileLabel(jFileLabel);
        end

        function uuid=get.LabelUUID(obj)
            jFileLabelFacade=obj.getJavaFileLabel();
            jLabel=jFileLabelFacade.getLabel();
            uuid=string(jLabel.getUUID());
        end

        function uuid=get.CategoryUUID(obj)
            jFileLabelFacade=obj.getJavaFileLabel();
            jCategory=jFileLabelFacade.getCategory();
            uuid=string(jCategory.getUUID());
        end
    end



    methods(Access=private)

        function dataType=getDataTypeFromJFileLabel(~,jFileLabel)
            dataHandler=jFileLabel.getCategory.getDataTypeHandler();
            dataType=char(dataHandler.getMatlabDataType());
        end

        function assertDataTypeMatch(obj,data,dataType)



            if~strcmp(dataType,class(data))



                if~(strcmp(dataType,'integer')&&iCanBeInteger(data))

                    error(message('MATLAB:project:api:LabelDataTypeMismatch',...
                    obj.Name,obj.CategoryName,dataType,class(data)));
                end
            end

        end

        function jFileLabel=getJavaFileLabel(obj)

            import matlab.internal.project.util.processJavaCall;

            javaProjectManager=obj.ProjectInstance.getJavaProjectManager();

            jFileLabel=processJavaCall(@()javaProjectManager.getLabelAttachedToFile(...
            char(obj.File),...
            char(obj.CategoryName),...
            char(obj.Name))...
            );

        end

        function integerPackage=processIntegerToSet(obj,data)


            originalData=data;
            if~isa(data,'int64')
                data=int64(data);
                if~(data==originalData)
                    error(message('MATLAB:project:api:LabelDataTypeMismatchValues',...
                    obj.Name,obj.CategoryName,obj.DataType));
                end
            end

            import com.mathworks.toolbox.slproject.project.metadata.label.data.implementations.util.LabelIntegerPackage;
            if(~isempty(data))
                integerPackage=LabelIntegerPackage(java.lang.Long(data));
            else
                integerPackage=LabelIntegerPackage([]);
            end

        end

        function data=processStringToSet(~,data)
            if numel(data)==1
                data=java.lang.String(data);
            end
            dataSize=size(data);
            if numel(dataSize)>2||dataSize(1)~=1
                error(message('MATLAB:project:api:LabelDataStringNot1xN'));
            end
        end

        function data=processIntegerToGet(~,fileLabel)

            integerPackage=fileLabel.getData();
            if isempty(integerPackage)
                data=int64(zeros(0,0));
            else
                data=integerPackage.getValueForMATLAB();
            end

        end
    end

end

function iAssertScalar(data)

    if(numel(data)>1||numel(size(data))~=2)&&~isa(data,'char')
        error(message('MATLAB:project:api:LabelNonScalarData'));
    end
end

function iAssertNonComplex(data)

    if iIsComplex(data)
        error(message('MATLAB:project:api:LabelComplexData'));
    end

end

function value=iIsComplex(data)
    value=isnumeric(data)&&~isreal(data);
end

function result=iCanBeInteger(data)


    result=isa(data,'double')||isa(data,'int64')||...
    isa(data,'int32')||isa(data,'int16')||isa(data,'int8');

end

