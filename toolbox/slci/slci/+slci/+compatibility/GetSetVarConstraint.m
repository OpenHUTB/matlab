


classdef GetSetVarConstraint<slci.compatibility.Constraint

    methods

        function obj=GetSetVarConstraint()
            obj.setEnum('GetSetVar');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end



        function out=getDescription(aObj)
            out=['The GetSet workspace vars referenced by ',...
            aObj.ParentModel().getName(),...
            ' must use a supported DataType and should have a header file'];
        end





        function out=check(aObj)
            out={};
            params={};
            WSVarInfoTable=aObj.ParentModel().getWSVarInfoTable();
            var_names=WSVarInfoTable.keys;
            for i=1:numel(var_names)
                paths_table=WSVarInfoTable(var_names{i});
                paths=paths_table.keys;
                for j=1:numel(paths)
                    var_prop=paths_table(paths{j});
                    if strcmp(var_prop.StorageClass,'Custom')...
                        &&strcmp(var_prop.CSCName,'GetSet')



                        if strcmp(var_prop.CSCHeaderFile,'')
                            incomp_str=['Simulink Object '...
                            ,var_prop.RTWName...
                            ,' has GetSet Custom Storage Class'...
                            ,' with no header file specified'];
                            params=[params,incomp_str];%#ok
                        end


                        if strcmp(var_prop.DataType,'struct')||...
                            strcmp(var_prop.DataType,'bus')
                            incomp_str=['Simulink Object '...
                            ,var_prop.RTWName...
                            ,' has GetSet Custom Storage Class'...
                            ,' with unsupported Data Type '...
                            ,var_prop.DataType];
                            params=[params,incomp_str];%#ok
                        end
                    end
                end
            end
            if~isempty(params)
                failure=slci.compatibility.Incompatibility(...
                aObj,...
                'GetSetVar');
                failure.setObjectsInvolved(params);
                out=failure;
            end
        end
    end
end

