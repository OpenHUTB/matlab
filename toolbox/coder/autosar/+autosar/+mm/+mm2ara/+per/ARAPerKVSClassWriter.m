function ARAPerKVSClassWriter(codeWriter,perVals,schemaVersion,modelName)





    codeWriter.wLine('#ifndef ARA_PER_KEY_VALUE_STORAGE_H');
    codeWriter.wLine('#define ARA_PER_KEY_VALUE_STORAGE_H');


    codeWriter.wLine('#include <memory>');
    if strcmp(schemaVersion,'ARA_VER_18_10')
        codeWriter.wLine('#include "ara/per/error.h"');
    else
        codeWriter.wLine('#include "ara/per/shared_handle.h"');
        codeWriter.wLine('#include "ara/per/per_error_domain.h"');
    end
    codeWriter.wLine('#include "ara/core/result.h"');
    codeWriter.wLine('#include "ara/core/string.h"');
    codeWriter.wLine('#include "ara/core/string_view.h"');
    codeWriter.wLine('#include "ara/core/instance_specifier.h"');
    codeWriter.wLine('#include "ara/core/vector.h"');
    codeWriter.wLine('#include "DDSSerializer.h"');
    codeWriter.wLine('#include "ara/per/per_storage.h"');
    codeWriter.wLine(['#include "',modelName,'_types.h"']);

    codeWriter.wBlockStart('namespace std');
    codeWriter.wLine('#if !defined(_MSC_VER) && __cplusplus <= 201103L //make_unique is defined if the platform is not Windows and C++ version is below 201103L');
    codeWriter.wLine('template<typename T, typename... Args>');
    codeWriter.wBlockStart('std::unique_ptr<T> make_unique(Args&&... args)');
    codeWriter.wLine('return std::unique_ptr<T>(new T(std::forward<Args>(args)...));');
    codeWriter.wBlockEnd();
    codeWriter.wLine('#endif');
    codeWriter.wBlockEnd();

    codeWriter.wBlockStart('namespace ara');
    codeWriter.wBlockStart('namespace per');
    if strcmp(schemaVersion,'ARA_VER_20_11')
        codeWriter.wBlockStart('class KeyValueStorage final');
    else
        codeWriter.wBlockStart('class KeyValueStorage');
    end
    codeWriter.wLine('public:');

    codeWriter.wBlockStart('KeyValueStorage(ara::core::InstanceSpecifier kvs): pImpl(std::make_unique<ara::per::PerStorage>(kvs))');
    codeWriter.wBlockEnd();


    codeWriter.wBlockStart('~KeyValueStorage() noexcept');
    codeWriter.wBlockEnd();


    codeWriter.wBlockStart('KeyValueStorage(KeyValueStorage&& rhs) noexcept: pImpl{std::move(rhs.pImpl)}');
    codeWriter.wBlockEnd();


    codeWriter.wLine('KeyValueStorage(const KeyValueStorage& rhs) = delete;');


    codeWriter.wBlockStart('KeyValueStorage& operator=(KeyValueStorage&& rhs) noexcept')
    codeWriter.wLine('pImpl = std::move(rhs.pImpl);');
    codeWriter.wLine('return *this;');
    codeWriter.wBlockEnd();


    codeWriter.wLine('KeyValueStorage& operator=(const KeyValueStorage& rhs) = delete;');


    codeWriter.wBlockStart('ara::core::Result<void> RemoveKey(ara::core::StringView key) noexcept')
    codeWriter.wLine('return pImpl->RemoveKey(key);');
    codeWriter.wBlockEnd();


    codeWriter.wBlockStart('ara::core::Result<void> RemoveAllKeys() noexcept')
    codeWriter.wLine('return pImpl->RemoveAllKeys();');
    codeWriter.wBlockEnd();


    codeWriter.wBlockStart('ara::core::Result<void> SyncToStorage() noexcept')
    codeWriter.wLine('return pImpl->SyncToStorage();');
    codeWriter.wBlockEnd();


    if strcmp(schemaVersion,'ARA_VER_18_10')
        codeWriter.wBlockStart('bool HasKey(ara::core::StringView key) const noexcept')
        codeWriter.wLine('return pImpl->HasKey(key);');
    elseif strcmp(schemaVersion,'ARA_VER_19_03')||strcmp(schemaVersion,'ARA_VER_19_11')
        codeWriter.wBlockStart('ara::core::Result<bool> HasKey(ara::core::StringView key) const noexcept')
        codeWriter.wLine('return pImpl->HasKey(key);');
    else
        codeWriter.wBlockStart('ara::core::Result<bool> KeyExists(ara::core::StringView key) const noexcept')
        codeWriter.wLine('return pImpl->KeyExists(key);');
    end
    codeWriter.wBlockEnd();


    if strcmp(schemaVersion,'ARA_VER_18_10')
        codeWriter.wBlockStart('ara::core::Vector<ara::core::String> GetAllKeys() const noexcept')
    else
        codeWriter.wBlockStart('ara::core::Result<ara::core::Vector<ara::core::String>> GetAllKeys() const noexcept')
    end
    codeWriter.wLine('return pImpl->GetAllKeys();');
    codeWriter.wBlockEnd();


    if~strcmp(schemaVersion,'ARA_VER_18_10')
        if strcmp(schemaVersion,'ARA_VER_19_03')
            codeWriter.wBlockStart('ara::core::Result<void> DiscardPendingChanges() const noexcept')
        else
            codeWriter.wBlockStart('ara::core::Result<void> DiscardPendingChanges() noexcept')
        end
        codeWriter.wLine('return pImpl->DiscardPendingChanges();');
        codeWriter.wBlockEnd();
    end


    codeWriter.wLine('template <class T>');
    codeWriter.wBlockStart('ara::core::Result<void> SetValue(ara::core::StringView key, const T& value) noexcept');
    codeWriter.wLine('T* val = (const_cast<T *>(std::addressof(value)));');
    codeWriter.wLine('std::string stringValue;');
    writeRTPSDynamicStruct_MultiArraySerializer(codeWriter,perVals);
    codeWriter.wLine('pImpl->SetValue(key, stringValue);');
    codeWriter.wLine('return ara::core::Result<void>::FromValue();');
    codeWriter.wBlockEnd();


    codeWriter.wLine('template <class T>');
    codeWriter.wBlockStart('ara::core::Result<void> GetValue(ara::core::StringView key, T& value) const noexcept');
    codeWriter.wLine('std::string stringValue;');
    codeWriter.wBlockStart('if(pImpl->GetValue(key, stringValue))');
    writeRTPSDynamicStruct_MultiArrayDeSerializer(codeWriter,perVals);
    codeWriter.wBlockEnd();
    codeWriter.wLine('return ara::core::Result<void>::FromValue();');
    codeWriter.wBlockEnd();


    codeWriter.wLine('template <class T>');
    codeWriter.wBlockStart('ara::core::Result<T> GetValue(ara::core::StringView key) const noexcept');
    codeWriter.wLine('std::string stringValue;');
    codeWriter.wLine('T value;');
    codeWriter.wBlockStart('if(pImpl->GetValue(key, stringValue))');
    writeRTPSDynamicStruct_MultiArrayDeSerializer(codeWriter,perVals);
    codeWriter.wLine('return ara::core::Result<T>::FromValue(value);');
    codeWriter.wBlockEnd();
    if strcmp(schemaVersion,'ARA_VER_20_11')
        codeWriter.wLine('return ara::core::Result<T>::FromError(ara::per::PerErrc::kKeyNotFound);');
    else
        codeWriter.wLine('return ara::core::Result<T>::FromError(ara::per::PerErrc::kKeyNotFoundError);');
    end
    codeWriter.wBlockEnd();

    codeWriter.wLine('private:');
    codeWriter.wLine('std::unique_ptr<ara::per::PerStorage> pImpl;');

    codeWriter.wBlockEnd();
    codeWriter.wLine(';');

    if strcmp(schemaVersion,'ARA_VER_18_10')

        codeWriter.wBlockStart('inline ara::core::Result<std::unique_ptr<KeyValueStorage>> CreateKeyValueStorage(ara::core::StringView database) noexcept');
        codeWriter.wLine('ara::core::InstanceSpecifier kvs = ara::core::InstanceSpecifier(database);');
        codeWriter.wLine('auto dbStorage = _CreateKeyValueStorage(database, sizeof(KeyValueStorage));');
        codeWriter.wBlockStart('if (dbStorage.second)');
        codeWriter.wLine('std::unique_ptr<KeyValueStorage> handle = std::make_unique<KeyValueStorage>(kvs);');
        codeWriter.wLine('return ara::core::Result<std::unique_ptr<KeyValueStorage>>::FromValue(std::move(handle));');
        codeWriter.wBlockEnd();
        codeWriter.wLine('return ara::core::Result<std::unique_ptr<KeyValueStorage>>::FromError(ara::per::MakeErrorCode(ara::per::PerErrc::kPhysicalStorageError, 0, NULL));');
        codeWriter.wBlockEnd();
    else

        if strcmp(schemaVersion,'ARA_VER_20_11')
            codeWriter.wBlockStart('inline ara::core::Result<SharedHandle<KeyValueStorage>> OpenKeyValueStorage(const ara::core::InstanceSpecifier& kvs) noexcept');
        else
            codeWriter.wBlockStart('inline ara::core::Result<SharedHandle<KeyValueStorage>> OpenKeyValueStorage(ara::core::InstanceSpecifier kvs) noexcept');
        end
        codeWriter.wLine('auto dbStorage = _OpenKeyValueStorage(kvs, sizeof(KeyValueStorage));');
        codeWriter.wBlockStart('if (dbStorage.second)');
        codeWriter.wLine('new(dbStorage.first.get()) KeyValueStorage(kvs);');
        codeWriter.wBlockEnd();
        codeWriter.wLine('std::shared_ptr<KeyValueStorage> handle = std::static_pointer_cast<KeyValueStorage>(dbStorage.first);');
        codeWriter.wBlockStart('if(handle == nullptr)')
        if strcmp(schemaVersion,'ARA_VER_20_11')
            codeWriter.wLine('return ara::core::Result<SharedHandle<KeyValueStorage>>::FromError(ara::per::MakeErrorCode(ara::per::PerErrc::kPhysicalStorageFailure, 0, NULL));');
        else
            codeWriter.wLine('return ara::core::Result<SharedHandle<KeyValueStorage>>::FromError(ara::per::MakeErrorCode(ara::per::PerErrc::kPhysicalStorageError, 0, NULL));');
        end
        codeWriter.wBlockEnd()
        codeWriter.wBlockStart('else')
        codeWriter.wLine('return ara::core::Result<SharedHandle<KeyValueStorage>>::FromValue(handle);');
        codeWriter.wBlockEnd();
        codeWriter.wBlockEnd();
    end

    codeWriter.wBlockEnd('namespace per');
    codeWriter.wBlockEnd('namespace ara');

    codeWriter.wLine('#endif //ARA_PER_KEY_VALUE_STORAGE_H');
    codeWriter.close();

end

function writeRTPSDynamicStruct_MultiArraySerializer(codeWriter,perVals)
    structTypes=containers.Map;
    codeWriter.wBlockStart('if(std::is_same<T, void>::value)');
    for ii=1:numel(perVals)
        dataElements=perVals{ii}.Interface.DataElements;
        for jj=1:dataElements.size()
            if~isempty(dataElements.at(jj).Type)
                elemDataType=dataElements.at(jj).Type;
                if isa(elemDataType,'Simulink.metamodel.types.Matrix')
                    elemDataBaseType=elemDataType.BaseType;
                else
                    elemDataBaseType=elemDataType;
                end


                if isa(elemDataBaseType,'Simulink.metamodel.types.Structure')||...
                    isa(elemDataBaseType,'Simulink.metamodel.types.Matrix')
                    structTypeName=autosar.mm.mm2ara.TypeWriter.getUsingTypeName(elemDataType);
                    if(structTypes.isKey(structTypeName))
                        continue;
                    end
                    structTypes(structTypeName)=1;
                    codeWriter.wBlockMiddle(['else if(std::is_same<T,',structTypeName,'>::value)'])
                    lambdaNum=0;
                    autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.generateSerializationLambda(codeWriter,lambdaNum,elemDataType);
                    codeWriter.wLine(['stringValue = ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getLambdaName(lambdaNum),'(*val);']);
                end
            end
        end
    end
    codeWriter.wBlockMiddle('else ');
    codeWriter.wLine('stringValue = ara::com::_RtpsSerialize<T>{ }(*val);');
    codeWriter.wBlockEnd();

end

function writeRTPSDynamicStruct_MultiArrayDeSerializer(codeWriter,perVals)
    structTypes=containers.Map;
    codeWriter.wBlockStart('if(std::is_same<T, void>::value)');
    for ii=1:numel(perVals)
        dataElements=perVals{ii}.Interface.DataElements;
        for jj=1:dataElements.size()
            if~isempty(dataElements.at(jj).Type)
                elemDataType=dataElements.at(jj).Type;
                if isa(elemDataType,'Simulink.metamodel.types.Matrix')
                    elemDataBaseType=elemDataType.BaseType;
                else
                    elemDataBaseType=elemDataType;
                end


                if isa(elemDataBaseType,'Simulink.metamodel.types.Structure')||...
                    isa(elemDataBaseType,'Simulink.metamodel.types.Matrix')
                    structTypeName=autosar.mm.mm2ara.TypeWriter.getUsingTypeName(elemDataType);
                    if(structTypes.isKey(structTypeName))
                        continue;
                    end
                    structTypes(structTypeName)=1;
                    codeWriter.wBlockMiddle(['else if(std::is_same<T,',structTypeName,'>::value)'])
                    lambdaNum=0;
                    autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.generateDeserializationLambda(codeWriter,lambdaNum,elemDataType);
                    codeWriter.wLine('size_t st = 0;');
                    codeWriter.wLine(['value = ',autosar.mm.mm2ara.com.RtpsSerializerWriterUtils.getLambdaName(lambdaNum),'(st, stringValue);']);
                end
            end
        end
    end
    codeWriter.wBlockMiddle('else ');
    codeWriter.wLine('value = ara::com::_RtpsDeserialize<T>{ }(0, stringValue);');
    codeWriter.wBlockEnd();
end


