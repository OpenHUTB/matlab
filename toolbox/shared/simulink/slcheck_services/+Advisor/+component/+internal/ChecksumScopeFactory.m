classdef ChecksumScopeFactory
    methods(Static)
        function checksumScope=createChecksumScope(template,component)
            checksumScopeID=...
            Advisor.component.internal.ChecksumScopeFactory.getChecksumScopeID(template,component.ID,component.Type);

            checksumScope.ChecksumScopeID=checksumScopeID;
            checksumScope.Checksum=template.FileChecksum;
            checksumScope.RootComponentID=component.ID;
        end

        function checksumScopeID=getChecksumScopeID(template,componentID,componentType)
            switch componentType
            case{Advisor.component.Types.Model,...
                Advisor.component.Types.MFile,Advisor.component.Types.ProtectedModel}

                stringForHash=template.File;

            case{Advisor.component.Types.SubSystem,Advisor.component.Types.Chart,...
                Advisor.component.Types.MATLABFunction}
                stringForHash=[template.File,componentID];

            otherwise


                error('Unsupported usage of ComponentManager');
            end

            checksumScopeID=reshape(dec2hex(typecast(CGXE.Utils.md5(stringForHash),'uint8')),1,64);
        end
    end
end