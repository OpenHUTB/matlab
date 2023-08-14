


classdef MultiPortSwitchConstraint2<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='If the indices for a Multi Port Switch block are specified, there may only be one value specified per input';
        end

        function obj=MultiPortSwitchConstraint2()
            obj.setEnum('MultiPortSwitch2');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            dataPortOrder=aObj.ParentBlock().getParam('DataPortOrder');
            if strcmpi(dataPortOrder,'Specify indices')
                blkSID=aObj.ParentBlock().getSID();
                dataPortIndices=slResolve(...
                aObj.ParentBlock().getParam('DataPortIndices'),...
                blkSID);
                if iscell(dataPortIndices)
                    for i=1:numel(dataPortIndices)
                        if numel(dataPortIndices{i})>1
                            out=slci.compatibility.Incompatibility(...
                            aObj,...
                            'MultiPortSwitchUniqueIndexPerInput',...
                            aObj.ParentBlock().getName());
                            return;
                        end
                    end
                end
            end
        end

    end
end
