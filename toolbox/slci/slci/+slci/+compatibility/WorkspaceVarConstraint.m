classdef WorkspaceVarConstraint<slci.compatibility.Constraint



    methods

        function obj=WorkspaceVarConstraint()
            obj.setEnum('WorkspaceVar');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=getDescription(aObj)
            out=['The workspace vars referenced by ',...
            aObj.ParentModel().getName(),...
            ' must use a builtin storage class, or an Unstructured custom storage class.'];
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






                    storageClassCheck=slci.internal.isUnSupportedCSC(var_prop);
                    if((storageClassCheck&&...
                        (~strcmp(var_prop.Package,'mpt')))||...
                        (strcmp(var_prop.Package,'mpt')...
                        &&~ismember(var_prop.CSCName,...
                        {'Global',...
                        'Const',...
                        'Volatile',...
                        'ConstVolatile',...
                        'ImportedDefine',...
                        'Define',...
                        'GetSet',...
                        'ExportToFile'}))...
                        )

                        incomp_str=['Custom storage class CSCType for '...
                        ,var_names{i}...
                        ,' in '...
                        ,paths{j}...
                        ,' is '...
                        ,var_prop.CSCType
                        ];
                        params=[params,incomp_str];%#ok                
                    end
                end
            end

            if~isempty(params)
                failure=slci.compatibility.Incompatibility(...
                aObj,...
                'TunableParameter');
                failure.setObjectsInvolved(params);
                out=failure;
            end
        end
    end
end




