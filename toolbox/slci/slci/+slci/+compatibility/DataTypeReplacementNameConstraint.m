

classdef DataTypeReplacementNameConstraint<slci.compatibility.Constraint

    properties(Access=private)

        fPrimitiveTypes={'double','single','int64','int32','int16','int8',...
        'uint64','uint32','uint16','uint8','boolean','int',...
        'uint','char'};
    end

    methods

        function out=getDescription(aObj)%#ok
            out='Type replacement name must be of type Simulink.AliasType';
        end


        function obj=DataTypeReplacementNameConstraint(varargin)
            obj.setEnum('DataTypeReplacementName');
            obj.setCompileNeeded(false);
            obj.setFatal(false);
            obj.addPreRequisiteConstraint(...
            slci.compatibility.ERTTargetConstraint);
        end

        function out=check(aObj)
            out=[];
            enableReplacement=aObj.ParentModel().getParam(...
            'EnableUserReplacementTypes');
            if strcmpi(enableReplacement,'on')
                replacements=aObj.ParentModel().getParam('ReplacementTypes');
                fnames=fieldnames(replacements);
                replNames={};
                for k=1:numel(fnames)
                    buildInType=fnames{k};
                    replName=replacements.(buildInType);
                    if~isempty(replName)
                        if(~aObj.checkReplacementName(replName))
                            replNames{end+1}=replName;%#ok
                        end
                    end
                end
                if~isempty(replNames)
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'DataTypeReplacementName');
                    out.setObjectsInvolved(replNames);
                end
            end
        end
    end

    methods(Access=private)



        function out=checkReplacementName(aObj,name)
            try
                aliasType=slResolve(name,aObj.ParentModel().getHandle());
                resolved=true;
            catch
                resolved=false;
            end

            if resolved&&isa(aliasType,'Simulink.AliasType')

                out=aObj.checkBaseType(aliasType.BaseType);
            elseif~resolved&&any(strcmp(aObj.fPrimitiveTypes,name))

                out=true;
            else

                out=false;
            end
        end


        function out=checkBaseType(aObj,baseType)
            out=any(strcmp(aObj.fPrimitiveTypes,baseType));
        end

    end

end
