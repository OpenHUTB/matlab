




classdef(Sealed)PasswordManager<handle
    properties(Transient,Access=private)
        fPasswordMap;
        fCertificatePasswordMap;
    end

    properties(Constant)

        passwordMinLength=8;
        passwordMaxLength=4096;
    end

    methods(Access=private)
        function obj=PasswordManager()
            obj.fPasswordMap=containers.Map('KeyType','char','ValueType','any');
            obj.fCertificatePasswordMap=containers.Map('KeyType','char','ValueType','char');
        end
    end

    methods
        function setPasswordForEncryptionCategory(obj,model_arg,category,password)
            assert(strcmp(category,'SIM')||...
            strcmp(category,'RTW')||...
            strcmp(category,'VIEW')||...
            strcmp(category,'MODIFY')||...
            strcmp(category,'HDL'));


            [~,model,~]=fileparts(model_arg);

            obj.checkPassword(password,model);
            if isKey(obj.fPasswordMap,model)
                modelPWStruct=obj.fPasswordMap(model);
            else
                modelPWStruct=obj.getDefaultPWStruct();
            end
            modelPWStruct(1).(category)=password;
            obj.fPasswordMap(model)=modelPWStruct(1);
        end

        function setPasswordForCertificate(obj,certificate,password)
            [~,name,ext]=fileparts(certificate);
            if~any(ext==[".pfx",".p12"])
                error(message('Simulink:protectedModel:SignatureCertificateFileExtension'));
            end
            obj.fCertificatePasswordMap([name,ext])=password;
        end

        function clearPasswordForModel(obj,model)
            if isKey(obj.fPasswordMap,model)
                remove(obj.fPasswordMap,model);
            end
        end

        function clearPasswordForCertificate(obj,certificate)
            [~,name,ext]=fileparts(certificate);
            if isKey(obj.fCertificatePasswordMap,[name,ext])
                remove(obj.fCertificatePasswordMap,[name,ext]);
            end
        end

        function clearEncryptionCategory(obj,model,category)
            assert(strcmp(category,'SIM')||...
            strcmp(category,'RTW')||...
            strcmp(category,'VIEW')||...
            strcmp(category,'MODIFY')||...
            strcmp(category,'HDL'));

            if isKey(obj.fPasswordMap,model)
                modelPWStruct=obj.fPasswordMap(model);
                modelPWStruct(1).(category)='';
                obj.fPasswordMap(model)=modelPWStruct(1);
            end
        end
    end

    methods(Static)
        function out=Utils(action,varargin)

            persistent pwManager;

            switch action
            case 'getManager'
                if isempty(pwManager)
                    pwManager=Simulink.ModelReference.ProtectedModel.PasswordManager();
                end
                out=pwManager;
                mlock;
            case 'clear'
                munlock;
                if~isempty(pwManager)
                    clear 'pwManager';
                end
                out=[];
            case 'clearModel'
                narginchk(2,2);
                obj=Simulink.ModelReference.ProtectedModel.PasswordManager.Utils('getManager');
                obj.clearPasswordForModel(varargin{1});
                out=[];
            case 'clearCertificate'
                narginchk(2,2);
                obj=Simulink.ModelReference.ProtectedModel.PasswordManager.Utils('getManager');
                obj.clearPasswordForCertificate(varargin{1});
                out=[];
            case 'clearEncryptionCategory'
                narginchk(3,3);
                obj=Simulink.ModelReference.ProtectedModel.PasswordManager.Utils('getManager');
                obj.clearEncryptionCategory(varargin{1},varargin{2});
                out=[];
            otherwise
                assert(true,'Misuse of PasswordManager Utils');
            end
        end
    end

    methods(Static,Hidden)


        function checkPassword(password,model)
            import Simulink.ModelReference.ProtectedModel.*;


            if length(password)<PasswordManager.passwordMinLength
                DAStudio.error('Simulink:protectedModel:EncryptPasswordTooShort',model);
            end


            if length(password)>=PasswordManager.passwordMaxLength
                DAStudio.error('Simulink:protectedModel:EncryptPasswordTooLong',model);
            end
        end

        function out=getPasswordForModify(model)
            out=Simulink.ModelReference.ProtectedModel.PasswordManager.getPasswordForEncryptionCategory(model,'MODIFY');
        end

        function out=getPasswordForCertificate(certificate)
            obj=Simulink.ModelReference.ProtectedModel.PasswordManager.Utils('getManager');
            [~,name,ext]=fileparts(certificate);
            if isKey(obj.fCertificatePasswordMap,[name,ext])
                out=obj.fCertificatePasswordMap([name,ext]);
            else
                out='';
            end
        end

        function out=getPasswordForEncryptionCategory(model,category)
            assert(strcmp(category,'SIM')||...
            strcmp(category,'RTW')||...
            strcmp(category,'VIEW')||...
            strcmp(category,'MODIFY')||...
            strcmp(category,'HDL')||...
            strcmp(category,'NONE'),...
            'Invalid encryption category specified');

            if strcmp(category,'NONE')
                out='';
            else
                obj=Simulink.ModelReference.ProtectedModel.PasswordManager.Utils('getManager');
                if isKey(obj.fPasswordMap,model)
                    modelPWStruct=obj.fPasswordMap(model);
                    out=modelPWStruct.(category);
                else
                    out='';
                end
            end
        end

        function out=getPasswordForRelationship(model,relationship)
            category=Simulink.ModelReference.ProtectedModel.getEncryptionCategoryForRelationship(model,relationship);
            assert(strcmp(category,'SIM')||...
            strcmp(category,'RTW')||...
            strcmp(category,'VIEW')||...
            strcmp(category,'MODIFY')||...
            strcmp(category,'HDL')||...
            strcmp(category,'NONE'),...
            'Invalid relationship specified');

            if strcmp(category,'NONE')
                out='';
            else
                obj=Simulink.ModelReference.ProtectedModel.PasswordManager.Utils('getManager');
                if isKey(obj.fPasswordMap,model)
                    modelPWStruct=obj.fPasswordMap(model);
                else
                    DAStudio.error('Simulink:protectedModel:ProtectedModelPasswordNotProvided',model);
                end
                out=modelPWStruct.(category);
            end
        end

        function out=isEncryptionCategoryEncryptedOpts(category,opts)

            import Simulink.ModelReference.ProtectedModel.*;

            switch category
            case 'SIM'
                out=opts.isSimEncrypted;
            case 'RTW'
                out=opts.isRTWEncrypted;
            case 'VIEW'
                out=opts.isViewEncrypted;
            case 'MODIFY'
                out=opts.isModifyEncrypted;
            case 'HDL'
                out=opts.isHDLEncrypted;
            end
        end

        function out=isEncryptionCategoryEncrypted(model,category)

            import Simulink.ModelReference.ProtectedModel.*;

            opts=getOptions(model);
            out=PasswordManager.isEncryptionCategoryEncryptedOpts(category,opts);
        end

        function out=doesEncryptionCategoryHaveTheRightPassword(model,category)
            import Simulink.ModelReference.ProtectedModel.*;
            modelFile=getProtectedModelFileName(model);

            [~,fullName]=slInternal('getReferencedModelFileInformation',modelFile);
            opts=getOptions(fullName,'runConsistencyChecksNoPlatform');
            relationships=getRelationshipsInEncryptionCategory(model,category,opts);
            encrypted=true;
            for i=1:length(relationships)
                currentRel=relationships{i};
                [year,~]=getStaticInformationForRelationship(currentRel,getCurrentTarget(opts.modelName));
                encrypted=encrypted&&slInternal('isRelationshipEncrypted',fullName,currentRel,year);
            end

            if~encrypted
                out=encrypted;
                return;
            end



            match=true;
            for i=1:length(relationships)
                currentRel=relationships{i};
                [year,~]=getStaticInformationForRelationship(currentRel,getCurrentTarget(opts.modelName));
                match=match&&slInternal('doPasswordsMatchForRelationship',fullName,currentRel,year);
            end
            out=match;
        end

        function clearAll()
            Simulink.ModelReference.ProtectedModel.PasswordManager.Utils('clear');
        end

        function clearModel(model)
            Simulink.ModelReference.ProtectedModel.PasswordManager.Utils('clearModel',model);
        end

        function clearCertificate(certificate)
            Simulink.ModelReference.ProtectedModel.PasswordManager.Utils('clearCertificate',certificate);
        end

        function clearEncryptionCategoryForModel(model,category)
            Simulink.ModelReference.ProtectedModel.PasswordManager.Utils('clearEncryptionCategory',model,category);
        end

        function out=getDefaultPWStruct()
            out=struct('SIM',{},'RTW',{},'VIEW',{},'MODIFY',{},'HDL',{});
        end
    end
end

