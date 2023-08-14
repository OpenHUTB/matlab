classdef(AllowedSubclasses={?hwconnectinstaller.SignpostReader,?hwconnectinstaller.SignpostWriter},Hidden)Signpost




















































    properties(SetAccess=immutable)
SignpostVersion
Repository
PackageName
BaseProduct
FullName
BaseCode
    end

    methods(Access=protected)
        function obj=Signpost(info)
            requiredFields={'PackageName','FullName','BaseProduct','SignpostVersion','Repository','BaseCode'};
            for i=1:numel(requiredFields)
                fld=requiredFields{i};
                assert(isfield(info,fld)&&...
                ischar(info.(fld))&&...
                ~isempty(strtrim(info.(fld))),...
                'Signpost:InvalidParameter','Invalid Parameter');
            end

            assert(strcmp(info.SignpostVersion,'1.0'));
            assert(strcmp(info.Repository,'MathWorks'));

            obj.SignpostVersion=info.SignpostVersion;
            obj.Repository=info.Repository;
            obj.PackageName=info.PackageName;
            obj.BaseProduct=info.BaseProduct;
            obj.FullName=info.FullName;
            obj.BaseCode=info.BaseCode;
        end

        function isValid=verifySignature(obj,signature)
            isValid=strcmp(signature,calculateSignature(obj));
        end
    end

    methods(Access={?hwconnectinstaller.SignpostWriter})
        function sig=calculateSignature(obj)
            import java.security.MessageDigest;


            salt='tp53d1fa40_1bea_4be7_ac43_46b50d196b62';

            str=[obj.SignpostVersion,obj.Repository,obj.PackageName,obj.BaseProduct,obj.FullName];
            data=uint8([str,salt]);
            md=MessageDigest.getInstance('MD5');
            hash=md.digest(data);

            hexstrs=dec2hex(typecast(hash(:),'uint8'))';
            sig=hexstrs(:)';
        end
    end
end

