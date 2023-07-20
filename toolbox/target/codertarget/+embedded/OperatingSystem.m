classdef(Hidden)OperatingSystem<embedded.OperatingSystemBase





    properties(GetAccess=public,SetAccess=private)
        OperatingSystemDistributions=[];
OperatingSystemSoftwareInfo
ConnectionInfo
    end
    methods(Static)

    end

    methods(Static,Hidden)

    end

    methods(Access=public)
        function obj=OperatingSystem(osName)
            [validOS,validOSInfo]=soc.internal.customoperatingsystem.getSupportedOperatingSystems;
            validatestring(osName,validOS,'','OperatingSystemName',1);
            obj=obj@embedded.OperatingSystemBase(osName);
            [~,idx]=ismember(lower(osName),lower(validOS));
            obj.OperatingSystemSoftwareInfo=validOSInfo{idx};
            obj.ConnectionInfo=obj.OperatingSystemSoftwareInfo.SystemInterface;
        end

        function ret=isValidFeature(obj,featureStructure)
            ftr=obj.OperatingSystemSoftwareInfo.BlocksetFeatures;
            requiredFields=fieldnames(ftr{1});
            actualFields=fieldnames(featureStructure);
            ret=isequal(requiredFields,actualFields);
        end

        function ret=getFeatures(obj)
            validateattributes(obj.OperatingSystemSoftwareInfo.BlocksetFeatures,{'cell'},{'nonempty'},'','BlocksetFeatures in <OS>softwareregistry.json')
            ret=obj.OperatingSystemSoftwareInfo.BlocksetFeatures;
        end

        function connectionObj=getConnection(obj,varargin)

            connectionObj=feval(obj.ConnectionInfo.MATLABFcn,varargin{:});
        end

        function distObj=getDistribution(h,option,value)








            if isequal(option,'name')
                for i=1:numel(h.OperatingSystemDistributions)
                    if isequal(value,h.OperatingSystemDistributions.Name)
                        distObj=h.OperatingSystemDistributions;
                    end
                end
            else

                distObj=h.OperatingSystemDistributions;
            end

        end

        function distObj=addNewOperatingSystemDistribution(h,name)
            for i=1:numel(h.OperatingSystemDistributions)
                if isequal(h.OperatingSystemDistributions{i}.Name,name)
                    distObj=h.OperatingSystemDistributions{i};
                    return;
                end
            end
            distObj=embedded.OperatingSystemDistribution(name);
            h.OperatingSystemDistributions{end+1}=distObj;
        end

        function deleteOperatingSystemDistribution(h,name)
            j=1;
            distObj=[];
            for i=1:numel(h.OperatingSystemDistributions)
                if isequal(name,h.OperatingSystemDistributions{i}.Name)
                    continue;
                else
                    distObj{j}=h.OperatingSystemDistributions{i};%#ok<AGROW>
                    j=j+1;
                end
            end
            h.OperatingSystemDistributions=distObj;
        end

    end
    methods(Access=public,Hidden)

    end
end
