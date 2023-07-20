classdef ObjectIDUtility

    properties(Constant)
        TypeDelimiter="|";
        MethodPropDelimiter="$";
    end



    methods(Static)
        function id=generateID(obj)
            idVisitor=classdiagram.app.core.visitors.GenerateIDVisitor;
            obj.accept(idVisitor);
            id=idVisitor.id;
        end

        function id=generateFolderID(folderName)
            id=classdiagram.app.core.domain.Folder.ConstantType+classdiagram.app.core.utils.ObjectIDUtility.TypeDelimiter+folderName;
        end

        function id=generateProjectID(projectName)
            id=classdiagram.app.core.domain.Project.ConstantType+classdiagram.app.core.utils.ObjectIDUtility.TypeDelimiter+projectName;
        end

        function id=generatePackageID(packageName)
            id=classdiagram.app.core.domain.Package.ConstantType+classdiagram.app.core.utils.ObjectIDUtility.TypeDelimiter+packageName;
        end

        function id=generateClassID(className)
            id=classdiagram.app.core.domain.Class.ConstantType+classdiagram.app.core.utils.ObjectIDUtility.TypeDelimiter+className;
        end

        function id=generateMethodID(className,methodName)
            id=classdiagram.app.core.domain.Method.ConstantType+classdiagram.app.core.utils.ObjectIDUtility.TypeDelimiter+className+classdiagram.app.core.utils.ObjectIDUtility.MethodPropDelimiter+methodName;
        end

        function id=generatePropertyID(className,propertyName)
            id=classdiagram.app.core.domain.Property.ConstantType+classdiagram.app.core.utils.ObjectIDUtility.TypeDelimiter+className+classdiagram.app.core.utils.ObjectIDUtility.MethodPropDelimiter+propertyName;
        end

        function id=generateEventID(className,eventName)
            id=classdiagram.app.core.domain.Event.ConstantType+classdiagram.app.core.utils.ObjectIDUtility.TypeDelimiter+className+classdiagram.app.core.utils.ObjectIDUtility.MethodPropDelimiter+eventName;
        end

        function id=generateEnumID(enumName)
            id=classdiagram.app.core.domain.Enum.ConstantType+classdiagram.app.core.utils.ObjectIDUtility.TypeDelimiter+enumName;
        end

        function id=generateEnumLiteralID(enumName,enumLiteralName)
            id=classdiagram.app.core.domain.EnumLiteral.ConstantType+classdiagram.app.core.utils.ObjectIDUtility.TypeDelimiter+enumName+classdiagram.app.core.utils.ObjectIDUtility.MethodPropDelimiter+enumLiteralName;
        end

        function id=generateRelationshipID(srcClassName,dstClassName,relationshipType)
            id=classdiagram.app.core.domain.Relationship.ConstantType...
            +classdiagram.app.core.utils.ObjectIDUtility.TypeDelimiter+srcClassName...
            +classdiagram.app.core.utils.ObjectIDUtility.TypeDelimiter+dstClassName...
            +classdiagram.app.core.utils.ObjectIDUtility.MethodPropDelimiter+relationshipType;
        end

        function id=generateRelationshipEndID(relationshipEndType,parentClassName,oppositeClassName,relationshipType)
            id=relationshipEndType+classdiagram.app.core.utils.ObjectIDUtility.TypeDelimiter+parentClassName+classdiagram.app.core.utils.ObjectIDUtility.TypeDelimiter+oppositeClassName+classdiagram.app.core.utils.ObjectIDUtility.MethodPropDelimiter+relationshipType;
        end


    end
end
