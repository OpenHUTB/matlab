





classdef CodeMappingDefaultsConstraint<slci.compatibility.Constraint

    methods


        function obj=CodeMappingDefaultsConstraint(varargin)
            obj.setEnum('CodeMappingDefaults');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end


        function out=getDescription(aObj)
            out=['The model ',aObj.ParentModel.getName,...
            ' must set each Storage Class to ''Default'' for each Model Element Category in Code Mappings.'];
        end


        function out=check(aObj)
            out=[];
            dcs={};
            try

                cp=Simulink.CodeMapping.get(bdroot,'CoderDictionary');
                if~isempty(cp)
                    dc=coder.mapping.defaults.dataCategories;
                    for i=1:numel(dc)
                        sc=coder.mapping.defaults.get(aObj.ParentModel.getName,dc{i},'StorageClass');
                        if~strcmp(sc,'Default')
                            dcs=[dcs,dc{i}];%#ok<*AGROW>
                        end
                    end
                end
            catch
            end
            if~isempty(dcs)
                out=slci.compatibility.Incompatibility(aObj,'CodeMappingDefaults',aObj.ParentModel.getName);
                out.setObjectsInvolved(dcs);
            end
        end

    end

end